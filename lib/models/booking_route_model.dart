import 'package:cloud_firestore/cloud_firestore.dart';

/// Statuts possibles d'une réservation Qlyp Route.
class QlypRouteBookingStatus {
  const QlypRouteBookingStatus._();
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String confirmed = 'confirmed';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

/// Document Firestore `bookings_route` — réservation d'un passager sur un trip_route.
/// Voir PRD Master section 21.9. Champ `driverId` dénormalisé (absent du PRD,
/// ajouté pour permettre les Security Rules sans lookup get() vers trips_route).
class BookingRouteModel {
  static const String collectionPath = 'bookings_route';

  final String id;
  final String tripId;
  final String passengerId;
  final String driverId; // dénormalisé depuis trips_route.driver_id à la création
  final int seatsBooked;
  final double offeredPricePerSeat;
  final String status; // QlypRouteBookingStatus
  final String stripePaymentIntentId;
  final GeoPoint pickupPoint;
  final GeoPoint dropoffPoint;
  final DateTime createdAt;
  final DateTime escrowReleaseAt; // confirmedAt + 4 jours (ZRS rideshare_escrow_days)

  const BookingRouteModel({
    required this.id, required this.tripId, required this.passengerId,
    required this.driverId, required this.seatsBooked,
    required this.offeredPricePerSeat, required this.status,
    required this.stripePaymentIntentId, required this.pickupPoint,
    required this.dropoffPoint, required this.createdAt,
    required this.escrowReleaseAt,
  });

  factory BookingRouteModel.fromJson(String id, Map<String, dynamic> json) => BookingRouteModel(
    id: id,
    tripId: json['trip_id'] ?? '',
    passengerId: json['passenger_id'] ?? '',
    driverId: json['driver_id'] ?? '',
    seatsBooked: json['seats_booked'] ?? 0,
    offeredPricePerSeat: (json['offered_price_per_seat'] ?? 0).toDouble(),
    status: json['status'] ?? QlypRouteBookingStatus.pending,
    stripePaymentIntentId: json['stripe_payment_intent_id'] ?? '',
    pickupPoint: json['pickup_point'] as GeoPoint,
    dropoffPoint: json['dropoff_point'] as GeoPoint,
    createdAt: (json['created_at'] as Timestamp).toDate(),
    escrowReleaseAt: (json['escrow_release_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'trip_id': tripId,
    'passenger_id': passengerId,
    'driver_id': driverId,
    'seats_booked': seatsBooked,
    'offered_price_per_seat': offeredPricePerSeat,
    'status': status,
    'stripe_payment_intent_id': stripePaymentIntentId,
    'pickup_point': pickupPoint,
    'dropoff_point': dropoffPoint,
    'created_at': Timestamp.fromDate(createdAt),
    'escrow_release_at': Timestamp.fromDate(escrowReleaseAt),
  };
}