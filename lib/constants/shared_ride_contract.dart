/// Firestore / callable wire names for shared rides (S7-1a2 contract v2).
///
/// Mirror of `functions/src/contracts/shared_ride_contract.json`.
/// One `static const String` per wire name — keep in sync for parity tests.
abstract final class SharedRideContract {
  static const int contractVersion = 2;

  // --- orders: clientWrite ---
  static const String fieldSharedRideOptIn = 'shared_ride_opt_in';
  static const String fieldSharedRideSeats = 'shared_ride_seats';

  // --- orders: serverWrite ---
  static const String fieldSharedTripId = 'sharedTripId';
  static const String fieldSharedRideStatus = 'shared_ride_status';
  static const String fieldSharedRideDispatchPhase = 'shared_ride_dispatch_phase';
  static const String fieldSharedRideBoardedAt = 'shared_ride_boarded_at';
  static const String fieldSharedRideDroppedAt = 'shared_ride_dropped_at';
  static const String fieldSharedRideWasShared = 'shared_ride_was_shared';
  static const String fieldSharedRideFallback = 'shared_ride_fallback';
  static const String fieldSharedRideFinalRideTotal = 'shared_ride_final_ride_total';
  static const String fieldQuoteSoloTotal = 'quote_solo_total';
  static const String fieldQuoteSharedTotal = 'quote_shared_total';
  static const String fieldQuoteSoloTotalBeforeCoupon = 'quote_solo_total_before_coupon';
  static const String fieldQuoteSharedTotalBeforeCoupon =
      'quote_shared_total_before_coupon';
  static const String fieldSharedRideView = 'shared_ride_view';

  static const String sharedRideStatusSearching = 'searching';
  static const String sharedRideStatusMatched = 'matched';
  static const String sharedRideStatusSolo = 'solo';
  static const String sharedRideStatusClosed = 'closed';

  static const String sharedRideFallbackMarketplace = 'marketplace';

  // --- orders: adminWrite ---
  static const String fieldQuotePayableTotal = 'quote_payable_total';

  // --- orders: addressFieldsForStops ---
  static const String fieldSourceLocationName = 'sourceLocationName';
  static const String fieldDestinationLocationName = 'destinationLocationName';

  // --- priceQuoteRideFields ---
  static const String fieldSharedRideAvailable = 'shared_ride_available';
  static const String fieldSharedRideDiscountPct = 'shared_ride_discount_pct';

  // --- sharedRideView (nested on order) ---
  static const String viewOtherPassengerFirstName = 'otherPassengerFirstName';
  static const String viewOtherPassengerOnBoard = 'otherPassengerOnBoard';
  static const String viewStopsBeforeMyPickup = 'stopsBeforeMyPickup';
  static const String viewStopsBeforeMyDropoff = 'stopsBeforeMyDropoff';
  static const String viewIsShared = 'isShared';
  static const String viewPriceIfShared = 'priceIfShared';
  static const String viewPriceIfSolo = 'priceIfSolo';
  static const String viewSharedRideFallback = 'shared_ride_fallback';

  // --- shared_trips document ---
  static const String sharedTripsCollection = 'shared_trips';
  static const String tripFieldDriverId = 'driverId';
  static const String tripFieldServiceId = 'serviceId';
  static const String tripFieldZoneId = 'zoneId';
  static const String tripFieldSeatCapacity = 'seatCapacity';
  static const String tripFieldSeatsUsed = 'seatsUsed';
  static const String tripFieldJoinOpen = 'joinOpen';
  static const String tripFieldStatus = 'status';
  static const String tripFieldLockVersion = 'lockVersion';
  static const String tripFieldNextStopIndex = 'nextStopIndex';
  static const String tripFieldBookings = 'bookings';
  static const String tripFieldStops = 'stops';

  static const String tripStatusOpen = 'open';
  static const String tripStatusFull = 'full';
  static const String tripStatusClosed = 'closed';
  static const String tripStatusCompleted = 'completed';

  // --- sharedTripStop ---
  static const String stopFieldOrderId = 'orderId';
  static const String stopFieldKind = 'kind';
  static const String stopFieldLat = 'lat';
  static const String stopFieldLng = 'lng';
  static const String stopFieldAddress = 'address';
  static const String stopFieldStatus = 'status';

  static const String stopKindPickup = 'pickup';
  static const String stopKindDropoff = 'dropoff';

