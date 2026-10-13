import 'cart_controller.dart';

class CartStorage {
  CartStorage._();

  static String serialize(CartController cart) {
    final items = cart.lines.map((l) {
      return {
        'productId': l.product.id,
        'quantity': l.quantity,
      };
    }).toList();
    return '{"items": ${_itemsToJson(items)}}';
  }

  static void restore(CartController cart, Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?) ?? <dynamic>[];
    cart.clear();
    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final productId = map['productId'] as String?;
      final qty = (map['quantity'] as num?)?.toInt() ?? 1;
      if (productId == null) continue;
      // Products are resolved from repository in UI scope; store IDs only.
      // To keep lightweight, we don't auto-add products here.
      final product = cart.get(productId)?.product;
      if (product != null) {
        cart.setQuantity(productId, qty);
      }
    }
  }

  static String _itemsToJson(List<Map<String, dynamic>> items) {
    final sb = StringBuffer();
    sb.write('[');
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      sb.write('{"productId":"${_escape(it['productId'])}","quantity":${it['quantity']}}');
      if (i < items.length - 1) sb.write(',');
    }
    sb.write(']');
    return sb.toString();
  }

  static String _escape(dynamic v) {
    return v.toString().replaceAll('"', '\\"');
  }
}
