import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AppStyle { modern, minimal, professional }

@immutable
class AppStyleConfig {
  const AppStyleConfig({
    required this.style,
    required this.seedColor,
    required this.cardRadius,
    required this.buttonRadius,
    required this.cardBorderWidth,
    required this.cardShadowBlur,
    required this.cardPadding,
    required this.spacingScale,
    required this.titleWeight,
    required this.titleLetterSpacing,
    required this.bodyHeight,
    required this.navIndicatorRadius,
    required this.sidebarWidth,
  });

  final AppStyle style;
  final Color seedColor;
  final double cardRadius;
  final double buttonRadius;
  final double cardBorderWidth;
  final double cardShadowBlur;
  final EdgeInsets cardPadding;
  final double spacingScale;
  final FontWeight titleWeight;
  final double titleLetterSpacing;
  final double bodyHeight;
  final double navIndicatorRadius;
  final double sidebarWidth;

  static AppStyleConfig of(AppStyle style) => switch (style) {
        AppStyle.modern => _modern,
        AppStyle.minimal => _minimal,
        AppStyle.professional => _professional,
      };

  static const _modern = AppStyleConfig(
    style: AppStyle.modern,
    seedColor: AppColors.modernSeed,
    cardRadius: 16,
    buttonRadius: 12,
    cardBorderWidth: 1,
    cardShadowBlur: 10,
    cardPadding: EdgeInsets.all(20),
    spacingScale: 1,
    titleWeight: FontWeight.w700,
    titleLetterSpacing: -0.2,
    bodyHeight: 1.5,
    navIndicatorRadius: 12,
    sidebarWidth: 264,
  );

  static const _minimal = AppStyleConfig(
    style: AppStyle.minimal,
    seedColor: AppColors.minimalSeed,
    cardRadius: 4,
    buttonRadius: 4,
    cardBorderWidth: 1,
    cardShadowBlur: 0,
    cardPadding: EdgeInsets.all(16),
    spacingScale: 0.8,
    titleWeight: FontWeight.w600,
    titleLetterSpacing: 0,
    bodyHeight: 1.4,
    navIndicatorRadius: 4,
    sidebarWidth: 240,
  );

  static const _professional = AppStyleConfig(
    style: AppStyle.professional,
    seedColor: AppColors.professionalSeed,
    cardRadius: 8,
    buttonRadius: 6,
    cardBorderWidth: 0,
    cardShadowBlur: 4,
    cardPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
    spacingScale: 1.15,
    titleWeight: FontWeight.w700,
    titleLetterSpacing: 0,
    bodyHeight: 1.35,
    navIndicatorRadius: 6,
    sidebarWidth: 280,
  );
}

@immutable
class AppStyleData extends ThemeExtension<AppStyleData> {
  const AppStyleData(this.config);

  final AppStyleConfig config;

  @override
  AppStyleData copyWith({AppStyleConfig? config}) =>
      AppStyleData(config ?? this.config);

  @override
  AppStyleData lerp(ThemeExtension<AppStyleData>? other, double t) {
    if (other is! AppStyleData) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppStyleDataX on BuildContext {
  AppStyleConfig get styleConfig =>
      Theme.of(this).extension<AppStyleData>()!.config;
}
