import '../../domain/models/category.dart';
import '../../domain/models/product.dart';

/// Immutable definition of a demo category before it is resolved against the
/// live repository (existing categories with the same name are reused).
class DemoCategoryDef {
  const DemoCategoryDef({
    required this.name,
    required this.slug,
    required this.description,
    required this.position,
    required this.asset,
  });

  final String name;
  final String slug;
  final String description;
  final int position;
  final String asset;
}

/// Immutable definition of a demo product. Images use bundled assets so no
/// network access is ever required.
class DemoProductDef {
  const DemoProductDef({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryName,
    required this.price,
    required this.costPrice,
    required this.sku,
    required this.stockQty,
    required this.mainImage,
    this.extraImages = const <String>[],
  });

  final String id;
  final String name;
  final String description;
  final String categoryName;
  final double price;
  final double costPrice;
  final String sku;
  final int stockQty;
  final String mainImage;
  final List<String> extraImages;
}

/// The optional demo catalog: 12 products across 6 categories with original,
/// locally bundled imagery. Every record is flagged as [Category.isDemo] /
/// [Product.isDemo] and carries a `DEMO-` SKU so demo prices are explicit.
abstract class DemoCatalog {
  DemoCatalog._();

  static const int productCount = 12;
  static const int categoryCount = 6;

  static const List<DemoCategoryDef> categories = [
    DemoCategoryDef(
      name: 'Clothing',
      slug: 'clothing',
      description: 'Everyday apparel for the whole family.',
      position: 1,
      asset: 'assets/images/categories/clothing.png',
    ),
    DemoCategoryDef(
      name: 'Shoes',
      slug: 'shoes',
      description: 'Sneakers, boots and comfort footwear.',
      position: 2,
      asset: 'assets/images/categories/shoes.png',
    ),
    DemoCategoryDef(
      name: 'Electronics',
      slug: 'electronics',
      description: 'Everyday gadgets and smart accessories.',
      position: 3,
      asset: 'assets/images/categories/electronics.png',
    ),
    DemoCategoryDef(
      name: 'Accessories',
      slug: 'accessories',
      description: 'Bags, wallets, eyewear and more.',
      position: 4,
      asset: 'assets/images/categories/accessories.png',
    ),
    DemoCategoryDef(
      name: 'Home and Decoration',
      slug: 'home-decor',
      description: 'Decor pieces and warm lighting for the home.',
      position: 5,
      asset: 'assets/images/categories/home_decor.png',
    ),
    DemoCategoryDef(
      name: 'Beauty and Personal Care',
      slug: 'beauty',
      description: 'Natural soaps and daily skincare.',
      position: 6,
      asset: 'assets/images/categories/beauty.png',
    ),
  ];

