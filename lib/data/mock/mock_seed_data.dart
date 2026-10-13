import '../../domain/models/category.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/form_definition.dart';
import '../../domain/models/order.dart';
import '../../domain/models/page_content.dart';
import '../../domain/models/product.dart';
import '../../domain/models/resource.dart';

// ignore_for_file: prefer_const_constructors

abstract class MockSeedData {
  MockSeedData._();

  // ── Categories ──────────────────────────────────────────────────
  static final categories = <Category>[
    Category(id: 'cat-1', name: 'Electronics', slug: 'electronics', createdAt: _d(60)),
    Category(id: 'cat-2', name: 'Clothing', slug: 'clothing', createdAt: _d(60)),
    Category(id: 'cat-3', name: 'Food & Beverage', slug: 'food', createdAt: _d(60)),
    Category(id: 'cat-4', name: 'Tools & Hardware', slug: 'tools', createdAt: _d(60)),
    Category(id: 'cat-5', name: 'Auto Parts', slug: 'auto', createdAt: _d(60)),
  ];

  // ── Products ─────────────────────────────────────────────────────
  static final products = <Product>[
    _p('p-01', 'Laptop Pro 15"', 'cat-1', 'Electronics', 8500, 6200, 'ELEC-001', 14, 2, ProductStatus.active, _d(45)),
    _p('p-02', 'Wireless Mouse', 'cat-1', 'Electronics', 120, 65, 'ELEC-002', 87, 5, ProductStatus.active, _d(40)),
    _p('p-03', 'USB Hub 7-Port', 'cat-1', 'Electronics', 85, 42, 'ELEC-003', 55, 5, ProductStatus.active, _d(38)),
    _p('p-04', 'Monitor 24"', 'cat-1', 'Electronics', 1800, 1350, 'ELEC-004', 8, 5, ProductStatus.active, _d(35)),
    _p('p-05', 'Cotton T-Shirt', 'cat-2', 'Clothing', 85, 40, 'CLO-001', 120, 10, ProductStatus.active, _d(50)),
    _p('p-06', 'Polo Shirt', 'cat-2', 'Clothing', 140, 70, 'CLO-002', 3, 10, ProductStatus.active, _d(48)),
    _p('p-07', 'Jeans Classic', 'cat-2', 'Clothing', 250, 130, 'CLO-003', 45, 5, ProductStatus.active, _d(46)),
    _p('p-08', 'Hoodie Sport', 'cat-2', 'Clothing', 180, 95, 'CLO-004', 0, 5, ProductStatus.active, _d(44)),
    _p('p-09', 'Olive Oil 1L', 'cat-3', 'Food & Beverage', 45, 28, 'FOOD-001', 200, 20, ProductStatus.active, _d(30)),
    _p('p-10', 'Honey Pure 500g', 'cat-3', 'Food & Beverage', 80, 50, 'FOOD-002', 4, 10, ProductStatus.active, _d(28)),
    _p('p-11', 'Mineral Water 24-Pack', 'cat-3', 'Food & Beverage', 35, 20, 'FOOD-003', 150, 20, ProductStatus.active, _d(25)),
    _p('p-12', 'Argan Oil 100ml', 'cat-3', 'Food & Beverage', 120, 65, 'FOOD-004', 32, 5, ProductStatus.active, _d(22)),
    _p('p-13', 'Hammer 500g', 'cat-4', 'Tools & Hardware', 65, 35, 'TOOL-001', 40, 5, ProductStatus.active, _d(55)),
    _p('p-14', 'Screwdriver Set 24pc', 'cat-4', 'Tools & Hardware', 95, 55, 'TOOL-002', 22, 5, ProductStatus.active, _d(52)),
    _p('p-15', 'Drill 18V', 'cat-4', 'Tools & Hardware', 650, 400, 'TOOL-003', 7, 3, ProductStatus.active, _d(50)),
    _p('p-16', 'Tape Measure 5m', 'cat-4', 'Tools & Hardware', 25, 12, 'TOOL-004', 65, 5, ProductStatus.draft, _d(48)),
    _p('p-17', 'Air Filter X20', 'cat-5', 'Auto Parts', 85, 48, 'AUTO-001', 36, 5, ProductStatus.active, _d(20)),
    _p('p-18', 'Oil Filter Pro', 'cat-5', 'Auto Parts', 55, 28, 'AUTO-002', 2, 5, ProductStatus.active, _d(18)),
    _p('p-19', 'Brake Pad Set', 'cat-5', 'Auto Parts', 180, 110, 'AUTO-003', 0, 5, ProductStatus.active, _d(15)),
    _p('p-20', 'Spark Plug Kit', 'cat-5', 'Auto Parts', 95, 55, 'AUTO-004', 18, 5, ProductStatus.archived, _d(60)),
  ];

