import 'package:cloud_firestore/cloud_firestore.dart';

/// Base vehicle fields identical in both client and pilote driver models.
class VehicleInformation {
  Timestamp? registrationDate;
  String? vehicleColor;
  String? vehicleNumber;
  String? seats;

  VehicleInformation({
    this.registrationDate,
    this.vehicleColor,
    this.vehicleNumber,
    this.seats,
  });

  VehicleInformation.fromJson(Map<String, dynamic> json) {
    registrationDate = json['registrationDate'];
    vehicleColor = json['vehicleColor'];
    vehicleNumber = json['vehicleNumber'];
    seats = json['seats'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['registrationDate'] = registrationDate;
    data['vehicleColor'] = vehicleColor;
    data['vehicleNumber'] = vehicleNumber;
    data['seats'] = seats;
    return data;
  }
}

/// Per-zone rate model — identical in both apps.
class RateModel {
  String? acPerKmRate;
  String? nonAcPerKmRate;
  String? perKmRate;
  String? zoneId;

  RateModel({
    this.acPerKmRate,
    this.nonAcPerKmRate,
    this.perKmRate,
    this.zoneId,
  });

  RateModel.fromJson(Map<String, dynamic> json) {
    acPerKmRate = json['acPerKmRate'];
    nonAcPerKmRate = json['nonAcPerKmRate'];
    perKmRate = json['perKmRate'];
    zoneId = json['zoneId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['acPerKmRate'] = acPerKmRate;
    data['nonAcPerKmRate'] = nonAcPerKmRate;
    data['perKmRate'] = perKmRate;
    data['zoneId'] = zoneId;
    return data;
  }
}
