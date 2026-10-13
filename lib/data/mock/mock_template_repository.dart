import '../../domain/models/app_error.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/template.dart';
import '../../domain/repositories/template_repository.dart';

class MockTemplateRepository implements TemplateRepository {
  MockTemplateRepository({List<Template>? initialData})
      : _templates =
            initialData != null ? List<Template>.from(initialData) : _seed();

  final List<Template> _templates;

  static List<Template> _seed() {
    final now = DateTime.now();
    return [
      Template(
        id: 'tpl_aurora',
        name: 'Aurora Store',
        slug: 'aurora-store',
        description:
            'A bright, conversion-focused storefront with a hero banner and featured products.',
        category: TemplateCategory.store,
        tags: const ['store', 'hero', 'featured'],
        isFeatured: true,
        customization: const TemplateCustomization(
          brandName: 'Diali',
          tagline: 'Quality you can trust',
          heroTitle: 'Everything your business needs',
          heroSubtitle: 'Browse our latest products and offers',
          heroButtonText: 'Shop now',
          primaryColorHex: '3949AB',
          accentColorHex: '0F9D8A',
        ),
        createdAt: now,
        updatedAt: now,
      ),
      Template(
        id: 'tpl_meridian',
        name: 'Meridian Corporate',
        slug: 'meridian-corporate',
        description:
            'A formal corporate layout emphasising services, articles and contact.',
        category: TemplateCategory.company,
        tags: const ['company', 'articles', 'formal'],
        isFeatured: true,
        customization: const TemplateCustomization(
          brandName: 'Diali',
          tagline: 'Trusted by businesses',
          heroTitle: 'Reliable solutions for modern businesses',
          heroSubtitle: 'Discover our services and expertise',
          heroButtonText: 'Get in touch',
          primaryColorHex: '0F172A',
          accentColorHex: '3949AB',
          showFeaturedProducts: false,
        ),
        createdAt: now,
        updatedAt: now,
      ),
      Template(
        id: 'tpl_minimal',
        name: 'Minimal Slate',
        slug: 'minimal-slate',
        description: 'A clean, minimal portfolio-style template with strong typography.',
        category: TemplateCategory.minimal,
        tags: const ['minimal', 'clean', 'portfolio'],
        customization: const TemplateCustomization(
          brandName: 'Diali',
          tagline: 'Less, but better',
          heroTitle: 'Simple. Clear. Effective.',
          heroSubtitle: 'A focused presentation of our work',
          heroButtonText: 'Explore',
          primaryColorHex: '111827',
          accentColorHex: 'F4B740',
          showArticles: false,
          showContact: false,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<Result<PaginatedResult<Template>>> list({
    String? search,
    bool? featuredOnly,
    int page = 1,
    int limit = 50,
  }) async {
    var items = List<Template>.from(_templates);
    if (featuredOnly == true) {
      items = items.where((t) => t.isFeatured).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      items = items
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q))
          .toList();
    }
    final total = items.length;
    final paged = items.skip((page - 1) * limit).take(limit).toList();
    return Success(
      PaginatedResult(items: paged, total: total, page: page, limit: limit),
    );
  }

  @override
  Future<Result<List<Template>>> all() async =>
      Success(List.unmodifiable(_templates));

  @override
  Future<Result<Template>> getById(String id) async {
    for (final t in _templates) {
      if (t.id == id) return Success(t);
    }
    return const Failure(AppError.notFound);
  }

  @override
  Future<Result<Template>> getBySlug(String slug) async {
    for (final t in _templates) {
      if (t.slug == slug) return Success(t);
    }
    return const Failure(AppError.notFound);
  }

  @override
  Future<Result<Template>> create(Template template) async {
    if (template.name.trim().isEmpty || template.slug.trim().isEmpty) {
      return const Failure(
        AppError(code: 'VALIDATION', message: 'Template name and slug are required'),
      );
    }
    _templates.add(template);
    return Success(template);
  }

  @override
  Future<Result<Template>> update(Template template) async {
    final idx = _templates.indexWhere((t) => t.id == template.id);
    if (idx == -1) return const Failure(AppError.notFound);
    _templates[idx] = template;
    return Success(template);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _templates.removeWhere((t) => t.id == id);
    return const Success(null);
  }
}