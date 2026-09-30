/// Server-backed models for Qlyp Route trip search (S4-R2).
class RouteTripPlaceLabel {
  const RouteTripPlaceLabel({required this.label});

  final String label;

  factory RouteTripPlaceLabel.fromJson(Map<String, dynamic>? json) =>
      RouteTripPlaceLabel(label: json?['label']?.toString() ?? '');
}

class RouteTripLatLngLabel {
  const RouteTripLatLngLabel({
    required this.lat,
    required this.lng,
    required this.label,
  });

  final double lat;
  final double lng;
  final String label;

  factory RouteTripLatLngLabel.fromJson(Map<String, dynamic> json) =>
      RouteTripLatLngLabel(
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        label: json['label']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'label': label,
      };
}

class RouteTripDriverSummary {
  const RouteTripDriverSummary({
    required this.firstName,
    required this.lastInitial,
    required this.photoUrl,
    required this.ratingAvg,
    required this.ratingCount,
    required this.verified,
  });

  final String firstName;
  final String lastInitial;
  final String photoUrl;
  final double? ratingAvg;
  final int ratingCount;
  final bool verified;

  factory RouteTripDriverSummary.fromJson(Map<String, dynamic>? json) =>
      RouteTripDriverSummary(
        firstName: json?['firstName']?.toString() ?? '',
        lastInitial: json?['lastInitial']?.toString() ?? '',
        photoUrl: json?['photoUrl']?.toString() ?? '',
        ratingAvg: (json?['ratingAvg'] as num?)?.toDouble(),
        ratingCount: (json?['ratingCount'] as num?)?.toInt() ?? 0,
        verified: json?['verified'] == true,
      );
}

class RouteTripVehicleSummary {
  const RouteTripVehicleSummary({
    required this.make,
    required this.model,
    required this.color,
  });

  final String make;
  final String model;
  final String color;

  factory RouteTripVehicleSummary.fromJson(Map<String, dynamic>? json) =>
      RouteTripVehicleSummary(
        make: json?['make']?.toString() ?? '',
        model: json?['model']?.toString() ?? '',
        color: json?['color']?.toString() ?? '',
      );
}

class RouteTripPreferences {
  const RouteTripPreferences({
    required this.smoking,
    required this.luggage,
    required this.animals,
  });

  final bool smoking;
  final bool luggage;
  final bool animals;

  factory RouteTripPreferences.fromJson(Map<String, dynamic>? json) =>
      RouteTripPreferences(
        smoking: json?['smoking'] == true,
        luggage: json?['luggage'] != false,
        animals: json?['animals'] == true,
      );
}

enum RouteSearchSort { departure, price, rating }

RouteSearchSort routeSearchSortFromApi(String? raw) {
  switch (raw) {
    case 'price':
      return RouteSearchSort.price;
    case 'rating':
      return RouteSearchSort.rating;
    default:
      return RouteSearchSort.departure;
  }
}

String routeSearchSortToApi(RouteSearchSort sort) {
  switch (sort) {
    case RouteSearchSort.price:
      return 'price';
    case RouteSearchSort.rating:
      return 'rating';
    case RouteSearchSort.departure:
      return 'departure';
  }
}

class RouteSearchFilters {
  const RouteSearchFilters({
    this.smoking = false,
    this.luggage = false,
    this.animals = false,
    this.maxTotalPrice,
  });

  final bool smoking;
  final bool luggage;
  final bool animals;
  final double? maxTotalPrice;

  RouteSearchFilters copyWith({
    bool? smoking,
    bool? luggage,
    bool? animals,
    double? maxTotalPrice,
    bool clearMaxTotalPrice = false,
  }) =>
      RouteSearchFilters(
        smoking: smoking ?? this.smoking,
        luggage: luggage ?? this.luggage,
        animals: animals ?? this.animals,
        maxTotalPrice:
            clearMaxTotalPrice ? null : (maxTotalPrice ?? this.maxTotalPrice),
      );

