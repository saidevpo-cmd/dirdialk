import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colour roles that are not fully expressible through [ColorScheme]
/// alone (brand accent, explicit card/border tokens, status colours).
///
/// Registered as a [ThemeExtension] so it is available from any widget via
/// `context.palette` and automatically animates between light and dark mode.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.card,
    required this.cardElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.shadow,
    required this.isDark,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color card;
  final Color cardElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color shadow;
  final bool isDark;

  static const AppPalette light = AppPalette(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    accent: AppColors.accent,
    background: AppColors.lightBackground,
    card: AppColors.lightCard,
    cardElevated: AppColors.lightCard,
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightText,
    textSecondary: AppColors.lightTextSecondary,
    success: AppColors.successLight,
    warning: AppColors.warning,
    danger: AppColors.danger,
    info: AppColors.info,
    shadow: AppColors.lightText,
    isDark: false,
  );

  static const AppPalette dark = AppPalette(
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    accent: AppColors.accent,
    background: AppColors.darkBackground,
    card: AppColors.darkCard,
    cardElevated: AppColors.darkCardElevated,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    danger: AppColors.dangerDark,
    info: AppColors.infoDark,
    shadow: Color(0xFF000000),
    isDark: true,
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  AppPalette copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? card,
    Color? cardElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? shadow,
    bool? isDark,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      card: card ?? this.card,
      cardElevated: cardElevated ?? this.cardElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      shadow: shadow ?? this.shadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      primary: c(primary, other.primary),
      secondary: c(secondary, other.secondary),
      accent: c(accent, other.accent),
      background: c(background, other.background),
      card: c(card, other.card),
      cardElevated: c(cardElevated, other.cardElevated),
      border: c(border, other.border),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      info: c(info, other.info),
      shadow: c(shadow, other.shadow),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => AppPalette.of(this);
}
