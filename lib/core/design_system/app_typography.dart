import 'package:flutter/material.dart';

import 'app_style.dart';

class AppTypography {
  const AppTypography._();

  /// Primary UI font. Latin script is rendered with Inter; any glyph Inter
  /// does not cover (notably Arabic) falls back to Cairo automatically.
  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = ['Cairo'];

  static TextTheme apply(
    TextTheme base,
    AppStyleConfig config,
    Brightness brightness, {
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    TextStyle? withFont(TextStyle? style) {
      if (style == null) return null;
      return style.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      );
    }

    TextStyle? titleStyle(TextStyle? style) => withFont(style)?.copyWith(
          fontWeight: config.titleWeight,
          letterSpacing: config.titleLetterSpacing,
          height: 1.2,
        );

    TextStyle? bodyStyle(TextStyle? style) =>
        withFont(style)?.copyWith(height: config.bodyHeight);

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
