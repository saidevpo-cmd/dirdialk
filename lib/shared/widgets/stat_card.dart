import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_style.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    this.title,
    this.label,
    required this.value,
    this.trend,
    required this.icon,
    this.iconColor,
  }) : assert(title != null || label != null, 'Either title or label must be provided');

  final String? title;
  final String? label;
  final String value;
  final String? trend;
  final IconData icon;
  final Color? iconColor;

  String get displayTitle => title ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    final config = context.styleConfig;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final success = AppColors.success(theme.brightness);

    return AppCard(
      expand: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: (iconColor ?? scheme.primary).withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(config.cardRadius * 0.5),
                        ),
                        child: Icon(
                          icon,
                          size: 18,
                          color: iconColor ?? scheme.primary,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (trend != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      trend!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: success,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
