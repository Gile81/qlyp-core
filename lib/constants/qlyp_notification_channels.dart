/// Shared FCM / Android channel ids (see shared/passenger_notification_contract.json).
class QlypNotificationChannels {
  const QlypNotificationChannels._();

  // Driver (alarm)
  static const String bidAlerts = 'qlyp_bid_alerts';
  static const String dispatch = 'qlyp_dispatch_channel';
  static const String marketplaceDriver = 'qlyp_marketplace_channel';

  // Passenger
  static const String rideAccepted = 'qlyp_ride_accepted';
  static const String driverArriving = 'qlyp_driver_arriving';
  static const String payments = 'qlyp_payments';
  static const String rideUpdates = 'qlyp_ride_updates';
  static const String scheduled = 'qlyp_scheduled_channel';
  static const String marketplacePassenger = 'qlyp_marketplace_passenger';
  static const String route = 'qlyp_route_channel';

  // Shared
  static const String legalZoneValidated = 'qlyp_legal_zone_validated';
  static const String legalZoneRefused = 'qlyp_legal_zone_refused';
}

enum QlypNotificationAppRole { driver, passenger }
