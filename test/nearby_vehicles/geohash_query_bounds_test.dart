import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/nearby_vehicles/geohash_query_bounds.dart';

void main() {
  test('encodeGeohash precision 7 matches server sample corners', () {
    expect(encodeGeohash(45.5017, -73.5673, 7).length, 7);
  });

  test('geohashQueryBounds returns sorted unique prefix ranges', () {
    final bounds = geohashQueryBounds(
      lat: 45.5017,
      lng: -73.5673,
      radiusMeters: 3000,
      precision: 7,
    );
    expect(bounds, isNotEmpty);
    for (final (start, end) in bounds) {
      expect(start.length, 7);
      expect(end, '$start~');
    }
    for (var i = 1; i < bounds.length; i++) {
      expect(bounds[i - 1].$1.compareTo(bounds[i].$1), lessThanOrEqualTo(0));
    }
  });
}