  // ── Customers ────────────────────────────────────────────────────
  static final customers = <Customer>[
    _c('c-01', 'Ahmed Ben Ali', 'ahmed@example.com', '+212 661-234567', CustomerTier.vip, 'Casablanca', 12, 4850, _d(180)),
    _c('c-02', 'Sara Benali', 'sara@example.com', '+212 662-345678', CustomerTier.regular, 'Rabat', 3, 420, _d(120)),
    _c('c-03', 'Mohamed Chraibi', 'm.chraibi@mail.com', '+212 663-456789', CustomerTier.vip, 'Fes', 9, 7200, _d(200)),
    _c('c-04', 'Fatima Zahra', 'fz@example.com', '+212 664-567890', CustomerTier.regular, 'Marrakech', 5, 1100, _d(90)),
    _c('c-05', 'Karim Naciri', 'karim.n@mail.com', '+212 665-678901', CustomerTier.regular, 'Agadir', 2, 350, _d(60)),
    _c('c-06', 'Leila Mansouri', 'leila@example.com', '+212 666-789012', CustomerTier.vip, 'Casablanca', 15, 9400, _d(365)),
    _c('c-07', 'Youssef Alami', 'yalami@mail.com', '+212 667-890123', CustomerTier.regular, 'Meknes', 4, 680, _d(75)),
    _c('c-08', 'Nadia Berrada', 'nadia@example.com', '+212 668-901234', CustomerTier.regular, 'Rabat', 1, 180, _d(30)),
    _c('c-09', 'Omar Tazi', 'omar.t@mail.com', '+212 669-012345', CustomerTier.vip, 'Casablanca', 8, 5600, _d(280)),
    _c('c-10', 'Amina El Fassi', 'amina@example.com', '+212 660-123456', CustomerTier.regular, 'Tanger', 6, 950, _d(110)),
  ];

