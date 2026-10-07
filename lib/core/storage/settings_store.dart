abstract class SettingsStore {
  String? read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([Map<String, String>? seed]) : _data = {...?seed};

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