  Map<String, dynamic> toApiPayload() {
    final map = <String, dynamic>{};
    if (smoking) map['smoking'] = true;
    if (luggage) map['luggage'] = true;
    if (animals) map['animals'] = true;
    if (maxTotalPrice != null && maxTotalPrice! > 0) {
      map['maxTotalPrice'] = maxTotalPrice;
    }
    return map;
  }

  bool get isEmpty =>
      !smoking && !luggage && !animals && (maxTotalPrice == null || maxTotalPrice! <= 0);
}

class RouteTripSearchResult {
  const RouteTripSearchResult({
    required this.tripId,
    required this.departureAt,
    required this.durationMin,
    required this.origin,
    required this.destination,
    required this.pickupPoint,
    required this.pickupDetourKm,
    required this.dropoffDetourKm,
    required this.seatsAvailable,
    required this.pricePerPassengerNow,
    required this.bookingFeePerPassenger,
    required this.totalPerPassenger,
    required this.totalForRequest,
    required this.pricePerSeatIfFull,
    required this.priceMayDrop,
    required this.seatPriceToDriver,
    required this.instantBook,
    required this.preferences,
    required this.driver,
    required this.vehicle,
  });

  final String tripId;
  final DateTime departureAt;
  final int durationMin;
  final RouteTripPlaceLabel origin;
  final RouteTripPlaceLabel destination;
  final RouteTripLatLngLabel pickupPoint;
  final double pickupDetourKm;
  final double dropoffDetourKm;
  final int seatsAvailable;
  final double pricePerPassengerNow;
  final double bookingFeePerPassenger;
  final double totalPerPassenger;
  final double totalForRequest;
  final double pricePerSeatIfFull;
  final bool priceMayDrop;
  final double seatPriceToDriver;
  final bool instantBook;
  final RouteTripPreferences preferences;
  final RouteTripDriverSummary driver;
  final RouteTripVehicleSummary vehicle;

