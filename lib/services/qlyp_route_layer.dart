import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'qlyp_map_view.dart';
import 'qlyp_route_flow_animator.dart';

String _casingLayerId(String sourceId) => '$sourceId-casing';

String _lineLayerId(String sourceId) => '$sourceId-line';

String _flowLayerId(String sourceId) => '$sourceId-flow';

List<Object> _zoomLineWidthExpression(List<double> stops) {
  return [
    'interpolate',
    ['exponential', 1.5],
    ['zoom'],
    ...stops,
  ];
}

/// Visual weight of the route polyline.
///
/// [preview] — booking card / home preview (~35% thinner than legacy, Uber-like).
///   Includes the animated emerald → blue flow pulse (pickup → dropoff).
/// [navigation] — live tracking / driver nav (slightly thicker, static line).
enum QlypRouteLineProfile {
  preview,
  navigation,
}

// Legacy widths (pre Sep 2026) — kept for navigation profile reference.
const List<double> _legacyMainLineWidthStops = [
  4, 1.5,
  8, 2.5,
  10, 4,
  12, 6,
  14, 9,
  16, 13,
  18, 18,
];

const List<double> _legacyCasingLineWidthStops = [
  4, 2.1,
  8, 3.5,
  10, 5.6,
  12, 8.4,
  14, 12.6,
  16, 18.2,
  18, 25.2,
];

List<double> _scaleWidthStops(List<double> stops, double factor) {
  final scaled = <double>[];
  for (var i = 0; i < stops.length; i++) {
    scaled.add(i.isOdd ? stops[i] * factor : stops[i]);
  }
  return scaled;
}

const List<double> _mainLineWidthStopsPreview =
    // 0.65× legacy — matches Uber/Lyft booking preview thinness.
    [
  4, 0.975,
  8, 1.625,
  10, 2.6,
  12, 3.9,
  14, 5.85,
  16, 8.45,
  18, 11.7,
];

const List<double> _casingLineWidthStopsPreview = [
  4, 1.365,
  8, 2.275,
  10, 3.64,
  12, 5.46,
  14, 8.19,
  16, 11.83,
  18, 16.38,
];

final List<double> _mainLineWidthStopsNavigation =
    _scaleWidthStops(_legacyMainLineWidthStops, 0.9);

final List<double> _casingLineWidthStopsNavigation =
    _scaleWidthStops(_legacyCasingLineWidthStops, 0.9);

({List<double> main, List<double> casing}) _widthStopsForProfile(
  QlypRouteLineProfile profile,
) {
  switch (profile) {
    case QlypRouteLineProfile.preview:
      return (main: _mainLineWidthStopsPreview, casing: _casingLineWidthStopsPreview);
    case QlypRouteLineProfile.navigation:
      return (
        main: _mainLineWidthStopsNavigation,
        casing: _casingLineWidthStopsNavigation,
      );
  }
}

bool _flowEnabledForProfile(QlypRouteLineProfile profile) =>
    profile == QlypRouteLineProfile.preview;

/// Paint tokens for route lines per Mapbox light preset.
class QlypRoutePaint {
  const QlypRoutePaint({
    required this.casingColor,
    required this.casingOpacity,
    required this.lineColor,
    required this.lineOpacity,
    this.lineEmissiveStrength,
    this.casingEmissiveStrength,
  });

  final int casingColor;
  final double casingOpacity;
  final int lineColor;
  final double lineOpacity;
  final double? lineEmissiveStrength;
  final double? casingEmissiveStrength;
}

const int _kEmeraldRoute = 0xFF27D96B;
const int _kDeepQlypRoute = 0xFF0E1F2F;
const int _kMidnightMidRoute = 0xFF1F3E63;

/// Emerald route colours tuned per light preset (PRD: night visibility on #152838).
QlypRoutePaint qlypRoutePaintForPreset(
  String lightPreset, {
  QlypRouteLineProfile profile = QlypRouteLineProfile.preview,
}) {
  final flowEnabled = _flowEnabledForProfile(profile);
  switch (lightPreset) {
    case 'night':
      return QlypRoutePaint(
        casingColor: _kMidnightMidRoute,
        casingOpacity: 0.72,
        lineColor: _kEmeraldRoute,
        lineOpacity: 1.0,
        lineEmissiveStrength: 1.0,
        casingEmissiveStrength: 0.35,
      );
    case 'dusk':
      return QlypRoutePaint(
        casingColor: _kDeepQlypRoute,
        casingOpacity: 0.42,
        lineColor: _kEmeraldRoute,
        lineOpacity: flowEnabled ? 0.82 : 1.0,
        lineEmissiveStrength: 0.45,
      );
    default:
      return QlypRoutePaint(
        casingColor: _kDeepQlypRoute,
        casingOpacity: 0.3,
        lineColor: _kEmeraldRoute,
        lineOpacity: flowEnabled ? 0.72 : 1.0,
      );
  }
}

