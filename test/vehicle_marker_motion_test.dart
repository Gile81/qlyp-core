import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';
import 'package:qlyp_core/ride_tracking/vehicle_marker_motion.dart';

void main() {
  test('shortest bearing delta and lerp', () {
    expect(VehicleMarkerMotion.shortestBearingDelta(359, 1), closeTo(2, 0.001));
    expect(
      VehicleMarkerMotion.lerpBearing(359, 1, 0.5),
      closeTo(0, 0.001),
    );
  });

  test('clamp tween duration between 1s and 5s', () {
    expect(
      VehicleMarkerMotion.clampTweenDuration(const Duration(milliseconds: 500)),
      kDurMarkerTweenMin,
    );
    expect(
      VehicleMarkerMotion.clampTweenDuration(const Duration(seconds: 10)),
      kDurMarkerTweenMax,
    );
  });

  test('interpolation progress 0, 50, 100 percent', () {
    final motion = VehicleMarkerMotion();
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    motion.applyGpsFix(
      lat: 45.0,
      lng: -73.0,
      bearing: 0,
      speedMps: 5,
      positionAt: t0,
      disableAnimations: false,
      now: t0,
    );
    motion.applyGpsFix(
      lat: 45.001,
      lng: -73.001,
      bearing: 90,
      speedMps: 5,
      positionAt: t0.add(const Duration(seconds: 3)),
      disableAnimations: false,
      now: t0,
    );

    final start = motion.frameAt(t0);
    expect(start.progress, closeTo(0, 0.001));

    final mid = motion.frameAt(
      t0.add(const Duration(milliseconds: 1500)),
    );
    expect(mid.progress, closeTo(0.5, 0.05));
    expect(mid.lat, isNot(start.lat));

    final end = motion.frameAt(t0.add(const Duration(seconds: 4)));
    expect(end.progress, closeTo(1, 0.001));
    expect(end.lat, closeTo(45.001, 0.0001));
  });

  test('zero speed keeps bearing, teleport and disableAnimations snap', () {
    final motion = VehicleMarkerMotion();
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    motion.applyGpsFix(
      lat: 45.0,
      lng: -73.0,
      bearing: 10,
      speedMps: 0,
      positionAt: t0,
      disableAnimations: false,
      now: t0,
    );
    motion.applyGpsFix(
      lat: 45.0001,
      lng: -73.0001,
      bearing: 200,
      speedMps: 0.1,
      positionAt: t0.add(const Duration(seconds: 1)),
      disableAnimations: false,
      now: t0,
    );
    final frame = motion.frameAt(t0.add(const Duration(seconds: 2)));
    expect(frame.bearing, closeTo(10, 0.001));

    motion.applyGpsFix(
      lat: 46.0,
      lng: -74.0,
      bearing: 50,
      speedMps: 10,
      positionAt: t0.add(const Duration(seconds: 3)),
      disableAnimations: false,
      now: t0.add(const Duration(seconds: 3)),
    );
    final tele = motion.frameAt(t0.add(const Duration(seconds: 3)));
    expect(tele.lat, 46.0);
    expect(tele.progress, 1);

    motion.reset();
    motion.applyGpsFix(
      lat: 45.0,
      lng: -73.0,
      bearing: 0,
      speedMps: 5,
      positionAt: t0,
      disableAnimations: true,
      now: t0,
    );
    motion.applyGpsFix(
      lat: 45.01,
      lng: -73.01,
      bearing: 180,
      speedMps: 5,
      positionAt: t0.add(const Duration(seconds: 1)),
      disableAnimations: true,
      now: t0.add(const Duration(seconds: 1)),
    );
    final snap = motion.frameAt(t0.add(const Duration(seconds: 1)));
    expect(snap.lat, 45.01);
    expect(snap.progress, 1);
  });

  test('stale opacity is 50%', () {
    final motion = VehicleMarkerMotion();
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    motion.applyGpsFix(
      lat: 45.0,
      lng: -73.0,
      bearing: 0,
      speedMps: 5,
      positionAt: t0,
      disableAnimations: false,
      now: t0,
      stale: true,
    );
    expect(motion.frameAt(t0).opacity, 0.5);
  });

  test('reset clears state', () {
    final motion = VehicleMarkerMotion();
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    motion.applyGpsFix(
      lat: 45.0,
      lng: -73.0,
      bearing: 0,
      speedMps: 5,
      positionAt: t0,
      disableAnimations: false,
      now: t0,
    );
    motion.reset();
    expect(motion.displayLat, isNull);
  });
}
