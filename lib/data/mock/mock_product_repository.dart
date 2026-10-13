import 'dart:convert';

import '../../core/storage/catalog_store.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'mock_category_repository.dart';
import 'mock_seed_data.dart';

class MockProductRepository implements ProductRepository {
  MockProductRepository({
    CategoryRepository? categoryRepository,
    CatalogStore? store,
    List<Product>? seedData,
  })  : _categoryRepository =
            categoryRepository ?? MockCategoryRepository(),
        _store = store,
        _seedData = seedData ?? MockSeedData.products {
    if (store == null) {
      _products = List<Product>.from(_seedData);
      _loaded = true;
    }
  }

  static const String _storageKey = 'products.v1';

  final CategoryRepository _categoryRepository;
  final CatalogStore? _store;
  final List<Product> _seedData;

  List<Product> _products = <Product>[];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final raw = _store?.read(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _products = decoded
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();
        return;
      } catch (_) {
        // Fall through to seeding on corrupt data.
      }
    }
    _products = List<Product>.from(_seedData);
    await _persist();
  }

  Future<void> _persist() async {
    await _store?.write(
      _storageKey,
      jsonEncode(_products.map((p) => p.toMap()).toList()),
    );
  }

  @override
  Future<Result<PaginatedResult<Product>>> list({
    String? search,
    ProductStatus? status,
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    await _ensureLoaded();
    var items = _products.where((p) {
      if (status != null && p.status != status) return false;
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !(p.sku?.toLowerCase().contains(q) ?? false) &&
            !(p.categoryName?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final total = items.length;
    final offset = (page - 1) * limit;
    final paged = items.skip(offset).take(limit).toList();

    return Success(PaginatedResult(
      items: paged,
      total: total,
      page: page,
      limit: limit,
    ));
  }

  @override
  Future<Result<Product>> getById(String id) async {
    await _ensureLoaded();
    final p = _products.where((p) => p.id == id).firstOrNull;
    if (p == null) return const Failure(AppError.notFound);
    return Success(p);
  }

  @override
  Future<Result<Product>> create(Product product) async {
    await _ensureLoaded();
    _products.insert(0, product);
    await _persist();
    return Success(product);
  }

  @override
  Future<Result<Product>> update(Product product) async {
    await _ensureLoaded();
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx == -1) return const Failure(AppError.notFound);
    _products[idx] = product;
    await _persist();
    return Success(product);
  }

  @override
  Future<Result<void>> delete(String id) async {
    await _ensureLoaded();
    _products.removeWhere((p) => p.id == id);
    await _persist();
    return const Success(null);
  }

  @override
  Future<Result<List<Category>>> categories() async {
    final res = await _categoryRepository.all();
    return switch (res) {
      Success(:final data) => Success(data),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    await _ensureLoaded();
    final byCategory = <String, int>{};
    for (final p in _products) {
      final key = p.categoryName ?? 'Uncategorized';
      byCategory[key] = (byCategory[key] ?? 0) + 1;
    }
    final categoriesRes = await _categoryRepository.stats();
    final totalCategories = switch (categoriesRes) {
      Success(:final data) => (data['totalCategories'] as int?) ?? 0,
      Failure() => 0,
    };
    final total = _products.length;
    final active = _products.where((p) => p.status == ProductStatus.active).length;
    final lowStock = _products.where((p) => p.isLowStock).length;
    final outOfStock = _products.where((p) => p.isOutOfStock).length;
    final inventoryValue = _products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stockQty),
    );
    return Success({
      'totalProducts': total,
      'activeProducts': active,
      'lowStockProducts': lowStock,
      'outOfStockProducts': outOfStock,
      'totalCategories': totalCategories,
      'inventoryValue': inventoryValue,
      'byCategory': byCategory,
    });
  }
}
