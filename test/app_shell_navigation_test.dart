import 'package:diali/app/app.dart';
import 'package:diali/core/navigation/nav_section.dart';
import 'package:diali/core/settings/settings_controller.dart';
import 'package:diali/core/storage/settings_store.dart';
import 'package:diali/features/orders/orders_page.dart';
import 'package:diali/features/products/products_page.dart';
import 'package:diali/features/shell/app_shell.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> l10n(Locale locale) =>
    AppLocalizations.delegate.load(locale);

Future<SettingsController> newController() async {
  final controller = SettingsController(InMemorySettingsStore());
  await controller.load(deviceLocale: const Locale('en'));
  return controller;
}

Future<void> pumpApp(
  WidgetTester tester,
  SettingsController controller,
) async {
  await tester.pumpWidget(DialiApp(settings: controller));
  await tester.pumpAndSettle();
}

void useView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

AnimatedOpacity backToTop(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byKey(AppShell.backToTopKey));

IconButton sidebarToggle(WidgetTester tester) =>
    tester.widget<IconButton>(find.byKey(AppShell.sidebarToggleKey));

/// Drags the routed page downwards (content moves up) and settles.
Future<void> scrollDown(WidgetTester tester, double distance) async {
  await tester.drag(
    find.byKey(AppShell.bodyKey).first,
    Offset(0, -distance),
  );
  await tester.pumpAndSettle();
}

