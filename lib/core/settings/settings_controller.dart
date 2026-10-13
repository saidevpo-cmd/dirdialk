import 'package:flutter/material.dart';

import '../app_info.dart';
import '../design_system/app_style.dart';
import '../storage/settings_store.dart';

/// Owns every persisted user preference and notifies listeners when one of
/// them changes so the whole application can react immediately.
///
/// Values are stored as strings through [SettingsStore] and every parse has a
/// safe fallback, so a missing or corrupted value never crashes the app.
class SettingsController extends ChangeNotifier {
  SettingsController(this._store);

  final SettingsStore _store;

  static const localeKey = 'settings.locale';
  static const themeModeKey = 'settings.themeMode';
  static const styleKey = 'settings.style';
  static const notifyOrdersKey = 'settings.notify.orders';
  static const notifyLowStockKey = 'settings.notify.lowStock';
  static const notifyWeeklyKey = 'settings.notify.weekly';
  static const privacyAnalyticsKey = 'settings.privacy.analytics';
  static const privacyCrashKey = 'settings.privacy.crash';
  static const privacyPersonalizationKey = 'settings.privacy.personalization';
  static const consentAcceptedAtKey = 'settings.consent.acceptedAt';
  static const consentPolicyVersionKey = 'settings.consent.policyVersion';

  static const List<String> _allKeys = [
    localeKey,
    themeModeKey,
    styleKey,
    notifyOrdersKey,
    notifyLowStockKey,
    notifyWeeklyKey,
    privacyAnalyticsKey,
    privacyCrashKey,
    privacyPersonalizationKey,
    consentAcceptedAtKey,
    consentPolicyVersionKey,
  ];

  static const supportedLanguageCodes = ['ar', 'en', 'fr'];

  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  AppStyle _style = AppStyle.modern;

  bool _notifyOrders = true;
  bool _notifyLowStock = true;
  bool _notifyWeekly = false;

  bool _privacyAnalytics = false;
  bool _privacyCrash = false;
  bool _privacyPersonalization = false;

  DateTime? _consentAcceptedAt;

  Locale? get locale => _locale;

  ThemeMode get themeMode => _themeMode;

  AppStyle get style => _style;

  bool get notifyOrders => _notifyOrders;

  bool get notifyLowStock => _notifyLowStock;

  bool get notifyWeekly => _notifyWeekly;

  bool get privacyAnalytics => _privacyAnalytics;

  bool get privacyCrash => _privacyCrash;

  bool get privacyPersonalization => _privacyPersonalization;

  DateTime? get consentAcceptedAt => _consentAcceptedAt;

  bool get hasValidConsent =>
      _consentAcceptedAt != null &&
      _store.read(consentPolicyVersionKey) == AppInfo.policyVersion;

  Future<void> load({Locale? deviceLocale}) async {
    _locale = _resolveLocale(_store.read(localeKey), deviceLocale);
    _themeMode = _parseThemeMode(_store.read(themeModeKey));
    _style = _parseStyle(_store.read(styleKey));

    _notifyOrders = _readBool(notifyOrdersKey, fallback: true);
    _notifyLowStock = _readBool(notifyLowStockKey, fallback: true);
    _notifyWeekly = _readBool(notifyWeeklyKey, fallback: false);

    _privacyAnalytics = _readBool(privacyAnalyticsKey, fallback: false);
    _privacyCrash = _readBool(privacyCrashKey, fallback: false);
    _privacyPersonalization =
        _readBool(privacyPersonalizationKey, fallback: false);

    _consentAcceptedAt = DateTime.tryParse(
      _store.read(consentAcceptedAtKey) ?? '',
    );
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

  Future<void> setNotifyOrders(bool value) =>
      _setBool(notifyOrdersKey, value, () => _notifyOrders = value);

  Future<void> setNotifyLowStock(bool value) =>
      _setBool(notifyLowStockKey, value, () => _notifyLowStock = value);

  Future<void> setNotifyWeekly(bool value) =>
      _setBool(notifyWeeklyKey, value, () => _notifyWeekly = value);

  Future<void> setPrivacyAnalytics(bool value) =>
      _setBool(privacyAnalyticsKey, value, () => _privacyAnalytics = value);

  Future<void> setPrivacyCrash(bool value) =>
      _setBool(privacyCrashKey, value, () => _privacyCrash = value);

  Future<void> setPrivacyPersonalization(bool value) => _setBool(
        privacyPersonalizationKey,
        value,
        () => _privacyPersonalization = value,
      );

  Future<void> acceptConsent({DateTime? now}) async {
    _consentAcceptedAt = now ?? DateTime.now();
    notifyListeners();
    await _store.write(
      consentAcceptedAtKey,
      _consentAcceptedAt!.toIso8601String(),
    );
    await _store.write(consentPolicyVersionKey, AppInfo.policyVersion);
  }

  /// Restores every preference to its default value.
  Future<void> resetAll({Locale? deviceLocale}) async {
    for (final key in _allKeys) {
      await _store.delete(key);
    }
    _locale = _resolveLocale(null, deviceLocale);
    _themeMode = ThemeMode.system;
    _style = AppStyle.modern;
    _notifyOrders = true;
    _notifyLowStock = true;
    _notifyWeekly = false;
    _privacyAnalytics = false;
    _privacyCrash = false;
    _privacyPersonalization = false;
    _consentAcceptedAt = null;
    notifyListeners();
  }

  /// Snapshot of every stored preference, used by "Export settings".
  Map<String, String> exportPreferences() => {
        localeKey: _locale?.languageCode ?? 'en',
        themeModeKey: _themeMode.name,
        styleKey: _style.name,
        notifyOrdersKey: '$_notifyOrders',
        notifyLowStockKey: '$_notifyLowStock',
        notifyWeeklyKey: '$_notifyWeekly',
        privacyAnalyticsKey: '$_privacyAnalytics',
        privacyCrashKey: '$_privacyCrash',
        privacyPersonalizationKey: '$_privacyPersonalization',
        consentAcceptedAtKey: _consentAcceptedAt?.toIso8601String() ?? '',
        consentPolicyVersionKey: hasValidConsent ? AppInfo.policyVersion : '',
      };

  bool _readBool(String key, {required bool fallback}) {
    final value = _store.read(key);
    if (value == null) return fallback;
    if (value == 'true' || value == '1') return true;
    if (value == 'false' || value == '0') return false;
    return fallback;
  }

  Future<void> _setBool(
    String key,
    bool value,
    VoidCallback apply,
  ) async {
    apply();
    notifyListeners();
    await _store.write(key, '$value');
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
