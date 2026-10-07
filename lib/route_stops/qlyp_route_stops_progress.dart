import '../models/ride_phase.dart';

enum QlypRouteStopNodeState {
  upcoming,
  current,
  reached,
}

enum QlypRouteStopNodeKind {
  pickup,
  intermediate,
  destination,
}

class QlypRouteStopTimelineNode {
  const QlypRouteStopTimelineNode({
    required this.kind,
    required this.address,
    this.intermediateIndex,
  });

  final QlypRouteStopNodeKind kind;
  final String address;
  final int? intermediateIndex;
}

List<QlypRouteStopTimelineNode> buildRouteStopTimelineNodes({
  required String pickupAddress,
  required List<String> intermediateAddresses,
  required String destinationAddress,
}) {
  if (intermediateAddresses.isEmpty) return const [];
  final nodes = <QlypRouteStopTimelineNode>[
    QlypRouteStopTimelineNode(
      kind: QlypRouteStopNodeKind.pickup,
      address: pickupAddress,
    ),
  ];
  for (var i = 0; i < intermediateAddresses.length; i++) {
    nodes.add(
      QlypRouteStopTimelineNode(
        kind: QlypRouteStopNodeKind.intermediate,
        address: intermediateAddresses[i],
        intermediateIndex: i,
      ),
    );
  }
  nodes.add(
    QlypRouteStopTimelineNode(
      kind: QlypRouteStopNodeKind.destination,
      address: destinationAddress,
    ),
  );
  return nodes;
}

int intermediateCountFromNodeCount(int nodeCount) {
  if (nodeCount < 2) return 0;
  return nodeCount - 2;
}

int? resolveHighlightedNodeIndex({
  required RidePhase? ridePhase,
  required int currentStopIndex,
  required int? liveNextStopIndex,
  required int nodeCount,
  required bool readOnly,
}) {
  if (readOnly || nodeCount <= 0) return null;
  switch (ridePhase) {
    case RidePhase.driverEnRoute:
    case RidePhase.driverArrived:
      return 0;
    case RidePhase.inProgress:
      if (liveNextStopIndex != null) {
        final idx = 1 + liveNextStopIndex;
        if (idx >= 0 && idx < nodeCount) return idx;
      }
      if (currentStopIndex >= intermediateCountFromNodeCount(nodeCount)) {
        return nodeCount - 1;
      }
      return 1 + currentStopIndex;
    case RidePhase.completed:
    case RidePhase.canceled:
    case null:
      return null;
  }
}

QlypRouteStopNodeState resolveNodeState({
  required int nodeIndex,
  required int nodeCount,
  required QlypRouteStopNodeKind kind,
  required int? intermediateIndex,
  required RidePhase? ridePhase,
  required int currentStopIndex,
  required int? highlightedIndex,
  required bool readOnly,
}) {
  if (readOnly) {
    return QlypRouteStopNodeState.reached;
  }

  if (kind == QlypRouteStopNodeKind.pickup) {
    final reached = ridePhase == RidePhase.inProgress ||
        ridePhase == RidePhase.completed;
    if (reached) return QlypRouteStopNodeState.reached;
    if (nodeIndex == highlightedIndex) return QlypRouteStopNodeState.current;
    return QlypRouteStopNodeState.upcoming;
  }

  if (kind == QlypRouteStopNodeKind.intermediate && intermediateIndex != null) {
    if (currentStopIndex > intermediateIndex) {
      return QlypRouteStopNodeState.reached;
    }
    if (nodeIndex == highlightedIndex) return QlypRouteStopNodeState.current;
    return QlypRouteStopNodeState.upcoming;
  }

  if (kind == QlypRouteStopNodeKind.destination) {
    if (ridePhase == RidePhase.completed) {
      return QlypRouteStopNodeState.reached;
    }
    if (nodeIndex == highlightedIndex) return QlypRouteStopNodeState.current;
    return QlypRouteStopNodeState.upcoming;
  }

  return QlypRouteStopNodeState.upcoming;
}