  static const String stopStatusPending = 'pending';
  static const String stopStatusDone = 'done';
  static const String stopStatusCanceled = 'canceled';

  // --- sharedTripBooking ---
  static const String bookingFieldOrderId = 'orderId';
  static const String bookingFieldUserId = 'userId';
  static const String bookingFieldSeats = 'seats';
  static const String bookingFieldSoloDurationS = 'soloDurationS';
  static const String bookingFieldPlannedDurationS = 'plannedDurationS';
  static const String bookingFieldStatus = 'status';
  static const String bookingFieldBoardedAt = 'boardedAt';
  static const String bookingFieldDroppedAt = 'droppedAt';

  static const String bookingStatusPending = 'pending';
  static const String bookingStatusBoarded = 'boarded';
  static const String bookingStatusDropped = 'dropped';
  static const String bookingStatusCanceled = 'canceled';

  // --- notifications ---
  static const String notificationTypeSharedRideCoPassenger =
      'shared_ride_co_passenger';
  static const String notificationTypeSharedRideMarketplaceFallback =
      'shared_ride_marketplace_fallback';
  static const String notificationTypeSharedRidePassengerJoined =
      'shared_ride_passenger_joined';

  static const String notificationChannelRideUpdates = 'qlyp_ride_updates';
  static const String notificationChannelDispatch = 'qlyp_dispatch_channel';

  static const String notificationDataType = 'type';
  static const String notificationDataOrderId = 'orderId';
  static const String notificationDataSharedTripId = 'sharedTripId';
  static const String notificationDataChannel = 'channel';

  /// Every wire name declared above that appears as a key in the JSON contract.
  static const List<String> jsonObjectKeys = [
    fieldSharedRideOptIn,
    fieldSharedRideSeats,
    fieldSharedTripId,
    fieldSharedRideStatus,
    fieldSharedRideDispatchPhase,
    fieldSharedRideBoardedAt,
    fieldSharedRideDroppedAt,
    fieldSharedRideWasShared,
    fieldSharedRideFallback,
    fieldSharedRideFinalRideTotal,
    fieldQuoteSoloTotal,
    fieldQuoteSharedTotal,
    fieldQuoteSoloTotalBeforeCoupon,
    fieldQuoteSharedTotalBeforeCoupon,
    fieldSharedRideView,
    fieldQuotePayableTotal,
    fieldSourceLocationName,
    fieldDestinationLocationName,
    fieldSharedRideAvailable,
    fieldSharedRideDiscountPct,
    viewOtherPassengerFirstName,
    viewOtherPassengerOnBoard,
    viewStopsBeforeMyPickup,
    viewStopsBeforeMyDropoff,
    viewIsShared,
    viewPriceIfShared,
    viewPriceIfSolo,
    viewSharedRideFallback,
    tripFieldDriverId,
    tripFieldServiceId,
    tripFieldZoneId,
    tripFieldSeatCapacity,
    tripFieldSeatsUsed,
    tripFieldJoinOpen,
    tripFieldStatus,
    tripFieldLockVersion,
    tripFieldNextStopIndex,
    tripFieldBookings,
    tripFieldStops,
    stopFieldOrderId,
    stopFieldKind,
    stopFieldLat,
    stopFieldLng,
    stopFieldAddress,
    stopFieldStatus,
    bookingFieldOrderId,
    bookingFieldUserId,
    bookingFieldSeats,
    bookingFieldSoloDurationS,
    bookingFieldPlannedDurationS,
    bookingFieldStatus,
    bookingFieldBoardedAt,
    bookingFieldDroppedAt,
  ];

  static const List<String> jsonEnumValues = [
    sharedRideStatusSearching,
    sharedRideStatusMatched,
    sharedRideStatusSolo,
    sharedRideStatusClosed,
    sharedRideFallbackMarketplace,
    tripStatusOpen,
    tripStatusFull,
    tripStatusClosed,
    tripStatusCompleted,
    stopKindPickup,
    stopKindDropoff,
    stopStatusPending,
    stopStatusDone,
    stopStatusCanceled,
    bookingStatusPending,
    bookingStatusBoarded,
    bookingStatusDropped,
    bookingStatusCanceled,
    notificationTypeSharedRideCoPassenger,
    notificationTypeSharedRideMarketplaceFallback,
    notificationTypeSharedRidePassengerJoined,
  ];
}
