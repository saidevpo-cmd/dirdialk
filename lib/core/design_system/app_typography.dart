import 'package:flutter/material.dart';

import 'app_style.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme apply(
    TextTheme base,
    AppStyleConfig config,
    Brightness brightness,
  ) {
    TextStyle? titleStyle(TextStyle? style) => style?.copyWith(
          fontWeight: config.titleWeight,
          letterSpacing: config.titleLetterSpacing,
          height: 1.2,
        );

    TextStyle? bodyStyle(TextStyle? style) =>
        style?.copyWith(height: config.bodyHeight);

    return base.copyWith(
      displayLarge: bodyStyle(base.displayLarge),
      displayMedium: bodyStyle(base.displayMedium),
      displaySmall: bodyStyle(base.displaySmall),
      headlineLarge: titleStyle(base.headlineLarge),
      headlineMedium: titleStyle(base.headlineMedium),
      headlineSmall: titleStyle(base.headlineSmall),
      titleLarge: titleStyle(base.titleLarge),
      titleMedium: titleStyle(base.titleMedium),
      titleSmall: titleStyle(base.titleSmall),
      bodyLarge: bodyStyle(base.bodyLarge),
      bodyMedium: bodyStyle(base.bodyMedium),
      bodySmall: bodyStyle(base.bodySmall),
      labelLarge: titleStyle(base.labelLarge),
      labelMedium: bodyStyle(base.labelMedium),
      labelSmall: bodyStyle(base.labelSmall),
    );
  }
}
