-- =====================================================================
-- DIALI — STORAGE BUCKETS & POLICIES
-- =====================================================================
-- Buckets:
--   products  (public)  product images
--   site      (public)  public website assets / article covers / logos
--   resources (private) business documents (signed URLs only)
--   avatars   (public)  user profile pictures
-- Limits: 10 MB per object, image mime types for image buckets.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('products',  'products',  true,  10485760,
     ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('site',      'site',      true,  10485760,
     ARRAY['image/png','image/jpeg','image/webp','image/svg+xml','image/gif']),
  ('avatars',   'avatars',   true,  5242880,
     ARRAY['image/png','image/jpeg','image/webp']),
  ('resources', 'resources', false, 20971520, NULL)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------
-- products bucket: public read, staff write
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "products_public_read" ON storage.objects;
CREATE POLICY "products_public_read" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'products');

DROP POLICY IF EXISTS "products_staff_write" ON storage.objects;
CREATE POLICY "products_staff_write" ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'products' AND public.is_staff())
  WITH CHECK (bucket_id = 'products' AND public.is_staff());

-- ---------------------------------------------------------------------
-- site bucket: public read, admin write
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "site_public_read" ON storage.objects;
CREATE POLICY "site_public_read" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'site');

DROP POLICY IF EXISTS "site_admin_write" ON storage.objects;
CREATE POLICY "site_admin_write" ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'site' AND public.is_admin())
  WITH CHECK (bucket_id = 'site' AND public.is_admin());

-- ---------------------------------------------------------------------
-- avatars bucket: public read, owner write (path starts with uid/)
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "avatars_public_read" ON storage.objects;
CREATE POLICY "avatars_public_read" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "avatars_owner_write" ON storage.objects;
CREATE POLICY "avatars_owner_write" ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text)
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- ---------------------------------------------------------------------
-- resources bucket: private — staff only for all operations
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "resources_staff_all" ON storage.objects;
CREATE POLICY "resources_staff_all" ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'resources' AND public.is_staff())
  WITH CHECK (bucket_id = 'resources' AND public.is_staff());
