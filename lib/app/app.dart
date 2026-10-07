import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/design_system/app_theme.dart';
import '../core/settings/settings_controller.dart';
import '../features/shell/app_shell.dart';
import '../l10n/generated/app_localizations.dart';

class DialiApp extends StatefulWidget {
  const DialiApp({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<DialiApp> createState() => _DialiAppState();
}

class _DialiAppState extends State<DialiApp> {
  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    widget.settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
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
    return MaterialApp(
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
      home: AppShell(settings: settings),
    );
  }
}
