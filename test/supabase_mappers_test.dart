import 'package:diali/data/supabase/supabase_mappers.dart';
import 'package:diali/domain/models/customer.dart';
import 'package:diali/domain/models/order.dart';
import 'package:diali/domain/models/product.dart';
import 'package:diali/domain/models/product_tracking.dart';
import 'package:diali/domain/models/resource.dart';
import 'package:diali/domain/models/site_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Db.product', () {
    final product = Product(
      id: 'p1',
      name: 'Desk',
      description: 'A desk',
      sku: 'SKU-1',
      categoryId: 'c1',
      locationId: 'l1',
      trackingStatus: TrackingStatus.shipped,
      trackingCode: 'TRK-9',
      price: 199.5,
      costPrice: 120.25,
      stockQty: 4,
      lowStockThreshold: 2,
      unit: 'pcs',
      imageUrl: 'https://cdn/x.png',
      extraImages: const ['https://cdn/y.png'],
      isDemo: true,
      status: ProductStatus.active,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 2, 1),
    );

    test('serialises to snake_case DB columns', () {
      final row = Db.product(product);
      expect(row['category_id'], 'c1');
      expect(row['location_id'], 'l1');
      expect(row['tracking_status'], 'shipped');
      expect(row['tracking_code'], 'TRK-9');
      expect(row['cost_price'], 120.25);
      expect(row['stock_qty'], 4);
      expect(row['low_stock_threshold'], 2);
      expect(row['extra_images'], ['https://cdn/y.png']);
      expect(row['is_demo'], true);
      expect(row['status'], 'active');
    });

    test('parses rows including joined category/location names', () {
      final parsed = Db.productFrom({
        'id': 'p1',
        'name': 'Desk',
        'sku': 'SKU-1',
        'category_id': 'c1',
        'category': {'name': 'Furniture'},
        'location_id': 'l1',
        'location': [{'name': 'Main Warehouse'}],
        'tracking_status': 'shipped',
        'price': '199.50',
        'cost_price': '120.25',
        'stock_qty': 4,
        'extra_images': ['a.png', 'b.png'],
        'status': 'active',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-02-01T00:00:00.000Z',
      });

      expect(parsed.id, 'p1');
      expect(parsed.categoryName, 'Furniture');
      expect(parsed.locationName, 'Main Warehouse');
      expect(parsed.trackingStatus, TrackingStatus.shipped);
      expect(parsed.price, 199.5);
      expect(parsed.costPrice, 120.25);
      expect(parsed.stockQty, 4);
      expect(parsed.extraImages, ['a.png', 'b.png']);
      expect(parsed.createdAt.isAfter(DateTime.utc(2025, 12, 31)), isTrue);
    });

    test('defaults unknown enum values safely', () {
      final parsed = Db.productFrom({'id': 'p1', 'name': 'x'});
      expect(parsed.trackingStatus, TrackingStatus.inStock);
      expect(parsed.status, ProductStatus.active);
      expect(parsed.unit, 'unit');
      expect(parsed.lowStockThreshold, 5);
    });
  });

  group('Db.order', () {
    test('parses nested order_items and customer relation', () {
      final order = Db.orderFrom({
        'id': 'o1',
        'order_number': 'ORD-1',
        'status': 'paid',
        'subtotal': '10.00',
        'tax': '1.00',
        'total': '11.00',
        'customer': {'name': 'Layla'},
        'order_items': [
          {
            'id': 'i1',
            'order_id': 'o1',
            'product_name': 'Desk',
            'unit_price': '10.00',
            'qty': 1,
            'subtotal': '10.00',
          },
        ],
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(order.status, OrderStatus.paid);
      expect(order.customerName, 'Layla');
      expect(order.total, 11.0);
      expect(order.items, hasLength(1));
      expect(order.items.single.productName, 'Desk');
      expect(order.items.single.qty, 1);
    });

    test('tolerates a missing order_items relation', () {
      final order = Db.orderFrom({
        'id': 'o1',
        'order_number': 'ORD-1',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(order.items, isEmpty);
      expect(order.status, OrderStatus.pending);
    });
  });

  group('other mappers', () {
    test('category maps parent and position', () {
      final c = Db.categoryFrom({
        'id': 'c1',
        'name': 'Furniture',
        'slug': 'furniture',
        'parent_id': 'c0',
        'position': 3,
        'image_url': 'x.png',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(c.parentId, 'c0');
      expect(c.position, 3);
      expect(c.imageUrl, 'x.png');
      expect(Db.category(c)['parent_id'], 'c0');
    });

    test('customer parses totals and tier', () {
      final c = Db.customerFrom({
        'id': 'cu1',
        'name': 'Layla',
        'email': 'l@example.com',
        'tier': 'vip',
        'total_orders': 7,
        'total_spent': '420.50',
      });
      expect(c.tier, CustomerTier.vip);
      expect(c.totalOrders, 7);
      expect(c.totalSpent, 420.5);
    });

    test('resource maps storage metadata', () {
      final r = Db.resourceFrom({
        'id': 'r1',
        'name': 'Invoice',
        'type': 'spreadsheet',
        'storage_size': 2048,
        'mime_type': 'text/csv',
        'is_published': true,
      });
      expect(r.type, ResourceType.spreadsheet);
      expect(r.storageSize, 2048);
      expect(r.mimeType, 'text/csv');
      expect(r.isPublished, isTrue);
    });

    test('tracking event maps status and timestamp', () {
      final e = Db.trackingEventFrom({
        'id': 'e1',
        'product_id': 'p1',
        'status': 'delivered',
        'reference_number': 'TRK-1',
        'occurred_at': '2026-03-01T10:00:00.000Z',
      });
      expect(e.status, TrackingStatus.delivered);
      expect(e.referenceNumber, 'TRK-1');
      expect(e.timestamp.isAfter(DateTime.utc(2026, 2, 28)), isTrue);
    });

    test('site settings round trip keeps customisation', () {
      const settings = SiteSettings(activeTemplateId: 't1');
      final row = Db.siteSettings(settings);
      expect(row['active_template_id'], 't1');
      final parsed = Db.siteSettingsFrom(row);
      expect(parsed.activeTemplateId, 't1');
      expect(parsed.customization.brandName, isNotEmpty);
    });
  });
}
