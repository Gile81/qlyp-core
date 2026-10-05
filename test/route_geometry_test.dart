import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/geo_lat_lng.dart';
import 'package:qlyp_core/ride_tracking/route_geometry.dart';
import 'package:qlyp_core/utils/polyline6.dart';

void main() {
  test('haversine and traveled fraction on simple polyline', () {
    final a = GeoLatLng(45.0, -73.0);
    final b = GeoLatLng(45.001, -73.0);
    final dist = haversineDistanceMeters(a, b);
    expect(dist, greaterThan(100));

    final line = [a, b];
    final mid = GeoLatLng(45.0005, -73.0);
    final result = closestPointOnPolyline(mid, line);
    expect(result.traveledFraction, closeTo(0.5, 0.05));
  });

  test('closest point when query is off polyline', () {
    final line = [
      GeoLatLng(0, 0),
      GeoLatLng(0, 1),
      GeoLatLng(0, 2),
    ];
    final off = GeoLatLng(1, 1);
    final result = closestPointOnPolyline(off, line);
    expect(result.closest.latitude, closeTo(0, 0.0001));
    expect(result.traveledFraction, inInclusiveRange(0, 1));
  });

  test('decodePolyline6 returns empty for blank input', () {
    expect(decodePolyline6(''), isEmpty);
    expect(decodePolyline6('   '), isEmpty);
  });

  test('decodePolyline6 round-trip at precision 6', () {
    final original = [
      GeoLatLng(45.5017, -73.5673),
      GeoLatLng(45.5117, -73.5773),
    ];
    final encoded = _encodePolyline6(original);
    final decoded = decodePolyline6(encoded);
    expect(decoded.length, original.length);
    for (var i = 0; i < original.length; i++) {
      expect(decoded[i].latitude, closeTo(original[i].latitude, 0.000001));
      expect(decoded[i].longitude, closeTo(original[i].longitude, 0.000001));
    }
  });
}

String _encodePolyline6(List<GeoLatLng> points) {
  var lastLat = 0;
  var lastLng = 0;
  final buffer = StringBuffer();
  for (final p in points) {
    final lat = (p.latitude * 1e6).round();
    final lng = (p.longitude * 1e6).round();
    _encodeComponent(buffer, lat - lastLat);
    _encodeComponent(buffer, lng - lastLng);
    lastLat = lat;
    lastLng = lng;
  }
  return buffer.toString();
}

void _encodeComponent(StringBuffer buffer, int value) {
  var v = value < 0 ? ~(value << 1) : (value << 1);
  while (v >= 0x20) {
    buffer.writeCharCode(((0x20 | (v & 0x1f)) + 63));
    v >>= 5;
  }
  buffer.writeCharCode(v + 63);
}
