-- =====================================================================
-- diali — RLS / authorization test suite
-- ---------------------------------------------------------------------
-- Runs against a real PostgreSQL instance carrying the diali migrations
-- plus tool/rls_verify/supabase_shim.sql. Acts as anon / viewer / staff /
-- admin / owner using SET ROLE + JWT claims (as PostgREST does).
--
-- Exits non-zero (via a final RAISE) if any assertion fails, so it can be
-- used in CI. See README.md for what this does and does NOT cover.
-- =====================================================================
\set ON_ERROR_STOP off

-- ---------------------------------------------------------------------
-- Fixtures (superuser: RLS bypassed)
-- ---------------------------------------------------------------------
INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000001','owner@diali.test','{"full_name":"Owner"}'),
 ('00000000-0000-0000-0000-000000000002','admin@diali.test','{"full_name":"Admin"}'),
 ('00000000-0000-0000-0000-000000000003','staff@diali.test','{"full_name":"Staff"}'),
 ('00000000-0000-0000-0000-000000000004','viewer@diali.test','{"full_name":"Viewer"}')
ON CONFLICT (id) DO NOTHING;

UPDATE public.profiles SET role='owner'  WHERE id='00000000-0000-0000-0000-000000000001';
UPDATE public.profiles SET role='admin'  WHERE id='00000000-0000-0000-0000-000000000002';
UPDATE public.profiles SET role='staff'  WHERE id='00000000-0000-0000-0000-000000000003';
UPDATE public.profiles SET role='viewer' WHERE id='00000000-0000-0000-0000-000000000004';

INSERT INTO categories (id, name, slug) VALUES
 ('11111111-1111-1111-1111-111111111111','Gadgets','gadgets') ON CONFLICT DO NOTHING;
INSERT INTO products (id, name, sku, price, stock_qty, status, category_id) VALUES
 ('22222222-2222-2222-2222-222222222221','Active Widget','WID-1',10.00,10,'active',
  '11111111-1111-1111-1111-111111111111'),
 ('22222222-2222-2222-2222-222222222222','Draft Widget','WID-2',20.00,5,'draft',
  '11111111-1111-1111-1111-111111111111'),
 ('dddddddd-dddd-dddd-dddd-ddddddddddd1','Owner-only Widget','OOW-1',5.00,10,'active',NULL)
ON CONFLICT DO NOTHING;
INSERT INTO page_categories (id, name, slug) VALUES
 ('33333333-3333-3333-3333-333333333331','News','news') ON CONFLICT DO NOTHING;
INSERT INTO pages (id, title, slug, status, category_id) VALUES
 ('44444444-4444-4444-4444-444444444441','Published Post','pub-post','published',
  '33333333-3333-3333-3333-333333333331'),
 ('44444444-4444-4444-4444-444444444442','Draft Post','draft-post','draft',
  '33333333-3333-3333-3333-333333333331')
ON CONFLICT DO NOTHING;
INSERT INTO customers (id, name, email) VALUES
 ('55555555-5555-5555-5555-555555555551','Alice','alice@example.com') ON CONFLICT DO NOTHING;
INSERT INTO orders (id, order_number, customer_id, total) VALUES
 ('66666666-6666-6666-6666-666666666661','ORD-1','55555555-5555-5555-5555-555555555551',10.00)
ON CONFLICT DO NOTHING;
INSERT INTO locations (id, name) VALUES
 ('77777777-7777-7777-7777-777777777771','Main WH') ON CONFLICT DO NOTHING;
INSERT INTO tracking_events (id, product_id, status) VALUES
 ('88888888-8888-8888-8888-888888888881','22222222-2222-2222-2222-222222222221','inStock')
ON CONFLICT DO NOTHING;
INSERT INTO resources (id, name, is_published) VALUES
 ('99999999-9999-9999-9999-999999999991','Private Doc', false) ON CONFLICT DO NOTHING;
INSERT INTO form_definitions (id, title, slug, status) VALUES
 ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1','Contact','contact','published'),
 ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2','Draft Form','draft-form','draft')
ON CONFLICT DO NOTHING;
INSERT INTO website_templates (id, name, slug, is_published) VALUES
 ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1','Hidden Theme','hidden-theme', false)
