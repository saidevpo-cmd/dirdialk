import '../../core/supabase/storage_service.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/category_repository.dart';
import 'remote_images.dart';
import 'supabase_mappers.dart';

class SupabaseCategoryRepository implements CategoryRepository {
  SupabaseCategoryRepository({this.storage = const StorageService()});

  final StorageService storage;

  static const _select = '*, parent:categories!categories_parent_id_fkey(name)';

  @override
  Future<Result<PaginatedResult<Category>>> list({
    String? search,
    String? parentId,
    int page = 1,
    int limit = 50,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('categories').select(_select);
      // `parentId == null` means "no parent filter" (all categories), matching
      // MockCategoryRepository. Roots are not special-cased here because the
      // admin listing expects the full set.
      if (parentId != null) {
        query = query.eq('parent_id', parentId);
      }
      if (search != null && search.trim().isNotEmpty) {
        query = query.ilike('name', '%${search.trim()}%');
      }
      final response = await query
          .order('position')
          .order('name')
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<Category>(
        items: response.data
            .map((r) => Db.categoryFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<List<Category>>> all() {
    return guard(() async {
      final data = await AppSupabase.client
          .from('categories')
          .select('*')
          .order('position')
          .order('name');
      return data
          .map((r) => Db.categoryFrom(Map<String, dynamic>.from(r)))
          .toList();
    });
  }

  @override
  Future<Result<Category>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('categories')
          .select(_select)
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.categoryFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Category>> create(Category category) async {
    final prepared = await guard(
      () => uploadCategoryImage(
        category,
        (ref, bucket, folder) => storage.uploadLocalImage(
          localRef: ref,
          bucket: bucket,
          folder: folder,
        ),
      ),
    );
    if (prepared is Failure<Category>) return prepared;
    final remoteCategory = (prepared as Success<Category>).data;

    return guard(() async {
      final data = await AppSupabase.client
          .from('categories')
          .insert(Db.category(remoteCategory))
          .select('*')
          .single();
      return Db.categoryFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Category>> update(Category category) async {
    final prepared = await guard(
      () => uploadCategoryImage(
        category,
        (ref, bucket, folder) => storage.uploadLocalImage(
          localRef: ref,
          bucket: bucket,
          folder: folder,
        ),
      ),
    );
    if (prepared is Failure<Category>) return prepared;
    final remoteCategory = (prepared as Success<Category>).data;

    return guard(() async {
      final data = await AppSupabase.client
          .from('categories')
          .update(Db.category(remoteCategory))
          .eq('id', category.id)
          .select('*')
          .single();
      return Db.categoryFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('categories').delete().eq('id', id);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final totalRes = await AppSupabase.client
          .from('categories')
          .select('id')
          .count(CountOption.exact);
      final rootsRes = await AppSupabase.client
          .from('categories')
          .select('id')
          .isFilter('parent_id', null)
          .count(CountOption.exact);
      final total = totalRes.count;
      final roots = rootsRes.count;
      return {
        'totalCategories': total,
        'rootCategories': roots,
        'childCategories': total - roots,
      };
    });
  }
}
