import 'dart:typed_data';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'qlyp_map_marker_assets.dart';
import 'qlyp_map_style_images.dart';
import 'qlyp_marker_renderer.dart';

/// Preloads pickup/dropoff SVG markers for Mapbox style registration.
class QlypPickupDropoffMarkerBytes {
  QlypPickupDropoffMarkerBytes({
    Uint8List? pickup,
    Uint8List? dropoff,
  })  : pickup = pickup ?? Uint8List(0),
        dropoff = dropoff ?? Uint8List(0);

  final Uint8List pickup;
  final Uint8List dropoff;

  static Future<QlypPickupDropoffMarkerBytes> load() async {
    return QlypPickupDropoffMarkerBytes(
      pickup: await QlypMarkerRenderer.renderSvgMarkerRaw(
        QlypMapMarkerAssets.pickupPin,
        sizePx: kQlypMapMarkerSizePickupDropoffPx,
      ),
      dropoff: await QlypMarkerRenderer.renderSvgMarkerRaw(
        QlypMapMarkerAssets.dropoffPin,
        sizePx: kQlypMapMarkerSizePickupDropoffPx,
      ),
    );
  }

  Future<void> registerOnMap(
    MapboxMap map, {
    required String pickupStyleId,
    required String dropoffStyleId,
  }) async {
    await addQlypMapStyleImage(
      map,
      id: pickupStyleId,
      pngBytes: pickup,
      sizePx: kQlypMapMarkerSizePickupDropoffPx,
    );
    await addQlypMapStyleImage(
      map,
      id: dropoffStyleId,
      pngBytes: dropoff,
      sizePx: kQlypMapMarkerSizePickupDropoffPx,
    );
  }
}
