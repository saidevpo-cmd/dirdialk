import '../../domain/models/app_error.dart';
import '../../domain/models/location.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/location_repository.dart';

class MockLocationRepository implements LocationRepository {
  MockLocationRepository({List<Location>? initialData})
      : _locations = initialData != null
            ? List<Location>.from(initialData)
            : List<Location>.from(_seed());

  final List<Location> _locations;

  static List<Location> _seed() {
    final now = DateTime.now();
    return [
      Location(
        id: 'loc_main',
        name: 'Main Warehouse',
        type: LocationType.warehouse,
        address: '12 Industrial Avenue',
        city: 'Casablanca',
        country: 'Morocco',
        latitude: 33.5731,
        longitude: -7.5898,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Location(
        id: 'loc_store',
        name: 'Downtown Store',
        type: LocationType.store,
        address: '45 Hassan II Boulevard',
        city: 'Casablanca',
        country: 'Morocco',
        createdAt: now,
        updatedAt: now,
      ),
      Location(
        id: 'loc_hub',
        name: 'Coastal Hub',
        type: LocationType.shipping,
        address: 'Port Zone 3',
        city: 'Tangier',
        country: 'Morocco',
        latitude: 35.7595,
        longitude: -5.8340,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<Result<PaginatedResult<Location>>> list({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    var items = List<Location>.from(_locations);
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      items = items
          .where((l) =>
              l.name.toLowerCase().contains(q) ||
              (l.city?.toLowerCase().contains(q) ?? false) ||
              (l.address?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    items.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    final total = items.length;
    final paged = items.skip((page - 1) * limit).take(limit).toList();
    return Success(
      PaginatedResult(items: paged, total: total, page: page, limit: limit),
    );
  }

  @override
  Future<Result<List<Location>>> all() async => Success(List.unmodifiable(_locations));

  @override
  Future<Result<Location>> getById(String id) async {
    for (final l in _locations) {
      if (l.id == id) return Success(l);
    }
    return const Failure(AppError.notFound);
  }

  @override
  Future<Result<Location>> create(Location location) async {
    if (location.name.trim().isEmpty) {
      return const Failure(
        AppError(code: 'VALIDATION', message: 'Location name is required'),
      );
    }
    _locations.add(location);
    return Success(location);
  }

  @override
  Future<Result<Location>> update(Location location) async {
    final idx = _locations.indexWhere((l) => l.id == location.id);
    if (idx == -1) return const Failure(AppError.notFound);
    _locations[idx] = location;
    return Success(location);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _locations.removeWhere((l) => l.id == id);
    return const Success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> stats() async {
    final byType = <String, int>{};
    var defaults = 0;
    for (final l in _locations) {
      byType[l.type.name] = (byType[l.type.name] ?? 0) + 1;
      if (l.isDefault) defaults++;
    }
    return Success({
      'totalLocations': _locations.length,
      'defaultLocations': defaults,
      'byType': byType,
    });
  }
}