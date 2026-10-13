import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';

/// Semantic colour families for [StatusBadge]. Prefer these over raw colours so
/// the badge adapts to light/dark mode.
enum StatusTone { success, warning, info, neutral, danger }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.tone,
    this.icon,
  }) : assert(
          color != null || tone != null,
          'Provide either an explicit color or a StatusTone',
        );

  final String label;
  final Color? color;
  final StatusTone? tone;
  final IconData? icon;

  factory StatusBadge.success({required String label, IconData? icon}) {
    return StatusBadge(label: label, tone: StatusTone.success, icon: icon);
  }

  factory StatusBadge.warning({required String label, IconData? icon}) {
    return StatusBadge(label: label, tone: StatusTone.warning, icon: icon);
  }

  factory StatusBadge.info({required String label, IconData? icon}) {
    return StatusBadge(label: label, tone: StatusTone.info, icon: icon);
  }

  factory StatusBadge.neutral({required String label, IconData? icon}) {
    return StatusBadge(label: label, tone: StatusTone.neutral, icon: icon);
  }

  factory StatusBadge.danger({required String label, IconData? icon}) {
    return StatusBadge(label: label, tone: StatusTone.danger, icon: icon);
  }

  Color _resolve(Brightness brightness) {
    if (color != null) return color!;
    switch (tone!) {
      case StatusTone.success:
        return AppColors.success(brightness);
      case StatusTone.warning:
        return AppColors.warningFor(brightness);
      case StatusTone.info:
        return AppColors.infoFor(brightness);
      case StatusTone.danger:
        return AppColors.dangerFor(brightness);
      case StatusTone.neutral:
        return AppColors.neutralFor(brightness);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = _resolve(theme.brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: resolved.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: resolved.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: resolved),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: resolved,
            ),
          ),
        ],
      ),
    );
  }
}
