import '../models/app_error.dart';
import '../models/paginated_result.dart';
import '../models/resource.dart';

abstract class ResourceRepository {
  Future<Result<PaginatedResult<Resource>>> list({
    String? search,
    ResourceType? type,
    String? folderId,
    int page = 1,
    int limit = 30,
  });

  Future<Result<Resource>> getById(String id);

  Future<Result<Resource>> create(Resource resource);

  Future<Result<Resource>> update(Resource resource);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();
}
