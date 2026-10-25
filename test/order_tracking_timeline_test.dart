import 'package:diali/core/design_system/app_style.dart';
import 'package:diali/core/design_system/app_theme.dart';
import 'package:diali/domain/models/order.dart';
import 'package:diali/domain/models/order_tracking.dart';
import 'package:diali/domain/models/tracking_stage.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:diali/shared/utils/order_number.dart';
import 'package:diali/shared/widgets/order_tracking_summary.dart';
import 'package:diali/shared/widgets/order_tracking_timeline.dart';
import 'package:diali/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] inside a themed, localized host of the given [width].
Future<AppLocalizations> pumpHost(
  WidgetTester tester,
  Widget child, {
  double width = 600,
  TextDirection direction = TextDirection.ltr,
}) async {
  final l10n = await AppLocalizations.delegate.load(const Locale('en'));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      theme: AppTheme.build(AppStyle.modern, Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: Directionality(
            textDirection: direction,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return l10n;
}

/// Decoration of the circular node rendered for [stage], or null.
BoxDecoration? nodeDecoration(WidgetTester tester, TrackingStage stage) {
  final nodes = tester.widgetList<Container>(
    find.descendant(
      of: OrderTrackingTimeline.stageKey(stage),
      matching: find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration != null,
      ),
    ),
  );
  if (nodes.isEmpty) return null;
  return nodes.first.decoration! as BoxDecoration;
}

OrderTracking orderTracking({
  String number = '#1',
  OrderStatus status = OrderStatus.pending,
  DateTime? paidAt,
  DateTime? deliveredAt,
  DateTime? cancelledAt,
}) =>
    OrderTracking(
      orderNumber: number,
      status: status,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 3),
      paidAt: paidAt,
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt,
      total: 0,
    );

Order order({
  String number = '#1',
  OrderStatus status = OrderStatus.pending,
  DateTime? paidAt,
  DateTime? deliveredAt,
  DateTime? cancelledAt,
}) =>
    Order(
      id: 'o-1',
      orderNumber: number,
      status: status,
      paidAt: paidAt,
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 3),
    );

