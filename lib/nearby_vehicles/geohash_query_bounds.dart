import 'dart:math' as math;

const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Encodes [lat]/[lng] at [precision] (same algorithm as `functions/src/nearby-vehicles/geohash.ts`).
String encodeGeohash(double lat, double lng, int precision) {
  var idx = 0;
  var bit = 0;
  var evenBit = true;
  var latMin = -90.0;
  var latMax = 90.0;
  var lngMin = -180.0;
  var lngMax = 180.0;
  final buffer = StringBuffer();

  while (buffer.length < precision) {
    if (evenBit) {
      final mid = (lngMin + lngMax) / 2;
      if (lng >= mid) {
        idx = idx * 2 + 1;
        lngMin = mid;
      } else {
        idx = idx * 2;
        lngMax = mid;
      }
    } else {
      final mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        idx = idx * 2 + 1;
        latMin = mid;
      } else {
        idx = idx * 2;
        latMax = mid;
      }
    }
    evenBit = !evenBit;
    bit += 1;
    if (bit == 5) {
      buffer.write(_base32[idx]);
      bit = 0;
      idx = 0;
    }
  }
  return buffer.toString();
}

/// Firestore range pairs for geohash prefix queries around a point.
List<(String start, String end)> geohashQueryBounds({
  required double lat,
  required double lng,
  required double radiusMeters,
  required int precision,
}) {
  final latDelta = radiusMeters / 111320;
  final lngDelta = radiusMeters /
      (111320 * math.max(math.cos(lat * math.pi / 180), 0.01));

  final corners = <(double, double)>[
    (lat - latDelta, lng - lngDelta),
    (lat - latDelta, lng + lngDelta),
    (lat + latDelta, lng - lngDelta),
    (lat + latDelta, lng + lngDelta),
  ];

  final prefixes = <String>{};
  for (final (clat, clng) in corners) {
    prefixes.add(encodeGeohash(clat, clng, precision));
  }

  final bounds = <(String, String)>[];
  for (final prefix in prefixes) {
    bounds.add((prefix, '$prefix~'));
  }
  bounds.sort((a, b) => a.$1.compareTo(b.$1));
  return bounds;
}
