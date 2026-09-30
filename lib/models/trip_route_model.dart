import 'package:cloud_firestore/cloud_firestore.dart';

/// Statuts possibles d'un trajet Qlyp Route publi? par un conducteur.
class QlypRouteTripStatus {
  const QlypRouteTripStatus._();
  static const String active = 'active';
  static const String full = 'full';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

class VehicleInfoRoute {
  final String make;
  final String model;
  final int year;
  final String color;
  final String plate;

  const VehicleInfoRoute({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plate,
  });

  factory VehicleInfoRoute.fromJson(Map<String, dynamic> json) => VehicleInfoRoute(
        make: json['make']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        year: (json['year'] as num?)?.toInt() ?? 0,
        color: json['color']?.toString() ?? '',
        plate: json['plate']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'plate': plate,
      };
}

class TripPreferencesRoute {
  final bool smoking;
  final bool luggage;
  final bool animals;

  const TripPreferencesRoute({
    this.smoking = false,
    this.luggage = true,
    this.animals = false,
  });

  factory TripPreferencesRoute.fromJson(Map<String, dynamic> json) => TripPreferencesRoute(
        smoking: json['smoking'] == true,
        luggage: json['luggage'] != false,
        animals: json['animals'] == true,
      );

  Map<String, dynamic> toJson() => {
        'smoking': smoking,
        'luggage': luggage,
        'animals': animals,
      };
}

/// Document Firestore `trips_route` ? lecture seule c?t? apps (?criture serveur).
class TripRouteModel {
  static const String collectionPath = 'trips_route';

  final String id;
  final String driverId;
  final String originCity;
  final GeoPoint originLatLng;
  final String destinationCity;
  final GeoPoint destinationLatLng;
  final List<GeoPoint> waypoints;
  final DateTime departureAt;
  final int seatsTotal;
  final int seatsAvailable;
  final double pricePerSeat;
  final double distanceKm;
  final int durationMin;
  final String zoneId;
  final double bookingFeePerSeat;
  final double? legalTotalCap;
  final List<String> complianceFlags;
  final String status;
  final VehicleInfoRoute vehicleInfo;
  final TripPreferencesRoute preferences;
  final bool instantBook;
  final String routePolyline;
  final DateTime? createdAt;

  const TripRouteModel({
    required this.id,
    required this.driverId,
    required this.originCity,
    required this.originLatLng,
    required this.destinationCity,
    required this.destinationLatLng,
    required this.waypoints,
    required this.departureAt,
    required this.seatsTotal,
    required this.seatsAvailable,
    required this.pricePerSeat,
    required this.distanceKm,
    required this.durationMin,
    required this.zoneId,
    required this.bookingFeePerSeat,
    this.legalTotalCap,
    this.complianceFlags = const [],
    required this.status,
    required this.vehicleInfo,
    required this.preferences,
    required this.instantBook,
    required this.routePolyline,
    this.createdAt,
  });

  factory TripRouteModel.fromJson(String id, Map<String, dynamic> json) => TripRouteModel(
        id: id,
        driverId: json['driver_id']?.toString() ?? '',
        originCity: json['origin_city']?.toString() ?? '',
        originLatLng: json['origin_lat_lng'] as GeoPoint,
        destinationCity: json['destination_city']?.toString() ?? '',
        destinationLatLng: json['destination_lat_lng'] as GeoPoint,
        waypoints: (json['waypoints'] as List<dynamic>? ?? [])
            .whereType<GeoPoint>()
            .toList(),
        departureAt: (json['departure_at'] as Timestamp).toDate(),
        seatsTotal: (json['seats_total'] as num?)?.toInt() ?? 0,
        seatsAvailable: (json['seats_available'] as num?)?.toInt() ?? 0,
        pricePerSeat: (json['price_per_seat'] as num?)?.toDouble() ?? 0,
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
        durationMin: (json['duration_min'] as num?)?.toInt() ?? 0,
        zoneId: json['zone_id']?.toString() ?? '',
        bookingFeePerSeat: (json['booking_fee_per_seat'] as num?)?.toDouble() ?? 0,
        legalTotalCap: (json['legal_total_cap'] as num?)?.toDouble(),
        complianceFlags: (json['compliance_flags'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        status: json['status']?.toString() ?? QlypRouteTripStatus.active,
        vehicleInfo: VehicleInfoRoute.fromJson(
          Map<String, dynamic>.from(json['vehicle_info'] as Map? ?? {}),
        ),
        preferences: TripPreferencesRoute.fromJson(
          Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
        ),
        instantBook: json['instant_book'] == true,
        routePolyline: json['route_polyline']?.toString() ?? '',
        createdAt: json['created_at'] is Timestamp
            ? (json['created_at'] as Timestamp).toDate()
            : null,
      );
}
