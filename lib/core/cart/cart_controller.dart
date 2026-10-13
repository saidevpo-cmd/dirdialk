import 'package:flutter/foundation.dart';

import '../../domain/models/product.dart';

class CartLine {
  CartLine({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get subtotal => product.price * quantity;

  CartLine copyWith({Product? product, int? quantity}) {
    return CartLine(product: product ?? this.product, quantity: quantity ?? this.quantity);
  }
}

class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList(growable: false);

  int get itemCount => _lines.values.fold(0, (sum, l) => sum + l.quantity);

  bool get isEmpty => _lines.isEmpty;

  double get subtotal => _lines.values.fold(0, (sum, l) => sum + l.subtotal);

  void add(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;
    if (_lines.containsKey(product.id)) {
      final existing = _lines[product.id]!;
      final nextQty = existing.quantity + quantity;
      _lines[product.id] = existing.copyWith(quantity: nextQty);
    } else {
      _lines[product.id] = CartLine(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void remove(String productId) {
    if (_lines.remove(productId) != null) {
      notifyListeners();
    }
  }

  void increment(String productId, {int amount = 1}) {
    final existing = _lines[productId];
    if (existing == null) return;
    _lines[productId] = existing.copyWith(quantity: existing.quantity + amount);
    notifyListeners();
  }

  void decrement(String productId, {int amount = 1}) {
    final existing = _lines[productId];
    if (existing == null) return;
    final nextQty = existing.quantity - amount;
    if (nextQty <= 0) {
      _lines.remove(productId);
    } else {
      _lines[productId] = existing.copyWith(quantity: nextQty);
    }
    notifyListeners();
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    final existing = _lines[productId];
    if (existing == null) return;
    _lines[productId] = existing.copyWith(quantity: quantity);
    notifyListeners();
  }

  void clear() {
    if (_lines.isNotEmpty) {
      _lines.clear();
      notifyListeners();
    }
  }

  CartLine? get(String productId) => _lines[productId];
}
