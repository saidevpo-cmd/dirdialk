import '../models/app_error.dart';
import '../models/form_definition.dart';
import '../models/paginated_result.dart';

abstract class FormRepository {
  Future<Result<PaginatedResult<FormDefinition>>> list({
    String? search,
    FormStatus? status,
    int page = 1,
    int limit = 20,
  });

  Future<Result<FormDefinition>> getById(String id);

  Future<Result<FormDefinition>> create(FormDefinition form);

  Future<Result<FormDefinition>> update(FormDefinition form);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();
}
