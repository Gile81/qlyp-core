import 'dart:math' as math;

import '../models/geo_lat_lng.dart';

const double _earthRadiusMeters = 6371000;

/// Haversine distance in meters between two WGS84 points.
double haversineDistanceMeters(GeoLatLng a, GeoLatLng b) {
  final lat1 = _toRadians(a.latitude);
  final lat2 = _toRadians(b.latitude);
  final dLat = _toRadians(b.latitude - a.latitude);
  final dLng = _toRadians(b.longitude - a.longitude);

  final sinDLat = math.sin(dLat / 2);
  final sinDLng = math.sin(dLng / 2);
  final h = sinDLat * sinDLat +
      math.cos(lat1) * math.cos(lat2) * sinDLng * sinDLng;
  return 2 * _earthRadiusMeters * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
}

double _toRadians(double degrees) => degrees * math.pi / 180;

/// Closest point on a polyline and fraction traveled along total length [0, 1].
({GeoLatLng closest, double traveledFraction}) closestPointOnPolyline(
  GeoLatLng point,
  List<GeoLatLng> polyline,
) {
  if (polyline.isEmpty) {
    return (closest: point, traveledFraction: 0);
  }
  if (polyline.length == 1) {
    return (closest: polyline.first, traveledFraction: 0);
  }

  var bestDistance = double.infinity;
  var bestPoint = polyline.first;
  var bestTraveled = 0.0;

  final segmentLengths = <double>[];
  var totalLength = 0.0;
  for (var i = 0; i < polyline.length - 1; i++) {
    final len = haversineDistanceMeters(polyline[i], polyline[i + 1]);
    segmentLengths.add(len);
    totalLength += len;
  }

  if (totalLength <= 0) {
    return (closest: polyline.first, traveledFraction: 0);
  }

  var lengthBefore = 0.0;
  for (var i = 0; i < polyline.length - 1; i++) {
    final a = polyline[i];
    final b = polyline[i + 1];
    final segLen = segmentLengths[i];
    final projected = _closestPointOnSegment(point, a, b);
    final dist = haversineDistanceMeters(point, projected);
    if (dist < bestDistance) {
      bestDistance = dist;
      bestPoint = projected;
      final alongSeg = haversineDistanceMeters(a, projected);
      bestTraveled = (lengthBefore + alongSeg) / totalLength;
    }
    lengthBefore += segLen;
  }

  return (
    closest: bestPoint,
    traveledFraction: bestTraveled.clamp(0.0, 1.0),
  );
}

GeoLatLng _closestPointOnSegment(GeoLatLng p, GeoLatLng a, GeoLatLng b) {
  final ax = a.longitude;
  final ay = a.latitude;
  final bx = b.longitude;
  final by = b.latitude;
  final px = p.longitude;
  final py = p.latitude;

  final dx = bx - ax;
  final dy = by - ay;
  if (dx == 0 && dy == 0) return a;

  final t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
  final clamped = t.clamp(0.0, 1.0);
  return GeoLatLng(ay + clamped * dy, ax + clamped * dx);
}

/// Fraction of polyline length from start to the closest point to [vehicle].
double traveledFractionAlongPolyline(
  GeoLatLng vehicle,
  List<GeoLatLng> polyline,
) {
  return closestPointOnPolyline(vehicle, polyline).traveledFraction;
}
