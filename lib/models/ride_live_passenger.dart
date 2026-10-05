import '../constants/ride_tracking_contract.dart';
import '../utils/ride_tracking_parse.dart';

/// Parsed `orders/{id}/live/passenger` document (no Firestore I/O).
class RideLivePassenger {
  const RideLivePassenger({
    this.lat,
    this.lng,
    this.updatedAt,
  });

  final double? lat;
  final double? lng;
  final DateTime? updatedAt;

  bool get hasPosition => lat != null && lng != null;

  factory RideLivePassenger.fromMap(Map<String, dynamic> map) {
    return RideLivePassenger(
      lat: rideTrackingDouble(map[RideTrackingContract.fieldLat]),
      lng: rideTrackingDouble(map[RideTrackingContract.fieldLng]),
      updatedAt:
          rideTrackingTimestamp(map[RideTrackingContract.fieldUpdatedAt]),
    );
  }
}
