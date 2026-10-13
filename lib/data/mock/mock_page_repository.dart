import '../../domain/models/app_error.dart';
import '../../domain/models/page_content.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/page_repository.dart';
import 'mock_seed_data.dart';

class MockPageRepository implements PageRepository {
  MockPageRepository({List<PageContent>? initialData})
      : _pages = initialData != null
            ? List<PageContent>.from(initialData)
            : List<PageContent>.from(MockSeedData.pages);

  final List<PageContent> _pages;

  @override
  Future<Result<PaginatedResult<PageContent>>> list({
    String? search,
    PageStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    var filtered = List<PageContent>.from(_pages);

    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.slug.toLowerCase().contains(q) ||
            (p.content?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = filtered.length;
    final startIndex = (page - 1) * limit;
    final paginatedItems = startIndex >= total
        ? <PageContent>[]
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
  Future<Result<PageContent>> getById(String id) async {
    try {
      final page = _pages.firstWhere((p) => p.id == id);
      return Success(page);
    } catch (_) {
      return const Failure(AppError.notFound);
    }
  }

  @override
  Future<Result<PageContent>> create(PageContent page) async {
    _pages.insert(0, page);
    return Success(page);
  }

  @override
  Future<Result<PageContent>> update(PageContent page) async {
    final index = _pages.indexWhere((p) => p.id == page.id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _pages[index] = page.copyWith(updatedAt: DateTime.now());
    return Success(_pages[index]);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final index = _pages.indexWhere((p) => p.id == id);
    if (index == -1) {
      return const Failure(AppError.notFound);
    }
    _pages.removeAt(index);
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    final publishedCount =
        _pages.where((p) => p.status == PageStatus.published).length;
    return Success({
      'totalPages': _pages.length,
      'publishedPages': publishedCount,
      'draftPages': _pages.length - publishedCount,
    });
  }
}
