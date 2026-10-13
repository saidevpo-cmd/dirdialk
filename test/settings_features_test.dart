import 'package:diali/core/app_info.dart';
import 'package:diali/core/design_system/app_style.dart';
import 'package:diali/core/navigation/nav_section.dart';
import 'package:diali/core/settings/settings_controller.dart';
import 'package:diali/core/storage/settings_store.dart';
import 'package:diali/features/shell/app_shell.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:diali/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> l10n(Locale locale) =>
    AppLocalizations.delegate.load(locale);

Future<SettingsController> newController({SettingsStore? store}) async {
  final controller = SettingsController(store ?? InMemorySettingsStore());
  await controller.load(deviceLocale: const Locale('en'));
  return controller;
}

Future<void> pumpApp(
  WidgetTester tester,
  SettingsController controller,
) async {
  await tester.pumpWidget(DialiApp(settings: controller));
  await tester.pump();
}

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byKey(AppShell.navTile(NavSection.settings)));
  await tester.pump();
  expect(find.byKey(const Key('settings-page')), findsOneWidget);
}

void useView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  test('notification preferences persist across a restart', () async {
    final store = InMemorySettingsStore();

    final first = SettingsController(store);
    await first.load(deviceLocale: const Locale('en'));
    await first.setNotifyOrders(false);
    await first.setNotifyLowStock(false);
    await first.setNotifyWeekly(true);

    final second = SettingsController(store);
    await second.load(deviceLocale: const Locale('en'));

    expect(second.notifyOrders, isFalse);
    expect(second.notifyLowStock, isFalse);
    expect(second.notifyWeekly, isTrue);
  });

  test('privacy preferences persist across a restart', () async {
    final store = InMemorySettingsStore();

    final first = SettingsController(store);
    await first.load(deviceLocale: const Locale('en'));
    await first.setPrivacyAnalytics(true);
    await first.setPrivacyCrash(true);
    await first.setPrivacyPersonalization(true);

    final second = SettingsController(store);
    await second.load(deviceLocale: const Locale('en'));

    expect(second.privacyAnalytics, isTrue);
    expect(second.privacyCrash, isTrue);
    expect(second.privacyPersonalization, isTrue);
  });

  test('notification and privacy defaults are applied', () async {
    final controller = await newController();

    expect(controller.notifyOrders, isTrue);
    expect(controller.notifyLowStock, isTrue);
    expect(controller.notifyWeekly, isFalse);
    expect(controller.privacyAnalytics, isFalse);
    expect(controller.privacyCrash, isFalse);
    expect(controller.privacyPersonalization, isFalse);
  });

  test('consent is recorded and tracked per policy version', () async {
    final store = InMemorySettingsStore();
    final controller = SettingsController(store);
    await controller.load(deviceLocale: const Locale('en'));

    expect(controller.consentAcceptedAt, isNull);
    expect(controller.hasValidConsent, isFalse);

    await controller.acceptConsent(now: DateTime(2026, 10, 8));
    expect(controller.consentAcceptedAt, DateTime(2026, 10, 8));
    expect(controller.hasValidConsent, isTrue);

    final reloaded = SettingsController(store);
    await reloaded.load(deviceLocale: const Locale('en'));
    expect(reloaded.consentAcceptedAt, DateTime(2026, 10, 8));
    expect(reloaded.hasValidConsent, isTrue);
  });

  test('reset all restores every preference to its default', () async {
    final store = InMemorySettingsStore();

    final controller = SettingsController(store);
    await controller.load(deviceLocale: const Locale('en'));
    await controller.setLocale(const Locale('ar'));
    await controller.setThemeMode(ThemeMode.dark);
    await controller.setStyle(AppStyle.professional);
    await controller.setNotifyOrders(false);
    await controller.setPrivacyAnalytics(true);
    await controller.acceptConsent(now: DateTime(2026, 10, 8));

    await controller.resetAll(deviceLocale: const Locale('fr'));

    expect(controller.locale, const Locale('fr'));
    expect(controller.themeMode, ThemeMode.system);
    expect(controller.style, AppStyle.modern);
    expect(controller.notifyOrders, isTrue);
    expect(controller.privacyAnalytics, isFalse);
    expect(controller.consentAcceptedAt, isNull);

    final reloaded = SettingsController(store);
    await reloaded.load(deviceLocale: const Locale('en'));
    expect(reloaded.themeMode, ThemeMode.system);
    expect(reloaded.style, AppStyle.modern);
    expect(reloaded.privacyAnalytics, isFalse);
    expect(reloaded.consentAcceptedAt, isNull);
  });

  test('export preferences returns an entry for every stored preference',
      () async {
    final controller = await newController();
    await controller.setLocale(const Locale('ar'));
    await controller.setThemeMode(ThemeMode.dark);
    await controller.setNotifyWeekly(true);
    await controller.setPrivacyCrash(true);

    final exported = controller.exportPreferences();

    expect(exported[SettingsController.localeKey], 'ar');
    expect(exported[SettingsController.themeModeKey], 'dark');
    expect(exported[SettingsController.notifyWeeklyKey], 'true');
    expect(exported[SettingsController.privacyCrashKey], 'true');
    expect(exported, contains(SettingsController.styleKey));
  });

  testWidgets('settings search filters the visible sections',
      (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);
    await openSettings(tester);

    final text = await l10n(const Locale('en'));

    await tester.enterText(
      find.byKey(const Key('settings-search')),
      text.sectionNotifications,
    );
    await tester.pump();
    expect(find.text(text.sectionNotifications), findsWidgets);
    expect(find.text(text.notifOrders), findsOneWidget);

    await tester.enterText(find.byKey(const Key('settings-search')), 'xyzzy');
    await tester.pump();
    expect(find.text(text.settingsNoResults('xyzzy')), findsOneWidget);
    expect(find.text(text.notifOrders), findsNothing);
  });

  testWidgets('consent can be accepted from the settings page',
      (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);
    await openSettings(tester);

    await tester.ensureVisible(find.byKey(const Key('consent-review')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('consent-review')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('consent-accept')));
    await tester.pumpAndSettle();

    expect(controller.consentAcceptedAt, isNotNull);
    expect(controller.hasValidConsent, isTrue);
  });

  testWidgets('reset all is confirmed through a dialog', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await controller.setThemeMode(ThemeMode.dark);
    await controller.setStyle(AppStyle.professional);
    await pumpApp(tester, controller);
    await openSettings(tester);

    await tester.ensureVisible(find.byKey(const Key('data-reset')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('data-reset')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-confirm')), findsOneWidget);
    await tester.tap(find.byKey(const Key('reset-confirm')));
    await tester.pumpAndSettle();

    expect(controller.themeMode, ThemeMode.system);
    expect(controller.style, AppStyle.modern);
  });

  testWidgets('about section exposes app metadata', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);
    await openSettings(tester);

    await tester.ensureVisible(find.byKey(const Key('about-licenses')));
    await tester.pump();

    expect(find.text(AppInfo.version), findsWidgets);
    expect(find.text(AppInfo.buildNumber), findsWidgets);
  });
}