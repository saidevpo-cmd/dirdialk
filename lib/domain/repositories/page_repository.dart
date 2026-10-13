import '../models/app_error.dart';
import '../models/page_content.dart';
import '../models/paginated_result.dart';

abstract class PageRepository {
  Future<Result<PaginatedResult<PageContent>>> list({
    String? search,
    PageStatus? status,
    int page = 1,
    int limit = 20,
  });

  Future<Result<PageContent>> getById(String id);

  Future<Result<PageContent>> create(PageContent page);

  Future<Result<PageContent>> update(PageContent page);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();
}
