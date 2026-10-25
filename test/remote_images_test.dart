import 'package:diali/data/supabase/remote_images.dart';
import 'package:diali/domain/models/category.dart';
import 'package:diali/domain/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product product({String? imageUrl, List<String> extraImages = const []}) =>
    Product(
      id: 'p-1',
      name: 'Widget',
      price: 10,
      stockQty: 1,
      imageUrl: imageUrl,
      extraImages: extraImages,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  group('uploadProductImages', () {
    test(
      'uploads local refs, deduplicates, and preserves remote URLs',
      () async {
        final calls = <String>[];
        Future<String> upload(String ref, String bucket, String folder) async {
          calls.add('$bucket|$folder|$ref');
          return 'https://cdn.example.com/${ref.substring(11)}.jpg';
        }

        final result = await uploadProductImages(
          product(
            imageUrl: 'localimg://main',
            extraImages: [
              'localimg://main',
              'https://cdn.example.com/keep.jpg',
            ],
          ),
          upload,
        );

        expect(calls, ['products|products/p-1|localimg://main']);
        expect(result.imageUrl, 'https://cdn.example.com/main.jpg');
        expect(result.extraImages, [
          'https://cdn.example.com/main.jpg',
          'https://cdn.example.com/keep.jpg',
        ]);
      },
    );

    test('does not call Storage when there are no local refs', () async {
      var called = false;
      final result = await uploadProductImages(
        product(
          imageUrl: 'https://cdn.example.com/main.jpg',
          extraImages: const [],
        ),
        (ref, bucket, folder) async {
          called = true;
          return ref;
        },
      );

      expect(called, isFalse);
      expect(result.imageUrl, 'https://cdn.example.com/main.jpg');
    });
  });

  group('uploadCategoryImage', () {
    test('uploads a local category image', () async {
      final calls = <String>[];
      final result = await uploadCategoryImage(
        Category(
          id: 'c-1',
          name: 'Tools',
          slug: 'tools',
          imageUrl: 'localimg://cat',
          createdAt: DateTime(2026),
        ),
        (ref, bucket, folder) async {
          calls.add('$bucket|$folder|$ref');
          return 'https://cdn.example.com/tools.jpg';
        },
      );

      expect(calls, ['products|categories/c-1|localimg://cat']);
      expect(result.imageUrl, 'https://cdn.example.com/tools.jpg');
    });

    test('keeps an already-remote category image', () async {
      final category = Category(
        id: 'c-1',
        name: 'Tools',
        slug: 'tools',
        imageUrl: 'https://cdn.example.com/tools.jpg',
        createdAt: DateTime(2026),
      );

      final result = await uploadCategoryImage(
        category,
        (ref, bucket, folder) async => fail('should not upload'),
      );

      expect(identical(result, category), isTrue);
    });
  });
}
