import '../models/geo_lat_lng.dart';

const double _polyline6Factor = 1e6;

/// Decodes a Google-encoded polyline at precision 6 (Mapbox / server routes).
List<GeoLatLng> decodePolyline6(String encoded) {
  if (encoded.trim().isEmpty) return const [];

  final points = <GeoLatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;

  while (index < encoded.length) {
    final latResult = _decodeComponent(encoded, index);
    index = latResult.$2;
    lat += latResult.$1;

    final lngResult = _decodeComponent(encoded, index);
    index = lngResult.$2;
    lng += lngResult.$1;

    points.add(GeoLatLng(lat / _polyline6Factor, lng / _polyline6Factor));
  }
  return points;
}

(int, int) _decodeComponent(String encoded, int index) {
  var shift = 0;
  var result = 0;
  int byte;
  do {
    if (index >= encoded.length) break;
    byte = encoded.codeUnitAt(index++) - 63;
    result |= (byte & 0x1f) << shift;
    shift += 5;
  } while (byte >= 0x20);

  final delta = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  return (delta, index);
}
