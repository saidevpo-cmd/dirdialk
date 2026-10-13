import 'dart:convert';

import '../../core/storage/catalog_store.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/category_repository.dart';
import 'mock_seed_data.dart';

/// In-memory category store, optionally persisted through a [CatalogStore].
///
/// It is the single source of truth for categories shared with
/// [MockProductRepository] so product and category screens never diverge.
///
/// When [store] is `null` (unit tests, previews) the repository keeps the
/// original behaviour and works purely from the seed data in memory.
class MockCategoryRepository implements CategoryRepository {
  MockCategoryRepository({
    List<Category>? initialData,
    CatalogStore? store,
    List<Category>? seedData,
  })  : _store = store,
        _seedData = seedData ?? MockSeedData.categories {
    if (initialData != null) {
      _categories = List<Category>.from(initialData);
      _loaded = true;
    } else if (store == null) {
      _categories = List<Category>.from(_seedData);
      _loaded = true;
    }
  }

  static const String _storageKey = 'categories.v1';

  final CatalogStore? _store;
  final List<Category> _seedData;

  List<Category> _categories = <Category>[];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final raw = _store?.read(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _categories = decoded
            .map((e) => Category.fromMap(e as Map<String, dynamic>))
            .toList();
        return;
      } catch (_) {
        // Fall through to seeding on corrupt data.
      }
    }
    _categories = List<Category>.from(_seedData);
    await _persist();
  }

  Future<void> _persist() async {
    await _store?.write(
      _storageKey,
      jsonEncode(_categories.map((c) => c.toMap()).toList()),
    );
  }

  @override
  Future<Result<PaginatedResult<Category>>> list({
    String? search,
    String? parentId,
    int page = 1,
    int limit = 50,
  }) async {
    await _ensureLoaded();
    var filtered = List<Category>.from(_categories);

    if (parentId != null) {
      filtered = filtered.where((c) => c.parentId == parentId).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.slug.toLowerCase().contains(q) ||
            (c.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    filtered.sort((a, b) {
      final byPosition = a.position.compareTo(b.position);
      return byPosition != 0 ? byPosition : a.name.compareTo(b.name);
    });

    final total = filtered.length;
    final startIndex = (page - 1) * limit;
    final paginatedItems = startIndex >= total
        ? <Category>[]
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
  Future<Result<List<Category>>> all() async {
    await _ensureLoaded();
    return Success(List<Category>.unmodifiable(_categories));
  }

  @override
  Future<Result<Category>> getById(String id) async {
    await _ensureLoaded();
    final match = _categories.where((c) => c.id == id).firstOrNull;
    if (match == null) return const Failure(AppError.notFound);
    return Success(match);
  }

  @override
  Future<Result<Category>> create(Category category) async {
    await _ensureLoaded();
    final name = category.name.trim();
    if (name.isEmpty) {
      return const Failure(
        AppError(code: 'VALIDATION', message: 'Category name is required'),
      );
    }
    if (_hasName(name)) {
      return const Failure(
        AppError(
          code: 'CONFLICT',
          message: 'A category with this name already exists',
        ),
      );
    }
    _categories.insert(0, category.copyWith(name: name));
    await _persist();
    return Success(_categories.first);
  }

  @override
  Future<Result<Category>> update(Category category) async {
    await _ensureLoaded();
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index == -1) return const Failure(AppError.notFound);

    final name = category.name.trim();
    if (name.isEmpty) {
      return const Failure(
        AppError(code: 'VALIDATION', message: 'Category name is required'),
      );
    }
    if (_hasName(name, ignoreId: category.id)) {
      return const Failure(
        AppError(
          code: 'CONFLICT',
          message: 'A category with this name already exists',
        ),
      );
    }

    _categories[index] = category.copyWith(name: name);
    await _persist();
    return Success(_categories[index]);
  }

  @override
  Future<Result<void>> delete(String id) async {
    await _ensureLoaded();
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return const Failure(AppError.notFound);
    _categories.removeAt(index);
    await _persist();
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    await _ensureLoaded();
    final roots = _categories.where((c) => c.parentId == null).length;
    return Success({
      'totalCategories': _categories.length,
      'rootCategories': roots,
      'childCategories': _categories.length - roots,
    });
  }

  bool _hasName(String name, {String? ignoreId}) {
    final normalized = name.trim().toLowerCase();
    return _categories.any(
      (c) => c.id != ignoreId && c.name.toLowerCase() == normalized,
    );
  }
}
