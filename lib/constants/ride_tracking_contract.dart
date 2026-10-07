/// Firestore / callable wire names for live ride tracking (S5-10).
///
/// Mirror of `functions/src/contracts/ride_tracking_contract.json` (S5-10a).
/// One `static const String` per wire name — keep in sync for parity tests.
abstract final class RideTrackingContract {
  static const String phaseDriverEnRoute = 'driver_en_route';
  static const String phaseDriverArrived = 'driver_arrived';
  static const String phaseInProgress = 'in_progress';
  static const String phaseCompleted = 'completed';
  static const String phaseCanceled = 'canceled';
  static const String ordersCollection = 'orders';
  static const String liveCollection = 'live';
  static const String liveDriverDoc = 'driver';
  static const String liveCardDoc = 'card';
  static const String livePassengerDoc = 'passenger';
  static const String fieldLat = 'lat';
  static const String fieldLng = 'lng';
  static const String fieldBearing = 'bearing';
  static const String fieldSpeedMps = 'speedMps';
  static const String fieldPositionAt = 'positionAt';
  static const String fieldPhase = 'phase';
  static const String fieldEtaSeconds = 'etaSeconds';
  static const String fieldDistanceMeters = 'distanceMeters';
  static const String fieldEtaTarget = 'etaTarget';
  static const String fieldEtaComputedAt = 'etaComputedAt';
  static const String fieldRoutePolyline6 = 'routePolyline6';
  static const String fieldRouteComputedAt = 'routeComputedAt';
  static const String fieldNextStopIndex = 'nextStopIndex';
  static const String fieldNextStopEtaSeconds = 'nextStopEtaSeconds';
  static const String fieldNextStopDistanceMeters = 'nextStopDistanceMeters';
  static const String fieldNextStopEtaComputedAt = 'nextStopEtaComputedAt';
  static const String fieldDriverFirstName = 'driverFirstName';
  static const String fieldDriverPhotoUrl = 'driverPhotoUrl';
  static const String fieldRatingAvg = 'ratingAvg';
  static const String fieldVehicleMake = 'vehicleMake';
  static const String fieldVehicleModel = 'vehicleModel';
  static const String fieldVehicleColor = 'vehicleColor';
  static const String fieldVehiclePlate = 'vehiclePlate';
  static const String fieldServiceId = 'serviceId';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldRidePhase = 'ridePhase';
  static const String fieldDriverArrivedAt = 'driverArrivedAt';
  static const String fieldFreeWaitEndsAt = 'freeWaitEndsAt';
  static const String fieldCompletedAt = 'completedAt';
  static const String etaTargetPickup = 'pickup';
  static const String etaTargetDropoff = 'dropoff';
  static const String callableMarkDriverArrived = 'markDriverArrived';
  static const String callableCompleteRide = 'completeRide';
  static const String callableGetRideShareLink = 'getRideShareLink';
}
