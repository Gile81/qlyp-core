import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../models/booking_route_stop.dart';
import '../models/ride_live_next_stop.dart';
import '../models/ride_phase.dart';
import '../route_stops/qlyp_route_stops_progress.dart';

/// Host-supplied copy (FR/EN via GetX or intl in the app).
class QlypRouteStopsTimelineLabels {
  const QlypRouteStopsTimelineLabels({
    required this.pickupBadge,
    required this.destinationBadge,
    required this.reachedHint,
    required this.nextStopEtaMinutes,
  });

  final String pickupBadge;
  final String destinationBadge;

  /// Shown when a node is reached (accessibility / subtle label).
  final String reachedHint;

  /// Template with `@minutes` for next-stop ETA during the ride.
  final String nextStopEtaMinutes;

  String intermediateBadge(int zeroBasedIndex) => '${zeroBasedIndex + 1}';
}

/// Vertical A → 1… → B timeline for multi-stop rides (S6-2d).
class QlypRouteStopsTimeline extends StatelessWidget {
  const QlypRouteStopsTimeline({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.intermediateStops,
    required this.labels,
    this.ridePhase,
    this.currentStopIndex = 0,
    this.nextStop,
    this.readOnly = false,
    this.compact = false,
  });

  final String pickupAddress;
  final String destinationAddress;
  final List<BookingRouteStop> intermediateStops;
  final QlypRouteStopsTimelineLabels labels;
  final RidePhase? ridePhase;
  final int currentStopIndex;
  final RideLiveNextStop? nextStop;
  final bool readOnly;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (intermediateStops.isEmpty) {
      return const SizedBox.shrink();
    }

    final nodes = buildRouteStopTimelineNodes(
      pickupAddress: pickupAddress,
      intermediateAddresses:
          intermediateStops.map((s) => s.address).toList(growable: false),
      destinationAddress: destinationAddress,
    );
    if (nodes.isEmpty) return const SizedBox.shrink();

    final highlighted = resolveHighlightedNodeIndex(
      ridePhase: ridePhase,
      currentStopIndex: currentStopIndex,
      liveNextStopIndex: nextStop?.stopIndex,
      nodeCount: nodes.length,
      readOnly: readOnly,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final duration = disableAnimations ? Duration.zero : kDurOverlay;

    final showNextEta = !readOnly &&
        ridePhase == RidePhase.inProgress &&
        nextStop != null &&
        nextStop!.hasEta &&
        highlighted != null &&
        highlighted > 0 &&
        highlighted < nodes.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < nodes.length; i++) ...[
          _NodeRow(
            node: nodes[i],
            state: resolveNodeState(
              nodeIndex: i,
              nodeCount: nodes.length,
              kind: nodes[i].kind,
              intermediateIndex: nodes[i].intermediateIndex,
              ridePhase: ridePhase,
              currentStopIndex: currentStopIndex,
              highlightedIndex: highlighted,
              readOnly: readOnly,
            ),
            badge: _badgeFor(nodes[i]),
            isFirst: i == 0,
            isLast: i == nodes.length - 1,
            isDark: isDark,
            duration: duration,
            reachedHint: labels.reachedHint,
            compact: compact,
          ),
          if (showNextEta &&
              i == highlighted &&
              nodes[i].kind == QlypRouteStopNodeKind.intermediate)
            Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 6, top: 2),
              child: Text(
                labels.nextStopEtaMinutes.replaceAll(
                  '@minutes',
                  '${nextStop!.remainingMinutesRounded()}',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? QlypColors.emeraldLight
                          : QlypColors.emeraldDark,
                    ),
              ),
            ),
        ],
      ],
    );
  }

  String _badgeFor(QlypRouteStopTimelineNode node) {
    switch (node.kind) {
      case QlypRouteStopNodeKind.pickup:
        return labels.pickupBadge;
      case QlypRouteStopNodeKind.destination:
        return labels.destinationBadge;
      case QlypRouteStopNodeKind.intermediate:
        return labels.intermediateBadge(node.intermediateIndex ?? 0);
    }
  }
}

class _NodeRow extends StatelessWidget {
  const _NodeRow({
    required this.node,
    required this.state,
    required this.badge,
    required this.isFirst,
    required this.isLast,
    required this.isDark,
    required this.duration,
    required this.reachedHint,
    required this.compact,
  });

  final QlypRouteStopTimelineNode node;
  final QlypRouteStopNodeState state;
  final String badge;
  final bool isFirst;
  final bool isLast;
  final bool isDark;
  final Duration duration;
  final String reachedHint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final inactive =
        isDark ? QlypColors.onDarkSecondary : QlypColors.gray;
    const active = QlypColors.emerald;

    Color dotFill;
    Color dotRing;
    switch (state) {
      case QlypRouteStopNodeState.reached:
        dotFill = active;
        dotRing = active.withValues(alpha: 0.35);
        break;
      case QlypRouteStopNodeState.current:
        dotFill = active;
        dotRing = active.withValues(alpha: 0.55);
        break;
      case QlypRouteStopNodeState.upcoming:
        dotFill = isDark ? QlypColors.midnightMid : QlypColors.grayLight;
        dotRing = inactive.withValues(alpha: 0.4);
        break;
    }

    final textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight:
              state == QlypRouteStopNodeState.current ? FontWeight.w700 : FontWeight.w500,
          color: state == QlypRouteStopNodeState.upcoming
              ? inactive
              : (isDark ? QlypColors.onDarkPrimary : QlypColors.midnightQlyp),
        );

    final lineColor = state == QlypRouteStopNodeState.upcoming
        ? inactive.withValues(alpha: 0.35)
        : active.withValues(alpha: isDark ? 0.75 : 0.65);

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 4 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (!isFirst)
                  AnimatedContainer(
                    duration: duration,
                    curve: kQlypSpring,
                    width: 2,
                    height: compact ? 8 : 10,
                    color: lineColor,
                  ),
                AnimatedContainer(
                  duration: duration,
                  curve: kQlypSpring,
                  width: state == QlypRouteStopNodeState.current ? 22 : 18,
                  height: state == QlypRouteStopNodeState.current ? 22 : 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotFill,
                    border: Border.all(color: dotRing, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: compact ? 9 : 10,
                      fontWeight: FontWeight.w800,
                      color: state == QlypRouteStopNodeState.upcoming
                          ? inactive
                          : QlypColors.white,
                    ),
                  ),
                ),
                if (!isLast)
                  AnimatedContainer(
                    duration: duration,
                    curve: kQlypSpring,
                    width: 2,
                    height: compact ? 14 : 18,
                    color: lineColor,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.address,
                    style: textStyle,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (state == QlypRouteStopNodeState.reached && !compact)
                    Text(
                      reachedHint,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: inactive,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
