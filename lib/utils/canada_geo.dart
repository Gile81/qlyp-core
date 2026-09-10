/// Helpers for Canadian map/search defaults and emulator GPS quirks.
class CanadaGeo {
  CanadaGeo._();

  /// Default Android emulator mock location (Google HQ).
  static const double googleHqLatitude = 37.422;
  static const double googleHqLongitude = -122.084;

  /// Montréal — default map/search origin for QLYP Canada apps.
  static const double defaultLatitude = 45.5017;
  static const double defaultLongitude = -73.5673;

  /// Autocomplete bias radius (~150 km, couvre le grand Montréal et couronne).
  static const int defaultSearchRadiusMeters = 150000;

  /// Rough bounding box for Canada (includes southern QC border).
  static const double _minLat = 41.7;
  static const double _maxLat = 83.2;
  static const double _minLng = -141.0;
  static const double _maxLng = -52.5;

  static bool isInCanada(double latitude, double longitude) {
    return latitude >= _minLat &&
        latitude <= _maxLat &&
        longitude >= _minLng &&
        longitude <= _maxLng;
  }

  /// Default [latitude, longitude] pair for map/search fallbacks.
  static (double lat, double lng) get defaultCoordinates =>
      (defaultLatitude, defaultLongitude);

  /// True when GPS should be ignored in favour of app Canada defaults
  /// (emulator mock at Google HQ, or any fix clearly outside Canada).
  static bool shouldUseCanadaFallback(double latitude, double longitude) {
    if (_isNearGoogleHq(latitude, longitude)) {
      return true;
    }
    return !isInCanada(latitude, longitude);
  }

  static bool _isNearGoogleHq(double latitude, double longitude) {
    const tolerance = 0.05;
    return (latitude - googleHqLatitude).abs() < tolerance &&
        (longitude - googleHqLongitude).abs() < tolerance;
  }
}
