import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_style.dart';
import '../../core/navigation/nav_section.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.onNavigate});

  final ValueChanged<NavSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final config = context.styleConfig;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = config.spacingScale;
        return SingleChildScrollView(
          key: const Key('dashboard-page'),
          padding: AppSpacing.pagePadding(width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.navDashboard, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                l10n.dashboardSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSpacing.lg * scale),
              _buildStats(width, l10n),
              SizedBox(height: AppSpacing.lg * scale),
              _buildBottom(width, l10n, theme, scale),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(double width, AppLocalizations l10n) {
    int columns;
    if (width >= 1000) {
      columns = 4;
    } else if (width >= 500) {
      columns = 2;
    } else {
      columns = 1;
    }

    final stats = [
      (
        title: l10n.statProducts,
        value: '128',
        trend: l10n.statProductsTrend,
        icon: Icons.inventory_2_outlined,
      ),
      (
        title: l10n.statOrders,
        value: '46',
        trend: l10n.statOrdersTrend,
        icon: Icons.receipt_long_outlined,
      ),
      (
        title: l10n.statCustomers,
        value: '89',
        trend: l10n.statCustomersTrend,
        icon: Icons.people_outline,
      ),
      (
        title: l10n.statResources,
        value: '15',
        trend: l10n.statResourcesTrend,
        icon: Icons.folder_copy_outlined,
      ),
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 168,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      children: [
        for (final stat in stats)
          StatCard(
            title: stat.title,
            value: stat.value,
            trend: stat.trend,
            icon: stat.icon,
          ),
      ],
    );
  }

  Widget _buildBottom(
    double width,
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    final activity = _buildActivity(l10n, theme, scale);
    final actions = _buildActions(l10n, theme, scale);

    if (width >= AppBreakpoints.wideContent) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: activity),
          SizedBox(width: AppSpacing.lg * scale),
          Expanded(flex: 2, child: actions),
        ],
      );
    }
    return Column(
      children: [
        activity,
        SizedBox(height: AppSpacing.lg * scale),
        actions,
      ],
    );
  }

  Widget _buildActivity(
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    final entries = [
      (
        icon: Icons.receipt_long_outlined,
        title: l10n.activityOrder('#1042'),
        time: l10n.timeToday,
      ),
      (
        icon: Icons.warning_amber_rounded,
        title: l10n.activityLowStock('Air Filter X20'),
        time: l10n.timeToday,
      ),
      (
        icon: Icons.person_add_alt_1_outlined,
        title: l10n.activityCustomer('Sara B.'),
        time: l10n.timeYesterday,
      ),
      (
        icon: Icons.folder_copy_outlined,
        title: l10n.activityResource('Atlas Supplies'),
        time: l10n.timeYesterday,
      ),
    ];

    return AppCard(
      expand: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recentActivity,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(NavSection.orders),
                child: Text(l10n.viewAll),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm * scale),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.sm * scale),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    entries[i].icon,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entries[i].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        entries[i].time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    final actions = [
      (
        label: l10n.actionAddProduct,
        icon: Icons.add_box_outlined,
        target: NavSection.products,
        primary: true,
      ),
      (
        label: l10n.actionNewOrder,
        icon: Icons.receipt_long_outlined,
        target: NavSection.orders,
        primary: false,
      ),
      (
        label: l10n.actionAddCustomer,
        icon: Icons.person_add_alt_1_outlined,
        target: NavSection.customers,
        primary: false,
      ),
      (
        label: l10n.actionAddResource,
        icon: Icons.folder_copy_outlined,
        target: NavSection.resources,
        primary: false,
      ),
    ];

    return AppCard(
      expand: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quickActions, style: theme.textTheme.titleMedium),
          SizedBox(height: AppSpacing.md * scale),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.sm * scale),
            SizedBox(
              width: double.infinity,
              child: actions[i].primary
                  ? FilledButton.icon(
                      onPressed: () => onNavigate(actions[i].target),
                      icon: Icon(actions[i].icon, size: 20),
                      label: Text(actions[i].label),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => onNavigate(actions[i].target),
                      icon: Icon(actions[i].icon, size: 20),
                      label: Text(actions[i].label),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
