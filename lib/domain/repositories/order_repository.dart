import '../models/app_error.dart';
import '../models/order.dart';
import '../models/paginated_result.dart';

abstract class OrderRepository {
  Future<Result<PaginatedResult<Order>>> list({
    String? search,
    OrderStatus? status,
    String? customerId,
    int page = 1,
    int limit = 20,
  });

  Future<Result<Order>> getById(String id);

  Future<Result<Order>> create(Order order);

  Future<Result<Order>> updateStatus(String id, OrderStatus status);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();
}
