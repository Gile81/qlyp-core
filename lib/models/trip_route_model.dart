import 'package:cloud_firestore/cloud_firestore.dart';

/// Statuts possibles d'un trajet Qlyp Route publié par un conducteur.
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
    required this.make, required this.model, required this.year,
    required this.color, required this.plate,
  });

  factory VehicleInfoRoute.fromJson(Map<String, dynamic> json) => VehicleInfoRoute(
    make: json['make'] ?? '', model: json['model'] ?? '',
    year: json['year'] ?? 0, color: json['color'] ?? '', plate: json['plate'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'make': make, 'model': model, 'year': year, 'color': color, 'plate': plate,
  };
}

class TripPreferencesRoute {
  final bool smoking;
  final bool luggage;
  final bool animals;

  const TripPreferencesRoute({
    this.smoking = false, this.luggage = true, this.animals = false,
  });

  factory TripPreferencesRoute.fromJson(Map<String, dynamic> json) => TripPreferencesRoute(
    smoking: json['smoking'] ?? false,
    luggage: json['luggage'] ?? true,
    animals: json['animals'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'smoking': smoking, 'luggage': luggage, 'animals': animals,
  };
}

/// Document Firestore `trips_route` — trajet interurbain publié par un conducteur.
/// Voir PRD Master section 21.9 pour le schéma source.
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
  final int seatsAvailable;
  final double pricePerSeat; // doit rester ≤ distanceKm * 0.20 (ZRS rideshare_max_km_rate)
  final double distanceKm;
  final String status; // QlypRouteTripStatus
  final VehicleInfoRoute vehicleInfo;
  final TripPreferencesRoute preferences;
  final bool instantBook;
  final String routePolyline; // Mapbox encoded polyline

  const TripRouteModel({
    required this.id, required this.driverId, required this.originCity,
    required this.originLatLng, required this.destinationCity,
    required this.destinationLatLng, required this.waypoints,
    required this.departureAt, required this.seatsAvailable,
    required this.pricePerSeat, required this.distanceKm, required this.status,
    required this.vehicleInfo, required this.preferences,
    required this.instantBook, required this.routePolyline,
  });

  factory TripRouteModel.fromJson(String id, Map<String, dynamic> json) => TripRouteModel(
    id: id,
    driverId: json['driver_id'] ?? '',
    originCity: json['origin_city'] ?? '',
    originLatLng: json['origin_lat_lng'] as GeoPoint,
    destinationCity: json['destination_city'] ?? '',
    destinationLatLng: json['destination_lat_lng'] as GeoPoint,
    waypoints: (json['waypoints'] as List<dynamic>? ?? [])
        .map((w) => w as GeoPoint).toList(),
    departureAt: (json['departure_at'] as Timestamp).toDate(),
    seatsAvailable: json['seats_available'] ?? 0,
    pricePerSeat: (json['price_per_seat'] ?? 0).toDouble(),
    distanceKm: (json['distance_km'] ?? 0).toDouble(),
    status: json['status'] ?? QlypRouteTripStatus.active,
    vehicleInfo: VehicleInfoRoute.fromJson(
      Map<String, dynamic>.from(json['vehicle_info'] ?? {})),
    preferences: TripPreferencesRoute.fromJson(
      Map<String, dynamic>.from(json['preferences'] ?? {})),
    instantBook: json['instant_book'] ?? false,
    routePolyline: json['route_polyline'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'driver_id': driverId,
    'origin_city': originCity,
    'origin_lat_lng': originLatLng,
    'destination_city': destinationCity,
    'destination_lat_lng': destinationLatLng,
    'waypoints': waypoints,
    'departure_at': Timestamp.fromDate(departureAt),
    'seats_available': seatsAvailable,
    'price_per_seat': pricePerSeat,
    'distance_km': distanceKm,
    'status': status,
    'vehicle_info': vehicleInfo.toJson(),
    'preferences': preferences.toJson(),
    'instant_book': instantBook,
    'route_polyline': routePolyline,
  };
}