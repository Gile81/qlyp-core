import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qlyp_core/constants/ride_tracking_contract.dart';
import 'package:qlyp_core/models/ride_eta.dart';
import 'package:qlyp_core/models/ride_live_card.dart';
import 'package:qlyp_core/models/ride_live_driver.dart';
import 'package:qlyp_core/models/ride_live_passenger.dart';
import 'package:qlyp_core/models/ride_phase.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_CA');
    await initializeDateFormatting('en_CA');
  });

  test('RideLiveDriver parses full driver live map', () {
    final at = DateTime.utc(2026, 10, 5, 20, 0);
    final driver = RideLiveDriver.fromMap({
      RideTrackingContract.fieldLat: 45.5017,
      RideTrackingContract.fieldLng: -73.5673,
      RideTrackingContract.fieldBearing: 90.0,
      RideTrackingContract.fieldSpeedMps: 8.2,
      RideTrackingContract.fieldPositionAt: Timestamp.fromDate(at),
      RideTrackingContract.fieldPhase:
          RideTrackingContract.phaseDriverEnRoute,
      RideTrackingContract.fieldEtaSeconds: 420,
      RideTrackingContract.fieldDistanceMeters: 3200,
      RideTrackingContract.fieldEtaTarget: RideTrackingContract.etaTargetPickup,
      RideTrackingContract.fieldEtaComputedAt: Timestamp.fromDate(at),
      RideTrackingContract.fieldRoutePolyline6: 'abc',
      RideTrackingContract.fieldRouteComputedAt: Timestamp.fromDate(at),
    });

    expect(driver.lat, 45.5017);
    expect(driver.phase, RidePhase.driverEnRoute);
    expect(driver.eta?.remainingSeconds(now: at), 420);
    expect(driver.routePolyline6, 'abc');
    expect(driver.isStale(now: at.add(const Duration(seconds: 29))), isFalse);
    expect(driver.isStale(now: at.add(const Duration(seconds: 31))), isTrue);
  });

  test('RideLiveDriver tolerates missing fields and unknown phase', () {
    final driver = RideLiveDriver.fromMap({
      RideTrackingContract.fieldPhase: 'unknown_phase',
    });
    expect(driver.lat, isNull);
    expect(driver.phase, isNull);
    expect(driver.eta, isNull);
    expect(driver.isStale(), isTrue);
  });

  test('RideEta countdown and arrival clock FR/EN', () {
    final computed = DateTime.utc(2026, 10, 5, 22, 0);
    final eta = RideEta.fromMap({
      RideTrackingContract.fieldEtaSeconds: 120,
      RideTrackingContract.fieldEtaComputedAt: Timestamp.fromDate(computed),
    });
    final mid = computed.add(const Duration(seconds: 30));
    expect(eta.remainingSeconds(now: mid), 90);
    expect(eta.remainingMinutesRounded(now: mid), 2);

    final frClock = eta.formatArrivalClock(
      french: true,
      now: computed,
    );
    expect(frClock, contains('h'));

    final enClock = eta.formatArrivalClock(
      french: false,
      now: computed,
    );
    expect(enClock, isNotEmpty);
  });

  test('RideLiveCard and RideLivePassenger parse maps', () {
    final card = RideLiveCard.fromMap({
      RideTrackingContract.fieldDriverFirstName: 'Alex',
      RideTrackingContract.fieldServiceId: 'svc_1',
      RideTrackingContract.fieldRatingAvg: 4.8,
    });
    expect(card.driverFirstName, 'Alex');
    expect(card.serviceId, 'svc_1');
    expect(card.ratingAvg, 4.8);

    final passenger = RideLivePassenger.fromMap({
      RideTrackingContract.fieldLat: 1.0,
      RideTrackingContract.fieldLng: 2.0,
    });
    expect(passenger.hasPosition, isTrue);
  });
}
