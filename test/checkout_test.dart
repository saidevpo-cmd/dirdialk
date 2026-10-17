import 'package:diali/data/mock/mock_order_repository.dart';
import 'package:diali/data/mock/mock_product_repository.dart';
import 'package:diali/domain/models/app_error.dart';
import 'package:diali/domain/models/order.dart';
import 'package:diali/domain/models/product.dart';
import 'package:diali/features/store/checkout/checkout.dart';
import 'package:diali/shared/utils/id_gen.dart';
import 'package:diali/shared/utils/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product({String? id, double price = 10, int stock = 5}) => Product(
      id: id ?? IdGen.uuid(),
      name: 'Widget',
      sku: 'W-1',
      price: price,
      stockQty: stock,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

CheckoutLine _line(Product product, int qty) =>
    CheckoutLine(product: product, qty: qty);

void main() {
  group('PhoneNumber', () {
    test('accepts 7-15 digits in common formats', () {
      expect(PhoneNumber.isValid('+1 (555) 010-0100'), isTrue);
      expect(PhoneNumber.isValid('5550100'), isTrue);
      expect(PhoneNumber.isValid('+212600000000'), isTrue);
    });

    test('rejects too short, too long and non-numeric input', () {
      expect(PhoneNumber.isValid('12345'), isFalse);
      expect(PhoneNumber.isValid('1234567890123456'), isFalse);
      expect(PhoneNumber.isValid('abcdefg'), isFalse);
      expect(PhoneNumber.isValid('   '), isFalse);
    });

    test('normalize keeps the leading + and strips formatting', () {
      expect(PhoneNumber.normalize('+1 (555) 010-0100'), '+15550100100');
      expect(PhoneNumber.normalize('555 0100'), '5550100');
      expect(PhoneNumber.normalize('no digits'), '');
    });
  });

  group('CheckoutTotals', () {
    test('rounds tax and total to two decimals', () {
      final totals = CheckoutTotals.compute(
        lines: [_line(_product(price: 33.33), 3)],
        taxRatePercent: 8,
      );
      expect(totals.subtotal, 99.99);
      expect(totals.tax, 8.0);
      expect(totals.total, 107.99);
    });
  });

  group('CheckoutValidator.validate', () {
    test('reports every missing field for an empty draft', () {
      final issues = CheckoutValidator.validate(
        customerName: '',
        customerPhone: '',
        lines: const [],
      );
      expect(
        issues.map((i) => i.problem),
        containsAll([
          CheckoutProblem.customerNameRequired,
          CheckoutProblem.phoneRequired,
          CheckoutProblem.cartEmpty,
        ]),
      );
    });

    test('flags a too-short name and a malformed phone', () {
      final issues = CheckoutValidator.validate(
        customerName: 'A',
        customerPhone: 'abc',
        lines: [_line(_product(), 1)],
      );
      expect(
        issues.map((i) => i.problem),
        containsAll([
          CheckoutProblem.customerNameTooShort,
          CheckoutProblem.phoneInvalid,
        ]),
      );
    });

    test('flags a quantity above available stock and names the product', () {
      final product = _product(stock: 2);
      final issues = CheckoutValidator.validate(
        customerName: 'Jane Doe',
        customerPhone: '5550100',
        lines: [_line(product, 5)],
      );
      final stockIssue = issues
          .singleWhere((i) => i.problem == CheckoutProblem.insufficientStock);
      expect(stockIssue.productName, 'Widget');
      expect(stockIssue.available, 2);
    });

    test('a valid draft produces no issues', () {
      final issues = CheckoutValidator.validate(
        customerName: 'Jane Doe',
        customerPhone: '+1 555 010 0100',
        lines: [_line(_product(stock: 10), 2)],
      );
      expect(issues, isEmpty);
    });
  });

  group('CheckoutValidator.buildOrder', () {
    test('generates RFC4122-shaped ids and consistent line totals', () {
      final product = _product(price: 12.5, stock: 10);
      final lines = [_line(product, 4)];
      final order = CheckoutValidator.buildOrder(
        lines: lines,
        totals: CheckoutTotals.compute(lines: lines, taxRatePercent: 0),
        customerName: ' Jane Doe ',
        customerPhone: '+1 555 0100',
        idempotencyKey: IdGen.uuid(),
      );

      final uuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuid.hasMatch(order.id), isTrue, reason: order.id);
      expect(uuid.hasMatch(order.items.single.id), isTrue);
      expect(order.customerName, 'Jane Doe');
      expect(order.items.single.subtotal, 50.0);
      expect(order.items.single.qty, 4);
    });
  });

  group('MockOrderRepository stock & idempotency', () {
    late MockProductRepository products;
    late MockOrderRepository orders;
    late Product product;

    Order draft({required String idempotencyKey, int qty = 2}) {
      final lines = [_line(product, qty)];
      return CheckoutValidator.buildOrder(
        lines: lines,
        totals: CheckoutTotals.compute(lines: lines, taxRatePercent: 0),
        customerName: 'Jane Doe',
        customerPhone: '5550100',
        idempotencyKey: idempotencyKey,
      );
    }

    Future<int> stock() async {
      final result = await products.getById(product.id);
      return (result as Success<Product>).data.stockQty;
    }

    setUp(() {
      product = _product(stock: 5);
      products = MockProductRepository(seedData: [product]);
      orders = MockOrderRepository(
        initialData: const [],
        productRepository: products,
      );
    });

    test('empty orders are rejected', () async {
      final result = await orders.create(Order(
        id: IdGen.uuid(),
        orderNumber: 'ORD-0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      expect(result, isA<Failure<Order>>());
    });

    test('creating an order reserves stock', () async {
      final result = await orders.create(draft(idempotencyKey: IdGen.uuid()));
      expect(result, isA<Success<Order>>());
      expect(await stock(), 3);
    });

    test('rejects an order that exceeds available stock', () async {
      final result = await orders.create(
        draft(idempotencyKey: IdGen.uuid(), qty: 10),
      );
      expect(result, isA<Failure<Order>>());
      expect(await stock(), 5, reason: 'a rejected order must not move stock');
    });

    test('the same idempotency key is replayed, not duplicated', () async {
      final key = IdGen.uuid();
      final first = await orders.create(draft(idempotencyKey: key));
      final second = await orders.create(draft(idempotencyKey: key));
      expect((first as Success<Order>).data.id, (second as Success<Order>).data.id);
      expect(await stock(), 3);
    });

    test('cancelling restores stock and reopening re-reserves it', () async {
      final created = await orders.create(draft(idempotencyKey: IdGen.uuid()));
      final id = (created as Success<Order>).data.id;

      await orders.updateStatus(id, OrderStatus.cancelled);
      expect(await stock(), 5);

      await orders.updateStatus(id, OrderStatus.paid);
      expect(await stock(), 3);
    });

    test('deleting a live order restores stock', () async {
      final created = await orders.create(draft(idempotencyKey: IdGen.uuid()));
      final id = (created as Success<Order>).data.id;
      expect(await stock(), 3);

      await orders.delete(id);
      expect(await stock(), 5);
    });

    test('deleting a cancelled order does not double-restore', () async {
      final created = await orders.create(draft(idempotencyKey: IdGen.uuid()));
      final id = (created as Success<Order>).data.id;

      await orders.updateStatus(id, OrderStatus.cancelled);
      expect(await stock(), 5);

      await orders.delete(id);
      expect(await stock(), 5);
    });
  });
}
