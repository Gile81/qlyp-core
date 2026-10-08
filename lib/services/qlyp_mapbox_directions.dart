import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const Duration kQlypMapboxDirectionsTimeout = Duration(seconds: 5);

/// Mapbox Directions (accueil favoris, cartes) — durée et géométrie.
class QlypMapboxDirections {
  QlypMapboxDirections._();

  /// Durée de trajet en minutes (arrondi supérieur), ou `null` si indisponible.
  static Future<int?> drivingDurationMinutes({
    required String accessToken,
    required double sourceLatitude,
    required double sourceLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    if (accessToken.trim().isEmpty) return null;

    final coords =
        '$sourceLongitude,$sourceLatitude;$destinationLongitude,$destinationLatitude';
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/$coords'
      '?overview=false&access_token=${Uri.encodeComponent(accessToken)}',
    );

    try {
      final response =
          await http.get(url).timeout(kQlypMapboxDirectionsTimeout);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = body['routes'];
      if (routes is! List || routes.isEmpty) return null;

      final duration = routes[0]['duration'];
      if (duration is! num || duration <= 0) return null;
      return (duration / 60).ceil();
    } catch (_) {
      return null;
    }
  }
}

/// Driving route polyline from Mapbox Directions API (GeoJSON overview).
///
/// Returns an empty list when the request fails, times out, or yields no route.
Future<List<Position>> fetchMapboxDrivingRoutePositions({
  required String accessToken,
  required double sourceLatitude,
  required double sourceLongitude,
  required double destinationLatitude,
  required double destinationLongitude,
  List<({double lat, double lng})> viaPoints = const [],
}) async {
  if (accessToken.trim().isEmpty) return const [];

  final chain = <String>[
    '$sourceLongitude,$sourceLatitude',
    ...viaPoints.map((p) => '${p.lng},${p.lat}'),
    '$destinationLongitude,$destinationLatitude',
  ];
  final coords = chain.join(';');
  final url = Uri.parse(
    'https://api.mapbox.com/directions/v5/mapbox/driving/$coords'
    '?geometries=geojson&overview=full&access_token=${Uri.encodeComponent(accessToken)}',
  );

  try {
    final response =
        await http.get(url).timeout(kQlypMapboxDirectionsTimeout);
    if (response.statusCode != 200) return const [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = body['routes'];
    if (routes is! List || routes.isEmpty) return const [];

    final geometry = routes[0]['geometry'];
    if (geometry is! Map<String, dynamic>) return const [];

    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) return const [];

    final points = <Position>[];
    for (final coord in coordinates) {
      if (coord is! List || coord.length < 2) continue;
      final lng = coord[0];
      final lat = coord[1];
      if (lng is! num || lat is! num) continue;
      points.add(Position(lng.toDouble(), lat.toDouble()));
    }
    return points;
  } catch (_) {
    return const [];
  }
}