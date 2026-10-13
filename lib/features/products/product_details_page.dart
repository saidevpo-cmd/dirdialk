import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../domain/models/product.dart';
import '../../l10n/generated/app_localizations.dart';
import '../products/widgets/product_image_gallery.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';

/// Full product view with a responsive image gallery.
///
/// Reached by tapping any storefront/back-office product card. It renders only
/// local data passed in, so it works offline and never triggers a network call.
class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 820;

    final gallery = ProductImageGallery(
      key: const Key('product-gallery'),
      images: product.images,
    );

    final details = _Details(product: product);

    return Scaffold(
      key: const Key('product-details-page'),
      appBar: AppBar(title: Text(product.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding(width),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: gallery),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(flex: 4, child: details),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        gallery,
                        const SizedBox(height: AppSpacing.lg),
                        details,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.categoryName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Chip(
              label: Text(product.categoryName!),
              avatar: const Icon(Icons.category_outlined, size: 16),
            ),
          ),
        Text(product.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.isDemo) ...[
              const SizedBox(width: 10),
              StatusBadge.neutral(label: l10n?.demoPrice ?? 'Demo price'),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.isOutOfStock)
              StatusBadge.neutral(label: l10n?.outOfStock ?? 'Out of stock')
            else if (product.isLowStock)
              StatusBadge.warning(label: l10n?.lowStock ?? 'Low stock')
            else
              StatusBadge.success(label: l10n?.inStock ?? 'In stock'),
            if (product.isDemo)
              StatusBadge.warning(label: l10n?.demoDataTitle ?? 'Demo data'),
          ],
        ),
        const SizedBox(height: 16),
        if (product.description != null && product.description!.isNotEmpty)
          Text(product.description!, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              _row(context, l10n?.colSku ?? 'SKU', product.sku ?? '—'),
              const Divider(height: 20),
              _row(context, l10n?.colStock ?? 'Stock',
                  '${product.stockQty} ${product.unit}'),
              const Divider(height: 20),
              _row(context, l10n?.colStatus ?? 'Status',
                  _statusLabel(l10n, product.status)),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(AppLocalizations? l10n, ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return l10n?.statusActive ?? 'Active';
      case ProductStatus.draft:
        return l10n?.statusDraft ?? 'Draft';
      case ProductStatus.archived:
        return l10n?.statusArchived ?? 'Archived';
    }
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
