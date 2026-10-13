import 'package:diali/app/app.dart';
import 'package:diali/core/navigation/nav_section.dart';
import 'package:diali/core/settings/settings_controller.dart';
import 'package:diali/core/storage/settings_store.dart';
import 'package:diali/features/categories/categories_page.dart';
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

Future<void> pumpApp(WidgetTester tester) async {
  final controller = await newController();
  await tester.pumpWidget(DialiApp(settings: controller));
  await tester.pump();
}

void useView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> openCategories(WidgetTester tester) async {
  await tester.tap(find.byKey(AppShell.navTile(NavSection.categories)));
  await tester.pumpAndSettle();
  expect(find.byType(CategoriesPage), findsOneWidget);
}

Finder dialogTextField(String label) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(TextField, label),
    );

Finder dialogConfirm(String label) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, label),
    );

Future<void> addCategory(
  WidgetTester tester,
  AppLocalizations l10n,
  String name,
) async {
  await tester.tap(
    find.widgetWithText(FilledButton, l10n.addCategory),
  );
  await tester.pumpAndSettle();
  await tester.enterText(dialogTextField(l10n.categoryName).first, name);
  await tester.tap(dialogConfirm(l10n.addCategory));
  await tester.pumpAndSettle();
}

Future<void> deleteCategoryRow(WidgetTester tester, String name) async {
  final textFinder = find.text(name);
  final textCenter = tester.getCenter(textFinder);
  final deleteButtons = find.byIcon(Icons.delete_outline);
  final count = tester.widgetList(deleteButtons).length;

  for (var i = 0; i < count; i++) {
    final center = tester.getCenter(deleteButtons.at(i));
    if ((center.dy - textCenter.dy).abs() < 12) {
      await tester.ensureVisible(deleteButtons.at(i));
      await tester.pumpAndSettle();
      await tester.tap(deleteButtons.at(i), warnIfMissed: false);
      return;
    }
  }
  fail('No delete button found on the row for "$name".');
}

void main() {
  testWidgets('categories can be created and show up in the list',
      (tester) async {
    useView(tester, const Size(1400, 900));
    await pumpApp(tester);
    final localized = await l10n();
    await openCategories(tester);

    expect(find.byKey(const Key('categories-page')), findsOneWidget);

    await addCategory(tester, localized, 'Test Category A');

    expect(find.text('Test Category A'), findsOneWidget);
  });

  testWidgets('creating a category with a duplicate name is rejected',
      (tester) async {
    useView(tester, const Size(1400, 900));
    await pumpApp(tester);
    final localized = await l10n();
    await openCategories(tester);

    await addCategory(tester, localized, 'Test Category B');
    expect(find.text('Test Category B'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, localized.addCategory),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      dialogTextField(localized.categoryName).first,
      'test category b',
    );
    await tester.tap(dialogConfirm(localized.addCategory));
    await tester.pumpAndSettle();

    expect(find.textContaining('already exists'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(TextButton, localized.actionCancel),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('a category can be deleted from the list', (tester) async {
    useView(tester, const Size(1400, 900));
    await pumpApp(tester);
    final localized = await l10n();
    await openCategories(tester);

    await addCategory(tester, localized, 'Doomed Category');
    expect(find.text('Doomed Category'), findsOneWidget);

    await deleteCategoryRow(tester, 'Doomed Category');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, localized.actionConfirm));
    await tester.pumpAndSettle();

    expect(find.text('Doomed Category'), findsNothing);
  });
}