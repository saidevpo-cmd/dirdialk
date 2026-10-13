import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/page_content.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/page_repository.dart';
import 'supabase_mappers.dart';

class SupabasePageRepository implements PageRepository {
  static const _select = '*, category:page_categories(name)';

  @override
  Future<Result<PaginatedResult<PageContent>>> list({
    String? search,
    PageStatus? status,
    int page = 1,
    int limit = 20,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('pages').select(_select);
      if (status != null) query = query.eq('status', status.name);
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('title.ilike.%$q%,slug.ilike.%$q%');
      }
      final response = await query
          .order('updated_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<PageContent>(
        items: response.data
            .map((r) => Db.pageFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<PageContent>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('pages')
          .select(_select)
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.pageFrom(Map<String, dynamic>.from(data));
    });
  }

  Future<Result<PageContent>> getBySlug(String slug) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('pages')
          .select(_select)
          .eq('slug', slug)
          .eq('status', 'published')
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.pageFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<PageContent>> create(PageContent page) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('pages')
          .insert(Db.page(page))
          .select(_select)
          .single();
      return Db.pageFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<PageContent>> update(PageContent page) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('pages')
          .update(Db.page(page))
          .eq('id', page.id)
          .select(_select)
          .single();
      return Db.pageFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('pages').delete().eq('id', id);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final rows = await AppSupabase.client.from('pages').select('status');
      final published = rows.where((r) => r['status'] == 'published').length;
      return {
        'totalPages': rows.length,
        'publishedPages': published,
        'draftPages': rows.length - published,
      };
    });
  }
}