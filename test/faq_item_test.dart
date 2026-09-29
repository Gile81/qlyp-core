import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/faq_item.dart';

void main() {
  // -------------------------------------------------------------------------
  // FaqItem.fromFirestore — default values for legacy documents
  // -------------------------------------------------------------------------

  group('FaqItem.fromFirestore defaults', () {
    test('missing app_type defaults to customer', () {
      final item = FaqItem.fromFirestore({
        'id': 'x',
        'title': [],
        'description': [],
        'enable': true,
      });
      expect(item.appType, 'customer');
    });

    test('missing category defaults to general', () {
      final item = FaqItem.fromFirestore({
        'id': 'x',
        'title': [],
        'description': [],
        'enable': true,
      });
      expect(item.category, 'general');
    });

    test('missing order defaults to 999 (placed at end)', () {
      final item = FaqItem.fromFirestore({
        'id': 'x',
        'title': [],
        'description': [],
        'enable': true,
      });
      expect(item.order, 999);
    });
  });

  // -------------------------------------------------------------------------
  // FaqItem.fromFirestore — title / description multilang parsing
  // -------------------------------------------------------------------------

  group('FaqItem multilang parsing', () {
    late FaqItem item;

    setUp(() {
      item = FaqItem.fromFirestore({
        'id': 'q1',
        'title': [
          {'type': 'fr', 'title': 'Titre FR'},
          {'type': 'en', 'title': 'Title EN'},
        ],
        'description': [
          {'type': 'fr', 'description': 'Description FR'},
          {'type': 'en', 'description': 'Description EN'},
        ],
        'enable': true,
        'app_type': 'customer',
        'category': 'rides',
        'order': 2,
      });
    });

    test('title(french:true) returns FR title', () {
      expect(item.title(french: true), 'Titre FR');
    });

    test('title(french:false) returns EN title', () {
      expect(item.title(french: false), 'Title EN');
    });

    test('description(french:true) returns FR description', () {
      expect(item.description(french: true), 'Description FR');
    });

    test('description(french:false) returns EN description', () {
      expect(item.description(french: false), 'Description EN');
    });

    test('fields parsed correctly', () {
      expect(item.appType, 'customer');
      expect(item.category, 'rides');
      expect(item.order, 2);
    });
  });

  // -------------------------------------------------------------------------
  // FaqItem.visibleFor — app_type filtering
  // -------------------------------------------------------------------------

  group('FaqItem.visibleFor — app type filtering', () {
    FaqItem makeItem(String appType) => FaqItem.fromFirestore({
          'id': 'i',
          'title': [],
          'description': [],
          'enable': true,
          'app_type': appType,
          'category': 'general',
          'order': 0,
        });

    test('customer item visible for customer', () {
      expect(makeItem('customer').visibleFor('customer'), isTrue);
    });

    test('customer item NOT visible for driver', () {
      expect(makeItem('customer').visibleFor('driver'), isFalse);
    });

    test('driver item visible for driver', () {
      expect(makeItem('driver').visibleFor('driver'), isTrue);
    });

    test('driver item NOT visible for customer', () {
      expect(makeItem('driver').visibleFor('customer'), isFalse);
    });

    test('all item visible for customer', () {
      expect(makeItem('all').visibleFor('customer'), isTrue);
    });

    test('all item visible for driver', () {
      expect(makeItem('all').visibleFor('driver'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // FaqItem.compare — sorting by category then order
  // -------------------------------------------------------------------------

  group('FaqItem.compare — sorting', () {
    FaqItem makeItem(String category, int order) => FaqItem.fromFirestore({
          'id': '$category-$order',
          'title': [],
          'description': [],
          'enable': true,
          'app_type': 'customer',
          'category': category,
          'order': order,
        });

    test('sorts by category index first', () {
      final items = [
        makeItem('payment', 0),  // index 2
        makeItem('general', 0),  // index 0
        makeItem('rides', 0),    // index 1
      ]..sort(FaqItem.compare);

      expect(items.map((e) => e.category).toList(),
          ['general', 'rides', 'payment']);
    });

    test('within same category sorts by order', () {
      final items = [
        makeItem('general', 3),
        makeItem('general', 1),
        makeItem('general', 0),
      ]..sort(FaqItem.compare);

      expect(items.map((e) => e.order).toList(), [0, 1, 3]);
    });

    test('unknown category sorts after known ones', () {
      final items = [
        makeItem('unknown_cat', 0),
        makeItem('general', 5),
        makeItem('documents', 0),
      ]..sort(FaqItem.compare);

      final cats = items.map((e) => e.category).toList();
      expect(cats.first, 'general');
      expect(cats[1], 'documents');
      expect(cats.last, 'unknown_cat');
    });
  });
}