  factory RouteTripSearchResult.fromJson(Map<String, dynamic> json) {
    return RouteTripSearchResult(
      tripId: json['tripId']?.toString() ?? '',
      departureAt: DateTime.tryParse(json['departureAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
      origin: RouteTripPlaceLabel.fromJson(
        Map<String, dynamic>.from(json['origin'] as Map? ?? {}),
      ),
      destination: RouteTripPlaceLabel.fromJson(
        Map<String, dynamic>.from(json['destination'] as Map? ?? {}),
      ),
      pickupPoint: RouteTripLatLngLabel.fromJson(
        Map<String, dynamic>.from(json['pickupPoint'] as Map? ?? {}),
      ),
      pickupDetourKm: (json['pickupDetourKm'] as num?)?.toDouble() ?? 0,
      dropoffDetourKm: (json['dropoffDetourKm'] as num?)?.toDouble() ?? 0,
      seatsAvailable: (json['seatsAvailable'] as num?)?.toInt() ?? 0,
      pricePerPassengerNow:
          (json['pricePerPassengerNow'] as num?)?.toDouble() ?? 0,
      bookingFeePerPassenger:
          (json['bookingFeePerPassenger'] as num?)?.toDouble() ?? 0,
      totalPerPassenger: (json['totalPerPassenger'] as num?)?.toDouble() ?? 0,
      totalForRequest: (json['totalForRequest'] as num?)?.toDouble() ?? 0,
      pricePerSeatIfFull: (json['pricePerSeatIfFull'] as num?)?.toDouble() ?? 0,
      priceMayDrop: json['priceMayDrop'] == true,
      seatPriceToDriver: (json['seatPriceToDriver'] as num?)?.toDouble() ?? 0,
      instantBook: json['instantBook'] == true,
      preferences: RouteTripPreferences.fromJson(
        Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
      ),
      driver: RouteTripDriverSummary.fromJson(
        Map<String, dynamic>.from(json['driver'] as Map? ?? {}),
      ),
      vehicle: RouteTripVehicleSummary.fromJson(
        Map<String, dynamic>.from(json['vehicle'] as Map? ?? {}),
      ),
    );
  }
}

class RouteTripDetail extends RouteTripSearchResult {
  const RouteTripDetail({
    required super.tripId,
    required super.departureAt,
    required super.durationMin,
    required super.origin,
    required super.destination,
    required super.pickupPoint,
    required super.pickupDetourKm,
    required super.dropoffDetourKm,
    required super.seatsAvailable,
    required super.pricePerPassengerNow,
    required super.bookingFeePerPassenger,
    required super.totalPerPassenger,
    required super.totalForRequest,
    required super.pricePerSeatIfFull,
    required super.priceMayDrop,
    required super.seatPriceToDriver,
    required super.instantBook,
    required super.preferences,
    required super.driver,
    required super.vehicle,
    required this.routePolyline,
    required this.waypoints,
    required this.pickupPoints,
    required this.priceBySeatsBooked,
    required this.cancellationPolicyFr,
    required this.cancellationPolicyEn,
  });

  final String routePolyline;
  final List<RouteTripLatLngLabel> waypoints;
  final List<RouteTripLatLngLabel> pickupPoints;
  final List<double> priceBySeatsBooked;
  final String cancellationPolicyFr;
  final String cancellationPolicyEn;

  factory RouteTripDetail.fromJson(Map<String, dynamic> json) {
    final base = RouteTripSearchResult.fromJson(json);
    return RouteTripDetail(
      tripId: base.tripId,
      departureAt: base.departureAt,
      durationMin: base.durationMin,
      origin: base.origin,
      destination: base.destination,
      pickupPoint: base.pickupPoint,
      pickupDetourKm: base.pickupDetourKm,
      dropoffDetourKm: base.dropoffDetourKm,
      seatsAvailable: base.seatsAvailable,
      pricePerPassengerNow: base.pricePerPassengerNow,
      bookingFeePerPassenger: base.bookingFeePerPassenger,
      totalPerPassenger: base.totalPerPassenger,
      totalForRequest: base.totalForRequest,
      pricePerSeatIfFull: base.pricePerSeatIfFull,
      priceMayDrop: base.priceMayDrop,
      seatPriceToDriver: base.seatPriceToDriver,
      instantBook: base.instantBook,
      preferences: base.preferences,
      driver: base.driver,
      vehicle: base.vehicle,
      routePolyline: json['routePolyline']?.toString() ?? '',
      waypoints: _parsePoints(json['waypoints']),
      pickupPoints: _parsePoints(json['pickupPoints']),
      priceBySeatsBooked: (json['priceBySeatsBooked'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      cancellationPolicyFr: json['cancellationPolicyFr']?.toString() ?? '',
      cancellationPolicyEn: json['cancellationPolicyEn']?.toString() ?? '',
    );
  }

  String cancellationPolicyForLanguage(String languageCode) {
    final useFr = languageCode.toLowerCase().startsWith('fr');
    if (useFr && cancellationPolicyFr.isNotEmpty) return cancellationPolicyFr;
    if (cancellationPolicyEn.isNotEmpty) return cancellationPolicyEn;
    return cancellationPolicyFr;
  }
}

List<RouteTripLatLngLabel> _parsePoints(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) {
        if (e is! Map) return null;
        return RouteTripLatLngLabel.fromJson(Map<String, dynamic>.from(e));
      })
      .whereType<RouteTripLatLngLabel>()
      .toList();
}

class RouteTripSearchResponse {
  const RouteTripSearchResponse({required this.results});

  final List<RouteTripSearchResult> results;

  factory RouteTripSearchResponse.fromJson(Map<String, dynamic> json) =>
      RouteTripSearchResponse(
        results: (json['results'] as List<dynamic>? ?? [])
            .map((e) => RouteTripSearchResult.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList(),
      );
}
