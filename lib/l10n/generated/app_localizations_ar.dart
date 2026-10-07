// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'diali';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navCustomers => 'العملاء';

  @override
  String get navResources => 'الموارد';

  @override
  String get navForms => 'النماذج';

  @override
  String get navPages => 'الصفحات';

  @override
  String get navStore => 'المتجر';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get openNavigation => 'فتح قائمة التنقل';

  @override
  String get closeNavigation => 'إغلاق قائمة التنقل';

  @override
  String get dashboardSubtitle => 'إليك ما يحدث في عملك اليوم.';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get statProducts => 'إجمالي المنتجات';

  @override
  String get statOrders => 'إجمالي الطلبات';

  @override
  String get statCustomers => 'إجمالي العملاء';

  @override
  String get statResources => 'إجمالي الموارد';

  @override
  String get statProductsTrend => '+12% هذا الشهر';

  @override
  String get statOrdersTrend => '+8% هذا الشهر';

  @override
  String get statCustomersTrend => '+5% هذا الشهر';

  @override
  String get statResourcesTrend => 'أُضيفت 2 هذا الأسبوع';

  @override
  String activityOrder(Object id) {
    return 'تم استلام طلب جديد $id';
  }

  @override
  String activityLowStock(Object name) {
    return 'مخزون منخفض لـ $name';
  }

  @override
  String activityCustomer(Object name) {
    return 'عميل جديد: $name';
  }

  @override
  String activityResource(Object name) {
    return 'تمت إضافة $name إلى الموارد';
  }

  @override
  String get timeToday => 'اليوم';

  @override
  String get timeYesterday => 'أمس';

  @override
  String get actionAddProduct => 'إضافة منتج';

  @override
  String get actionNewOrder => 'طلب جديد';

  @override
  String get actionAddCustomer => 'إضافة عميل';

  @override
  String get actionAddResource => 'إضافة مورد';

  @override
  String get actionComingSoon => 'متاح في مرحلة لاحقة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubtitle => 'خصّص اللغة والمظهر والنمط.';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageDescription => 'اختر لغة التطبيق.';

  @override
  String get appearanceTitle => 'المظهر';

  @override
  String get appearanceDescription => 'اختر الوضع الفاتح أو الداكن أو النظام.';

  @override
  String get modeSystem => 'النظام';

  @override
  String get modeLight => 'فاتح';

  @override
  String get modeDark => 'داكن';

  @override
  String get styleTitle => 'النمط';

  @override
  String get styleDescription => 'غيّر النمط البصري لتطبيقك بالكامل.';

  @override
  String get styleModern => 'عصري';

  @override
  String get styleMinimal => 'بسيط';

  @override
  String get styleProfessional => 'احترافي';

  @override
  String get styleModernDesc => 'زوايا دائرية وألوان ودودة.';

  @override
  String get styleMinimalDesc => 'مسطّح وحاد وهادئ.';

  @override
  String get styleProfessionalDesc => 'مضغوط ورسمي ومركّز.';

  @override
  String pagePhase(Object phase) {
    return 'مخطّط للمرحلة $phase.';
  }

  @override
  String get pageBadge => 'قريباً';
}
