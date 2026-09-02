/// Shared ride/trip status strings used by both apps.
/// Full [OrderModel] remains in each app.
class QlypTripStatus {
  const QlypTripStatus._();

  static const String ridePlaced = 'Ride Placed';
  static const String rideActive = 'Ride Active';
  static const String rideInProgress = 'Ride InProgress';
  static const String rideComplete = 'Ride Completed';
  static const String rideCanceled = 'Ride Canceled';
  static const String rideHold = 'Ride Hold';
  static const String rideHoldAccepted = 'Ride Hold Accepted';
}

/// Shared login type constants.
class QlypLoginType {
  const QlypLoginType._();

  static const String phone = 'phone';
  static const String google = 'google';
  static const String apple = 'apple';
}

/// Shared user role type constants.
class QlypUserType {
  const QlypUserType._();

  static const String customer = 'customer';
  static const String driver = 'driver';
  static const String admin = 'admin';
  static const String owner = 'owner';
}
