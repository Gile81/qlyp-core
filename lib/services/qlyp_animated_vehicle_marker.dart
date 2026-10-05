import 'dart:async';
import 'dart:convert';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../constants/qlyp_motion.dart';
import '../models/ride_live_driver.dart';
import '../ride_tracking/vehicle_marker_motion.dart';

const String _defaultVehicleSourceId = 'qlyp-live-vehicle';
const String _defaultVehicleLayerId = 'qlyp-live-vehicle-symbol';

/// Animated driver marker on a [MapboxMap] (GeoJSON source + [SymbolLayer]).
///
/// Updates the source at ~30 fps via [kDurMarkerFrame] to limit native channel traffic.
class QlypAnimatedVehicleMarker {
  QlypAnimatedVehicleMarker({
    required MapboxMap map,
    this.sourceId = _defaultVehicleSourceId,
    this.layerId = _defaultVehicleLayerId,
  })  : _map = map,
        _motion = VehicleMarkerMotion();

  final MapboxMap _map;
  final VehicleMarkerMotion _motion;
  Timer? _frameTimer;
  bool _attached = false;
  String? _iconImage;
  bool _disableAnimations = false;

  final String sourceId;
  final String layerId;

  VehicleMarkerMotion get motion => _motion;

  Future<void> attach({required String iconImage}) async {
    if (_attached) return;
    _iconImage = iconImage;
    final style = _map.style;
    if (!await style.styleSourceExists(sourceId)) {
      await style.addSource(
        GeoJsonSource(
          id: sourceId,
          data: json.encode(_emptyPointFeatureCollection()),
        ),
      );
    }
    if (!await style.styleLayerExists(layerId)) {
      await style.addLayer(
        SymbolLayer(
          id: layerId,
          sourceId: sourceId,
          iconImage: iconImage,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconAnchor: IconAnchor.CENTER,
          iconRotationAlignment: IconRotationAlignment.MAP,
          iconPitchAlignment: IconPitchAlignment.MAP,
        ),
      );
    }
    _attached = true;
    _startFramePump();
  }

  void setDisableAnimations(bool value) {
    _disableAnimations = value;
  }

  Future<void> setIconImage(String iconImage) async {
    _iconImage = iconImage;
    if (!_attached) return;
    if (await _map.style.styleLayerExists(layerId)) {
      await _map.style.setStyleLayerProperty(layerId, 'icon-image', iconImage);
    }
  }

  void updateFromDriver(RideLiveDriver driver, {DateTime? now}) {
    if (!driver.hasPosition) return;
    final clock = now ?? DateTime.now();
    _motion.applyGpsFix(
      lat: driver.lat!,
      lng: driver.lng!,
      bearing: driver.bearing,
      speedMps: driver.speedMps,
      positionAt: driver.positionAt,
      disableAnimations: _disableAnimations,
      now: clock,
      stale: driver.isStale(now: clock),
    );
    unawaited(_pushFrame(clock));
  }

  void updatePosition({
    required double lat,
    required double lng,
    double? bearing,
    double? speedMps,
    DateTime? positionAt,
    bool stale = false,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    _motion.applyGpsFix(
      lat: lat,
      lng: lng,
      bearing: bearing,
      speedMps: speedMps,
      positionAt: positionAt,
      disableAnimations: _disableAnimations,
      now: clock,
      stale: stale,
    );
    unawaited(_pushFrame(clock));
  }

  void _startFramePump() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(kDurMarkerFrame, (_) {
      unawaited(_pushFrame(DateTime.now()));
    });
  }

  Future<void> _pushFrame(DateTime now) async {
    if (!_attached || _iconImage == null) return;
    final frame = _motion.frameAt(now);
    if (_motion.displayLat == null) return;

    final feature = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [frame.lng, frame.lat],
          },
          'properties': {
            'bearing': frame.bearing,
          },
        },
      ],
    };

    final style = _map.style;
    if (!await style.styleSourceExists(sourceId)) return;

    await style.setStyleSourceProperty(
      sourceId,
      'data',
      json.encode(feature),
    );

    if (await style.styleLayerExists(layerId)) {
      await style.setStyleLayerProperty(
        layerId,
        'icon-rotate',
        frame.bearing,
      );
      await style.setStyleLayerProperty(
        layerId,
        'icon-opacity',
        frame.opacity,
      );
    }
  }

  Map<String, Object> _emptyPointFeatureCollection() => {
        'type': 'FeatureCollection',
        'features': <Object>[],
      };

  Future<void> dispose() async {
    _frameTimer?.cancel();
    _frameTimer = null;
    _motion.reset();

    if (!_attached) return;
    final style = _map.style;
    if (await style.styleLayerExists(layerId)) {
      await style.removeStyleLayer(layerId);
    }
    if (await style.styleSourceExists(sourceId)) {
      await style.removeStyleSource(sourceId);
    }
    _attached = false;
  }
}
