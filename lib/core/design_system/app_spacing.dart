import 'package:flutter/material.dart';

class AppBreakpoints {
  const AppBreakpoints._();

  static const double mobile = 720;
  static const double desktop = 1100;
  static const double wideContent = 900;

  static bool isMobile(double width) => width < mobile;

  static bool isDesktop(double width) => width >= desktop;
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static EdgeInsets pagePadding(double width) {
    final compact = AppBreakpoints.isMobile(width);
    return EdgeInsets.symmetric(
      horizontal: compact ? 16 : 24,
      vertical: compact ? 16 : 24,
    );
  }

  static double gap(double base, double scale) => base * scale;
}
