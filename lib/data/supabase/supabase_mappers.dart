import '../../domain/models/category.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/form_definition.dart';
import '../../domain/models/location.dart';
import '../../domain/models/order.dart';
import '../../domain/models/page_content.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_tracking.dart';
import '../../domain/models/resource.dart';
import '../../domain/models/site_settings.dart';
import '../../domain/models/template.dart';

/// Central conversion between domain models and Supabase rows (snake_case).
///
/// Keeping this in one place means the Hive persistence path (`toMap`/
/// `fromMap` with camelCase) stays untouched while the remote layer has a
/// single, testable mapping surface.
class Db {
  const Db._();

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;

  static DateTime _dateOr(Object? v, DateTime fallback) =>
      _date(v) ?? fallback;

  static String? _str(Object? v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static String? _iso(DateTime? d) => d?.toUtc().toIso8601String();

  static double _dbl(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  static double? _dblN(Object? v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

  static int _int(Object? v, [int fallback = 0]) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? fallback;

  static bool _bool(Object? v) => v == true || v == 'true';

  static List<String> _strings(Object? v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }

  /// Extracts a joined relation's `name` whether PostgREST returns a map or list.
  static String? _joinedName(Object? relation) {
    if (relation is Map) return _str(relation['name']);
    if (relation is List && relation.isNotEmpty && relation.first is Map) {
      return _str((relation.first as Map)['name']);
    }
    return null;
  }

  // ---- Category -------------------------------------------------------
  static Map<String, dynamic> category(Category c) => {
        'id': c.id,
        'name': c.name,
        'slug': c.slug,
        'description': c.description,
        'parent_id': c.parentId,
        'position': c.position,
        'image_url': c.imageUrl,
      };

  static Category categoryFrom(Map<String, dynamic> r) => Category(
        id: r['id'] as String,
        name: _str(r['name']) ?? '',
        slug: _str(r['slug']) ?? '',
        description: _str(r['description']),
        parentId: _str(r['parent_id']),
        position: _int(r['position']),
        imageUrl: _str(r['image_url']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
      );

  // ---- Location -------------------------------------------------------
  static Map<String, dynamic> location(Location l) => {
        'id': l.id,
        'name': l.name,
        'type': l.type.name,
        'address': l.address,
        'city': l.city,
        'country': l.country,
        'latitude': l.latitude,
        'longitude': l.longitude,
        'contact_person': l.contactPerson,
        'contact_phone': l.contactPhone,
        'is_default': l.isDefault,
      };

  static Location locationFrom(Map<String, dynamic> r) => Location(
        id: r['id'] as String,
        name: _str(r['name']) ?? '',
        type: _enum(LocationType.values, r['type'], LocationType.warehouse),
        address: _str(r['address']),
        city: _str(r['city']),
        country: _str(r['country']),
        latitude: _dblN(r['latitude']),
        longitude: _dblN(r['longitude']),
        contactPerson: _str(r['contact_person']),
        contactPhone: _str(r['contact_phone']),
        isDefault: _bool(r['is_default']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  // ---- Product --------------------------------------------------------
  static Map<String, dynamic> product(Product p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'sku': p.sku,
        'category_id': p.categoryId,
        'location_id': p.locationId,
        'tracking_status': p.trackingStatus.name,
        'tracking_code': p.trackingCode,
        'price': p.price,
        'cost_price': p.costPrice,
        'stock_qty': p.stockQty,
        'low_stock_threshold': p.lowStockThreshold,
        'unit': p.unit,
        'image_url': p.imageUrl,
        'extra_images': p.extraImages,
        'is_demo': p.isDemo,
        'status': p.status.name,
      };

  static Product productFrom(Map<String, dynamic> r) => Product(
        id: r['id'] as String,
        name: _str(r['name']) ?? '',
        description: _str(r['description']),
        sku: _str(r['sku']),
        categoryId: _str(r['category_id']),
        categoryName: _joinedName(r['category']),
        locationId: _str(r['location_id']),
        locationName: _joinedName(r['location']),
        trackingStatus:
            _enum(TrackingStatus.values, r['tracking_status'], TrackingStatus.inStock),
        trackingCode: _str(r['tracking_code']),
        price: _dbl(r['price']),
        costPrice: _dblN(r['cost_price']),
        stockQty: _int(r['stock_qty']),
        lowStockThreshold: _int(r['low_stock_threshold'], 5),
        unit: _str(r['unit']) ?? 'unit',
        imageUrl: _str(r['image_url']),
        extraImages: _strings(r['extra_images']),
        isDemo: _bool(r['is_demo']),
        status: _enum(ProductStatus.values, r['status'], ProductStatus.active),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  // ---- Customer -------------------------------------------------------
  static Map<String, dynamic> customer(Customer c) => {
        'id': c.id,
        'name': c.name,
        'email': c.email,
        'phone': c.phone,
        'address': c.address,
        'city': c.city,
        'country': c.country,
        'tier': c.tier.name,
        'notes': c.notes,
      };

  static Customer customerFrom(Map<String, dynamic> r) => Customer(
        id: r['id'] as String,
        name: _str(r['name']) ?? '',
        email: _str(r['email']),
        phone: _str(r['phone']),
        address: _str(r['address']),
        city: _str(r['city']),
        country: _str(r['country']),
        tier: _enum(CustomerTier.values, r['tier'], CustomerTier.regular),
        notes: _str(r['notes']),
        totalOrders: _int(r['total_orders']),
        totalSpent: _dbl(r['total_spent']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  // ---- Order ----------------------------------------------------------
  static Map<String, dynamic> order(Order o) => {
        'id': o.id,
        'order_number': o.orderNumber,
        'customer_id': o.customerId,
        'customer_name': o.customerName,
        'customer_email': o.customerEmail,
        'shipping_address': o.shippingAddress,
        'shipping_city': o.shippingCity,
        'status': o.status.name,
        'subtotal': o.subtotal,
        'discount': o.discount,
        'tax': o.tax,
        'shipping_fee': o.shippingFee,
        'total': o.total,
        'paid_at': _iso(o.paidAt),
        'delivered_at': _iso(o.deliveredAt),
        'cancelled_at': _iso(o.cancelledAt),
        'notes': o.notes,
      };

  static Order orderFrom(Map<String, dynamic> r) => Order(
        id: r['id'] as String,
        orderNumber: _str(r['order_number']) ?? '',
        customerId: _str(r['customer_id']),
        customerName: _str(r['customer_name']) ?? _joinedName(r['customer']),
        customerEmail: _str(r['customer_email']),
        shippingAddress: _str(r['shipping_address']),
        shippingCity: _str(r['shipping_city']),
        status: _enum(OrderStatus.values, r['status'], OrderStatus.pending),
        items: (r['order_items'] is List)
            ? (r['order_items'] as List)
                .whereType<Map>()
                .map((e) => orderItemFrom(e.cast<String, dynamic>()))
                .toList()
            : const [],
        subtotal: _dbl(r['subtotal']),
        discount: _dbl(r['discount']),
        tax: _dbl(r['tax']),
        shippingFee: _dbl(r['shipping_fee']),
        total: _dbl(r['total']),
        paidAt: _date(r['paid_at']),
        deliveredAt: _date(r['delivered_at']),
        cancelledAt: _date(r['cancelled_at']),
        notes: _str(r['notes']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  static Map<String, dynamic> orderItem(OrderItem i) => {
        'id': i.id,
        'order_id': i.orderId,
        'product_id': i.productId,
        'product_name': i.productName,
        'product_sku': i.productSku,
        'unit_price': i.unitPrice,
        'qty': i.qty,
        'subtotal': i.subtotal,
      };

  static OrderItem orderItemFrom(Map<String, dynamic> r) => OrderItem(
        id: r['id'] as String,
        orderId: _str(r['order_id']) ?? '',
        productId: _str(r['product_id']),
        productName: _str(r['product_name']) ?? '',
        productSku: _str(r['product_sku']),
        unitPrice: _dbl(r['unit_price']),
        qty: _int(r['qty'], 1),
        subtotal: _dbl(r['subtotal']),
      );

  // ---- Resource -------------------------------------------------------
  static Map<String, dynamic> resource(Resource r) => {
        'id': r.id,
        'name': r.name,
        'description': r.description,
        'type': r.type.name,
        'category': r.category,
        'url': r.url,
        'contact': r.contact,
        'location': r.location,
        'image_url': r.imageUrl,
        'is_published': r.isPublished,
        'storage_path': r.storagePath,
        'storage_size': r.storageSize,
        'mime_type': r.mimeType,
        'folder_id': r.folderId,
      };

  static Resource resourceFrom(Map<String, dynamic> r) => Resource(
        id: r['id'] as String,
        name: _str(r['name']) ?? '',
        description: _str(r['description']),
        type: _enum(ResourceType.values, r['type'], ResourceType.document),
        category: _str(r['category']),
        url: _str(r['url']),
        contact: _str(r['contact']),
        location: _str(r['location']),
        imageUrl: _str(r['image_url']),
        isPublished: _bool(r['is_published']),
        storagePath: _str(r['storage_path']),
        storageSize: r['storage_size'] == null ? null : _int(r['storage_size']),
        mimeType: _str(r['mime_type']),
        folderId: _str(r['folder_id']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  // ---- Form -----------------------------------------------------------
  static Map<String, dynamic> form(FormDefinition f) => {
        'id': f.id,
        'title': f.title,
        'description': f.description,
        'slug': f.slug,
        'status': f.status.name,
        'fields': f.fields.map(formField).toList(),
      };

  static FormDefinition formFrom(Map<String, dynamic> r) => FormDefinition(
        id: r['id'] as String,
        title: _str(r['title']) ?? '',
        description: _str(r['description']),
        slug: _str(r['slug']) ?? '',
        status: _enum(FormStatus.values, r['status'], FormStatus.draft),
        fields: (r['fields'] is List)
            ? (r['fields'] as List)
                .whereType<Map>()
                .map((e) => formFieldFrom(e.cast<String, dynamic>()))
                .toList()
            : const [],
        submissionsCount: _int(r['submissions_count']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  static Map<String, dynamic> formField(AppFormField f) => {
        'id': f.id,
        'type': f.type.name,
        'label': f.label,
        'placeholder': f.placeholder,
        'required': f.required,
        'options': f.options,
      };

  static AppFormField formFieldFrom(Map<String, dynamic> r) => AppFormField(
        id: _str(r['id']) ?? '',
        type: _enum(FieldType.values, r['type'], FieldType.text),
        label: _str(r['label']) ?? '',
        placeholder: _str(r['placeholder']),
        required: _bool(r['required']),
        options: _strings(r['options']),
      );

  // ---- Page / Article -------------------------------------------------
  static Map<String, dynamic> page(PageContent p) => {
        'id': p.id,
        'title': p.title,
        'slug': p.slug,
        'excerpt': p.excerpt,
        'content': p.content,
        'image_url': p.imageUrl,
        'category_id': p.categoryId,
        'status': p.status.name,
        'meta_title': p.metaTitle,
        'meta_desc': p.metaDesc,
        'published_at': _iso(p.publishedAt),
      };

  static PageContent pageFrom(Map<String, dynamic> r) => PageContent(
        id: r['id'] as String,
        title: _str(r['title']) ?? '',
        slug: _str(r['slug']) ?? '',
        excerpt: _str(r['excerpt']),
        content: _str(r['content']),
        imageUrl: _str(r['image_url']),
        categoryId: _str(r['category_id']),
        categoryName: _joinedName(r['category']),
        status: _enum(PageStatus.values, r['status'], PageStatus.draft),
        metaTitle: _str(r['meta_title']),
        metaDesc: _str(r['meta_desc']),
        publishedAt: _date(r['published_at']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  // ---- Template -------------------------------------------------------
  static Map<String, dynamic> template(Template t) => {
        'id': t.id,
        'name': t.name,
        'slug': t.slug,
        'description': t.description,
        'category': t.category.name,
        'preview_image_url': t.previewImageUrl,
        'tags': t.tags,
        'is_published': t.isPublished,
        'is_featured': t.isFeatured,
        'customization': customization(t.customization),
      };

  static Template templateFrom(Map<String, dynamic> r) => Template(
        id: r['id'] as String,
        name: _str(r['name']) ?? '',
        slug: _str(r['slug']) ?? '',
        description: _str(r['description']) ?? '',
        category:
            _enum(TemplateCategory.values, r['category'], TemplateCategory.store),
        previewImageUrl: _str(r['preview_image_url']),
        tags: _strings(r['tags']),
        isPublished: r['is_published'] == null ? true : _bool(r['is_published']),
        isFeatured: _bool(r['is_featured']),
        customization: customizationFrom(r['customization']),
        createdAt: _dateOr(r['created_at'], DateTime.now()),
        updatedAt: _dateOr(r['updated_at'], DateTime.now()),
      );

  static Map<String, dynamic> customization(TemplateCustomization c) => {
        'brandName': c.brandName,
        'tagline': c.tagline,
        'logoUrl': c.logoUrl,
        'primaryColorHex': c.primaryColorHex,
        'accentColorHex': c.accentColorHex,
        'fontFamily': c.fontFamily,
        'heroTitle': c.heroTitle,
        'heroSubtitle': c.heroSubtitle,
        'heroButtonText': c.heroButtonText,
        'heroImageUrl': c.heroImageUrl,
        'contactEmail': c.contactEmail,
        'contactPhone': c.contactPhone,
        'address': c.address,
        'footerText': c.footerText,
        'showHero': c.showHero,
        'showFeaturedProducts': c.showFeaturedProducts,
        'showArticles': c.showArticles,
        'showContact': c.showContact,
      };

  static TemplateCustomization customizationFrom(Object? raw) {
    if (raw is! Map) return const TemplateCustomization();
    final m = raw.cast<String, dynamic>();
    const d = TemplateCustomization();
    return TemplateCustomization(
      brandName: _str(m['brandName']) ?? d.brandName,
      tagline: _str(m['tagline']) ?? d.tagline,
      logoUrl: _str(m['logoUrl']),
      primaryColorHex: _str(m['primaryColorHex']) ?? d.primaryColorHex,
      accentColorHex: _str(m['accentColorHex']) ?? d.accentColorHex,
      fontFamily: _str(m['fontFamily']) ?? d.fontFamily,
      heroTitle: _str(m['heroTitle']) ?? d.heroTitle,
      heroSubtitle: _str(m['heroSubtitle']) ?? d.heroSubtitle,
      heroButtonText: _str(m['heroButtonText']) ?? d.heroButtonText,
      heroImageUrl: _str(m['heroImageUrl']),
      contactEmail: _str(m['contactEmail']) ?? d.contactEmail,
      contactPhone: _str(m['contactPhone']) ?? d.contactPhone,
      address: _str(m['address']) ?? d.address,
      footerText: _str(m['footerText']) ?? d.footerText,
      showHero: m['showHero'] == null ? d.showHero : _bool(m['showHero']),
      showFeaturedProducts: m['showFeaturedProducts'] == null
          ? d.showFeaturedProducts
          : _bool(m['showFeaturedProducts']),
      showArticles: m['showArticles'] == null ? d.showArticles : _bool(m['showArticles']),
      showContact: m['showContact'] == null ? d.showContact : _bool(m['showContact']),
    );
  }

  // ---- Site settings --------------------------------------------------
  static Map<String, dynamic> siteSettings(SiteSettings s) {
    final c = s.customization;
    return {
      'active_template_id': s.activeTemplateId,
      'brand_name': c.brandName,
      'tagline': c.tagline,
      'logo_url': c.logoUrl,
      'primary_color_hex': c.primaryColorHex,
      'accent_color_hex': c.accentColorHex,
      'font_family': c.fontFamily,
      'hero_title': c.heroTitle,
      'hero_subtitle': c.heroSubtitle,
      'hero_button_text': c.heroButtonText,
      'hero_image_url': c.heroImageUrl,
      'contact_email': c.contactEmail,
      'contact_phone': c.contactPhone,
      'address': c.address,
      'footer_text': c.footerText,
      'show_hero': c.showHero,
      'show_featured_products': c.showFeaturedProducts,
      'show_articles': c.showArticles,
      'show_contact': c.showContact,
    };
  }

  static SiteSettings siteSettingsFrom(Map<String, dynamic> r) {
    const d = TemplateCustomization();
    return SiteSettings(
      activeTemplateId: _str(r['active_template_id']),
      customization: TemplateCustomization(
        brandName: _str(r['brand_name']) ?? d.brandName,
        tagline: _str(r['tagline']) ?? '',
        logoUrl: _str(r['logo_url']),
        primaryColorHex: _str(r['primary_color_hex']) ?? d.primaryColorHex,
        accentColorHex: _str(r['accent_color_hex']) ?? d.accentColorHex,
        fontFamily: _str(r['font_family']) ?? d.fontFamily,
        heroTitle: _str(r['hero_title']) ?? '',
        heroSubtitle: _str(r['hero_subtitle']) ?? '',
        heroButtonText: _str(r['hero_button_text']) ?? '',
        heroImageUrl: _str(r['hero_image_url']),
        contactEmail: _str(r['contact_email']) ?? '',
        contactPhone: _str(r['contact_phone']) ?? '',
        address: _str(r['address']) ?? '',
        footerText: _str(r['footer_text']) ?? '',
        showHero: r['show_hero'] == null ? true : _bool(r['show_hero']),
        showFeaturedProducts: r['show_featured_products'] == null
            ? true
            : _bool(r['show_featured_products']),
        showArticles: r['show_articles'] == null ? true : _bool(r['show_articles']),
        showContact: r['show_contact'] == null ? true : _bool(r['show_contact']),
      ),
    );
  }

  // ---- App settings ---------------------------------------------------
  static double appSettingNumber(Map<String, dynamic> row, String key,
          [double fallback = 0]) =>
      _dblN((row['value'] as Map?)?.cast<String, dynamic>()[key]) ?? fallback;

  static String appSettingString(Map<String, dynamic> row, String key,
          [String fallback = '']) =>
      _str((row['value'] as Map?)?.cast<String, dynamic>()[key]) ?? fallback;

  // ---- Tracking -------------------------------------------------------
  static Map<String, dynamic> trackingEvent(TrackingEvent e) => {
        'id': e.id,
        'product_id': e.productId,
        'status': e.status.name,
        'status_title': e.statusTitle,
        'location_name': e.locationName,
        'location_address': e.locationAddress,
        'latitude': e.latitude,
        'longitude': e.longitude,
        'actor_name': e.actorName,
        'actor_role': e.actorRole,
        'description': e.description,
        'reference_number': e.referenceNumber,
        'notes': e.notes,
        'occurred_at': _iso(e.timestamp),
      };

  static TrackingEvent trackingEventFrom(Map<String, dynamic> r) => TrackingEvent(
        id: r['id'] as String,
        productId: _str(r['product_id']) ?? '',
        status: _enum(TrackingStatus.values, r['status'], TrackingStatus.inStock),
        statusTitle: _str(r['status_title']),
        locationName: _str(r['location_name']),
        locationAddress: _str(r['location_address']),
        latitude: _dblN(r['latitude']),
        longitude: _dblN(r['longitude']),
        actorName: _str(r['actor_name']),
        actorRole: _str(r['actor_role']),
        description: _str(r['description']),
        referenceNumber: _str(r['reference_number']),
        notes: _str(r['notes']),
        timestamp: _dateOr(r['occurred_at'], DateTime.now()),
      );

  static T _enum<T extends Enum>(List<T> values, Object? raw, T fallback) =>
      values.firstWhere((v) => v.name == raw, orElse: () => fallback);
}
