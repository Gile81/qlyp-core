import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qlyp_core/models/geo_lat_lng.dart';
import 'package:qlyp_core/ride_tracking/route_geometry.dart';

/// One anonymous nearby vehicle from `nearby_vehicles/{presenceId}`.
class NearbyVehicleSnapshot {
  const NearbyVehicleSnapshot({
    required this.presenceId,
    required this.lat,
    required this.lng,
    required this.heading,
    required this.primaryServiceId,
    required this.serviceIds,
    required this.zoneId,
    required this.updatedAt,
    required this.distanceMeters,
  });

  final String presenceId;
  final double lat;
  final double lng;
  final double? heading;
  final String primaryServiceId;
  final List<String> serviceIds;
  final String zoneId;
  final DateTime? updatedAt;
  final double distanceMeters;

  static NearbyVehicleSnapshot? fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required double passengerLat,
    required double passengerLng,
  }) {
    final data = doc.data();
    if (data == null) return null;
    final lat = _asDouble(data['lat']);
    final lng = _asDouble(data['lng']);
    if (lat == null || lng == null) return null;

    final primary = (data['primaryServiceId'] ?? '').toString().trim();
    final zoneId = (data['zoneId'] ?? '').toString().trim();
    if (primary.isEmpty || zoneId.isEmpty) return null;

    final serviceIds = <String>[];
    final rawIds = data['serviceIds'];
    if (rawIds is List) {
      for (final item in rawIds) {
        final id = item.toString().trim();
        if (id.isNotEmpty) serviceIds.add(id);
      }
    }

    final heading = _asDouble(data['heading']);
    final updatedAt = _asDateTime(data['updatedAt']);

    return NearbyVehicleSnapshot(
      presenceId: doc.id,
      lat: lat,
      lng: lng,
      heading: heading,
      primaryServiceId: primary,
      serviceIds: serviceIds,
      zoneId: zoneId,
      updatedAt: updatedAt,
      distanceMeters: haversineDistanceMeters(
        GeoLatLng(passengerLat, passengerLng),
        GeoLatLng(lat, lng),
      ),
    );
  }
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

DateTime? _asDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
