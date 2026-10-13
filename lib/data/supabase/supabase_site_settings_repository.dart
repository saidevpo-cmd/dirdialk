import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/site_settings.dart';
import '../../domain/repositories/site_settings_repository.dart';
import 'supabase_mappers.dart';

class SupabaseSiteSettingsRepository implements SiteSettingsRepository {
  @override
  Future<Result<SiteSettings>> load() {
    return guard(() async {
      final data = await AppSupabase.client
          .from('site_settings')
          .select('*')
          .limit(1)
          .maybeSingle();
      if (data == null) return const SiteSettings();
      return Db.siteSettingsFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> save(SiteSettings settings) {
    return guard(() async {
      final existing = await AppSupabase.client
          .from('site_settings')
          .select('id')
          .limit(1)
          .maybeSingle();
      if (existing == null) {
        await AppSupabase.client.from('site_settings').insert(Db.siteSettings(settings));
      } else {
        await AppSupabase.client
            .from('site_settings')
            .update(Db.siteSettings(settings))
            .eq('id', existing['id']);
      }
    });
  }

  @override
  Future<Result<String>> currencySymbol() {
    return guard(() async {
      final data = await AppSupabase.client
          .from('app_settings')
          .select('*')
          .eq('key', 'currency')
          .maybeSingle();
      if (data == null) return r'$';
      return Db.appSettingString(
        Map<String, dynamic>.from(data),
        'symbol',
        r'$',
      );
    });
  }

  @override
  Future<Result<double>> taxRatePercent() {
    return guard(() async {
      final data = await AppSupabase.client
          .from('app_settings')
          .select('*')
          .eq('key', 'tax_rate')
          .maybeSingle();
      if (data == null) return 0;
      return Db.appSettingNumber(Map<String, dynamic>.from(data), 'percent', 0);
    });
  }
}