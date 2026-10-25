import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_tracking.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/order_repository.dart';
import 'supabase_mappers.dart';

class SupabaseOrderRepository implements OrderRepository {
  static const _select = '*, customer:customers(name), order_items(*)';

  @override
  Future<Result<PaginatedResult<Order>>> list({
    String? search,
    OrderStatus? status,
    String? customerId,
    DateTime? createdFrom,
    DateTime? createdTo,
    int page = 1,
    int limit = 20,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('orders').select(_select);
      if (status != null) query = query.eq('status', status.name);
      if (customerId != null && customerId.isNotEmpty) {
        query = query.eq('customer_id', customerId);
      }
      // Inclusive order-date window on created_at (stored as timestamptz).
      if (createdFrom != null) {
        query = query.gte('created_at', createdFrom.toUtc().toIso8601String());
      }
      if (createdTo != null) {
        query = query.lte('created_at', createdTo.toUtc().toIso8601String());
      }
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or(
          'order_number.ilike.%$q%,customer_name.ilike.%$q%,'
          'customer_phone.ilike.%$q%,customer_email.ilike.%$q%',
        );
      }
      final response = await query
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<Order>(
        items: response.data
            .map((r) => Db.orderFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<Order>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('orders')
          .select(_select)
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.orderFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Order>> create(Order order) async {
    if (order.items.isEmpty) {
      return Failure(
        AppError.validation('An order must contain at least one item.'),
      );
    }
    final inserted = await guard<String>(() async {
      final id = await AppSupabase.client.rpc('place_order', params: {
        'p_order': Db.order(order),
        'p_items': order.items.map(Db.orderItem).toList(),
      });
      return id as String;
    });
    if (inserted case Failure(:final error)) return Failure(error);
    final id = (inserted as Success<String>).data;
    return getById(id);
  }

  @override
  Future<Result<Order>> updateStatus(String id, OrderStatus status) {
    return guard(() async {
      final now = DateTime.now().toUtc().toIso8601String();
      final patch = <String, dynamic>{'status': status.name};
      if (status == OrderStatus.paid ||
          status == OrderStatus.shipped ||
          status == OrderStatus.delivered) {
        patch['paid_at'] = now;
      }
      if (status == OrderStatus.delivered) patch['delivered_at'] = now;
      if (status == OrderStatus.cancelled) patch['cancelled_at'] = now;
      final data = await AppSupabase.client
          .from('orders')
          .update(patch)
          .eq('id', id)
          .select(_select)
          .single();
      return Db.orderFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('orders').delete().eq('id', id);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final rows =
          await AppSupabase.client.from('orders').select('status,total');
      var totalSales = 0.0;
      var pending = 0;
      var delivered = 0;
      for (final r in rows) {
        final status = r['status']?.toString();
        final total = (r['total'] as num?)?.toDouble() ?? 0;
        if (status != 'cancelled') totalSales += total;
        if (status == 'pending') pending++;
        if (status == 'delivered') delivered++;
      }
      return {
        'totalOrders': rows.length,
        'totalSales': totalSales,
        'pendingOrders': pending,
        'deliveredOrders': delivered,
      };
    });
  }

  @override
  Future<Result<OrderTracking?>> track({
    required String orderNumber,
    required String phone,
  }) {
    return guard(() async {
      final data = await AppSupabase.client.rpc('track_order', params: {
        'p_order_number': orderNumber,
        'p_phone': phone,
      });
      if (data == null) return null;
      return Db.orderTrackingFrom(Map<String, dynamic>.from(data as Map));
    });
  }
}