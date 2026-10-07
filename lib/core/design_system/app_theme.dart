import 'package:flutter/material.dart';

import 'app_style.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build(AppStyle style, Brightness brightness) {
    final config = AppStyleConfig.of(style);
    final scheme =
        ColorScheme.fromSeed(seedColor: config.seedColor, brightness: brightness);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    final textTheme = AppTypography.apply(base.textTheme, config, brightness);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(config.buttonRadius),
    );

    return base.copyWith(
      textTheme: textTheme,
      dividerColor: scheme.outlineVariant,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: const Size(64, 44),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          minimumSize: const Size(64, 44),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: shape),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
        ),
      ),
      extensions: [AppStyleData(config)],
    );
  }
}
