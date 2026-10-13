import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/template.dart';
import '../../domain/repositories/template_repository.dart';
import 'supabase_mappers.dart';

class SupabaseTemplateRepository implements TemplateRepository {
  @override
  Future<Result<PaginatedResult<Template>>> list({
    String? search,
    bool? featuredOnly,
    int page = 1,
    int limit = 50,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('website_templates').select('*');
      if (featuredOnly == true) query = query.eq('is_featured', true);
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('name.ilike.%$q%,description.ilike.%$q%');
      }
      final response = await query
          .order('is_featured', ascending: false)
          .order('name')
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<Template>(
        items: response.data
            .map((r) => Db.templateFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<List<Template>>> all() {
    return guard(() async {
      final data = await AppSupabase.client
          .from('website_templates')
          .select('*')
          .order('is_featured', ascending: false)
          .order('name');
      return data
          .map((r) => Db.templateFrom(Map<String, dynamic>.from(r)))
          .toList();
    });
  }

  @override
  Future<Result<Template>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('website_templates')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.templateFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Template>> getBySlug(String slug) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('website_templates')
          .select('*')
          .eq('slug', slug)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.templateFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Template>> create(Template template) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('website_templates')
          .insert(Db.template(template))
          .select('*')
          .single();
      return Db.templateFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Template>> update(Template template) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('website_templates')
          .update(Db.template(template))
          .eq('id', template.id)
          .select('*')
          .single();
      return Db.templateFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('website_templates').delete().eq('id', id);
    });
  }
}