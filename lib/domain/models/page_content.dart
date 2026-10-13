enum PageStatus { draft, published }

class PageContent {
  const PageContent({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.status = PageStatus.draft,
    this.metaTitle,
    this.metaDesc,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String? imageUrl;
  final String? categoryId;
  final String? categoryName;
  final PageStatus status;
  final String? metaTitle;
  final String? metaDesc;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPublished => status == PageStatus.published;

  PageContent copyWith({
    String? id,
    String? title,
    String? slug,
    String? excerpt,
    String? content,
    String? imageUrl,
    String? categoryId,
    String? categoryName,
    PageStatus? status,
    String? metaTitle,
    String? metaDesc,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      PageContent(
        id: id ?? this.id,
        title: title ?? this.title,
        slug: slug ?? this.slug,
        excerpt: excerpt ?? this.excerpt,
        content: content ?? this.content,
        imageUrl: imageUrl ?? this.imageUrl,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        status: status ?? this.status,
        metaTitle: metaTitle ?? this.metaTitle,
        metaDesc: metaDesc ?? this.metaDesc,
        publishedAt: publishedAt ?? this.publishedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
