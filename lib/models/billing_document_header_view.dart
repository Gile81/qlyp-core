import 'billing_map_helpers.dart';

class BillingDocumentHeaderView {
  const BillingDocumentHeaderView({
    this.passengerName,
    this.driverDisplayName,
    this.driverRating,
    this.routeFrom,
    this.routeTo,
    this.distanceKm,
    this.durationMinutes,
    this.pillarLabelFr,
    this.pillarLabelEn,
    this.tierLabelFr,
    this.tierLabelEn,
    this.priceTypeLabelFr,
    this.priceTypeLabelEn,
    this.billingDescriptorFr,
    this.billingDescriptorEn,
    this.issuedLocalDate,
    this.issuedLocalTime,
  });

  final String? passengerName;
  final String? driverDisplayName;
  final double? driverRating;
  final String? routeFrom;
  final String? routeTo;
  final double? distanceKm;
  final int? durationMinutes;
  final String? pillarLabelFr;
  final String? pillarLabelEn;
  final String? tierLabelFr;
  final String? tierLabelEn;
  final String? priceTypeLabelFr;
  final String? priceTypeLabelEn;
  final String? billingDescriptorFr;
  final String? billingDescriptorEn;
  final String? issuedLocalDate;
  final String? issuedLocalTime;

  factory BillingDocumentHeaderView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingDocumentHeaderView();
    }
    return BillingDocumentHeaderView(
      passengerName: billingOptionalString(raw['passenger_name']),
      driverDisplayName: billingOptionalString(raw['driver_display_name']),
      driverRating: billingAsDouble(raw['driver_rating']),
      routeFrom: billingOptionalString(raw['route_from']),
      routeTo: billingOptionalString(raw['route_to']),
      distanceKm: billingAsDouble(raw['distance_km']),
      durationMinutes: billingAsDouble(raw['duration_minutes'])?.round(),
      pillarLabelFr: billingOptionalString(raw['pillar_label_fr']),
      pillarLabelEn: billingOptionalString(raw['pillar_label_en']),
      tierLabelFr: billingOptionalString(raw['tier_label_fr']),
      tierLabelEn: billingOptionalString(raw['tier_label_en']),
      priceTypeLabelFr: billingOptionalString(raw['price_type_label_fr']),
      priceTypeLabelEn: billingOptionalString(raw['price_type_label_en']),
      billingDescriptorFr: billingOptionalString(raw['billing_descriptor_fr']),
      billingDescriptorEn: billingOptionalString(raw['billing_descriptor_en']),
      issuedLocalDate: billingOptionalString(raw['issued_local_date']),
      issuedLocalTime: billingOptionalString(raw['issued_local_time']),
    );
  }

  String pillarLabelForLanguage(String languageCode) {
    return billingLabelForLanguage(
      languageCode: languageCode,
      labelFr: pillarLabelFr ?? '',
      labelEn: pillarLabelEn ?? '',
    );
  }
}
