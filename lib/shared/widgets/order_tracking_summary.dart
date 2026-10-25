import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/order_number.dart';

/// Key/value summary of everything the backend knows about a shipment.
///
/// Every field except the order number and the current status is optional and
/// maps to data a shipping provider *may* one day return: when nothing exists
/// the card says so (see [unavailableKey]) instead of showing placeholders
/// that look like real tracking data. Adding a provider later is a matter of
/// passing the values — no widget changes required.
class OrderTrackingSummary extends StatelessWidget {
  const OrderTrackingSummary({
    super.key,
    required this.orderNumber,
    this.statusBadge,
    this.trackingNumber,
    this.shippingCompany,
    this.shipmentDate,
    this.estimatedDelivery,
    this.currentLocation,
    this.latestUpdate,
    this.latestUpdateAt,
  });

  static const Key unavailableKey = Key('tracking-info-unavailable');

  /// Key for the formatted order number shown in the card.
  static const Key orderNumberKey = ValueKey('tracking-info-orderNumber');

  /// Key for the value of a single spec, e.g. `valueKey('trackingNumber')`.
  static Key valueKey(String name) => ValueKey('tracking-info-$name');

  /// Raw order number as stored; formatted for display with [OrderNumber].
  final String orderNumber;

  /// Optional status badge (from the app-wide `StatusBadge` factories).
  /// Callers that already show the status nearby — the admin order dialog in
  /// its title row — pass null so the badge is not repeated.
  final Widget? statusBadge;

  final String? trackingNumber;
  final String? shippingCompany;
  final DateTime? shipmentDate;
  final DateTime? estimatedDelivery;
  final String? currentLocation;
  final String? latestUpdate;
  final DateTime? latestUpdateAt;

  /// True when nothing beyond the order itself is known about the shipment.
  bool get _hasCarrierData =>
      trackingNumber != null ||
      shippingCompany != null ||
      currentLocation != null ||
      latestUpdate != null ||
      estimatedDelivery != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final specs = <_Spec>[
      _Spec(
        valueKey: orderNumberKey,
        label: l10n.orderNumberLabel,
        value: OrderNumber.format(orderNumber),
      ),
      _Spec(
        valueKey: valueKey('shipmentDate'),
        label: l10n.shipmentDateLabel,
        value: shipmentDate == null ? null : _formatDate(context, shipmentDate!),
      ),
      _Spec(
        valueKey: valueKey('trackingNumber'),
        label: l10n.trackingNumberLabel,
        value: trackingNumber,
      ),
      _Spec(
        valueKey: valueKey('shippingCompany'),
        label: l10n.shippingCompanyLabel,
        value: shippingCompany,
      ),
      _Spec(
        valueKey: valueKey('estimatedDelivery'),
        label: l10n.estimatedDeliveryLabel,
        value:
            estimatedDelivery == null ? null : _formatDate(context, estimatedDelivery!),
      ),
      _Spec(
        valueKey: valueKey('currentLocation'),
        label: l10n.currentLocationLabel,
        value: currentLocation,
      ),
      _Spec(
        valueKey: valueKey('latestUpdate'),
        label: l10n.latestUpdateLabel,
        value: latestUpdate == null
            ? null
            : latestUpdateAt == null
                ? latestUpdate
                : '${_formatDate(context, latestUpdateAt!)} — $latestUpdate',
      ),
    ].where((spec) => spec.value != null).toList(growable: false);

    // Cardless on purpose: call sites place this section inside their own
    // [AppCard] next to the timeline, so the whole tracking block reads as
    // one card instead of nested ones.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                l10n.trackingTitle,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ?statusBadge,
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            for (final spec in specs) _buildSpec(context, spec),
          ],
        ),
        if (!_hasCarrierData) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            key: unavailableKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.trackingUnavailable,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSpec(BuildContext context, _Spec spec) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            spec.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            spec.value!,
            key: spec.valueKey,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static String _formatDate(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final local = value.toLocal();
    final date = localizations.formatMediumDate(local);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '$date · $time';
  }
}

class _Spec {
  const _Spec({required this.valueKey, required this.label, this.value});

  final Key valueKey;
  final String label;
  final String? value;
}
