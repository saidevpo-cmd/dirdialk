import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/product_tracking.dart';
import '../../domain/repositories/tracking_repository.dart';
import 'supabase_mappers.dart';

class SupabaseTrackingRepository implements TrackingRepository {
  @override
  Future<Result<ProductTrackingSummary?>> summaryFor(String productId) {
    return guard(() async {
      final product = await AppSupabase.client
          .from('products')
          .select(
            'id,name,sku,tracking_status,location:locations(name,address),product_tracking:tracking_events(*)',
          )
          .eq('id', productId)
          .maybeSingle();
      if (product == null) return null;

      final rawEvents = (product['product_tracking'] as List?) ?? const [];
      final events = rawEvents
          .whereType<Map>()
          .map((e) => Db.trackingEventFrom(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final location = product['location'];
      String? locationName;
      String? locationAddress;
      if (location is Map) {
        locationName = location['name']?.toString();
        locationAddress = location['address']?.toString();
      }
      if (events.isNotEmpty) {
        locationName ??= events.first.locationName;
        locationAddress ??= events.first.locationAddress;
      }

      return ProductTrackingSummary(
        productId: product['id'] as String,
        productName: product['name']?.toString() ?? '',
        sku: product['sku']?.toString() ?? '',
        currentStatus: TrackingStatus.values.firstWhere(
          (s) => s.name == product['tracking_status'],
          orElse: () => TrackingStatus.inStock,
        ),
        currentLocationName: locationName,
        currentLocationAddress: locationAddress,
        events: events,
        lastUpdated: events.isNotEmpty ? events.first.timestamp : DateTime.now(),
      );
    });
  }

  @override
  Future<Result<List<TrackingEvent>>> historyFor(String productId) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('tracking_events')
          .select('*')
          .eq('product_id', productId)
          .order('occurred_at', ascending: false);
      return data
          .map((r) => Db.trackingEventFrom(Map<String, dynamic>.from(r)))
          .toList();
    });
  }

  @override
  Future<Result<TrackingEvent>> addEvent({
    required String productId,
    required TrackingEvent event,
    bool updateProduct = true,
  }) async {
    final inserted = await guard<TrackingEvent>(() async {
      final payload = Db.trackingEvent(event.copyWith(productId: productId));
      final data = await AppSupabase.client
          .from('tracking_events')
          .insert(payload)
          .select('*')
          .single();
      return Db.trackingEventFrom(Map<String, dynamic>.from(data));
    });
    if (inserted case Failure(:final error)) return Failure(error);

    if (updateProduct) {
      final patch = <String, dynamic>{'tracking_status': event.status.name};
      if (event.referenceNumber != null) {
        patch['tracking_code'] = event.referenceNumber;
      }
      final updated = await guard<void>(() async {
        await AppSupabase.client
            .from('products')
            .update(patch)
            .eq('id', productId);
      });
      if (updated case Failure(:final error)) return Failure(error);
    }
    return inserted;
  }
}