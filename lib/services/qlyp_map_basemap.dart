import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const Map<String, String> kQlypBgByPreset = {
  'day': '#F4F7FA',
  'night': '#0E1F2F',
};

const Map<String, String> kQlypWaterByPreset = {
  'day': '#B8D4E8',
  'night': '#0C1C2E',
};

const Map<String, String> kQlypParksByPreset = {
  'day': '#CCDFC8',
  'night': '#0E2A1C',
};

/// Pushes the QLYP custom-layer colours for [preset] (`day` | `night`).
Future<void> applyQlypLayerColors(MapboxMap map, String preset) async {
  try {
    await map.style.setStyleLayerProperty(
      'qlyp-bg',
      'background-color',
      kQlypBgByPreset[preset] ?? kQlypBgByPreset['day']!,
    );
    await map.style.setStyleLayerProperty(
      'qlyp-water',
      'fill-color',
      kQlypWaterByPreset[preset] ?? kQlypWaterByPreset['day']!,
    );
    await map.style.setStyleLayerProperty(
      'qlyp-parks',
      'fill-color',
      kQlypParksByPreset[preset] ?? kQlypParksByPreset['day']!,
    );
  } catch (e) {
    debugPrint('applyQlypLayerColors[$preset]: $e');
  }
}
