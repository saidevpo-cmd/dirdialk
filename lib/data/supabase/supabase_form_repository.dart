import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/form_definition.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/form_repository.dart';
import 'supabase_mappers.dart';

class SupabaseFormRepository implements FormRepository {
  @override
  Future<Result<PaginatedResult<FormDefinition>>> list({
    String? search,
    FormStatus? status,
    int page = 1,
    int limit = 20,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('form_definitions').select('*');
      if (status != null) query = query.eq('status', status.name);
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('title.ilike.%$q%,slug.ilike.%$q%');
      }
      final response = await query
          .order('updated_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<FormDefinition>(
        items: response.data
            .map((r) => Db.formFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<FormDefinition>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('form_definitions')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.formFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<FormDefinition>> create(FormDefinition form) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('form_definitions')
          .insert(Db.form(form))
          .select('*')
          .single();
      return Db.formFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<FormDefinition>> update(FormDefinition form) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('form_definitions')
          .update(Db.form(form))
          .eq('id', form.id)
          .select('*')
          .single();
      return Db.formFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('form_definitions').delete().eq('id', id);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final rows = await AppSupabase.client
          .from('form_definitions')
          .select('status,submissions_count');
      var published = 0;
      var submissions = 0;
      for (final r in rows) {
        if (r['status'] == 'published') published++;
        submissions += (r['submissions_count'] as num?)?.toInt() ?? 0;
      }
      return {
        'totalForms': rows.length,
        'publishedForms': published,
        'totalSubmissions': submissions,
      };
    });
  }
}