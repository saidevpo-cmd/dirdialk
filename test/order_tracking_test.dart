import 'package:diali/core/design_system/app_style.dart';
import 'package:diali/core/design_system/app_theme.dart';
import 'package:diali/data/app_repositories.dart';
import 'package:diali/data/mock/mock_order_repository.dart';
import 'package:diali/data/supabase/supabase_mappers.dart';
import 'package:diali/domain/models/app_error.dart';
import 'package:diali/domain/models/order.dart';
import 'package:diali/domain/models/order_tracking.dart';
import 'package:diali/domain/models/tracking_stage.dart';
import 'package:diali/features/tracking/order_tracking_page.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:diali/shared/widgets/order_tracking_summary.dart';
import 'package:diali/shared/widgets/order_tracking_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order({
  String number = 'ORD-1',
  String? phone,
  OrderStatus status = OrderStatus.paid,
}) =>
    Order(
      id: 'o1',
      orderNumber: number,
      status: status,
      total: 30,
      subtotal: 30,
      customerName: 'Layla',
      customerPhone: phone,
      paidAt: DateTime.utc(2026, 1, 2),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
      items: const [
        OrderItem(
          id: 'i1',
          orderId: 'o1',
          productName: 'Widget',
          unitPrice: 10,
          qty: 3,
          subtotal: 30,
        ),
      ],
    );

void main() {
  group('Db.orderTrackingFrom', () {
    test('parses the curated RPC projection', () {
      final tracking = Db.orderTrackingFrom({
        'order_number': 'ORD-1',
        'status': 'shipped',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-03T00:00:00.000Z',
        'paid_at': '2026-01-02T00:00:00.000Z',
        'delivered_at': null,
        'cancelled_at': null,
        'total': '30.00',
        'currency_symbol': 'MAD',
        'items': [
          {'name': 'Widget', 'qty': 3, 'subtotal': '30.00'},
        ],
      });

      expect(tracking.orderNumber, 'ORD-1');
      expect(tracking.status, OrderStatus.shipped);
      expect(tracking.paidAt, isNotNull);
      expect(tracking.deliveredAt, isNull);
      expect(tracking.total, 30.0);
      expect(tracking.currencySymbol, 'MAD');
      expect(tracking.items, hasLength(1));
      expect(tracking.items.single.name, 'Widget');
      expect(tracking.items.single.qty, 3);
      expect(tracking.items.single.subtotal, 30.0);
    });

    test('tolerates a missing items array and unknown status', () {
      final tracking = Db.orderTrackingFrom({
        'order_number': 'ORD-2',
        'status': 'not-a-status',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
        'total': 0,
      });

      expect(tracking.status, OrderStatus.pending);
      expect(tracking.items, isEmpty);
      expect(tracking.currencySymbol, '');
    });
  });

  group('MockOrderRepository.track', () {
    test('matches on order number and phone digits', () async {
      final repo = MockOrderRepository(
        initialData: [_order(number: 'ORD-7', phone: '+1 (555) 010-0100')],
      );

      final result = await repo.track(
        orderNumber: ' ord-7 ',
        phone: '+1 555 0100100',
      );

      expect(result, isA<Success<OrderTracking?>>());
      final tracking = (result as Success<OrderTracking?>).data;
      expect(tracking, isNotNull);
      expect(tracking!.orderNumber, 'ORD-7');
      expect(tracking.items.single.name, 'Widget');
    });

    test('a wrong phone and an unknown order both return null', () async {
      final repo = MockOrderRepository(
        initialData: [_order(number: 'ORD-7', phone: '+1 555 010-0100')],
      );

      final wrongPhone =
          await repo.track(orderNumber: 'ORD-7', phone: '5550199');
      expect(wrongPhone, isA<Success<OrderTracking?>>());
      expect((wrongPhone as Success<OrderTracking?>).data, isNull);

      final unknown =
          await repo.track(orderNumber: 'NOPE', phone: '5550100100');
      expect((unknown as Success<OrderTracking?>).data, isNull);
    });

    test('seeded orders without a stored phone match by number alone', () async {
      final repo = MockOrderRepository(initialData: [_order(number: '#001')]);

      final result = await repo.track(orderNumber: '#001', phone: '5550100');
      expect((result as Success<OrderTracking?>).data, isNotNull);
    });

    test('rejects empty order numbers and malformed phones', () async {
      final repo = MockOrderRepository(initialData: const []);

      expect(
        await repo.track(orderNumber: '', phone: '5550100'),
        isA<Failure<OrderTracking?>>(),
      );
      final bad = await repo.track(orderNumber: 'ORD-1', phone: 'abc');
      expect(bad, isA<Failure<OrderTracking?>>());
      expect((bad as Failure<OrderTracking?>).error.code,
          AppError.validationCode);
    });
  });

  group('OrderTrackingPage', () {
    setUp(AppRepositories.reset);

    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppTheme.build(AppStyle.modern, Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OrderTrackingPage(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('requires both fields before searching', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await pumpPage(tester);

      await tester.tap(find.byKey(OrderTrackingPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(find.text(l10n.trackOrderRequired), findsOneWidget);
    });

    testWidgets('shows a result for a matching order', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await pumpPage(tester);

      await tester.enterText(
          find.byKey(OrderTrackingPage.orderNumberFieldKey), '#001');
      await tester.enterText(
          find.byKey(OrderTrackingPage.phoneFieldKey), '5550100');
      await tester.tap(find.byKey(OrderTrackingPage.submitButtonKey));
      await tester.pumpAndSettle();

      // The seeded demo order carries no stored phone, so the mock matches on
      // the order number; the real backend requires both factors. The result
      // renders the order number, the status badge and the six-stage timeline
      // ("Delivered" therefore appears as both a badge and a stage label).
      expect(
        find.byKey(OrderTrackingSummary.orderNumberKey),
        findsOneWidget,
      );
      expect(find.text('#001'), findsOneWidget);
      expect(find.text(l10n.statusDelivered), findsWidgets);
      expect(
        find.byKey(OrderTrackingTimeline.stageKey(TrackingStage.delivered)),
        findsOneWidget,
      );
      // Nothing about the shipment beyond the order itself is stored, so the
      // card must say so rather than imply a carrier exists.
      expect(find.byKey(OrderTrackingSummary.unavailableKey), findsOneWidget);
    });

    testWidgets('shows a not-found state for an unknown order',
        (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await pumpPage(tester);

      await tester.enterText(
          find.byKey(OrderTrackingPage.orderNumberFieldKey), 'NO-SUCH-ORDER');
      await tester.enterText(
          find.byKey(OrderTrackingPage.phoneFieldKey), '5550100');
      await tester.tap(find.byKey(OrderTrackingPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(find.text(l10n.trackOrderNotFound), findsOneWidget);
    });
  });
}
