import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'image_store.dart';

/// Hive-backed binary image store.
///
/// This is the local, platform-appropriate strategy used by the app:
/// * On Android/iOS/desktop Hive keeps the bytes in the application support
///   directory managed by `path_provider`.
/// * On Flutter Web Hive transparently uses IndexedDB.
///
/// Either way the bytes never leave the device and are not plain text in a
/// settings box.
class HiveImageStore implements ImageStore {
  HiveImageStore._(this._box);

  final Box<Uint8List> _box;

  static const String boxName = 'product_images';

  static Future<ImageStore> open() async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationSupportDirectory();
        Hive.init(directory.path);
      }
      final box = await Hive.openBox<Uint8List>(boxName);
      return HiveImageStore._(box);
    } catch (_) {
      return InMemoryImageStore();
    }
  }

  @override
  Future<String> save(Uint8List bytes, {String extension = 'png'}) async {
    final id = 'img_${DateTime.now().microsecondsSinceEpoch}_${_box.length}';
    await _box.put(id, Uint8List.fromList(bytes));
    return id;
  }

  @override
  Future<Uint8List?> read(String id) async => _box.get(id);

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Future<bool> exists(String id) async => _box.containsKey(id);

  @override
  Future<void> clear() async => _box.clear();
}
