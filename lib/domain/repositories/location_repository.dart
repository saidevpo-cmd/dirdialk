import '../models/app_error.dart';
import '../models/location.dart';
import '../models/paginated_result.dart';

abstract class LocationRepository {
  Future<Result<PaginatedResult<Location>>> list({
    String? search,
    int page = 1,
    int limit = 50,
  });

  Future<Result<List<Location>>> all();

  Future<Result<Location>> getById(String id);

  Future<Result<Location>> create(Location location);

  Future<Result<Location>> update(Location location);

  Future<Result<void>> delete(String id);

  Future<Result<Map<String, dynamic>>> stats();
}