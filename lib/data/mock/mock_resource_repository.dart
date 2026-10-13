import '../../domain/models/app_error.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/resource.dart';
import '../../domain/repositories/resource_repository.dart';
import 'mock_seed_data.dart';

class MockResourceRepository implements ResourceRepository {
  MockResourceRepository({List<Resource>? initialData})
      : _resources = initialData != null
            ? List<Resource>.from(initialData)
            : List<Resource>.from(MockSeedData.resources);

  final List<Resource> _resources;

  @override
  Future<Result<PaginatedResult<Resource>>> list({
    String? search,
    ResourceType? type,
    String? folderId,
    int page = 1,
    int limit = 30,
  }) async {
    var filtered = List<Resource>.from(_resources);

    if (type != null) {
      filtered = filtered.where((r) => r.type == type).toList();
    }

    if (folderId != null) {
      filtered = filtered.where((r) => r.folderId == folderId).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((r) {
        return r.name.toLowerCase().contains(q) ||
            (r.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = filtered.length;
    final startIndex = (page - 1) * limit;
    final paginatedItems = startIndex >= total
        ? <Resource>[]
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
  Future<Result<Resource>> getById(String id) async {
    try {
      final resource = _resources.firstWhere((r) => r.id == id);
      return Success(resource);
    } catch (_) {
      return const Failure(AppError.notFound);
    }
  }

  @override
  Future<Result<Resource>> create(Resource resource) async {
    _resources.insert(0, resource);
    return Success(resource);
  }

  @override
  Future<Result<Resource>> update(Resource resource) async {
    final index = _resources.indexWhere((r) => r.id == resource.id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _resources[index] = resource.copyWith(updatedAt: DateTime.now());
    return Success(_resources[index]);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _resources.removeAt(index);
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    final totalBytes = _resources.fold<int>(
        0, (sum, r) => sum + (r.storageSize ?? 0));
    return Success({
      'totalFiles': _resources.length,
      'totalBytes': totalBytes,
      'documents': _resources.where((r) => r.type == ResourceType.document).length,
      'spreadsheets': _resources.where((r) => r.type == ResourceType.spreadsheet).length,
      'images': _resources.where((r) => r.type == ResourceType.image).length,
    });
  }
}
