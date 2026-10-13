enum ResourceType { document, spreadsheet, image, folder, other }

class Resource {
  const Resource({
    required this.id,
    required this.name,
    this.description,
    this.type = ResourceType.document,
    this.category,
    this.url,
    this.contact,
    this.location,
    this.imageUrl,
    this.isPublished = false,
    this.storagePath,
    this.storageSize,
    this.mimeType,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final ResourceType type;
  final String? category;
  final String? url;
  final String? contact;
  final String? location;
  final String? imageUrl;
  final bool isPublished;
  final String? storagePath;
  final int? storageSize;
  final String? mimeType;
  final String? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasLink => url != null && url!.trim().isNotEmpty;

  String get sizeLabel {
    if (storageSize == null) return '—';
    final kb = storageSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Resource copyWith({
    String? id,
    String? name,
    String? description,
    ResourceType? type,
    String? category,
    String? url,
    String? contact,
    String? location,
    String? imageUrl,
    bool? isPublished,
    String? storagePath,
    int? storageSize,
    String? mimeType,
    String? folderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Resource(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        type: type ?? this.type,
        category: category ?? this.category,
        url: url ?? this.url,
        contact: contact ?? this.contact,
        location: location ?? this.location,
        imageUrl: imageUrl ?? this.imageUrl,
        isPublished: isPublished ?? this.isPublished,
        storagePath: storagePath ?? this.storagePath,
        storageSize: storageSize ?? this.storageSize,
        mimeType: mimeType ?? this.mimeType,
        folderId: folderId ?? this.folderId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
