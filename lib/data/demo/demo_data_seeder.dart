import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'demo_catalog.dart';

class DemoSeedResult {
  const DemoSeedResult({
    required this.categoriesAdded,
    required this.productsAdded,
    required this.productsSkipped,
  });

  final int categoriesAdded;
  final int productsAdded;
  final int productsSkipped;

  bool get addedAnything => categoriesAdded > 0 || productsAdded > 0;

  bool get alreadyLoaded => categoriesAdded == 0 && productsAdded == 0;
}

/// Repeat-safe demo data loader.
///
/// The seeder is idempotent: categories are matched by name (reusing any the
/// user already created) and products are matched by id. Running it twice adds
/// nothing the second time and never overwrites existing business data. It is
/// only invoked on an explicit user action — never during app startup.
class DemoDataSeeder {
  DemoDataSeeder({
    required this.categories,
    required this.products,
  });

  final CategoryRepository categories;
  final ProductRepository products;

  Future<DemoSeedResult> seed() async {
    final now = DateTime.now();

    final existingCategories = await categories.all();
    final byName = <String, Category>{};
    if (existingCategories is Success<List<Category>>) {
      for (final category in existingCategories.data) {
        byName[category.name.trim().toLowerCase()] = category;
      }
    }

    var categoriesAdded = 0;
    final resolved = <String, Category>{};
    for (final def in DemoCatalog.categories) {
      final key = def.name.toLowerCase();
      final existing = byName[key];
      if (existing != null) {
        resolved[def.name] = existing;
        continue;
      }
      final result = await categories.create(Category(
        id: 'demo-cat-${def.slug}',
        name: def.name,
        slug: def.slug,
        description: def.description,
        position: def.position,
        imageUrl: def.asset,
        isDemo: true,
        createdAt: now,
      ));
      if (result is Success<Category>) {
        resolved[def.name] = result.data;
        byName[key] = result.data;
        categoriesAdded++;
      }
    }

    final existingProducts = await products.list(limit: 100000);
    final existingIds = <String>{};
    if (existingProducts is Success<PaginatedResult<Product>>) {
      existingIds.addAll(existingProducts.data.items.map((p) => p.id));
    }

    var productsAdded = 0;
    var productsSkipped = 0;
    for (final def in DemoCatalog.products) {
      final category = resolved[def.categoryName];
      if (category == null || existingIds.contains(def.id)) {
        productsSkipped++;
        continue;
      }
      final result = await products.create(Product(
        id: def.id,
        name: def.name,
        description: def.description,
        sku: def.sku,
        categoryId: category.id,
        categoryName: category.name,
        price: def.price,
        costPrice: def.costPrice,
        stockQty: def.stockQty,
        imageUrl: def.mainImage,
        extraImages: def.extraImages,
        isDemo: true,
        status: ProductStatus.active,
        createdAt: now,
        updatedAt: now,
      ));
      if (result is Success<Product>) {
        productsAdded++;
      } else {
        productsSkipped++;
      }
    }

    return DemoSeedResult(
      categoriesAdded: categoriesAdded,
      productsAdded: productsAdded,
      productsSkipped: productsSkipped,
    );
  }
}
