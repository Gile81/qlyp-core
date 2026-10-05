import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../models/ride_phase.dart';

/// Localized step labels supplied by the host app (FR/EN business copy).
class QlypRidePhaseTimelineLabels {
  const QlypRidePhaseTimelineLabels({
    required this.enRoute,
    required this.arrivedPickup,
    required this.inProgress,
    required this.arrivedDestination,
  });

  final String enRoute;
  final String arrivedPickup;
  final String inProgress;
  final String arrivedDestination;
}

/// Four-step ride progress strip for live tracking (S5-10).
class QlypRidePhaseTimeline extends StatelessWidget {
  const QlypRidePhaseTimeline({
    super.key,
    required this.phase,
    required this.labels,
  });

  final RidePhase phase;
  final QlypRidePhaseTimelineLabels labels;

  int get _activeIndex {
    switch (phase) {
      case RidePhase.driverEnRoute:
        return 0;
      case RidePhase.driverArrived:
        return 1;
      case RidePhase.inProgress:
        return 2;
      case RidePhase.completed:
        return 3;
      case RidePhase.canceled:
        return 0;
    }
  }

  List<String> get _steps => [
        labels.enRoute,
        labels.arrivedPickup,
        labels.inProgress,
        labels.arrivedDestination,
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final duration = disableAnimations ? Duration.zero : kDurOverlay;
    final active = _activeIndex;

    final inactiveColor =
        isDark ? QlypColors.onDarkSecondary : QlypColors.gray;
    const activeColor = QlypColors.emerald;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: AnimatedContainer(
                          duration: duration,
                          curve: kQlypSpring,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: i <= active
                                ? activeColor.withValues(
                                    alpha: isDark ? 0.85 : 0.75,
                                  )
                                : inactiveColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      duration: duration,
                      curve: kQlypSpring,
                      width: i == active ? 14 : 10,
                      height: i == active ? 14 : 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= active ? activeColor : inactiveColor,
                        boxShadow: i == active && !disableAnimations
                            ? [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    if (i < _steps.length - 1)
                      Expanded(
                        child: AnimatedContainer(
                          duration: duration,
                          curve: kQlypSpring,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: i < active
                                ? activeColor.withValues(
                                    alpha: isDark ? 0.85 : 0.75,
                                  )
                                : inactiveColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: kQlypSpring,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontWeight:
                            i == active ? FontWeight.w700 : FontWeight.w500,
                        color: i == active
                            ? (isDark
                                ? QlypColors.emeraldLight
                                : QlypColors.emeraldDark)
                            : inactiveColor,
                      ),
                  child: Text(
                    _steps[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
