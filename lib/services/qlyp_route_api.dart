import 'package:cloud_functions/cloud_functions.dart';
import 'package:qlyp_core/models/route_booking_models.dart';
import 'package:qlyp_core/models/route_trip_search_models.dart';
import 'package:qlyp_core/services/qlyp_firebase_functions.dart';

class RouteDocumentIssue {
  const RouteDocumentIssue({
    required this.documentId,
    required this.titleFr,
    required this.titleEn,
  });

  final String documentId;
  final String titleFr;
  final String titleEn;

  factory RouteDocumentIssue.fromJson(Map<String, dynamic> json) =>
      RouteDocumentIssue(
        documentId: json['documentId']?.toString() ?? '',
        titleFr: json['title_fr']?.toString() ?? '',
        titleEn: json['title_en']?.toString() ?? '',
      );
}

class RouteDriverStatus {
  const RouteDriverStatus({
    required this.eligible,
    required this.pillarStatus,
    required this.missingDocuments,
    required this.expiredDocuments,
  });

  final bool eligible;
  final String? pillarStatus;
  final List<RouteDocumentIssue> missingDocuments;
  final List<RouteDocumentIssue> expiredDocuments;

  factory RouteDriverStatus.fromJson(Map<String, dynamic> json) =>
      RouteDriverStatus(
        eligible: json['eligible'] == true,
        pillarStatus: json['pillarStatus']?.toString(),
        missingDocuments: (json['missingDocuments'] as List<dynamic>? ?? [])
            .map((e) => RouteDocumentIssue.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        expiredDocuments: (json['expiredDocuments'] as List<dynamic>? ?? [])
            .map((e) => RouteDocumentIssue.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class RouteTripQuote {
  const RouteTripQuote({
    required this.distanceKm,
    required this.durationMin,
    required this.zoneId,
    required this.suggestedPricePerSeat,
    required this.maxPricePerSeat,
    required this.bookingFee,
    required this.seatPriceToDriver,
    required this.pricePerSeatIfFull,
    required this.priceBySeatsBooked,
    required this.legalTotalCap,
    required this.commissionPct,
    required this.routePolyline,
  });

  final double distanceKm;
  final int durationMin;
  final String zoneId;
  final double suggestedPricePerSeat;
  final double maxPricePerSeat;
  final double bookingFee;
  final double seatPriceToDriver;
  final double pricePerSeatIfFull;
  final List<double> priceBySeatsBooked;
  final double legalTotalCap;
  final double commissionPct;
  final String routePolyline;

  factory RouteTripQuote.fromJson(Map<String, dynamic> json) => RouteTripQuote(
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
        zoneId: json['zoneId']?.toString() ?? '',
        suggestedPricePerSeat:
            (json['suggestedPricePerSeat'] as num?)?.toDouble() ?? 0,
        maxPricePerSeat: (json['maxPricePerSeat'] as num?)?.toDouble() ?? 0,
        bookingFee: (json['bookingFee'] as num?)?.toDouble() ?? 0,
        seatPriceToDriver:
            (json['seatPriceToDriver'] as num?)?.toDouble() ?? 0,
        pricePerSeatIfFull:
            (json['pricePerSeatIfFull'] as num?)?.toDouble() ?? 0,
        priceBySeatsBooked: (json['priceBySeatsBooked'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
        legalTotalCap: (json['legalTotalCap'] as num?)?.toDouble() ?? 0,
        commissionPct: (json['commissionPct'] as num?)?.toDouble() ?? 0.15,
        routePolyline: json['routePolyline']?.toString() ?? '',
      );
}

class QlypRouteApiException implements Exception {
  QlypRouteApiException(this.message, {this.reason});

  final String message;
  final String? reason;

  @override
  String toString() => message;
}

class QlypRouteApi {
  QlypRouteApi({FirebaseFunctions? functions, this.languageCode = 'fr'})
      : _functions = functions ?? getQlypFunctions();

  final FirebaseFunctions _functions;
  final String languageCode;

  Future<T> _call<T>(
    String name,
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic> json) parse,
  ) async {
    try {
      final result = await _functions.httpsCallable(name).call(data ?? {});
      final raw = result.data;
      if (raw is Map) {
        return parse(Map<String, dynamic>.from(raw));
      }
      throw QlypRouteApiException('Invalid response');
    } on FirebaseFunctionsException catch (e) {
      throw QlypRouteApiException(
        _localizedMessage(e),
        reason: _reason(e),
      );
    }
  }

  String _localizedMessage(FirebaseFunctionsException e) {
    final details = e.details;
    if (details is Map) {
      final map = Map<String, dynamic>.from(details);
      final fr = map['message_fr']?.toString();
      final en = map['message_en']?.toString();
      final useFr = languageCode.toLowerCase().startsWith('fr');
      if (useFr && fr != null && fr.isNotEmpty) return fr;
      if (en != null && en.isNotEmpty) return en;
      if (fr != null && fr.isNotEmpty) return fr;
    }
    return e.message ?? 'Route error';
  }

  String? _reason(FirebaseFunctionsException e) {
    final details = e.details;
    if (details is Map) {
      return Map<String, dynamic>.from(details)['reason']?.toString();
    }
    return null;
  }

  Future<RouteDriverStatus> getRouteDriverStatus() => _call(
        'getRouteDriverStatus',
        null,
        RouteDriverStatus.fromJson,
      );

  Future<RouteDriverStatus> startRouteDriverProfile() => _call(
        'startRouteDriverProfile',
        null,
        RouteDriverStatus.fromJson,
      );

  Future<RouteDriverStatus> submitRouteDocument({
    required String documentId,
    required String frontImagePath,
    String? backImagePath,
    String? expireAtIso,
  }) =>
      _call(
        'submitRouteDocument',
        {
          'documentId': documentId,
          'frontImagePath': frontImagePath,
          if (backImagePath != null) 'backImagePath': backImagePath,
          if (expireAtIso != null) 'expireAt': expireAtIso,
        },
        RouteDriverStatus.fromJson,
      );

  Future<RouteTripQuote> quoteRouteTrip(Map<String, dynamic> payload) => _call(
        'quoteRouteTrip',
        payload,
        RouteTripQuote.fromJson,
      );

  Future<String> publishRouteTrip(Map<String, dynamic> payload) async {
    final map = await _call(
      'publishRouteTrip',
      payload,
      (json) => json,
    );
    return map['tripId']?.toString() ?? '';
  }

  Future<void> cancelRouteTrip({required String tripId, required String reason}) async {
    try {
      await _functions.httpsCallable('cancelRouteTrip').call({
        'tripId': tripId,
        'reason': reason,
      });
    } on FirebaseFunctionsException catch (e) {
      throw QlypRouteApiException(_localizedMessage(e), reason: _reason(e));
    }
  }

  Future<RouteTripSearchResponse> searchRouteTrips(
    Map<String, dynamic> payload,
  ) =>
      _call(
        'searchRouteTrips',
        payload,
        RouteTripSearchResponse.fromJson,
      );

  Future<RouteTripDetail> getRouteTripDetail(Map<String, dynamic> payload) =>
      _call(
        'getRouteTripDetail',
        payload,
        RouteTripDetail.fromJson,
      );

  Future<RouteBookSeatResult> bookRouteSeat(Map<String, dynamic> payload) =>
      _call(
        'bookRouteSeat',
        payload,
        RouteBookSeatResult.fromJson,
      );

  Future<RouteBookingPaymentConfirmResult> confirmRouteBookingPayment({
    required String bookingId,
  }) =>
      _call(
        'confirmRouteBookingPayment',
        {'bookingId': bookingId},
        RouteBookingPaymentConfirmResult.fromJson,
      );

  Future<RouteBookingRespondResult> respondRouteBooking({
    required String bookingId,
    required bool accept,
  }) =>
      _call(
        'respondRouteBooking',
        {'bookingId': bookingId, 'accept': accept},
        RouteBookingRespondResult.fromJson,
      );

  Future<RouteBookingCancelResult> cancelRouteBooking({
    required String bookingId,
    String? reason,
  }) =>
      _call(
        'cancelRouteBooking',
        {
          'bookingId': bookingId,
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
        RouteBookingCancelResult.fromJson,
      );

  Future<RouteBookingNoShowResult> reportRouteNoShow({
    required String bookingId,
  }) =>
      _call(
        'reportRouteNoShow',
        {'bookingId': bookingId},
        RouteBookingNoShowResult.fromJson,
      );
}
