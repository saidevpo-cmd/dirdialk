import 'dart:typed_data';

/// Platform-agnostic abstraction over local binary image storage.
///
/// Images are never stored as plain text: implementations keep the raw bytes
/// so that large files do not bloat structured records. Only a compact
/// reference (see [ImageRef]) is written into product/category records.
abstract class ImageStore {
  /// Persists [bytes] and returns a generated, stable identifier.
  Future<String> save(Uint8List bytes, {String extension = 'png'});

  /// Returns the bytes for [id], or `null` when the file is missing.
  Future<Uint8List?> read(String id);

  /// Deletes the image for [id] if it exists.
  Future<void> delete(String id);

  /// Whether an image exists for [id].
  Future<bool> exists(String id);

  /// Removes every stored image. Used by "reset all" style flows.
  Future<void> clear();
}

/// Helpers for the `localimg://` reference scheme used in records.
class ImageRef {
  ImageRef._();

  static const String scheme = 'localimg://';

  static String forId(String id) => '$scheme$id';

  static bool isLocal(String? ref) => ref != null && ref.startsWith(scheme);

  static String? idOf(String? ref) =>
      isLocal(ref) ? ref!.substring(scheme.length) : null;
}

/// Non-persistent fallback used when the platform store cannot be opened or
/// in tests. Keeps the same contract as the Hive-backed store.
class InMemoryImageStore implements ImageStore {
  final Map<String, Uint8List> _images = {};

  int _counter = 0;

  @override
  Future<String> save(Uint8List bytes, {String extension = 'png'}) async {
    final id = 'img_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
    _images[id] = Uint8List.fromList(bytes);
    return id;
  }

  @override
  Future<Uint8List?> read(String id) async => _images[id];

  @override
  Future<void> delete(String id) async => _images.remove(id);

  @override
  Future<bool> exists(String id) async => _images.containsKey(id);

  @override
  Future<void> clear() async => _images.clear();
}
