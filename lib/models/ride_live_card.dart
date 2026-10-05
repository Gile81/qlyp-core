import '../constants/ride_tracking_contract.dart';
import '../utils/ride_tracking_parse.dart';

/// Parsed `orders/{id}/live/card` document (no Firestore I/O).
class RideLiveCard {
  const RideLiveCard({
    this.driverFirstName,
    this.driverPhotoUrl,
    this.ratingAvg,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.vehiclePlate,
    this.serviceId,
  });

  final String? driverFirstName;
  final String? driverPhotoUrl;
  final double? ratingAvg;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehiclePlate;
  final String? serviceId;

  factory RideLiveCard.fromMap(Map<String, dynamic> map) {
    return RideLiveCard(
      driverFirstName: rideTrackingOptionalString(
        map[RideTrackingContract.fieldDriverFirstName],
      ),
      driverPhotoUrl: rideTrackingOptionalString(
        map[RideTrackingContract.fieldDriverPhotoUrl],
      ),
      ratingAvg: rideTrackingDouble(map[RideTrackingContract.fieldRatingAvg]),
      vehicleMake: rideTrackingOptionalString(
        map[RideTrackingContract.fieldVehicleMake],
      ),
      vehicleModel: rideTrackingOptionalString(
        map[RideTrackingContract.fieldVehicleModel],
      ),
      vehicleColor: rideTrackingOptionalString(
        map[RideTrackingContract.fieldVehicleColor],
      ),
      vehiclePlate: rideTrackingOptionalString(
        map[RideTrackingContract.fieldVehiclePlate],
      ),
      serviceId:
          rideTrackingOptionalString(map[RideTrackingContract.fieldServiceId]),
    );
  }
}
