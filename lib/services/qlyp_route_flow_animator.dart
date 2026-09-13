import 'dart:async';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const double kQlypRouteFlowPulseLength = 0.12;
const Duration kQlypRouteFlowCycle = Duration(milliseconds: 2500);
const Duration kQlypRouteFlowFrame = Duration(milliseconds: 33);

List<Object> buildQlypFlowGradientExpression(
  double phase, {
  String lightPreset = 'day',
}) {
  const transparent = 'rgba(0, 0, 0, 0)';

  final bool isNight = lightPreset == 'night';
  final String emeraldBright = isNight ? '#27D96B' : '#6EE7A8';
  final String blueAccent =
      isNight ? 'rgba(59, 130, 246, 0.9)' : 'rgba(59, 130, 246, 0.65)';
  final String headBright =
      isNight ? 'rgba(39, 217, 107, 1.0)' : 'rgba(110, 231, 168, 0.95)';

  final entries = <(double, String)>[
    (0.0, transparent),
    (1.0, transparent),
  ];

  void addPulseWindow(double center) {
    double clamp01(double v) => v.clamp(0.0, 1.0);

    final head = clamp01(center);
    final neck = clamp01(center - kQlypRouteFlowPulseLength * 0.25);
    final mid = clamp01(center - kQlypRouteFlowPulseLength * 0.55);
    final tail = clamp01(center - kQlypRouteFlowPulseLength);

    if (head <= tail && tail <= 0 && head <= 0) {
      return;
    }

    entries
      ..add((tail, transparent))
      ..add((mid, blueAccent))
      ..add((neck, emeraldBright))
      ..add((head, headBright));

    final afterHead = clamp01(head + 0.001);
    if (afterHead > head) {
      entries.add((afterHead, transparent));
    }
  }

  final p = phase % 1.0;
  addPulseWindow(p);

  if (p > 1.0 - kQlypRouteFlowPulseLength * 0.5) {
    addPulseWindow(p - 1.0);
  }

  entries.sort((a, b) => a.$1.compareTo(b.$1));

  final deduped = <(double, String)>[];
  for (final entry in entries) {
    if (deduped.isNotEmpty &&
        (deduped.last.$1 - entry.$1).abs() < 0.0001) {
      deduped[deduped.length - 1] = entry;
    } else {
      deduped.add(entry);
    }
  }

  final stops = <Object>[
    'interpolate',
    ['linear'],
    ['line-progress'],
  ];
  for (final (t, color) in deduped) {
    stops.add(t);
    stops.add(color);
  }
  return stops;
}

class QlypRouteFlowAnimator {
  QlypRouteFlowAnimator({
    required this.map,
    required this.layerId,
    this.lightPreset = 'day',
    this.cycleDuration = kQlypRouteFlowCycle,
  });

  final MapboxMap map;
  final String layerId;
  final String lightPreset;
  final Duration cycleDuration;

  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  bool _updating = false;
  bool _disposed = false;

  void start() {
    stop();
    _disposed = false;
    _stopwatch
      ..reset()
      ..start();
    _timer = Timer.periodic(kQlypRouteFlowFrame, (_) {
      unawaited(_tick());
    });
    unawaited(_tick());
  }

  void stop() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  Future<void> _tick() async {
    if (_disposed || _updating) {
      return;
    }
    _updating = true;
    try {
      if (!await map.style.styleLayerExists(layerId)) {
        stop();
        return;
      }
      final elapsedMs =
          _stopwatch.elapsedMilliseconds % cycleDuration.inMilliseconds;
      final phase = elapsedMs / cycleDuration.inMilliseconds;
      await map.style.setStyleLayerProperty(
        layerId,
        'line-gradient',
        buildQlypFlowGradientExpression(phase, lightPreset: lightPreset),
      );
    } catch (_) {
      stop();
    } finally {
      _updating = false;
    }
  }
}

final Map<String, QlypRouteFlowAnimator> _activeFlowAnimators = {};

String qlypRouteFlowAnimatorKey(MapboxMap map, String sourceId) =>
    '${identityHashCode(map)}_$sourceId';

void stopQlypRouteFlowAnimator(MapboxMap map, String sourceId) {
  final key = qlypRouteFlowAnimatorKey(map, sourceId);
  _activeFlowAnimators.remove(key)?.stop();
}

void startQlypRouteFlowAnimator({
  required MapboxMap map,
  required String sourceId,
  required String layerId,
  String lightPreset = 'day',
}) {
  stopQlypRouteFlowAnimator(map, sourceId);
  final animator = QlypRouteFlowAnimator(
    map: map,
    layerId: layerId,
    lightPreset: lightPreset,
  );
  _activeFlowAnimators[qlypRouteFlowAnimatorKey(map, sourceId)] = animator;
  animator.start();
}
