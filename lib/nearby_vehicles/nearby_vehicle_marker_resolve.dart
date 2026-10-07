import 'package:qlyp_core/services/qlyp_service_marker_registry.dart';

import 'nearby_vehicle_models.dart';

/// Service id used to pick the admin marker SVG for one nearby vehicle.
String nearbyVehicleMarkerServiceId({
  required String? passengerSelectedTierId,
  required String primaryServiceId,
}) {
  final selected = passengerSelectedTierId?.trim() ?? '';
  if (selected.isNotEmpty) return selected;
  return primaryServiceId.trim();
}

/// Filename from registry for [markerServiceId], else registry default.
String? nearbyVehicleMarkerFilename({
  required Map<String, String> registry,
  required String markerServiceId,
}) {
  final id = markerServiceId.trim();
  if (id.isEmpty) return QlypServiceMarkerRegistry.defaultFilename(registry);
  return registry[id] ?? QlypServiceMarkerRegistry.defaultFilename(registry);
}

/// Keeps the nearest [maxCount] vehicles within [maxRadiusMeters].
List<NearbyVehicleSnapshot> selectNearestNearbyVehicles(
  Iterable<NearbyVehicleSnapshot> vehicles, {
  required double maxRadiusMeters,
  required int maxCount,
}) {
  final filtered = vehicles
      .where((v) => v.distanceMeters <= maxRadiusMeters)
      .toList(growable: false);
  filtered.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  if (filtered.length <= maxCount) return filtered;
  return filtered.sublist(0, maxCount);
}
