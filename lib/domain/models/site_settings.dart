import 'template.dart';

/// Global configuration for the public website: which template is active plus
/// the business content a template renders. Kept separate from admin
/// appearance preferences (theme / style / locale).
class SiteSettings {
  const SiteSettings({
    this.activeTemplateId,
    this.customization = const TemplateCustomization(),
  });

  final String? activeTemplateId;
  final TemplateCustomization customization;

  SiteSettings copyWith({
    String? activeTemplateId,
    TemplateCustomization? customization,
  }) =>
      SiteSettings(
        activeTemplateId: activeTemplateId ?? this.activeTemplateId,
        customization: customization ?? this.customization,
      );
}
