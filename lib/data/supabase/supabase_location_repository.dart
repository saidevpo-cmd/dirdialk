import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/location.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/location_repository.dart';
import 'supabase_mappers.dart';

class SupabaseLocationRepository implements LocationRepository {
  @override
  Future<Result<PaginatedResult<Location>>> list({
    String? search,
    int page = 1,
    int limit = 50,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('locations').select('*');
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('name.ilike.%$q%,city.ilike.%$q%,address.ilike.%$q%');
      }
      final response = await query
          .order('is_default', ascending: false)
          .order('name')
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<Location>(
        items: response.data
            .map((r) => Db.locationFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<List<Location>>> all() {
    return guard(() async {
      final data = await AppSupabase.client
          .from('locations')
          .select('*')
          .order('is_default', ascending: false)
          .order('name');
      return data
          .map((r) => Db.locationFrom(Map<String, dynamic>.from(r)))
          .toList();
    });
  }

  @override
  Future<Result<Location>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('locations')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.locationFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Location>> create(Location location) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('locations')
          .insert(Db.location(location))
          .select('*')
          .single();
      return Db.locationFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Location>> update(Location location) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('locations')
          .update(Db.location(location))
          .eq('id', location.id)
          .select('*')
          .single();
      return Db.locationFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('locations').delete().eq('id', id);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final rows = await AppSupabase.client.from('locations').select('type,is_default');
      final byType = <String, int>{};
      var defaults = 0;
      for (final r in rows) {
        final t = r['type']?.toString() ?? 'other';
        byType[t] = (byType[t] ?? 0) + 1;
        if (r['is_default'] == true) defaults++;
      }
      return {
        'totalLocations': rows.length,
        'defaultLocations': defaults,
        'byType': byType,
      };
    });
  }
}