import 'package:flutter/material.dart';

import '../../../core/images/image_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/app_feedback.dart';
import '../../../shared/widgets/app_image.dart';
import '../../../shared/widgets/image_placeholder.dart';

/// Preview + pick/replace/remove control for a single category image.
///
/// Category images are recommended at 600 x 600 (1:1) and are never stretched:
/// the preview uses `BoxFit.cover`.
class CategoryImageField extends StatefulWidget {
  const CategoryImageField({
    super.key,
    required this.imageRef,
    required this.onChanged,
    this.imageService,
    this.enabled = true,
  });

  final String? imageRef;
  final ValueChanged<String?> onChanged;
  final ImageService? imageService;
  final bool enabled;

  @override
  State<CategoryImageField> createState() => _CategoryImageFieldState();
}

class _CategoryImageFieldState extends State<CategoryImageField> {
  ImageService? _service;
  bool _busy = false;

  ImageService get _imageService =>
      widget.imageService ?? (_service ??= ImageService());

  Future<void> _pick() async {
    if (_busy) return;
    setState(() => _busy = true);
    final outcome = await _imageService.pickAndStore(
      aspectRatio: ImageSpecs.categoryAspectRatio,
      maxWidth: 1200,
      maxHeight: 1200,
      context: context,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (outcome.isSuccess) {
      widget.onChanged(outcome.reference);
    } else if (outcome.isFailure) {
      if (!mounted) return;
      AppFeedback.failure(context, outcome.error!);
    }
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeImageTitle),
        content: Text(l10n.removeCategoryImageBody),
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
    if (confirmed == true) {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImage = widget.imageRef?.isNotEmpty == true;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          height: 108,
          child: _busy
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : hasImage
                  ? AppImage(
                      key: const Key('category-image-preview'),
                      imageRef: widget.imageRef,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : ImagePlaceholder(
                      key: const Key('category-image-placeholder'),
                      borderRadius: null,
                      label: l10n.noImage,
                    ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.categoryImageLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.categoryImageHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('category-image-pick'),
                    onPressed: widget.enabled && !_busy ? _pick : null,
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                    label: Text(hasImage ? l10n.imageReplace : l10n.selectImage),
                  ),
                  if (hasImage)
                    TextButton.icon(
                      key: const Key('category-image-remove'),
                      onPressed:
                          widget.enabled && !_busy ? _remove : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(l10n.actionRemove),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
