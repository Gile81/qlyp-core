class PassengerPublicProfile {
  PassengerPublicProfile({
    required this.passengerId,
    this.firstName,
    this.profilePic,
    this.ratingAvg,
    this.reviewsCount,
  });

  final String passengerId;
  final String? firstName;
  final String? profilePic;
  final double? ratingAvg;
  final int? reviewsCount;

  factory PassengerPublicProfile.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    final avgRaw = json['ratingAvg'];
    final countRaw = json['reviewsCount'];
    return PassengerPublicProfile(
      passengerId: id,
      firstName: json['firstName']?.toString(),
      profilePic: json['profilePic']?.toString(),
      ratingAvg: avgRaw is num ? avgRaw.toDouble() : double.tryParse('$avgRaw'),
      reviewsCount: countRaw is num
          ? countRaw.toInt()
          : int.tryParse('$countRaw'),
    );
  }

  String get displayFirstName {
    final name = (firstName ?? '').trim();
    return name.isEmpty ? 'Passager' : name;
  }

  String get ratingLabel {
    if (ratingAvg == null) return '—';
    return ratingAvg!.toStringAsFixed(1);
  }
}
