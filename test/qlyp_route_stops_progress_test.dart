import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/ride_phase.dart';
import 'package:qlyp_core/route_stops/qlyp_route_stops_progress.dart';

void main() {
  group('buildRouteStopTimelineNodes', () {
    test('empty when no intermediate addresses', () {
      expect(
        buildRouteStopTimelineNodes(
          pickupAddress: 'A',
          intermediateAddresses: const [],
          destinationAddress: 'B',
        ),
        isEmpty,
      );
    });

    test('pickup, stops, destination order', () {
      final nodes = buildRouteStopTimelineNodes(
        pickupAddress: 'Pickup',
        intermediateAddresses: const ['S1', 'S2'],
        destinationAddress: 'Dest',
      );
      expect(nodes.length, 4);
      expect(nodes.first.kind, QlypRouteStopNodeKind.pickup);
      expect(nodes[1].intermediateIndex, 0);
      expect(nodes.last.kind, QlypRouteStopNodeKind.destination);
    });
  });

  group('resolveHighlightedNodeIndex', () {
    const nodeCount = 4; // A, 1, 2, B

    test('en route highlights pickup', () {
      expect(
        resolveHighlightedNodeIndex(
          ridePhase: RidePhase.driverEnRoute,
          currentStopIndex: 0,
          liveNextStopIndex: null,
          nodeCount: nodeCount,
          readOnly: false,
        ),
        0,
      );
    });

    test('in progress highlights live next stop', () {
      expect(
        resolveHighlightedNodeIndex(
          ridePhase: RidePhase.inProgress,
          currentStopIndex: 0,
          liveNextStopIndex: 1,
          nodeCount: nodeCount,
          readOnly: false,
        ),
        2,
      );
    });

    test('read only returns null', () {
      expect(
        resolveHighlightedNodeIndex(
          ridePhase: RidePhase.inProgress,
          currentStopIndex: 0,
          liveNextStopIndex: 0,
          nodeCount: nodeCount,
          readOnly: true,
        ),
        isNull,
      );
    });
  });

  group('resolveNodeState', () {
    test('intermediate reached when currentStopIndex advanced', () {
      expect(
        resolveNodeState(
          nodeIndex: 1,
          nodeCount: 4,
          kind: QlypRouteStopNodeKind.intermediate,
          intermediateIndex: 0,
          ridePhase: RidePhase.inProgress,
          currentStopIndex: 1,
          highlightedIndex: 2,
          readOnly: false,
        ),
        QlypRouteStopNodeState.reached,
      );
    });

    test('pickup reached in progress', () {
      expect(
        resolveNodeState(
          nodeIndex: 0,
          nodeCount: 4,
          kind: QlypRouteStopNodeKind.pickup,
          intermediateIndex: null,
          ridePhase: RidePhase.inProgress,
          currentStopIndex: 0,
          highlightedIndex: 1,
          readOnly: false,
        ),
        QlypRouteStopNodeState.reached,
      );
    });
  });
}
