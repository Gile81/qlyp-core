import 'package:cloud_firestore/cloud_firestore.dart';

/// Lat/lng pair with Firestore [GeoPoint] support (client superset).
class LocationLatLng {
  double? latitude;
  double? longitude;

  LocationLatLng({this.latitude, this.longitude});

  LocationLatLng.fromJson(Map<String, dynamic> json) {
    latitude = _toDouble(json['latitude']);
    longitude = _toDouble(json['longitude']);
  }

  /// Supports Firestore [GeoPoint] or `{latitude, longitude}` map shapes.
  static LocationLatLng? fromDynamic(dynamic raw) {
    if (raw == null) return null;
    if (raw is GeoPoint) {
      return LocationLatLng(latitude: raw.latitude, longitude: raw.longitude);
    }
    if (raw is Map) {
      return LocationLatLng.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

/// Geohash + geopoint pair used for driver/order geo queries.
class Positions {
  String? geohash;
  GeoPoint? geoPoint;

  Positions({this.geohash, this.geoPoint});

  Positions.fromJson(Map<String, dynamic> json) {
    geohash = json['geohash'];
    geoPoint = json['geopoint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geohash'] = geohash;
    data['geopoint'] = geoPoint;
    return data;
  }
}
