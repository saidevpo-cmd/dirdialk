// Generates original, locally bundled demo imagery for diali.
//
// Run once from the project root:
//   dart run tool/generate_demo_assets.dart
//
// The script is deterministic and safe to re-run: it only writes files inside
// assets/images/{products,categories,banners}. No text is baked into the
// images, so every asset stays language-neutral.
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final productsDir = Directory('assets/images/products')..createSync(recursive: true);
  final categoriesDir = Directory('assets/images/categories')..createSync(recursive: true);
  final bannersDir = Directory('assets/images/banners')..createSync(recursive: true);

  final products = <String, List<int>>{
    'classic_shirt': [0x39, 0x4B, 0xA8, 0x8E, 0x9C, 0xF5],
    'slim_jeans': [0x1F, 0x3A, 0x5F, 0x64, 0x8C, 0xC4],
    'running_sneakers': [0xE8, 0x6A, 0x17, 0xFF, 0xC1, 0x7A],
    'leather_boots': [0x6D, 0x4C, 0x41, 0xC6, 0x9A, 0x7B],
    'wireless_earbuds': [0x21, 0x54, 0x7A, 0x7E, 0xC8, 0xE8],
    'smart_watch': [0x11, 0x1E, 0x36, 0x53, 0x86, 0xB5],
    'leather_wallet': [0x4E, 0x34, 0x2E, 0xB0, 0x7D, 0x57],
    'sunglasses': [0x2B, 0x2B, 0x2B, 0x8D, 0x9A, 0xA6],
    'ceramic_vase': [0x8D, 0x6E, 0x63, 0xE7, 0xD3, 0xC1],
    'table_lamp': [0x7A, 0x5C, 0x2E, 0xF2, 0xD1, 0x8E],
    'natural_soap': [0x8B, 0xC3, 0x4A, 0xE6, 0xF0, 0xC9],
    'face_care_kit': [0xC2, 0x5E, 0x86, 0xFF, 0xC2, 0xDA],
  };

  final categories = <String, List<int>>{
    'clothing': [0x39, 0x4B, 0xA8, 0x8E, 0x9C, 0xF5],
    'shoes': [0xE8, 0x6A, 0x17, 0xFF, 0xC1, 0x7A],
    'electronics': [0x21, 0x54, 0x7A, 0x7E, 0xC8, 0xE8],
    'accessories': [0x0F, 0x76, 0x6E, 0x89, 0xE0, 0xC7],
    'home_decor': [0x8D, 0x6E, 0x63, 0xE7, 0xD3, 0xC1],
    'beauty': [0xC2, 0x5E, 0x86, 0xFF, 0xC2, 0xDA],
  };

  products.forEach((name, colors) {
    final main = _gradient(800, 1000, colors, seed: name.hashCode);
    File('${productsDir.path}/$name.png').writeAsBytesSync(img.encodePng(main));
    // A second gallery image for a subset keeps the size of the bundle sane.
    if (name.hashCode.isEven) {
      final second = _gradient(800, 1000, colors.reversed.toList(), seed: name.hashCode + 7);
      File('${productsDir.path}/${name}_2.png').writeAsBytesSync(img.encodePng(second));
    }
  });

  categories.forEach((name, colors) {
    final image = _gradient(600, 600, colors, seed: name.hashCode);
    File('${categoriesDir.path}/$name.png').writeAsBytesSync(img.encodePng(image));
  });

  final banners = <String, List<int>>{
    'banner_new_arrivals': [0x1B, 0x2A, 0x4A, 0x6C, 0x9A, 0xD8],
    'banner_local_delivery': [0x0E, 0x5C, 0x54, 0x6F, 0xD6, 0xA8],
    'banner_store_pickup': [0x7A, 0x3F, 0x11, 0xF0, 0xB4, 0x6A],
  };
  banners.forEach((name, colors) {
    final image = _gradient(1600, 600, colors, seed: name.hashCode);
    File('${bannersDir.path}/$name.png').writeAsBytesSync(img.encodePng(image));
  });

  final promo = _gradient(1200, 500, [0x2B, 0x1F, 0x4A, 0xA9, 0x8C, 0xE0], seed: 42);
  File('${bannersDir.path}/promo_spotlight.png').writeAsBytesSync(img.encodePng(promo));

  stdout.writeln('Generated ${products.length} products, ${categories.length} '
      'categories and ${banners.length + 1} banners.');
}

img.Image _gradient(int width, int height, List<int> colors, {required int seed}) {
  final image = img.Image(width: width, height: height);
  final c1 = _rgb(colors[0], colors[1], colors[2]);
  final c2 = _rgb(colors[3], colors[4], colors[5]);
  final random = math.Random(seed);

  // Diagonal soft gradient background.
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final t = ((x / width) + (y / height)) / 2;
      final r = (c1.$1 + (c2.$1 - c1.$1) * t).round();
      final g = (c1.$2 + (c2.$2 - c1.$2) * t).round();
      final b = (c1.$3 + (c2.$3 - c1.$3) * t).round();
      image.setPixelRgb(x, y, r, g, b);
    }
  }

  // Decorative translucent circles to give the assets a product-photo feel.
  for (var i = 0; i < 7; i++) {
    final radius = (math.min(width, height) * (0.08 + random.nextDouble() * 0.22)).round();
    final cx = random.nextInt(width);
    final cy = random.nextInt(height);
    final white = random.nextBool();
    final r = white ? 255 : c1.$1;
    final g = white ? 255 : c1.$2;
    final b = white ? 255 : c1.$3;
    _blendCircle(image, cx, cy, radius, r, g, b, white ? 0.10 : 0.16);
  }

  // Subtle vignette.
  final maxDist = math.sqrt(width * width + height * height) / 2;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final dx = x - width / 2;
      final dy = y - height / 2;
      final dist = math.sqrt(dx * dx + dy * dy);
      final shade = (1 - (dist / maxDist) * 0.35).clamp(0.0, 1.0);
      final pixel = image.getPixel(x, y);
      image.setPixelRgb(
        x,
        y,
        (pixel.r * shade).round(),
        (pixel.g * shade).round(),
        (pixel.b * shade).round(),
      );
    }
  }
  return image;
}

void _blendCircle(img.Image image, int cx, int cy, int radius, int r, int g, int b, double alpha) {
  for (var y = cy - radius; y <= cy + radius; y++) {
    for (var x = cx - radius; x <= cx + radius; x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy > radius * radius) continue;
      final pixel = image.getPixel(x, y);
      image.setPixelRgb(
        x,
        y,
        (pixel.r * (1 - alpha) + r * alpha).round(),
        (pixel.g * (1 - alpha) + g * alpha).round(),
        (pixel.b * (1 - alpha) + b * alpha).round(),
      );
    }
  }
}

(int, int, int) _rgb(int r, int g, int b) => (r, g, b);
