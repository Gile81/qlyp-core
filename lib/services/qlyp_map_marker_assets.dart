import 'map_service.dart';

/// Package-qualified SVG paths for standard QLYP map markers.
abstract final class QlypMapMarkerAssets {
  static const String pickupPin = '${QlypMapService.markersPath}/pickup_pin.svg';
  static const String dropoffPin = '${QlypMapService.markersPath}/dropoff_pin.svg';
  static const String customerPin = '${QlypMapService.markersPath}/customer_pin.svg';
  static const String pickerPin = '${QlypMapService.markersPath}/picker_pin.svg';
}
