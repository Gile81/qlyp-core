import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/pricing/moving_tier_recommendation.dart';

void main() {
  const config = MovingTierRecommendationConfig(
    noElevatorFloorThreshold: 3,
    crewToServiceId: MovingTierCrewServiceMap(
      crew1: 'svc-bloc',
      crew2: 'svc-tera',
      crew2HeavyOrHighFloor: 'svc-max',
      crew3Plus: 'svc-cargo',
    ),
  );

  MovingWizardRecommendationInputs inputs({
    int movers = 2,
    String dep = 'ground',
    String arr = 'ground',
    bool elevDep = false,
    bool elevArr = false,
    bool heavy = false,
  }) {
    return MovingWizardRecommendationInputs(
      moversCount: movers,
      floorDeparture: dep,
      floorArrival: arr,
      elevatorDeparture: elevDep,
      elevatorArrival: elevArr,
      heavyItems: heavy,
    );
  }

  test('1 mover → crew_1', () {
    expect(
      resolveMovingTierRecommendedServiceId(
        config: config,
        inputs: inputs(movers: 1),
      ),
      'svc-bloc',
    );
  });

  test('2 movers plain → crew_2', () {
    expect(
      resolveMovingTierRecommendedServiceId(
        config: config,
        inputs: inputs(movers: 2),
      ),
      'svc-tera',
    );
  });

  test('2 movers heavy → crew_2_heavy_or_high_floor', () {
    expect(
      resolveMovingTierRecommendedServiceId(
        config: config,
        inputs: inputs(movers: 2, heavy: true),
      ),
      'svc-max',
    );
  });

  test('2 movers floor 3 without elevator → Max', () {
    expect(
      resolveMovingTierRecommendedServiceId(
        config: config,
        inputs: inputs(movers: 2, dep: '3'),
      ),
      'svc-max',
    );
  });

  test('elevator on high floor side skips high-floor rule', () {
    expect(
      resolveMovingTierRecommendedServiceId(
        config: config,
        inputs: inputs(movers: 2, dep: '3', elevDep: true),
      ),
      'svc-tera',
    );
  });

  test('3+ movers → crew_3_plus', () {
    expect(
      resolveMovingTierRecommendedServiceId(
        config: config,
        inputs: inputs(movers: 4),
      ),
      'svc-cargo',
    );
  });

  test('parseMovingTierRecommendationFromZone reads snake_case map', () {
    final parsed = parseMovingTierRecommendationFromZone({
      'moving_tier_recommendation': {
        'no_elevator_floor_threshold': 4,
        'crew_to_service_id': {
          'crew_1': 'a',
          'crew_2': 'b',
          'crew_2_heavy_or_high_floor': 'c',
          'crew_3_plus': 'd',
        },
      },
    });
    expect(parsed.noElevatorFloorThreshold, 4);
    expect(parsed.crewToServiceId.crew1, 'a');
    expect(parsed.crewToServiceId.crew3Plus, 'd');
  });

  test('missing service id in map yields null recommendation', () {
    const partial = MovingTierRecommendationConfig(
      noElevatorFloorThreshold: 3,
      crewToServiceId: MovingTierCrewServiceMap(
        crew1: '',
        crew2: 'svc-tera',
        crew2HeavyOrHighFloor: '',
        crew3Plus: '',
      ),
    );
    expect(
      resolveMovingTierRecommendedServiceId(
        config: partial,
        inputs: inputs(movers: 1),
      ),
      isNull,
    );
  });
}
