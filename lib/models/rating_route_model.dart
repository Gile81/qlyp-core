/// Type de notation Qlyp Route (bidirectionnelle).
class QlypRouteRatingType {
  const QlypRouteRatingType._();
  static const String driverRating = 'driver_rating';
  static const String passengerRating = 'passenger_rating';
}

/// Document Firestore `ratings_route`. Voir PRD Master section 21.9.
class RatingRouteModel {
  static const String collectionPath = 'ratings_route';

  final String id;
  final String tripId;
  final String raterId;
  final String ratedId;
  final int score; // 1-5
  final String comment;
  final String type; // QlypRouteRatingType

  const RatingRouteModel({
    required this.id, required this.tripId, required this.raterId,
    required this.ratedId, required this.score, required this.comment,
    required this.type,
  });

  factory RatingRouteModel.fromJson(String id, Map<String, dynamic> json) => RatingRouteModel(
    id: id,
    tripId: json['trip_id'] ?? '',
    raterId: json['rater_id'] ?? '',
    ratedId: json['rated_id'] ?? '',
    score: json['score'] ?? 0,
    comment: json['comment'] ?? '',
    type: json['type'] ?? QlypRouteRatingType.driverRating,
  );

  Map<String, dynamic> toJson() => {
    'trip_id': tripId,
    'rater_id': raterId,
    'rated_id': ratedId,
    'score': score,
    'comment': comment,
    'type': type,
  };
}