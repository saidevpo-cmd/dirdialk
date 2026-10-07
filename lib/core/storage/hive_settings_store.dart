import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'settings_store.dart';

class HiveSettingsStore implements SettingsStore {
  HiveSettingsStore._(this._box);

  final Box<String> _box;

  static Future<SettingsStore> open() async {
    try {
      final directory = await getApplicationSupportDirectory();
      return await openAt(directory.path);
    } catch (_) {
      return InMemorySettingsStore();
    }
  }

  static Future<SettingsStore> openAt(String path) async {
    Hive.init(path);
    final box = await Hive.openBox<String>('settings');
    return HiveSettingsStore._(box);
  }

  @override
  String? read(String key) => _box.get(key);

  @override
  Future<void> write(String key, String value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);
}
