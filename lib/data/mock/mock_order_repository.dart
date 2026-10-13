import '../../domain/models/app_error.dart';
import '../../domain/models/order.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/order_repository.dart';
import 'mock_seed_data.dart';

class MockOrderRepository implements OrderRepository {
  MockOrderRepository({List<Order>? initialData})
      : _orders = initialData != null
            ? List<Order>.from(initialData)
            : List<Order>.from(MockSeedData.orders);

  final List<Order> _orders;

  @override
  Future<Result<PaginatedResult<Order>>> list({
    String? search,
    OrderStatus? status,
    String? customerId,
    int page = 1,
    int limit = 20,
  }) async {
    var filtered = List<Order>.from(_orders);

    if (status != null) {
      filtered = filtered.where((o) => o.status == status).toList();
    }

    if (customerId != null && customerId.isNotEmpty) {
      filtered = filtered.where((o) => o.customerId == customerId).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((o) {
        return o.orderNumber.toLowerCase().contains(q) ||
            (o.customerName?.toLowerCase().contains(q) ?? false) ||
            (o.customerEmail?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = filtered.length;
    final startIndex = (page - 1) * limit;
    final paginatedItems = startIndex >= total
        ? <Order>[]
        : filtered.skip(startIndex).take(limit).toList();

    return Success(
      PaginatedResult(
        items: paginatedItems,
        total: total,
        page: page,
        limit: limit,
      ),
    );
  }

  @override
  Future<Result<Order>> getById(String id) async {
    try {
      final order = _orders.firstWhere((o) => o.id == id);
      return Success(order);
    } catch (_) {
      return const Failure(AppError.notFound);
    }
  }

  @override
  Future<Result<Order>> create(Order order) async {
    _orders.insert(0, order);
    return Success(order);
  }

  @override
  Future<Result<Order>> updateStatus(String id, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    final existing = _orders[index];
    final updated = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      paidAt: status == OrderStatus.paid || status == OrderStatus.shipped || status == OrderStatus.delivered
          ? (existing.paidAt ?? DateTime.now())
          : existing.paidAt,
      deliveredAt: status == OrderStatus.delivered
          ? (existing.deliveredAt ?? DateTime.now())
          : existing.deliveredAt,
      cancelledAt: status == OrderStatus.cancelled
          ? (existing.cancelledAt ?? DateTime.now())
          : existing.cancelledAt,
    );
    _orders[index] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _orders.removeAt(index);
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    final totalSales = _orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (sum, o) => sum + o.total);
    final pendingCount =
        _orders.where((o) => o.status == OrderStatus.pending).length;
    final deliveredCount =
        _orders.where((o) => o.status == OrderStatus.delivered).length;
    return Success({
      'totalOrders': _orders.length,
      'totalSales': totalSales,
      'pendingOrders': pendingCount,
      'deliveredOrders': deliveredCount,
    });
  }
}
