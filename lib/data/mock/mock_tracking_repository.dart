import '../../domain/models/app_error.dart';
import '../../domain/models/product_tracking.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/tracking_repository.dart';

class MockTrackingRepository implements TrackingRepository {
  MockTrackingRepository({ProductRepository? productRepository})
      : _products = productRepository;

  final ProductRepository? _products;
  final Map<String, List<TrackingEvent>> _events = {};

  @override
  Future<Result<ProductTrackingSummary?>> summaryFor(String productId) async {
    final events = <TrackingEvent>[...(_events[productId] ?? const [])]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String name = '';
    String sku = '';
    var status = TrackingStatus.inStock;
    final res = await _products?.getById(productId);
    if (res case Success(:final data)) {
      name = data.name;
      sku = data.sku ?? '';
      status = data.trackingStatus;
    }
    if (events.isNotEmpty) {
      status = events.first.status;
    }

    return Success(
      ProductTrackingSummary(
        productId: productId,
        productName: name,
        sku: sku,
        currentStatus: status,
        currentLocationName: events.isNotEmpty ? events.first.locationName : null,
        currentLocationAddress:
            events.isNotEmpty ? events.first.locationAddress : null,
        events: events,
        lastUpdated: events.isNotEmpty ? events.first.timestamp : DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<List<TrackingEvent>>> historyFor(String productId) async {
    final events = <TrackingEvent>[...(_events[productId] ?? const [])]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return Success(events);
  }

  @override
  Future<Result<TrackingEvent>> addEvent({
    required String productId,
    required TrackingEvent event,
    bool updateProduct = true,
  }) async {
    if (event.status == TrackingStatus.cancelled && event.notes == null) {
      return const Failure(
        AppError(code: 'VALIDATION', message: 'A reason is required to cancel'),
      );
    }
    final saved = event.copyWith(productId: productId);
    _events.putIfAbsent(productId, () => []).add(saved);
    return Success(saved);
  }
}