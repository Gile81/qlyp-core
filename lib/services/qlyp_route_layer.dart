import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../constants/qlyp_colors.dart';

String _casingLayerId(String sourceId) => '$sourceId-casing';

String _lineLayerId(String sourceId) => '$sourceId-line';

List<Object> _zoomLineWidthExpression(List<double> stops) {
  return [
    'interpolate',
    ['exponential', 1.5],
    ['zoom'],
    ...stops,
  ];
}

const List<double> _mainLineWidthStops = [
  4, 1.5,
  8, 2.5,
  10, 4,
  12, 6,
  14, 9,
  16, 13,
  18, 18,
];

const List<double> _casingLineWidthStops = [
  4, 2.1,
  8, 3.5,
  10, 5.6,
  12, 8.4,
  14, 12.6,
  16, 18.2,
  18, 25.2,
];

/// Adds a QLYP-branded route line (casing + main stroke) to [map].
Future<void> addQlypRouteLine(
  MapboxMap map,
  List<Position> coordinates, {
  String sourceId = 'qlyp-route',
  double casingOpacity = 0.3,
}) async {
  if (coordinates.length < 2) {
    return;
  }

  await removeQlypRouteLine(map, sourceId: sourceId);

  final lineString = LineString(coordinates: coordinates);
  await map.style.addSource(
    GeoJsonSource(id: sourceId, data: json.encode(lineString)),
  );

  await map.style.addLayer(
    LineLayer(
      id: _casingLayerId(sourceId),
      sourceId: sourceId,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineColor: QlypColors.deepQlyp.value,
      lineOpacity: casingOpacity,
      lineWidthExpression: _zoomLineWidthExpression(_casingLineWidthStops),
    ),
  );

  await map.style.addLayer(
    LineLayer(
      id: _lineLayerId(sourceId),
      sourceId: sourceId,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineColor: QlypColors.emeraldLight.value,
      lineOpacity: 1.0,
      lineWidthExpression: _zoomLineWidthExpression(_mainLineWidthStops),
    ),
  );
}

/// Removes the QLYP route line layers and GeoJSON source from [map].
Future<void> removeQlypRouteLine(
  MapboxMap map, {
  String sourceId = 'qlyp-route',
}) async {
  final style = map.style;
  final lineLayerId = _lineLayerId(sourceId);
  final casingLayerId = _casingLayerId(sourceId);

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