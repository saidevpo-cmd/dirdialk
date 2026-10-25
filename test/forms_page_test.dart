import 'package:diali/core/design_system/app_style.dart';
import 'package:diali/core/design_system/app_theme.dart';
import 'package:diali/data/app_repositories.dart';
import 'package:diali/features/forms/forms_page.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AppRepositories.reset();
  });

  tearDown(() {
    AppRepositories.reset();
  });

  testWidgets('preview submits through the repository and reports success', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(AppStyle.modern, Brightness.light),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: FormsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('forms-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('preview-form-f-01')));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(3));

    await tester.enterText(fields.at(0), 'Ada Lovelace');
    await tester.enterText(fields.at(1), 'ada@example.com');
    await tester.enterText(fields.at(2), 'Hello from the test suite');

    await tester.tap(find.text(l10n.submitFormAction));
    await tester.pumpAndSettle();

    expect(find.text(l10n.formSubmittedMessage), findsOneWidget);
  });
}
