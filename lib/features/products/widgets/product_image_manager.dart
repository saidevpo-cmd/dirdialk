import 'package:flutter/material.dart';

import '../../../core/images/image_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/app_feedback.dart';
import '../../../shared/widgets/app_image.dart';
import '../../../shared/widgets/image_placeholder.dart';

/// Controlled editor for a product's image list.
///
/// The first image is always the main image. Supports adding (multiple at
/// once), replacing, removing, promoting to main and reordering without
/// drag-and-drop so it stays usable on touch and mouse alike.
class ProductImageManager extends StatefulWidget {
  const ProductImageManager({
    super.key,
    required this.images,
    required this.onChanged,
    this.imageService,
    this.enabled = true,
    this.thumbWidth = 96,
    this.thumbHeight = 120,
  });

  final List<String> images;
  final ValueChanged<List<String>> onChanged;
  final ImageService? imageService;
  final bool enabled;
  final double thumbWidth;
  final double thumbHeight;

  @override
  State<ProductImageManager> createState() => _ProductImageManagerState();
}

class _ProductImageManagerState extends State<ProductImageManager> {
  ImageService? _service;
  bool _busy = false;

  ImageService get _imageService =>
      widget.imageService ?? (_service ??= ImageService());

  Future<void> _addImages() async {
    if (_busy) return;
    setState(() => _busy = true);
    final outcome = await _imageService.pickAndStore(
      aspectRatio: ImageSpecs.productAspectRatio,
      maxWidth: 1600,
      maxHeight: 2000,
      context: context,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (outcome.isSuccess) {
      widget.onChanged([...widget.images, outcome.reference!]);
    } else if (outcome.isFailure) {
      _snack(outcome.error!);
    }
  }

  Future<void> _replace(int index) async {
    if (_busy) return;
    setState(() => _busy = true);
    final outcome = await _imageService.pickAndStore(
      aspectRatio: ImageSpecs.productAspectRatio,
      maxWidth: 1600,
      maxHeight: 2000,
      context: context,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (outcome.isSuccess) {
      final next = [...widget.images];
      next[index] = outcome.reference!;
      widget.onChanged(next);
    } else if (outcome.isFailure) {
      _snack(outcome.error!);
    }
  }

  Future<void> _remove(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeImageTitle),
        content: Text(l10n.removeImageBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final next = [...widget.images]..removeAt(index);
    widget.onChanged(next);
    if (mounted) AppFeedback.success(context, l10n.imageRemoved);
  }

  void _setMain(int index) {
    final next = [...widget.images];
    final selected = next.removeAt(index);
    next.insert(0, selected);
    widget.onChanged(next);
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= widget.images.length) return;
    final next = [...widget.images];
    final item = next.removeAt(index);
    next.insert(target, item);
    widget.onChanged(next);
  }

  void _snack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.productImagesLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${widget.images.length})',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.productImagesHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < widget.images.length; i++)
              _ImageTile(
                key: ValueKey('product-image-$i-${widget.images[i]}'),
                imageRef: widget.images[i],
                index: i,
                total: widget.images.length,
                isMain: i == 0,
                width: widget.thumbWidth,
                height: widget.thumbHeight,
                enabled: widget.enabled && !_busy,
                onSetMain: () => _setMain(i),
                onReplace: () => _replace(i),
                onRemove: () => _remove(i),
                onMoveBackward: () => _move(i, -1),
                onMoveForward: () => _move(i, 1),
              ),
            if (widget.enabled)
              _AddTile(
                width: widget.thumbWidth,
                height: widget.thumbHeight,
                busy: _busy,
                onTap: _addImages,
              ),
          ],
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    super.key,
    required this.imageRef,
    required this.index,
    required this.total,
    required this.isMain,
    required this.width,
    required this.height,
    required this.enabled,
    required this.onSetMain,
    required this.onReplace,
    required this.onRemove,
    required this.onMoveBackward,
    required this.onMoveForward,
  });

  final String imageRef;
  final int index;
  final int total;
  final bool isMain;
  final double width;
  final double height;
  final bool enabled;
  final VoidCallback onSetMain;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final VoidCallback onMoveBackward;
  final VoidCallback onMoveForward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final radius = BorderRadius.circular(10);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppImage(
              imageRef: imageRef,
              fit: BoxFit.cover,
              borderRadius: radius,
            ),
          ),
          if (isMain)
            Positioned(
              left: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.imageMainBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<_ImageAction>(
              enabled: enabled,
              tooltip: l10n.imageOptions,
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (action) {
                switch (action) {
                  case _ImageAction.setMain:
                    onSetMain();
                  case _ImageAction.replace:
                    onReplace();
                  case _ImageAction.remove:
                    onRemove();
                  case _ImageAction.moveBackward:
                    onMoveBackward();
                  case _ImageAction.moveForward:
                    onMoveForward();
                }
              },
              itemBuilder: (context) => [
                if (!isMain)
                  PopupMenuItem(
                    value: _ImageAction.setMain,
                    child: Text(l10n.imageSetMain),
                  ),
                PopupMenuItem(
                  value: _ImageAction.replace,
                  child: Text(l10n.imageReplace),
                ),
                PopupMenuItem(
                  value: _ImageAction.moveBackward,
                  enabled: index > 0,
                  child: Text(l10n.imageMoveBackward),
                ),
                PopupMenuItem(
                  value: _ImageAction.moveForward,
                  enabled: index < total - 1,
                  child: Text(l10n.imageMoveForward),
                ),
                PopupMenuItem(
                  value: _ImageAction.remove,
                  child: Text(l10n.actionRemove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ImageAction { setMain, replace, remove, moveBackward, moveForward }

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.width,
    required this.height,
    required this.busy,
    required this.onTap,
  });

  final double width;
  final double height;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outline),
        ),
        child: busy
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: scheme.primary),
                  const SizedBox(height: 6),
                  Text(l10n.imageAdd,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
      ),
    );
  }
}

/// Read-only horizontal thumbnail strip reused by product cards.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    this.imageRef,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? imageRef;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageRef == null || imageRef!.isEmpty) {
      return ImagePlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }
    return AppImage(
      imageRef: imageRef,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
    );
  }
}
