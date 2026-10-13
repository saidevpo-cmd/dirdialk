import '../models/app_error.dart';
import '../models/customer.dart';
import '../models/paginated_result.dart';

abstract class CustomerRepository {
  Future<Result<PaginatedResult<Customer>>> list({
    String? search,
    CustomerTier? tier,
    int page = 1,
    int limit = 20,
  });

  Future<Result<Customer>> getById(String id);

  Future<Result<Customer>> create(Customer customer);

  Future<Result<Customer>> update(Customer customer);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();
}