void main() {
  group('stage mapping only advances on database evidence', () {
    test('each order status maps to its journey stage', () {
      expect(
        trackingStageFor(OrderStatus.pending),
        TrackingStage.orderReceived,
      );
      expect(trackingStageFor(OrderStatus.paid), TrackingStage.processing);
      expect(trackingStageFor(OrderStatus.shipped), TrackingStage.shipped);
      expect(trackingStageFor(OrderStatus.delivered), TrackingStage.delivered);
    });

    test('a cancelled order never claims more progress than it had', () {
      expect(
        trackingStageFor(OrderStatus.cancelled, paid: false),
        TrackingStage.orderReceived,
      );
      expect(
        trackingStageFor(OrderStatus.cancelled, paid: true),
        TrackingStage.processing,
      );
      expect(
        trackingStageForOrder(order(status: OrderStatus.cancelled)),
        TrackingStage.orderReceived,
      );
      expect(
        trackingStageForOrder(
          order(status: OrderStatus.cancelled, paidAt: DateTime.utc(2026, 1, 2)),
        ),
        TrackingStage.processing,
      );
    });

    test('timestamps exist only for stages the backend recorded', () {
      final paid = stageTimestampsForOrder(
        order(status: OrderStatus.paid, paidAt: DateTime.utc(2026, 1, 2)),
      );
      expect(paid.keys, [
        TrackingStage.orderReceived,
        TrackingStage.processing,
      ]);
      // No column records these, so they must stay absent.
      expect(paid.containsKey(TrackingStage.inTransit), isFalse);
      expect(paid.containsKey(TrackingStage.outForDelivery), isFalse);
      expect(paid.containsKey(TrackingStage.shipped), isFalse);

      final shipped = stageTimestampsForOrder(
        order(status: OrderStatus.shipped),
      );
      // No shipped_at column: the tracked moment is updated_at while the
      // order is in that state (same convention the tracking page documents).
      expect(shipped[TrackingStage.shipped], DateTime.utc(2026, 1, 3));

      final delivered = stageTimestampsForTracking(
        orderTracking(
          status: OrderStatus.delivered,
          deliveredAt: DateTime.utc(2026, 1, 5),
        ),
      );
      expect(delivered[TrackingStage.delivered], DateTime.utc(2026, 1, 5));
    });

    test('the shipment date is only known while the order is shipped', () {
      expect(shipmentDateFor(order(status: OrderStatus.paid)), isNull);
      expect(shipmentDateFor(order(status: OrderStatus.delivered)), isNull);
      expect(
        shipmentDateFor(order(status: OrderStatus.shipped)),
        DateTime.utc(2026, 1, 3),
      );
    });
  });

  group('OrderNumber.format', () {
    test('pads plain integers to the zero-padded business format', () {
      expect(OrderNumber.format('7'), '#007');
      expect(OrderNumber.format('#7'), '#007');
      expect(OrderNumber.format('007'), '#007');
      expect(OrderNumber.format('42'), '#042');
      expect(OrderNumber.format('#1048'), '#1048');
      expect(OrderNumber.format('  #1  '), '#001');
    });

    test('leaves generated labels and empty values untouched', () {
      expect(OrderNumber.format('ORD-1-ABCD'), 'ORD-1-ABCD');
      expect(OrderNumber.format(''), '');
      expect(OrderNumber.format('   '), '   ');
      expect(OrderNumber.format('-5'), '-5');
    });

    test('is idempotent, so the displayed number keeps matching storage', () {
      const once = '#1';
      final twice = OrderNumber.format(OrderNumber.format(once));
      expect(twice, OrderNumber.format(once));
    });
  });

  group('OrderTrackingTimeline', () {
    testWidgets('renders a vertical rail on narrow screens', (tester) async {
      final l10n = await pumpHost(
        tester,
        OrderTrackingTimeline(
          currentStage: TrackingStage.shipped,
          timestamps: {
            TrackingStage.orderReceived: DateTime.utc(2026, 1, 1, 10),
            TrackingStage.processing: DateTime.utc(2026, 1, 2, 9),
            TrackingStage.shipped: DateTime.utc(2026, 1, 3, 8),
          },
        ),
        width: 400,
      );

      expect(find.byKey(const ValueKey('tracking-timeline-vertical')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('tracking-timeline-horizontal')),
          findsNothing);

      for (final stage in TrackingStage.values) {
        expect(find.byKey(OrderTrackingTimeline.stageKey(stage)), findsOneWidget,
            reason: '${stage.name} must be rendered');
      }
      // Every stage carries its localized label.
      expect(find.byKey(ValueKey('stage-label-orderReceived')),
          findsOneWidget);
      expect(
        find.text(l10n.trackingStageOutForDelivery),
        findsOneWidget,
      );
      // Known timestamps are shown as date · time under the label.
      expect(find.textContaining('Jan 1'), findsWidgets);
    });

    testWidgets('switches to a horizontal rail on wide screens',
        (tester) async {
      await pumpHost(
        tester,
        const OrderTrackingTimeline(currentStage: TrackingStage.shipped),
        width: 900,
      );

      expect(find.byKey(const ValueKey('tracking-timeline-horizontal')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('tracking-timeline-vertical')),
          findsNothing);
      for (final stage in TrackingStage.values) {
        expect(find.byKey(OrderTrackingTimeline.stageKey(stage)), findsOneWidget);
      }
    });

    testWidgets('distinguishes completed, current and upcoming stages',
        (tester) async {
      await pumpHost(
        tester,
        const OrderTrackingTimeline(currentStage: TrackingStage.shipped),
        width: 400,
      );
      final scheme = Theme.of(
        tester.element(find.byKey(const ValueKey('tracking-timeline-vertical'))),
      ).colorScheme;

      final completed = nodeDecoration(tester, TrackingStage.orderReceived);
      expect(completed?.color, scheme.primary);
      expect(completed?.border, isNull);

      final current = nodeDecoration(tester, TrackingStage.shipped);
      expect(current?.color, scheme.primaryContainer);
      expect(current?.border, isNotNull);

      final upcoming = nodeDecoration(tester, TrackingStage.inTransit);
      expect(upcoming?.color, scheme.surfaceContainerHighest);
      expect(upcoming?.border, isNull);

      final last = nodeDecoration(tester, TrackingStage.delivered);
      expect(last?.color, scheme.surfaceContainerHighest);
    });

    testWidgets('marks a cancelled order without implying movement',
        (tester) async {
      final l10n = await pumpHost(
        tester,
        const OrderTrackingTimeline(
          currentStage: TrackingStage.orderReceived,
          cancelled: true,
        ),
        width: 400,
      );

      expect(find.text(l10n.trackingCancelled), findsOneWidget);
      final cancelled = nodeDecoration(tester, TrackingStage.orderReceived);
      expect(cancelled?.border, isNotNull);
    });

    testWidgets('lays out without overflow in RTL', (tester) async {
      final l10n = await pumpHost(
        tester,
        const OrderTrackingTimeline(currentStage: TrackingStage.processing),
        width: 360,
        direction: TextDirection.rtl,
      );

      expect(find.byKey(const ValueKey('tracking-timeline-vertical')),
          findsOneWidget);
      expect(find.text(l10n.trackingStageInTransit), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('OrderTrackingSummary', () {
    testWidgets('says tracking is unavailable when the backend knows nothing',
        (tester) async {
      final l10n = await pumpHost(
        tester,
        const OrderTrackingSummary(orderNumber: '#7'),
      );

      expect(find.byKey(OrderTrackingSummary.unavailableKey), findsOneWidget);
      expect(find.text(l10n.trackingUnavailable), findsOneWidget);
      // The order number is rendered in the padded business format.
      expect(find.text('#007'), findsOneWidget);
      expect(
        find.byKey(OrderTrackingSummary.valueKey('trackingNumber')),
        findsNothing,
      );
      expect(
        find.byKey(OrderTrackingSummary.valueKey('shippingCompany')),
        findsNothing,
      );
    });

    testWidgets('renders provider data as soon as it is passed in',
        (tester) async {
      final l10n = await pumpHost(
        tester,
        const OrderTrackingSummary(
          orderNumber: '#12',
          statusBadge: StatusBadge.warning(label: 'Shipped'),
          trackingNumber: 'TRK-991',
          shippingCompany: 'Atlas Air',
          shipmentDate: null,
          estimatedDelivery: null,
          currentLocation: 'Casablanca hub',
          latestUpdate: 'Departed sorting facility',
          latestUpdateAt: null,
        ),
      );

      expect(find.byKey(OrderTrackingSummary.unavailableKey), findsNothing);
      expect(find.text(l10n.trackingUnavailable), findsNothing);
      expect(find.text('#012'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('TRK-991'), findsOneWidget);
      expect(find.text('Atlas Air'), findsOneWidget);
      expect(find.text('Casablanca hub'), findsOneWidget);
      expect(find.text('Departed sorting facility'), findsOneWidget);
    });

    testWidgets('shows the shipment date when one exists', (tester) async {
      final l10n = await pumpHost(
        tester,
        const OrderTrackingSummary(
          orderNumber: '#3',
          shipmentDate: null,
        ),
      );

      expect(
        find.byKey(OrderTrackingSummary.valueKey('shipmentDate')),
        findsNothing,
      );
      expect(find.text(l10n.shipmentDateLabel), findsNothing);
      expect(find.byKey(OrderTrackingSummary.unavailableKey), findsOneWidget);
    });
  });

  group('OrderTracking model mapping', () {
    test('the public projection drives the same stages as the admin order',
        () {
      expect(
        trackingStageForOrderTracking(
          orderTracking(status: OrderStatus.pending),
        ),
        TrackingStage.orderReceived,
      );
      expect(
        trackingStageForOrderTracking(
          orderTracking(
            status: OrderStatus.paid,
            paidAt: DateTime.utc(2026, 1, 2),
          ),
        ),
        TrackingStage.processing,
      );
      expect(
        trackingStageForOrderTracking(
          orderTracking(status: OrderStatus.shipped),
        ),
        TrackingStage.shipped,
      );
      expect(
        trackingStageForOrderTracking(
          orderTracking(
            status: OrderStatus.delivered,
            deliveredAt: DateTime.utc(2026, 1, 4),
          ),
        ),
        TrackingStage.delivered,
      );
    });
  });
}
