/// Minimal key/value abstraction for persisting catalog JSON locally.
///
/// Products and categories are stored as JSON strings; image binaries are kept
/// separately in the [ImageStore]. When no store is configured the repositories
/// behave exactly as before (in-memory seed data), which keeps unit tests fast
/// and deterministic.
abstract class CatalogStore {
  String? read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class InMemoryCatalogStore implements CatalogStore {
  InMemoryCatalogStore([Map<String, String>? seed]) : _data = {...?seed};

  final Map<String, String> _data;

  @override
  String? read(String key) => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}
