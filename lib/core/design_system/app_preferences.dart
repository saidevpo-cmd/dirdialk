import 'package:flutter/material.dart';

/// User preference enums and small value helpers.
///
/// Every enum here is persisted by name through [SettingsStore] so a missing
/// or unknown value always falls back to the matching default.
enum AppFontSize {
  small,
  medium,
  large;

  double get scale => switch (this) {
        AppFontSize.small => 0.9,
        AppFontSize.medium => 1,
        AppFontSize.large => 1.12,
      };
}

enum AppDensity {
  compact,
  comfortable,
  spacious;

  double get scale => switch (this) {
        AppDensity.compact => 0.8,
        AppDensity.comfortable => 1,
        AppDensity.spacious => 1.3,
      };
}

enum AppCornerStyle {
  sharp,
  medium,
  rounded;

  /// Applies the corner style to a base radius coming from the visual style.
  double apply(double base) => switch (this) {
        AppCornerStyle.sharp => (base * 0.35).clamp(2, 6).toDouble(),
        AppCornerStyle.medium => base,
        AppCornerStyle.rounded => (base * 1.5).clamp(16, 32).toDouble(),
      };
}

enum AppShadowLevel {
  off,
  low,
  medium;

  double get blur => switch (this) {
        AppShadowLevel.off => 0,
        AppShadowLevel.low => 6,
        AppShadowLevel.medium => 12,
      };
}

enum AppDirectionMode {
  automatic,
  rtl,
  ltr;
}

enum AppSidebarState {
  expanded,
  collapsed;
}

/// Parses [stored] against [values] by enum name, falling back to [fallback].
T parsePreferenceEnum<T extends Enum>(
  List<T> values,
  String? stored,
  T fallback,
) {
  for (final value in values) {
    if (value.name == stored) return value;
  }
  return fallback;
}

String colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';

Color? colorFromHex(String? stored) {
  if (stored == null || stored.isEmpty) return null;
  var hex = stored.replaceFirst('#', '').trim();
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return Color(value);
}
