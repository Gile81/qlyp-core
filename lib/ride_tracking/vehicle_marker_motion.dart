import '../constants/qlyp_motion.dart';
import '../models/geo_lat_lng.dart';
import '../ride_tracking/route_geometry.dart';

/// Display frame for the animated vehicle marker (pure logic, no Mapbox).
class VehicleMarkerFrame {
  const VehicleMarkerFrame({
    required this.lat,
    required this.lng,
    required this.bearing,
    required this.opacity,
    required this.progress,
  });

  final double lat;
  final double lng;
  final double bearing;
  final double opacity;
  /// 0 at tween start, 1 at end.
  final double progress;
}

/// GPS-driven interpolation for a vehicle map marker.
class VehicleMarkerMotion {
  VehicleMarkerMotion();

  double? _displayLat;
  double? _displayLng;
  double _displayBearing = 0;
  bool _stale = true;

  double? _tweenStartLat;
  double? _tweenStartLng;
  double _tweenStartBearing = 0;
  double? _tweenEndLat;
  double? _tweenEndLng;
  double _tweenEndBearing = 0;
  DateTime? _tweenStartedAt;
  Duration _tweenDuration = kDurMarkerTween;

  double? get displayLat => _displayLat;
  double? get displayLng => _displayLng;
  double get displayBearing => _displayBearing;

  static double shortestBearingDelta(double fromDeg, double toDeg) {
    var delta = (toDeg - fromDeg) % 360;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return delta;
  }

  static double lerpBearing(double fromDeg, double toDeg, double t) {
    final delta = shortestBearingDelta(fromDeg, toDeg);
    return (fromDeg + delta * t) % 360;
  }

  static Duration clampTweenDuration(Duration betweenUpdates) {
    if (betweenUpdates <= Duration.zero) return kDurMarkerTween;
    if (betweenUpdates < kDurMarkerTweenMin) return kDurMarkerTweenMin;
    if (betweenUpdates > kDurMarkerTweenMax) return kDurMarkerTweenMax;
    return betweenUpdates;
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  void reset() {
    _displayLat = null;
    _displayLng = null;
    _displayBearing = 0;
    _stale = true;
    _tweenStartLat = null;
    _tweenEndLat = null;
    _tweenStartedAt = null;
  }

  void applyGpsFix({
    required double lat,
    required double lng,
    required double? bearing,
    required double? speedMps,
    required DateTime? positionAt,
    required bool disableAnimations,
    required DateTime now,
    bool stale = false,
  }) {
    _stale = stale;
    final target = GeoLatLng(lat, lng);
    final hadDisplay = _displayLat != null && _displayLng != null;

    if (!hadDisplay) {
      _snapTo(lat, lng, bearing, speedMps, positionAt);
      return;
    }

    final from = GeoLatLng(_displayLat!, _displayLng!);
    final jump = haversineDistanceMeters(from, target);
    if (disableAnimations || jump >= kVehicleTeleportDistanceMeters) {
      _snapTo(lat, lng, bearing, speedMps, positionAt);
      return;
    }

    _tweenStartLat = _displayLat;
    _tweenStartLng = _displayLng;
    _tweenStartBearing = _displayBearing;
    _tweenEndLat = lat;
    _tweenEndLng = lng;
    _tweenEndBearing = _resolveTargetBearing(
      speedMps: speedMps,
      bearing: bearing,
      fallback: _displayBearing,
    );

    final between = positionAt != null && _lastPositionAt != null
        ? positionAt.difference(_lastPositionAt!)
        : kDurMarkerTween;
    _tweenDuration = clampTweenDuration(between);
    _tweenStartedAt = now;
    _lastPositionAt = positionAt;
  }

  DateTime? _lastPositionAt;

  void _snapTo(
    double lat,
    double lng,
    double? bearing,
    double? speedMps,
    DateTime? positionAt,
  ) {
    _displayLat = lat;
    _displayLng = lng;
    if (bearing != null) {
      _displayBearing = bearing % 360;
    } else {
      _displayBearing = _resolveTargetBearing(
        speedMps: speedMps,
        bearing: bearing,
        fallback: _displayBearing,
      );
    }
    _tweenStartLat = null;
    _tweenEndLat = null;
    _tweenStartedAt = null;
    _lastPositionAt = positionAt;
  }

  double _resolveTargetBearing({
    required double? speedMps,
    required double? bearing,
    required double fallback,
  }) {
    final speed = speedMps ?? 0;
    if (speed < kVehicleBearingSpeedThresholdMps) {
      return fallback;
    }
    if (bearing == null) return fallback;
    return bearing % 360;
  }

  VehicleMarkerFrame frameAt(DateTime now) {
    final opacity = _stale ? 0.5 : 1.0;
    if (_displayLat == null || _displayLng == null) {
      return VehicleMarkerFrame(
        lat: 0,
        lng: 0,
        bearing: 0,
        opacity: opacity,
        progress: 0,
      );
    }

    if (_tweenStartedAt == null ||
        _tweenEndLat == null ||
        _tweenStartLat == null) {
      return VehicleMarkerFrame(
        lat: _displayLat!,
        lng: _displayLng!,
        bearing: _displayBearing,
        opacity: opacity,
        progress: 1,
      );
    }

    final elapsed = now.difference(_tweenStartedAt!);
    final totalMs = _tweenDuration.inMilliseconds;
    final t = totalMs <= 0
        ? 1.0
        : (elapsed.inMilliseconds / totalMs).clamp(0.0, 1.0);

    final lat = lerpDouble(_tweenStartLat!, _tweenEndLat!, t);
    final lng = lerpDouble(_tweenStartLng!, _tweenEndLng!, t);
    final bearing = lerpBearing(_tweenStartBearing, _tweenEndBearing, t);

    if (t >= 1.0) {
      _displayLat = _tweenEndLat;
      _displayLng = _tweenEndLng;
      _displayBearing = _tweenEndBearing;
      _tweenStartedAt = null;
    } else {
      _displayLat = lat;
      _displayLng = lng;
      _displayBearing = bearing;
    }

    return VehicleMarkerFrame(
      lat: lat,
      lng: lng,
      bearing: bearing,
      opacity: opacity,
      progress: t,
    );
  }
}
