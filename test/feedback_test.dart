import 'package:diali/domain/models/app_error.dart';
import 'package:diali/shared/utils/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a minimal app and hands back a [BuildContext] below the Scaffold.
Future<BuildContext> pumpHost(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(builder: (context) {
        ctx = context;
        return const SizedBox.shrink();
      }),
    ),
  ));
  return ctx;
}

void main() {
  testWidgets('success shows a confirmation snack bar', (tester) async {
    final ctx = await pumpHost(tester);

    AppFeedback.success(ctx, 'Saved successfully');
    await tester.pump();

    expect(find.text('Saved successfully'), findsOneWidget);
  });

  testWidgets('error surfaces the AppError message', (tester) async {
    final ctx = await pumpHost(tester);

    AppFeedback.error(ctx, const AppError(code: 'NOPE', message: 'Boom'));
    await tester.pump();

    expect(find.text('Boom'), findsOneWidget);
  });

  testWidgets('fromResult reports the outcome and never fakes success',
      (tester) async {
    final ctx = await pumpHost(tester);

    final ok = AppFeedback.fromResult(
      ctx,
      const Success<Object?>('ok'),
      successMessage: 'Done',
    );
    await tester.pump();
    expect(ok, isTrue);
    expect(find.text('Done'), findsOneWidget);

    final failed = AppFeedback.fromResult(
      ctx,
      const Failure<Object?>(AppError(code: 'X', message: 'Rejected')),
      successMessage: 'Done',
    );
    await tester.pump();
    expect(failed, isFalse);
    expect(find.text('Rejected'), findsOneWidget);
    // The success copy must not appear when the operation failed.
    expect(find.text('Done'), findsNothing);
  });
}
