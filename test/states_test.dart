import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:diali/shared/widgets/error_state_view.dart';
import 'package:diali/shared/widgets/responsive_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> load(Locale locale) =>
    AppLocalizations.delegate.load(locale);

Widget wrap(Locale locale, Widget child) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('ErrorStateView uses localized title, retry label and callback',
      (tester) async {
    final ar = await load(const Locale('ar'));
    var retried = false;

    await tester.pumpWidget(wrap(
      const Locale('ar'),
      ErrorStateView(message: 'تعذر التحميل', onRetry: () => retried = true),
    ));
    await tester.pumpAndSettle();

    expect(find.text(ar.errorTitle), findsOneWidget);
    expect(find.text('تعذر التحميل'), findsOneWidget);
    await tester.tap(find.text(ar.actionRetry));
    expect(retried, isTrue);
  });

  testWidgets('ResponsiveDataTable defaults its empty title to l10n',
      (tester) async {
    final fr = await load(const Locale('fr'));

    await tester.pumpWidget(wrap(
      const Locale('fr'),
      ResponsiveDataTable<String>(
        items: const [],
        columns: const [TableColumnDef(label: 'A')],
        rowBuilder: (context, item, index) => const [],
        mobileCardBuilder: (context, item, index) => const SizedBox.shrink(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text(fr.noRecordsTitle), findsOneWidget);
  });
}
