import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'qlyp_map_style_images.dart';
import 'qlyp_service_marker_registry.dart';

/// Registers the admin tier vehicle marker as a Mapbox style image.
///
/// Returns [styleImageId] when registration succeeded, else null.
Future<String?> registerTierVehicleMapStyleImage(
  MapboxMap map, {
  required QlypServiceMarkerRegistry registry,
  required String serviceId,
  required String styleImageId,
}) async {
  final id = serviceId.trim();
  if (id.isEmpty) return null;

  final assetPath = await registry.assetPathForMarkerService(id);
  if (assetPath == null || assetPath.isEmpty) return null;

  final ok = await addQlypMapStyleImageFromSvgAsset(
    map,
    id: styleImageId,
    svgAssetPath: assetPath,
    sizePx: kQlypMapMarkerSizeVehiclePx,
  );
  return ok ? styleImageId : null;
}
