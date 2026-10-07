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
  String get actionComingSoon => 'Available in a later phase';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Customize language, appearance and style.';

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
  String pagePhase(Object phase) {
    return 'Planned for Phase $phase.';
  }

  @override
  String get pageBadge => 'Coming soon';
}
