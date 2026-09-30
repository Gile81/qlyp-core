/// Server-backed models for Qlyp Route seat booking (S4-R3b).

class RouteBookSeatResult {
  const RouteBookSeatResult({
    required this.bookingId,
    required this.status,
    required this.pricePerPassenger,
    required this.bookingFeeTotal,
    this.clientSecret,
    this.guestLinkUrl,
    this.respondByAt,
  });

  final String bookingId;
  final String status;
  final double pricePerPassenger;
  final double bookingFeeTotal;
  final String? clientSecret;
  final String? guestLinkUrl;
  final DateTime? respondByAt;

  factory RouteBookSeatResult.fromJson(Map<String, dynamic> json) {
    final respondRaw = json['respondByAt']?.toString();
    return RouteBookSeatResult(
      bookingId: json['bookingId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      pricePerPassenger: (json['pricePerPassenger'] as num?)?.toDouble() ?? 0,
      bookingFeeTotal: (json['bookingFeeTotal'] as num?)?.toDouble() ?? 0,
      clientSecret: json['clientSecret']?.toString(),
      guestLinkUrl: json['guestLinkUrl']?.toString(),
      respondByAt: respondRaw != null && respondRaw.isNotEmpty
          ? DateTime.tryParse(respondRaw)
          : null,
    );
  }
}

class RouteBookingPaymentConfirmResult {
  const RouteBookingPaymentConfirmResult({
    required this.bookingId,
    required this.status,
  });

  final String bookingId;
  final String status;

  factory RouteBookingPaymentConfirmResult.fromJson(Map<String, dynamic> json) =>
      RouteBookingPaymentConfirmResult(
        bookingId: json['bookingId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );
}

class RouteBookingRespondResult {
  const RouteBookingRespondResult({
    required this.bookingId,
    required this.status,
  });

  final String bookingId;
  final String status;

  factory RouteBookingRespondResult.fromJson(Map<String, dynamic> json) =>
      RouteBookingRespondResult(
        bookingId: json['bookingId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );
}

class RouteBookingCancelResult {
  const RouteBookingCancelResult({
    required this.bookingId,
    required this.status,
    required this.refundedAmount,
    required this.refundPolicyApplied,
  });

  final String bookingId;
  final String status;
  final double refundedAmount;
  final String refundPolicyApplied;

  factory RouteBookingCancelResult.fromJson(Map<String, dynamic> json) =>
      RouteBookingCancelResult(
        bookingId: json['bookingId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        refundedAmount: (json['refundedAmount'] as num?)?.toDouble() ?? 0,
        refundPolicyApplied: json['refundPolicyApplied']?.toString() ?? '',
      );
}

class RouteBookingNoShowResult {
  const RouteBookingNoShowResult({
    required this.bookingId,
    required this.status,
  });

  final String bookingId;
  final String status;

  factory RouteBookingNoShowResult.fromJson(Map<String, dynamic> json) =>
      RouteBookingNoShowResult(
        bookingId: json['bookingId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );
}


class RouteArrivalConfirmResult {
  const RouteArrivalConfirmResult({
    required this.bookingId,
    required this.status,
    required this.completed,
  });

  final String bookingId;
  final String status;
  final bool completed;

  factory RouteArrivalConfirmResult.fromJson(Map<String, dynamic> json) =>
      RouteArrivalConfirmResult(
        bookingId: json['bookingId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        completed: json['completed'] == true,
      );
}

class RouteRatingSubmitResult {
  const RouteRatingSubmitResult({required this.bookingId, required this.ratingId});

  final String bookingId;
  final String ratingId;

  factory RouteRatingSubmitResult.fromJson(Map<String, dynamic> json) =>
      RouteRatingSubmitResult(
        bookingId: json['bookingId']?.toString() ?? '',
        ratingId: json['ratingId']?.toString() ?? '',
      );
}
