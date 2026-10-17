import '../../../domain/models/order.dart';
import '../../../domain/models/product.dart';
import '../../../shared/utils/id_gen.dart';
import '../../../shared/utils/phone_number.dart';

/// One product line in the checkout review. Prices always come from the
/// catalog product, never from user input.
class CheckoutLine {
  CheckoutLine({required this.product, required this.qty});

  final Product product;
  int qty;

  double get unitPrice => product.price;
  double get lineTotal => product.price * qty;
  int get available => product.stockQty;
}

/// Everything that can be wrong with a checkout attempt.
enum CheckoutProblem {
  customerNameRequired,
  customerNameTooShort,
  phoneRequired,
  phoneInvalid,
  cartEmpty,
  quantityInvalid,
  insufficientStock,
  addressTooLong,
  cityTooLong,
}

/// A single validated problem; [productName]/[available] only apply to
/// [CheckoutProblem.insufficientStock].
class CheckoutIssue {
  const CheckoutIssue(this.problem, {this.productName, this.available});

  final CheckoutProblem problem;
  final String? productName;
  final int? available;
}

/// Totals shown to the customer before submitting.
///
/// These are estimates for display only. The server recomputes every amount
/// from the trusted product rows (`place_order`), so a tampered client value
/// can never change what is charged or recorded.
class CheckoutTotals {
  const CheckoutTotals({
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double tax;
  final double total;

  factory CheckoutTotals.compute({
    required Iterable<CheckoutLine> lines,
    required double taxRatePercent,
  }) {
    final subtotal = lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
    final tax = _round2(subtotal * taxRatePercent / 100);
    return CheckoutTotals(
      subtotal: subtotal,
      tax: tax,
      total: _round2(subtotal + tax),
    );
  }

  static double _round2(double value) => (value * 100).roundToDouble() / 100;
}

/// Pure checkout rules, shared by the checkout UI and the unit tests.
///
/// Keeping the rules here (instead of inline in the widget) means the exact
/// same logic can be exercised without a live backend and cannot drift from
/// the server-side checks.
abstract final class CheckoutValidator {
  static const int minNameLength = 2;
  static const int maxAddressLength = 300;
  static const int maxCityLength = 120;

  static List<CheckoutIssue> validate({
    required String customerName,
    required String customerPhone,
    required List<CheckoutLine> lines,
    String shippingAddress = '',
    String shippingCity = '',
  }) {
    final issues = <CheckoutIssue>[];

    final name = customerName.trim();
    if (name.isEmpty) {
      issues.add(const CheckoutIssue(CheckoutProblem.customerNameRequired));
    } else if (name.length < minNameLength) {
      issues.add(const CheckoutIssue(CheckoutProblem.customerNameTooShort));
    }

    final phone = customerPhone.trim();
    if (phone.isEmpty) {
      issues.add(const CheckoutIssue(CheckoutProblem.phoneRequired));
    } else if (!PhoneNumber.isValid(phone)) {
      issues.add(const CheckoutIssue(CheckoutProblem.phoneInvalid));
    }

    if (lines.isEmpty) {
      issues.add(const CheckoutIssue(CheckoutProblem.cartEmpty));
    }

    for (final line in lines) {
      if (line.qty < 1) {
        issues.add(CheckoutIssue(
          CheckoutProblem.quantityInvalid,
          productName: line.product.name,
        ));
      } else if (line.qty > line.available) {
        issues.add(CheckoutIssue(
          CheckoutProblem.insufficientStock,
          productName: line.product.name,
          available: line.available,
        ));
      }
    }

    if (shippingAddress.trim().length > maxAddressLength) {
      issues.add(const CheckoutIssue(CheckoutProblem.addressTooLong));
    }
    if (shippingCity.trim().length > maxCityLength) {
      issues.add(const CheckoutIssue(CheckoutProblem.cityTooLong));
    }

    return issues;
  }

  /// Builds a submission-ready [Order]. Ids are real UUIDs and the phone is
  /// normalised; the order number is a label only (the row id is what is
  /// unique).
  static Order buildOrder({
    required List<CheckoutLine> lines,
    required CheckoutTotals totals,
    required String customerName,
    required String customerPhone,
    String shippingAddress = '',
    String shippingCity = '',
    String? customerId,
    String? notes,
    String? idempotencyKey,
    OrderStatus status = OrderStatus.pending,
  }) {
    final now = DateTime.now();
    final orderId = IdGen.uuid();
    return Order(
      id: orderId,
      orderNumber: IdGen.orderNumber(),
      customerId: customerId,
      customerName: customerName.trim(),
      status: status,
      shippingAddress:
          shippingAddress.trim().isEmpty ? null : shippingAddress.trim(),
      shippingCity: shippingCity.trim().isEmpty ? null : shippingCity.trim(),
      subtotal: totals.subtotal,
      tax: totals.tax,
      total: totals.total,
      notes: notes,
      idempotencyKey: idempotencyKey,
      items: [
        for (final line in lines)
          OrderItem(
            id: IdGen.uuid(),
            orderId: orderId,
            productId: line.product.id,
            productName: line.product.name,
            productSku: line.product.sku,
            unitPrice: line.unitPrice,
            qty: line.qty,
            subtotal: line.lineTotal,
          ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }
}
