import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/ride_tracking_contract.dart';
import 'package:qlyp_core/models/ride_live_next_stop.dart';

void main() {
  test('fromLiveDriverMap absent index yields empty', () {
    expect(RideLiveNextStop.fromLiveDriverMap(const {}), const RideLiveNextStop());
  });

  test('parses next stop ETA fields', () {
    final parsed = RideLiveNextStop.fromLiveDriverMap({
      RideTrackingContract.fieldNextStopIndex: 1,
      RideTrackingContract.fieldNextStopEtaSeconds: 240,
      RideTrackingContract.fieldNextStopDistanceMeters: 1500,
    });
    expect(parsed.stopIndex, 1);
    expect(parsed.etaSeconds, 240);
    expect(parsed.hasEta, isTrue);
  });

  test('remainingSeconds ticks down from computedAt', () {
    final at = DateTime.utc(2026, 1, 1, 12, 0, 0);
    final next = RideLiveNextStop(
      stopIndex: 0,
      etaSeconds: 120,
      computedAt: at,
    );
    expect(
      next.remainingSeconds(now: at.add(const Duration(seconds: 30))),
      90,
    );
  });
}
