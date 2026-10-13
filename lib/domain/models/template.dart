enum TemplateCategory {
  store,
  services,
  portfolio,
  restaurant,
  company,
  landingPage,
  minimal,
  modern,
}

class TemplateCustomization {
  const TemplateCustomization({
    this.brandName = 'My Business',
    this.tagline = 'Professional solutions tailored for you',
    this.logoUrl,
    this.primaryColorHex = '2563EB',
    this.accentColorHex = '10B981',
    this.fontFamily = 'Inter',
    this.heroTitle = 'Build Your Dream Business With diali',
    this.heroSubtitle = 'Deliver high-quality products and services to your customers worldwide.',
    this.heroButtonText = 'Explore Catalog',
    this.heroImageUrl,
    this.contactEmail = 'contact@example.com',
    this.contactPhone = '+1 234 567 890',
    this.address = '123 Business Avenue, Tech City',
    this.footerText = '© 2026 diali Platform. All rights reserved.',
    this.showHero = true,
    this.showFeaturedProducts = true,
    this.showArticles = true,
    this.showContact = true,
  });

  final String brandName;
  final String tagline;
  final String? logoUrl;
  final String primaryColorHex;
  final String accentColorHex;
  final String fontFamily;
  final String heroTitle;
  final String heroSubtitle;
  final String heroButtonText;
  final String? heroImageUrl;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String footerText;
  final bool showHero;
  final bool showFeaturedProducts;
  final bool showArticles;
  final bool showContact;

  TemplateCustomization copyWith({
    String? brandName,
    String? tagline,
    String? logoUrl,
    String? primaryColorHex,
    String? accentColorHex,
    String? fontFamily,
    String? heroTitle,
    String? heroSubtitle,
    String? heroButtonText,
    String? heroImageUrl,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? footerText,
    bool? showHero,
    bool? showFeaturedProducts,
    bool? showArticles,
    bool? showContact,
  }) =>
      TemplateCustomization(
        brandName: brandName ?? this.brandName,
        tagline: tagline ?? this.tagline,
        logoUrl: logoUrl ?? this.logoUrl,
        primaryColorHex: primaryColorHex ?? this.primaryColorHex,
        accentColorHex: accentColorHex ?? this.accentColorHex,
        fontFamily: fontFamily ?? this.fontFamily,
        heroTitle: heroTitle ?? this.heroTitle,
        heroSubtitle: heroSubtitle ?? this.heroSubtitle,
        heroButtonText: heroButtonText ?? this.heroButtonText,
        heroImageUrl: heroImageUrl ?? this.heroImageUrl,
        contactEmail: contactEmail ?? this.contactEmail,
        contactPhone: contactPhone ?? this.contactPhone,
        address: address ?? this.address,
        footerText: footerText ?? this.footerText,
        showHero: showHero ?? this.showHero,
        showFeaturedProducts:
            showFeaturedProducts ?? this.showFeaturedProducts,
        showArticles: showArticles ?? this.showArticles,
        showContact: showContact ?? this.showContact,
      );
}

class Template {
  const Template({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.category = TemplateCategory.store,
    this.previewImageUrl,
    this.tags = const [],
    this.isPublished = true,
    this.isFeatured = false,
    this.customization = const TemplateCustomization(),
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final TemplateCategory category;
  final String? previewImageUrl;
  final List<String> tags;
  final bool isPublished;
  final bool isFeatured;
  final TemplateCustomization customization;
  final DateTime createdAt;
  final DateTime updatedAt;

  Template copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    TemplateCategory? category,
    String? previewImageUrl,
    List<String>? tags,
    bool? isPublished,
    bool? isFeatured,
    TemplateCustomization? customization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Template(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        description: description ?? this.description,
        category: category ?? this.category,
        previewImageUrl: previewImageUrl ?? this.previewImageUrl,
        tags: tags ?? this.tags,
        isPublished: isPublished ?? this.isPublished,
        isFeatured: isFeatured ?? this.isFeatured,
        customization: customization ?? this.customization,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
