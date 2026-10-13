import '../models/app_error.dart';
import '../models/paginated_result.dart';
import '../models/template.dart';

abstract class TemplateRepository {
  Future<Result<PaginatedResult<Template>>> list({
    String? search,
    bool? featuredOnly,
    int page = 1,
    int limit = 50,
  });

  Future<Result<List<Template>>> all();

  Future<Result<Template>> getById(String id);

  Future<Result<Template>> getBySlug(String slug);

  Future<Result<Template>> create(Template template);

  Future<Result<Template>> update(Template template);

  Future<Result<void>> delete(String id);
}