import 'image_store.dart';

/// Process-wide access point for the active [ImageStore].
///
/// `main()` configures the persistent Hive store before the first frame. Tests
/// and widget previews fall back to the in-memory store automatically.
class AppImages {
  AppImages._();

  static ImageStore _store = InMemoryImageStore();

  static ImageStore get instance => _store;

  static void configure(ImageStore store) {
    _store = store;
  }

  /// Restores the default in-memory store. Intended for tests.
  static void reset() {
    _store = InMemoryImageStore();
  }
}
