import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../data/demo/demo_catalog.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../domain/models/site_settings.dart';
import '../../domain/models/social_links.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/external_links.dart';
import '../../shared/utils/id_gen.dart';
import '../../shared/utils/order_number.dart';
import '../../shared/utils/phone_number.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/social_links_bar.dart';
import '../../shared/widgets/status_badge.dart';
import '../products/product_details_page.dart';
import '../tracking/order_tracking_page.dart';
import 'checkout/checkout.dart';

class StoreCartItem {
  StoreCartItem({required this.product, this.quantity = 1});
  final Product product;
  int quantity;

  double get total => product.price * quantity;
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final _prodRepo = AppRepositories.instance.products;
  final _orderRepo = AppRepositories.instance.orders;
  final _settingsRepo = AppRepositories.instance.siteSettings;

  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _allProducts = [];
  List<Category> _categories = [];
  String? _selectedCategory;
  final Map<String, StoreCartItem> _cart = {};

  /// Tax rate and currency come from `app_settings`; totals shown here are
  /// estimates only — `place_order` recomputes them from the product rows.
  double _taxRatePercent = 0;
  String _currencySymbol = r'$';

  /// Public presentation content (brand, contact, social links) shown in the
  /// storefront footer and the WhatsApp chat button.
  SiteSettings _siteSettings = const SiteSettings();

