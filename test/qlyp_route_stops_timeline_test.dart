import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/booking_route_stop.dart';
import 'package:qlyp_core/models/ride_live_next_stop.dart';
import 'package:qlyp_core/models/ride_phase.dart';
import 'package:qlyp_core/widgets/qlyp_route_stops_timeline.dart';

import 'widgets/design_test_helpers.dart';

const _labels = QlypRouteStopsTimelineLabels(
  pickupBadge: 'A',
  destinationBadge: 'B',
  reachedHint: 'Reached',
  nextStopEtaMinutes: '@minutes min',
);

const _stops = [
  BookingRouteStop(lat: 1, lng: 1, address: 'Stop 1'),
  BookingRouteStop(lat: 2, lng: 2, address: 'Stop 2'),
];

void main() {
  testWidgets('hidden without intermediate stops', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypRouteStopsTimeline(
          pickupAddress: 'Pickup',
          destinationAddress: 'Dest',
          intermediateStops: [],
          labels: _labels,
        ),
      ),
    );
    expect(find.text('Pickup'), findsNothing);
  });

  testWidgets('shows addresses and badges', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypRouteStopsTimeline(
          pickupAddress: 'Pickup addr',
          destinationAddress: 'Dest addr',
          intermediateStops: _stops,
          labels: _labels,
          readOnly: true,
        ),
      ),
    );
    expect(find.text('Pickup addr'), findsOneWidget);
    expect(find.text('Stop 1'), findsOneWidget);
    expect(find.text('Dest addr'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('next stop ETA when in progress', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypRouteStopsTimeline(
          pickupAddress: 'Pickup',
          destinationAddress: 'Dest',
          intermediateStops: _stops,
          labels: _labels,
          ridePhase: RidePhase.inProgress,
          currentStopIndex: 0,
          nextStop: const RideLiveNextStop(
            stopIndex: 0,
            etaSeconds: 600,
            computedAt: null,
          ),
        ),
      ),
    );
    expect(find.textContaining('min'), findsOneWidget);
  });

  testWidgets('dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(),
          child: Scaffold(
            body: const QlypRouteStopsTimeline(
              pickupAddress: 'P',
              destinationAddress: 'D',
              intermediateStops: [
                BookingRouteStop(lat: 0, lng: 0, address: 'Mid'),
              ],
              labels: _labels,
              ridePhase: RidePhase.driverEnRoute,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Mid'), findsOneWidget);
  });
}
