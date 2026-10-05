import '../constants/qlyp_motion.dart';
import '../constants/ride_tracking_contract.dart';
import '../models/ride_eta.dart';
import '../models/ride_phase.dart';
import '../utils/ride_tracking_parse.dart';

/// Parsed `orders/{id}/live/driver` document (no Firestore I/O).
class RideLiveDriver {
  const RideLiveDriver({
    this.lat,
    this.lng,
    this.bearing,
    this.speedMps,
    this.positionAt,
    this.phase,
    this.eta,
    this.routePolyline6,
    this.routeComputedAt,
  });

  final double? lat;
  final double? lng;
  final double? bearing;
  final double? speedMps;
  final DateTime? positionAt;
  final RidePhase? phase;
  final RideEta? eta;
  final String? routePolyline6;
  final DateTime? routeComputedAt;

  bool get hasPosition => lat != null && lng != null;

  bool isStale({DateTime? now}) {
    if (positionAt == null) return true;
    final clock = now ?? DateTime.now();
    return clock.difference(positionAt!) > kRideLiveStalePosition;
  }

  factory RideLiveDriver.fromMap(Map<String, dynamic> map) {
    final etaMap = <String, dynamic>{
      RideTrackingContract.fieldEtaSeconds:
          map[RideTrackingContract.fieldEtaSeconds],
      RideTrackingContract.fieldDistanceMeters:
          map[RideTrackingContract.fieldDistanceMeters],
      RideTrackingContract.fieldEtaTarget:
          map[RideTrackingContract.fieldEtaTarget],
      RideTrackingContract.fieldEtaComputedAt:
          map[RideTrackingContract.fieldEtaComputedAt],
    };
    final hasEta = etaMap.values.any((v) => v != null);
    return RideLiveDriver(
      lat: rideTrackingDouble(map[RideTrackingContract.fieldLat]),
      lng: rideTrackingDouble(map[RideTrackingContract.fieldLng]),
      bearing: rideTrackingDouble(map[RideTrackingContract.fieldBearing]),
      speedMps: rideTrackingDouble(map[RideTrackingContract.fieldSpeedMps]),
      positionAt:
          rideTrackingTimestamp(map[RideTrackingContract.fieldPositionAt]),
      phase: ridePhaseFromWire(map[RideTrackingContract.fieldPhase]),
      eta: hasEta ? RideEta.fromMap(etaMap) : null,
      routePolyline6:
          rideTrackingOptionalString(map[RideTrackingContract.fieldRoutePolyline6]),
      routeComputedAt: rideTrackingTimestamp(
        map[RideTrackingContract.fieldRouteComputedAt],
      ),
    );
  }
}
