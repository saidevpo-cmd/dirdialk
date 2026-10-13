import 'product_tracking.dart';

enum ProductStatus { active, draft, archived }

class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    this.categoryId,
    this.categoryName,
    this.locationId,
    this.locationName,
    this.trackingStatus = TrackingStatus.inStock,
    this.trackingCode,
    required this.price,
    this.costPrice,
    required this.stockQty,
    this.lowStockThreshold = 5,
    this.unit = 'unit',
    this.imageUrl,
    this.extraImages = const <String>[],
    this.isDemo = false,
    this.status = ProductStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? sku;
  final String? categoryId;
  final String? categoryName;
  final String? locationId;
  final String? locationName;
  final TrackingStatus trackingStatus;
  final String? trackingCode;
  final double price;
  final double? costPrice;
  final int stockQty;
  final int lowStockThreshold;
  final String unit;

  /// Main product image reference. May be an asset path, a remote URL, or a
  /// `localimg://<id>` reference resolved by the local image store.
  final String? imageUrl;

  /// Additional gallery images, displayed after [imageUrl] in the order given.
  final List<String> extraImages;

  /// Marks records inserted by the optional demo-data seeder so they can be
  /// identified and safely re-checked without touching real business data.
  final bool isDemo;

  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stockQty > 0 && stockQty <= lowStockThreshold;
  bool get isOutOfStock => stockQty == 0;
  double? get margin =>
      costPrice != null && costPrice! > 0
          ? ((price - costPrice!) / price) * 100
          : null;

  /// All images for this product, main image first. Empty entries are ignored.
  List<String> get images => [
        if (imageUrl != null && imageUrl!.isNotEmpty) imageUrl!,
        ...extraImages.where((e) => e.isNotEmpty),
      ];

  bool get hasImages => images.isNotEmpty;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? categoryId,
    String? categoryName,
    String? locationId,
    String? locationName,
    TrackingStatus? trackingStatus,
    String? trackingCode,
    double? price,
    double? costPrice,
    int? stockQty,
    int? lowStockThreshold,
    String? unit,
    String? imageUrl,
    List<String>? extraImages,
    bool? isDemo,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        sku: sku ?? this.sku,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        locationId: locationId ?? this.locationId,
        locationName: locationName ?? this.locationName,
        trackingStatus: trackingStatus ?? this.trackingStatus,
        trackingCode: trackingCode ?? this.trackingCode,
        price: price ?? this.price,
        costPrice: costPrice ?? this.costPrice,
        stockQty: stockQty ?? this.stockQty,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        unit: unit ?? this.unit,
        imageUrl: imageUrl ?? this.imageUrl,
        extraImages: extraImages ?? this.extraImages,
        isDemo: isDemo ?? this.isDemo,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'sku': sku,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'locationId': locationId,
        'locationName': locationName,
        'trackingStatus': trackingStatus.name,
        'trackingCode': trackingCode,
        'price': price,
        'costPrice': costPrice,
        'stockQty': stockQty,
        'lowStockThreshold': lowStockThreshold,
        'unit': unit,
        'imageUrl': imageUrl,
        'extraImages': extraImages,
        'isDemo': isDemo,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        description: map['description'] as String?,
        sku: map['sku'] as String?,
        categoryId: map['categoryId'] as String?,
        categoryName: map['categoryName'] as String?,
        locationId: map['locationId'] as String?,
        locationName: map['locationName'] as String?,
        trackingStatus: _trackingStatus(map['trackingStatus'] as String?),
        trackingCode: map['trackingCode'] as String?,
        price: _toDouble(map['price']),
        costPrice: map['costPrice'] == null ? null : _toDouble(map['costPrice']),
        stockQty: _toInt(map['stockQty']),
        lowStockThreshold: _toInt(map['lowStockThreshold'], fallback: 5),
        unit: map['unit'] as String? ?? 'unit',
        imageUrl: _emptyToNull(map['imageUrl'] as String?),
        extraImages: (map['extraImages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList() ??
            const <String>[],
        isDemo: map['isDemo'] as bool? ?? false,
        status: _productStatus(map['status'] as String?),
        createdAt: _toDate(map['createdAt']),
        updatedAt: _toDate(map['updatedAt']),
      );
}

ProductStatus _productStatus(String? value) => ProductStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ProductStatus.active,
    );

TrackingStatus _trackingStatus(String? value) =>
    TrackingStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => TrackingStatus.inStock,
    );

String? _emptyToNull(String? value) =>
    (value == null || value.isEmpty) ? null : value;

double _toDouble(Object? value, {double fallback = 0}) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

int _toInt(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

DateTime _toDate(Object? value) =>
    value is String ? (DateTime.tryParse(value) ?? DateTime.now()) : DateTime.now();
