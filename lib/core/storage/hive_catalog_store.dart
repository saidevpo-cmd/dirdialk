import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'catalog_store.dart';

/// Hive-backed implementation of [CatalogStore]. Uses Hive strings for JSON,
/// never for binary image payloads.
class HiveCatalogStore implements CatalogStore {
  HiveCatalogStore._(this._box);

  final Box<String> _box;

  static const String boxName = 'catalog';

  static Future<CatalogStore> open() async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationSupportDirectory();
        Hive.init(directory.path);
      }
      final box = await Hive.openBox<String>(boxName);
      return HiveCatalogStore._(box);
    } catch (_) {
      return InMemoryCatalogStore();
    }
  }

  @override
  String? read(String key) => _box.get(key);

  @override
  Future<void> write(String key, String value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);
}
