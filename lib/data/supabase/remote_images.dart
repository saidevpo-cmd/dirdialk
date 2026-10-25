import '../../core/images/image_store.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';

/// Uploads a single local image reference and returns its public URL.
typedef LocalImageUploader = Future<String> Function(
  String localRef,
  String bucket,
  String folder,
);

/// Replaces every `localimg://` product image with a public Storage URL.
///
/// Remote/asset references are preserved, duplicate local references are
/// uploaded once, and the first resolved image becomes the primary image.
Future<Product> uploadProductImages(
  Product product,
  LocalImageUploader upload,
) async {
  if (!product.images.any(ImageRef.isLocal)) return product;

  final resolved = <String>[];
  final cache = <String, String>{};

  for (final ref in product.images) {
    if (!ImageRef.isLocal(ref)) {
      resolved.add(ref);
      continue;
    }
    final cached = cache[ref];
    if (cached != null) {
      resolved.add(cached);
      continue;
    }
    final url = await upload(ref, 'products', 'products/${product.id}');
    cache[ref] = url;
    resolved.add(url);
  }

  return product.copyWith(
    imageUrl: resolved.first,
    extraImages: resolved.skip(1).toList(),
  );
}

/// Replaces a local category image with a public Storage URL.
Future<Category> uploadCategoryImage(
  Category category,
  LocalImageUploader upload,
) async {
  final ref = category.imageUrl;
  if (!ImageRef.isLocal(ref)) return category;

  final url = await upload(ref!, 'products', 'categories/${category.id}');
  return category.copyWith(imageUrl: url);
}
