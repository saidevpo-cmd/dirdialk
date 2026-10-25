import '../../domain/models/order.dart';

/// Semantic keys for customer fields that may be missing on a stored order.
///
/// The renderer maps each key to a localized label; a field whose value is
/// null/blank is **omitted** from [OrderDocument.customerFields] instead of
/// being filled with a placeholder, so a reprint only ever shows data the
/// order actually captured.
enum OrderDocumentFieldKey { name, phone, email, address, city }

/// Semantic keys for the totals block. `discount`, `tax` and `shipping` only
/// appear when the stored value is greater than zero (mirroring the on-screen
/// order details); `subtotal` and `total` are always present because every
/// order records them.
enum OrderDocumentTotalKey { subtotal, discount, tax, shipping, total }

/// One customer field that actually exists on the order.
class OrderDocumentField {
  const OrderDocumentField(this.key, this.value);

  final OrderDocumentFieldKey key;
  final String value;
}

/// One totals line that should be rendered.
class OrderDocumentTotal {
  const OrderDocumentTotal(this.key, this.amount);

  final OrderDocumentTotalKey key;
  final double amount;

  bool get isGrandTotal => key == OrderDocumentTotalKey.total;
}

/// A line item exactly as it was saved with the order.
///
/// `unitPrice`, `qty` and `subtotal` are the historical snapshots stored on
/// `order_items` — the current catalog price is never consulted, so a reprint
/// years later still shows what the customer actually paid.
class OrderDocumentItem {
  const OrderDocumentItem({
    required this.name,
    this.sku,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  final String name;
  final String? sku;
  final int qty;
  final double unitPrice;
  final double subtotal;
}

/// Locale-agnostic presentation model of a stored order for printing.
///
/// [OrderDocument.fromOrder] is a pure transformation: it never invents or
/// defaults order data. Missing customer fields, absent lifecycle timestamps
/// and zero discount/tax/shipping simply produce no rows; the renderer shows
/// only what is here.
class OrderDocument {
  const OrderDocument({
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.customerFields,
    required this.items,
    required this.totals,
    this.notes,
    required this.currencySymbol,
  });

  /// Builds the print model from the order as stored (original snapshot).
  ///
  /// [currencySymbol] comes from app settings, not from the order row — it is
  /// presentation only and never changes an amount.
  factory OrderDocument.fromOrder(
    Order order, {
    required String currencySymbol,
  }) {
    return OrderDocument(
      orderNumber: order.orderNumber,
      status: order.status,
      createdAt: formatDateTime(order.createdAt),
      paidAt: order.paidAt == null ? null : formatDateTime(order.paidAt!),
      deliveredAt: order.deliveredAt == null
          ? null
          : formatDateTime(order.deliveredAt!),
      cancelledAt: order.cancelledAt == null
          ? null
          : formatDateTime(order.cancelledAt!),
      customerFields: _customerFields(order),
      items: [
        for (final item in order.items)
          OrderDocumentItem(
            name: item.productName,
            sku: _present(item.productSku),
            qty: item.qty,
            unitPrice: item.unitPrice,
            subtotal: item.subtotal,
          ),
      ],
      totals: _totals(order),
      notes: _present(order.notes),
      currencySymbol: currencySymbol,
    );
  }

  final String orderNumber;
  final OrderStatus status;
  final String createdAt;
  final String? paidAt;
  final String? deliveredAt;
  final String? cancelledAt;
  final List<OrderDocumentField> customerFields;
  final List<OrderDocumentItem> items;
  final List<OrderDocumentTotal> totals;
  final String? notes;
  final String currencySymbol;

  bool get hasCustomerInfo => customerFields.isNotEmpty;

  /// `true` when at least one field exists for [key] — used by tests to prove
  /// absent data stays absent.
  bool hasField(OrderDocumentFieldKey key) =>
      customerFields.any((f) => f.key == key);

  /// Trims and returns [value], or `null` when it carries no information.
  static String? _present(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<OrderDocumentField> _customerFields(Order order) {
    final fields = <OrderDocumentField>[];
    void add(OrderDocumentFieldKey key, String? value) {
      final v = _present(value);
      if (v != null) fields.add(OrderDocumentField(key, v));
    }

    add(OrderDocumentFieldKey.name, order.customerName);
    add(OrderDocumentFieldKey.phone, order.customerPhone);
    add(OrderDocumentFieldKey.email, order.customerEmail);
    add(OrderDocumentFieldKey.address, order.shippingAddress);
    add(OrderDocumentFieldKey.city, order.shippingCity);
    return fields;
  }

  static List<OrderDocumentTotal> _totals(Order order) {
    final lines = <OrderDocumentTotal>[
      OrderDocumentTotal(OrderDocumentTotalKey.subtotal, order.subtotal),
      if (order.discount > 0)
        OrderDocumentTotal(OrderDocumentTotalKey.discount, order.discount),
      if (order.tax > 0)
        OrderDocumentTotal(OrderDocumentTotalKey.tax, order.tax),
      if (order.shippingFee > 0)
        OrderDocumentTotal(OrderDocumentTotalKey.shipping, order.shippingFee),
      OrderDocumentTotal(OrderDocumentTotalKey.total, order.total),
    ];
    return lines;
  }

  /// Receipt-style timestamp: `yyyy-MM-dd HH:mm` in the viewer's local time.
  ///
  /// Numeric on purpose — it renders identically in Arabic and Latin locales
  /// without needing locale date-symbol data inside the PDF layer.
  static String formatDateTime(DateTime value) {
    final d = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }

  /// Amount formatted for the document: symbol + 2 decimals, exactly as
  /// stored (no rounding beyond display precision).
  static String money(double amount, String symbol) =>
      '$symbol${amount.toStringAsFixed(2)}';
}
