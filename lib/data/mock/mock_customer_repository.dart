import '../../domain/models/app_error.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/customer_repository.dart';
import 'mock_seed_data.dart';

class MockCustomerRepository implements CustomerRepository {
  MockCustomerRepository({List<Customer>? initialData})
      : _customers = initialData != null
            ? List<Customer>.from(initialData)
            : List<Customer>.from(MockSeedData.customers);

  final List<Customer> _customers;

  @override
  Future<Result<PaginatedResult<Customer>>> list({
    String? search,
    CustomerTier? tier,
    int page = 1,
    int limit = 20,
  }) async {
    var filtered = List<Customer>.from(_customers);

    if (tier != null) {
      filtered = filtered.where((c) => c.tier == tier).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(q) ||
            (c.email?.toLowerCase().contains(q) ?? false) ||
            (c.phone?.toLowerCase().contains(q) ?? false) ||
            (c.city?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = filtered.length;
    final startIndex = (page - 1) * limit;
    final paginatedItems = startIndex >= total
        ? <Customer>[]
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
  Future<Result<Customer>> getById(String id) async {
    try {
      final customer = _customers.firstWhere((c) => c.id == id);
      return Success(customer);
    } catch (_) {
      return const Failure(AppError.notFound);
    }
  }

  @override
  Future<Result<Customer>> create(Customer customer) async {
    _customers.insert(0, customer);
    return Success(customer);
  }

  @override
  Future<Result<Customer>> update(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _customers[index] = customer.copyWith(updatedAt: DateTime.now());
    return Success(_customers[index]);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _customers.removeAt(index);
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    final totalSpentAll =
        _customers.fold<double>(0, (sum, c) => sum + c.totalSpent);
    final vipCount =
        _customers.where((c) => c.tier == CustomerTier.vip).length;
    return Success({
      'totalCustomers': _customers.length,
      'vipCustomers': vipCount,
      'totalSpentAll': totalSpentAll,
    });
  }
}
