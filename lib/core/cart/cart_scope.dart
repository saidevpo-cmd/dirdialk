import 'package:flutter/material.dart';

import 'cart_controller.dart';

class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController cart,
    required super.child,
  }) : super(notifier: cart);

  static CartController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<CartScope>();
    if (result == null) {
      throw StateError('CartScope not found in widget tree');
    }
    return result.notifier!;
  }
}
