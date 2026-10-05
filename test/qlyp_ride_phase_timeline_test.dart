import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/ride_phase.dart';
import 'package:qlyp_core/widgets/qlyp_ride_phase_timeline.dart';

import 'widgets/design_test_helpers.dart';

const _labelsFr = QlypRidePhaseTimelineLabels(
  enRoute: 'En route',
  arrivedPickup: 'Arrivé',
  inProgress: 'En course',
  arrivedDestination: 'Destination',
);

const _labelsEn = QlypRidePhaseTimelineLabels(
  enRoute: 'On the way',
  arrivedPickup: 'Arrived',
  inProgress: 'In ride',
  arrivedDestination: 'Drop-off',
);

void main() {
  testWidgets('timeline shows FR labels for each phase', (tester) async {
    for (final phase in [
      RidePhase.driverEnRoute,
      RidePhase.driverArrived,
      RidePhase.inProgress,
      RidePhase.completed,
    ]) {
      await tester.pumpWidget(
        wrapDesignTest(
          child: QlypRidePhaseTimeline(phase: phase, labels: _labelsFr),
        ),
      );
      expect(find.text('En route'), findsOneWidget);
      expect(find.text('Destination'), findsOneWidget);
    }
  });

  testWidgets('timeline EN locale labels', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: const QlypRidePhaseTimeline(
          phase: RidePhase.inProgress,
          labels: _labelsEn,
        ),
      ),
    );
    expect(find.text('In ride'), findsOneWidget);
  });

  testWidgets('timeline dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(),
          child: Scaffold(
            body: QlypRidePhaseTimeline(
              phase: RidePhase.driverEnRoute,
              labels: _labelsFr,
            ),
          ),
        ),
      ),
    );
    expect(find.text('En route'), findsOneWidget);
  });

  testWidgets('timeline reduce motion', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: const QlypRidePhaseTimeline(
          phase: RidePhase.driverArrived,
          labels: _labelsFr,
        ),
      ),
    );
    expect(find.text('Arrivé'), findsOneWidget);
  });
}
