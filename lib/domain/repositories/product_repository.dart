import '../models/app_error.dart';
import '../models/category.dart';
import '../models/paginated_result.dart';
import '../models/product.dart';

abstract class ProductRepository {
  Future<Result<PaginatedResult<Product>>> list({
    String? search,
    ProductStatus? status,
    String? categoryId,
    int page = 1,
    int limit = 20,
  });

  Future<Result<Product>> getById(String id);

  Future<Result<Product>> create(Product product);

  Future<Result<Product>> update(Product product);

  Future<Result<void>> delete(String id);

  Future<Result<List<Category>>> categories();

  Future<Result<Map<String, dynamic>>> stats();
}
