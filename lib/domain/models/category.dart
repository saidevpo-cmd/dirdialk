class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.parentId,
    this.position = 0,
    this.imageUrl,
    this.isDemo = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? parentId;
  final int position;

  /// Category image reference. Asset path, remote URL, or a `localimg://<id>`
  /// reference resolved by the local image store.
  final String? imageUrl;

  /// Marks records inserted by the optional demo-data seeder.
  final bool isDemo;

  final DateTime createdAt;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? parentId,
    int? position,
    String? imageUrl,
    bool? isDemo,
    DateTime? createdAt,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        description: description ?? this.description,
        parentId: parentId ?? this.parentId,
        position: position ?? this.position,
        imageUrl: imageUrl ?? this.imageUrl,
        isDemo: isDemo ?? this.isDemo,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'parentId': parentId,
        'position': position,
        'imageUrl': imageUrl,
        'isDemo': isDemo,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        slug: map['slug'] as String? ?? '',
        description: map['description'] as String?,
        parentId: map['parentId'] as String?,
        position: map['position'] is num ? (map['position'] as num).toInt() : 0,
        imageUrl: (map['imageUrl'] as String?)?.isEmpty == true
            ? null
            : map['imageUrl'] as String?,
        isDemo: map['isDemo'] as bool? ?? false,
        createdAt: DateTime.tryParse('${map['createdAt']}') ?? DateTime.now(),
      );
}
