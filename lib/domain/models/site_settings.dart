import 'social_links.dart';
import 'template.dart';

/// Global configuration for the public website: which template is active plus
/// the business content a template renders. Kept separate from admin
/// appearance preferences (theme / style / locale).
class SiteSettings {
  const SiteSettings({
    this.activeTemplateId,
    this.customization = const TemplateCustomization(),
    this.socialLinks = SocialLinks.empty,
  });

  final String? activeTemplateId;
  final TemplateCustomization customization;

  /// Public business social/contact links (Instagram, WhatsApp, ...).
  final SocialLinks socialLinks;

  SiteSettings copyWith({
    String? activeTemplateId,
    TemplateCustomization? customization,
    SocialLinks? socialLinks,
  }) =>
      SiteSettings(
        activeTemplateId: activeTemplateId ?? this.activeTemplateId,
        customization: customization ?? this.customization,
        socialLinks: socialLinks ?? this.socialLinks,
      );
}
