-- =====================================================================
-- DIALI — INITIAL SCHEMA (single-business, no multi-tenancy)
-- =====================================================================
-- Conventions:
--   * uuid primary keys (gen_random_uuid)
--   * timestamptz for all timestamps, default now()
--   * numeric(12,2) for money (never float)
--   * RLS enabled on every table; default deny when no policy matches
--   * public read is limited to explicitly published records only
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------
-- ENUMS
-- ---------------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('owner', 'admin', 'staff', 'viewer');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE product_status AS ENUM ('active', 'draft', 'archived');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE customer_tier AS ENUM ('regular', 'vip');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE order_status AS ENUM ('pending', 'paid', 'shipped', 'delivered', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE resource_type AS ENUM ('document', 'spreadsheet', 'image', 'folder', 'other');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE form_status AS ENUM ('draft', 'published', 'archived');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE page_status AS ENUM ('draft', 'published');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE location_type AS ENUM ('warehouse', 'store', 'office', 'customer', 'shipping', 'other');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------
-- 1. PROFILES (maps auth.users -> role)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   text NOT NULL DEFAULT '',
  avatar_url  text,
  role        user_role NOT NULL DEFAULT 'owner',
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 2. LOOKUP / INVENTORY LOCATIONS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS locations (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  type          location_type NOT NULL DEFAULT 'warehouse',
  address       text,
  city          text,
  country       text,
  latitude      double precision,
  longitude     double precision,
  contact_person text,
  contact_phone text,
  is_default    boolean NOT NULL DEFAULT false,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 3. CATEGORIES (product)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  slug        text NOT NULL UNIQUE,
  description text,
  parent_id   uuid REFERENCES categories(id) ON DELETE SET NULL,
  position    int NOT NULL DEFAULT 0,
  image_url   text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 4. PRODUCTS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name                text NOT NULL,
  description         text,
  sku                 text UNIQUE,
  category_id         uuid REFERENCES categories(id) ON DELETE SET NULL,
  location_id         uuid REFERENCES locations(id) ON DELETE SET NULL,
  tracking_status     text NOT NULL DEFAULT 'inStock',
  tracking_code       text,
  price               numeric(12,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
  cost_price          numeric(12,2) CHECK (cost_price IS NULL OR cost_price >= 0),
  stock_qty           int NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  low_stock_threshold int NOT NULL DEFAULT 5 CHECK (low_stock_threshold >= 0),
  unit                text NOT NULL DEFAULT 'unit',
  image_url           text,
  extra_images        jsonb NOT NULL DEFAULT '[]'::jsonb,
  is_demo             boolean NOT NULL DEFAULT false,
  status              product_status NOT NULL DEFAULT 'active',
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 5. PRODUCT IMAGES (ordered gallery)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_images (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url        text NOT NULL,
  alt        text,
  position   int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 6. STOCK MOVEMENTS (append-only inventory ledger)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stock_movements (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id    uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  delta         int NOT NULL CHECK (delta <> 0),
  resulting_qty int,
  reason        text NOT NULL DEFAULT 'adjustment',
  reference     text,
  actor_name    text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 7. TRACKING EVENTS (product shipment / status history)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tracking_events (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id       uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  status           text NOT NULL,
  status_title     text,
  location_id      uuid REFERENCES locations(id) ON DELETE SET NULL,
  location_name    text,
  location_address text,
  latitude         double precision,
  longitude        double precision,
  actor_name       text,
  actor_role       text,
  description      text,
  reference_number text,
  notes            text,
  occurred_at      timestamptz NOT NULL DEFAULT now(),
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 8. CUSTOMERS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text NOT NULL,
  email        text UNIQUE,
  phone        text,
  address      text,
  city         text,
  country      text,
  tier         customer_tier NOT NULL DEFAULT 'regular',
  notes        text,
  total_orders int NOT NULL DEFAULT 0,
  total_spent  numeric(12,2) NOT NULL DEFAULT 0,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 9. ORDERS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number     text NOT NULL UNIQUE,
  customer_id      uuid REFERENCES customers(id) ON DELETE SET NULL,
  status           order_status NOT NULL DEFAULT 'pending',
  subtotal         numeric(12,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
  discount         numeric(12,2) NOT NULL DEFAULT 0 CHECK (discount >= 0),
  tax              numeric(12,2) NOT NULL DEFAULT 0 CHECK (tax >= 0),
  shipping_fee     numeric(12,2) NOT NULL DEFAULT 0 CHECK (shipping_fee >= 0),
  total            numeric(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
  customer_name    text,
  customer_email   text,
  shipping_address text,
  shipping_city    text,
  notes            text,
  paid_at          timestamptz,
  delivered_at     timestamptz,
  cancelled_at     timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 10. ORDER ITEMS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_items (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id   uuid REFERENCES products(id) ON DELETE SET NULL,
  product_name text NOT NULL,
  product_sku  text,
  unit_price   numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  qty          int NOT NULL CHECK (qty > 0),
  subtotal     numeric(12,2) NOT NULL CHECK (subtotal >= 0),
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 11. ARTICLE / PAGE CATEGORIES
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS page_categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  slug        text NOT NULL UNIQUE,
  description text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 12. PAGES / ARTICLES (CMS)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title        text NOT NULL,
  slug         text NOT NULL UNIQUE,
  excerpt      text,
  content      text,
  image_url    text,
  category_id  uuid REFERENCES page_categories(id) ON DELETE SET NULL,
  status       page_status NOT NULL DEFAULT 'draft',
  meta_title   text,
  meta_desc    text,
  published_at timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 13. RESOURCES
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS resources (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text NOT NULL,
  description  text,
  type         resource_type NOT NULL DEFAULT 'document',
  category     text,
  url          text,
  contact      text,
  location     text,
  image_url    text,
  is_published boolean NOT NULL DEFAULT false,
  storage_path text,
  storage_size bigint,
  mime_type    text,
  folder_id    uuid REFERENCES resources(id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 14. FORMS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS form_definitions (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title             text NOT NULL,
  description       text,
  slug              text NOT NULL UNIQUE,
  status            form_status NOT NULL DEFAULT 'draft',
  fields            jsonb NOT NULL DEFAULT '[]'::jsonb,
  submissions_count int NOT NULL DEFAULT 0,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS form_submissions (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id    uuid NOT NULL REFERENCES form_definitions(id) ON DELETE CASCADE,
  payload    jsonb NOT NULL DEFAULT '{}'::jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 15. INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_location ON products(location_id);
CREATE INDEX IF NOT EXISTS idx_product_images_product ON product_images(product_id, position);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product ON stock_movements(product_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tracking_events_product ON tracking_events(product_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_customers_tier ON customers(tier);
CREATE INDEX IF NOT EXISTS idx_pages_status ON pages(status);
CREATE INDEX IF NOT EXISTS idx_pages_category ON pages(category_id);
CREATE INDEX IF NOT EXISTS idx_resources_type ON resources(type);

-- =====================================================================
-- HELPER FUNCTIONS (SECURITY DEFINER to avoid RLS recursion on profiles)
-- =====================================================================
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT COALESCE((SELECT role::text FROM public.profiles WHERE id = auth.uid()), 'anon');
$$;

CREATE OR REPLACE FUNCTION public.has_profile()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid());
$$;

-- write access (owner / admin) for destructive or config actions
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.current_user_role() IN ('owner', 'admin');
$$;

-- operational write access (owner / admin / staff)
CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.current_user_role() IN ('owner', 'admin', 'staff');
$$;

-- ---------------------------------------------------------------------
-- updated_at trigger
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'profiles','locations','categories','products','customers','orders',
    'page_categories','pages','resources','form_definitions'
  ] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS set_updated_at ON public.%I', t);
    EXECUTE format(
      'CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.%I
       FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at()', t);
  END LOOP;
END $$;

-- ---------------------------------------------------------------------
-- Stock movement: keep products.stock_qty consistent atomically
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.apply_stock_movement()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE new_qty int;
BEGIN
  UPDATE public.products
     SET stock_qty = stock_qty + NEW.delta
   WHERE id = NEW.product_id
   RETURNING stock_qty INTO new_qty;

  IF new_qty IS NULL THEN
    RAISE EXCEPTION 'product % not found', NEW.product_id;
  END IF;
  IF new_qty < 0 THEN
    RAISE EXCEPTION 'insufficient stock for product % (would be %)', NEW.product_id, new_qty;
  END IF;

  NEW.resulting_qty = new_qty;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_apply_stock_movement ON public.stock_movements;
CREATE TRIGGER trg_apply_stock_movement
  BEFORE INSERT ON public.stock_movements
  FOR EACH ROW EXECUTE FUNCTION public.apply_stock_movement();

-- ---------------------------------------------------------------------
-- Form submissions counter
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_form_submissions()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE public.form_definitions
     SET submissions_count = submissions_count + 1
   WHERE id = NEW.form_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_increment_form_submissions ON public.form_submissions;
CREATE TRIGGER trg_increment_form_submissions
  AFTER INSERT ON public.form_submissions
  FOR EACH ROW EXECUTE FUNCTION public.increment_form_submissions();

-- ---------------------------------------------------------------------
-- Atomic order placement (creates order + items + stock movements)
-- Returns the new order id.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.place_order(
  p_order jsonb,
  p_items jsonb
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_order_id uuid;
  v_item jsonb;
BEGIN
  IF NOT public.is_staff() THEN
    RAISE EXCEPTION 'not authorized to place orders';
  END IF;

  INSERT INTO public.orders (
    order_number, customer_id, status, subtotal, discount, tax, shipping_fee,
    total, customer_name, customer_email, shipping_address, shipping_city, notes
  ) VALUES (
    p_order->>'order_number',
    NULLIF(p_order->>'customer_id','')::uuid,
    COALESCE((p_order->>'status')::order_status, 'pending'),
    COALESCE((p_order->>'subtotal')::numeric, 0),
    COALESCE((p_order->>'discount')::numeric, 0),
    COALESCE((p_order->>'tax')::numeric, 0),
    COALESCE((p_order->>'shipping_fee')::numeric, 0),
    COALESCE((p_order->>'total')::numeric, 0),
    p_order->>'customer_name',
    p_order->>'customer_email',
    p_order->>'shipping_address',
    p_order->>'shipping_city',
    p_order->>'notes'
  ) RETURNING id INTO v_order_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    INSERT INTO public.order_items (
      order_id, product_id, product_name, product_sku, unit_price, qty, subtotal
    ) VALUES (
      v_order_id,
      NULLIF(v_item->>'product_id','')::uuid,
      v_item->>'product_name',
      v_item->>'product_sku',
      (v_item->>'unit_price')::numeric,
      (v_item->>'qty')::int,
      (v_item->>'subtotal')::numeric
    );

    IF (v_item->>'product_id') IS NOT NULL AND (v_item->>'product_id') <> '' THEN
      INSERT INTO public.stock_movements (product_id, delta, reason, reference)
      VALUES (
        (v_item->>'product_id')::uuid,
        -(v_item->>'qty')::int,
        'order',
        p_order->>'order_number'
      );
    END IF;
  END LOOP;

  RETURN v_order_id;
END;
$$;

-- =====================================================================
-- ROW LEVEL SECURITY
-- Default deny: a table with no matching policy returns no rows / rejects.
-- =====================================================================
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations         ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories        ENABLE ROW LEVEL SECURITY;
ALTER TABLE products          ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images    ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements   ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_events   ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders            ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items       ENABLE ROW LEVEL SECURITY;
ALTER TABLE page_categories   ENABLE ROW LEVEL SECURITY;
ALTER TABLE pages             ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources         ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_definitions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_submissions  ENABLE ROW LEVEL SECURITY;

-- ---------- profiles ----------
DROP POLICY IF EXISTS profiles_select_self ON profiles;
CREATE POLICY profiles_select_self ON profiles
  FOR SELECT USING (id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS profiles_select_staff ON profiles;
CREATE POLICY profiles_select_staff ON profiles
  FOR SELECT USING (public.has_profile());

DROP POLICY IF EXISTS profiles_update_self ON profiles;
CREATE POLICY profiles_update_self ON profiles
  FOR UPDATE USING (id = auth.uid() OR public.is_admin())
  WITH CHECK (role = public.current_user_role()::user_role OR public.is_admin());

DROP POLICY IF EXISTS profiles_insert_admin ON profiles;
CREATE POLICY profiles_insert_admin ON profiles
  FOR INSERT WITH CHECK (public.is_admin());

-- ---------- staff-managed tables (read for any signed-in profile) ----------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'locations','categories','customers','orders','order_items',
    'product_images','stock_movements','tracking_events','resources',
    'page_categories','form_definitions','form_submissions'
  ] LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', t || '_admin_read', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT USING (public.has_profile())',
      t || '_admin_read', t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', t || '_staff_write', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR ALL USING (public.is_staff()) WITH CHECK (public.is_staff())',
      t || '_staff_write', t);
  END LOOP;
END $$;

-- ---------- products ----------
DROP POLICY IF EXISTS products_admin_read ON products;
CREATE POLICY products_admin_read ON products
  FOR SELECT USING (public.has_profile());
DROP POLICY IF EXISTS products_public_read ON products;
CREATE POLICY products_public_read ON products
  FOR SELECT TO anon, authenticated USING (status = 'active');
DROP POLICY IF EXISTS products_staff_write ON products;
CREATE POLICY products_staff_write ON products
  FOR ALL USING (public.is_staff()) WITH CHECK (public.is_staff());

-- ---------- pages (articles) ----------
DROP POLICY IF EXISTS pages_admin_read ON pages;
CREATE POLICY pages_admin_read ON pages
  FOR SELECT USING (public.has_profile());
DROP POLICY IF EXISTS pages_public_read ON pages;
CREATE POLICY pages_public_read ON pages
  FOR SELECT TO anon, authenticated USING (status = 'published');
DROP POLICY IF EXISTS pages_staff_write ON pages;
CREATE POLICY pages_staff_write ON pages
  FOR ALL USING (public.is_staff()) WITH CHECK (public.is_staff());

-- ---------- public storefront / site reads ----------
DROP POLICY IF EXISTS categories_public_read ON categories;
CREATE POLICY categories_public_read ON categories
  FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS page_categories_public_read ON page_categories;
CREATE POLICY page_categories_public_read ON page_categories
  FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS form_definitions_public_read ON form_definitions;
CREATE POLICY form_definitions_public_read ON form_definitions
  FOR SELECT TO anon, authenticated USING (status = 'published');

-- ---------- form submissions: anonymous submit to published forms only ----
DROP POLICY IF EXISTS form_submissions_public_insert ON form_submissions;
CREATE POLICY form_submissions_public_insert ON form_submissions
  FOR INSERT TO anon, authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.form_definitions f
      WHERE f.id = form_submissions.form_id AND f.status = 'published'
    )
  );
