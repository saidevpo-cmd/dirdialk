import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_style.dart';
import '../../core/navigation/nav_section.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/order.dart';
import '../../domain/models/page_content.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/resource.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/stat_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onNavigate});

  final ValueChanged<NavSection> onNavigate;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repos = AppRepositories.instance;

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _productStats = {};
  Map<String, dynamic> _categoryStats = {};
  Map<String, dynamic> _orderStats = {};
  Map<String, dynamic> _customerStats = {};

  List<Order> _recentOrders = [];
  List<Product> _recentProducts = [];
  List<PageContent> _latestArticles = [];
  List<Resource> _directory = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await Future.wait<Object?>([
      _repos.products.stats(),
      _repos.categories.stats(),
      _repos.orders.stats(),
      _repos.customers.stats(),
      _repos.orders.list(limit: 5),
      _repos.products.list(limit: 5),
      _repos.pages.list(limit: 4),
      _repos.resources.list(limit: 4),
    ]);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = results.any((r) => r is Failure) ? 'Failed to load dashboard' : null;

      _productStats = _mapOf(results[0]) ?? {};
      _categoryStats = _mapOf(results[1]) ?? {};
      _orderStats = _mapOf(results[2]) ?? {};
      _customerStats = _mapOf(results[3]) ?? {};

      _recentOrders = _itemsOf<Order>(results[4]);
      _recentProducts = _itemsOf<Product>(results[5]);
      _latestArticles = _itemsOf<PageContent>(results[6]);
      _directory = _itemsOf<Resource>(results[7]);
    });
  }

  Map<String, dynamic>? _mapOf(Object? result) {
    if (result is Success<Map<String, dynamic>>) return result.data;
    return null;
  }

  List<T> _itemsOf<T>(Object? result) {
    if (result is! Success) return const [];
    final data = result.data;
    if (data is! PaginatedResult) return const [];
    return data.items.whereType<T>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final config = context.styleConfig;

    if (_error != null) {
      return ErrorStateView(message: _error!, onRetry: _load);
    }

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
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _buildStats(width, l10n),
                SizedBox(height: AppSpacing.lg * scale),
                _buildQuickActions(l10n, theme),
                SizedBox(height: AppSpacing.lg * scale),
                _buildPanels(width, l10n, theme, scale),
              ],
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
    } else if (width >= 520) {
      columns = 2;
    } else {
      columns = 1;
    }

    final stats = [
      (
        title: l10n.statProducts,
        value: _productStats['totalProducts']?.toString() ?? '0',
        icon: Icons.inventory_2_outlined,
        color: null,
      ),
      (
        title: l10n.dashboardTotalCategories,
        value: _categoryStats['totalCategories']?.toString() ?? '0',
        icon: Icons.category_outlined,
        color: null,
      ),
      (
        title: l10n.statOrders,
        value: _orderStats['totalOrders']?.toString() ?? '0',
        icon: Icons.receipt_long_outlined,
        color: null,
      ),
      (
        title: l10n.statCustomers,
        value: _customerStats['totalCustomers']?.toString() ?? '0',
        icon: Icons.people_outline,
        color: null,
      ),
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 150,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      children: [
        for (final stat in stats)
          StatCard(
            label: stat.title,
            value: stat.value,
            icon: stat.icon,
            iconColor: stat.color,
          ),
      ],
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n, ThemeData theme) {
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
        icon: Icons.add_business_outlined,
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
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final action in actions)
                if (action.primary)
                  FilledButton.icon(
                    onPressed: () => widget.onNavigate(action.target),
                    icon: Icon(action.icon, size: 20),
                    label: Text(action.label),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => widget.onNavigate(action.target),
                    icon: Icon(action.icon, size: 20),
                    label: Text(action.label),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanels(
    double width,
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    final panels = [
      _buildRecentOrders(l10n, theme),
      _buildRecentProducts(l10n, theme),
      _buildLatestArticles(l10n, theme),
      _buildDirectory(l10n, theme),
    ];

    Widget rowChild(int first, int second) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: panels[first]),
            SizedBox(width: AppSpacing.md * scale),
            Expanded(child: panels[second]),
          ],
        );

    if (width >= AppBreakpoints.wideContent) {
      return Column(
        children: [
          rowChild(0, 1),
          SizedBox(height: AppSpacing.md * scale),
          rowChild(2, 3),
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < panels.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.md * scale),
          panels[i],
        ],
      ],
    );
  }

  Widget _buildRecentOrders(AppLocalizations l10n, ThemeData theme) {
    return _panel(
      title: l10n.dashboardRecentOrders,
      theme: theme,
      actionLabel: l10n.viewAll,
      onAction: () => widget.onNavigate(NavSection.orders),
      child: _recentOrders.isEmpty
          ? _empty(theme, l10n.dashboardNoOrders, Icons.receipt_long_outlined)
          : Column(
              children: [
                for (final order in _recentOrders)
                  _row(
                    theme,
                    leading: Icons.receipt_long_outlined,
                    title: '${order.orderNumber} · ${order.customerName ?? 'Guest'}',
                    subtitle: '${order.items.length} items',
                    trailing: '\$${order.total.toStringAsFixed(2)}',
                  ),
              ],
            ),
    );
  }

  Widget _buildRecentProducts(AppLocalizations l10n, ThemeData theme) {
    return _panel(
      title: l10n.dashboardRecentProducts,
      theme: theme,
      onOpen: () => widget.onNavigate(NavSection.products),
      child: _recentProducts.isEmpty
          ? _empty(theme, l10n.dashboardNoProducts, Icons.inventory_2_outlined)
          : Column(
              children: [
                for (final product in _recentProducts)
                  _row(
                    theme,
                    leading: Icons.inventory_2_outlined,
                    title: product.name,
                    subtitle: product.categoryName ?? '—',
                    trailing: '\$${product.price.toStringAsFixed(2)}',
                  ),
              ],
            ),
    );
  }

  Widget _buildLatestArticles(AppLocalizations l10n, ThemeData theme) {
    return _panel(
      title: l10n.dashboardLatestArticles,
      theme: theme,
      onOpen: () => widget.onNavigate(NavSection.pages),
      child: _latestArticles.isEmpty
          ? _empty(theme, l10n.dashboardNoArticles, Icons.description_outlined)
          : Column(
              children: [
                for (final article in _latestArticles)
                  _row(
                    theme,
                    leading: Icons.description_outlined,
                    title: article.title,
                    subtitle: article.status.name,
                    trailing: null,
                  ),
              ],
            ),
    );
  }

  Widget _buildDirectory(AppLocalizations l10n, ThemeData theme) {
    return _panel(
      title: l10n.dashboardRecentDirectory,
      theme: theme,
      onOpen: () => widget.onNavigate(NavSection.resources),
      child: _directory.isEmpty
          ? _empty(theme, l10n.dashboardNoDirectory, Icons.folder_copy_outlined)
          : Column(
              children: [
                for (final resource in _directory)
                  _row(
                    theme,
                    leading: Icons.folder_copy_outlined,
                    title: resource.name,
                    subtitle: resource.category ?? resource.type.name,
                    trailing: resource.isPublished ? l10n.statusPublished : null,
                  ),
              ],
            ),
    );
  }

  Widget _panel({
    required String title,
    required ThemeData theme,
    required Widget child,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onOpen,
  }) {
    return AppCard(
      expand: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionLabel))
              else if (onOpen != null)
                IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  onPressed: onOpen,
                  tooltip: 'Open',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _row(
    ThemeData theme, {
    required IconData leading,
    required String title,
    required String subtitle,
    String? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              leading,
              size: 17,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty(ThemeData theme, String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