  // ── Orders ───────────────────────────────────────────────────────
  static final orders = <Order>[
    _o('o-01', '#1048', 'c-01', 'Ahmed Ben Ali', OrderStatus.delivered, 2650, _d(2), [
      OrderItem(id: 'oi-1', orderId: 'o-01', productId: 'p-01', productName: 'Laptop Pro 15"', productSku: 'ELEC-001', unitPrice: 8500, qty: 1, subtotal: 8500),
    ]),
    _o('o-02', '#1047', 'c-03', 'Mohamed Chraibi', OrderStatus.shipped, 720, _d(3), [
      OrderItem(id: 'oi-2', orderId: 'o-02', productId: 'p-05', productName: 'Cotton T-Shirt', productSku: 'CLO-001', unitPrice: 85, qty: 4, subtotal: 340),
      OrderItem(id: 'oi-3', orderId: 'o-02', productId: 'p-07', productName: 'Jeans Classic', productSku: 'CLO-003', unitPrice: 250, qty: 1, subtotal: 250),
    ]),
    _o('o-03', '#1046', 'c-06', 'Leila Mansouri', OrderStatus.paid, 1800, _d(4), [
      OrderItem(id: 'oi-4', orderId: 'o-03', productId: 'p-04', productName: 'Monitor 24"', productSku: 'ELEC-004', unitPrice: 1800, qty: 1, subtotal: 1800),
    ]),
    _o('o-04', '#1045', 'c-02', 'Sara Benali', OrderStatus.pending, 420, _d(1), [
      OrderItem(id: 'oi-5', orderId: 'o-04', productId: 'p-09', productName: 'Olive Oil 1L', productSku: 'FOOD-001', unitPrice: 45, qty: 4, subtotal: 180),
      OrderItem(id: 'oi-6', orderId: 'o-04', productId: 'p-12', productName: 'Argan Oil 100ml', productSku: 'FOOD-004', unitPrice: 120, qty: 2, subtotal: 240),
    ]),
    _o('o-05', '#1044', 'c-09', 'Omar Tazi', OrderStatus.delivered, 650, _d(6), [
      OrderItem(id: 'oi-7', orderId: 'o-05', productId: 'p-15', productName: 'Drill 18V', productSku: 'TOOL-003', unitPrice: 650, qty: 1, subtotal: 650),
    ]),
    _o('o-06', '#1043', 'c-04', 'Fatima Zahra', OrderStatus.cancelled, 255, _d(7), [
      OrderItem(id: 'oi-8', orderId: 'o-06', productId: 'p-13', productName: 'Hammer 500g', productSku: 'TOOL-001', unitPrice: 65, qty: 2, subtotal: 130),
      OrderItem(id: 'oi-9', orderId: 'o-06', productId: 'p-14', productName: 'Screwdriver Set 24pc', productSku: 'TOOL-002', unitPrice: 95, qty: 1, subtotal: 95),
    ]),
    _o('o-07', '#1042', 'c-01', 'Ahmed Ben Ali', OrderStatus.delivered, 510, _d(10), [
      OrderItem(id: 'oi-10', orderId: 'o-07', productId: 'p-17', productName: 'Air Filter X20', productSku: 'AUTO-001', unitPrice: 85, qty: 2, subtotal: 170),
      OrderItem(id: 'oi-11', orderId: 'o-07', productId: 'p-18', productName: 'Oil Filter Pro', productSku: 'AUTO-002', unitPrice: 55, qty: 2, subtotal: 110),
      OrderItem(id: 'oi-12', orderId: 'o-07', productId: 'p-19', productName: 'Brake Pad Set', productSku: 'AUTO-003', unitPrice: 180, qty: 1, subtotal: 180),
    ]),
    _o('o-08', '#1041', 'c-07', 'Youssef Alami', OrderStatus.paid, 680, _d(12), [
      OrderItem(id: 'oi-13', orderId: 'o-08', productId: 'p-03', productName: 'USB Hub 7-Port', productSku: 'ELEC-003', unitPrice: 85, qty: 4, subtotal: 340),
      OrderItem(id: 'oi-14', orderId: 'o-08', productId: 'p-02', productName: 'Wireless Mouse', productSku: 'ELEC-002', unitPrice: 120, qty: 2, subtotal: 240),
    ]),
    _o('o-09', '#1040', 'c-05', 'Karim Naciri', OrderStatus.pending, 350, _d(1), [
      OrderItem(id: 'oi-15', orderId: 'o-09', productId: 'p-11', productName: 'Mineral Water 24-Pack', productSku: 'FOOD-003', unitPrice: 35, qty: 10, subtotal: 350),
    ]),
    _o('o-10', '#1039', 'c-10', 'Amina El Fassi', OrderStatus.shipped, 500, _d(5), [
      OrderItem(id: 'oi-16', orderId: 'o-10', productId: 'p-08', productName: 'Hoodie Sport', productSku: 'CLO-004', unitPrice: 180, qty: 1, subtotal: 180),
      OrderItem(id: 'oi-17', orderId: 'o-10', productId: 'p-06', productName: 'Polo Shirt', productSku: 'CLO-002', unitPrice: 140, qty: 2, subtotal: 280),
    ]),
  ];

