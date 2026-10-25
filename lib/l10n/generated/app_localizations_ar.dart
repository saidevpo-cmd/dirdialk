// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ديالي';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navOrderHistory => 'سجل الطلبات';

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
  String get dashboardSubtitle => 'إليك ما يحدث في عملك وتجارتك اليوم.';

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
  String get statResourcesTrend => 'تمت إضافة 2 هذا الأسبوع';

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
  String get actionAddForm => 'نموذج جديد';

  @override
  String get actionAddPage => 'صفحة جديدة';

  @override
  String get actionComingSoon => 'متاح في مرحلة قادمة';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionCopy => 'نسخ';

  @override
  String get actionCopied => 'تم النسخ إلى الحافظة.';

  @override
  String searchIn(Object section) {
    return 'البحث في $section';
  }

  @override
  String emptySearch(Object query) {
    return 'لا توجد نتائج لـ “$query”.';
  }

  @override
  String resultCount(Object count) {
    return '$count نتيجة';
  }

  @override
  String get productsSubtitle => 'إدارة الكتالوج والأسعار ومستويات المخزون.';

  @override
  String get ordersSubtitle => 'تتبع كل طلب من الدفع إلى التسليم.';

  @override
  String get customersSubtitle => 'قاعدة عملائك وسجل الشراء والطلبات.';

  @override
  String get resourcesSubtitle => 'المستندات والوسائط والملفات المشتركة.';

  @override
  String get formsSubtitle => 'بناء النماذج وجمع الإرسالات والملاحظات.';

  @override
  String get pagesSubtitle => 'إنشاء وإدارة صفحات منصتك وموقعك.';

  @override
  String get storeSubtitle => 'معاينة واجهة متجرك الإلكتروني.';

  @override
  String get colName => 'الاسم';

  @override
  String get colSku => 'رمز المنتج';

  @override
  String get colCategory => 'الفئة';

  @override
  String get colPrice => 'السعر';

  @override
  String get colStock => 'المخزون';

  @override
  String get colStatus => 'الحالة';

  @override
  String get colOrder => 'الطلب';

  @override
  String get colCustomer => 'العميل';

  @override
  String get colDate => 'التاريخ';

  @override
  String get colTotal => 'الإجمالي';

  @override
  String get colEmail => 'البريد الإلكتروني';

  @override
  String get colOrders => 'الطلبات';

  @override
  String get colSpent => 'إجمالي الإنفاق';

  @override
  String get colTier => 'الفئة';

  @override
  String get colType => 'النوع';

  @override
  String get colSize => 'الحجم';

  @override
  String get colUpdated => 'آخر تحديث';

  @override
  String get colSubmissions => 'المشاركات';

  @override
  String get colTitle => 'العنوان';

  @override
  String get colSlug => 'الرابط المختصر';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusLow => 'مخزون منخفض';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusShipped => 'تم الشحن';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusPublished => 'منشور';

  @override
  String get statusNew => 'جديد';

  @override
  String get statusVip => 'عميل مميز';

  @override
  String get statusRegular => 'عادي';

  @override
  String get typeDocument => 'مستند';

  @override
  String get typeSpreadsheet => 'جدول بيانات';

  @override
  String get typeImage => 'صورة';

  @override
  String get typeFolder => 'مجلد';

  @override
  String get productsLowStockTitle => 'مخزون منخفض';

  @override
  String productsLowStock(Object count) {
    return '$count منخفض في المخزن';
  }

  @override
  String get productsValueTitle => 'قيمة المخزون';

  @override
  String get ordersPendingTitle => 'قيد المعالجة';

  @override
  String ordersPending(Object count) {
    return '$count قيد الانتظار';
  }

  @override
  String get ordersRevenueTitle => 'الإيرادات';

  @override
  String get customersVipTitle => 'العملاء المميزون';

  @override
  String customersVip(Object count) {
    return '$count عميل مميز';
  }

  @override
  String get customersValueTitle => 'إجمالي المشتريات';

  @override
  String get resourcesUsedTitle => 'المساحة المستخدمة';

  @override
  String formsSubmissions(Object count) {
    return '$count إرسال';
  }

  @override
  String formsPublished(Object count) {
    return '$count منشور';
  }

  @override
  String pagesPublished(Object count) {
    return '$count منشورة';
  }

  @override
  String pagesDraft(Object count) {
    return '$count مسودة';
  }

  @override
  String get storeOpen => 'فتح واجهة المتجر';

  @override
  String get storeBannerTitle => 'موسم جديد، تشكيلة جديدة';

  @override
  String get storeBannerBody => 'تصفح كتالوج العرض التجريبي.';

  @override
  String get storeBannerCta => 'تصفح المنتجات';

  @override
  String get addToCart => 'إضافة إلى السلة';

  @override
  String addedToCart(Object name) {
    return 'تمت إضافة $name إلى سلتك.';
  }

  @override
  String get storeCartTitle => 'سلة التسوق';

  @override
  String get cartEmpty => 'سلة التسوق فارغة.';

  @override
  String storeCartItems(Object count) {
    return '$count عناصر في السلة';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubtitle =>
      'كل ما يتعلق باللغة والإشعارات والخصوصية والبيانات.';

  @override
  String get settingsSearchHint => 'بحث في الإعدادات';

  @override
  String settingsNoResults(Object query) {
    return 'لا توجد إعدادات تطابق “$query”.';
  }

  @override
  String get sectionGeneral => 'عام';

  @override
  String get sectionGeneralDesc => 'اللغة والمظهر والنمط البصري.';

  @override
  String get sectionNotifications => 'الإشعارات';

  @override
  String get sectionNotificationsDesc =>
      'اختر التنبيهات التي ترغب في استلامها.';

  @override
  String get sectionPrivacy => 'الخصوصية والسياسات';

  @override
  String get sectionPrivacyDesc => 'تفضيلات البيانات وسياسة الخصوصية والشروط.';

  @override
  String get sectionData => 'البيانات والتخزين';

  @override
  String get sectionDataDesc => 'التصدير وإعادة الضبط والتخزين المحلي.';

  @override
  String get sectionAbout => 'حول التطبيق';

  @override
  String get sectionAboutDesc => 'الإصدار والتراخيص والدعم.';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageDescription => 'اختر لغة واجهة التطبيق.';

  @override
  String get appearanceTitle => 'المظهر';

  @override
  String get appearanceDescription =>
      'اختر بين الوضع الفاتح أو الداكن أو تلقائي حسب النظام.';

  @override
  String get modeSystem => 'النظام';

  @override
  String get modeLight => 'فاتح';

  @override
  String get modeDark => 'داكن';

  @override
  String get styleTitle => 'النمط البصري';

  @override
  String get styleDescription => 'تغيير النمط البصري للتطبيق بالكامل.';

  @override
  String get styleModern => 'عصري';

  @override
  String get styleMinimal => 'بسيط';

  @override
  String get styleProfessional => 'احترافي';

  @override
  String get styleModernDesc => 'حواف مستديرة وألوان مريحة وجذابة.';

  @override
  String get styleMinimalDesc => 'تصميم مسطح ومباشر وهادئ.';

  @override
  String get styleProfessionalDesc => 'مدمج ورسمي وعالي الكثافة.';

  @override
  String get notifOrders => 'الطلبات الجديدة';

  @override
  String get notifOrdersDesc => 'تلقي إشعار عند وصول طلب جديد.';

  @override
  String get notifLowStock => 'تنبيهات انخفاض المخزون';

  @override
  String get notifLowStockDesc => 'تنبيهي عندما يوشك منتج على النفاد.';

  @override
  String get notifWeekly => 'الملخص الأسبوعي';

  @override
  String get notifWeeklyDesc => 'ملخص شامل للنشاط كل يوم اثنين.';

  @override
  String get privacyAnalytics => 'تحليلات مجهولة';

  @override
  String get privacyAnalyticsDesc =>
      'مشاركة إحصاءات استخدام مجهولة لتحسين التطبيق.';

  @override
  String get privacyCrash => 'تقارير الأعطال';

  @override
  String get privacyCrashDesc => 'إرسال تقارير تشخيصية عند حدوث خلل.';

  @override
  String get privacyPersonalization => 'التخصيص';

  @override
  String get privacyPersonalizationDesc =>
      'حفظ تفضيلات لوحة التحكم على هذا الجهاز.';

  @override
  String get privacyPolicyAction => 'قراءة سياسة الخصوصية';

  @override
  String get privacyPolicyActionDesc => 'كيفية تخزين بياناتك وحمايتها.';

  @override
  String get termsAction => 'قراءة شروط الخدمة';

  @override
  String get termsActionDesc => 'القواعد المطبقة عند استخدام ديالي.';

  @override
  String get consentTitle => 'الموافقة على السياسات';

  @override
  String consentAccepted(Object date) {
    return 'تمت الموافقة في $date.';
  }

  @override
  String get consentPending => 'لم تتم الموافقة على السياسة الحالية بعد.';

  @override
  String get consentAction => 'مراجعة وموافقة';

  @override
  String get consentUpdated => 'تم تحديث السياسة';

  @override
  String get consentAcceptedToast => 'شكراً لك — تم تسجيل موافقتك.';

  @override
  String get policyAccept => 'قبول السياسة';

  @override
  String get policyNotNow => 'ليس الآن';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyIntro => 'يعمل تطبيق ديالي بالكامل على جهازك محلياً.';

  @override
  String get privacyIntroTitle => 'نظرة عامة';

  @override
  String get privacyCollectTitle => 'البيانات المخزنة على جهازك';

  @override
  String get privacyCollectBody =>
      'يتم تخزين التفضيلات والإعدادات في قاعدة البيانات المحلية.';

  @override
  String get privacyOptionalTitle => 'البيانات الاختيارية';

  @override
  String get privacyOptionalBody =>
      'التحليلات المجهولة وتقارير الأعطال معطلة افتراضياً.';

  @override
  String get privacyLocalTitle => 'تخزين محلي فقط';

  @override
  String get privacyLocalBody =>
      'يستخدم التطبيق التخزين المحلي على هذا الجهاز فقط.';

  @override
  String get privacyRightsTitle => 'حقوقك';

  @override
  String get privacyRightsBody =>
      'يمكنك مراجعة تفضيلاتك أو تعديلها أو حذفها في أي وقت.';

  @override
  String get privacyContactTitle => 'التواصل';

  @override
  String privacyContactBody(Object email) {
    return 'أسئلة حول هذه السياسة؟ راسلنا على $email.';
  }

  @override
  String privacyUpdatedOn(Object date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get privacyUpdatedTitle => 'آخر تحديث';

  @override
  String get termsTitle => 'شروط الخدمة';

  @override
  String get termsAcceptTitle => 'القبول';

  @override
  String get termsAcceptBody => 'باستخدامك لديالي فإنك توافق على هذه الشروط.';

  @override
  String get termsUseTitle => 'الاستخدام المصرح به';

  @override
  String get termsUseBody => 'التطبيق مخصص لإدارة بيانات عملك وتجارتك الخاصة.';

  @override
  String get termsAvailabilityTitle => 'التوافر';

  @override
  String get termsAvailabilityBody => 'هذا الإصدار هو تطبيق أساسي محلي.';

  @override
  String get termsLiabilityTitle => 'المسؤولية';

  @override
  String get termsLiabilityBody => 'يتم توفير التطبيق كما هو دون أي ضمانات.';

  @override
  String get termsChangesTitle => 'التغييرات';

  @override
  String get termsChangesBody =>
      'قد نقوم بتحديث هذه الشروط وسياسة الخصوصية دورياً.';

  @override
  String get termsContactTitle => 'التواصل';

  @override
  String termsContactBody(Object email) {
    return 'أسئلة حول هذه الشروط؟ راسلنا على $email.';
  }

  @override
  String get dataStorage => 'التخزين المحلي';

  @override
  String get dataStorageDesc => 'يتم حفظ التفضيلات على هذا الجهاز فقط.';

  @override
  String get dataExport => 'تصدير الإعدادات';

  @override
  String get dataExportDesc => 'تنزيل تفضيلاتك كملف JSON.';

  @override
  String get dataExportTitle => 'إعداداتك';

  @override
  String get dataReset => 'إعادة ضبط جميع الإعدادات';

  @override
  String get dataResetDesc =>
      'استعادة اللغة والمظهر والنمط والإشعارات إلى الوضع الافتراضي.';

  @override
  String get dataResetTitle => 'إعادة ضبط جميع الإعدادات؟';

  @override
  String get dataResetBody => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get dataResetConfirm => 'إعادة ضبط';

  @override
  String get aboutVersion => 'إصدار التطبيق';

  @override
  String get aboutBuild => 'رقم البناء';

  @override
  String get aboutLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get aboutLicensesDesc => 'تراخيص الحزم المستخدمة في ديالي.';

  @override
  String get aboutContact => 'اتصل بنا';

  @override
  String get aboutContactDesc => 'الأسئلة والملاحظات والدعم الفني.';

  @override
  String get aboutOffline => 'يعمل دون اتصال';

  @override
  String get aboutOfflineDesc =>
      'ديالي يعمل بالكامل دون الحاجة للاتصال بالإنترنت.';

  @override
  String get navCategories => 'الفئات';

  @override
  String get dashboardRecentOrders => 'أحدث الطلبات';

  @override
  String get dashboardRecentProducts => 'أحدث المنتجات';

  @override
  String get dashboardLatestArticles => 'أحدث المقالات';

  @override
  String get dashboardRecentDirectory => 'أبرز الموارد';

  @override
  String get dashboardNoOrders =>
      'لا توجد طلبات بعد. تظهر الطلبات القادمة من المتجر هنا.';

  @override
  String get dashboardNoProducts =>
      'لا توجد منتجات بعد. أضف منتجك الأول للبدء.';

  @override
  String get dashboardNoArticles => 'لا توجد مقالات بعد.';

  @override
  String get dashboardNoDirectory => 'لا توجد موارد في الدليل بعد.';

  @override
  String get dashboardInventoryValue => 'قيمة المخزون';

  @override
  String get dashboardTotalCategories => 'الفئات';

  @override
  String get dashboardRevenue => 'الإيرادات';

  @override
  String get dashboardPublishedArticles => 'المقالات المنشورة';

  @override
  String get categoriesSubtitle =>
      'نظّم كتالوجك باستخدام فئات قابلة لإعادة الاستخدام.';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get categorySlug => 'المعرّف';

  @override
  String get categoryDescription => 'الوصف';

  @override
  String get categoryNameRequired => 'اسم الفئة مطلوب.';

  @override
  String get categoryNameExists => 'توجد فئة بهذا الاسم بالفعل.';

  @override
  String get categoryCreated => 'تم إنشاء الفئة.';

  @override
  String get categoryUpdated => 'تم تحديث الفئة.';

  @override
  String get categoryDeleted => 'تم حذف الفئة.';

  @override
  String get deleteCategoryTitle => 'حذف الفئة؟';

  @override
  String deleteCategoryBody(Object name) {
    return 'هل أنت متأكد من حذف \"$name\"؟';
  }

  @override
  String deleteCategoryInUse(Object count) {
    return 'يستخدم $count منتج هذه الفئة. سيتم نقلهم إلى غير مصنّف.';
  }

  @override
  String get uncategorized => 'غير مصنّف';

  @override
  String get storeProfileTitle => 'ملف المتجر';

  @override
  String get storeProfileDescription =>
      'اسم الواجهة العامة والهوية وبيانات الاتصال.';

  @override
  String get storeName => 'اسم المتجر';

  @override
  String get storeDescriptionLabel => 'وصف المتجر';

  @override
  String get storeLogoUrl => 'رابط صورة الشعار';

  @override
  String get storeContactEmail => 'البريد الإلكتروني';

  @override
  String get storeContactPhone => 'هاتف التواصل';

  @override
  String get storeAddress => 'العنوان';

  @override
  String get storefrontTemplate => 'قالب الواجهة';

  @override
  String get storefrontTemplateDesc =>
      'تصميم موجه للعملاء: عصري أو بسيط أو احترافي.';

  @override
  String get templateModern => 'عصري';

  @override
  String get templateMinimal => 'بسيط';

  @override
  String get templateProfessional => 'احترافي';

  @override
  String get saved => 'تم الحفظ.';

  @override
  String get demoDataTitle => 'بيانات تجريبية';

  @override
  String get demoDataDesc => 'تحميل منتجات وفئات تجريبية مع صور محلية.';

  @override
  String get demoDataAction => 'تحميل البيانات التجريبية';

  @override
  String get demoDataLoading => 'جارٍ تحميل البيانات التجريبية…';

  @override
  String demoDataResult(Object categories, Object products) {
    return 'تمت إضافة $products منتجًا و$categories فئة.';
  }

  @override
  String get demoDataAlready => 'البيانات التجريبية محمّلة بالفعل.';

  @override
  String get demoDataFailed => 'تعذر تحميل البيانات التجريبية.';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'سجّل الدخول لإدارة أعمالك.';

  @override
  String get loginEmail => 'البريد الإلكتروني';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginEmailRequired => 'أدخل بريدك الإلكتروني.';

  @override
  String get loginEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get loginPasswordRequired => 'أدخل كلمة المرور.';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. تحقّق من بياناتك وحاول مجددًا.';

  @override
  String get loginOfflineNotice => 'يعمل دون اتصال — لا حاجة لتسجيل الدخول.';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get accountDescription => 'تسجيل الدخول والجلسة.';

  @override
  String accountSignedInAs(String email) {
    return 'مسجّل الدخول باسم $email';
  }

  @override
  String get accountLocalMode => 'وضع عدم الاتصال — لا حاجة لحساب.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get signOutConfirmBody =>
      'ستحتاج إلى تسجيل الدخول مجددًا للوصول إلى لوحة التحكم.';

  @override
  String get signOutConfirm => 'تسجيل الخروج';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionView => 'عرض';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionRemove => 'إزالة';

  @override
  String get actionSaveChanges => 'حفظ التغييرات';

  @override
  String get actionClear => 'مسح';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get noRecordsTitle => 'لا توجد سجلات';

  @override
  String get searchDefaultHint => 'بحث...';

  @override
  String get loadFailed => 'تعذّر تحميل البيانات. حاول مرة أخرى.';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get changesSaved => 'تم حفظ التغييرات.';

  @override
  String get recordCreated => 'تم الإنشاء بنجاح.';

  @override
  String get recordUpdated => 'تم التحديث بنجاح.';

  @override
  String get recordDeleted => 'تم الحذف بنجاح.';

  @override
  String get operationFailed => 'تعذّر إكمال العملية.';

  @override
  String deleteDialogTitle(Object name) {
    return 'حذف «$name»؟';
  }

  @override
  String get deleteDialogBody => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get guestLabel => 'زائر';

  @override
  String get subtotalLabel => 'المجموع الفرعي';

  @override
  String get taxLabel => 'الضريبة';

  @override
  String get shippingLabel => 'الشحن';

  @override
  String get totalAmountLabel => 'المبلغ الإجمالي';

  @override
  String get allCategories => 'كل الفئات';

  @override
  String get allStatuses => 'كل الحالات';

  @override
  String get allTiers => 'كل المستويات';

  @override
  String get colProduct => 'المنتج';

  @override
  String get colContact => 'التواصل';

  @override
  String get colLocation => 'الموقع';

  @override
  String get colDetails => 'التفاصيل';

  @override
  String get colItems => 'العناصر';

  @override
  String get colActions => 'إجراءات';

  @override
  String get statusArchived => 'مؤرشف';

  @override
  String get statusHidden => 'مخفي';

  @override
  String get statActive => 'نشط';

  @override
  String get statLowStock => 'مخزون منخفض';

  @override
  String get statOutOfStock => 'نفد المخزون';

  @override
  String itemCount(Object count) {
    return '$count عنصر';
  }

  @override
  String get productDetailsTitle => 'تفاصيل المنتج';

  @override
  String get demoPrice => 'سعر تجريبي';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'نفد المخزون';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get searchProductsHint => 'ابحث عن المنتجات بالاسم أو رمز SKU...';

  @override
  String get productsEmptyTitle => 'لا توجد منتجات';

  @override
  String get productsEmptyMessage => 'جرّب تعديل البحث أو أضف منتجًا جديدًا.';

  @override
  String get productCreated => 'تم إنشاء المنتج.';

  @override
  String get productUpdated => 'تم تحديث المنتج.';

  @override
  String get productDeleted => 'تم حذف المنتج.';

  @override
  String get deleteProductTitle => 'حذف المنتج؟';

  @override
  String deleteProductBody(Object name) {
    return 'حذف «$name»؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String stockUnits(Object count) {
    return '$count في المخزون';
  }

  @override
  String get lowBadge => 'منخفض';

  @override
  String get editProductTitle => 'تعديل المنتج';

  @override
  String get productNameLabel => 'اسم المنتج';

  @override
  String get productPriceLabel => 'السعر';

  @override
  String get productCostLabel => 'التكلفة';

  @override
  String get productStockLabel => 'كمية المخزون';

  @override
  String get productStatusLabel => 'الحالة';

  @override
  String get productDescriptionLabel => 'الوصف';

  @override
  String get productNameRequired => 'اسم المنتج مطلوب.';

  @override
  String get searchOrdersHint => 'ابحث عن الطلبات برقم الطلب أو العميل...';

  @override
  String get orderHistorySubtitle => 'اعثر على أي طلب سابق واعرضه وأعد طباعته.';

  @override
  String get searchHistoryHint => 'ابحث برقم الطلب أو اسم الزبون...';

  @override
  String get orderDateLabel => 'تاريخ الطلب';

  @override
  String get dateRangeFilter => 'الفترة الزمنية';

  @override
  String get clearDateFilter => 'مسح الفلتر الزمني';

  @override
  String get colQty => 'الكمية';

  @override
  String get unitPriceLabel => 'سعر الوحدة';

  @override
  String get discountLabel => 'الخصم';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get historyEmptyTitle => 'لا توجد طلبات مطابقة للمرشّحات';

  @override
  String get historyEmptyMessage =>
      'جرّب تعديل نص البحث أو الفترة الزمنية أو حالة الطلب.';

  @override
  String get printOrder => 'طباعة الطلب';

  @override
  String get downloadPdf => 'تنزيل PDF';

  @override
  String get printDocumentFailed =>
      'تعذّر تحضير مستند الطباعة. يرجى المحاولة مرة أخرى.';

  @override
  String get orderDocumentTitle => 'وصل الطلب';

  @override
  String reprintFooter(Object date) {
    return 'أُعيدت الطباعة في $date اعتمادًا على بيانات الطلب الأصلية.';
  }

  @override
  String get customerInformation => 'معلومات العميل';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get updateStatusTitle => 'تحديث الحالة';

  @override
  String get markPaid => 'تحديد كمدفوع';

  @override
  String get markShipped => 'تحديد كمشحون';

  @override
  String get markDelivered => 'تحديد كمُسلَّم';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get cancelOrderTitle => 'إلغاء هذا الطلب؟';

  @override
  String get cancelOrderBody => 'سيتم تعليم الطلب كملغى.';

  @override
  String get ordersEmptyTitle => 'لا توجد طلبات';

  @override
  String get ordersEmptyMessage => 'جرّب مسح عوامل التصفية أو كلمات البحث.';

  @override
  String get orderStatusUpdated => 'تم تحديث حالة الطلب.';

  @override
  String orderLabel(Object number) {
    return 'طلب $number';
  }

  @override
  String get editCustomerTitle => 'تعديل العميل';

  @override
  String get customerNameLabel => 'الاسم الكامل';

  @override
  String get customerPhoneLabel => 'الهاتف';

  @override
  String get customerCityLabel => 'المدينة';

  @override
  String get customerCountryLabel => 'الدولة';

  @override
  String get customerAddressLabel => 'عنوان الشارع';

  @override
  String get customerTierLabel => 'مستوى العميل';

  @override
  String get customerNotesLabel => 'ملاحظات داخلية';

  @override
  String get searchCustomersHint =>
      'ابحث بالاسم أو البريد أو الهاتف أو المدينة...';

  @override
  String get customersEmptyTitle => 'لا يوجد عملاء';

  @override
  String get customersEmptyMessage => 'أضف عميلًا جديدًا للبدء.';

  @override
  String get customerCreated => 'تم إنشاء العميل.';

  @override
  String get customerUpdated => 'تم تحديث العميل.';

  @override
  String get customerDeleted => 'تم حذف العميل.';

  @override
  String get deleteCustomerTitle => 'حذف العميل؟';

  @override
  String get spentLabel => 'أنفق';

  @override
  String get statVipClients => 'عملاء VIP';

  @override
  String get statLifetimeValue => 'القيمة الإجمالية';

  @override
  String get storefrontTitle => 'المتجر';

  @override
  String get shopByCategory => 'تسوق حسب الفئة';

  @override
  String get featuredProducts => 'منتجات مميزة';

  @override
  String get latestProducts => 'أحدث المنتجات';

  @override
  String get allProducts => 'كل المنتجات';

  @override
  String get cartTitle => 'السلة';

  @override
  String get cartEmptyMessage => 'سلتك فارغة.';

  @override
  String get checkoutAction => 'إتمام الطلب';

  @override
  String orderPlaced(Object number) {
    return 'تم إنشاء الطلب $number بنجاح.';
  }

  @override
  String get orderFailed => 'تعذّر إنشاء الطلب.';

  @override
  String get estimatedTax => 'الضريبة التقديرية';

  @override
  String get storefrontSubtitle =>
      'تصفح المنتجات واستعرض تجربة العميل عبر الإنترنت.';

  @override
  String productsInCategory(Object category) {
    return 'منتجات في $category';
  }

  @override
  String get noProductsInCategoryTitle => 'لا توجد منتجات في هذه الفئة';

  @override
  String get noProductsInCategoryMessage => 'جرّب اختيار فئة أخرى.';

  @override
  String get generalLabel => 'عام';

  @override
  String get eachLabel => 'للقطعة';

  @override
  String get bannerNewArrivals => 'وصل حديثاً';

  @override
  String get bannerLocalDelivery => 'توصيل محلي';

  @override
  String get bannerStorePickup => 'استلام من المتجر';

  @override
  String get storeCustomerName => 'عميل المتجر الإلكتروني';

  @override
  String get storeOrderNote => 'طلب إلكتروني من المتجر';

  @override
  String get removeFromCart => 'إزالة من السلة';

  @override
  String get increaseQuantity => 'زيادة الكمية';

  @override
  String get decreaseQuantity => 'تقليل الكمية';

  @override
  String get catRoot => 'الفئات الرئيسية';

  @override
  String get catSub => 'الفئات الفرعية';

  @override
  String get catShopBy => 'تسوق حسب الفئة';

  @override
  String get catTapHint => 'اضغط على فئة لعرض منتجاتها.';

  @override
  String get catSearchHint => 'ابحث في الفئات...';

  @override
  String get catNoProducts => 'لا توجد منتجات في هذه الفئة';

  @override
  String catNoProductsHint(Object category) {
    return 'أضف منتجات وعيّنها إلى $category.';
  }

  @override
  String catProductCount(Object count) {
    return '$count منتج';
  }

  @override
  String get categoriesEmptyTitle => 'لا توجد فئات بعد';

  @override
  String get categoriesEmptyMessage => 'أنشئ فئتك الأولى لتنظيم المنتجات.';

  @override
  String get colProducts => 'المنتجات';

  @override
  String get colDescription => 'الوصف';

  @override
  String get productImagesLabel => 'صور المنتج';

  @override
  String get productImagesHint =>
      'المقاس الموصى به 800 × 1000 (4:5). الصورة الأولى هي الرئيسية.';

  @override
  String get imageMainBadge => 'رئيسية';

  @override
  String get imageSetMain => 'تعيين كرئيسية';

  @override
  String get imageReplace => 'استبدال';

  @override
  String get imageMoveBackward => 'تحريك لليسار';

  @override
  String get imageMoveForward => 'تحريك لليمين';

  @override
  String get imageAdd => 'إضافة صورة';

  @override
  String get imageOptions => 'خيارات الصورة';

  @override
  String get removeImageTitle => 'إزالة هذه الصورة؟';

  @override
  String get removeImageBody =>
      'ستُزال الصورة من المنتج. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get imageRemoved => 'تمت إزالة الصورة.';

  @override
  String get noImage => 'لا توجد صورة';

  @override
  String get categoryImageLabel => 'صورة الفئة';

  @override
  String get categoryImageHint => 'المقاس الموصى به 600 × 600 (1:1).';

  @override
  String get selectImage => 'اختيار صورة';

  @override
  String get removeCategoryImageBody =>
      'ستُزال الصورة من الفئة. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String imageCounter(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get checkoutNameTooShort => 'يرجى إدخال الاسم الكامل للعميل.';

  @override
  String get checkoutPhoneInvalid => 'أدخل رقم هاتف صالح (7-15 رقمًا).';

  @override
  String get checkoutQuantityInvalid => 'يجب أن تكون الكمية 1 على الأقل.';

  @override
  String checkoutInsufficientStock(Object available, Object product) {
    return 'المتبقي $available فقط من $product.';
  }

  @override
  String get checkoutAddressTooLong => 'العنوان طويل جدًا (300 حرف كحد أقصى).';

  @override
  String get checkoutCityTooLong =>
      'اسم المدينة طويل جدًا (120 حرفًا كحد أقصى).';

  @override
  String get businessLocation => 'موقع النشاط';

  @override
  String get businessLocationHint =>
      'يظهر على خريطة المتجر ويُستخدم للاتجاهات.';

  @override
  String get latitudeLabel => 'خط العرض';

  @override
  String get longitudeLabel => 'خط الطول';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الوصول إلى الموقع.';

  @override
  String get locationServicesDisabled => 'خدمات الموقع متوقفة.';

  @override
  String get locationUnavailable => 'تعذّر تحديد موقعك.';

  @override
  String get locationInvalid =>
      'أدخل خط عرض بين -90 و90 وخط طول بين -180 و180.';

  @override
  String get openInMaps => 'فتح في الخرائط';

  @override
  String get socialMedia => 'وسائل التواصل الاجتماعي';

  @override
  String get socialMediaHint => 'أضف روابط حسابات النشاط التي تظهر في المتجر.';

  @override
  String get socialInstagram => 'إنستغرام';

  @override
  String get socialFacebook => 'فيسبوك';

  @override
  String get socialTiktok => 'تيك توك';

  @override
  String get socialWhatsapp => 'واتساب';

  @override
  String get socialYoutube => 'يوتيوب';

  @override
  String get socialLinkedin => 'لينكدإن';

  @override
  String get socialUrlLabel => 'رابط الملف الشخصي';

  @override
  String get socialInvalidUrl => 'أدخل رابط http(s) صالحًا.';

  @override
  String get trackOrderTitle => 'تتبّع طلبك';

  @override
  String get trackOrderSubtitle =>
      'أدخل رقم الطلب ورقم الهاتف المستخدم عند الدفع.';

  @override
  String get orderNumberLabel => 'رقم الطلب';

  @override
  String get trackOrderAction => 'تتبّع الطلب';

  @override
  String get trackOrderRequired => 'أدخل رقم الطلب ورقم الهاتف.';

  @override
  String get trackOrderNotFound =>
      'لا يوجد طلب مطابق لهذه البيانات. تحقّق من الرقم والهاتف ثم حاول مجددًا.';

  @override
  String get trackOrderFailed =>
      'تعذّر العثور على الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get trackOrderItems => 'العناصر';

  @override
  String get storefrontFollowUs => 'تابعنا';

  @override
  String get chatOnWhatsapp => 'الدردشة على واتساب';

  @override
  String get chatOnWhatsappMessage => 'مرحبًا! أرغب في الاستفسار عن طلبي.';

  @override
  String paginationRange(Object end, Object start, Object total) {
    return 'عرض $start-$end من $total';
  }

  @override
  String paginationPageOf(Object page, Object total) {
    return 'صفحة $page من $total';
  }

  @override
  String get paginationPrevious => 'السابق';

  @override
  String get paginationNext => 'التالي';

  @override
  String get backToTop => 'العودة إلى الأعلى';

  @override
  String get hideSidebar => 'إخفاء الشريط الجانبي';

  @override
  String get showSidebar => 'إظهار الشريط الجانبي';

  @override
  String get trackingTitle => 'تتبّع الشحنة';

  @override
  String get trackingStageOrderReceived => 'تم استلام الطلب';

  @override
  String get trackingStageProcessing => 'قيد التجهيز';

  @override
  String get trackingStageShipped => 'تم الشحن';

  @override
  String get trackingStageInTransit => 'في الطريق';

  @override
  String get trackingStageOutForDelivery => 'خارج للتوصيل';

  @override
  String get trackingStageDelivered => 'تم التوصيل';

  @override
  String get trackingNumberLabel => 'رقم التتبّع';

  @override
  String get shippingCompanyLabel => 'شركة الشحن';

  @override
  String get shipmentDateLabel => 'تاريخ الشحن';

  @override
  String get estimatedDeliveryLabel => 'التوصيل المتوقّع';

  @override
  String get currentLocationLabel => 'الموقع الحالي';

  @override
  String get latestUpdateLabel => 'آخر تحديث';

  @override
  String get trackingUnavailable => 'معلومات التتبّع غير متاحة بعد.';

  @override
  String get trackingCancelled => 'تم إلغاء هذا الطلب.';

  @override
  String get openAction => 'فتح';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get allTypes => 'كل الأنواع';

  @override
  String get categoriesLabel => 'الفئات';

  @override
  String fieldsCount(Object count) {
    return '$count حقل';
  }

  @override
  String submissionsCountLabel(Object count) {
    return '$count مشاركة';
  }

  @override
  String get formsPageTitle => 'منشئ النماذج';

  @override
  String get formsPageSubtitle =>
      'صمّم نماذج جمع العملاء والاستبيانات ومسارات الاستطلاع.';

  @override
  String get createFormAction => 'إنشاء نموذج';

  @override
  String get editFormTitle => 'تعديل النموذج';

  @override
  String get formTitleLabel => 'عنوان النموذج';

  @override
  String get formSlugLabel => 'الرابط المختصر (مثل contact-us)';

  @override
  String get formStatusLabel => 'حالة النموذج';

  @override
  String get formDescriptionLabel => 'الوصف';

  @override
  String get formNameField => 'الاسم الكامل';

  @override
  String get formEmailField => 'البريد الإلكتروني';

  @override
  String get formMessageField => 'الرسالة / الاستفسار';

  @override
  String get formNamePlaceholder => 'اسمك';

  @override
  String get formEmailPlaceholder => 'you@company.com';

  @override
  String get formMessagePlaceholder => 'كيف يمكننا مساعدتك؟';

  @override
  String get formTitleRequired => 'عنوان النموذج مطلوب.';

  @override
  String get formUnpublishedHint => 'انشر النموذج قبل إرسال مشاركة تجريبية.';

  @override
  String get selectOptionLabel => 'اختر خيارًا';

  @override
  String get submitFormAction => 'إرسال النموذج';

  @override
  String get formSubmittedMessage => 'تم إرسال النموذج بنجاح.';

  @override
  String get formCreated => 'تم إنشاء النموذج.';

  @override
  String get formUpdated => 'تم تحديث النموذج.';

  @override
  String get formDeleted => 'تم حذف النموذج.';

  @override
  String get totalForms => 'إجمالي النماذج';

  @override
  String get activePublished => 'نشط ومنشور';

  @override
  String get totalSubmissions => 'إجمالي المشاركات';

  @override
  String get searchFormsHint => 'ابحث عن النماذج بالعنوان أو الرابط...';

  @override
  String get noFormsTitle => 'لا توجد نماذج بعد';

  @override
  String get noFormsMessage =>
      'أنشئ نموذجًا جديدًا لبدء استقبال مشاركات العملاء.';

  @override
  String get previewFormTooltip => 'معاينة / اختبار النموذج';

  @override
  String get colFields => 'الحقول';

  @override
  String get directoryTitle => 'دليل الأعمال';

  @override
  String get directorySubtitle =>
      'نسّق الشركاء والموردين والمواقع المحلية مع بيانات التواصل.';

  @override
  String get addEntryAction => 'إضافة سجل';

  @override
  String get editEntryTitle => 'تعديل سجل الدليل';

  @override
  String get entryNameLabel => 'اسم النشاط / السجل';

  @override
  String get entryNameHint => 'مثال: مطعم، مورد';

  @override
  String get entryTypeLabel => 'النوع';

  @override
  String get entryWebsiteLabel => 'رابط الموقع';

  @override
  String get entryContactLabel => 'التواصل (هاتف / بريد)';

  @override
  String get entryLocationLabel => 'الموقع / العنوان';

  @override
  String get publishedInDirectory => 'منشور في الدليل';

  @override
  String get entryNameRequired => 'اسم السجل مطلوب.';

  @override
  String get totalEntries => 'إجمالي السجلات';

  @override
  String get withContactLabel => 'مع بيانات تواصل';

  @override
  String get searchDirectoryHint =>
      'ابحث في الدليل بالاسم أو الفئة أو التواصل...';

  @override
  String get noDirectoryTitle => 'لا توجد سجلات في الدليل';

  @override
  String get noDirectoryMessage =>
      'أضف شريكًا أو موردًا أو موقعًا لبناء دليلك.';

  @override
  String get viewLinkTooltip => 'عرض الرابط';

  @override
  String get websiteLabel => 'الموقع الإلكتروني';

  @override
  String get pagesPageTitle => 'صفحات المحتوى';

  @override
  String get pagesPageSubtitle =>
      'أدر صفحات السياسات العامة وشروط الشركة ومحتوى المدونة.';

  @override
  String get createPageAction => 'إنشاء صفحة';

  @override
  String get editPageTitle => 'تعديل الصفحة';

  @override
  String get pageTitleLabel => 'عنوان الصفحة';

  @override
  String get urlSlugLabel => 'الرابط المختصر';

  @override
  String get shortExcerptLabel => 'مقتطف قصير';

  @override
  String get excerptHint => 'ملخص من جملة أو جملتين يظهر في القوائم...';

  @override
  String get coverImageUrlLabel => 'رابط صورة الغلاف';

  @override
  String get pageBodyLabel => 'محتوى الصفحة';

  @override
  String get pageBodyHint => 'اكتب نصًا أو Markdown أو محتوى مقال...';

  @override
  String get seoMetaTitleLabel => 'عنوان SEO';

  @override
  String get seoMetaDescriptionLabel => 'وصف SEO';

  @override
  String get pageTitleRequired => 'عنوان الصفحة مطلوب.';

  @override
  String get pageContentRequired => 'محتوى الصفحة مطلوب.';

  @override
  String get pageSlugRequired => 'رابط مختصر صالح مطلوب.';

  @override
  String pageSlugInUse(Object slug) {
    return 'الرابط \"/pages/$slug\" مستخدم بالفعل.';
  }

  @override
  String get totalPages => 'إجمالي الصفحات';

  @override
  String get draftsLabel => 'المسودات';

  @override
  String get searchPagesHint => 'ابحث في الصفحات بالعنوان أو المحتوى...';

  @override
  String get noPagesTitle => 'لا توجد صفحات محتوى';

  @override
  String get noPagesMessage => 'أنشئ صفحة جديدة لنشر محتوى في متجرك.';

  @override
  String get readPreviewTooltip => 'قراءة / معاينة الصفحة';

  @override
  String get metaLabel => 'SEO';

  @override
  String get noContentYet => 'لم يُضف محتوى بعد.';

  @override
  String get colSeoTitle => 'عنوان SEO';
}
