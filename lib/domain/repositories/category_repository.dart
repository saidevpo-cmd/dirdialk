import '../models/app_error.dart';
import '../models/category.dart';
import '../models/paginated_result.dart';

abstract class CategoryRepository {
  Future<Result<PaginatedResult<Category>>> list({
    String? search,
    String? parentId,
    int page = 1,
    int limit = 50,
  });

  Future<Result<List<Category>>> all();

  Future<Result<Category>> getById(String id);

  Future<Result<Category>> create(Category category);

  Future<Result<Category>> update(Category category);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();
}
