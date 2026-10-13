import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';

/// Returns a dialog content width clamped to the current viewport.
///
/// Fixed-width dialogs (480–600px) overflow on phones and small tablets; use
/// this to keep them usable on every breakpoint.
double dialogContentWidth(BuildContext context, double preferred) {
  final width = MediaQuery.sizeOf(context).width;
  final available = width - AppSpacing.lg * 2;
  if (available <= 0) return preferred;
  return preferred < available ? preferred : available;
}
