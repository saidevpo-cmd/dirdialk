import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_image.dart';
import '../../../shared/widgets/image_placeholder.dart';

/// Responsive product image gallery.
///
/// * Main image with a fixed 4:5 frame (consistent proportions, `BoxFit.cover`).
/// * Thumbnail navigation.
/// * Horizontal swipe on touch devices; arrow controls on wide layouts.
/// * Tap to open a full-screen, zoomable `BoxFit.contain` viewer.
/// * Neutral placeholder when there are no images.
class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    required this.images,
    this.aspectRatio = 4 / 5,
  });

  final List<String> images;
  final double aspectRatio;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void didUpdateWidget(covariant ProductImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.images.length) {
      _index = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.images.length) return;
    setState(() => _index = index);
    if (_controller.hasClients) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openFullscreen(int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        var current = index;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog.fullscreen(
              backgroundColor: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Center(
                          child: AppImage(
                            imageRef: widget.images[current],
                            fit: BoxFit.contain,
                            semanticLabel: widget.images[current],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: l10n.actionClose,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  if (widget.images.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: l10n.imageMoveBackward,
                            onPressed: current > 0
                                ? () => setDialogState(() => current--)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.imageCounter(
                                current + 1, widget.images.length),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: l10n.imageMoveForward,
                            onPressed: current < widget.images.length - 1
                                ? () => setDialogState(() => current++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final images = widget.images;
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ImagePlaceholder(label: l10n.noImage),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => _openFullscreen(i),
                      child: AppImage(imageRef: images[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              if (isWide && images.length > 1) ...[
                _ArrowButton(
                  alignment: Alignment.centerLeft,
                  icon: Icons.chevron_left,
                  label: l10n.imageMoveBackward,
                  enabled: _index > 0,
                  onTap: () => _goTo(_index - 1),
                ),
                _ArrowButton(
                  alignment: Alignment.centerRight,
                  icon: Icons.chevron_right,
                  label: l10n.imageMoveForward,
                  enabled: _index < images.length - 1,
                  onTap: () => _goTo(_index + 1),
                ),
              ],
              if (images.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < images.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _index ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white70,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _index;
                return GestureDetector(
                  onTap: () => _goTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: AppImage(
                      imageRef: images[i],
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
          color: Colors.black.withValues(alpha: enabled ? 0.45 : 0.15),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            tooltip: label,
            onPressed: enabled ? onTap : null,
          ),
        ),
      ),
    );
  }
}
