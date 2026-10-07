import 'package:flutter/material.dart';

import '../../core/design_system/app_style.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.expand = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final config = context.styleConfig;
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(config.cardRadius);
    final shadows = config.cardShadowBlur > 0
        ? <BoxShadow>[
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: config.cardShadowBlur,
              offset: const Offset(0, 2),
            ),
          ]
        : const <BoxShadow>[];

    return Container(
      width: expand ? double.infinity : null,
      padding: padding ?? config.cardPadding,
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerLow,
        borderRadius: radius,
        border: config.cardBorderWidth > 0
            ? Border.all(
                color: scheme.outlineVariant,
                width: config.cardBorderWidth,
              )
            : null,
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
