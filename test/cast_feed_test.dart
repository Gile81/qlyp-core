import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/cast_item.dart';
import 'package:qlyp_core/utils/cast_feed.dart';

CastItem _item({
  required String id,
  String topic = '',
  bool isOffer = false,
  int position = 0,
  DateTime? createdAt,
  List<String> zoneIds = const [],
  String category = 'customer',
  bool enable = true,
  bool isDeleted = false,
}) {
  return CastItem(
    id: id,
    title: id,
    description: '',
    type: 'image',
    mediaUrl: '',
    thumbnail: '',
    externalLink: '',
    offerCode: '',
    couponId: '',
    isOffer: isOffer,
    enable: enable,
    isDeleted: isDeleted,
    createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    category: category,
    position: position,
    zoneIds: zoneIds,
    topic: topic,
  );
}

void main() {
  group('castTabs', () {
    test('hides empty topics and keeps order offers, events, tourism, training, news',
        () {
      final items = [
        _item(id: 'a', topic: 'news'),
        _item(id: 'b', topic: 'events'),
        _item(id: 'c', isOffer: true),
      ];

      expect(
        castTabs(items),
        [
          castTabKeyAll,
          castTabKeyOffers,
          castTabKeyEvents,
          castTabKeyNews,
        ],
      );
    });

    test('item without topic only contributes to all tab', () {
      final items = [_item(id: 'legacy')];
      expect(castTabs(items), [castTabKeyAll]);
      expect(castItemMatchesTab(items.first, castTabKeyOffers), isFalse);
      expect(castItemMatchesTab(items.first, castTabKeyAll), isTrue);
    });

    test('offers tab includes isOffer without topic', () {
      final item = _item(id: 'o', isOffer: true);
      expect(castItemMatchesTab(item, castTabKeyOffers), isTrue);
      expect(castTabs([item]), [castTabKeyAll, castTabKeyOffers]);
    });
  });

  group('compareCastItems', () {
    test('sorts by ascending position then newer createdAt', () {
      final a = _item(
        id: 'a',
        position: 1,
        createdAt: DateTime(2026, 1, 1),
      );
      final b = _item(
        id: 'b',
        position: 2,
        createdAt: DateTime(2026, 6, 1),
      );
      final c = _item(
        id: 'c',
        position: 1,
        createdAt: DateTime(2026, 3, 1),
      );

      final sorted = [b, c, a]..sort(compareCastItems);
      expect(sorted.map((e) => e.id).toList(), ['c', 'a', 'b']);
    });
  });

  group('filterCastItems zone', () {
    test('all zones visible when zone_ids empty', () {
      final items = filterCastItems(
        items: [_item(id: 'x', zoneIds: [])],
        audience: CastAudience.customer,
        userZoneIds: [],
      );
      expect(items, hasLength(1));
    });

    test('matching zone visible', () {
      final items = filterCastItems(
        items: [_item(id: 'x', zoneIds: ['zone-mtl'])],
        audience: CastAudience.customer,
        userZoneIds: ['zone-mtl'],
      );
      expect(items, hasLength(1));
    });

    test('unknown zone hides restricted casts', () {
      final items = filterCastItems(
        items: [_item(id: 'x', zoneIds: ['zone-mtl'])],
        audience: CastAudience.customer,
        userZoneIds: [],
      );
      expect(items, isEmpty);
    });
  });

  group('castMatchesAudience', () {
    test('customer sees customer and both', () {
      expect(castMatchesAudience('customer', CastAudience.customer), isTrue);
      expect(castMatchesAudience('both', CastAudience.customer), isTrue);
      expect(castMatchesAudience('driver', CastAudience.customer), isFalse);
    });
  });
}
