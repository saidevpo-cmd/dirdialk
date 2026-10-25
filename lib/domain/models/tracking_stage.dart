import 'order.dart';
import 'order_tracking.dart';

/// The customer-facing shipping journey, from checkout to doorstep.
///
/// These stages are a *view* over [OrderStatus]: the database only stores
/// `pending | paid | shipped | delivered | cancelled`, so the intermediate
/// carrier stages (in transit, out for delivery) are always upcoming until an
/// external shipping provider reports them. Nothing here invents progress —
/// [trackingStageFor] only ever advances a stage when a timestamp in the
/// database proves it.
enum TrackingStage {
  orderReceived,
  processing,
  shipped,
  inTransit,
  outForDelivery,
  delivered;

  /// True when this stage is the one the order is currently sitting on.
  bool isAtOrAfter(TrackingStage other) => index >= other.index;

  bool isBefore(TrackingStage other) => index < other.index;
}

/// Resolves the furthest journey stage that is *evidenced* by the order data.
///
/// [paid] carries whether the order was ever paid (its `paid_at` timestamp),
/// which is the only way to tell how far a cancelled order had progressed
/// before it was stopped.
TrackingStage trackingStageFor(OrderStatus status, {bool paid = false}) {
  switch (status) {
    case OrderStatus.pending:
      return TrackingStage.orderReceived;
    case OrderStatus.paid:
      return TrackingStage.processing;
    case OrderStatus.shipped:
      return TrackingStage.shipped;
    case OrderStatus.delivered:
      return TrackingStage.delivered;
    case OrderStatus.cancelled:
      return paid ? TrackingStage.processing : TrackingStage.orderReceived;
  }
}

/// Maps a full order row to its journey stage.
TrackingStage trackingStageForOrder(Order order) => trackingStageFor(
      order.status,
      paid: order.paidAt != null || order.status == OrderStatus.delivered,
    );

/// Maps the public tracking projection (from the `track_order` RPC) to its
/// journey stage.
TrackingStage trackingStageForOrderTracking(OrderTracking tracking) =>
    trackingStageFor(
      tracking.status,
      paid: tracking.paidAt != null ||
          tracking.status == OrderStatus.delivered,
    );

/// Timestamps that are actually known for each stage, keyed by stage.
///
/// Stages without a backing column in the database are simply absent, which
/// keeps the timeline from displaying dates the backend never produced. The
/// shipped stage reuses `updated_at` while the order *is* shipped — the same
/// convention the tracking page already documents (there is no `shipped_at`
/// column).
Map<TrackingStage, DateTime> stageTimestampsForOrder(Order order) => {
      TrackingStage.orderReceived: order.createdAt,
      if (order.paidAt != null) TrackingStage.processing: order.paidAt!,
      if (order.status == OrderStatus.shipped)
        TrackingStage.shipped: order.updatedAt,
      if (order.deliveredAt != null)
        TrackingStage.delivered: order.deliveredAt!,
    };

/// Same as [stageTimestampsForOrder] for the public tracking projection.
Map<TrackingStage, DateTime> stageTimestampsForTracking(
  OrderTracking tracking,
) =>
    {
      TrackingStage.orderReceived: tracking.createdAt,
      if (tracking.paidAt != null) TrackingStage.processing: tracking.paidAt!,
      if (tracking.status == OrderStatus.shipped)
        TrackingStage.shipped: tracking.updatedAt,
      if (tracking.deliveredAt != null)
        TrackingStage.delivered: tracking.deliveredAt!,
    };

/// The moment the order was handed to shipping, when it is known.
///
/// Only `shipped` orders carry it (via `updated_at`); for older orders the
/// database cannot tell us, so this returns null instead of guessing.
DateTime? shipmentDateFor(Order order) =>
    order.status == OrderStatus.shipped ? order.updatedAt : null;

/// Same as [shipmentDateFor] for the public tracking projection.
DateTime? shipmentDateForTracking(OrderTracking tracking) =>
    tracking.status == OrderStatus.shipped ? tracking.updatedAt : null;
