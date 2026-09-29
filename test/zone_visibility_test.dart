import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/utils/zone_visibility.dart';

void main() {
  // S4-6g-2 — visibleInZones unit tests.

  group('visibleInZones', () {
    // --- empty zoneIds = all zones --------------------------------------------

    test('empty zoneIds is visible for any user zone (all zones)', () {
      expect(
        visibleInZones([], userZoneIds: ['zone-mtl']),
        isTrue,
      );
    });

    test('empty zoneIds is visible even when user zone is unknown', () {
      expect(
        visibleInZones([], userZoneIds: []),
        isTrue,
      );
    });

    // --- non-empty zoneIds ---------------------------------------------------

    test('visible when user zone is in zoneIds', () {
      expect(
        visibleInZones(['zone-mtl', 'zone-laval'], userZoneIds: ['zone-laval']),
        isTrue,
      );
    });

    test('not visible when user zone is not in zoneIds', () {
      expect(
        visibleInZones(['zone-mtl'], userZoneIds: ['zone-laval']),
        isFalse,
      );
    });

    // --- zone inconnue (restrictive rule) ------------------------------------

    test('not visible when user zone is unknown and zoneIds is non-empty', () {
      expect(
        visibleInZones(['zone-mtl'], userZoneIds: []),
        isFalse,
      );
    });

    // --- multi-zone driver ---------------------------------------------------

    test('visible when driver covers multiple zones and one matches', () {
      expect(
        visibleInZones(
          ['zone-mtl'],
          userZoneIds: ['zone-laval', 'zone-mtl', 'zone-longueuil'],
        ),
        isTrue,
      );
    });

    test('not visible when driver covers multiple zones with no overlap', () {
      expect(
        visibleInZones(
          ['zone-quebec'],
          userZoneIds: ['zone-laval', 'zone-mtl'],
        ),
        isFalse,
      );
    });
  });
}