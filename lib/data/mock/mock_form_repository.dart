import '../../domain/models/app_error.dart';
import '../../domain/models/form_definition.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/form_repository.dart';
import 'mock_seed_data.dart';

class MockFormRepository implements FormRepository {
  MockFormRepository({List<FormDefinition>? initialData})
      : _forms = initialData != null
            ? List<FormDefinition>.from(initialData)
            : List<FormDefinition>.from(MockSeedData.forms);

  final List<FormDefinition> _forms;

  @override
  Future<Result<PaginatedResult<FormDefinition>>> list({
    String? search,
    FormStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    var filtered = List<FormDefinition>.from(_forms);

    if (status != null) {
      filtered = filtered.where((f) => f.status == status).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((f) {
        return f.title.toLowerCase().contains(q) ||
            (f.description?.toLowerCase().contains(q) ?? false) ||
            f.slug.toLowerCase().contains(q);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = filtered.length;
    final startIndex = (page - 1) * limit;
    final paginatedItems = startIndex >= total
        ? <FormDefinition>[]
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
  Future<Result<FormDefinition>> getById(String id) async {
    try {
      final form = _forms.firstWhere((f) => f.id == id);
      return Success(form);
    } catch (_) {
      return const Failure(AppError.notFound);
    }
  }

  @override
  Future<Result<FormDefinition>> create(FormDefinition form) async {
    _forms.insert(0, form);
    return Success(form);
  }

  @override
  Future<Result<FormDefinition>> update(FormDefinition form) async {
    final index = _forms.indexWhere((f) => f.id == form.id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _forms[index] = form.copyWith(updatedAt: DateTime.now());
    return Success(_forms[index]);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final index = _forms.indexWhere((f) => f.id == id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _forms.removeAt(index);
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    final totalSubmissions =
        _forms.fold<int>(0, (sum, f) => sum + f.submissionsCount);
    final publishedCount =
        _forms.where((f) => f.status == FormStatus.published).length;
    return Success({
      'totalForms': _forms.length,
      'publishedForms': publishedCount,
      'totalSubmissions': totalSubmissions,
    });
  }
}
