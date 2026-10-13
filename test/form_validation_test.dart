import 'package:diali/app/app.dart';
import 'package:diali/core/navigation/nav_section.dart';
import 'package:diali/core/settings/settings_controller.dart';
import 'package:diali/core/storage/settings_store.dart';
import 'package:diali/features/shell/app_shell.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<SettingsController> newController() async {
  final controller = SettingsController(InMemorySettingsStore());
  await controller.load(deviceLocale: const Locale('en'));
  return controller;
}

Future<AppLocalizations> l10n() =>
    AppLocalizations.delegate.load(const Locale('en'));

Future<void> openSection(WidgetTester tester, NavSection section) async {
  await tester.tap(find.byKey(AppShell.navTile(section)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('product dialog blocks an empty name', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(DialiApp(settings: await newController()));
    await tester.pump();
    final strings = await l10n();
    await openSection(tester, NavSection.products);

    await tester
        .tap(find.widgetWithText(FilledButton, strings.actionAddProduct).first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, strings.actionCreate));
    await tester.pumpAndSettle();

    expect(find.text(strings.productNameRequired), findsOneWidget);
  });

  testWidgets('customer dialog blocks an empty name', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(DialiApp(settings: await newController()));
    await tester.pump();
    final strings = await l10n();
    await openSection(tester, NavSection.customers);

    await tester
        .tap(find.widgetWithText(FilledButton, strings.actionAddCustomer).first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, strings.actionCreate));
    await tester.pumpAndSettle();

    expect(find.text(strings.fieldRequired), findsOneWidget);
  });
}
