import '../../domain/models/app_error.dart';
import '../../domain/models/order.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'mock_seed_data.dart';

/// In-memory order store used when Supabase is not configured.
///
/// Mirrors the server-side rules that matter for a consistent demo/test
/// experience: orders must contain items, stock is checked and decremented on
/// creation, restored when an order is cancelled, re-reserved when a cancelled
/// order is reopened, and repeated submissions with the same
/// [Order.idempotencyKey] return the original order instead of duplicating it.
class MockOrderRepository implements OrderRepository {
  MockOrderRepository({
    List<Order>? initialData,
    ProductRepository? productRepository,
  })  : _orders = initialData != null
            ? List<Order>.from(initialData)
            : List<Order>.from(MockSeedData.orders),
        _products = productRepository;

  final List<Order> _orders;
  final ProductRepository? _products;

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
            (o.customerPhone?.toLowerCase().contains(q) ?? false) ||
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
    if (order.items.isEmpty) {
      return Failure(
        AppError.validation('An order must contain at least one item.'),
      );
    }

    final key = order.idempotencyKey;
    if (key != null && key.isNotEmpty) {
      final existing = _orders.where((o) => o.idempotencyKey == key).toList();
      if (existing.isNotEmpty) return Success(existing.first);
    }

    // Check every line before mutating stock so a rejected order leaves the
    // catalog untouched.
    if (_products != null) {
      for (final item in order.items) {
        final resolved = await _reserve(productId: item.productId, qty: item.qty);
        if (resolved is Failure<Product>) return Failure(resolved.error);
      }
    }

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
    if (existing.status == status) return Success(existing);

    final wasCancelled = existing.status == OrderStatus.cancelled;
    final willCancel = status == OrderStatus.cancelled;

    // Cancel restores stock; reopening a cancelled order reserves it again.
    if (!wasCancelled && willCancel) {
      await _restoreStock(existing);
    } else if (wasCancelled && !willCancel && _products != null) {
      for (final item in existing.items) {
        final resolved = await _reserve(
          productId: item.productId,
          qty: item.qty,
        );
        if (resolved is Failure<Product>) return Failure(resolved.error);
      }
    }

    final updated = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      paidAt: status == OrderStatus.paid ||
              status == OrderStatus.shipped ||
              status == OrderStatus.delivered
          ? (existing.paidAt ?? DateTime.now())
          : existing.paidAt,
      deliveredAt: status == OrderStatus.delivered
          ? (existing.deliveredAt ?? DateTime.now())
          : existing.deliveredAt,
      cancelledAt:
          status == OrderStatus.cancelled ? DateTime.now() : existing.cancelledAt,
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
    final order = _orders[index];
    if (order.status != OrderStatus.cancelled) {
      await _restoreStock(order);
    }
    _orders.removeAt(index);
    return const Success(null);
  }

  /// Decrements [qty] units of [productId], rejecting when unavailable.
  /// Only called when a [ProductRepository] is wired in.
  Future<Result<Product>> _reserve({
    required String? productId,
    required int qty,
  }) async {
    final repo = _products!;
    if (productId == null || productId.isEmpty) {
      return Failure(AppError.validation('Order item has no product.'));
    }
    if (qty < 1) {
      return Failure(AppError.validation('Order item quantity must be positive.'));
    }
    final found = await repo.getById(productId);
    if (found is Failure<Product>) return Failure(found.error);
    final product = (found as Success<Product>).data;
    if (product.stockQty < qty) {
      return Failure(AppError.conflict('Insufficient stock for ${product.name}'));
    }
    final updated = product.copyWith(
      stockQty: product.stockQty - qty,
      updatedAt: DateTime.now(),
    );
    final saved = await repo.update(updated);
    if (saved is Failure<Product>) return Failure(saved.error);
    return Success(updated);
  }

  /// Adds the order's quantities back into stock (used when an order is
  /// cancelled or deleted).
  Future<void> _restoreStock(Order order) async {
    final repo = _products;
    if (repo == null) return;
    for (final item in order.items) {
      final productId = item.productId;
      if (productId == null || productId.isEmpty) continue;
      final found = await repo.getById(productId);
      if (found is! Success<Product>) continue;
      final product = found.data;
      await repo.update(product.copyWith(
        stockQty: product.stockQty + item.qty,
        updatedAt: DateTime.now(),
      ));
    }
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
