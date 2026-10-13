import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../supabase/supabase_client.dart';

/// Minimal surface over the authentication backend.
///
/// Keeping the router and UI behind this interface lets the app run and be
/// tested without a live Supabase project.
abstract interface class AuthGateway {
  bool get hasSession;

  String? get email;

  Stream<void> get changes;

  Future<void> signIn(String email, String password);

  Future<void> signOut();
}

/// [AuthGateway] backed by Supabase Auth.
class SupabaseAuthGateway implements AuthGateway {
  const SupabaseAuthGateway();

  @override
  bool get hasSession => AppSupabase.client.auth.currentSession != null;

  @override
  String? get email => AppSupabase.client.auth.currentUser?.email;

  @override
  Stream<void> get changes => AppSupabase.auth.onAuthStateChange.map((_) {});

  @override
  Future<void> signIn(String email, String password) =>
      AppSupabase.auth.signInWithPassword(email: email, password: password);

  @override
  Future<void> signOut() => AppSupabase.auth.signOut();
}

/// Owns the current authentication state and exposes it to the router and UI.
///
/// When no backend is configured ([requireAuth] is false — the default in
/// local/offline mode) the app is always considered authenticated so the admin
/// opens directly, matching the offline-first development experience. When a
/// Supabase project is configured, a valid session is required and the router
/// redirects to `/login` otherwise.
class AuthController extends ChangeNotifier {
  AuthController({bool? requireAuth, AuthGateway? gateway})
      : requireAuth = requireAuth ?? AppConfig.isSupabaseConfigured,
        _gateway = gateway ??
            (AppConfig.isSupabaseConfigured
                ? const SupabaseAuthGateway()
                : null);

  /// True when a signed-in session is required to reach the admin.
  final bool requireAuth;

  final AuthGateway? _gateway;

  StreamSubscription<void>? _subscription;
  bool _hasSession = false;
  String? _email;

  /// True when authentication is not required or a session exists.
  bool get isAuthenticated => !requireAuth || _hasSession;

  /// True when a real authentication backend is wired up.
  bool get isBackendConfigured => _gateway != null;

  String? get email => _email;

  /// Reads the current session once and subscribes to auth state changes.
  Future<void> initialize() async {
    final gateway = _gateway;
    if (gateway == null) {
      notifyListeners();
      return;
    }
    _hasSession = gateway.hasSession;
    _email = gateway.email;
    _subscription = gateway.changes.listen((_) {
      _hasSession = gateway.hasSession;
      _email = gateway.email;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Returns `null` on success or a human-readable error message on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final gateway = _gateway;
    if (gateway == null) return null;
    try {
      await gateway.signIn(email.trim(), password);
      _hasSession = gateway.hasSession;
      _email = gateway.email;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    final gateway = _gateway;
    if (gateway == null) return;
    await gateway.signOut();
    _hasSession = false;
    _email = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
