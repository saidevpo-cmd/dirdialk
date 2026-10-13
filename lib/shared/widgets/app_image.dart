import 'package:flutter/material.dart';

import '../../core/images/app_images.dart';
import '../../core/images/image_store.dart';
import '../../core/images/local_image_provider.dart';
import 'image_placeholder.dart';

/// Displays an image from any supported reference:
///
/// * `localimg://<id>`  – bytes persisted in a local [ImageStore]
/// * `assets/...`       – bundled Flutter asset
/// * `http(s)://...`    – network image
/// * anything else/empty – neutral [ImagePlaceholder]
///
/// The widget never throws on missing/corrupt images; it degrades to the
/// placeholder instead, which keeps list and gallery layouts stable.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.imageRef,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
    this.semanticLabel,
    this.store,
  });

  final String? imageRef;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final String? semanticLabel;
  final ImageStore? store;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius;
    Widget child = _buildImage(context);
    if (radius != null) {
      child = ClipRRect(borderRadius: radius, child: child);
    }
    return child;
  }

  Widget _buildImage(BuildContext context) {
    final ref = imageRef;
    if (ref == null || ref.isEmpty) {
      return _placeholder();
    }

    if (ImageRef.isLocal(ref)) {
      final id = ImageRef.idOf(ref)!;
      return Image(
        image: LocalImageProvider(id, store ?? AppImages.instance),
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stack) => _placeholder(),
        frameBuilder: _frameBuilder,
      );
    }

    if (ref.startsWith('assets/')) {
      return Image.asset(
        ref,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stack) => _placeholder(),
        frameBuilder: _frameBuilder,
      );
    }

    if (ref.startsWith('http://') || ref.startsWith('https://')) {
      return Image.network(
        ref,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stack) => _placeholder(),
        frameBuilder: _frameBuilder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _loading(),
      );
    }

    return _placeholder();
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: frame == null ? _loading() : child,
    );
  }

  Widget _loading() {
    return ImagePlaceholder(
      width: width,
      height: height,
      borderRadius: borderRadius,
      icon: placeholderIcon,
    );
  }

  Widget _placeholder() => ImagePlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        icon: placeholderIcon,
      );
}
