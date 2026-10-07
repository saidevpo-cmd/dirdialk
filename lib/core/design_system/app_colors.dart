import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const modernSeed = Color(0xFF6750A4);
  static const minimalSeed = Color(0xFF00695C);
  static const professionalSeed = Color(0xFF1D4E89);

  static const successLight = Color(0xFF2E7D32);
  static const successDark = Color(0xFF66BB6A);
  static const warning = Color(0xFFED6C02);
  static const danger = Color(0xFFB3261E);

  static Color success(Brightness brightness) =>
      brightness == Brightness.dark ? successDark : successLight;
}
