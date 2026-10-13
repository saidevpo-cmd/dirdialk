-- =====================================================================
-- DIALI — WEBSITE TEMPLATES, SITE SETTINGS & APP SETTINGS
-- =====================================================================

-- ---------------------------------------------------------------------
-- WEBSITE TEMPLATES (public presentation)
-- `customization` stores a TemplateCustomization jsonb blob so new
-- presentation fields do not require a migration.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS website_templates (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name              text NOT NULL,
  slug              text NOT NULL UNIQUE,
  description       text,
  category          text NOT NULL DEFAULT 'store',
  preview_image_url text,
  tags              jsonb NOT NULL DEFAULT '[]'::jsonb,
  is_published      boolean NOT NULL DEFAULT true,
  is_featured       boolean NOT NULL DEFAULT false,
  customization     jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- SITE SETTINGS (single row: active template + public content)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS site_settings (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  active_template_id  uuid REFERENCES website_templates(id) ON DELETE SET NULL,
  brand_name          text NOT NULL DEFAULT 'Diali',
  tagline             text DEFAULT '',
  logo_url            text,
  primary_color_hex   text NOT NULL DEFAULT '3949AB',
  accent_color_hex    text NOT NULL DEFAULT '0F9D8A',
  font_family         text NOT NULL DEFAULT 'Inter',
  hero_title          text DEFAULT '',
  hero_subtitle       text DEFAULT '',
  hero_button_text    text DEFAULT 'Shop now',
  hero_image_url      text,
  contact_email       text DEFAULT '',
  contact_phone       text DEFAULT '',
  address             text DEFAULT '',
  footer_text         text DEFAULT '',
  show_hero           boolean NOT NULL DEFAULT true,
  show_featured_products boolean NOT NULL DEFAULT true,
  show_articles       boolean NOT NULL DEFAULT true,
  show_contact        boolean NOT NULL DEFAULT true,
  updated_at          timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- APP SETTINGS (business-level key/value: currency, tax rate, locale...)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_settings (
  key        text PRIMARY KEY,
  value      jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- updated_at triggers
DROP TRIGGER IF EXISTS set_updated_at ON website_templates;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON website_templates
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON site_settings;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON site_settings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ---------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------
ALTER TABLE website_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings     ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings      ENABLE ROW LEVEL SECURITY;

-- public can read published templates
DROP POLICY IF EXISTS website_templates_public_read ON website_templates;
CREATE POLICY website_templates_public_read ON website_templates
  FOR SELECT TO anon, authenticated USING (is_published = true);
DROP POLICY IF EXISTS website_templates_admin_read ON website_templates;
CREATE POLICY website_templates_admin_read ON website_templates
  FOR SELECT USING (public.has_profile());
DROP POLICY IF EXISTS website_templates_admin_write ON website_templates;
CREATE POLICY website_templates_admin_write ON website_templates
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- public can read the single site settings row (presentation only)
DROP POLICY IF EXISTS site_settings_public_read ON site_settings;
CREATE POLICY site_settings_public_read ON site_settings
  FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS site_settings_admin_write ON site_settings;
CREATE POLICY site_settings_admin_write ON site_settings
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- app settings are private to signed-in staff
DROP POLICY IF EXISTS app_settings_staff_read ON app_settings;
CREATE POLICY app_settings_staff_read ON app_settings
  FOR SELECT USING (public.has_profile());
DROP POLICY IF EXISTS app_settings_admin_write ON app_settings;
CREATE POLICY app_settings_admin_write ON app_settings
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- Ensure a single site_settings row exists (idempotent).
-- ---------------------------------------------------------------------
INSERT INTO site_settings (id)
SELECT gen_random_uuid()
WHERE NOT EXISTS (SELECT 1 FROM site_settings);
