enum OrderStatus { pending, paid, shipped, delivered, cancelled }

class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.productSku,
    required this.unitPrice,
    required this.qty,
    required this.subtotal,
  });

  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final String? productSku;
  final double unitPrice;
  final int qty;
  final double subtotal;

  int get quantity => qty;
  double get total => subtotal;
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.shippingAddress,
    this.shippingCity,
    this.status = OrderStatus.pending,
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.shippingFee = 0,
    this.total = 0,
    this.paidAt,
    this.deliveredAt,
    this.cancelledAt,
    this.notes,
    this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderNumber;
  final String? customerId;
  final String? customerName;

  /// Contact phone captured at checkout (guest checkout does not require a
  /// customer account, but does require reachable contact information).
  final String? customerPhone;
  final String? customerEmail;
  final String? shippingAddress;
  final String? shippingCity;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double shippingFee;
  final double total;
  final DateTime? paidAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? notes;

  /// One key per checkout attempt; reused on retry so a lost response can be
  /// replayed without creating a duplicate order (enforced by a unique index
  /// in Postgres).
  final String? idempotencyKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? shippingAddress,
    String? shippingCity,
    OrderStatus? status,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? shippingFee,
    double? total,
    DateTime? paidAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? notes,
    String? idempotencyKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Order(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        customerEmail: customerEmail ?? this.customerEmail,
        shippingAddress: shippingAddress ?? this.shippingAddress,
        shippingCity: shippingCity ?? this.shippingCity,
        status: status ?? this.status,
        items: items ?? this.items,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        tax: tax ?? this.tax,
        shippingFee: shippingFee ?? this.shippingFee,
        total: total ?? this.total,
        paidAt: paidAt ?? this.paidAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        notes: notes ?? this.notes,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
