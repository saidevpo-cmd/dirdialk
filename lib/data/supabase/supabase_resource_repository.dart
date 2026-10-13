import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/resource.dart';
import '../../domain/repositories/resource_repository.dart';
import 'supabase_mappers.dart';

class SupabaseResourceRepository implements ResourceRepository {
  @override
  Future<Result<PaginatedResult<Resource>>> list({
    String? search,
    ResourceType? type,
    String? folderId,
    int page = 1,
    int limit = 30,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('resources').select('*');
      if (type != null) query = query.eq('type', type.name);
      if (folderId != null && folderId.isNotEmpty) {
        query = query.eq('folder_id', folderId);
      }
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('name.ilike.%$q%,description.ilike.%$q%,category.ilike.%$q%');
      }
      final response = await query
          .order('updated_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<Resource>(
        items: response.data
            .map((r) => Db.resourceFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<Resource>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('resources')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.resourceFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Resource>> create(Resource resource) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('resources')
          .insert(Db.resource(resource))
          .select('*')
          .single();
      return Db.resourceFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Resource>> update(Resource resource) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('resources')
          .update(Db.resource(resource))
          .eq('id', resource.id)
          .select('*')
          .single();
      return Db.resourceFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('resources').delete().eq('id', id);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final rows =
          await AppSupabase.client.from('resources').select('type,storage_size');
      var totalBytes = 0;
      final byType = <String, int>{};
      for (final r in rows) {
        totalBytes += (r['storage_size'] as num?)?.toInt() ?? 0;
        final t = r['type']?.toString() ?? 'other';
        byType[t] = (byType[t] ?? 0) + 1;
      }
      return {
        'totalFiles': rows.length,
        'totalBytes': totalBytes,
        'documents': byType['document'] ?? 0,
        'spreadsheets': byType['spreadsheet'] ?? 0,
        'images': byType['image'] ?? 0,
      };
    });
  }
}