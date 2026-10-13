import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/auth/auth_controller.dart';
import '../core/design_system/app_theme.dart';
import '../core/settings/settings_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

class DialiApp extends StatefulWidget {
  const DialiApp({super.key, required this.settings, this.auth});

  final SettingsController settings;

  /// Authentication state. When omitted (tests, previews) a local-mode
  /// controller is created so no sign-in is required.
  final AuthController? auth;

  @override
  State<DialiApp> createState() => _DialiAppState();
}

class _DialiAppState extends State<DialiApp> {
  late final AuthController _auth = widget.auth ?? AuthController();
  late final AppRouter _appRouter =
      AppRouter(settings: widget.settings, auth: _auth);

  bool get _ownsAuth => widget.auth == null;

  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_onChanged);
    if (_ownsAuth) {
      _auth.initialize();
    }
  }

  @override
  void dispose() {
    widget.settings.removeListener(_onChanged);
    if (_ownsAuth) {
      _auth.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  Locale _resolveLocale(Locale? device, Iterable<Locale> supported) {
    if (device != null) {
      for (final locale in supported) {
        if (locale.languageCode == device.languageCode) {
          return locale;
        }
      }
    }
    return const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return MaterialApp.router(
      title: 'diali',
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: _resolveLocale,
      theme: AppTheme.build(settings.style, Brightness.light),
      darkTheme: AppTheme.build(settings.style, Brightness.dark),
      themeMode: settings.themeMode,
      routerConfig: _appRouter.router,
    );
  }
}
