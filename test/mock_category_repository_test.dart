import 'package:diali/data/mock/mock_category_repository.dart';
import 'package:diali/domain/models/app_error.dart';
import 'package:diali/domain/models/category.dart';
import 'package:diali/domain/models/paginated_result.dart';
import 'package:flutter_test/flutter_test.dart';

Category buildCategory(String id, String name, {String? parentId}) => Category(
      id: id,
      name: name,
      slug: name.toLowerCase().replaceAll(' ', '-'),
      parentId: parentId,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('MockCategoryRepository', () {
    test('create adds a category and makes it visible through list', () async {
      final repo = MockCategoryRepository(initialData: const []);
      final created = await repo.create(buildCategory('c1', 'Fresh Category'));

      expect(created, isA<Success<Category>>());
      final result = await repo.list();
      expect(result, isA<Success<PaginatedResult<Category>>>());
      expect((result as Success).data.items.single.name, 'Fresh Category');
    });

    test('list filters by search term', () async {
      final repo = MockCategoryRepository(initialData: [
        buildCategory('a', 'Electronics'),
        buildCategory('b', 'Clothing'),
      ]);
      final result = await repo.list(search: 'elec');
      expect(result, isA<Success<PaginatedResult<Category>>>());
      final items = (result as Success).data.items;
      expect(items.length, 1);
      expect(items.single.id, 'a');
    });

    test('create rejects an empty name with VALIDATION', () async {
      final repo = MockCategoryRepository(initialData: const []);
      final result = await repo.create(buildCategory('c1', '  '));
      expect(result, isA<Failure<Category>>());
      final failure = result as Failure<Category>;
      expect(failure.error.code, 'VALIDATION');
    });

    test('create rejects a duplicate name with CONFLICT', () async {
      final repo = MockCategoryRepository(initialData: [
        buildCategory('a', 'Electronics'),
      ]);
      final result = await repo.create(buildCategory('b', 'electronics'));
      expect(result, isA<Failure<Category>>());
      expect((result as Failure).error.code, 'CONFLICT');
    });

    test('update renames a category and allows unchanged names', () async {
      final repo = MockCategoryRepository(initialData: [
        buildCategory('a', 'Electronics'),
      ]);
      final updated = await repo.update(
        buildCategory('a', 'Computers'),
      );
      expect(updated, isA<Success<Category>>());
      expect((updated as Success).data.name, 'Computers');

      final sameName = await repo.update(buildCategory('a', 'Computers'));
      expect(sameName, isA<Success<Category>>());
    });

    test('update returns notFound for missing category', () async {
      final repo = MockCategoryRepository(initialData: const []);
      final result = await repo.update(buildCategory('ghost', 'Ghost'));
      expect(result, isA<Failure<Category>>());
      expect((result as Failure).error.code, AppError.notFound.code);
    });

    test('delete removes the category', () async {
      final repo = MockCategoryRepository(initialData: [
        buildCategory('a', 'Electronics'),
      ]);
      final deleted = await repo.delete('a');
      expect(deleted, isA<Success<void>>());
      final result = await repo.list();
      expect((result as Success).data.items, isEmpty);
    });

    test('stats counts roots and children', () async {
      final repo = MockCategoryRepository(initialData: [
        buildCategory('a', 'Root A'),
        buildCategory('b', 'Root B'),
        buildCategory('c', 'Child C', parentId: 'a'),
        buildCategory('d', 'Child D', parentId: 'a'),
      ]);
      final stats = await repo.stats();
      final data = (stats as Success).data;
      expect(data['totalCategories'], 4);
      expect(data['rootCategories'], 2);
      expect(data['childCategories'], 2);
    });
  });
}