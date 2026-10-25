import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/order.dart';
import '../../domain/models/tracking_stage.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
import '../../shared/utils/order_number.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/order_tracking_summary.dart';
import '../../shared/widgets/order_tracking_timeline.dart';
import '../../shared/widgets/pagination_bar.dart';
import '../../shared/widgets/responsive_data_table.dart';
import '../../shared/widgets/search_and_filter_bar.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_badge.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.orders;

  bool _isLoading = true;
  String? _errorMessage;
  String _currencySymbol = r'$';
  List<Order> _orders = [];
  Map<String, dynamic> _stats = {};
  OrderStatus? _selectedStatus;

  static const int _pageSize = 10;
  int _page = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final statsRes = await _repo.stats();
    if (statsRes is Success<Map<String, dynamic>>) {
      _stats = statsRes.data;
    }

    final currencyRes = await AppRepositories.instance.siteSettings
        .currencySymbol();
    if (currencyRes is Success<String> && currencyRes.data.trim().isNotEmpty) {
      _currencySymbol = currencyRes.data.trim();
    }

    await _fetchOrders();
  }

  String _money(double value) => '$_currencySymbol${value.toStringAsFixed(2)}';

  Future<void> _fetchOrders() async {
    final res = await _repo.list(
      search: _searchController.text,
      status: _selectedStatus,
      page: _page,
      limit: _pageSize,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      switch (res) {
        case Success(data: final page):
          _orders = page.items;
          _total = page.total;
        case Failure(:final error):
          _errorMessage = error.message;
      }
    });
  }

  /// Applies a filter change and returns to the first page so the visible
  /// rows always match the reported total.
  void _applyFilters() {
    _page = 1;
    _fetchOrders();
  }

  void _goToPage(int page) {
    _page = page;
    _fetchOrders();
  }

  String _orderStatusLabel(AppLocalizations l10n, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return l10n.statusPending;
      case OrderStatus.paid:
        return l10n.statusPaid;
      case OrderStatus.shipped:
        return l10n.statusShipped;
      case OrderStatus.delivered:
        return l10n.statusDelivered;
      case OrderStatus.cancelled:
        return l10n.statusCancelled;
    }
  }

  Widget _buildOrderStatusBadge(AppLocalizations l10n, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return StatusBadge.warning(
          label: l10n.statusPending,
          icon: Icons.schedule,
        );
      case OrderStatus.paid:
        return StatusBadge.info(label: l10n.statusPaid, icon: Icons.payment);
      case OrderStatus.shipped:
        return StatusBadge.info(
          label: l10n.statusShipped,
          icon: Icons.local_shipping_outlined,
        );
      case OrderStatus.delivered:
        return StatusBadge.success(
          label: l10n.statusDelivered,
          icon: Icons.check_circle_outline,
        );
      case OrderStatus.cancelled:
        return StatusBadge.danger(
          label: l10n.statusCancelled,
          icon: Icons.cancel_outlined,
        );
    }
  }

  Future<void> _updateStatus(
    BuildContext dialogCtx,
    Order order,
    OrderStatus next,
  ) async {
    final res = await _repo.updateStatus(order.id, next);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (res is Success<Order>) {
      if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
      AppFeedback.success(context, l10n.orderStatusUpdated);
      _loadData();
    } else {
      AppFeedback.error(context, (res as Failure).error);
    }
  }

  Future<void> _confirmCancelOrder(BuildContext dialogCtx, Order order) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: dialogCtx,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelOrderTitle),
        content: Text(l10n.cancelOrderBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionClose),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.cancelOrder),
          ),
        ],
      ),
    );
    if (confirmed == true && dialogCtx.mounted) {
      await _updateStatus(dialogCtx, order, OrderStatus.cancelled);
    }
  }

  void _showOrderDetails(Order order) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return StatefulBuilder(
          builder: (context, setDetailState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.orderLabel(OrderNumber.format(order.orderNumber)),
                    ),
                  ),
                  _buildOrderStatusBadge(l10n, order.status),
                ],
              ),
              content: SizedBox(
                width: dialogContentWidth(context, 600),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Shipment tracking — one card holding everything the
                      // backend knows: timeline states come only from the
                      // timestamps that exist on the row, and the summary
                      // says so when nothing else is known. The status badge
                      // stays in the dialog title above.
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OrderTrackingSummary(
                              orderNumber: order.orderNumber,
                              shipmentDate: shipmentDateFor(order),
                            ),
                            const Divider(height: AppSpacing.lg),
                            OrderTrackingTimeline(
                              currentStage: trackingStageForOrder(order),
                              timestamps: stageTimestampsForOrder(order),
                              cancelled: order.cancelledAt != null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer Summary
                      AppCard(
                        expand: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.customerInformation,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${l10n.nameLabel}: ${order.customerName ?? l10n.guestLabel}',
                            ),
                            if (order.customerEmail != null)
                              Text(
                                '${l10n.emailLabel}: ${order.customerEmail}',
                              ),
                            if (order.shippingAddress != null)
                              Text(
                                '${l10n.addressLabel}: ${order.shippingAddress}, ${order.shippingCity ?? ''}',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Order Items
                      Text(
                        '${l10n.colItems} (${order.items.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.productSku != null)
                                      Text(
                                        '${l10n.colSku}: ${item.productSku}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '${item.quantity} x ${_money(item.unitPrice)}',
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _money(item.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 24),

                      // Totals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.subtotalLabel),
                          Text(_money(order.subtotal)),
                        ],
                      ),
                      if (order.tax > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.taxLabel),
                            Text(_money(order.tax)),
                          ],
                        ),
                      ],
                      if (order.shippingFee > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.shippingLabel),
                            Text(_money(order.shippingFee)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.totalAmountLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _money(order.total),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Status Progression Actions
                      Text(
                        l10n.updateStatusTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (order.status == OrderStatus.pending)
                            FilledButton.tonalIcon(
                              onPressed: () => _updateStatus(
                                dialogCtx,
                                order,
                                OrderStatus.paid,
                              ),
                              icon: const Icon(Icons.payment, size: 16),
                              label: Text(l10n.markPaid),
                            ),
                          if (order.status == OrderStatus.paid)
                            FilledButton.tonalIcon(
                              onPressed: () => _updateStatus(
                                dialogCtx,
                                order,
                                OrderStatus.shipped,
                              ),
                              icon: const Icon(
                                Icons.local_shipping_outlined,
                                size: 16,
                              ),
                              label: Text(l10n.markShipped),
                            ),
                          if (order.status == OrderStatus.shipped)
                            FilledButton.icon(
                              onPressed: () => _updateStatus(
                                dialogCtx,
                                order,
                                OrderStatus.delivered,
                              ),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                              ),
                              label: Text(l10n.markDelivered),
                            ),
                          if (order.status != OrderStatus.cancelled &&
                              order.status != OrderStatus.delivered)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                              ),
                              onPressed: () =>
                                  _confirmCancelOrder(dialogCtx, order),
                              icon: const Icon(Icons.cancel_outlined, size: 16),
                              label: Text(l10n.cancelOrder),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(l10n.actionClose),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    if (_errorMessage != null) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadData);
    }

    final totalOrders = _stats['totalOrders']?.toString() ?? '—';
    final totalSalesValue = _stats['totalSales'];
    final totalSales = totalSalesValue is num
        ? _money(totalSalesValue.toDouble())
        : '—';
    final pendingOrders = _stats['pendingOrders']?.toString() ?? '—';
    final deliveredOrders = _stats['deliveredOrders']?.toString() ?? '—';

    return SingleChildScrollView(
      key: const Key('orders-page'),
      padding: AppSpacing.pagePadding(width),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.navOrders, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  l10n.ordersSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = AppBreakpoints.isMobile(constraints.maxWidth);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isCompact ? 2 : 4,
                    mainAxisExtent: 130,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  children: [
                    StatCard(
                      label: l10n.statOrders,
                      value: totalOrders,
                      icon: Icons.shopping_bag_outlined,
                    ),
                    StatCard(
                      label: l10n.ordersRevenueTitle,
                      value: totalSales,
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: l10n.ordersPendingTitle,
                      value: pendingOrders,
                      icon: Icons.hourglass_empty,
                      iconColor: Colors.amber,
                    ),
                    StatCard(
                      label: l10n.statusDelivered,
                      value: deliveredOrders,
                      icon: Icons.local_shipping_outlined,
                      iconColor: Colors.blue,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search and Status Filter
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.searchOrdersHint,
              onSearchChanged: (_) => _applyFilters(),
              filterWidgets: [
                DropdownButton<OrderStatus?>(
                  value: _selectedStatus,
                  hint: Text(l10n.allStatuses),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.allStatuses),
                    ),
                    ...OrderStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_orderStatusLabel(l10n, s)),
                      ),
                    ),
                  ],
                  onChanged: (status) {
                    setState(() => _selectedStatus = status);
                    _applyFilters();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Orders Table
            ResponsiveDataTable<Order>(
              items: _orders,
              isLoading: _isLoading,
              emptyTitle: l10n.ordersEmptyTitle,
              emptyMessage: l10n.ordersEmptyMessage,
              onItemTap: (order) => _showOrderDetails(order),
              columns: [
                TableColumnDef(label: l10n.colOrder, flex: 2),
                TableColumnDef(label: l10n.colCustomer, flex: 3),
                TableColumnDef(label: l10n.colItems, flex: 2),
                TableColumnDef(label: l10n.colTotal, flex: 2),
                TableColumnDef(label: l10n.colStatus, flex: 2),
                TableColumnDef(
                  label: l10n.colDetails,
                  flex: 2,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, order, index) {
                return [
                  Text(
                    OrderNumber.format(order.orderNumber),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.customerName ?? l10n.guestLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (order.customerEmail != null)
                        Text(
                          order.customerEmail!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  Text(l10n.itemCount(order.items.length)),
                  Text(
                    _money(order.total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildOrderStatusBadge(l10n, order.status),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showOrderDetails(order),
                        child: Text(l10n.actionView),
                      ),
                    ],
                  ),
                ];
              },
              mobileCardBuilder: (context, order, index) {
                return InkWell(
                  onTap: () => _showOrderDetails(order),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              OrderNumber.format(order.orderNumber),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildOrderStatusBadge(l10n, order.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${l10n.colCustomer}: ${order.customerName ?? l10n.guestLabel}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.itemCount(order.items.length)),
                            Text(
                              _money(order.total),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            PaginationBar(
              page: _page,
              pageSize: _pageSize,
              total: _total,
              onPageChanged: _goToPage,
            ),
          ],
        ),
      ),
    );
  }
}
