import 'order.dart';

/// One line of a tracked order (a snapshot taken at order time).
class OrderTrackingItem {
  const OrderTrackingItem({
    required this.name,
    required this.qty,
    required this.subtotal,
  });

  final String name;
  final int qty;
  final double subtotal;
}

/// A customer-facing view of a single order, returned by the public
/// `track_order` RPC.
///
/// This is intentionally a *curated subset* of [Order]: the backend never
/// exposes the private row (shipping address, email, customer id, ...). The UI
/// builds a status timeline from the timestamps below.
class OrderTracking {
  const OrderTracking({
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.total,
    this.currencySymbol = '',
    this.items = const [],
  });

  final String orderNumber;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final double total;
  final String currencySymbol;
  final List<OrderTrackingItem> items;
}