double bodyOffset(WidgetTester tester) {
  final state = tester.state<ScrollableState>(
    find
        .descendant(
          of: find.byKey(AppShell.bodyKey),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  return state.position.pixels;
}

void main() {
  group('back to top', () {
    testWidgets('stays hidden until the page is scrolled down',
        (tester) async {
      useView(tester, const Size(1400, 700));
      await pumpApp(tester, await newController());

      // Nothing scrolled yet: the button exists but is invisible and
      // unreachable, so the top bar keeps its clean first impression.
      expect(backToTop(tester).opacity, 0);
      final hidden = tester.widget<IgnorePointer>(
        find
            .descendant(
              of: find.byKey(AppShell.backToTopKey),
              matching: find.byType(IgnorePointer),
            )
            .first,
      );
      expect(hidden.ignoring, isTrue);

      await tester.tap(find.byKey(AppShell.navTile(NavSection.orders)));
      await tester.pumpAndSettle();
      expect(find.byType(OrdersPage), findsOneWidget);
      expect(backToTop(tester).opacity, 0);

      await scrollDown(tester, 600);
      expect(bodyOffset(tester), greaterThan(300));
      expect(backToTop(tester).opacity, 1);
    });

    testWidgets('returns to the top with a smooth scroll and hides again',
        (tester) async {
      useView(tester, const Size(1400, 700));
      await pumpApp(tester, await newController());
      await tester.tap(find.byKey(AppShell.navTile(NavSection.orders)));
      await tester.pumpAndSettle();

      await scrollDown(tester, 600);
      expect(bodyOffset(tester), greaterThan(300));

      await tester.tap(
        find.descendant(
          of: find.byKey(AppShell.backToTopKey),
          matching: find.byType(IconButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(bodyOffset(tester), 0);
      expect(backToTop(tester).opacity, 0);
    });

    testWidgets('works on every routed section that scrolls', (tester) async {
      useView(tester, const Size(1400, 700));
      await pumpApp(tester, await newController());

      for (final section in const [
        NavSection.products,
        NavSection.orders,
        NavSection.settings,
      ]) {
        await tester.tap(find.byKey(AppShell.navTile(section)));
        await tester.pumpAndSettle();
        expect(find.byKey(AppShell.bodyKey), findsOneWidget);

        await scrollDown(tester, 500);
        if (bodyOffset(tester) > 300) {
          expect(backToTop(tester).opacity, 1,
              reason: 'back to top should show on ${section.name}');

          await tester.tap(
            find.descendant(
              of: find.byKey(AppShell.backToTopKey),
              matching: find.byType(IconButton),
            ),
          );
          await tester.pumpAndSettle();
          expect(bodyOffset(tester), 0,
              reason: 'should return to the top on ${section.name}');
        }
      }
    });

    testWidgets('shows on mobile once the drawer page is scrolled',
        (tester) async {
      useView(tester, const Size(360, 700));
      await pumpApp(tester, await newController());
      await tester.tap(find.byKey(AppShell.openMenuKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppShell.navTile(NavSection.orders)));
      await tester.pumpAndSettle();

      expect(backToTop(tester).opacity, 0);
      await scrollDown(tester, 500);
      if (bodyOffset(tester) > 300) {
        expect(backToTop(tester).opacity, 1);
      }
    });
  });

  group('hide / show sidebar', () {
    testWidgets('collapses the desktop sidebar and expands the body',
        (tester) async {
      useView(tester, const Size(1400, 700));
      final controller = await newController();
      await pumpApp(tester, controller);
      final l10nEn = await l10n(const Locale('en'));

      expect(find.byKey(AppShell.headerKey), findsOneWidget);
      expect(find.byKey(AppShell.sidebarKey), findsOneWidget);
      expect(sidebarToggle(tester).tooltip, l10nEn.hideSidebar);

      final collapsedWidth = tester.getSize(find.byKey(AppShell.bodyKey)).width;

      await tester.tap(find.byKey(AppShell.sidebarToggleKey));
      await tester.pumpAndSettle();

      // Sidebar gone, body reclaims exactly the freed width, icon flips.
      expect(find.byKey(AppShell.sidebarKey), findsNothing);
      final expandedWidth = tester.getSize(find.byKey(AppShell.bodyKey)).width;
      expect(expandedWidth, greaterThan(collapsedWidth));
      expect(sidebarToggle(tester).tooltip, l10nEn.showSidebar);
      expect((sidebarToggle(tester).icon as Icon).icon, Icons.menu);

      // Navigation keeps working while the sidebar is hidden: the header's
      // quick-settings action still routes to the settings section.
      await tester.tap(find.byKey(AppShell.quickSettingsKey));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings-page')), findsOneWidget);
      expect(find.byKey(AppShell.sidebarKey), findsNothing);

      // Restore the sidebar: the navigation is intact and the settings tile
      // is still the selected route.
      await tester.tap(find.byKey(AppShell.sidebarToggleKey));
      await tester.pumpAndSettle();
      expect(find.byKey(AppShell.sidebarKey), findsOneWidget);
      expect(sidebarToggle(tester).tooltip, l10nEn.hideSidebar);
      expect((sidebarToggle(tester).icon as Icon).icon, Icons.menu_open);
      expect(
        tester.widget<Material>(
          find.byKey(AppShell.navTile(NavSection.settings)),
        ).color,
        isNot(Colors.transparent),
        reason: 'the selected section keeps its highlight after a toggle',
      );
    });

    testWidgets('keeps the selected section and nav highlight after a toggle',
        (tester) async {
      useView(tester, const Size(1400, 700));
      await pumpApp(tester, await newController());

      await tester.tap(find.byKey(AppShell.navTile(NavSection.products)));
      await tester.pumpAndSettle();
      expect(find.byType(ProductsPage), findsOneWidget);

      await tester.tap(find.byKey(AppShell.sidebarToggleKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppShell.sidebarToggleKey));
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(find.byKey(AppShell.sidebarKey), findsOneWidget);
    });

    testWidgets('tablet toggles the navigation rail too', (tester) async {
      useView(tester, const Size(800, 600));
      await pumpApp(tester, await newController());
      final l10nEn = await l10n(const Locale('en'));

      expect(find.byKey(AppShell.navRailKey), findsOneWidget);
      expect(sidebarToggle(tester).tooltip, l10nEn.hideSidebar);

      await tester.tap(find.byKey(AppShell.sidebarToggleKey));
      await tester.pumpAndSettle();

      expect(find.byKey(AppShell.navRailKey), findsNothing);
      expect(sidebarToggle(tester).tooltip, l10nEn.showSidebar);
    });

    testWidgets('mobile keeps the drawer menu button as its sidebar toggle',
        (tester) async {
      useView(tester, const Size(360, 780));
      await pumpApp(tester, await newController());

      // The desktop toggle does not exist on mobile: the drawer menu button
      // is the show/hide control there.
      expect(find.byKey(AppShell.sidebarToggleKey), findsNothing);
      expect(find.byKey(AppShell.openMenuKey), findsOneWidget);
      expect(find.byKey(AppShell.sidebarKey), findsNothing);

      await tester.tap(find.byKey(AppShell.openMenuKey));
      await tester.pumpAndSettle();
      expect(find.byKey(AppShell.drawerKey), findsOneWidget);
      expect(find.byKey(AppShell.sidebarKey), findsNothing);
    });
  });
}
