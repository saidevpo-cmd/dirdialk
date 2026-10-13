import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_style.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] for every visual style.
///
/// All styles share the single brand palette (see [AppColors]); the
/// [AppStyle] only changes shape, elevation, density and typography so the
/// app feels consistent while keeping the personalisation feature.
class AppTheme {
  const AppTheme._();

  static ThemeData build(AppStyle style, Brightness brightness) {
    final config = AppStyleConfig.of(style);
    final palette =
        brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
    final scheme = _scheme(brightness);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    final textTheme = AppTypography.apply(
      base.textTheme,
      config,
      brightness,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
    );
    final radius = BorderRadius.circular(config.cardRadius);
    final buttonRadius = BorderRadius.circular(config.buttonRadius);
    final buttonShape = RoundedRectangleBorder(borderRadius: buttonRadius);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      textTheme: textTheme,
      dividerColor: scheme.outlineVariant,
      extensions: [AppStyleData(config), palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.card,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardRadius + 8),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        modalBackgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape,
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outlineVariant),
          backgroundColor: palette.card,
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.card,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius + 4),
        ),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        showCheckmark: false,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: buttonRadius),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: buttonRadius),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius + 4),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.card,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.card,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
      ),
    );
  }

  static ColorScheme _scheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );

    if (brightness == Brightness.light) {
      return base.copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE6E9FA),
        onPrimaryContainer: const Color(0xFF1A237E),
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFD6F2EC),
        onSecondaryContainer: const Color(0xFF075E52),
        tertiary: AppColors.accent,
        onTertiary: const Color(0xFF3A2A00),
        tertiaryContainer: const Color(0xFFFDEFD0),
        onTertiaryContainer: const Color(0xFF4A3200),
        error: AppColors.danger,
        onError: Colors.white,
        errorContainer: const Color(0xFFFDE4E4),
        onErrorContainer: const Color(0xFF7A1212),
        surface: AppColors.lightCard,
        onSurface: AppColors.lightText,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: const Color(0xFFC7CCD9),
        outlineVariant: AppColors.lightBorder,
        shadow: AppColors.lightText,
        surfaceTint: Colors.transparent,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: AppColors.lightCard,
        surfaceContainer: const Color(0xFFF2F4FA),
        surfaceContainerHigh: const Color(0xFFEDF0F8),
        surfaceContainerHighest: const Color(0xFFE7EAF3),
        inverseSurface: AppColors.lightText,
        onInverseSurface: AppColors.lightBackground,
      );
    }

    return base.copyWith(
      primary: AppColors.primaryDark,
      onPrimary: const Color(0xFF11163A),
      primaryContainer: const Color(0xFF2C3766),
      onPrimaryContainer: const Color(0xFFDDE2FF),
      secondary: AppColors.secondaryDark,
      onSecondary: const Color(0xFF00332B),
      secondaryContainer: const Color(0xFF14544A),
      onSecondaryContainer: const Color(0xFFCFF6EE),
      tertiary: AppColors.accent,
      onTertiary: const Color(0xFF3A2A00),
      tertiaryContainer: const Color(0xFF5A4200),
      onTertiaryContainer: const Color(0xFFFDEFD0),
      error: AppColors.dangerDark,
      onError: const Color(0xFF4A0A0A),
      errorContainer: const Color(0xFF5C1A1A),
      onErrorContainer: const Color(0xFFFDD5D5),
      surface: AppColors.darkCard,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: const Color(0xFF3A4557),
      outlineVariant: AppColors.darkBorder,
      shadow: Colors.black,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: const Color(0xFF0D121C),
      surfaceContainerLow: AppColors.darkCard,
      surfaceContainer: AppColors.darkCardElevated,
      surfaceContainerHigh: const Color(0xFF283244),
      surfaceContainerHighest: const Color(0xFF2E394B),
      inverseSurface: AppColors.darkText,
      onInverseSurface: AppColors.darkBackground,
    );
  }
}
