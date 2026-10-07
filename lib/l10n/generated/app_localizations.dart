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

  /// No description provided for @actionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Available in a later phase'**
  String get actionComingSoon;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize language, appearance and style.'**
  String get settingsSubtitle;

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

  /// No description provided for @pagePhase.
  ///
  /// In en, this message translates to:
  /// **'Planned for Phase {phase}.'**
  String pagePhase(Object phase);

  /// No description provided for @pageBadge.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get pageBadge;
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