  // Contact fields are captured once per checkout attempt so a retry after a
  // failed submission keeps the same idempotency key.
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String? _idempotencyKey;
  bool _placing = false;
  List<CheckoutIssue> _checkoutIssues = const [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  /// Any change to the cart content is a different order, so a fresh
  /// idempotency key is generated on the next checkout attempt.
  void _invalidateCheckoutAttempt() {
    _idempotencyKey = null;
    _checkoutIssues = const [];
  }

  String _money(double value) => '$_currencySymbol${value.toStringAsFixed(2)}';

  List<Product> get _visibleProducts {
    if (_selectedCategory == null) return _allProducts;
    return _allProducts
        .where((p) => p.categoryId == _selectedCategory)
        .toList();
  }

  List<Product> get _featuredProducts =>
      _allProducts.where((p) => p.hasImages).take(8).toList();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final catRes = await _prodRepo.categories();
    if (catRes is Success<List<Category>>) {
      _categories = catRes.data;
    }

    final prodRes = await _prodRepo.list(
      status: ProductStatus.active,
      limit: 100,
    );

    final currencyRes = await _settingsRepo.currencySymbol();
    final taxRes = await _settingsRepo.taxRatePercent();
    final settingsRes = await _settingsRepo.load();
    final symbol = currencyRes is Success<String> ? currencyRes.data : r'$';
    final tax = taxRes is Success<double> ? taxRes.data : 0.0;

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _currencySymbol = symbol;
      _taxRatePercent = tax;
      if (settingsRes is Success<SiteSettings>) {
        _siteSettings = settingsRes.data;
      }
      if (prodRes is Success) {
        _allProducts = (prodRes as Success).data.items;
      } else {
        _errorMessage = AppLocalizations.of(context)!.loadFailed;
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

  void _openTracking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OrderTrackingPage()),
    );
  }

  void _addToCart(Product product) {
    final l10n = AppLocalizations.of(context)!;
    final inCart = _cart[product.id]?.quantity ?? 0;

    if (product.stockQty <= 0) {
      AppFeedback.failure(context, l10n.outOfStock);
      return;
    }
    if (inCart + 1 > product.stockQty) {
      AppFeedback.failure(
        context,
        l10n.checkoutInsufficientStock(product.stockQty, product.name),
      );
      return;
    }

    setState(() {
      _invalidateCheckoutAttempt();
      if (_cart.containsKey(product.id)) {
        _cart[product.id]!.quantity += 1;
      } else {
        _cart[product.id] = StoreCartItem(product: product);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.addedToCart(product.name)),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitCheckout({
    required BuildContext sheetContext,
    required StateSetter refresh,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final lines = _cart.values
        .map((ci) => CheckoutLine(product: ci.product, qty: ci.quantity))
        .toList();

    final issues = CheckoutValidator.validate(
      customerName: _nameCtrl.text,
      customerPhone: _phoneCtrl.text,
      lines: lines,
      shippingAddress: _addressCtrl.text,
      shippingCity: _cityCtrl.text,
    );
    if (issues.isNotEmpty) {
      setState(() => _checkoutIssues = issues);
      refresh(() {});
      return;
    }

    setState(() {
      _checkoutIssues = const [];
      _placing = true;
    });
    refresh(() {});

    // One key per attempt: a retry after a lost response replays the same
    // order instead of creating a duplicate.
    _idempotencyKey ??= IdGen.uuid();

    final totals = CheckoutTotals.compute(
      lines: lines,
      taxRatePercent: _taxRatePercent,
    );
    final order = CheckoutValidator.buildOrder(
      lines: lines,
      totals: totals,
      customerName: _nameCtrl.text,
      customerPhone: PhoneNumber.normalize(_phoneCtrl.text),
      shippingAddress: _addressCtrl.text,
      shippingCity: _cityCtrl.text,
      idempotencyKey: _idempotencyKey,
    );

    final result = await _orderRepo.create(order);
    if (!mounted) return;

    setState(() => _placing = false);
    refresh(() {});

    switch (result) {
      case Success(data: final saved):
        setState(() {
          _cart.clear();
          _invalidateCheckoutAttempt();
        });
        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        AppFeedback.success(
            context, l10n.orderPlaced(OrderNumber.format(saved.orderNumber)));
      case Failure(:final error):
        AppFeedback.error(context, error);
    }
  }

  /// Localised message for a single validation issue.
  String _issueMessage(CheckoutIssue issue, AppLocalizations l10n) {
    switch (issue.problem) {
      case CheckoutProblem.customerNameRequired:
      case CheckoutProblem.phoneRequired:
        return l10n.fieldRequired;
      case CheckoutProblem.customerNameTooShort:
        return l10n.checkoutNameTooShort;
      case CheckoutProblem.phoneInvalid:
        return l10n.checkoutPhoneInvalid;
      case CheckoutProblem.cartEmpty:
        return l10n.cartEmptyMessage;
      case CheckoutProblem.quantityInvalid:
        return l10n.checkoutQuantityInvalid;
      case CheckoutProblem.insufficientStock:
        return l10n.checkoutInsufficientStock(
          issue.available ?? 0,
          issue.productName ?? '',
        );
      case CheckoutProblem.addressTooLong:
        return l10n.checkoutAddressTooLong;
      case CheckoutProblem.cityTooLong:
        return l10n.checkoutCityTooLong;
    }
  }

  /// Error text for a group of problem codes (first match wins).
  String? _errorFor(Set<CheckoutProblem> problems, AppLocalizations l10n) {
    for (final issue in _checkoutIssues) {
      if (problems.contains(issue.problem)) {
        return _issueMessage(issue, l10n);
      }
    }
    return null;
  }

  void _openCartDrawer() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return StatefulBuilder(
          builder: (bottomCtx, setModalState) {
            final cartItems = _cart.values.toList();
            final lines = cartItems
                .map((ci) => CheckoutLine(product: ci.product, qty: ci.quantity))
                .toList();
            final totals = CheckoutTotals.compute(
              lines: lines,
              taxRatePercent: _taxRatePercent,
            );

            return Container(
              height: MediaQuery.sizeOf(ctx).height * 0.85,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.cartTitle} (${cartItems.length})',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(bottomCtx).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (cartItems.isEmpty)
                    Expanded(
                      child: EmptyStateView(
                        title: l10n.cartEmpty,
                        message: l10n.cartEmptyMessage,
                        icon: Icons.shopping_cart_outlined,
                      ),
                    )
                  else ...[
                    Expanded(
                      child: ListView(
                        children: [
                          for (final item in cartItems) ...[
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: AppImage(
                                imageRef: item.product.images.isNotEmpty
                                    ? item.product.images.first
                                    : null,
                                width: 44,
                                height: 44,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              title: Text(item.product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  '${_money(item.product.price)} ${l10n.eachLabel}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        size: 20),
                                    tooltip: item.quantity > 1
                                        ? l10n.decreaseQuantity
                                        : l10n.removeFromCart,
                                    onPressed: () {
                                      setState(() {
                                        _invalidateCheckoutAttempt();
                                        if (item.quantity > 1) {
                                          item.quantity -= 1;
                                        } else {
                                          _cart.remove(item.product.id);
                                        }
                                      });
                                      setModalState(() {});
                                    },
                                  ),
                                  Text('${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 20),
                                    tooltip: l10n.increaseQuantity,
                                    // Cannot add more than the available stock.
                                    onPressed: item.quantity >=
                                            item.product.stockQty
                                        ? null
                                        : () {
                                            setState(() {
                                              _invalidateCheckoutAttempt();
                                              item.quantity += 1;
                                            });
                                            setModalState(() {});
                                          },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            l10n.customerInformation,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('checkout-name'),
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.customerNameLabel,
                              errorText: _errorFor(const {
                                CheckoutProblem.customerNameRequired,
                                CheckoutProblem.customerNameTooShort,
                              }, l10n),
                            ),
                            onChanged: (_) {
                              if (_checkoutIssues.isNotEmpty) {
                                setState(() => _checkoutIssues = const []);
                                setModalState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('checkout-phone'),
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: l10n.customerPhoneLabel,
                              errorText: _errorFor(const {
                                CheckoutProblem.phoneRequired,
                                CheckoutProblem.phoneInvalid,
                              }, l10n),
                            ),
                            onChanged: (_) {
                              if (_checkoutIssues.isNotEmpty) {
                                setState(() => _checkoutIssues = const []);
                                setModalState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('checkout-address'),
                            controller: _addressCtrl,
                            decoration: InputDecoration(
                              labelText: l10n.customerAddressLabel,
                              errorText: _errorFor(
                                  const {CheckoutProblem.addressTooLong}, l10n),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('checkout-city'),
                            controller: _cityCtrl,
                            decoration: InputDecoration(
                              labelText: l10n.customerCityLabel,
                              errorText: _errorFor(
                                  const {CheckoutProblem.cityTooLong}, l10n),
                            ),
                          ),
                          if (_checkoutIssues.any((i) =>
                              i.problem == CheckoutProblem.insufficientStock)) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorFor(const {
                                    CheckoutProblem.insufficientStock,
                                  }, l10n) ??
                                  '',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.subtotalLabel),
                        Text(_money(totals.subtotal)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.estimatedTax),
                        Text(_money(totals.tax)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.totalAmountLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold)),
                        Text(
                          _money(totals.total),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('checkout-submit'),
                      onPressed: _placing
                          ? null
                          : () => _submitCheckout(
                                sheetContext: bottomCtx,
                                refresh: setModalState,
                              ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _placing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.checkoutAction,
                                style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
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
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadCatalog,
      );
    }

    final totalCartCount =
        _cart.values.fold<int>(0, (sum, item) => sum + item.quantity);

    return SingleChildScrollView(
      key: const Key('store-page'),
      padding: AppSpacing.pagePadding(width),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header with Cart Trigger
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.storefrontTitle,
                            style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          l10n.storefrontSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _openTracking,
                        icon: const Icon(Icons.local_shipping_outlined, size: 20),
                        label: Text(l10n.trackOrderAction),
                      ),
                      Badge(
                        isLabelVisible: totalCartCount > 0,
                        label: Text('$totalCartCount'),
                        child: FilledButton.tonalIcon(
                          onPressed: _openCartDrawer,
                          icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                          label: Text(l10n.cartTitle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                const _BannerCarousel(),
                const SizedBox(height: AppSpacing.xl),
                _sectionTitle(theme, l10n.shopByCategory),
                const SizedBox(height: AppSpacing.md),
                _CategoryStrip(
                  categories: _categories,
                  selectedId: _selectedCategory,
                  onSelected: (id) => setState(
                    () => _selectedCategory = id == _selectedCategory ? null : id,
                  ),
                ),
                if (_featuredProducts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _sectionTitle(theme, l10n.featuredProducts),
                  const SizedBox(height: AppSpacing.md),
                  _ProductStrip(
                    products: _featuredProducts,
                    onTap: _openProduct,
                    onAdd: _addToCart,
                  ),
                ],
                if (_allProducts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _sectionTitle(theme, l10n.latestProducts),
                  const SizedBox(height: AppSpacing.md),
                  _ProductStrip(
                    products: _allProducts.take(6).toList(),
                    onTap: _openProduct,
                    onAdd: _addToCart,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                _sectionTitle(
                  theme,
                  _selectedCategory == null
                      ? l10n.allProducts
                      : l10n.productsInCategory(
                          _categoryName(_selectedCategory!)),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_visibleProducts.isEmpty)
                  EmptyStateView(
                    title: l10n.noProductsInCategoryTitle,
                    message: l10n.noProductsInCategoryMessage,
                    icon: Icons.storefront_outlined,
                  )
                else
                  _CatalogGrid(
                    products: _visibleProducts,
                    onTap: _openProduct,
                    onAdd: _addToCart,
                  ),
                const SizedBox(height: AppSpacing.xl),
                _StoreFooter(settings: _siteSettings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _categoryName(String id) =>
      _categories.where((c) => c.id == id).firstOrNull?.name ??
      AppLocalizations.of(context)!.generalLabel;

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _titles(AppLocalizations l10n) => [
        l10n.bannerNewArrivals,
        l10n.bannerLocalDelivery,
        l10n.bannerStorePickup,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = _titles(l10n);
    final height = MediaQuery.sizeOf(context).width < 720 ? 160.0 : 220.0;
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    return SizedBox(
      key: const Key('store-banner-carousel'),
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: DemoCatalog.banners.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final banner = DemoCatalog.banners[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(imageRef: banner.asset, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.black.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            titles[i % titles.length],
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (isWide && DemoCatalog.banners.length > 1) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: _roundButton(Icons.chevron_left, () {
                if (_index > 0) {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _roundButton(Icons.chevron_right, () {
                if (_index < DemoCatalog.banners.length - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              }),
            ),
          ],
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < DemoCatalog.banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return SizedBox(
      key: const Key('store-category-strip'),
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final category = categories[i];
          final selected = category.id == selectedId;
          return SizedBox(
            width: 132,
            child: InkWell(
              onTap: () => onSelected(category.id),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AppImage(
                      imageRef: category.imageUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductStrip extends StatelessWidget {
  const _ProductStrip({
    required this.products,
    required this.onTap,
    required this.onAdd,
  });

  final List<Product> products;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        key: const Key('store-product-strip'),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(
          width: 200,
          child: _StoreProductCard(
            product: products[i],
            onTap: () => onTap(products[i]),
            onAdd: () => onAdd(products[i]),
          ),
        ),
      ),
    );
  }
}

class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({
    required this.products,
    required this.onTap,
    required this.onAdd,
  });

  final List<Product> products;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);
        final isDesktop = AppBreakpoints.isDesktop(constraints.maxWidth);
        final crossAxisCount = isMobile ? 2 : (isDesktop ? 4 : 3);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 300,
          ),
          itemCount: products.length,
          itemBuilder: (context, i) => _StoreProductCard(
            product: products[i],
            onTap: () => onTap(products[i]),
            onAdd: () => onAdd(products[i]),
          ),
        );
      },
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  const _StoreProductCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
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
                      imageRef:
                          product.images.isNotEmpty ? product.images.first : null,
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  if (product.isLowStock)
                    Positioned(
                      top: 8,
                      left: 8,
                        child: StatusBadge.warning(label: l10n.lowStock),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.categoryName ?? l10n.generalLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onAdd,
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        tooltip: l10n.addToCart,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Storefront footer: business identity, contact details, the public social
/// links and a prominent WhatsApp chat button (all from `site_settings`).
class _StoreFooter extends StatelessWidget {
  const _StoreFooter({required this.settings});

  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customization = settings.customization;
    final links = settings.socialLinks;

    final hasContact = customization.contactEmail.isNotEmpty ||
        customization.contactPhone.isNotEmpty ||
        customization.address.isNotEmpty;
    if (links.isEmpty && !hasContact) return const SizedBox.shrink();

    final whatsapp = SocialLinks.whatsappChatUrl(
      links.whatsappUrl,
      text: l10n.chatOnWhatsappMessage,
    );

    return AppCard(
      expand: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customization.brandName,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (customization.tagline.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              customization.tagline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (hasContact) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: [
                if (customization.contactEmail.isNotEmpty)
                  _contactRow(theme, Icons.mail_outline,
                      customization.contactEmail),
                if (customization.contactPhone.isNotEmpty)
                  _contactRow(theme, Icons.phone_outlined,
                      customization.contactPhone),
                if (customization.address.isNotEmpty)
                  _contactRow(
                      theme, Icons.location_on_outlined, customization.address),
              ],
            ),
          ],
          if (links.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.storefrontFollowUs,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SocialLinksBar(links: links),
          ],
          if (whatsapp != null) ...[
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              onPressed: () => ExternalLinks.open(whatsapp),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.chat),
              label: Text(l10n.chatOnWhatsapp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactRow(ThemeData theme, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