  static const List<DemoProductDef> products = [
    // Clothing
    DemoProductDef(
      id: 'demo-prod-01',
      name: 'Classic Cotton Shirt',
      description: 'Soft, breathable cotton shirt with a regular fit. (Demo)',
      categoryName: 'Clothing',
      price: 149,
      costPrice: 70,
      sku: 'DEMO-CLO-01',
      stockQty: 40,
      mainImage: 'assets/images/products/classic_shirt.png',
    ),
    DemoProductDef(
      id: 'demo-prod-02',
      name: 'Slim Fit Jeans',
      description: 'Stretch denim jeans with a modern slim cut. (Demo)',
      categoryName: 'Clothing',
      price: 229,
      costPrice: 120,
      sku: 'DEMO-CLO-02',
      stockQty: 25,
      mainImage: 'assets/images/products/slim_jeans.png',
    ),
    // Shoes
    DemoProductDef(
      id: 'demo-prod-03',
      name: 'Running Sneakers',
      description: 'Lightweight running shoes with cushioned soles. (Demo)',
      categoryName: 'Shoes',
      price: 399,
      costPrice: 210,
      sku: 'DEMO-SHO-01',
      stockQty: 30,
      mainImage: 'assets/images/products/running_sneakers.png',
    ),
    DemoProductDef(
      id: 'demo-prod-04',
      name: 'Leather Boots',
      description: 'Durable leather boots built for daily wear. (Demo)',
      categoryName: 'Shoes',
      price: 549,
      costPrice: 310,
      sku: 'DEMO-SHO-02',
      stockQty: 15,
      mainImage: 'assets/images/products/leather_boots.png',
      extraImages: ['assets/images/products/leather_boots_2.png'],
    ),
    // Electronics
    DemoProductDef(
      id: 'demo-prod-05',
      name: 'Wireless Earbuds',
      description: 'Compact earbuds with a charging case. (Demo)',
      categoryName: 'Electronics',
      price: 349,
      costPrice: 180,
      sku: 'DEMO-ELE-01',
      stockQty: 60,
      mainImage: 'assets/images/products/wireless_earbuds.png',
      extraImages: ['assets/images/products/wireless_earbuds_2.png'],
    ),
    DemoProductDef(
      id: 'demo-prod-06',
      name: 'Smart Watch',
      description: 'Fitness tracking smart watch with a bright display. (Demo)',
      categoryName: 'Electronics',
      price: 799,
      costPrice: 430,
      sku: 'DEMO-ELE-02',
      stockQty: 20,
      mainImage: 'assets/images/products/smart_watch.png',
      extraImages: ['assets/images/products/smart_watch_2.png'],
    ),
    // Accessories
    DemoProductDef(
      id: 'demo-prod-07',
      name: 'Leather Wallet',
      description: 'Handcrafted wallet with multiple card slots. (Demo)',
      categoryName: 'Accessories',
      price: 179,
      costPrice: 85,
      sku: 'DEMO-ACC-01',
      stockQty: 45,
      mainImage: 'assets/images/products/leather_wallet.png',
    ),
    DemoProductDef(
      id: 'demo-prod-08',
      name: 'Classic Sunglasses',
      description: 'UV-protective sunglasses with a timeless frame. (Demo)',
      categoryName: 'Accessories',
      price: 199,
      costPrice: 90,
      sku: 'DEMO-ACC-02',
      stockQty: 35,
      mainImage: 'assets/images/products/sunglasses.png',
      extraImages: ['assets/images/products/sunglasses_2.png'],
    ),
    // Home and Decoration
    DemoProductDef(
      id: 'demo-prod-09',
      name: 'Ceramic Vase',
      description: 'Minimalist ceramic vase for fresh or dried flowers. (Demo)',
      categoryName: 'Home and Decoration',
      price: 139,
      costPrice: 60,
      sku: 'DEMO-HOM-01',
      stockQty: 28,
      mainImage: 'assets/images/products/ceramic_vase.png',
      extraImages: ['assets/images/products/ceramic_vase_2.png'],
    ),
    DemoProductDef(
      id: 'demo-prod-10',
      name: 'Warm Table Lamp',
      description: 'Soft-glow table lamp with a fabric shade. (Demo)',
      categoryName: 'Home and Decoration',
      price: 279,
      costPrice: 140,
      sku: 'DEMO-HOM-02',
      stockQty: 18,
      mainImage: 'assets/images/products/table_lamp.png',
    ),
    // Beauty and Personal Care
    DemoProductDef(
      id: 'demo-prod-11',
      name: 'Natural Soap Set',
      description: 'Set of three cold-process natural soaps. (Demo)',
      categoryName: 'Beauty and Personal Care',
      price: 89,
      costPrice: 35,
      sku: 'DEMO-BEA-01',
      stockQty: 80,
      mainImage: 'assets/images/products/natural_soap.png',
    ),
    DemoProductDef(
      id: 'demo-prod-12',
      name: 'Face Care Kit',
      description: 'Gentle cleanser, toner and moisturiser set. (Demo)',
      categoryName: 'Beauty and Personal Care',
      price: 249,
      costPrice: 120,
      sku: 'DEMO-BEA-02',
      stockQty: 40,
      mainImage: 'assets/images/products/face_care_kit.png',
      extraImages: ['assets/images/products/face_care_kit_2.png'],
    ),
  ];

  static const List<({String asset, String titleKey})> banners = [
    (asset: 'assets/images/banners/banner_new_arrivals.png', titleKey: 'newArrivals'),
    (asset: 'assets/images/banners/banner_local_delivery.png', titleKey: 'localDelivery'),
    (asset: 'assets/images/banners/banner_store_pickup.png', titleKey: 'storePickup'),
  ];

  static const String promoAsset = 'assets/images/banners/promo_spotlight.png';
}
