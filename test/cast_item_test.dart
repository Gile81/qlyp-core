import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/cast_item.dart';

void main() {
  group('CastItem.fromFirestore', () {
    test('reads admin payload fields including topic', () {
      final created = DateTime(2026, 3, 15, 12, 0);
      final item = CastItem.fromFirestore(
        {
          'id': 'cast-1',
          'title': 'Summer promo',
          'description': 'Details',
          'type': 'image',
          'category': 'customer',
          'position': 2,
          'enable': true,
          'isOffer': true,
          'offerCode': 'SAVE10',
          'zone_ids': ['zone-mtl'],
          'mediaUrl': 'https://cdn.example/a.webp',
          'thumbnail': 'https://cdn.example/t.webp',
          'externalLink': 'https://example.com',
          'isDeleted': false,
          'topic': 'offers',
          'createdAt': Timestamp.fromDate(created),
        },
        'doc-1',
      );

      expect(item.id, 'doc-1');
      expect(item.title, 'Summer promo');
      expect(item.description, 'Details');
      expect(item.type, 'image');
      expect(item.category, 'customer');
      expect(item.position, 2);
      expect(item.enable, isTrue);
      expect(item.isOffer, isTrue);
      expect(item.offerCode, 'SAVE10');
      expect(item.zoneIds, ['zone-mtl']);
      expect(item.mediaUrl, 'https://cdn.example/a.webp');
      expect(item.thumbnail, 'https://cdn.example/t.webp');
      expect(item.externalLink, 'https://example.com');
      expect(item.isDeleted, isFalse);
      expect(item.topic, 'offers');
      expect(item.createdAt, created);
    });

    test('topic absent yields empty topic string', () {
      final item = CastItem.fromFirestore(
        {'title': 'Legacy', 'category': 'both'},
        'legacy-1',
      );
      expect(item.topic, isEmpty);
    });

    test('falls back to alternate keys', () {
      final item = CastItem.fromFirestore(
        {
          'name': 'Headline',
          'content': 'Body',
          'imageUrl': 'https://img',
          'link': 'https://link',
          'promoCode': 'X',
        },
        'x',
      );
      expect(item.title, 'Headline');
      expect(item.description, 'Body');
      expect(item.mediaUrl, 'https://img');
      expect(item.externalLink, 'https://link');
      expect(item.offerCode, 'X');
    });

    test('enable defaults true and isDeleted defaults false', () {
      final item = CastItem.fromFirestore({}, 'x');
      expect(item.enable, isTrue);
      expect(item.isDeleted, isFalse);
    });
  });
}
