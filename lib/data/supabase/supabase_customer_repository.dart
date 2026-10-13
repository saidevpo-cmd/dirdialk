import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_result.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/customer_repository.dart';
import 'supabase_mappers.dart';

class SupabaseCustomerRepository implements CustomerRepository {
  @override
  Future<Result<PaginatedResult<Customer>>> list({
    String? search,
    CustomerTier? tier,
    int page = 1,
    int limit = 20,
  }) {
    return guard(() async {
      var query = AppSupabase.client.from('customers').select('*');
      if (tier != null) query = query.eq('tier', tier.name);
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('name.ilike.%$q%,email.ilike.%$q%,phone.ilike.%$q%');
      }
      final response = await query
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1)
          .count(CountOption.exact);
      return PaginatedResult<Customer>(
        items: response.data
            .map((r) => Db.customerFrom(Map<String, dynamic>.from(r)))
            .toList(),
        total: response.count,
        page: page,
        limit: limit,
      );
    });
  }

  @override
  Future<Result<Customer>> getById(String id) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('customers')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw AppError.notFound;
      return Db.customerFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Customer>> create(Customer customer) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('customers')
          .insert(Db.customer(customer))
          .select('*')
          .single();
      return Db.customerFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<Customer>> update(Customer customer) {
    return guard(() async {
      final data = await AppSupabase.client
          .from('customers')
          .update(Db.customer(customer))
          .eq('id', customer.id)
          .select('*')
          .single();
      return Db.customerFrom(Map<String, dynamic>.from(data));
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return guard(() async {
      await AppSupabase.client.from('customers').delete().eq('id', id);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() {
    return guard(() async {
      final totalRes = await AppSupabase.client
          .from('customers')
          .select('id')
          .count(CountOption.exact);
      final vipRes = await AppSupabase.client
          .from('customers')
          .select('id')
          .eq('tier', 'vip')
          .count(CountOption.exact);
      final spentRes = await AppSupabase.client
          .from('customers')
          .select('total_spent');
      final totalSpent = spentRes.fold<double>(
        0,
        (sum, r) => sum + ((r['total_spent'] as num?)?.toDouble() ?? 0),
      );
      return {
        'totalCustomers': totalRes.count,
        'vipCustomers': vipRes.count,
        'totalSpentAll': totalSpent,
      };
    });
  }
}