import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
import '../../shared/utils/id_gen.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/responsive_data_table.dart';
import '../../shared/widgets/search_and_filter_bar.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_badge.dart';
import 'product_details_page.dart';
import 'widgets/product_image_manager.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.products;

  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _products = [];
  List<Category> _categories = [];
  Map<String, dynamic> _stats = {};

  String? _selectedCategory;
  ProductStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final catRes = await _repo.categories();
    if (catRes is Success<List<Category>>) {
      _categories = catRes.data;
    }

    final statsRes = await _repo.stats();
    if (statsRes is Success<Map<String, dynamic>>) {
      _stats = statsRes.data;
    }

    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final res = await _repo.list(
      search: _searchController.text,
      categoryId: _selectedCategory,
      status: _selectedStatus,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res is Success) {
        _products = (res as Success).data.items;
      } else {
        _errorMessage = (res as Failure).error.message;
      }
    });
  }

  void _openDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(product: product),
      ),
    );
  }

  void _showAddEditDialog([Product? product]) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final priceCtrl = TextEditingController(
        text: product != null ? product.price.toString() : '');
    final costCtrl = TextEditingController(
        text: product?.costPrice != null ? product!.costPrice.toString() : '');
    final stockCtrl = TextEditingController(
        text: product != null ? product.stockQty.toString() : '10');
    final descCtrl = TextEditingController(text: product?.description ?? '');

    String? nameError;
    String? categoryId = product?.categoryId ??
        (_categories.isNotEmpty ? _categories.first.id : null);
    ProductStatus status = product?.status ?? ProductStatus.active;
    List<String> images = [...?product?.images];

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? l10n.editProductTitle : l10n.actionAddProduct,
              ),
              content: SizedBox(
                width: dialogContentWidth(context, 540),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProductImageManager(
                        key: const Key('product-image-manager'),
                        images: images,
                        onChanged: (next) => setDialogState(() => images = next),
                      ),
                      const Divider(height: 28),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.productNameLabel,
                          errorText: nameError,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: skuCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.colSku,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: categoryId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.colCategory,
                                border: const OutlineInputBorder(),
                              ),
                              items: _categories.map((c) {
                                return DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) => setDialogState(() => categoryId = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: l10n.productPriceLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: costCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: l10n.productCostLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.productStockLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<ProductStatus>(
                              initialValue: status,
                              decoration: InputDecoration(
                                labelText: l10n.productStatusLabel,
                                border: const OutlineInputBorder(),
                              ),
                              items: ProductStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(_productStatusLabel(l10n, s)),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setDialogState(() => status = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.productDescriptionLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      setDialogState(() => nameError = l10n.productNameRequired);
                      return;
                    }
                    final price = double.tryParse(priceCtrl.text) ?? 0.0;
                    final cost = double.tryParse(costCtrl.text);
                    final stock = int.tryParse(stockCtrl.text) ?? 0;
                    final selectedCatName = _categories
                        .firstWhere(
                          (c) => c.id == categoryId,
                          orElse: () => Category(
                            id: '',
                            name: l10n.uncategorized,
                            slug: 'general',
                            createdAt: DateTime.now(),
                          ),
                        )
                        .name;

                    final mainImage = images.isNotEmpty ? images.first : '';
                    final extraImages = images.length > 1
                        ? images.sublist(1)
                        : const <String>[];

                    final Result<Object?> result;
                    if (isEditing) {
                      final updated = product.copyWith(
                        name: nameCtrl.text.trim(),
                        sku: skuCtrl.text.trim(),
                        categoryId: categoryId,
                        categoryName: selectedCatName,
                        price: price,
                        costPrice: cost,
                        stockQty: stock,
                        status: status,
                        description: descCtrl.text.trim(),
                        imageUrl: mainImage,
                        extraImages: extraImages,
                        updatedAt: DateTime.now(),
                      );
                      result = await _repo.update(updated);
                    } else {
                      final newProd = Product(
                        id: IdGen.uuid(),
                        name: nameCtrl.text.trim(),
                        sku: skuCtrl.text.trim().isNotEmpty
                            ? skuCtrl.text.trim()
                            : 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        categoryId: categoryId,
                        categoryName: selectedCatName,
                        price: price,
                        costPrice: cost,
                        stockQty: stock,
                        status: status,
                        description: descCtrl.text.trim(),
                        imageUrl: mainImage.isEmpty ? null : mainImage,
                        extraImages: extraImages,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      result = await _repo.create(newProd);
                    }

                    switch (result) {
                      case Success():
                        // Only close the dialog once the write actually
                        // succeeded; on failure the user keeps their input
                        // and sees the error.
                        if (dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                        if (!mounted) return;
                        AppFeedback.success(
                          this.context,
                          isEditing
                              ? l10n.productUpdated
                              : l10n.productCreated,
                        );
                        _loadData();
                      case Failure(:final error):
                        AppFeedback.error(
                          dialogCtx.mounted ? dialogCtx : this.context,
                          error,
                        );
                    }
                  },
                  child: Text(
                    isEditing ? l10n.actionSaveChanges : l10n.actionCreate,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteProductTitle),
        content: Text(l10n.deleteProductBody(product.name)),
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
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _repo.delete(product.id);
      if (!mounted) return;
      AppFeedback.fromResult(
        context,
        result,
        successMessage: l10n.productDeleted,
      );
      _loadData();
    }
  }

  String _productStatusLabel(AppLocalizations l10n, ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return l10n.statusActive;
      case ProductStatus.draft:
        return l10n.statusDraft;
      case ProductStatus.archived:
        return l10n.statusArchived;
    }
  }

  Widget _buildStatusBadge(AppLocalizations l10n, ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return StatusBadge.success(label: l10n.statusActive);
      case ProductStatus.draft:
        return StatusBadge.warning(label: l10n.statusDraft);
      case ProductStatus.archived:
        return StatusBadge.neutral(label: l10n.statusArchived);
    }
  }

  Widget _productIdentity(Product product, ThemeData theme) {
    return InkWell(
      onTap: () => _openDetails(product),
      child: Row(
        children: [
          AppImage(
            imageRef: product.images.isNotEmpty ? product.images.first : null,
            width: 40,
            height: 50,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (product.sku != null)
                  Text(
                    'SKU: ${product.sku}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadData,
      );
    }

    final totalProds = _stats['totalProducts']?.toString() ?? '—';
    final activeProds = _stats['activeProducts']?.toString() ?? '—';
    final lowStockProds = _stats['lowStockProducts']?.toString() ?? '—';
    final outOfStockProds = _stats['outOfStockProducts']?.toString() ?? '—';

    return SingleChildScrollView(
      key: const Key('products-page'),
      padding: AppSpacing.pagePadding(width),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.navProducts, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        l10n.productsSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(l10n.actionAddProduct),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Metric Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = AppBreakpoints.isMobile(constraints.maxWidth);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isCompact ? 2 : 4,
                    mainAxisExtent: 130,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  children: [
                    StatCard(
                      label: l10n.statProducts,
                      value: totalProds,
                      icon: Icons.inventory_2_outlined,
                    ),
                    StatCard(
                      label: l10n.statActive,
                      value: activeProds,
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: l10n.statLowStock,
                      value: lowStockProds,
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.amber,
                    ),
                    StatCard(
                      label: l10n.statOutOfStock,
                      value: outOfStockProds,
                      icon: Icons.remove_circle_outline,
                      iconColor: Colors.red,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search and Filters Bar
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.searchProductsHint,
              onSearchChanged: (_) => _fetchProducts(),
              filterWidgets: [
                // Category Filter
                DropdownButton<String?>(
                  value: _selectedCategory,
                  hint: Text(l10n.allCategories),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.allCategories),
                    ),
                    ..._categories.map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (cat) {
                    setState(() => _selectedCategory = cat);
                    _fetchProducts();
                  },
                ),
                const SizedBox(width: 8),
                // Status Filter
                DropdownButton<ProductStatus?>(
                  value: _selectedStatus,
                  hint: Text(l10n.allStatuses),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.allStatuses),
                    ),
                    ...ProductStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_productStatusLabel(l10n, s)),
                      ),
                    ),
                  ],
                  onChanged: (status) {
                    setState(() => _selectedStatus = status);
                    _fetchProducts();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Products Table
            ResponsiveDataTable<Product>(
              items: _products,
              isLoading: _isLoading,
              emptyTitle: l10n.productsEmptyTitle,
              emptyMessage: l10n.productsEmptyMessage,
              emptyActionLabel: l10n.actionAddProduct,
              onEmptyAction: () => _showAddEditDialog(),
              columns: [
                TableColumnDef(label: l10n.colProduct, flex: 4),
                TableColumnDef(label: l10n.colCategory, flex: 2),
                TableColumnDef(label: l10n.colPrice, flex: 2),
                TableColumnDef(label: l10n.colStock, flex: 2),
                TableColumnDef(label: l10n.colStatus, flex: 2),
                TableColumnDef(
                  label: l10n.colActions,
                  flex: 2,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, product, index) {
                return [
                  _productIdentity(product, theme),
                  Text(product.categoryName ?? '—'),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${product.stockQty}'),
                      if (product.isLowStock) ...[
                        const SizedBox(width: 6),
                        StatusBadge.warning(label: l10n.lowBadge),
                      ],
                    ],
                  ),
                  _buildStatusBadge(l10n, product.status),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        onPressed: () => _openDetails(product),
                        tooltip: l10n.actionView,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(product),
                        tooltip: l10n.actionEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deleteProduct(product),
                        tooltip: l10n.actionDelete,
                      ),
                    ],
                  ),
                ];
              },
              mobileCardBuilder: (context, product, index) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppImage(
                            imageRef: product.images.isNotEmpty
                                ? product.images.first
                                : null,
                            width: 56,
                            height: 70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _buildStatusBadge(l10n, product.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.categoryName ?? '—',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(l10n.stockUnits(product.stockQty)),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 18),
                                onPressed: () => _openDetails(product),
                                tooltip: l10n.actionView,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAddEditDialog(product),
                                tooltip: l10n.actionEdit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: theme.colorScheme.error,
                                onPressed: () => _deleteProduct(product),
                                tooltip: l10n.actionDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
