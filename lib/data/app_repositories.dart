import '../core/config/app_config.dart';
import '../core/storage/catalog_store.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/customer_repository.dart';
import '../domain/repositories/form_repository.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/repositories/page_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/resource_repository.dart';
import '../domain/repositories/site_settings_repository.dart';
import '../domain/repositories/template_repository.dart';
import '../domain/repositories/tracking_repository.dart';
import 'demo/demo_data_seeder.dart';
import 'mock/mock_category_repository.dart';
import 'mock/mock_customer_repository.dart';
import 'mock/mock_form_repository.dart';
import 'mock/mock_location_repository.dart';
import 'mock/mock_order_repository.dart';
import 'mock/mock_page_repository.dart';
import 'mock/mock_product_repository.dart';
import 'mock/mock_resource_repository.dart';
import 'mock/mock_site_settings_repository.dart';
import 'mock/mock_template_repository.dart';
import 'mock/mock_tracking_repository.dart';
import 'supabase/supabase_category_repository.dart';
import 'supabase/supabase_customer_repository.dart';
import 'supabase/supabase_form_repository.dart';
import 'supabase/supabase_location_repository.dart';
import 'supabase/supabase_order_repository.dart';
import 'supabase/supabase_page_repository.dart';
import 'supabase/supabase_product_repository.dart';
import 'supabase/supabase_resource_repository.dart';
import 'supabase/supabase_site_settings_repository.dart';
import 'supabase/supabase_template_repository.dart';
import 'supabase/supabase_tracking_repository.dart';

/// Composition root for all repositories.
///
/// When Supabase is configured (`--dart-define=SUPABASE_URL/SUPABASE_ANON_KEY`)
/// production screens use the remote repositories; otherwise the app runs on
/// in-memory/Hive mocks so it always works offline and in tests.
class AppRepositories {
  AppRepositories._({CatalogStore? store, bool useRemote = false})
      : _store = store,
        _useRemote = useRemote {
    if (useRemote) {
      categories = SupabaseCategoryRepository();
      products = SupabaseProductRepository(categoryRepository: categories);
      customers = SupabaseCustomerRepository();
      orders = SupabaseOrderRepository();
      resources = SupabaseResourceRepository();
      forms = SupabaseFormRepository();
      pages = SupabasePageRepository();
      locations = SupabaseLocationRepository();
      templates = SupabaseTemplateRepository();
      tracking = SupabaseTrackingRepository();
      siteSettings = SupabaseSiteSettingsRepository();
    } else {
      final mockCategories = MockCategoryRepository(store: store);
      categories = mockCategories;
      final mockProducts =
          MockProductRepository(categoryRepository: mockCategories, store: store);
      products = mockProducts;
      customers = MockCustomerRepository();
      orders = MockOrderRepository(productRepository: mockProducts);
      resources = MockResourceRepository();
      forms = MockFormRepository();
      pages = MockPageRepository();
      locations = MockLocationRepository();
      templates = MockTemplateRepository();
      tracking = MockTrackingRepository(productRepository: mockProducts);
      siteSettings = MockSiteSettingsRepository();
    }
  }

  static AppRepositories? _instance;

  static AppRepositories get instance => _instance ??= AppRepositories._();

  /// Wires a persistent [CatalogStore] into the repositories. Called once from
  /// `main()`; tests and previews keep the in-memory default.
  static AppRepositories configure({CatalogStore? store, bool? useRemote}) {
    if (_instance != null && store == null && useRemote == null) {
      return _instance!;
    }
    _instance = AppRepositories._(
      store: store,
      useRemote: useRemote ?? AppConfig.isSupabaseConfigured,
    );
    return _instance!;
  }

  /// Restores the in-memory default. Intended for tests.
  static void reset() => _instance = null;

  final CatalogStore? _store;
  final bool _useRemote;

  late final CategoryRepository categories;
  late final ProductRepository products;
  late final OrderRepository orders;
  late final CustomerRepository customers;
  late final ResourceRepository resources;
  late final FormRepository forms;
  late final PageRepository pages;
  late final LocationRepository locations;
  late final TemplateRepository templates;
  late final TrackingRepository tracking;
  late final SiteSettingsRepository siteSettings;

  CatalogStore? get store => _store;

  /// True when repositories are backed by the remote backend.
  bool get isRemote => _useRemote;

  /// Fresh seeder bound to the current repositories. Only meaningful for the
  /// local/mock data source.
  DemoDataSeeder get demoSeeder =>
      DemoDataSeeder(categories: categories, products: products);
}
