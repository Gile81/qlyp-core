import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/pricing/wizard_surcharges.dart';

double _defaults(String key, double fallback) => fallback;

void main() {
  group('demenagement floor surcharges', () {
    test('ground departure costs 0', () {
      final r = computeWizardSurcharges(
        wizardKind: 'demenagement',
        zoneNum: _defaults,
        crewCount: 2,
        floorDeparture: 'ground',
        floorArrival: 'ground',
      );
      expect(r.delta, 35); // one extra mover only
      expect(
        r.lines.any((l) => l.key == 'moving_floor_departure'),
        isFalse,
      );
    });

    test('departure elevator skips floor surcharge on that side', () {
      final r = computeWizardSurcharges(
        wizardKind: 'demenagement',
        zoneNum: _defaults,
        crewCount: 1,
        floorDeparture: '2',
        floorArrival: '1',
        elevatorDeparture: true,
      );
      expect(r.lines.any((l) => l.key == 'moving_floor_departure'), isFalse);
      expect(r.lines.any((l) => l.key == 'moving_floor_arrival'), isTrue);
      expect(r.delta, 10);
    });

    test('both elevators skip floor surcharges', () {
      final r = computeWizardSurcharges(
        wizardKind: 'demenagement',
        zoneNum: _defaults,
        crewCount: 1,
        floorDeparture: '3',
        floorArrival: '4plus',
        elevatorDeparture: true,
        elevatorArrival: true,
      );
      expect(r.delta, 0);
    });
  });

  group('logistique_group', () {
    test('weight tiers without extra movers line', () {
      final r = computeWizardSurcharges(
        wizardKind: 'logistique_group',
        zoneNum: _defaults,
        crewCount: 2,
        logisticsWeightKg: 120,
      );
      expect(r.lines.any((l) => l.key == 'moving_extra_movers'), isFalse);
      expect(r.lines.any((l) => l.key == 'logistics_weight'), isTrue);
      expect(r.delta, 15); // 3 tiers × 5
    });
  });
}
