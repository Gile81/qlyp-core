import '../constants/ride_tracking_contract.dart';
import '../utils/ride_tracking_parse.dart';

/// Parsed next intermediate stop ETA from `orders/{id}/live/driver` (S6-3).
class RideLiveNextStop {
  const RideLiveNextStop({
    this.stopIndex,
    this.etaSeconds,
    this.distanceMeters,
    this.computedAt,
  });

  final int? stopIndex;
  final int? etaSeconds;
  final int? distanceMeters;
  final DateTime? computedAt;

  bool get hasEta =>
      stopIndex != null && etaSeconds != null && etaSeconds! > 0;

  factory RideLiveNextStop.fromLiveDriverMap(Map<String, dynamic> map) {
    final rawIndex = map[RideTrackingContract.fieldNextStopIndex];
    int? index;
    if (rawIndex is num) {
      index = rawIndex.round();
    } else if (rawIndex != null) {
      index = int.tryParse(rawIndex.toString());
    }

    final secondsRaw = map[RideTrackingContract.fieldNextStopEtaSeconds];
    int? seconds;
    if (secondsRaw is num) {
      seconds = secondsRaw.round();
    } else if (secondsRaw != null) {
      seconds = int.tryParse(secondsRaw.toString());
    }

    final distanceRaw = map[RideTrackingContract.fieldNextStopDistanceMeters];
    int? distance;
    if (distanceRaw is num) {
      distance = distanceRaw.round();
    } else if (distanceRaw != null) {
      distance = int.tryParse(distanceRaw.toString());
    }

    if (index == null) {
      return const RideLiveNextStop();
    }

    return RideLiveNextStop(
      stopIndex: index,
      etaSeconds: seconds,
      distanceMeters: distance,
      computedAt: rideTrackingTimestamp(
        map[RideTrackingContract.fieldNextStopEtaComputedAt],
      ),
    );
  }

  int remainingSeconds({DateTime? now}) {
    if (etaSeconds == null) return 0;
    if (computedAt == null) return etaSeconds!;
    final clock = now ?? DateTime.now();
    final elapsed = clock.difference(computedAt!).inSeconds;
    final left = etaSeconds! - elapsed;
    return left < 0 ? 0 : left;
  }

  int remainingMinutesRounded({DateTime? now}) {
    final seconds = remainingSeconds(now: now);
    if (seconds <= 0) return 0;
    return (seconds + 59) ~/ 60;
  }
}
