import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/responsive_data_table.dart';
import '../../shared/widgets/search_and_filter_bar.dart';
import '../../shared/widgets/stat_card.dart';
import '../products/product_details_page.dart';
import 'widgets/category_image_field.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.categories;
  final _productRepo = AppRepositories.instance.products;

  bool _isLoading = true;
  String? _errorMessage;
  List<Category> _categories = [];
  Map<String, dynamic> _stats = {};
  Map<String, int> _productCounts = {};

  String? _selectedCategoryId;
  List<Product> _selectedProducts = [];
  bool _loadingProducts = false;

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

    final statsRes = await _repo.stats();
    if (statsRes is Success<Map<String, dynamic>>) {
      _stats = statsRes.data;
    }

    final productsRes = await _productRepo.list(limit: 1000);
    if (productsRes is Success) {
      final counts = <String, int>{};
      for (final p in (productsRes as Success).data.items as List<Product>) {
        final id = p.categoryId;
        if (id != null) counts[id] = (counts[id] ?? 0) + 1;
      }
      _productCounts = counts;
    }

    await _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final res = await _repo.list(search: _searchController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res is Success) {
        _categories = (res as Success).data.items;
      } else {
        _errorMessage = AppLocalizations.of(context)!.loadFailed;
      }
    });
  }

  Future<void> _selectCategory(Category category) async {
    if (_selectedCategoryId == category.id) {
      setState(() {
        _selectedCategoryId = null;
        _selectedProducts = [];
      });
      return;
    }
    setState(() {
      _selectedCategoryId = category.id;
      _loadingProducts = true;
      _selectedProducts = [];
    });
    final res = await _productRepo.list(categoryId: category.id, limit: 100);
    if (!mounted) return;
    setState(() {
      _loadingProducts = false;
      if (res is Success) {
        _selectedProducts = (res as Success).data.items;
      }
    });
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(product: product),
      ),
    );
  }

  String _slugify(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  Future<void> _showAddEditDialog([Category? category]) async {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = category != null;
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final slugCtrl = TextEditingController(text: category?.slug ?? '');
    final descCtrl = TextEditingController(text: category?.description ?? '');
    String? imageRef = category?.imageUrl;
    String? nameError;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? l10n.editCategory : l10n.addCategory),
              content: SizedBox(
                width: dialogContentWidth(context, 460),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CategoryImageField(
                        key: const Key('category-image-field'),
                        imageRef: imageRef,
                        onChanged: (ref) => setDialogState(() => imageRef = ref),
                      ),
                      const Divider(height: 24),
                      TextField(
                        controller: nameCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: l10n.categoryName,
                          border: const OutlineInputBorder(),
                          errorText: nameError,
                        ),
                        onChanged: (value) {
                          if (!isEditing && slugCtrl.text.isEmpty) {
                            slugCtrl.text = _slugify(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: slugCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.categorySlug,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.categoryDescription,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      setDialogState(() => nameError = l10n.categoryNameRequired);
                      return;
                    }

                    final slug = slugCtrl.text.trim().isNotEmpty
                        ? _slugify(slugCtrl.text)
                        : _slugify(name);

                    final Result<Category> result;
                    if (isEditing) {
                      result = await _repo.update(category.copyWith(
                        name: name,
                        slug: slug,
                        description: descCtrl.text.trim(),
                        imageUrl: imageRef ?? '',
                      ));
                    } else {
                      result = await _repo.create(Category(
                        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        slug: slug,
                        description: descCtrl.text.trim(),
                        imageUrl: imageRef,
                        createdAt: DateTime.now(),
                      ));
                    }

                    if (!dialogCtx.mounted) return;

                    if (result is Failure) {
                      setDialogState(() => nameError = l10n.categoryNameExists);
                      return;
                    }
                    Navigator.of(dialogCtx).pop(true);
                  },
                  child: Text(isEditing ? l10n.actionConfirm : l10n.addCategory),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      AppFeedback.success(
        context,
        category == null ? l10n.categoryCreated : l10n.categoryUpdated,
      );
      _loadData();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final referencing = _productCounts[category.id] ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteCategoryBody(category.name)),
            if (referencing > 0) ...[
              const SizedBox(height: 12),
              Text(
                l10n.deleteCategoryInUse(referencing),
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ],
          ],
        ),
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
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (referencing > 0) {
      final productsRes = await _productRepo.list(categoryId: category.id, limit: 1000);
      if (productsRes is Success) {
        for (final p in (productsRes as Success).data.items as List<Product>) {
          final reassign = await _productRepo.update(p.copyWith(
            categoryId: null,
            categoryName: l10n.uncategorized,
            updatedAt: DateTime.now(),
          ));
          if (reassign is Failure) {
            if (!mounted) return;
            AppFeedback.error(context, (reassign as Failure).error);
            return;
          }
        }
      }
    }

    final deleteRes = await _repo.delete(category.id);
    if (!mounted) return;
    AppFeedback.fromResult(
      context,
      deleteRes,
      successMessage: l10n.categoryDeleted,
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    if (_errorMessage != null) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadData);
    }

    final total = _stats['totalCategories']?.toString() ?? '—';
    final roots = _stats['rootCategories']?.toString() ?? '—';
    final children = _stats['childCategories']?.toString() ?? '—';
    final selectedCategory = _categories
        .where((c) => c.id == _selectedCategoryId)
        .firstOrNull;

    return SingleChildScrollView(
      key: const Key('categories-page'),
      padding: AppSpacing.pagePadding(width),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.navCategories, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        l10n.categoriesSubtitle,
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
                  label: Text(l10n.addCategory),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = AppBreakpoints.isMobile(constraints.maxWidth);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isCompact ? 1 : 3,
                    mainAxisExtent: 130,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  children: [
                    StatCard(
                      label: l10n.navCategories,
                      value: total,
                      icon: Icons.category_outlined,
                    ),
                    StatCard(
                      label: l10n.catRoot,
                      value: roots,
                      icon: Icons.account_tree_outlined,
                    ),
                    StatCard(
                      label: l10n.catSub,
                      value: children,
                      icon: Icons.subdirectory_arrow_right,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Responsive category cards with images.
            Text(
              l10n.catShopBy,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.catTapHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryCards(theme),
            if (selectedCategory != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildSelectedProducts(theme, selectedCategory),
            ],
            const SizedBox(height: AppSpacing.lg),
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.catSearchHint,
              onSearchChanged: (_) => _fetchCategories(),
            ),
            const SizedBox(height: AppSpacing.md),
            ResponsiveDataTable<Category>(
              items: _categories,
              isLoading: _isLoading,
              emptyTitle: l10n.categoriesEmptyTitle,
              emptyMessage: l10n.categoriesEmptyMessage,
              emptyActionLabel: l10n.addCategory,
              onEmptyAction: () => _showAddEditDialog(),
              columns: [
                TableColumnDef(label: l10n.colCategory.toUpperCase(), flex: 4),
                TableColumnDef(label: l10n.colSlug.toUpperCase(), flex: 2),
                TableColumnDef(label: l10n.colProducts.toUpperCase(), flex: 2),
                TableColumnDef(
                    label: l10n.colDescription.toUpperCase(), flex: 3),
                TableColumnDef(
                  label: l10n.colActions.toUpperCase(),
                  flex: 2,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, category, index) {
                final count = _productCounts[category.id] ?? 0;
                return [
                  Row(
                    children: [
                      AppImage(
                        imageRef: category.imageUrl,
                        width: 36,
                        height: 36,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Text('/${category.slug}', style: theme.textTheme.bodySmall),
                  Text('$count'),
                  Text(
                    category.description?.isNotEmpty == true
                        ? category.description!
                        : '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: l10n.editCategory,
                        onPressed: () => _showAddEditDialog(category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        tooltip: l10n.deleteCategoryTitle,
                        onPressed: () => _deleteCategory(category),
                      ),
                    ],
                  ),
                ];
              },
              mobileCardBuilder: (context, category, index) {
                final count = _productCounts[category.id] ?? 0;
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(l10n.catProductCount(count),
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('/${category.slug}', style: theme.textTheme.bodySmall),
                      if (category.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(category.description!, style: theme.textTheme.bodySmall),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: l10n.editCategory,
                            onPressed: () => _showAddEditDialog(category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: theme.colorScheme.error,
                            tooltip: l10n.deleteCategoryTitle,
                            onPressed: () => _deleteCategory(category),
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

  Widget _buildCategoryCards(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 210,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final selected = category.id == _selectedCategoryId;
        final count = _productCounts[category.id] ?? 0;
        return InkWell(
          key: Key('category-card-${category.id}'),
          onTap: () => _selectCategory(category),
          borderRadius: BorderRadius.circular(12),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AppImage(
                          imageRef: category.imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colorScheme.primary,
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '${category.name} · $count',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedProducts(ThemeData theme, Category category) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.productsInCategory(category.name),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _selectedCategoryId = null;
                _selectedProducts = [];
              }),
              child: Text(l10n.actionClear),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_loadingProducts)
          const Center(child: CircularProgressIndicator())
        else if (_selectedProducts.isEmpty)
          EmptyStateView(
            title: l10n.catNoProducts,
            message: l10n.catNoProductsHint(category.name),
            icon: Icons.inventory_2_outlined,
          )
        else
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedProducts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final product = _selectedProducts[i];
                return SizedBox(
                  width: 180,
                  child: InkWell(
                    onTap: () => _openProduct(product),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: AppImage(
                              imageRef: product.images.isNotEmpty
                                  ? product.images.first
                                  : null,
                              fit: BoxFit.cover,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
