import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'supabase_mappers.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository({this._categoryRepository});

  final CategoryRepository? _categoryRepository;

  static const _select = '*, category:categories(name), location:locations(name)';

  @override
  Future<Result<PaginatedResult<Product>>> list({
    String? search,
    ProductStatus? status,
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('products').select(_select);
      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('name.ilike.%$q%,sku.ilike.%$q%');
      }
      final response = await query
          .order('updated_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);

      return PaginatedResult<Product>(
        items: response.data
            .map((r) => Db.productFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<Product>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('products')
          .select(_select)
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.productFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Product>> create(Product product) async {
    final insert = await guard(() async {
      final data = await AppSupabase.client
          .from('products')
          .insert(Db.product(product))
          .select(_select)
          .single();
      return Db.productFrom(Map<String, dynamic>.from(data));
    });
    if (insert is Failure) return insert;
    final id = (insert as Success<Product>).data.id;
    final res = await getById(id);
    return switch (res) {
      Success(:final data) => Success(data),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<Product>> update(Product product) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('products')
          .update(Db.product(product))
          .eq('id', product.id)
          .select(_select)
          .single();
      return Db.productFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('products').delete().eq('id', id);
    });
  }

  @override
  Future<Result<List<Category>>> categories() {
    final repo = _categoryRepository;
    if (repo == null) return Future.value(const Success(<Category>[]));
    return repo.all();
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final rows = await AppSupabase.client
          .from('products')
          .select(
            'id,status,price,stock_qty,low_stock_threshold,category_id,category:categories(name)',
          );
      final products = rows
          .map((r) => Db.productFrom(Map<String, dynamic>.from(r)))
          .toList();

      final byCategory = <String, int>{};
      for (final p in products) {
        final key = p.categoryName ?? 'Uncategorized';
        byCategory[key] = (byCategory[key] ?? 0) + 1;
      }

      final totalCategoriesRes = _categoryRepository?.stats();
      var totalCategories = 0;
      if (totalCategoriesRes != null) {
        switch (await totalCategoriesRes) {
          case Success(:final data):
            totalCategories = (data['totalCategories'] as int?) ?? 0;
          case Failure():
            break;
        }
      }

      final active = products.where((p) => p.status == ProductStatus.active).length;
      final lowStock = products.where((p) => p.isLowStock).length;
      final outOfStock = products.where((p) => p.isOutOfStock).length;
      final inventoryValue =
          products.fold<double>(0, (sum, p) => sum + (p.price * p.stockQty));

      return {
        'totalProducts': products.length,
        'activeProducts': active,
        'lowStockProducts': lowStock,
        'outOfStockProducts': outOfStock,
        'totalCategories': totalCategories,
        'inventoryValue': inventoryValue,
        'byCategory': byCategory,
      };
    });
  }
}