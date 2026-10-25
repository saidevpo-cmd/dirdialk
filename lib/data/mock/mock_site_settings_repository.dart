import '../../domain/models/app_error.dart';
import '../../domain/models/site_settings.dart';
import '../../domain/models/social_links.dart';
import '../../domain/models/template.dart';
import '../../domain/repositories/site_settings_repository.dart';

class MockSiteSettingsRepository implements SiteSettingsRepository {
  MockSiteSettingsRepository({SiteSettings? initial})
      : _settings = initial ??
            const SiteSettings(
              activeTemplateId: 'tpl_aurora',
              customization: TemplateCustomization(
                brandName: 'Diali',
                tagline: 'Quality you can trust',
                heroTitle: 'Everything your business needs',
                heroSubtitle: 'Browse our latest products and offers',
                heroButtonText: 'Shop now',
                contactEmail: 'contact@diali.example',
                contactPhone: '+212 600 000 000',
                address: 'Casablanca, Morocco',
                footerText: '© 2026 Diali. All rights reserved.',
              ),
              socialLinks: SocialLinks({
                SocialPlatform.instagram: 'https://instagram.com/diali',
                SocialPlatform.facebook: 'https://facebook.com/diali',
                SocialPlatform.whatsapp: 'https://wa.me/212600000000',
              }),
            );

  SiteSettings _settings;
  final String _currencySymbol = r'$';
  final double _taxRate = 8;

  @override
  Future<Result<SiteSettings>> load() async => Success(_settings);

  @override
  Future<Result<void>> save(SiteSettings settings) async {
    _settings = settings;
    return const Success(null);
  }

  @override
  Future<Result<String>> currencySymbol() async => Success(_currencySymbol);

  @override
  Future<Result<double>> taxRatePercent() async => Success(_taxRate);
}
