import 'package:diali/data/demo/demo_catalog.dart';
import 'package:diali/data/demo/demo_data_seeder.dart';
import 'package:diali/data/mock/mock_category_repository.dart';
import 'package:diali/data/mock/mock_product_repository.dart';
import 'package:diali/domain/models/app_error.dart';
import 'package:diali/domain/models/category.dart';
import 'package:diali/domain/models/paginated_result.dart';
import 'package:diali/domain/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockCategoryRepository categories;
  late MockProductRepository products;
  late DemoDataSeeder seeder;

  setUp(() {
    categories = MockCategoryRepository(initialData: const []);
    products = MockProductRepository(
      categoryRepository: categories,
      seedData: const [],
    );
    seeder = DemoDataSeeder(categories: categories, products: products);
  });

  test('first run adds every demo category and product', () async {
    final result = await seeder.seed();

    expect(result.categoriesAdded, DemoCatalog.categories.length);
    expect(result.productsAdded, DemoCatalog.products.length);
    expect(result.productsSkipped, 0);
    expect(result.addedAnything, isTrue);
    expect(result.alreadyLoaded, isFalse);
  });

  test('second run is idempotent and adds nothing', () async {
    await seeder.seed();

    final second = await seeder.seed();
    expect(second.categoriesAdded, 0);
    expect(second.productsAdded, 0);
    expect(second.alreadyLoaded, isTrue);

    final listRes = await products.list(limit: 100000);
    expect(listRes, isA<Success<PaginatedResult<Product>>>());
    expect((listRes as Success).data.total, DemoCatalog.products.length);
  });

  test('reuses an existing category with the same name', () async {
    final existing = await categories.create(
      Category(
        id: 'existing-clothing',
        name: 'Clothing',
        slug: 'clothing',
        createdAt: DateTime(2026),
      ),
    );
    expect(existing, isA<Success<Category>>());

    final result = await seeder.seed();
    expect(
      result.categoriesAdded,
      DemoCatalog.categories.length - 1,
    );

    final all = await categories.all();
    expect(all, isA<Success<List<Category>>>());
    final clothingIds =
        (all as Success).data.where((c) => c.name == 'Clothing').length;
    expect(clothingIds, 1);
  });

  test('seeded products link to the resolved category', () async {
    await seeder.seed();

    final productsRes = await products.list(limit: 100000);
    expect(productsRes, isA<Success<PaginatedResult<Product>>>());
    final items = (productsRes as Success).data.items as List<Product>;

    final shirt = items.firstWhere((p) => p.name.contains('Shirt'));
    expect(shirt.categoryName, isNotNull);

    final categoryRes = await categories.getById(shirt.categoryId!);
    expect(categoryRes, isA<Success<Category>>());
    final resolved = (categoryRes as Success).data;
    expect(resolved.name, shirt.categoryName);
  });
}