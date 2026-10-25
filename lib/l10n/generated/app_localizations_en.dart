// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'diali';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProducts => 'Products';

  @override
  String get navOrders => 'Orders';

  @override
  String get navOrderHistory => 'Order History';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navResources => 'Resources';

  @override
  String get navForms => 'Forms';

  @override
  String get navPages => 'Pages';

  @override
  String get navStore => 'Store';

  @override
  String get navSettings => 'Settings';

  @override
  String get openNavigation => 'Open navigation menu';

  @override
  String get closeNavigation => 'Close navigation menu';

  @override
  String get dashboardSubtitle =>
      'Here is what is happening in your business today.';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get viewAll => 'View all';

  @override
  String get statProducts => 'Total products';

  @override
  String get statOrders => 'Total orders';

  @override
  String get statCustomers => 'Total customers';

  @override
  String get statResources => 'Total resources';

  @override
  String get statProductsTrend => '+12% this month';

  @override
  String get statOrdersTrend => '+8% this month';

  @override
  String get statCustomersTrend => '+5% this month';

  @override
  String get statResourcesTrend => '2 added this week';

  @override
  String activityOrder(Object id) {
    return 'New order $id received';
  }

  @override
  String activityLowStock(Object name) {
    return 'Low stock for $name';
  }

  @override
  String activityCustomer(Object name) {
    return 'New customer: $name';
  }

  @override
  String activityResource(Object name) {
    return '$name added to resources';
  }

  @override
  String get timeToday => 'Today';

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String get actionAddProduct => 'Add product';

  @override
  String get actionNewOrder => 'New order';

  @override
  String get actionAddCustomer => 'Add customer';

  @override
  String get actionAddResource => 'Add resource';

  @override
  String get actionAddForm => 'New form';

  @override
  String get actionAddPage => 'New page';

  @override
  String get actionComingSoon => 'Available in a later phase';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionClose => 'Close';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionCopied => 'Copied to clipboard.';

  @override
  String searchIn(Object section) {
    return 'Search in $section';
  }

  @override
  String emptySearch(Object query) {
    return 'No results for “$query”.';
  }

  @override
  String resultCount(Object count) {
    return '$count results';
  }

  @override
  String get productsSubtitle =>
      'Manage your catalogue, prices and stock levels.';

  @override
  String get ordersSubtitle => 'Track every order from payment to delivery.';

  @override
  String get customersSubtitle => 'Your customer base and purchase history.';

  @override
  String get resourcesSubtitle => 'Documents, media and shared files.';

  @override
  String get formsSubtitle => 'Build forms and collect submissions.';

  @override
  String get pagesSubtitle => 'Create and manage the pages of your platform.';

  @override
  String get storeSubtitle =>
      'Preview your storefront, running entirely on this device.';

  @override
  String get colName => 'Name';

  @override
  String get colSku => 'SKU';

  @override
  String get colCategory => 'Category';

  @override
  String get colPrice => 'Price';

  @override
  String get colStock => 'Stock';

  @override
  String get colStatus => 'Status';

  @override
  String get colOrder => 'Order';

  @override
  String get colCustomer => 'Customer';

  @override
  String get colDate => 'Date';

  @override
  String get colTotal => 'Total';

  @override
  String get colEmail => 'Email';

  @override
  String get colOrders => 'Orders';

  @override
  String get colSpent => 'Total spent';

  @override
  String get colTier => 'Tier';

  @override
  String get colType => 'Type';

  @override
  String get colSize => 'Size';

  @override
  String get colUpdated => 'Updated';

  @override
  String get colSubmissions => 'Submissions';

  @override
  String get colTitle => 'Title';

  @override
  String get colSlug => 'Slug';

  @override
  String get statusActive => 'Active';

  @override
  String get statusLow => 'Low stock';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPublished => 'Published';

  @override
  String get statusNew => 'New';

  @override
  String get statusVip => 'VIP';

  @override
  String get statusRegular => 'Regular';

  @override
  String get typeDocument => 'Document';

  @override
  String get typeSpreadsheet => 'Spreadsheet';

  @override
  String get typeImage => 'Image';

  @override
  String get typeFolder => 'Folder';

  @override
  String get productsLowStockTitle => 'Low stock';

  @override
  String productsLowStock(Object count) {
    return '$count low in stock';
  }

  @override
  String get productsValueTitle => 'Inventory value';

  @override
  String get ordersPendingTitle => 'Pending';

  @override
  String ordersPending(Object count) {
    return '$count pending';
  }

  @override
  String get ordersRevenueTitle => 'Revenue';

  @override
  String get customersVipTitle => 'VIP customers';

  @override
  String customersVip(Object count) {
    return '$count VIP';
  }

  @override
  String get customersValueTitle => 'Total spent';

  @override
  String get resourcesUsedTitle => 'Storage used';

  @override
  String formsSubmissions(Object count) {
    return '$count submissions';
  }

  @override
  String formsPublished(Object count) {
    return '$count published';
  }

  @override
  String pagesPublished(Object count) {
    return '$count published';
  }

  @override
  String pagesDraft(Object count) {
    return '$count draft';
  }

  @override
  String get storeOpen => 'Open storefront';

  @override
  String get storeBannerTitle => 'New season, new stock';

  @override
  String get storeBannerBody =>
      'Browse the demo catalogue. Everything runs locally, no server required.';

  @override
  String get storeBannerCta => 'Browse products';

  @override
  String get addToCart => 'Add to cart';

  @override
  String addedToCart(Object name) {
    return '$name added to your cart.';
  }

  @override
  String get storeCartTitle => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty.';

  @override
  String storeCartItems(Object count) {
    return '$count items in cart';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Everything about language, alerts, privacy and data.';

  @override
  String get settingsSearchHint => 'Search settings';

  @override
  String settingsNoResults(Object query) {
    return 'No settings match “$query”.';
  }

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionGeneralDesc => 'Language, appearance and visual style.';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionNotificationsDesc => 'Choose which alerts you want to see.';

  @override
  String get sectionPrivacy => 'Privacy & policy';

  @override
  String get sectionPrivacyDesc =>
      'Data preferences, privacy policy and terms.';

  @override
  String get sectionData => 'Data & storage';

  @override
  String get sectionDataDesc => 'Export, reset and local storage.';

  @override
  String get sectionAbout => 'About';

  @override
  String get sectionAboutDesc => 'Version, licenses and contact.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageDescription => 'Choose the application language.';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceDescription => 'Choose light, dark or system mode.';

  @override
  String get modeSystem => 'System';

  @override
  String get modeLight => 'Light';

  @override
  String get modeDark => 'Dark';

  @override
  String get styleTitle => 'Style';

  @override
  String get styleDescription =>
      'Change the visual style of the whole application.';

  @override
  String get styleModern => 'Modern';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleProfessional => 'Professional';

  @override
  String get styleModernDesc => 'Rounded, colorful and friendly.';

  @override
  String get styleMinimalDesc => 'Flat, sharp and quiet.';

  @override
  String get styleProfessionalDesc => 'Compact, formal and dense.';

  @override
  String get notifOrders => 'New orders';

  @override
  String get notifOrdersDesc => 'Get notified when a new order arrives.';

  @override
  String get notifLowStock => 'Low stock alerts';

  @override
  String get notifLowStockDesc => 'Warn me when a product is about to run out.';

  @override
  String get notifWeekly => 'Weekly summary';

  @override
  String get notifWeeklyDesc => 'A recap of activity every Monday.';

  @override
  String get privacyAnalytics => 'Anonymous analytics';

  @override
  String get privacyAnalyticsDesc =>
      'Share anonymous usage counts to improve the app.';

  @override
  String get privacyCrash => 'Crash reports';

  @override
  String get privacyCrashDesc =>
      'Send diagnostic reports when something fails.';

  @override
  String get privacyPersonalization => 'Personalization';

  @override
  String get privacyPersonalizationDesc =>
      'Remember dashboard preferences on this device.';

  @override
  String get privacyPolicyAction => 'Read the privacy policy';

  @override
  String get privacyPolicyActionDesc =>
      'How your data is stored and protected.';

  @override
  String get termsAction => 'Read the terms of service';

  @override
  String get termsActionDesc => 'The rules that apply when you use diali.';

  @override
  String get consentTitle => 'Policy consent';

  @override
  String consentAccepted(Object date) {
    return 'Accepted on $date.';
  }

  @override
  String get consentPending => 'The current policy has not been accepted yet.';

  @override
  String get consentAction => 'Review & accept';

  @override
  String get consentUpdated => 'Policy updated';

  @override
  String get consentAcceptedToast =>
      'Thank you — your consent has been recorded.';

  @override
  String get policyAccept => 'Accept policy';

  @override
  String get policyNotNow => 'Not now';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyIntro =>
      'diali runs entirely on your device. This policy explains what is stored locally, what optional data you can share, and how to change your mind at any time.';

  @override
  String get privacyIntroTitle => 'Overview';

  @override
  String get privacyCollectTitle => 'Data stored on your device';

  @override
  String get privacyCollectBody =>
      'Language, appearance, style, notification and privacy preferences are stored in the local application database. No account is created and nothing is sent to a server.';

  @override
  String get privacyOptionalTitle => 'Optional data';

  @override
  String get privacyOptionalBody =>
      'Anonymous analytics and crash reports are disabled by default. You can enable them at any time from Settings → Privacy & policy, and revoke consent the same way.';

  @override
  String get privacyLocalTitle => 'Local storage only';

  @override
  String get privacyLocalBody =>
      'The application uses local storage on this device. Clearing the application data or uninstalling it removes everything.';

  @override
  String get privacyRightsTitle => 'Your rights';

  @override
  String get privacyRightsBody =>
      'You can review, change or delete your preferences at any time from Settings → Data & storage, where every setting can be reset to its default value.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String privacyContactBody(Object email) {
    return 'Questions about this policy? Write to $email.';
  }

  @override
  String privacyUpdatedOn(Object date) {
    return 'Last updated: $date';
  }

  @override
  String get privacyUpdatedTitle => 'Last updated';

  @override
  String get termsTitle => 'Terms of service';

  @override
  String get termsAcceptTitle => 'Acceptance';

  @override
  String get termsAcceptBody =>
      'By using diali you agree to these terms. If you do not agree, do not use the application.';

  @override
  String get termsUseTitle => 'Permitted use';

  @override
  String get termsUseBody =>
      'The application is provided for managing your own business data. You are responsible for the accuracy of the content you enter.';

  @override
  String get termsAvailabilityTitle => 'Availability';

  @override
  String get termsAvailabilityBody =>
      'This release is a local base application without backend services. Features may change between versions.';

  @override
  String get termsLiabilityTitle => 'Liability';

  @override
  String get termsLiabilityBody =>
      'The application is provided “as is”, without warranty of any kind. To the maximum extent permitted by law, the author is not liable for any loss of data or profit.';

  @override
  String get termsChangesTitle => 'Changes';

  @override
  String get termsChangesBody =>
      'We may update these terms and the privacy policy. When the policy changes you will be asked to review and accept it again from Settings.';

  @override
  String get termsContactTitle => 'Contact';

  @override
  String termsContactBody(Object email) {
    return 'Questions about these terms? Write to $email.';
  }

  @override
  String get dataStorage => 'Local storage';

  @override
  String get dataStorageDesc =>
      'Preferences are saved on this device only. No account, no server, no sync.';

  @override
  String get dataExport => 'Export settings';

  @override
  String get dataExportDesc => 'Download your preferences as a JSON file.';

  @override
  String get dataExportTitle => 'Your settings';

  @override
  String get dataReset => 'Reset all settings';

  @override
  String get dataResetDesc =>
      'Restore language, appearance, style, notifications and privacy to their defaults.';

  @override
  String get dataResetTitle => 'Reset all settings?';

  @override
  String get dataResetBody =>
      'This cannot be undone. Every preference will return to its default value.';

  @override
  String get dataResetConfirm => 'Reset';

  @override
  String get aboutVersion => 'App version';

  @override
  String get aboutBuild => 'Build number';

  @override
  String get aboutLicenses => 'Open-source licenses';

  @override
  String get aboutLicensesDesc => 'Licenses of the packages used by diali.';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutContactDesc => 'Questions, feedback and support.';

  @override
  String get aboutOffline => 'Works offline';

  @override
  String get aboutOfflineDesc =>
      'diali runs fully locally, without an internet connection.';

  @override
  String get navCategories => 'Categories';

  @override
  String get dashboardRecentOrders => 'Recent orders';

  @override
  String get dashboardRecentProducts => 'Recent products';

  @override
  String get dashboardLatestArticles => 'Latest articles';

  @override
  String get dashboardRecentDirectory => 'Directory highlights';

  @override
  String get dashboardNoOrders =>
      'No orders yet. Orders placed in the storefront appear here.';

  @override
  String get dashboardNoProducts =>
      'No products yet. Add your first product to get started.';

  @override
  String get dashboardNoArticles => 'No articles yet.';

  @override
  String get dashboardNoDirectory => 'No directory resources yet.';

  @override
  String get dashboardInventoryValue => 'Inventory value';

  @override
  String get dashboardTotalCategories => 'Categories';

  @override
  String get dashboardRevenue => 'Revenue';

  @override
  String get dashboardPublishedArticles => 'Published articles';

  @override
  String get categoriesSubtitle =>
      'Organize your catalogue with reusable categories.';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categorySlug => 'Slug';

  @override
  String get categoryDescription => 'Description';

  @override
  String get categoryNameRequired => 'A category name is required.';

  @override
  String get categoryNameExists => 'A category with this name already exists.';

  @override
  String get categoryCreated => 'Category created.';

  @override
  String get categoryUpdated => 'Category updated.';

  @override
  String get categoryDeleted => 'Category deleted.';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String deleteCategoryBody(Object name) {
    return 'Are you sure you want to delete “$name”?';
  }

  @override
  String deleteCategoryInUse(Object count) {
    return '$count product(s) use this category. They will be moved to Uncategorized.';
  }

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get storeProfileTitle => 'Store profile';

  @override
  String get storeProfileDescription =>
      'Public storefront name, branding and contact details.';

  @override
  String get storeName => 'Store name';

  @override
  String get storeDescriptionLabel => 'Store description';

  @override
  String get storeLogoUrl => 'Logo image URL';

  @override
  String get storeContactEmail => 'Contact email';

  @override
  String get storeContactPhone => 'Contact phone';

  @override
  String get storeAddress => 'Address';

  @override
  String get storefrontTemplate => 'Storefront template';

  @override
  String get storefrontTemplateDesc =>
      'Customer-facing design. Modern, minimal or professional.';

  @override
  String get templateModern => 'Modern';

  @override
  String get templateMinimal => 'Minimal';

  @override
  String get templateProfessional => 'Professional';

  @override
  String get saved => 'Saved.';

  @override
  String get demoDataTitle => 'Demo data';

  @override
  String get demoDataDesc =>
      'Load sample products and categories with local images.';

  @override
  String get demoDataAction => 'Load demo data';

  @override
  String get demoDataLoading => 'Loading demo data…';

  @override
  String demoDataResult(Object categories, Object products) {
    return 'Added $products products and $categories categories.';
  }

  @override
  String get demoDataAlready => 'Demo data is already loaded.';

  @override
  String get demoDataFailed => 'Could not load demo data.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Sign in to manage your business.';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginEmailRequired => 'Enter your email address.';

  @override
  String get loginEmailInvalid => 'Enter a valid email address.';

  @override
  String get loginPasswordRequired => 'Enter your password.';

  @override
  String get loginFailed =>
      'Sign in failed. Check your credentials and try again.';

  @override
  String get loginOfflineNotice => 'Running offline — no sign-in required.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountDescription => 'Your sign-in and session.';

  @override
  String accountSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get accountLocalMode => 'Offline mode — no account required.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody =>
      'You will need to sign in again to access the dashboard.';

  @override
  String get signOutConfirm => 'Sign out';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionView => 'View';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionSaveChanges => 'Save changes';

  @override
  String get actionClear => 'Clear';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get noRecordsTitle => 'No records found';

  @override
  String get searchDefaultHint => 'Search...';

  @override
  String get loadFailed => 'Could not load data. Please try again.';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get changesSaved => 'Changes saved.';

  @override
  String get recordCreated => 'Created successfully.';

  @override
  String get recordUpdated => 'Updated successfully.';

  @override
  String get recordDeleted => 'Deleted successfully.';

  @override
  String get operationFailed => 'The operation could not be completed.';

  @override
  String deleteDialogTitle(Object name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteDialogBody => 'This action cannot be undone.';

  @override
  String get guestLabel => 'Guest';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get taxLabel => 'Tax';

  @override
  String get shippingLabel => 'Shipping';

  @override
  String get totalAmountLabel => 'Total amount';

  @override
  String get allCategories => 'All categories';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get allTiers => 'All tiers';

  @override
  String get colProduct => 'Product';

  @override
  String get colContact => 'Contact';

  @override
  String get colLocation => 'Location';

  @override
  String get colDetails => 'Details';

  @override
  String get colItems => 'Items';

  @override
  String get colActions => 'Actions';

  @override
  String get statusArchived => 'Archived';

  @override
  String get statusHidden => 'Hidden';

  @override
  String get statActive => 'Active';

  @override
  String get statLowStock => 'Low stock';

  @override
  String get statOutOfStock => 'Out of stock';

  @override
  String itemCount(Object count) {
    return '$count items';
  }

  @override
  String get productDetailsTitle => 'Product details';

  @override
  String get demoPrice => 'Demo price';

  @override
  String get inStock => 'In stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get lowStock => 'Low stock';

  @override
  String get searchProductsHint => 'Search products by name or SKU...';

  @override
  String get productsEmptyTitle => 'No products found';

  @override
  String get productsEmptyMessage =>
      'Try adjusting your search or add a new product.';

  @override
  String get productCreated => 'Product created.';

  @override
  String get productUpdated => 'Product updated.';

  @override
  String get productDeleted => 'Product deleted.';

  @override
  String get deleteProductTitle => 'Delete product?';

  @override
  String deleteProductBody(Object name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String stockUnits(Object count) {
    return '$count in stock';
  }

  @override
  String get lowBadge => 'Low';

  @override
  String get editProductTitle => 'Edit product';

  @override
  String get productNameLabel => 'Product name';

  @override
  String get productPriceLabel => 'Price';

  @override
  String get productCostLabel => 'Cost';

  @override
  String get productStockLabel => 'Stock quantity';

  @override
  String get productStatusLabel => 'Status';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productNameRequired => 'A product name is required.';

  @override
  String get searchOrdersHint => 'Search orders by order number or customer...';

  @override
  String get orderHistorySubtitle => 'Find, view and reprint any past order.';

  @override
  String get searchHistoryHint => 'Search by order number or customer...';

  @override
  String get orderDateLabel => 'Order date';

  @override
  String get dateRangeFilter => 'Date range';

  @override
  String get clearDateFilter => 'Clear date filter';

  @override
  String get colQty => 'Qty';

  @override
  String get unitPriceLabel => 'Unit price';

  @override
  String get discountLabel => 'Discount';

  @override
  String get notesLabel => 'Notes';

  @override
  String get historyEmptyTitle => 'No orders match your filters';

  @override
  String get historyEmptyMessage =>
      'Try adjusting the search text, date range or status filter.';

  @override
  String get printOrder => 'Print order';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get printDocumentFailed =>
      'Could not prepare the print document. Please try again.';

  @override
  String get orderDocumentTitle => 'Order receipt';

  @override
  String reprintFooter(Object date) {
    return 'Reprinted on $date from the original order data.';
  }

  @override
  String get customerInformation => 'Customer information';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get addressLabel => 'Address';

  @override
  String get updateStatusTitle => 'Update status';

  @override
  String get markPaid => 'Mark as paid';

  @override
  String get markShipped => 'Mark as shipped';

  @override
  String get markDelivered => 'Mark as delivered';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get cancelOrderTitle => 'Cancel this order?';

  @override
  String get cancelOrderBody => 'This order will be marked as cancelled.';

  @override
  String get ordersEmptyTitle => 'No orders found';

  @override
  String get ordersEmptyMessage => 'Try clearing the filters or search terms.';

  @override
  String get orderStatusUpdated => 'Order status updated.';

  @override
  String orderLabel(Object number) {
    return 'Order $number';
  }

  @override
  String get editCustomerTitle => 'Edit customer';

  @override
  String get customerNameLabel => 'Full name';

  @override
  String get customerPhoneLabel => 'Phone';

  @override
  String get customerCityLabel => 'City';

  @override
  String get customerCountryLabel => 'Country';

  @override
  String get customerAddressLabel => 'Street address';

  @override
  String get customerTierLabel => 'Customer tier';

  @override
  String get customerNotesLabel => 'Internal notes';

  @override
  String get searchCustomersHint => 'Search by name, email, phone, or city...';

  @override
  String get customersEmptyTitle => 'No customers found';

  @override
  String get customersEmptyMessage => 'Add a new customer to get started.';

  @override
  String get customerCreated => 'Customer created.';

  @override
  String get customerUpdated => 'Customer updated.';

  @override
  String get customerDeleted => 'Customer deleted.';

  @override
  String get deleteCustomerTitle => 'Delete customer?';

  @override
  String get spentLabel => 'Spent';

  @override
  String get statVipClients => 'VIP clients';

  @override
  String get statLifetimeValue => 'Lifetime value';

  @override
  String get storefrontTitle => 'Storefront';

  @override
  String get shopByCategory => 'Shop by category';

  @override
  String get featuredProducts => 'Featured products';

  @override
  String get latestProducts => 'Latest products';

  @override
  String get allProducts => 'All products';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmptyMessage => 'Your cart is empty.';

  @override
  String get checkoutAction => 'Checkout & place order';

  @override
  String orderPlaced(Object number) {
    return 'Order $number placed successfully.';
  }

  @override
  String get orderFailed => 'Could not place the order.';

  @override
  String get estimatedTax => 'Estimated tax';

  @override
  String get storefrontSubtitle =>
      'Browse products and preview the online customer experience.';

  @override
  String productsInCategory(Object category) {
    return 'Products in $category';
  }

  @override
  String get noProductsInCategoryTitle => 'No products in this category';

  @override
  String get noProductsInCategoryMessage => 'Try selecting another category.';

  @override
  String get generalLabel => 'General';

  @override
  String get eachLabel => 'each';

  @override
  String get bannerNewArrivals => 'New arrivals';

  @override
  String get bannerLocalDelivery => 'Local delivery';

  @override
  String get bannerStorePickup => 'Store pickup';

  @override
  String get storeCustomerName => 'Storefront customer';

  @override
  String get storeOrderNote => 'Storefront online order';

  @override
  String get removeFromCart => 'Remove from cart';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get catRoot => 'Root categories';

  @override
  String get catSub => 'Sub-categories';

  @override
  String get catShopBy => 'Shop by category';

  @override
  String get catTapHint => 'Tap a category to see its products.';

  @override
  String get catSearchHint => 'Search categories...';

  @override
  String get catNoProducts => 'No products in this category';

  @override
  String catNoProductsHint(Object category) {
    return 'Add products and assign them to $category.';
  }

  @override
  String catProductCount(Object count) {
    return '$count products';
  }

  @override
  String get categoriesEmptyTitle => 'No categories yet';

  @override
  String get categoriesEmptyMessage =>
      'Create your first category to organize products.';

  @override
  String get colProducts => 'Products';

  @override
  String get colDescription => 'Description';

  @override
  String get productImagesLabel => 'Product images';

  @override
  String get productImagesHint =>
      'Recommended 800 x 1000 (4:5). The first image is the main one. Card thumbnails use 300 x 375 (4:5).';

  @override
  String get imageMainBadge => 'Main';

  @override
  String get imageSetMain => 'Set as main';

  @override
  String get imageReplace => 'Replace';

  @override
  String get imageMoveBackward => 'Move left';

  @override
  String get imageMoveForward => 'Move right';

  @override
  String get imageAdd => 'Add image';

  @override
  String get imageOptions => 'Image options';

  @override
  String get removeImageTitle => 'Remove this image?';

  @override
  String get removeImageBody =>
      'The image will be removed from the product. This cannot be undone.';

  @override
  String get imageRemoved => 'Image removed.';

  @override
  String get noImage => 'No image';

  @override
  String get categoryImageLabel => 'Category image';

  @override
  String get categoryImageHint => 'Recommended 600 x 600 (1:1).';

  @override
  String get selectImage => 'Select image';

  @override
  String get removeCategoryImageBody =>
      'The image will be removed from the category. This cannot be undone.';

  @override
  String imageCounter(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get checkoutNameTooShort => 'Please enter the customer\'s full name.';

  @override
  String get checkoutPhoneInvalid =>
      'Enter a valid phone number (7-15 digits).';

  @override
  String get checkoutQuantityInvalid => 'Item quantity must be at least 1.';

  @override
  String checkoutInsufficientStock(Object available, Object product) {
    return 'Only $available left of $product.';
  }

  @override
  String get checkoutAddressTooLong =>
      'Address is too long (max 300 characters).';

  @override
  String get checkoutCityTooLong => 'City is too long (max 120 characters).';

  @override
  String get businessLocation => 'Business location';

  @override
  String get businessLocationHint =>
      'Shown on the storefront map and used for directions.';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get locationPermissionDenied => 'Location permission was denied.';

  @override
  String get locationServicesDisabled => 'Location services are turned off.';

  @override
  String get locationUnavailable => 'Could not determine your location.';

  @override
  String get locationInvalid =>
      'Enter a latitude between -90 and 90 and a longitude between -180 and 180.';

  @override
  String get openInMaps => 'Open in maps';

  @override
  String get socialMedia => 'Social media';

  @override
  String get socialMediaHint =>
      'Add the business profile links shown on the storefront.';

  @override
  String get socialInstagram => 'Instagram';

  @override
  String get socialFacebook => 'Facebook';

  @override
  String get socialTiktok => 'TikTok';

  @override
  String get socialWhatsapp => 'WhatsApp';

  @override
  String get socialYoutube => 'YouTube';

  @override
  String get socialLinkedin => 'LinkedIn';

  @override
  String get socialUrlLabel => 'Profile URL';

  @override
  String get socialInvalidUrl => 'Enter a valid http(s) link.';

  @override
  String get trackOrderTitle => 'Track your order';

  @override
  String get trackOrderSubtitle =>
      'Enter your order number and the phone number used at checkout.';

  @override
  String get orderNumberLabel => 'Order number';

  @override
  String get trackOrderAction => 'Track order';

  @override
  String get trackOrderRequired =>
      'Enter both the order number and phone number.';

  @override
  String get trackOrderNotFound =>
      'No order matches those details. Check the order number and phone, then try again.';

  @override
  String get trackOrderFailed =>
      'Could not look up the order. Please try again.';

  @override
  String get trackOrderItems => 'Items';

  @override
  String get storefrontFollowUs => 'Follow us';

  @override
  String get chatOnWhatsapp => 'Chat on WhatsApp';

  @override
  String get chatOnWhatsappMessage =>
      'Hello! I would like to ask about my order.';

  @override
  String paginationRange(Object end, Object start, Object total) {
    return 'Showing $start-$end of $total';
  }

  @override
  String paginationPageOf(Object page, Object total) {
    return 'Page $page of $total';
  }

  @override
  String get paginationPrevious => 'Previous';

  @override
  String get paginationNext => 'Next';

  @override
  String get backToTop => 'Back to top';

  @override
  String get hideSidebar => 'Hide sidebar';

  @override
  String get showSidebar => 'Show sidebar';

  @override
  String get trackingTitle => 'Shipment tracking';

  @override
  String get trackingStageOrderReceived => 'Order received';

  @override
  String get trackingStageProcessing => 'Processing';

  @override
  String get trackingStageShipped => 'Shipped';

  @override
  String get trackingStageInTransit => 'In transit';

  @override
  String get trackingStageOutForDelivery => 'Out for delivery';

  @override
  String get trackingStageDelivered => 'Delivered';

  @override
  String get trackingNumberLabel => 'Tracking number';

  @override
  String get shippingCompanyLabel => 'Shipping company';

  @override
  String get shipmentDateLabel => 'Shipment date';

  @override
  String get estimatedDeliveryLabel => 'Estimated delivery';

  @override
  String get currentLocationLabel => 'Current location';

  @override
  String get latestUpdateLabel => 'Latest update';

  @override
  String get trackingUnavailable =>
      'Tracking information is not available yet.';

  @override
  String get trackingCancelled => 'This order was cancelled.';
}
