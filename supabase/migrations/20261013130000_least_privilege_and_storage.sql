-- =====================================================================
-- DIALI — LEAST PRIVILEGE & RESOURCE STORAGE HARDENING
-- =====================================================================
-- Additive migration. Applied after:
--   20261008000000_initial_schema.sql
--   20261008120000_templates_and_settings.sql
--   20261008130000_storage.sql
--   20261013120000_security_hardening.sql
--
-- Goals:
--   1. `profiles.role` must default to the LOWEST role. The auto-provision
--      trigger already inserts 'viewer', but the column default was 'owner',
--      so any manual insert without an explicit role silently created an
--      owner. This closes that footgun.
--   2. The private `resources` bucket had `allowed_mime_types = NULL`, which
--      means "any MIME type". Enforce an explicit allow-list so the bucket
--      constraint matches the documented policy (size + MIME at bucket level).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. profiles.role default = viewer (least privilege)
-- ---------------------------------------------------------------------
ALTER TABLE public.profiles ALTER COLUMN role SET DEFAULT 'viewer';

-- ---------------------------------------------------------------------
-- 2. resources bucket: explicit MIME allow-list
-- ---------------------------------------------------------------------
-- Business documents, spreadsheets, presentations, images, plain text,
-- JSON and PDFs. The bucket stays private (signed URLs only) and
-- staff-only for reads/writes (see 20261008130000_storage.sql).
UPDATE storage.buckets
   SET allowed_mime_types = ARRAY[
     'application/pdf',
     'application/json',
     'application/zip',
     'application/msword',
     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
     'application/vnd.ms-excel',
     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
     'application/vnd.ms-powerpoint',
     'application/vnd.openxmlformats-officedocument.presentationml.presentation',
     'text/plain',
     'text/csv',
     'text/markdown',
     'image/png',
     'image/jpeg',
     'image/webp',
     'image/gif'
   ]
 WHERE id = 'resources';
