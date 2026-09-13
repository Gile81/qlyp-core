/// Lightweight lat/lng pair — replaces google_maps_flutter LatLng and latlong2.
class GeoLatLng {
  const GeoLatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  String toString() => 'GeoLatLng($latitude, $longitude)';
}