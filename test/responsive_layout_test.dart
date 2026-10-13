import 'package:diali/core/design_system/app_spacing.dart';
import 'package:diali/shared/utils/dialog_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('breakpoints split mobile, tablet and desktop', () {
    expect(AppBreakpoints.isMobile(719), isTrue);
    expect(AppBreakpoints.isMobile(720), isFalse);
    expect(AppBreakpoints.isDesktop(1099), isFalse);
    expect(AppBreakpoints.isDesktop(1100), isTrue);
  });

  testWidgets('dialog width keeps its preferred size on wide viewports',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late double width;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        width = dialogContentWidth(context, 560);
        return const SizedBox.shrink();
      }),
    ));

    expect(width, 560);
  });

  testWidgets('dialog width is clamped on a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late double width;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        width = dialogContentWidth(context, 560);
        return const SizedBox.shrink();
      }),
    ));

    expect(width, lessThan(560));
    expect(width, 360 - AppSpacing.lg * 2);
  });
}
