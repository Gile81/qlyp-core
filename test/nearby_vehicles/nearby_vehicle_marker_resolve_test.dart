import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/nearby_vehicles/nearby_vehicle_marker_resolve.dart';
import 'package:qlyp_core/nearby_vehicles/nearby_vehicle_models.dart';

void main() {
  test('marker service id prefers passenger tier', () {
    expect(
      nearbyVehicleMarkerServiceId(
        passengerSelectedTierId: 'tier_a',
        primaryServiceId: 'tier_b',
      ),
      'tier_a',
    );
    expect(
      nearbyVehicleMarkerServiceId(
        passengerSelectedTierId: '',
        primaryServiceId: 'tier_b',
      ),
      'tier_b',
    );
  });

  test('marker filename falls back to registry default', () {
    final registry = {
      'default': 'sedan_dark.svg',
      'tier_a': 'suv_black.svg',
    };
    expect(
      nearbyVehicleMarkerFilename(
        registry: registry,
        markerServiceId: 'tier_a',
      ),
      'suv_black.svg',
    );
    expect(
      nearbyVehicleMarkerFilename(
        registry: registry,
        markerServiceId: 'missing',
      ),
      'sedan_dark.svg',
    );
  });

  test('selectNearestNearbyVehicles caps count and radius', () {
    final vehicles = List.generate(
      25,
      (i) => NearbyVehicleSnapshot(
        presenceId: 'p$i',
        lat: 45.0,
        lng: -73.0,
        heading: 0,
        primaryServiceId: 's1',
        serviceIds: const ['s1'],
        zoneId: 'z1',
        updatedAt: null,
        distanceMeters: (i + 1) * 100,
      ),
    );
    final selected = selectNearestNearbyVehicles(
      vehicles,
      maxRadiusMeters: 3000,
      maxCount: 20,
    );
    expect(selected.length, 20);
    expect(selected.first.distanceMeters, 100);
    expect(selected.last.distanceMeters, 2000);

    final far = selectNearestNearbyVehicles(
      [
        NearbyVehicleSnapshot(
          presenceId: 'far',
          lat: 45,
          lng: -73,
          heading: null,
          primaryServiceId: 's',
          serviceIds: const ['s'],
          zoneId: 'z',
          updatedAt: null,
          distanceMeters: 5000,
        ),
      ],
      maxRadiusMeters: 3000,
      maxCount: 20,
    );
    expect(far, isEmpty);
  });
}
