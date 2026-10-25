import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'diali'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get navOrderHistory;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get navResources;

  /// No description provided for @navForms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get navForms;

  /// No description provided for @navPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get navPages;

  /// No description provided for @navStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get navStore;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @openNavigation.
  ///
  /// In en, this message translates to:
  /// **'Open navigation menu'**
  String get openNavigation;

  /// No description provided for @closeNavigation.
  ///
  /// In en, this message translates to:
  /// **'Close navigation menu'**
  String get closeNavigation;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is what is happening in your business today.'**
  String get dashboardSubtitle;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @statProducts.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get statProducts;

  /// No description provided for @statOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get statOrders;

  /// No description provided for @statCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total customers'**
  String get statCustomers;

  /// No description provided for @statResources.
  ///
  /// In en, this message translates to:
  /// **'Total resources'**
  String get statResources;

  /// No description provided for @statProductsTrend.
  ///
  /// In en, this message translates to:
  /// **'+12% this month'**
  String get statProductsTrend;

  /// No description provided for @statOrdersTrend.
  ///
  /// In en, this message translates to:
  /// **'+8% this month'**
  String get statOrdersTrend;

  /// No description provided for @statCustomersTrend.
  ///
  /// In en, this message translates to:
  /// **'+5% this month'**
  String get statCustomersTrend;

  /// No description provided for @statResourcesTrend.
  ///
  /// In en, this message translates to:
  /// **'2 added this week'**
  String get statResourcesTrend;

  /// No description provided for @activityOrder.
  ///
  /// In en, this message translates to:
  /// **'New order {id} received'**
  String activityOrder(Object id);

  /// No description provided for @activityLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock for {name}'**
  String activityLowStock(Object name);

  /// No description provided for @activityCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer: {name}'**
  String activityCustomer(Object name);

  /// No description provided for @activityResource.
  ///
  /// In en, this message translates to:
  /// **'{name} added to resources'**
  String activityResource(Object name);

  /// No description provided for @timeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timeToday;

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @actionAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get actionAddProduct;

  /// No description provided for @actionNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get actionNewOrder;

  /// No description provided for @actionAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get actionAddCustomer;

  /// No description provided for @actionAddResource.
  ///
  /// In en, this message translates to:
  /// **'Add resource'**
  String get actionAddResource;

  /// No description provided for @actionAddForm.
  ///
  /// In en, this message translates to:
  /// **'New form'**
  String get actionAddForm;

  /// No description provided for @actionAddPage.
  ///
  /// In en, this message translates to:
  /// **'New page'**
  String get actionAddPage;

  /// No description provided for @actionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Available in a later phase'**
  String get actionComingSoon;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get actionCopied;

  /// No description provided for @searchIn.
  ///
  /// In en, this message translates to:
  /// **'Search in {section}'**
  String searchIn(Object section);

  /// No description provided for @emptySearch.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”.'**
  String emptySearch(Object query);

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultCount(Object count);

  /// No description provided for @productsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your catalogue, prices and stock levels.'**
  String get productsSubtitle;

  /// No description provided for @ordersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track every order from payment to delivery.'**
  String get ordersSubtitle;

  /// No description provided for @customersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your customer base and purchase history.'**
  String get customersSubtitle;

  /// No description provided for @resourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Documents, media and shared files.'**
  String get resourcesSubtitle;

  /// No description provided for @formsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build forms and collect submissions.'**
  String get formsSubtitle;

  /// No description provided for @pagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage the pages of your platform.'**
  String get pagesSubtitle;

  /// No description provided for @storeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview your storefront, running entirely on this device.'**
  String get storeSubtitle;

  /// No description provided for @colName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get colName;

  /// No description provided for @colSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get colSku;

  /// No description provided for @colCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get colCategory;

  /// No description provided for @colPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get colPrice;

  /// No description provided for @colStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get colStock;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @colOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get colOrder;

  /// No description provided for @colCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get colCustomer;

  /// No description provided for @colDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get colTotal;

  /// No description provided for @colEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get colEmail;

  /// No description provided for @colOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get colOrders;

  /// No description provided for @colSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get colSpent;

  /// No description provided for @colTier.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get colTier;

  /// No description provided for @colType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get colType;

  /// No description provided for @colSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get colSize;

  /// No description provided for @colUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get colUpdated;

  /// No description provided for @colSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get colSubmissions;

  /// No description provided for @colTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get colTitle;

  /// No description provided for @colSlug.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get colSlug;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get statusLow;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get statusPublished;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get statusVip;

  /// No description provided for @statusRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get statusRegular;

  /// No description provided for @typeDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get typeDocument;

  /// No description provided for @typeSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get typeSpreadsheet;

  /// No description provided for @typeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get typeImage;

  /// No description provided for @typeFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get typeFolder;

  /// No description provided for @productsLowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get productsLowStockTitle;

  /// No description provided for @productsLowStock.
  ///
  /// In en, this message translates to:
  /// **'{count} low in stock'**
  String productsLowStock(Object count);

  /// No description provided for @productsValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory value'**
  String get productsValueTitle;

  /// No description provided for @ordersPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersPendingTitle;

  /// No description provided for @ordersPending.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String ordersPending(Object count);

  /// No description provided for @ordersRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get ordersRevenueTitle;

  /// No description provided for @customersVipTitle.
  ///
  /// In en, this message translates to:
  /// **'VIP customers'**
  String get customersVipTitle;

  /// No description provided for @customersVip.
  ///
  /// In en, this message translates to:
  /// **'{count} VIP'**
  String customersVip(Object count);

  /// No description provided for @customersValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get customersValueTitle;

  /// No description provided for @resourcesUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get resourcesUsedTitle;

  /// No description provided for @formsSubmissions.
  ///
  /// In en, this message translates to:
  /// **'{count} submissions'**
  String formsSubmissions(Object count);

  /// No description provided for @formsPublished.
  ///
  /// In en, this message translates to:
  /// **'{count} published'**
  String formsPublished(Object count);

  /// No description provided for @pagesPublished.
  ///
  /// In en, this message translates to:
  /// **'{count} published'**
  String pagesPublished(Object count);

  /// No description provided for @pagesDraft.
  ///
  /// In en, this message translates to:
  /// **'{count} draft'**
  String pagesDraft(Object count);

  /// No description provided for @storeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open storefront'**
  String get storeOpen;

  /// No description provided for @storeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'New season, new stock'**
  String get storeBannerTitle;

  /// No description provided for @storeBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Browse the demo catalogue. Everything runs locally, no server required.'**
  String get storeBannerBody;

  /// No description provided for @storeBannerCta.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get storeBannerCta;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your cart.'**
  String addedToCart(Object name);

  /// No description provided for @storeCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get storeCartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get cartEmpty;

  /// No description provided for @storeCartItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items in cart'**
  String storeCartItems(Object count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything about language, alerts, privacy and data.'**
  String get settingsSubtitle;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settingsSearchHint;

  /// No description provided for @settingsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No settings match “{query}”.'**
  String settingsNoResults(Object query);

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Language, appearance and visual style.'**
  String get sectionGeneralDesc;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// No description provided for @sectionNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which alerts you want to see.'**
  String get sectionNotificationsDesc;

  /// No description provided for @sectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & policy'**
  String get sectionPrivacy;

  /// No description provided for @sectionPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'Data preferences, privacy policy and terms.'**
  String get sectionPrivacyDesc;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data & storage'**
  String get sectionData;

  /// No description provided for @sectionDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Export, reset and local storage.'**
  String get sectionDataDesc;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @sectionAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Version, licenses and contact.'**
  String get sectionAboutDesc;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the application language.'**
  String get languageDescription;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose light, dark or system mode.'**
  String get appearanceDescription;

  /// No description provided for @modeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get modeSystem;

  /// No description provided for @modeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get modeLight;

  /// No description provided for @modeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get modeDark;

  /// No description provided for @styleTitle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get styleTitle;

  /// No description provided for @styleDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the visual style of the whole application.'**
  String get styleDescription;

  /// No description provided for @styleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get styleModern;

  /// No description provided for @styleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get styleMinimal;

  /// No description provided for @styleProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get styleProfessional;

  /// No description provided for @styleModernDesc.
  ///
  /// In en, this message translates to:
  /// **'Rounded, colorful and friendly.'**
  String get styleModernDesc;

  /// No description provided for @styleMinimalDesc.
  ///
  /// In en, this message translates to:
  /// **'Flat, sharp and quiet.'**
  String get styleMinimalDesc;

  /// No description provided for @styleProfessionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Compact, formal and dense.'**
  String get styleProfessionalDesc;

  /// No description provided for @notifOrders.
  ///
  /// In en, this message translates to:
  /// **'New orders'**
  String get notifOrders;

  /// No description provided for @notifOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new order arrives.'**
  String get notifOrdersDesc;

  /// No description provided for @notifLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock alerts'**
  String get notifLowStock;

  /// No description provided for @notifLowStockDesc.
  ///
  /// In en, this message translates to:
  /// **'Warn me when a product is about to run out.'**
  String get notifLowStockDesc;

  /// No description provided for @notifWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get notifWeekly;

  /// No description provided for @notifWeeklyDesc.
  ///
  /// In en, this message translates to:
  /// **'A recap of activity every Monday.'**
  String get notifWeeklyDesc;

  /// No description provided for @privacyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Anonymous analytics'**
  String get privacyAnalytics;

  /// No description provided for @privacyAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage counts to improve the app.'**
  String get privacyAnalyticsDesc;

  /// No description provided for @privacyCrash.
  ///
  /// In en, this message translates to:
  /// **'Crash reports'**
  String get privacyCrash;

  /// No description provided for @privacyCrashDesc.
  ///
  /// In en, this message translates to:
  /// **'Send diagnostic reports when something fails.'**
  String get privacyCrashDesc;

  /// No description provided for @privacyPersonalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get privacyPersonalization;

  /// No description provided for @privacyPersonalizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Remember dashboard preferences on this device.'**
  String get privacyPersonalizationDesc;

  /// No description provided for @privacyPolicyAction.
  ///
  /// In en, this message translates to:
  /// **'Read the privacy policy'**
  String get privacyPolicyAction;

  /// No description provided for @privacyPolicyActionDesc.
  ///
  /// In en, this message translates to:
  /// **'How your data is stored and protected.'**
  String get privacyPolicyActionDesc;

  /// No description provided for @termsAction.
  ///
  /// In en, this message translates to:
  /// **'Read the terms of service'**
  String get termsAction;

  /// No description provided for @termsActionDesc.
  ///
  /// In en, this message translates to:
  /// **'The rules that apply when you use diali.'**
  String get termsActionDesc;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Policy consent'**
  String get consentTitle;

  /// No description provided for @consentAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted on {date}.'**
  String consentAccepted(Object date);

  /// No description provided for @consentPending.
  ///
  /// In en, this message translates to:
  /// **'The current policy has not been accepted yet.'**
  String get consentPending;

  /// No description provided for @consentAction.
  ///
  /// In en, this message translates to:
  /// **'Review & accept'**
  String get consentAction;

  /// No description provided for @consentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Policy updated'**
  String get consentUpdated;

  /// No description provided for @consentAcceptedToast.
  ///
  /// In en, this message translates to:
  /// **'Thank you — your consent has been recorded.'**
  String get consentAcceptedToast;

  /// No description provided for @policyAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept policy'**
  String get policyAccept;

  /// No description provided for @policyNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get policyNotNow;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'diali runs entirely on your device. This policy explains what is stored locally, what optional data you can share, and how to change your mind at any time.'**
  String get privacyIntro;

  /// No description provided for @privacyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get privacyIntroTitle;

  /// No description provided for @privacyCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Data stored on your device'**
  String get privacyCollectTitle;

  /// No description provided for @privacyCollectBody.
  ///
  /// In en, this message translates to:
  /// **'Language, appearance, style, notification and privacy preferences are stored in the local application database. No account is created and nothing is sent to a server.'**
  String get privacyCollectBody;

  /// No description provided for @privacyOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional data'**
  String get privacyOptionalTitle;

  /// No description provided for @privacyOptionalBody.
  ///
  /// In en, this message translates to:
  /// **'Anonymous analytics and crash reports are disabled by default. You can enable them at any time from Settings → Privacy & policy, and revoke consent the same way.'**
  String get privacyOptionalBody;

  /// No description provided for @privacyLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Local storage only'**
  String get privacyLocalTitle;

  /// No description provided for @privacyLocalBody.
  ///
  /// In en, this message translates to:
  /// **'The application uses local storage on this device. Clearing the application data or uninstalling it removes everything.'**
  String get privacyLocalBody;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You can review, change or delete your preferences at any time from Settings → Data & storage, where every setting can be reset to its default value.'**
  String get privacyRightsBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In en, this message translates to:
  /// **'Questions about this policy? Write to {email}.'**
  String privacyContactBody(Object email);

  /// No description provided for @privacyUpdatedOn.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String privacyUpdatedOn(Object date);

  /// No description provided for @privacyUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get privacyUpdatedTitle;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsTitle;

  /// No description provided for @termsAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance'**
  String get termsAcceptTitle;

  /// No description provided for @termsAcceptBody.
  ///
  /// In en, this message translates to:
  /// **'By using diali you agree to these terms. If you do not agree, do not use the application.'**
  String get termsAcceptBody;

  /// No description provided for @termsUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Permitted use'**
  String get termsUseTitle;

  /// No description provided for @termsUseBody.
  ///
  /// In en, this message translates to:
  /// **'The application is provided for managing your own business data. You are responsible for the accuracy of the content you enter.'**
  String get termsUseBody;

  /// No description provided for @termsAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get termsAvailabilityTitle;

  /// No description provided for @termsAvailabilityBody.
  ///
  /// In en, this message translates to:
  /// **'This release is a local base application without backend services. Features may change between versions.'**
  String get termsAvailabilityBody;

  /// No description provided for @termsLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get termsLiabilityTitle;

  /// No description provided for @termsLiabilityBody.
  ///
  /// In en, this message translates to:
  /// **'The application is provided “as is”, without warranty of any kind. To the maximum extent permitted by law, the author is not liable for any loss of data or profit.'**
  String get termsLiabilityBody;

  /// No description provided for @termsChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get termsChangesTitle;

  /// No description provided for @termsChangesBody.
  ///
  /// In en, this message translates to:
  /// **'We may update these terms and the privacy policy. When the policy changes you will be asked to review and accept it again from Settings.'**
  String get termsChangesBody;

  /// No description provided for @termsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get termsContactTitle;

  /// No description provided for @termsContactBody.
  ///
  /// In en, this message translates to:
  /// **'Questions about these terms? Write to {email}.'**
  String termsContactBody(Object email);

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'Local storage'**
  String get dataStorage;

  /// No description provided for @dataStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Preferences are saved on this device only. No account, no server, no sync.'**
  String get dataStorageDesc;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Export settings'**
  String get dataExport;

  /// No description provided for @dataExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Download your preferences as a JSON file.'**
  String get dataExportDesc;

  /// No description provided for @dataExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Your settings'**
  String get dataExportTitle;

  /// No description provided for @dataReset.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings'**
  String get dataReset;

  /// No description provided for @dataResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore language, appearance, style, notifications and privacy to their defaults.'**
  String get dataResetDesc;

  /// No description provided for @dataResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings?'**
  String get dataResetTitle;

  /// No description provided for @dataResetBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Every preference will return to its default value.'**
  String get dataResetBody;

  /// No description provided for @dataResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get dataResetConfirm;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get aboutVersion;

  /// No description provided for @aboutBuild.
  ///
  /// In en, this message translates to:
  /// **'Build number'**
  String get aboutBuild;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutLicensesDesc.
  ///
  /// In en, this message translates to:
  /// **'Licenses of the packages used by diali.'**
  String get aboutLicensesDesc;

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContact;

  /// No description provided for @aboutContactDesc.
  ///
  /// In en, this message translates to:
  /// **'Questions, feedback and support.'**
  String get aboutContactDesc;

  /// No description provided for @aboutOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get aboutOffline;

  /// No description provided for @aboutOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'diali runs fully locally, without an internet connection.'**
  String get aboutOfflineDesc;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @dashboardRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get dashboardRecentOrders;

  /// No description provided for @dashboardRecentProducts.
  ///
  /// In en, this message translates to:
  /// **'Recent products'**
  String get dashboardRecentProducts;

  /// No description provided for @dashboardLatestArticles.
  ///
  /// In en, this message translates to:
  /// **'Latest articles'**
  String get dashboardLatestArticles;

  /// No description provided for @dashboardRecentDirectory.
  ///
  /// In en, this message translates to:
  /// **'Directory highlights'**
  String get dashboardRecentDirectory;

  /// No description provided for @dashboardNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet. Orders placed in the storefront appear here.'**
  String get dashboardNoOrders;

  /// No description provided for @dashboardNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet. Add your first product to get started.'**
  String get dashboardNoProducts;

  /// No description provided for @dashboardNoArticles.
  ///
  /// In en, this message translates to:
  /// **'No articles yet.'**
  String get dashboardNoArticles;

  /// No description provided for @dashboardNoDirectory.
  ///
  /// In en, this message translates to:
  /// **'No directory resources yet.'**
  String get dashboardNoDirectory;

  /// No description provided for @dashboardInventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory value'**
  String get dashboardInventoryValue;

  /// No description provided for @dashboardTotalCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get dashboardTotalCategories;

  /// No description provided for @dashboardRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get dashboardRevenue;

  /// No description provided for @dashboardPublishedArticles.
  ///
  /// In en, this message translates to:
  /// **'Published articles'**
  String get dashboardPublishedArticles;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your catalogue with reusable categories.'**
  String get categoriesSubtitle;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categorySlug.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get categorySlug;

  /// No description provided for @categoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get categoryDescription;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'A category name is required.'**
  String get categoryNameRequired;

  /// No description provided for @categoryNameExists.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists.'**
  String get categoryNameExists;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created.'**
  String get categoryCreated;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated.'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted.'**
  String get categoryDeleted;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete “{name}”?'**
  String deleteCategoryBody(Object name);

  /// No description provided for @deleteCategoryInUse.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s) use this category. They will be moved to Uncategorized.'**
  String deleteCategoryInUse(Object count);

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @storeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Store profile'**
  String get storeProfileTitle;

  /// No description provided for @storeProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Public storefront name, branding and contact details.'**
  String get storeProfileDescription;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeName;

  /// No description provided for @storeDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Store description'**
  String get storeDescriptionLabel;

  /// No description provided for @storeLogoUrl.
  ///
  /// In en, this message translates to:
  /// **'Logo image URL'**
  String get storeLogoUrl;

  /// No description provided for @storeContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get storeContactEmail;

  /// No description provided for @storeContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get storeContactPhone;

  /// No description provided for @storeAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get storeAddress;

  /// No description provided for @storefrontTemplate.
  ///
  /// In en, this message translates to:
  /// **'Storefront template'**
  String get storefrontTemplate;

  /// No description provided for @storefrontTemplateDesc.
  ///
  /// In en, this message translates to:
  /// **'Customer-facing design. Modern, minimal or professional.'**
  String get storefrontTemplateDesc;

  /// No description provided for @templateModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get templateModern;

  /// No description provided for @templateMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get templateMinimal;

  /// No description provided for @templateProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get templateProfessional;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get saved;

  /// No description provided for @demoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo data'**
  String get demoDataTitle;

  /// No description provided for @demoDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Load sample products and categories with local images.'**
  String get demoDataDesc;

  /// No description provided for @demoDataAction.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get demoDataAction;

  /// No description provided for @demoDataLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading demo data…'**
  String get demoDataLoading;

  /// No description provided for @demoDataResult.
  ///
  /// In en, this message translates to:
  /// **'Added {products} products and {categories} categories.'**
  String demoDataResult(Object categories, Object products);

  /// No description provided for @demoDataAlready.
  ///
  /// In en, this message translates to:
  /// **'Demo data is already loaded.'**
  String get demoDataAlready;

  /// No description provided for @demoDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load demo data.'**
  String get demoDataFailed;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your business.'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get loginEmailHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get loginPasswordRequired;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Check your credentials and try again.'**
  String get loginFailed;

  /// No description provided for @loginOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Running offline — no sign-in required.'**
  String get loginOfflineNotice;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountDescription.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in and session.'**
  String get accountDescription;

  /// No description provided for @accountSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String accountSignedInAs(String email);

  /// No description provided for @accountLocalMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode — no account required.'**
  String get accountLocalMode;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access the dashboard.'**
  String get signOutConfirmBody;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirm;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get actionView;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSaveChanges;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @noRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noRecordsTitle;

  /// No description provided for @searchDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchDefaultHint;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Please try again.'**
  String get loadFailed;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get changesSaved;

  /// No description provided for @recordCreated.
  ///
  /// In en, this message translates to:
  /// **'Created successfully.'**
  String get recordCreated;

  /// No description provided for @recordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully.'**
  String get recordUpdated;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully.'**
  String get recordDeleted;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'The operation could not be completed.'**
  String get operationFailed;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteDialogTitle(Object name);

  /// No description provided for @deleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteDialogBody;

  /// No description provided for @guestLabel.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestLabel;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalLabel;

  /// No description provided for @taxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxLabel;

  /// No description provided for @shippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shippingLabel;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmountLabel;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @allTiers.
  ///
  /// In en, this message translates to:
  /// **'All tiers'**
  String get allTiers;

  /// No description provided for @colProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get colProduct;

  /// No description provided for @colContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get colContact;

  /// No description provided for @colLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get colLocation;

  /// No description provided for @colDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get colDetails;

  /// No description provided for @colItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get colItems;

  /// No description provided for @colActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get colActions;

  /// No description provided for @statusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// No description provided for @statusHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get statusHidden;

  /// No description provided for @statActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statActive;

  /// No description provided for @statLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get statLowStock;

  /// No description provided for @statOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get statOutOfStock;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(Object count);

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetailsTitle;

  /// No description provided for @demoPrice.
  ///
  /// In en, this message translates to:
  /// **'Demo price'**
  String get demoPrice;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products by name or SKU...'**
  String get searchProductsHint;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or add a new product.'**
  String get productsEmptyMessage;

  /// No description provided for @productCreated.
  ///
  /// In en, this message translates to:
  /// **'Product created.'**
  String get productCreated;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated.'**
  String get productUpdated;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted.'**
  String get productDeleted;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product?'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This cannot be undone.'**
  String deleteProductBody(Object name);

  /// No description provided for @stockUnits.
  ///
  /// In en, this message translates to:
  /// **'{count} in stock'**
  String stockUnits(Object count);

  /// No description provided for @lowBadge.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowBadge;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProductTitle;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productNameLabel;

  /// No description provided for @productPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPriceLabel;

  /// No description provided for @productCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get productCostLabel;

  /// No description provided for @productStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity'**
  String get productStockLabel;

  /// No description provided for @productStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get productStatusLabel;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionLabel;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'A product name is required.'**
  String get productNameRequired;

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Search orders by order number or customer...'**
  String get searchOrdersHint;

  /// No description provided for @orderHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find, view and reprint any past order.'**
  String get orderHistorySubtitle;

  /// No description provided for @searchHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search by order number or customer...'**
  String get searchHistoryHint;

  /// No description provided for @orderDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get orderDateLabel;

  /// No description provided for @dateRangeFilter.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRangeFilter;

  /// No description provided for @clearDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get clearDateFilter;

  /// No description provided for @colQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get colQty;

  /// No description provided for @unitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPriceLabel;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders match your filters'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the search text, date range or status filter.'**
  String get historyEmptyMessage;

  /// No description provided for @printOrder.
  ///
  /// In en, this message translates to:
  /// **'Print order'**
  String get printOrder;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @printDocumentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the print document. Please try again.'**
  String get printDocumentFailed;

  /// No description provided for @orderDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Order receipt'**
  String get orderDocumentTitle;

  /// No description provided for @reprintFooter.
  ///
  /// In en, this message translates to:
  /// **'Reprinted on {date} from the original order data.'**
  String reprintFooter(Object date);

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer information'**
  String get customerInformation;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @updateStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get updateStatusTitle;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get markPaid;

  /// No description provided for @markShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark as shipped'**
  String get markShipped;

  /// No description provided for @markDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered'**
  String get markDelivered;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrderBody.
  ///
  /// In en, this message translates to:
  /// **'This order will be marked as cancelled.'**
  String get cancelOrderBody;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the filters or search terms.'**
  String get ordersEmptyMessage;

  /// No description provided for @orderStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order status updated.'**
  String get orderStatusUpdated;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order {number}'**
  String orderLabel(Object number);

  /// No description provided for @editCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomerTitle;

  /// No description provided for @customerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get customerNameLabel;

  /// No description provided for @customerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customerPhoneLabel;

  /// No description provided for @customerCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get customerCityLabel;

  /// No description provided for @customerCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get customerCountryLabel;

  /// No description provided for @customerAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get customerAddressLabel;

  /// No description provided for @customerTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer tier'**
  String get customerTierLabel;

  /// No description provided for @customerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Internal notes'**
  String get customerNotesLabel;

  /// No description provided for @searchCustomersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, phone, or city...'**
  String get searchCustomersHint;

  /// No description provided for @customersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get customersEmptyTitle;

  /// No description provided for @customersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a new customer to get started.'**
  String get customersEmptyMessage;

  /// No description provided for @customerCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer created.'**
  String get customerCreated;

  /// No description provided for @customerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer updated.'**
  String get customerUpdated;

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted.'**
  String get customerDeleted;

  /// No description provided for @deleteCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete customer?'**
  String get deleteCustomerTitle;

  /// No description provided for @spentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentLabel;

  /// No description provided for @statVipClients.
  ///
  /// In en, this message translates to:
  /// **'VIP clients'**
  String get statVipClients;

  /// No description provided for @statLifetimeValue.
  ///
  /// In en, this message translates to:
  /// **'Lifetime value'**
  String get statLifetimeValue;

  /// No description provided for @storefrontTitle.
  ///
  /// In en, this message translates to:
  /// **'Storefront'**
  String get storefrontTitle;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get shopByCategory;

  /// No description provided for @featuredProducts.
  ///
  /// In en, this message translates to:
  /// **'Featured products'**
  String get featuredProducts;

  /// No description provided for @latestProducts.
  ///
  /// In en, this message translates to:
  /// **'Latest products'**
  String get latestProducts;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProducts;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get cartEmptyMessage;

  /// No description provided for @checkoutAction.
  ///
  /// In en, this message translates to:
  /// **'Checkout & place order'**
  String get checkoutAction;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order {number} placed successfully.'**
  String orderPlaced(Object number);

  /// No description provided for @orderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not place the order.'**
  String get orderFailed;

  /// No description provided for @estimatedTax.
  ///
  /// In en, this message translates to:
  /// **'Estimated tax'**
  String get estimatedTax;

  /// No description provided for @storefrontSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse products and preview the online customer experience.'**
  String get storefrontSubtitle;

  /// No description provided for @productsInCategory.
  ///
  /// In en, this message translates to:
  /// **'Products in {category}'**
  String productsInCategory(Object category);

  /// No description provided for @noProductsInCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get noProductsInCategoryTitle;

  /// No description provided for @noProductsInCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Try selecting another category.'**
  String get noProductsInCategoryMessage;

  /// No description provided for @generalLabel.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalLabel;

  /// No description provided for @eachLabel.
  ///
  /// In en, this message translates to:
  /// **'each'**
  String get eachLabel;

  /// No description provided for @bannerNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get bannerNewArrivals;

  /// No description provided for @bannerLocalDelivery.
  ///
  /// In en, this message translates to:
  /// **'Local delivery'**
  String get bannerLocalDelivery;

  /// No description provided for @bannerStorePickup.
  ///
  /// In en, this message translates to:
  /// **'Store pickup'**
  String get bannerStorePickup;

  /// No description provided for @storeCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Storefront customer'**
  String get storeCustomerName;

  /// No description provided for @storeOrderNote.
  ///
  /// In en, this message translates to:
  /// **'Storefront online order'**
  String get storeOrderNote;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from cart'**
  String get removeFromCart;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @catRoot.
  ///
  /// In en, this message translates to:
  /// **'Root categories'**
  String get catRoot;

  /// No description provided for @catSub.
  ///
  /// In en, this message translates to:
  /// **'Sub-categories'**
  String get catSub;

  /// No description provided for @catShopBy.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get catShopBy;

  /// No description provided for @catTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a category to see its products.'**
  String get catTapHint;

  /// No description provided for @catSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get catSearchHint;

  /// No description provided for @catNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get catNoProducts;

  /// No description provided for @catNoProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Add products and assign them to {category}.'**
  String catNoProductsHint(Object category);

  /// No description provided for @catProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String catProductCount(Object count);

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first category to organize products.'**
  String get categoriesEmptyMessage;

  /// No description provided for @colProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get colProducts;

  /// No description provided for @colDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get colDescription;

  /// No description provided for @productImagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Product images'**
  String get productImagesLabel;

  /// No description provided for @productImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended 800 x 1000 (4:5). The first image is the main one. Card thumbnails use 300 x 375 (4:5).'**
  String get productImagesHint;

  /// No description provided for @imageMainBadge.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get imageMainBadge;

  /// No description provided for @imageSetMain.
  ///
  /// In en, this message translates to:
  /// **'Set as main'**
  String get imageSetMain;

  /// No description provided for @imageReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get imageReplace;

  /// No description provided for @imageMoveBackward.
  ///
  /// In en, this message translates to:
  /// **'Move left'**
  String get imageMoveBackward;

  /// No description provided for @imageMoveForward.
  ///
  /// In en, this message translates to:
  /// **'Move right'**
  String get imageMoveForward;

  /// No description provided for @imageAdd.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get imageAdd;

  /// No description provided for @imageOptions.
  ///
  /// In en, this message translates to:
  /// **'Image options'**
  String get imageOptions;

  /// No description provided for @removeImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this image?'**
  String get removeImageTitle;

  /// No description provided for @removeImageBody.
  ///
  /// In en, this message translates to:
  /// **'The image will be removed from the product. This cannot be undone.'**
  String get removeImageBody;

  /// No description provided for @imageRemoved.
  ///
  /// In en, this message translates to:
  /// **'Image removed.'**
  String get imageRemoved;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImage;

  /// No description provided for @categoryImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Category image'**
  String get categoryImageLabel;

  /// No description provided for @categoryImageHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended 600 x 600 (1:1).'**
  String get categoryImageHint;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get selectImage;

  /// No description provided for @removeCategoryImageBody.
  ///
  /// In en, this message translates to:
  /// **'The image will be removed from the category. This cannot be undone.'**
  String get removeCategoryImageBody;

  /// No description provided for @imageCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String imageCounter(Object current, Object total);

  /// No description provided for @checkoutNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter the customer\'s full name.'**
  String get checkoutNameTooShort;

  /// No description provided for @checkoutPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (7-15 digits).'**
  String get checkoutPhoneInvalid;

  /// No description provided for @checkoutQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Item quantity must be at least 1.'**
  String get checkoutQuantityInvalid;

  /// No description provided for @checkoutInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Only {available} left of {product}.'**
  String checkoutInsufficientStock(Object available, Object product);

  /// No description provided for @checkoutAddressTooLong.
  ///
  /// In en, this message translates to:
  /// **'Address is too long (max 300 characters).'**
  String get checkoutAddressTooLong;

  /// No description provided for @checkoutCityTooLong.
  ///
  /// In en, this message translates to:
  /// **'City is too long (max 120 characters).'**
  String get checkoutCityTooLong;

  /// No description provided for @businessLocation.
  ///
  /// In en, this message translates to:
  /// **'Business location'**
  String get businessLocation;

  /// No description provided for @businessLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Shown on the storefront map and used for directions.'**
  String get businessLocationHint;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off.'**
  String get locationServicesDisabled;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location.'**
  String get locationUnavailable;

  /// No description provided for @locationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a latitude between -90 and 90 and a longitude between -180 and 180.'**
  String get locationInvalid;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get openInMaps;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get socialMedia;

  /// No description provided for @socialMediaHint.
  ///
  /// In en, this message translates to:
  /// **'Add the business profile links shown on the storefront.'**
  String get socialMediaHint;

  /// No description provided for @socialInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get socialInstagram;

  /// No description provided for @socialFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get socialFacebook;

  /// No description provided for @socialTiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get socialTiktok;

  /// No description provided for @socialWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get socialWhatsapp;

  /// No description provided for @socialYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get socialYoutube;

  /// No description provided for @socialLinkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get socialLinkedin;

  /// No description provided for @socialUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile URL'**
  String get socialUrlLabel;

  /// No description provided for @socialInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) link.'**
  String get socialInvalidUrl;

  /// No description provided for @trackOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your order'**
  String get trackOrderTitle;

  /// No description provided for @trackOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your order number and the phone number used at checkout.'**
  String get trackOrderSubtitle;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderNumberLabel;

  /// No description provided for @trackOrderAction.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrderAction;

  /// No description provided for @trackOrderRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter both the order number and phone number.'**
  String get trackOrderRequired;

  /// No description provided for @trackOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'No order matches those details. Check the order number and phone, then try again.'**
  String get trackOrderNotFound;

  /// No description provided for @trackOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not look up the order. Please try again.'**
  String get trackOrderFailed;

  /// No description provided for @trackOrderItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get trackOrderItems;

  /// No description provided for @storefrontFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get storefrontFollowUs;

  /// No description provided for @chatOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get chatOnWhatsapp;

  /// No description provided for @chatOnWhatsappMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! I would like to ask about my order.'**
  String get chatOnWhatsappMessage;

  /// No description provided for @paginationRange.
  ///
  /// In en, this message translates to:
  /// **'Showing {start}-{end} of {total}'**
  String paginationRange(Object end, Object start, Object total);

  /// No description provided for @paginationPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String paginationPageOf(Object page, Object total);

  /// No description provided for @paginationPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get paginationPrevious;

  /// No description provided for @paginationNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get paginationNext;

  /// No description provided for @backToTop.
  ///
  /// In en, this message translates to:
  /// **'Back to top'**
  String get backToTop;

  /// No description provided for @hideSidebar.
  ///
  /// In en, this message translates to:
  /// **'Hide sidebar'**
  String get hideSidebar;

  /// No description provided for @showSidebar.
  ///
  /// In en, this message translates to:
  /// **'Show sidebar'**
  String get showSidebar;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment tracking'**
  String get trackingTitle;

  /// No description provided for @trackingStageOrderReceived.
  ///
  /// In en, this message translates to:
  /// **'Order received'**
  String get trackingStageOrderReceived;

  /// No description provided for @trackingStageProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get trackingStageProcessing;

  /// No description provided for @trackingStageShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get trackingStageShipped;

  /// No description provided for @trackingStageInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get trackingStageInTransit;

  /// No description provided for @trackingStageOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get trackingStageOutForDelivery;

  /// No description provided for @trackingStageDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get trackingStageDelivered;

  /// No description provided for @trackingNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking number'**
  String get trackingNumberLabel;

  /// No description provided for @shippingCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping company'**
  String get shippingCompanyLabel;

  /// No description provided for @shipmentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipment date'**
  String get shipmentDateLabel;

  /// No description provided for @estimatedDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get estimatedDeliveryLabel;

  /// No description provided for @currentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocationLabel;

  /// No description provided for @latestUpdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest update'**
  String get latestUpdateLabel;

  /// No description provided for @trackingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tracking information is not available yet.'**
  String get trackingUnavailable;

  /// No description provided for @trackingCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled.'**
  String get trackingCancelled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
