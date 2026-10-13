import '../models/app_error.dart';
import '../models/site_settings.dart';

abstract class SiteSettingsRepository {
  Future<Result<SiteSettings>> load();

  Future<Result<void>> save(SiteSettings settings);

  /// Reads the configured currency symbol (e.g. "USD" → "$").
  Future<Result<String>> currencySymbol();

  /// Reads the configured default sales-tax rate in percent.
  Future<Result<double>> taxRatePercent();
}