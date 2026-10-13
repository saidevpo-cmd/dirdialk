-- =====================================================================
-- DIALI — SEED DATA (safe to run repeatedly)
-- =====================================================================
-- Creates the default website templates, baseline site settings values
-- and business app settings. Does NOT create users or business records.

-- Default templates
INSERT INTO website_templates (name, slug, description, category, tags, is_featured, customization)
VALUES
  ('Aurora Store', 'aurora-store',
   'A bright, conversion-focused storefront with a hero banner and featured products.',
   'store', '["store","hero","featured"]'::jsonb, true,
   '{"brandName":"Diali","tagline":"Quality you can trust","primaryColorHex":"3949AB","accentColorHex":"0F9D8A","heroTitle":"Everything your business needs","heroSubtitle":"Browse our latest products and offers","heroButtonText":"Shop now","showHero":true,"showFeaturedProducts":true,"showArticles":true,"showContact":true}'::jsonb),
  ('Meridian Corporate', 'meridian-corporate',
   'A formal corporate layout emphasising services, articles and contact.',
   'company', '["company","articles","formal"]'::jsonb, true,
   '{"brandName":"Diali","tagline":"Trusted by businesses","primaryColorHex":"0F172A","accentColorHex":"3949AB","heroTitle":"Reliable solutions for modern businesses","heroSubtitle":"Discover our services and expertise","heroButtonText":"Get in touch","showHero":true,"showFeaturedProducts":false,"showArticles":true,"showContact":true}'::jsonb),
  ('Minimal Slate', 'minimal-slate',
   'A clean, minimal portfolio-style template with strong typography.',
   'minimal', '["minimal","clean","portfolio"]'::jsonb, false,
   '{"brandName":"Diali","tagline":"Less, but better","primaryColorHex":"111827","accentColorHex":"F4B740","heroTitle":"Simple. Clear. Effective.","heroSubtitle":"A focused presentation of our work","heroButtonText":"Explore","showHero":true,"showFeaturedProducts":true,"showArticles":false,"showContact":false}'::jsonb)
ON CONFLICT (slug) DO NOTHING;

-- Activate the first template if none set
UPDATE site_settings
   SET active_template_id = (SELECT id FROM website_templates WHERE slug = 'aurora-store')
 WHERE active_template_id IS NULL;

-- Business app settings
INSERT INTO app_settings (key, value) VALUES
  ('currency',       '{"code":"USD","symbol":"$"}'::jsonb),
  ('tax_rate',       '{"percent":8}'::jsonb),
  ('default_locale', '{"code":"ar"}'::jsonb)
ON CONFLICT (key) DO NOTHING;