/// Adds a QLYP-branded route line (casing + main stroke) to [map].
///
/// When [profile] is [QlypRouteLineProfile.preview], a traveling pulse overlay
/// (emerald → blue, pickup → dropoff, ~2.5 s loop) is drawn on top.
///
/// [lightPreset] defaults to the preset registered on [map] by [QlypMapView],
/// or [qlypLightPresetForTime] when the map was created outside [QlypMapView].
Future<void> addQlypRouteLine(
  MapboxMap map,
  List<Position> coordinates, {
  String sourceId = 'qlyp-route',
  double? casingOpacity,
  QlypRouteLineProfile profile = QlypRouteLineProfile.preview,
  String? lightPreset,
}) async {
  if (coordinates.length < 2) {
    return;
  }

  final preset = lightPreset ?? qlypMapLightPreset(map);
  final paint = qlypRoutePaintForPreset(preset, profile: profile);
  final resolvedCasingOpacity = casingOpacity ?? paint.casingOpacity;

  final widthStops = _widthStopsForProfile(profile);
  final flowEnabled = _flowEnabledForProfile(profile);

  await removeQlypRouteLine(map, sourceId: sourceId);

  final lineString = LineString(coordinates: coordinates);
  await map.style.addSource(
    GeoJsonSource(
      id: sourceId,
      data: json.encode(lineString),
      lineMetrics: flowEnabled,
    ),
  );

  await map.style.addLayer(
    LineLayer(
      id: _casingLayerId(sourceId),
      sourceId: sourceId,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineColor: paint.casingColor,
      lineOpacity: resolvedCasingOpacity,
      lineEmissiveStrength: paint.casingEmissiveStrength,
      lineWidthExpression:
          _zoomLineWidthExpression(widthStops.casing),
    ),
  );

  await map.style.addLayer(
    LineLayer(
      id: _lineLayerId(sourceId),
      sourceId: sourceId,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineColor: paint.lineColor,
      lineOpacity: paint.lineOpacity,
      lineEmissiveStrength: paint.lineEmissiveStrength,
      lineWidthExpression: _zoomLineWidthExpression(widthStops.main),
    ),
  );

  if (flowEnabled) {
    final flowLayerId = _flowLayerId(sourceId);
    await map.style.addLayer(
      LineLayer(
        id: flowLayerId,
        sourceId: sourceId,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
        lineWidthExpression: _zoomLineWidthExpression(widthStops.main),
        lineGradientExpression:
            buildQlypFlowGradientExpression(0, lightPreset: preset),
      ),
    );
    startQlypRouteFlowAnimator(
      map: map,
      sourceId: sourceId,
      layerId: flowLayerId,
      lightPreset: preset,
    );
  }
}

/// Removes the QLYP route line layers and GeoJSON source from [map].
Future<void> removeQlypRouteLine(
  MapboxMap map, {
  String sourceId = 'qlyp-route',
}) async {
  stopQlypRouteFlowAnimator(map, sourceId);

  final style = map.style;
  final lineLayerId = _lineLayerId(sourceId);
  final casingLayerId = _casingLayerId(sourceId);
  final flowLayerId = _flowLayerId(sourceId);

  if (await style.styleLayerExists(flowLayerId)) {
    await style.removeStyleLayer(flowLayerId);
  }
  if (await style.styleLayerExists(lineLayerId)) {
    await style.removeStyleLayer(lineLayerId);
  }
  if (await style.styleLayerExists(casingLayerId)) {
    await style.removeStyleLayer(casingLayerId);
  }
  if (await style.styleSourceExists(sourceId)) {
    await style.removeStyleSource(sourceId);
  }
}

/// Animates the camera to fit all [coordinates] with [padding].
Future<void> fitQlypRouteBounds(
  MapboxMap map,
  List<Position> coordinates, {
  EdgeInsets padding = const EdgeInsets.all(48),
}) async {
  if (coordinates.isEmpty) {
    return;
  }

  var minLng = coordinates.first.lng.toDouble();
  var maxLng = minLng;
  var minLat = coordinates.first.lat.toDouble();
  var maxLat = minLat;

  for (final coordinate in coordinates) {
    final lng = coordinate.lng.toDouble();
    final lat = coordinate.lat.toDouble();
    if (lng < minLng) minLng = lng;
    if (lng > maxLng) maxLng = lng;
    if (lat < minLat) minLat = lat;
    if (lat > maxLat) maxLat = lat;
  }

  final bounds = CoordinateBounds(
    southwest: Point(coordinates: Position(minLng, minLat)),
    northeast: Point(coordinates: Position(maxLng, maxLat)),
    infiniteBounds: false,
  );

  final camera = await map.cameraForCoordinateBounds(
    bounds,
    MbxEdgeInsets(
      top: padding.top,
      left: padding.left,
      bottom: padding.bottom,
      right: padding.right,
    ),
    null,
    null,
    null,
    null,
  );

  await map.flyTo(camera, MapAnimationOptions(duration: 1000));
}
