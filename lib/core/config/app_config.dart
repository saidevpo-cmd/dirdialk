/// Compile-time application configuration.
///
/// Values are injected with `--dart-define` so no secrets live in source:
///
/// ```bash
/// flutter run -d chrome \
///   --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=<anon-key>
/// ```
///
/// The anon (publishable) key is safe for the client. The service-role key must
/// never be provided here.
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// `development` | `production` | `staging`.
  static const String environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');

  /// Force the local/mock mode even if Supabase is configured (used by tests).
  static const bool forceLocalMode =
      bool.fromEnvironment('DIALI_LOCAL_MODE', defaultValue: false);

  /// True when a real backend is configured and should be used.
  static bool get isSupabaseConfigured =>
      !forceLocalMode && supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isProduction => environment == 'production';
}
