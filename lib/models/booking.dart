/// Shared intercity booking status strings.
/// Full [InterCityOrderModel] remains in each app (heavy dependencies).
class QlypBookingStatus {
  const QlypBookingStatus._();

  static const String placed = 'Ride Placed';
  static const String active = 'Ride Active';
  static const String inProgress = 'Ride InProgress';
  static const String completed = 'Ride Completed';
  static const String canceled = 'Ride Canceled';
}
