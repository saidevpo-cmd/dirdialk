import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../images/app_images.dart';
import '../images/image_store.dart';
import 'supabase_client.dart';

/// File uploads to Supabase Storage.
///
/// - validates size before uploading
/// - generates safe, unique object names
/// - returns a public URL for public buckets
class StorageService {
  const StorageService();

  static const int maxImageBytes = 10 * 1024 * 1024;

  /// Uploads raw bytes; returns the storage object path.
  Future<String> uploadBytes({
    required String bucket,
    required String folder,
    required Uint8List bytes,
    required String contentType,
    String? extension,
    bool upsert = false,
  }) async {
    if (bytes.isEmpty) {
      throw const StorageException('The selected file is empty.');
    }
    if (bytes.length > maxImageBytes) {
      throw const StorageException('File is larger than the 10 MB limit.');
    }
    final path = buildPath(folder: folder, bytes: bytes, extension: extension);
    await AppSupabase.client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: upsert),
        );
    return path;
  }

  /// Uploads an image referenced by a local `localimg://<id>` ref (or raw
  /// bytes) to a public bucket and returns its public URL.
  Future<String> uploadLocalImage({
    required String localRef,
    required String bucket,
    required String folder,
  }) async {
    final bytes = await _readBytes(localRef);
    if (bytes == null) {
      throw const StorageException('Image data is no longer available.');
    }
    final contentType = detectContentType(bytes);
    final path = await uploadBytes(
      bucket: bucket,
      folder: folder,
      bytes: bytes,
      contentType: contentType,
      extension: extensionForContentType(contentType),
    );
    return AppSupabase.client.storage.from(bucket).getPublicUrl(path);
  }

  Future<Uint8List?> _readBytes(String ref) async {
    final id = ImageRef.idOf(ref);
    if (id == null) return null;
    return AppImages.instance.read(id);
  }

  /// `folder/<timestamp>_<random>.<ext>` — no user-controlled characters.
  static String buildPath({
    required String folder,
    required Uint8List bytes,
    String? extension,
  }) {
    final ext = extension ?? extensionForContentType(detectContentType(bytes));
    final rand = Random().nextInt(1 << 32).toRadixString(16);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final safeFolder = folder.replaceAll(RegExp(r'[^a-zA-Z0-9/_-]'), '_');
    return '$safeFolder/${stamp}_$rand.$ext';
  }

  static String detectContentType(Uint8List b) {
    if (b.length >= 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47) {
      return 'image/png';
    }
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (b.length >= 12 &&
        b[8] == 0x57 &&
        b[9] == 0x45 &&
        b[10] == 0x42 &&
        b[11] == 0x50) {
      return 'image/webp';
    }
    if (b.length >= 6 &&
        b[0] == 0x47 &&
        b[1] == 0x49 &&
        b[2] == 0x46) {
      return 'image/gif';
    }
    return 'application/octet-stream';
  }

  static String extensionForContentType(String contentType) {
    switch (contentType) {
      case 'image/png':
        return 'png';
      case 'image/jpeg':
        return 'jpg';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      case 'image/svg+xml':
        return 'svg';
      default:
        return 'bin';
    }
  }
}
