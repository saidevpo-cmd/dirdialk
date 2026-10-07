import 'package:flutter/material.dart';

import '../design_system/app_style.dart';
import '../storage/settings_store.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._store);

  final SettingsStore _store;

  static const localeKey = 'settings.locale';
  static const themeModeKey = 'settings.themeMode';
  static const styleKey = 'settings.style';

  static const supportedLanguageCodes = ['ar', 'en', 'fr'];

  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  AppStyle _style = AppStyle.modern;

  Locale? get locale => _locale;

  ThemeMode get themeMode => _themeMode;

  AppStyle get style => _style;

  Future<void> load({Locale? deviceLocale}) async {
    _locale = _resolveLocale(_store.read(localeKey), deviceLocale);
    _themeMode = _parseThemeMode(_store.read(themeModeKey));
    _style = _parseStyle(_store.read(styleKey));
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    await _store.write(localeKey, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _store.write(themeModeKey, mode.name);
  }

  Future<void> setStyle(AppStyle style) async {
    _style = style;
    notifyListeners();
    await _store.write(styleKey, style.name);
  }

  Locale? _resolveLocale(String? stored, Locale? deviceLocale) {
    if (stored != null && supportedLanguageCodes.contains(stored)) {
      return Locale(stored);
    }
    if (deviceLocale != null &&
        supportedLanguageCodes.contains(deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('en');
  }

  ThemeMode _parseThemeMode(String? stored) {
    for (final mode in ThemeMode.values) {
      if (mode.name == stored) return mode;
    }
    return ThemeMode.system;
  }

  AppStyle _parseStyle(String? stored) {
    for (final style in AppStyle.values) {
      if (style.name == stored) return style;
    }
    return AppStyle.modern;
  }
}
