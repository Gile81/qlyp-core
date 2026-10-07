import 'dart:typed_data';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'qlyp_marker_renderer.dart';

/// Mapbox style-image scale shared across QLYP map markers.
const double kQlypMapStyleImageScale = 3.0;

const int kQlypMapMarkerSizeRoutePinPx = 44;
const int kQlypMapMarkerSizePickupDropoffPx = 48;
const int kQlypMapMarkerSizeVehiclePx = 64;

/// True when [bytes] look like a PNG stream (Mapbox Android codec requirement).
bool qlypMapStyleImageBytesAreValidPng(Uint8List bytes) {
  return bytes.length >= 4 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47;
}

/// Registers a pre-rendered PNG on the Mapbox style (idempotent on duplicate id).
Future<bool> addQlypMapStyleImage(
  MapboxMap map, {
  required String id,
  required Uint8List pngBytes,
  required int sizePx,
  double scale = kQlypMapStyleImageScale,
}) async {
  if (pngBytes.isEmpty || !qlypMapStyleImageBytesAreValidPng(pngBytes)) {
    return false;
  }
  try {
    await map.style.addStyleImage(
      id,
      scale,
      MbxImage(width: sizePx, height: sizePx, data: pngBytes),
      false,
      [],
      [],
      null,
    );
    return true;
  } catch (_) {
    return false;
  }
}

/// Renders an SVG marker asset and registers it as a style image.
Future<bool> addQlypMapStyleImageFromSvgAsset(
  MapboxMap map, {
  required String id,
  required String svgAssetPath,
  required int sizePx,
  double scale = kQlypMapStyleImageScale,
}) async {
  final bytes = await QlypMarkerRenderer.renderSvgMarkerRaw(
    svgAssetPath,
    sizePx: sizePx,
  );
  return addQlypMapStyleImage(
    map,
    id: id,
    pngBytes: bytes,
    sizePx: sizePx,
    scale: scale,
  );
}