ON CONFLICT DO NOTHING;
INSERT INTO storage.objects (id, bucket_id, name, owner) VALUES
 ('cccccccc-cccc-cccc-cccc-ccccccccccc1','products','p1.png',NULL),
 ('cccccccc-cccc-cccc-cccc-ccccccccccc2','resources','secret/plan.pdf',NULL),
 ('cccccccc-cccc-cccc-cccc-ccccccccccc3','avatars','00000000-0000-0000-0000-000000000003',
  '00000000-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- Harness
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS _rls_results;
CREATE TABLE _rls_results (label text, ok boolean, detail text);
GRANT INSERT, SELECT ON _rls_results TO anon, authenticated;

CREATE OR REPLACE FUNCTION _expect_rows(label text, expected int, sql text)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE n int;
BEGIN
  EXECUTE 'SELECT count(*)::int FROM (' || sql || ') q' INTO n;
  INSERT INTO _rls_results VALUES (label, n = expected, 'rows=' || n || ' expected=' || expected);
EXCEPTION WHEN OTHERS THEN
  INSERT INTO _rls_results VALUES (label, false, 'raised: ' || SQLERRM);
END $$;

CREATE OR REPLACE FUNCTION _expect_affected(label text, expected int, sql text)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE n int;
BEGIN
  EXECUTE sql;
  GET DIAGNOSTICS n = ROW_COUNT;
  INSERT INTO _rls_results VALUES (label, n = expected, 'affected=' || n || ' expected=' || expected);
EXCEPTION WHEN OTHERS THEN
  INSERT INTO _rls_results VALUES (label, false, 'raised: ' || SQLERRM);
END $$;

CREATE OR REPLACE FUNCTION _expect_ok(label text, sql text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE sql;
  INSERT INTO _rls_results VALUES (label, true, 'succeeded');
EXCEPTION WHEN OTHERS THEN
  INSERT INTO _rls_results VALUES (label, false, 'raised: ' || SQLERRM);
END $$;

CREATE OR REPLACE FUNCTION _expect_err(label text, sql text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE sql;
  INSERT INTO _rls_results VALUES (label, false, 'unexpected success');
EXCEPTION WHEN OTHERS THEN
  INSERT INTO _rls_results VALUES (label, true, 'blocked [' || SQLSTATE || ']: ' || SQLERRM);
END $$;

GRANT EXECUTE ON FUNCTION
  _expect_rows(text,int,text), _expect_affected(text,int,text),
  _expect_ok(text,text), _expect_err(text,text)
TO anon, authenticated;

-- =====================================================================
-- ACTOR: anon (public visitor, no JWT)
-- =====================================================================
RESET ROLE;
SET request.jwt.claims = '{"role":"anon"}';
SET ROLE anon;

SELECT _expect_rows('anon reads active products', 2, 'SELECT 1 FROM products WHERE status=''active''');
SELECT _expect_rows('anon cannot read draft products', 0, 'SELECT 1 FROM products WHERE status=''draft''');
SELECT _expect_rows('anon cannot read customers', 0, 'SELECT 1 FROM customers');
SELECT _expect_rows('anon cannot read orders', 0, 'SELECT 1 FROM orders');
SELECT _expect_rows('anon cannot read order_items', 0, 'SELECT 1 FROM order_items');
SELECT _expect_rows('anon cannot read locations', 0, 'SELECT 1 FROM locations');
SELECT _expect_rows('anon cannot read stock_movements', 0, 'SELECT 1 FROM stock_movements');
SELECT _expect_rows('anon cannot read tracking_events', 0, 'SELECT 1 FROM tracking_events');
SELECT _expect_rows('anon cannot read resources table', 0, 'SELECT 1 FROM resources');
SELECT _expect_rows('anon cannot read form_submissions', 0, 'SELECT 1 FROM form_submissions');
SELECT _expect_rows('anon cannot read product_images', 0, 'SELECT 1 FROM product_images');
SELECT _expect_rows('anon cannot read app_settings', 0, 'SELECT 1 FROM app_settings');
SELECT _expect_rows('anon cannot read profiles', 0, 'SELECT 1 FROM profiles');
SELECT _expect_rows('anon can read categories', 1, 'SELECT 1 FROM categories');
SELECT _expect_rows('anon reads published pages only', 1, 'SELECT 1 FROM pages');
SELECT _expect_rows('anon can read site_settings', 1, 'SELECT 1 FROM site_settings');
SELECT _expect_rows('anon reads published templates only', 3, 'SELECT 1 FROM website_templates');
SELECT _expect_rows('anon reads published forms only', 1, 'SELECT 1 FROM form_definitions');
SELECT _expect_err('anon cannot insert products',
  'INSERT INTO products (name) VALUES (''hax'')');
SELECT _expect_affected('anon cannot update products', 0,
  'UPDATE products SET name=''hax'' WHERE id=''22222222-2222-2222-2222-222222222221''');
SELECT _expect_affected('anon cannot delete products', 0,
  'DELETE FROM products WHERE id=''22222222-2222-2222-2222-222222222221''');
SELECT _expect_rows('products name unchanged after anon update attempt', 1,
  'SELECT 1 FROM products WHERE id=''22222222-2222-2222-2222-222222222221'' AND name=''Active Widget''');
SELECT _expect_ok('anon submits to published form',
  'INSERT INTO form_submissions (form_id, payload) VALUES
    (''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'', jsonb_build_object(''msg'',''hi''))');
SELECT _expect_err('anon cannot submit to draft form',
  'INSERT INTO form_submissions (form_id, payload) VALUES
    (''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'', ''{}''::jsonb)');
SELECT _expect_rows('anon cannot read private resources bucket', 0,
  'SELECT 1 FROM storage.objects WHERE bucket_id=''resources''');
SELECT _expect_ok('anon can read products bucket',
  'SELECT 1 FROM storage.objects WHERE bucket_id=''products''');
SELECT _expect_err('anon cannot write resources bucket',
  'INSERT INTO storage.objects (bucket_id, name) VALUES (''resources'',''x/y.pdf'')');
SELECT _expect_err('anon cannot call place_order',
  'SELECT public.place_order(''{"order_number":"HACK"}''::jsonb,
     ''[{"product_name":"x","qty":1,"unit_price":1,"subtotal":1}]''::jsonb)');

-- =====================================================================
-- ACTOR: viewer (read-only)
-- =====================================================================
RESET ROLE;
SET request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000004","role":"authenticated","email":"viewer@diali.test"}';
SET ROLE authenticated;

SELECT _expect_rows('viewer reads customers', 1, 'SELECT 1 FROM customers');
SELECT _expect_rows('viewer reads orders', 1, 'SELECT 1 FROM orders');
SELECT _expect_rows('viewer reads all profiles', 4, 'SELECT 1 FROM profiles');
SELECT _expect_rows('viewer reads app_settings', 1,
  'SELECT 1 FROM app_settings WHERE key=''currency''');
SELECT _expect_err('viewer cannot insert products',
  'INSERT INTO products (name) VALUES (''v'')');
SELECT _expect_err('viewer cannot insert customers',
  'INSERT INTO customers (name) VALUES (''v'')');
SELECT _expect_ok('viewer can edit own profile (non-role field)',
  'UPDATE profiles SET full_name=''Viewer Edit'' WHERE id=''00000000-0000-0000-0000-000000000004''');
SELECT _expect_err('viewer cannot self-promote',
  'UPDATE profiles SET role=''owner'' WHERE id=''00000000-0000-0000-0000-000000000004''');
SELECT _expect_err('viewer cannot place orders',
  'SELECT public.place_order(''{"order_number":"V-1","total":1}''::jsonb,
     ''[{"product_name":"x","qty":1,"unit_price":1,"subtotal":1}]''::jsonb)');

-- =====================================================================
-- ACTOR: staff (operational write)
-- =====================================================================
RESET ROLE;
SET request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000003","role":"authenticated","email":"staff@diali.test"}';
SET ROLE authenticated;

SELECT _expect_rows('staff reads customers', 1, 'SELECT 1 FROM customers');
SELECT _expect_ok('staff can insert products',
  'INSERT INTO products (name, sku, price, stock_qty) VALUES (''Staff P'',''STF-1'',5,10)');
SELECT _expect_affected('staff cannot manage templates', 0,
  'UPDATE website_templates SET name=''x'' WHERE id=''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1''');
SELECT _expect_rows('template unchanged after staff attempt', 1,
  'SELECT 1 FROM website_templates WHERE id=''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1'' AND name=''Hidden Theme''');
SELECT _expect_err('staff cannot insert app_settings',
  'INSERT INTO app_settings (key, value) VALUES (''hax'',''{}''::jsonb)');
SELECT _expect_ok('staff uploads avatar under own uid',
  'INSERT INTO storage.objects (bucket_id, name) VALUES
    (''avatars'',''00000000-0000-0000-0000-000000000003/me.png'')');
SELECT _expect_err('staff cannot upload avatar under another uid',
  'INSERT INTO storage.objects (bucket_id, name) VALUES
    (''avatars'',''00000000-0000-0000-0000-000000000001/steal.png'')');
SELECT _expect_ok('staff can read private resources bucket',
  'SELECT 1 FROM storage.objects WHERE bucket_id=''resources''');

-- place_order: happy path + stock ledger + rejections
SELECT _expect_ok('staff places a valid order',
  'SELECT public.place_order(''{"order_number":"ORD-STAFF-1","total":30,"subtotal":30}''::jsonb,
     ''[{"product_id":"22222222-2222-2222-2222-222222222221","product_name":"Active Widget","qty":3,"unit_price":10,"subtotal":30}]''::jsonb)');
SELECT _expect_rows('stock decreased by 3 after order', 1,
  'SELECT 1 FROM products WHERE id=''22222222-2222-2222-2222-222222222221'' AND stock_qty=7');
SELECT _expect_rows('stock movement row recorded', 1,
  'SELECT 1 FROM stock_movements WHERE reference=''ORD-STAFF-1'' AND delta=-3');
SELECT _expect_err('order rejected on insufficient stock',
  'SELECT public.place_order(''{"order_number":"ORD-STAFF-2","total":1000}''::jsonb,
     ''[{"product_id":"22222222-2222-2222-2222-222222222221","product_name":"Active Widget","qty":9999,"unit_price":1,"subtotal":9999}]''::jsonb)');
SELECT _expect_rows('failed order did not persist', 0,
  'SELECT 1 FROM orders WHERE order_number=''ORD-STAFF-2''');
SELECT _expect_err('order rejected on non-positive qty',
  'SELECT public.place_order(''{"order_number":"ORD-STAFF-3","total":1}''::jsonb,
     ''[{"product_name":"x","qty":0,"unit_price":1,"subtotal":1}]''::jsonb)');
SELECT _expect_err('order rejected with no items',
  'SELECT public.place_order(''{"order_number":"ORD-STAFF-4","total":1}''::jsonb, ''[]''::jsonb)');
SELECT _expect_err('order rejected with negative amount',
  'SELECT public.place_order(''{"order_number":"ORD-STAFF-5","total":-5}''::jsonb,
     ''[{"product_name":"x","qty":1,"unit_price":1,"subtotal":1}]''::jsonb)');
SELECT _expect_err('oversized form payload rejected',
  'INSERT INTO form_submissions (form_id, payload) VALUES
    (''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'', jsonb_build_object(''blob'', repeat(''a'', 300000)))');

-- =====================================================================
-- ACTOR: admin (config write; still cannot change roles)
-- =====================================================================
RESET ROLE;
SET request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000002","role":"authenticated","email":"admin@diali.test"}';
SET ROLE authenticated;

SELECT _expect_ok('admin can manage templates',
  'UPDATE website_templates SET name=''Admin Theme'' WHERE id=''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1''');
SELECT _expect_ok('admin can write app_settings',
  'INSERT INTO app_settings (key, value) VALUES (''admin_key'',''{}''::jsonb) ON CONFLICT (key) DO NOTHING');
SELECT _expect_ok('admin can read profiles', 'SELECT 1 FROM profiles');
SELECT _expect_err('admin cannot self-promote to owner',
  'UPDATE profiles SET role=''owner'' WHERE id=''00000000-0000-0000-0000-000000000002''');
SELECT _expect_err('admin cannot promote another user to owner',
  'UPDATE profiles SET role=''owner'' WHERE id=''00000000-0000-0000-0000-000000000004''');
SELECT _expect_ok('admin can edit a user''s non-role fields',
  'UPDATE profiles SET full_name=''Renamed by admin'' WHERE id=''00000000-0000-0000-0000-000000000004''');

-- =====================================================================
-- ACTOR: owner (can change roles)
-- =====================================================================
RESET ROLE;
SET request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated","email":"owner@diali.test"}';
SET ROLE authenticated;

SELECT _expect_ok('owner can manage templates',
  'UPDATE website_templates SET name=''Owner Theme'' WHERE id=''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1''');
SELECT _expect_ok('owner can write app_settings',
  'INSERT INTO app_settings (key, value) VALUES (''owner_key'',''{}''::jsonb) ON CONFLICT (key) DO NOTHING');
SELECT _expect_ok('owner can promote a user',
  'UPDATE profiles SET role=''staff'' WHERE id=''00000000-0000-0000-0000-000000000004''');

-- reset viewer for cleanliness
RESET ROLE;
UPDATE public.profiles SET role='viewer' WHERE id='00000000-0000-0000-0000-000000000004';

-- =====================================================================
-- place_order EXECUTE grants + bootstrap paths
-- =====================================================================
RESET ROLE;
RESET request.jwt.claims;

SELECT _expect_rows('anon has NO EXECUTE on place_order', 1,
  $$SELECT 1 WHERE NOT has_function_privilege('anon','public.place_order(jsonb,jsonb)','EXECUTE')$$);
SELECT _expect_rows('authenticated has EXECUTE on place_order', 1,
  $$SELECT 1 WHERE has_function_privilege('authenticated','public.place_order(jsonb,jsonb)','EXECUTE')$$);
SELECT _expect_rows('place_order not executable by PUBLIC', 0,
  $$SELECT 1 FROM information_schema.routine_privileges
     WHERE routine_name='place_order' AND grantee='PUBLIC'$$);

-- Bootstrap paths: postgres (SQL editor) and service_role may change roles
SELECT _expect_ok('postgres may bootstrap/repair roles',
  'UPDATE public.profiles SET role=''admin'' WHERE id=''00000000-0000-0000-0000-000000000002''');
SET ROLE service_role;
SELECT _expect_ok('service_role may change roles',
  'UPDATE public.profiles SET role=''admin'' WHERE id=''00000000-0000-0000-0000-000000000002''');
RESET ROLE;

-- staff can still place an order after all grants changes
SET request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000003","role":"authenticated"}';
SET ROLE authenticated;
SELECT _expect_ok('staff can still place an order',
  'SELECT public.place_order(''{"order_number":"OWN-1","total":5,"subtotal":5}''::jsonb,
     ''[{"product_id":"dddddddd-dddd-dddd-dddd-ddddddddddd1","product_name":"Owner-only Widget","qty":1,"unit_price":5,"subtotal":5}]''::jsonb)');
SELECT _expect_rows('owner-only widget stock decremented', 1,
  'SELECT 1 FROM products WHERE id=''dddddddd-dddd-dddd-dddd-ddddddddddd1'' AND stock_qty=9');

-- =====================================================================
-- Structural checks (superuser)
-- =====================================================================
RESET ROLE;
RESET request.jwt.claims;

SELECT _expect_rows('RLS enabled on every public app table', 0,
  $$SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
     WHERE n.nspname='public' AND c.relkind='r' AND c.relname NOT LIKE '\_%'
       AND c.relrowsecurity = false$$);
SELECT _expect_rows('private resources bucket is not public', 1,
  $$SELECT 1 FROM storage.buckets WHERE id='resources' AND public=false$$);
SELECT _expect_rows('private resources bucket has explicit MIME allow-list', 1,
  $$SELECT 1 FROM storage.buckets WHERE id='resources' AND allowed_mime_types IS NOT NULL$$);
SELECT _expect_rows('profiles.role defaults to viewer', 1,
  $$SELECT 1 FROM information_schema.columns
     WHERE table_name='profiles' AND column_name='role' AND column_default LIKE '%viewer%'$$);

-- =====================================================================
-- RESULTS
-- =====================================================================
\echo ''
\echo '================ RLS TEST RESULTS ================'
SELECT count(*) FILTER (WHERE ok)     AS passed,
       count(*) FILTER (WHERE NOT ok) AS failed,
       count(*)                       AS total
FROM _rls_results;
\echo '--- failures (empty = all good) ---'
SELECT label, detail FROM _rls_results WHERE NOT ok ORDER BY label;

-- Fail the run (non-zero exit) if anything regressed.
\set ON_ERROR_STOP on
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM _rls_results WHERE NOT ok;
  IF n > 0 THEN
    RAISE EXCEPTION '% RLS assertion(s) failed', n;
  END IF;
END $$;
