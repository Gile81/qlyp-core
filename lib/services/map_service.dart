enum MapProvider {
  google,
  osm,
}

class MapModel {
  List<String>? destinationAddresses;
  List<String>? originAddresses;
  List<Rows>? rows;
  String? status;
  String? errorMessage;

  MapModel({
    this.destinationAddresses,
    this.originAddresses,
    this.rows,
    this.status,
    this.errorMessage,
  });

  MapModel.fromJson(Map<String, dynamic> json) {
    destinationAddresses = json['destination_addresses'].cast<String>();
    originAddresses = json['origin_addresses'].cast<String>();
    if (json['rows'] != null) {
      rows = <Rows>[];
      json['rows'].forEach((v) {
        rows!.add(Rows.fromJson(v));
      });
    }
    status = json['status'];
    errorMessage = json['error_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['destination_addresses'] = destinationAddresses;
    data['origin_addresses'] = originAddresses;
    data['error_message'] = errorMessage;
    if (rows != null) {
      data['rows'] = rows!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Rows {
  List<Elements>? elements;

  Rows({this.elements});

  Rows.fromJson(Map<String, dynamic> json) {
    if (json['elements'] != null) {
      elements = <Elements>[];
      json['elements'].forEach((v) {
        elements!.add(Elements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (elements != null) {
      data['elements'] = elements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Elements {
  Distance? distance;
  Duration? duration;
  String? status;

  Elements({this.distance, this.duration, this.status});

  Elements.fromJson(Map<String, dynamic> json) {
    distance =
        json['distance'] != null ? Distance.fromJson(json['distance']) : null;
    duration =
        json['duration'] != null ? Duration.fromJson(json['duration']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (distance != null) {
      data['distance'] = distance!.toJson();
    }
    if (duration != null) {
      data['duration'] = duration!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class Distance {
  String? text;
  int? value;

  Distance({this.text, this.value});

  Distance.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['value'] = value;
    return data;
  }
}

class Duration {
  String? text;
  int? value;

  Duration({this.text, this.value});

  Duration.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['value'] = value;
    return data;
  }
}

/// Shared map configuration and asset paths.
/// Mapbox styles are not implemented — see `assets/styles/` (empty).
class QlypMapService {
  const QlypMapService._();

  static const String mapTypeGoogle = 'google';
  static const String mapTypeOsm = 'osm';
  static const String selectedMapTypeOsm = 'osm';

  static const String packageAssetPrefix = 'packages/qlyp_core/assets';
  static const String markersPath = '$packageAssetPrefix/markers';

  /// Vehicle map marker SVGs (admin-configurable via service_markers).
  static const String markerSedanDark = '$markersPath/sedan_dark.svg';
  static const String markerSedanBlue = '$markersPath/sedan_blue.svg';
  static const String markerSedanViolet = '$markersPath/sedan_violet.svg';
  static const String markerSedanViolet2 = '$markersPath/sedan_violet_2.svg';
  static const String markerSedanViolet3 = '$markersPath/sedan_violet_3.svg';
  static const String markerSuvBlack = '$markersPath/suv_black.svg';
  static const String markerSuvBlue = '$markersPath/suv_blue.svg';
  static const String markerSuvGrey = '$markersPath/suv_grey.svg';
  static const String markerSuvWhite = '$markersPath/suv_white.svg';
  static const String markerTowViolet = '$markersPath/tow_violet.svg';
  static const String markerTowViolet2 = '$markersPath/tow_violet_2.svg';
  static const String markerTruckCargo = '$markersPath/truck_cargo.svg';
  static const String markerTruckCube = '$markersPath/truck_cube.svg';
  static const String markerVanCreamEv = '$markersPath/van_cream_ev.svg';
  static const String markerVanMint = '$markersPath/van_mint.svg';
  static const String markerVanMint2 = '$markersPath/van_mint_2.svg';
  static const String markerVanWhiteEv = '$markersPath/van_white_ev.svg';
  static const String markerWagonViolet = '$markersPath/wagon_violet.svg';
  static const String markerWagonViolet2 = '$markersPath/wagon_violet_2.svg';

  static const List<String> allVehicleMarkers = [
    markerSedanDark,
    markerSedanBlue,
    markerSedanViolet,
    markerSedanViolet2,
    markerSedanViolet3,
    markerSuvBlack,
    markerSuvBlue,
    markerSuvGrey,
    markerSuvWhite,
    markerTowViolet,
    markerTowViolet2,
    markerTruckCargo,
    markerTruckCube,
    markerVanCreamEv,
    markerVanMint,
    markerVanMint2,
    markerVanWhiteEv,
    markerWagonViolet,
    markerWagonViolet2,
  ];

  static MapProvider providerFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'osm':
        return MapProvider.osm;
      case 'google':
      default:
        return MapProvider.google;
    }
  }

  static String providerToString(MapProvider provider) {
    switch (provider) {
      case MapProvider.osm:
        return mapTypeOsm;
      case MapProvider.google:
        return mapTypeGoogle;
    }
  }
}
