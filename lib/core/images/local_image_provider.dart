import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'image_store.dart';

/// [ImageProvider] that decodes images persisted in a local [ImageStore].
///
/// Going through an [ImageProvider] lets Flutter's global image cache and
/// lifecycle handle decoding/eviction, exactly like `AssetImage` or
/// `NetworkImage`. Missing bytes surface as a load error so callers can render
/// the shared placeholder via `errorBuilder`.
class LocalImageProvider extends ImageProvider<LocalImageProvider> {
  const LocalImageProvider(this.id, this.store);

  final String id;
  final ImageStore store;

  @override
  Future<LocalImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<LocalImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    LocalImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: 1.0,
      debugLabel: 'LocalImageProvider($id)',
    );
  }

  Future<ui.Codec> _load(
    LocalImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    final bytes = await store.read(key.id);
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Image "$id" is not available locally');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalImageProvider && other.id == id && other.store == store;

  @override
  int get hashCode => Object.hash(id, store);
}
