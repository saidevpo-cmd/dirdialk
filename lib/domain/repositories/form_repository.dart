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

  /// Records a submission for a published form.
  ///
  /// The database owns the submission counter trigger and enforces the
  /// published-only insert policy, so callers must not mutate counters locally.
  Future<Result<void>> submit(String formId, Map<String, dynamic> payload);

  Future<Result<Map<String, dynamic>>> stats();
}
