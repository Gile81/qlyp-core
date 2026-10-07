import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qlyp_core/models/booking_route_stop.dart';
import 'package:qlyp_core/services/qlyp_booking_route_markers.dart';
import 'package:qlyp_core/services/qlyp_map_mode_controller.dart';
import 'package:qlyp_core/services/qlyp_map_point_annotations.dart';
import 'package:qlyp_core/services/qlyp_map_style_images.dart';

/// Style id for pickup (A) on a booking preview map.
String bookingRoutePickupStyleId(String prefix) => '${prefix}_a';

/// Style id for destination (B) on a booking preview map.
String bookingRouteDestinationStyleId(String prefix) => '${prefix}_b';

String bookingRouteStopStyleId(String prefix, int index) =>
    '${prefix}_stop_$index';

/// Registers A/B/1..N style images for a multi-stop booking route preview.
Future<void> registerBookingRouteMarkerStyleImages(
  MapboxMap map, {
  required String styleIdPrefix,
  required int intermediateStopCount,
  bool? nightMode,
}) async {
  final night = nightMode ?? (qlypMapLightPreset(map) != 'day');
  await _ensureLabelStyle(
    map,
    styleId: bookingRoutePickupStyleId(styleIdPrefix),
    label: bookingRouteMarkerLabel(BookingRouteMarkerRole.pickup),
    nightMode: night,
  );
  await _ensureLabelStyle(
    map,
    styleId: bookingRouteDestinationStyleId(styleIdPrefix),
    label: bookingRouteMarkerLabel(BookingRouteMarkerRole.destination),
    nightMode: night,
  );
  for (var i = 0; i < intermediateStopCount; i++) {
    await _ensureLabelStyle(
      map,
      styleId: bookingRouteStopStyleId(styleIdPrefix, i),
      label: bookingRouteMarkerLabel(
        BookingRouteMarkerRole.intermediateStop,
        stopIndex: i,
      ),
      nightMode: night,
    );
  }
}

Future<void> _ensureLabelStyle(
  MapboxMap map, {
  required String styleId,
  required String label,
  required bool nightMode,
}) async {
  final bytes = await renderBookingRouteMarkerPng(
    label: label,
    nightMode: nightMode,
    sizePx: kQlypMapMarkerSizeRoutePinPx,
  );
  await addQlypMapStyleImage(
    map,
    id: styleId,
    pngBytes: bytes,
    sizePx: kQlypMapMarkerSizeRoutePinPx,
  );
}

/// Places pickup, intermediate stops, and destination markers on the map.
Future<Set<String>> placeBookingRoutePointMarkers(
  QlypMapPointAnnotationController annotations, {
  required String styleIdPrefix,
  required double srcLat,
  required double srcLng,
  required double dstLat,
  required double dstLng,
  required List<BookingRouteStop> intermediateStops,
}) async {
  final stopKeys = <String>{};
  await annotations.upsert(
    key: 'source',
    lat: srcLat,
    lng: srcLng,
    iconImage: bookingRoutePickupStyleId(styleIdPrefix),
  );
  for (var i = 0; i < intermediateStops.length; i++) {
    final stop = intermediateStops[i];
    final key = 'route_stop_$i';
    stopKeys.add(key);
    await annotations.upsert(
      key: key,
      lat: stop.lat,
      lng: stop.lng,
      iconImage: bookingRouteStopStyleId(styleIdPrefix, i),
    );
  }
  await annotations.upsert(
    key: 'destination',
    lat: dstLat,
    lng: dstLng,
    iconImage: bookingRouteDestinationStyleId(styleIdPrefix),
  );
  return stopKeys;
}
