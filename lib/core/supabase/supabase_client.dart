import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

export 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthException,
        CountOption,
        PostgrestException,
        RealtimeChannel,
        StorageException;

/// Owns the single Supabase client for the process.
///
/// Initialization happens once in `main()` when [AppConfig.isSupabaseConfigured]
/// is true. Repositories access the client through [AppSupabase.client], which
/// throws a clear error if accessed before initialization.
class AppSupabase {
  AppSupabase._();

  static SupabaseClient? _client;

  /// Initializes Supabase. Safe to call when not configured (no-op) so the app
  /// can keep running in local/mock mode.
  static Future<void> init() async {
    if (!AppConfig.isSupabaseConfigured) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  static bool get isReady => _client != null;

  static SupabaseClient get client {
    final c = _client;
    if (c == null) {
      throw StateError(
        'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
      );
    }
    return c;
  }

  static GoTrueClient get auth => client.auth;

  static String? get currentUserId => _client?.auth.currentUser?.id;
}
