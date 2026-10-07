import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_style.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_card.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final config = context.styleConfig;
    final width = MediaQuery.sizeOf(context).width;
    final scale = config.spacingScale;

    return SingleChildScrollView(
      key: const Key('products-page'),
      padding: AppSpacing.pagePadding(width),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.navProducts, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        l10n.pagePhase('2'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(l10n.actionAddProduct),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg * scale),
            AppCard(
              expand: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.navProducts, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    l10n.actionComingSoon,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