  // ── Resources (business directory / micro-directory) ─────────────
  static final resources = <Resource>[
    Resource(id: 'r-01', name: 'Atlas Supplies Co.', type: ResourceType.other, category: 'Suppliers', description: 'Wholesale supplier for tools and hardware.', contact: '+212 522-100200', url: 'https://atlas-supplies.example', location: 'Casablanca, Morocco', isPublished: true, createdAt: _d(20), updatedAt: _d(20)),
    Resource(id: 'r-02', name: 'Zahra Accounting', type: ResourceType.other, category: 'Services', description: 'Bookkeeping and tax filing for small businesses.', contact: 'info@zahra-accounting.example', url: 'https://zahra-accounting.example', location: 'Rabat, Morocco', isPublished: true, createdAt: _d(15), updatedAt: _d(5)),
    Resource(id: 'r-03', name: 'Diali Brand Guidelines.pdf', type: ResourceType.document, category: 'Brand Assets', storageSize: 5_200_000, mimeType: 'application/pdf', location: 'Internal', isPublished: false, createdAt: _d(90), updatedAt: _d(90)),
    Resource(id: 'r-04', name: 'Logo High Res.png', type: ResourceType.image, category: 'Brand Assets', storageSize: 1_100_000, mimeType: 'image/png', location: 'Internal', isPublished: true, createdAt: _d(90), updatedAt: _d(90)),
    Resource(id: 'r-05', name: 'Inventory Sheet.xlsx', type: ResourceType.spreadsheet, category: 'Internal Tools', storageSize: 220_000, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', location: 'Internal', createdAt: _d(7), updatedAt: _d(1)),
    Resource(id: 'r-06', name: 'Marrakech Logistics', type: ResourceType.other, category: 'Shipping', description: 'Last-mile delivery partner.', contact: '+212 524-300400', url: 'https://marrakech-logistics.example', location: 'Marrakech, Morocco', isPublished: false, createdAt: _d(10), updatedAt: _d(10)),
    Resource(id: 'r-07', name: 'Product Photos', type: ResourceType.folder, category: 'Brand Assets', location: 'Internal', createdAt: _d(30), updatedAt: _d(5)),
    Resource(id: 'r-08', name: 'Fes Trading Portal', type: ResourceType.other, category: 'Marketplace', description: 'Online marketplace for local artisans.', url: 'https://fes-trading.example', location: 'Fes, Morocco', isPublished: true, createdAt: _d(3), updatedAt: _d(1)),
  ];

  // ── Forms ────────────────────────────────────────────────────────
  static final forms = <FormDefinition>[
    FormDefinition(
      id: 'f-01', title: 'Contact Form', slug: 'contact',
      description: 'General contact form for website visitors.',
      status: FormStatus.published, submissionsCount: 24,
      fields: [
        AppFormField(id: 'ff-1', type: FieldType.text, label: 'Full name', required: true),
        AppFormField(id: 'ff-2', type: FieldType.email, label: 'Email address', required: true),
        AppFormField(id: 'ff-3', type: FieldType.textarea, label: 'Message', required: true),
      ],
      createdAt: _d(30), updatedAt: _d(2),
    ),
    FormDefinition(
      id: 'f-02', title: 'Product Inquiry', slug: 'product-inquiry',
      description: 'Let customers ask about specific products.',
      status: FormStatus.published, submissionsCount: 11,
      fields: [
        AppFormField(id: 'ff-4', type: FieldType.text, label: 'Name', required: true),
        AppFormField(id: 'ff-5', type: FieldType.email, label: 'Email', required: true),
        AppFormField(id: 'ff-6', type: FieldType.text, label: 'Product name', required: true),
        AppFormField(id: 'ff-7', type: FieldType.textarea, label: 'Details', required: false),
      ],
      createdAt: _d(25), updatedAt: _d(4),
    ),
    FormDefinition(
      id: 'f-03', title: 'Customer Feedback', slug: 'feedback',
      description: 'Collect satisfaction feedback after purchase.',
      status: FormStatus.published, submissionsCount: 67,
      fields: [
        AppFormField(id: 'ff-8', type: FieldType.select, label: 'Rating', required: true, options: ['5 - Excellent', '4 - Good', '3 - Average', '2 - Poor', '1 - Very poor']),
        AppFormField(id: 'ff-9', type: FieldType.textarea, label: 'Comments', required: false),
      ],
      createdAt: _d(60), updatedAt: _d(1),
    ),
    FormDefinition(
      id: 'f-04', title: 'Wholesale Request', slug: 'wholesale',
      description: 'Request wholesale pricing and conditions.',
      status: FormStatus.draft, submissionsCount: 0,
      fields: [
        AppFormField(id: 'ff-10', type: FieldType.text, label: 'Company name', required: true),
        AppFormField(id: 'ff-11', type: FieldType.email, label: 'Business email', required: true),
        AppFormField(id: 'ff-12', type: FieldType.phone, label: 'Phone', required: true),
        AppFormField(id: 'ff-13', type: FieldType.textarea, label: 'Products of interest', required: false),
      ],
      createdAt: _d(5), updatedAt: _d(5),
    ),
  ];

  // ── Articles / Pages ─────────────────────────────────────────────
  static final pages = <PageContent>[
    PageContent(id: 'pg-01', title: 'About Us', slug: 'about', status: PageStatus.published,
      excerpt: 'Who we are and what we stand for.',
      content: 'We are a trusted local business serving our community since 2018.',
      metaTitle: 'About diali', metaDesc: 'Learn about our story and values.',
      createdAt: _d(90), updatedAt: _d(15)),
    PageContent(id: 'pg-02', title: 'Contact', slug: 'contact', status: PageStatus.published,
      excerpt: 'How to reach our team.',
      content: 'Reach us by phone, email, or visit our store.',
      metaTitle: 'Contact Us', metaDesc: 'Get in touch with our team.',
      createdAt: _d(90), updatedAt: _d(10)),
    PageContent(id: 'pg-03', title: 'Terms of Service', slug: 'terms', status: PageStatus.published,
      excerpt: 'The rules that apply when you shop with us.',
      content: 'By using our platform you agree to these terms.',
      metaTitle: 'Terms of Service',
      createdAt: _d(80), updatedAt: _d(80)),
    PageContent(id: 'pg-04', title: 'Privacy Policy', slug: 'privacy', status: PageStatus.published,
      excerpt: 'How we protect your personal data.',
      content: 'We protect your data and respect your privacy.',
      metaTitle: 'Privacy Policy',
      createdAt: _d(80), updatedAt: _d(80)),
    PageContent(id: 'pg-05', title: 'FAQ', slug: 'faq', status: PageStatus.draft,
      excerpt: 'Answers to the most common questions.',
      content: 'Frequently asked questions about our products and services.',
      metaTitle: 'FAQ',
      createdAt: _d(3), updatedAt: _d(1)),
    PageContent(id: 'pg-06', title: '5 Tips to Manage Your Stock',
      slug: '5-tips-to-manage-your-stock', status: PageStatus.published,
      excerpt: 'Practical advice to avoid stockouts and dead inventory.',
      content: 'Keeping an accurate inventory is the backbone of a healthy retail '
          'business. Start by reviewing your low-stock alerts weekly, then set a '
          'reorder threshold for every fast-moving product.',
      metaTitle: 'Stock management tips',
      metaDesc: 'Five practical inventory tips for small shops.',
      createdAt: _d(12), updatedAt: _d(2)),
  ];

  // ── Helpers ──────────────────────────────────────────────────────
  static DateTime _d(int daysAgo) =>
      DateTime.now().subtract(Duration(days: daysAgo));

  static Product _p(
    String id,
    String name,
    String catId,
    String catName,
    double price,
    double cost,
    String sku,
    int stock,
    int lowThreshold,
    ProductStatus status,
    DateTime created,
  ) =>
      Product(
        id: id,
        name: name,
        categoryId: catId,
        categoryName: catName,
        price: price,
        costPrice: cost,
        sku: sku,
        stockQty: stock,
        lowStockThreshold: lowThreshold,
        status: status,
        createdAt: created,
        updatedAt: created,
      );

  static Customer _c(
    String id,
    String name,
    String email,
    String phone,
    CustomerTier tier,
    String city,
    int orders,
    double spent,
    DateTime created,
  ) =>
      Customer(
        id: id,
        name: name,
        email: email,
        phone: phone,
        tier: tier,
        city: city,
        country: 'Morocco',
        totalOrders: orders,
        totalSpent: spent,
        createdAt: created,
        updatedAt: created,
      );

  static Order _o(
    String id,
    String number,
    String? customerId,
    String? customerName,
    OrderStatus status,
    double total,
    DateTime created,
    List<OrderItem> items,
  ) =>
      Order(
        id: id,
        orderNumber: number,
        customerId: customerId,
        customerName: customerName,
        status: status,
        total: total,
        subtotal: total,
        items: items,
        createdAt: created,
        updatedAt: created,
      );
}
