import '../models/app_error.dart';
import '../models/product_tracking.dart';

abstract class TrackingRepository {
  /// Current tracking summary per product.
  Future<Result<ProductTrackingSummary?>> summaryFor(String productId);

  /// Full, chronological history for a product.
  Future<Result<List<TrackingEvent>>> historyFor(String productId);

  /// Appends a tracking event and (optionally) updates the product's current
  /// status and location in the same operation.
  Future<Result<TrackingEvent>> addEvent({
    required String productId,
    required TrackingEvent event,
    bool updateProduct = true,
  });
}