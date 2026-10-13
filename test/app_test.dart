import 'package:diali/app/app.dart';
import 'package:diali/core/design_system/app_style.dart';
import 'package:diali/core/navigation/nav_section.dart';
import 'package:diali/core/settings/settings_controller.dart';
import 'package:diali/core/storage/settings_store.dart';
import 'package:diali/features/dashboard/dashboard_page.dart';
import 'package:diali/features/orders/orders_page.dart';
import 'package:diali/features/products/products_page.dart';
import 'package:diali/features/settings/settings_page.dart';
import 'package:diali/features/shell/app_shell.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
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

void useView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

TextDirection directionOf(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(AppShell)));

MaterialApp appWidget(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp));

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byKey(AppShell.navTile(NavSection.settings)));
  await tester.pump();
  expect(find.byKey(const Key('settings-page')), findsOneWidget);
}

void main() {
  testWidgets('1. opens directly on the dashboard without login',
      (tester) async {
    final controller = await newController();
    await pumpApp(tester, controller);

    final text = await l10n(const Locale('en'));
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.text(text.dashboardSubtitle), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Login'), findsNothing);
    expect(find.text('Register'), findsNothing);
  });

  testWidgets('3. desktop navigation works', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);

    expect(find.byKey(AppShell.sidebarKey), findsOneWidget);

    await tester.tap(find.byKey(AppShell.navTile(NavSection.products)));
    await tester.pumpAndSettle();
    expect(find.byType(ProductsPage), findsOneWidget);

    await tester.tap(find.byKey(AppShell.navTile(NavSection.dashboard)));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('4 + 5. Arabic works and layout becomes RTL', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);

    await openSettings(tester);
    await tester.tap(find.text('العربية'));
    await tester.pump();

    expect(controller.locale, const Locale('ar'));
    expect(directionOf(tester), TextDirection.rtl);
    expect(find.text('لوحة التحكم'), findsWidgets);
    expect(
      appWidget(tester).locale,
      const Locale('ar'),
    );
  });

  testWidgets('6. English works with LTR', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);

    expect(controller.locale, const Locale('en'));
    expect(directionOf(tester), TextDirection.ltr);
    expect(find.text('Dashboard'), findsWidgets);

    await openSettings(tester);
    await tester.tap(find.text('Français'));
    await tester.pump();
    await tester.tap(find.text('English'));
    await tester.pump();

    expect(controller.locale, const Locale('en'));
    expect(directionOf(tester), TextDirection.ltr);
  });

  testWidgets('7. French works', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);

    await openSettings(tester);
    await tester.tap(find.text('Français'));
    await tester.pump();

    expect(controller.locale, const Locale('fr'));
    expect(directionOf(tester), TextDirection.ltr);
    expect(find.text('Tableau de bord'), findsWidgets);
    expect(find.text('Paramètres'), findsWidgets);
  });

  testWidgets('8. light mode works', (tester) async {
    final controller = await newController();
    await controller.setThemeMode(ThemeMode.light);
    await pumpApp(tester, controller);

    final app = appWidget(tester);
    expect(app.themeMode, ThemeMode.light);
    expect(app.theme!.brightness, Brightness.light);
    expect(
      Theme.of(tester.element(find.byType(DashboardPage))).brightness,
      Brightness.light,
    );
  });

  testWidgets('9. dark mode works and is switchable from settings',
      (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);

    await openSettings(tester);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(controller.themeMode, ThemeMode.dark);
    final app = appWidget(tester);
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme!.brightness, Brightness.dark);
    expect(
      Theme.of(tester.element(find.byType(SettingsPage))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('10. style switching changes the theme configuration',
      (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);

    expect(controller.style, AppStyle.modern);
    await openSettings(tester);
    expect(
      appWidget(tester)
          .theme!
          .extension<AppStyleData>()!
          .config
          .style,
      AppStyle.modern,
    );

    await tester.tap(find.text('Professional'));
    await tester.pump();
    expect(controller.style, AppStyle.professional);
    expect(
      appWidget(tester)
          .theme!
          .extension<AppStyleData>()!
          .config
          .style,
      AppStyle.professional,
    );

    await tester.tap(find.text('Minimal'));
    await tester.pump();
    expect(controller.style, AppStyle.minimal);
    final config = appWidget(tester).theme!.extension<AppStyleData>()!.config;
    expect(config.style, AppStyle.minimal);
    expect(config.cardRadius, 4);
  });

  testWidgets('11. settings persist after a restart', (tester) async {
    final store = InMemorySettingsStore();

    final first = SettingsController(store);
    await first.load(deviceLocale: const Locale('en'));
    await first.setLocale(const Locale('ar'));
    await first.setThemeMode(ThemeMode.dark);
    await first.setStyle(AppStyle.professional);
    await pumpApp(tester, first);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final second = SettingsController(store);
    await second.load(deviceLocale: const Locale('fr'));
    await pumpApp(tester, second);

    expect(second.locale, const Locale('ar'));
    expect(second.themeMode, ThemeMode.dark);
    expect(second.style, AppStyle.professional);

    final app = appWidget(tester);
    expect(app.locale, const Locale('ar'));
    expect(app.themeMode, ThemeMode.dark);
    expect(
      app.darkTheme!.extension<AppStyleData>()!.config.style,
      AppStyle.professional,
    );
    expect(directionOf(tester), TextDirection.rtl);
  });

  testWidgets('12. responsive layout adapts to the screen size',
      (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);
    expect(find.byKey(AppShell.sidebarKey), findsOneWidget);
    expect(find.byKey(AppShell.navRailKey), findsNothing);

    tester.view.physicalSize = const Size(800, 600);
    await tester.pump();
    expect(find.byKey(AppShell.navRailKey), findsOneWidget);
    expect(find.byKey(AppShell.sidebarKey), findsNothing);
    expect(find.byKey(AppShell.openMenuKey), findsNothing);

    tester.view.physicalSize = const Size(360, 780);
    await tester.pump();
    expect(find.byKey(AppShell.navRailKey), findsNothing);
    expect(find.byKey(AppShell.sidebarKey), findsNothing);
    expect(find.byKey(AppShell.openMenuKey), findsOneWidget);

    await tester.tap(find.byKey(AppShell.openMenuKey));
    await tester.pumpAndSettle();
    expect(find.byKey(AppShell.drawerKey), findsOneWidget);

    await tester.tap(find.byKey(AppShell.navTile(NavSection.orders)));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersPage), findsOneWidget);
  });

  testWidgets('quick actions navigate to their section', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);
    final text = await l10n(const Locale('en'));

    await tester.tap(find.text(text.actionAddProduct));
    await tester.pumpAndSettle();
    expect(find.byType(ProductsPage), findsOneWidget);
  });

  testWidgets('view all opens the orders section', (tester) async {
    useView(tester, const Size(1400, 900));
    final controller = await newController();
    await pumpApp(tester, controller);
    final text = await l10n(const Locale('en'));

    await tester.tap(find.text(text.viewAll));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersPage), findsOneWidget);
  });
}
