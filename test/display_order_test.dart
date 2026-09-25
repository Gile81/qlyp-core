import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/catalog/display_order.dart';
import 'package:qlyp_core/catalog/official_service_order.dart';

void main() {
  test('compareByDisplayOrder sorts ascending then label', () {
    expect(
      compareByDisplayOrder(
        orderA: 10,
        orderB: 20,
        labelA: 'B',
        labelB: 'A',
      ),
      lessThan(0),
    );
    expect(
      compareByDisplayOrder(
        orderA: 10,
        orderB: 10,
        labelA: 'Beta',
        labelB: 'Alpha',
      ),
      greaterThan(0),
    );
  });

  test('official courses tier order', () {
    final keys = [
      'luxe',
      'core',
      'volt',
      'mega',
      'relax',
      'relax_e',
      'squad_5',
      'squad_6',
    ];
    keys.sort((a, b) {
      final oa = OfficialServiceOrder.sequenceForTierKey(a)!;
      final ob = OfficialServiceOrder.sequenceForTierKey(b)!;
      return compareByDisplayOrder(
        orderA: oa,
        orderB: ob,
        labelA: a,
        labelB: b,
      );
    });
    expect(
      keys,
      ['core', 'volt', 'relax', 'relax_e', 'squad_5', 'squad_6', 'mega', 'luxe'],
    );
  });

  test('missing sequence sorts last', () {
    expect(
      compareByDisplayOrder(
        orderA: OfficialServiceOrder.missingOrderSentinel,
        orderB: 10,
        labelA: 'A',
        labelB: 'B',
      ),
      greaterThan(0),
    );
  });

  test('demenagement filter order', () {
    final ordered = OfficialServiceOrder.tierSequenceByKey.keys
        .where((k) => OfficialServiceOrder.demenagementTierKeys.contains(k))
        .toList()
      ..sort((a, b) => OfficialServiceOrder.sequenceForTierKey(a)!
          .compareTo(OfficialServiceOrder.sequenceForTierKey(b)!));
    expect(ordered, ['bloc', 'max', 'tera', 'cargo']);
  });

  test('normalize maps legacy keys', () {
    expect(normalizeServiceKey('unlocker'), 'dbloc');
    expect(normalizeServiceKey('boost'), 'boost_light');
  });
}
