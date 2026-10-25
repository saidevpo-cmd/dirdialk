import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/order.dart';
import '../../domain/models/site_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
import '../../shared/utils/order_number.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/pagination_bar.dart';
import '../../shared/widgets/responsive_data_table.dart';
import '../../shared/widgets/search_and_filter_bar.dart';
import '../../shared/widgets/status_badge.dart';
import '../orders/order_document.dart';
import '../orders/order_printout.dart';

/// Read-only archive of past orders.
///
/// While [OrdersPage] drives the active workflow (status transitions,
/// cancellations), this screen is optimised for *finding* any past order —
/// free-text search, a status filter and an order-date range — and for
/// re-printing its original receipt through [OrderPrintout]. Rows are
/// projections of stored order data, so a reprint always shows what the
/// customer actually paid, never current catalog prices.
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({
    super.key,
    this.printActions = const PrintingOrderPrintActions(),
  });

  /// Seam over the platform print/download pipeline. Production uses
  /// [PrintingOrderPrintActions]; widget tests can inject a fake.
  final OrderPrintActions printActions;

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.orders;
  final _settingsRepo = AppRepositories.instance.siteSettings;

  bool _isLoading = true;
  String? _errorMessage;
  List<Order> _orders = [];
  OrderStatus? _selectedStatus;
  DateTimeRange? _dateRange;

  /// Display currency for totals on screen and in the printed PDF. Read once
  /// from site settings; presentation only, never mutates stored amounts.
  String _currencySymbol = r'$';
  SiteSettings _siteSettings = const SiteSettings();

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

    final currencyRes = await _settingsRepo.currencySymbol();
    final settingsRes = await _settingsRepo.load();
    if (!mounted) return;
    setState(() {
      if (currencyRes is Success<String>) _currencySymbol = currencyRes.data;
      if (settingsRes is Success<SiteSettings>) {
        _siteSettings = settingsRes.data;
      }
    });

    await _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final res = await _repo.list(
      search: _searchController.text,
      status: _selectedStatus,
      createdFrom: _dateRange?.start,
      createdTo: _dateRange == null
          ? null
          : DateTime(
              _dateRange!.end.year,
              _dateRange!.end.month,
              _dateRange!.end.day,
              23,
              59,
              59,
              999,
            ),
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

  Future<void> _pickDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _dateRange,
      helpText: l10n.dateRangeFilter,
      saveText: l10n.actionConfirm,
      cancelText: l10n.actionCancel,
    );
    if (picked == null || !mounted) return;
    setState(() => _dateRange = picked);
    _applyFilters();
  }

  void _clearDateRange() {
    setState(() => _dateRange = null);
    _applyFilters();
  }

  String _money(double amount) => OrderDocument.money(amount, _currencySymbol);

  /// `yyyy-MM-dd` in the viewer's local time — same numeric style as
  /// [OrderDocument.formatDateTime], for compact range labels.
  String _formatDate(DateTime value) {
    final d = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
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
            label: l10n.statusPending, icon: Icons.schedule);
      case OrderStatus.paid:
        return StatusBadge.info(label: l10n.statusPaid, icon: Icons.payment);
      case OrderStatus.shipped:
        return StatusBadge.info(
            label: l10n.statusShipped, icon: Icons.local_shipping_outlined);
      case OrderStatus.delivered:
        return StatusBadge.success(
            label: l10n.statusDelivered, icon: Icons.check_circle_outline);
      case OrderStatus.cancelled:
        return StatusBadge.danger(
            label: l10n.statusCancelled, icon: Icons.cancel_outlined);
    }
  }

  /// Renders the receipt PDF from the stored order and hands it to
  /// [OrderPrintActions]. All async work finishes before any state change, and
  /// the failure path only surfaces the localized message — a broken print
  /// pipeline can never crash the page.
  Future<void> _printOrder(Order order, {required bool download}) async {
    final l10n = AppLocalizations.of(context)!;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    try {
      final pdf = await OrderPrintout.buildPdf(
        order: order,
        l10n: l10n,
        settings: _siteSettings,
        currencySymbol: _currencySymbol,
        rtl: rtl,
      );
      final filename = OrderPrintout.filenameFor(order);
      if (download) {
        await widget.printActions.download(pdf, filename);
      } else {
        await widget.printActions.print(pdf, filename);
      }
    } catch (_) {
      if (!mounted) return;
      AppFeedback.failure(context, l10n.printDocumentFailed);
    }
  }

  void _showOrderDetails(Order order) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                      l10n.orderLabel(OrderNumber.format(order.orderNumber)))),
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
                  // Order meta
                  AppCard(
                    expand: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.orderDateLabel}: '
                          '${OrderDocument.formatDateTime(order.createdAt)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (order.paidAt != null)
                          Text(
                            '${l10n.statusPaid}: '
                            '${OrderDocument.formatDateTime(order.paidAt!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        if (order.deliveredAt != null)
                          Text(
                            '${l10n.statusDelivered}: '
                            '${OrderDocument.formatDateTime(order.deliveredAt!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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
                            '${l10n.nameLabel}: ${order.customerName ?? l10n.guestLabel}'),
                        if (order.customerEmail != null)
                          Text(
                              '${l10n.emailLabel}: ${order.customerEmail}'),
                        if (order.shippingAddress != null)
                          Text(
                              '${l10n.addressLabel}: ${order.shippingAddress}, ${order.shippingCity ?? ''}'),
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
                                      fontWeight: FontWeight.w600),
                                ),
                                if (item.productSku != null)
                                  Text(
                                    '${l10n.colSku}: ${item.productSku}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                              '${item.quantity} x ${_money(item.unitPrice)}'),
                          const SizedBox(width: 16),
                          Text(
                            _money(item.total),
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                  if (order.discount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.discountLabel),
                        Text(_money(order.discount)),
                      ],
                    ),
                  ],
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
                  if (order.notes != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.notesLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(order.notes!),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              key: const Key('history-download'),
              onPressed: () => _printOrder(order, download: true),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(l10n.downloadPdf),
            ),
            FilledButton.icon(
              key: const Key('history-print'),
              onPressed: () => _printOrder(order, download: false),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: Text(l10n.printOrder),
            ),
          ],
        );
      },
    );
  }

  Widget _dateRangeFilterChip(AppLocalizations l10n) {
    final range = _dateRange;
    final label = range == null
        ? l10n.dateRangeFilter
        : '${_formatDate(range.start)} – ${_formatDate(range.end)}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          key: const Key('history-date-filter'),
          onPressed: _pickDateRange,
          icon: const Icon(Icons.date_range_outlined, size: 18),
          label: Text(label),
        ),
        if (range != null)
          IconButton(
            key: const Key('history-date-clear'),
            icon: const Icon(Icons.clear, size: 18),
            tooltip: l10n.clearDateFilter,
            onPressed: _clearDateRange,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadData,
      );
    }

    return SingleChildScrollView(
      key: const Key('order-history-page'),
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
                Text(l10n.navOrderHistory,
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  l10n.orderHistorySubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search, Status and Date-Range Filters
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.searchHistoryHint,
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
                _dateRangeFilterChip(l10n),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Orders Table
            ResponsiveDataTable<Order>(
              items: _orders,
              isLoading: _isLoading,
              emptyTitle: l10n.historyEmptyTitle,
              emptyMessage: l10n.historyEmptyMessage,
              onItemTap: (order) => _showOrderDetails(order),
              columns: [
                TableColumnDef(label: l10n.colOrder, flex: 2),
                TableColumnDef(label: l10n.colDate, flex: 2),
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
                  Text(OrderDocument.formatDateTime(order.createdAt)),
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
                      IconButton(
                        key: Key('history-row-print-${order.orderNumber}'),
                        icon: const Icon(Icons.print_outlined, size: 18),
                        tooltip: l10n.printOrder,
                        onPressed: () => _printOrder(order, download: false),
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
                        Text(
                          '${l10n.colDate}: '
                          '${OrderDocument.formatDateTime(order.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
