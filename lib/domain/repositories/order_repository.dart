import '../models/app_error.dart';
import '../models/order.dart';
import '../models/order_tracking.dart';
import '../models/paginated_result.dart';

abstract class OrderRepository {
  /// Lists orders newest-first.
  ///
  /// [search] matches the order number and customer name/contact details;
  /// [status] narrows to one workflow state; [createdFrom] / [createdTo]
  /// bound the order date (inclusive, local time — both are normalised to UTC
  /// by the implementations). All filters combine, and [page] is 1-based.
  Future<Result<PaginatedResult<Order>>> list({
    String? search,
    OrderStatus? status,
    String? customerId,
    DateTime? createdFrom,
    DateTime? createdTo,
    int page = 1,
    int limit = 20,
  });

  Future<Result<Order>> getById(String id);

  Future<Result<Order>> create(Order order);

  Future<Result<Order>> updateStatus(String id, OrderStatus status);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();

  /// Public order lookup by order number **and** the phone captured at
  /// checkout. The phone is the proof of ownership; a bare order number is
  /// not enough. Returns `null` when no order matches — an unknown number and
  /// a wrong phone are deliberately indistinguishable (no enumeration
  /// oracle). Backed by the `track_order` RPC on the server.
  Future<Result<OrderTracking?>> track({
    required String orderNumber,
    required String phone,
  });
}
