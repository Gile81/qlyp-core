import '../constants/qlyp_motion.dart';

/// Firestore `nearby_vehicles` client query limits (S6-9b, aligned with server S6-9a).
const String kNearbyVehiclesCollection = 'nearby_vehicles';

/// Search radius around the passenger (meters).
const double kNearbyVehiclesRadiusMeters = 3000;

/// Maximum vehicles drawn after distance sort.
const int kNearbyVehiclesMaxCount = 20;

/// Geohash precision written by the server projection.
const int kNearbyVehiclesGeohashPrecision = 7;

/// Server write throttle — marker tween duration target.
const Duration kNearbyVehiclesServerWriteInterval = kDurNearbyVehicleServerWrite;