import 'package:intl/intl.dart';

import '../constants/ride_tracking_contract.dart';
import '../utils/ride_tracking_parse.dart';

enum RideEtaTarget {
  pickup,
  dropoff,
}

RideEtaTarget? rideEtaTargetFromWire(Object? raw) {
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) return null;
  switch (value) {
    case RideTrackingContract.etaTargetPickup:
      return RideEtaTarget.pickup;
    case RideTrackingContract.etaTargetDropoff:
      return RideEtaTarget.dropoff;
    default:
      return null;
  }
}

/// Server ETA snapshot with local countdown between Firestore updates.
class RideEta {
  const RideEta({
    this.etaSeconds,
    this.distanceMeters,
    this.target,
    this.computedAt,
  });

  final int? etaSeconds;
  final int? distanceMeters;
  final RideEtaTarget? target;
  final DateTime? computedAt;

  factory RideEta.fromMap(Map<String, dynamic> map) {
    final seconds = map[RideTrackingContract.fieldEtaSeconds];
    final distance = map[RideTrackingContract.fieldDistanceMeters];
    return RideEta(
      etaSeconds: seconds is num ? seconds.round() : int.tryParse('$seconds'),
      distanceMeters:
          distance is num ? distance.round() : int.tryParse('$distance'),
      target: rideEtaTargetFromWire(map[RideTrackingContract.fieldEtaTarget]),
      computedAt: rideTrackingTimestamp(
        map[RideTrackingContract.fieldEtaComputedAt],
      ),
    );
  }

  /// Seconds remaining, ticking down locally from [computedAt].
  int remainingSeconds({DateTime? now}) {
    if (etaSeconds == null || computedAt == null) return etaSeconds ?? 0;
    final clock = now ?? DateTime.now();
    final elapsed = clock.difference(computedAt!).inSeconds;
    final left = etaSeconds! - elapsed;
    return left < 0 ? 0 : left;
  }

  /// Whole minutes remaining (ceil), minimum 0.
  int remainingMinutesRounded({DateTime? now}) {
    final seconds = remainingSeconds(now: now);
    if (seconds <= 0) return 0;
    return (seconds + 59) ~/ 60;
  }

  DateTime? arrivalTime({DateTime? now}) {
    final seconds = remainingSeconds(now: now);
    if (computedAt == null && etaSeconds == null) return null;
    final base = now ?? DateTime.now();
    return base.add(Duration(seconds: seconds));
  }

  /// FR: « Arrivée 18 h 32 » — EN: « Arrival 6:32 PM » (prefix supplied by app).
  String formatArrivalClock({required bool french, DateTime? now}) {
    final arrival = arrivalTime(now: now);
    if (arrival == null) return '';
    if (french) {
      return DateFormat("HH 'h' mm", 'fr_CA').format(arrival.toLocal());
    }
    return DateFormat.jm('en_CA').format(arrival.toLocal());
  }
}
