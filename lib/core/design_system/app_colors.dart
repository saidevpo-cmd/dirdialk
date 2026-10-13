import 'package:flutter/material.dart';

/// Central brand palette and semantic status colors for diali.
///
/// These are raw tokens. Widgets should normally read the semantic
/// [AppPalette] theme extension (`context.palette`) or `ColorScheme` roles so
/// that light and dark mode stay consistent everywhere.
class AppColors {
  const AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────
  static const primary = Color(0xFF3949AB); // Indigo Blue
  static const secondary = Color(0xFF0F9D8A); // Teal
  static const accent = Color(0xFFF4B740); // Warm Yellow

  // Brand tints tinted for dark surfaces (better contrast than raw brand).
  static const primaryDark = Color(0xFF8B97EE);
  static const secondaryDark = Color(0xFF4FD1BE);

  // ── Light surfaces ────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF7F8FC);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF202534);
  static const lightTextSecondary = Color(0xFF687083);
  static const lightBorder = Color(0xFFE4E7EF);

  // ── Dark surfaces ─────────────────────────────────────────────────
  static const darkBackground = Color(0xFF111827);
  static const darkCard = Color(0xFF1B2433);
  static const darkCardElevated = Color(0xFF222C3D);
  static const darkText = Color(0xFFE7E9F0);
  static const darkTextSecondary = Color(0xFF9AA3B2);
  static const darkBorder = Color(0xFF2A3444);

  // ── Status ────────────────────────────────────────────────────────
  static const successLight = Color(0xFF16A34A);
  static const successDark = Color(0xFF4ADE80);
  static const warning = Color(0xFFD97706);
  static const warningDark = Color(0xFFFBBF24);
  static const danger = Color(0xFFDC2626);
  static const dangerDark = Color(0xFFF87171);
  static const info = Color(0xFF2563EB);
  static const infoDark = Color(0xFF60A5FA);
  static const neutralLight = Color(0xFF64748B);
  static const neutralDark = Color(0xFF94A3B8);

  static Color success(Brightness brightness) =>
      brightness == Brightness.dark ? successDark : successLight;

  static Color warningFor(Brightness brightness) =>
      brightness == Brightness.dark ? warningDark : warning;

  static Color dangerFor(Brightness brightness) =>
      brightness == Brightness.dark ? dangerDark : danger;

  static Color infoFor(Brightness brightness) =>
      brightness == Brightness.dark ? infoDark : info;

  static Color neutralFor(Brightness brightness) =>
      brightness == Brightness.dark ? neutralDark : neutralLight;
}
