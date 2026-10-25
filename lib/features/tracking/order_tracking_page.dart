import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_tracking.dart';
import '../../domain/models/tracking_stage.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/phone_number.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/order_tracking_summary.dart';
import '../../shared/widgets/order_tracking_timeline.dart';
import '../../shared/widgets/status_badge.dart';

/// Customer-facing order tracking.
///
/// Deliberately standalone (its own [Scaffold]) so it can be both pushed from
/// the storefront and reached directly at the public `/track` route. It calls
/// the `track_order` RPC with the order number and the checkout phone — the
/// phone is the proof of ownership, and the backend returns the same "not
/// found" for a wrong phone as for an unknown order.
class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  static const Key orderNumberFieldKey = Key('track-order-number');
  static const Key phoneFieldKey = Key('track-order-phone');
  static const Key submitButtonKey = Key('track-order-submit');

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final _orderNumberCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = false;
  bool _searched = false;
  String? _errorText;
  OrderTracking? _result;

  @override
  void dispose() {
    _orderNumberCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final number = _orderNumberCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (number.isEmpty || phone.isEmpty) {
      setState(() {
        _errorText = l10n.trackOrderRequired;
        _searched = false;
        _result = null;
      });
      return;
    }
    if (!PhoneNumber.isValid(phone)) {
      setState(() {
        _errorText = l10n.checkoutPhoneInvalid;
        _searched = false;
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
      _searched = false;
      _result = null;
    });

    final response = await AppRepositories.instance.orders.track(
      orderNumber: number,
      phone: PhoneNumber.normalize(phone),
    );
    if (!mounted) return;

    setState(() {
      _loading = false;
      _searched = true;
      switch (response) {
        case Success(data: final data):
          _result = data;
        case Failure():
          // The RPC raises English-only messages (validation / throttle);
          // showing a single localized failure keeps the page consistent.
          _errorText = l10n.trackOrderFailed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackOrderTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.trackOrderTitle,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.trackOrderSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    key: OrderTrackingPage.orderNumberFieldKey,
                    controller: _orderNumberCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.orderNumberLabel,
                      prefixIcon: const Icon(Icons.receipt_long_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    key: OrderTrackingPage.phoneFieldKey,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loading ? null : _submit(),
                    decoration: InputDecoration(
                      labelText: l10n.customerPhoneLabel,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _errorText!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    key: OrderTrackingPage.submitButtonKey,
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(l10n.trackOrderAction),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_searched && _result != null) _resultCard(context),
                  if (_searched && _result == null && _errorText == null)
                    AppCard(
                      child: Row(
                        children: [
                          Icon(Icons.search_off,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(child: Text(l10n.trackOrderNotFound)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final result = _result!;
    final symbol =
        result.currencySymbol.isNotEmpty ? result.currencySymbol : r'$';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Everything the backend actually knows about the shipment,
              // followed by the six-stage timeline driven by the same
              // timestamps — no carrier data is ever invented.
              OrderTrackingSummary(
                orderNumber: result.orderNumber,
                statusBadge: _statusBadge(l10n, result.status),
                shipmentDate: shipmentDateForTracking(result),
              ),
              const Divider(height: AppSpacing.lg),
              OrderTrackingTimeline(
                currentStage: trackingStageForOrderTracking(result),
                timestamps: stageTimestampsForTracking(result),
                cancelled: result.cancelledAt != null,
              ),
            ],
          ),
        ),
        if (result.items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trackOrderItems,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final item in result.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${item.qty} × ${item.name}'),
                        ),
                        Text('$symbol${item.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                const Divider(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.totalAmountLabel,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '$symbol${result.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  StatusBadge _statusBadge(AppLocalizations l10n, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return StatusBadge.neutral(
            label: l10n.statusPending, icon: Icons.schedule);
      case OrderStatus.paid:
        return StatusBadge.info(label: l10n.statusPaid, icon: Icons.payment);
      case OrderStatus.shipped:
        return StatusBadge.warning(
            label: l10n.statusShipped, icon: Icons.local_shipping_outlined);
      case OrderStatus.delivered:
        return StatusBadge.success(
            label: l10n.statusDelivered, icon: Icons.check_circle_outline);
      case OrderStatus.cancelled:
        return StatusBadge.danger(
            label: l10n.statusCancelled, icon: Icons.cancel_outlined);
    }
  }
}
