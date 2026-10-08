import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';

/// Porte le [AnimationController] de la cascade d'atterrissage (accueil 10C).
class QlypLandingScope extends StatefulWidget {
  const QlypLandingScope({
    super.key,
    required this.child,
    this.totalDuration = const Duration(milliseconds: 2200),
  });

  final Widget child;

  /// Doit couvrir le plus grand `delay + durée` des descendants.
  final Duration totalDuration;

  static QlypLandingScopeState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<QlypLandingScopeState>();
  }

  static QlypLandingScopeState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'QlypLandingScope missing above this widget');
    return state!;
  }

  @override
  State<QlypLandingScope> createState() => QlypLandingScopeState();
}

class QlypLandingScopeState extends State<QlypLandingScope>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  AnimationController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.totalDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = QlypMotionAccessibility.duration(
      context,
      widget.totalDuration,
    );
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant QlypLandingScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalDuration != widget.totalDuration) {
      _controller.duration = QlypMotionAccessibility.duration(
        context,
        widget.totalDuration,
      );
    }
  }

  /// Relance la cascade depuis le début (fin de chargement ou après refresh).
  Future<void> play() async {
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      _controller.value = 1;
      return;
    }
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _QlypLandingScopeInherited(
      state: this,
      child: widget.child,
    );
  }
}

class _QlypLandingScopeInherited extends InheritedWidget {
  const _QlypLandingScopeInherited({
    required this.state,
    required super.child,
  });

  final QlypLandingScopeState state;

  @override
  bool updateShouldNotify(_QlypLandingScopeInherited oldWidget) =>
      oldWidget.state != state;
}

/// Atterrissage : décalage [QlypStyle.landOffset] → 0 et opacité 0 → 1.
class QlypLandIn extends StatelessWidget {
  const QlypLandIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      return child;
    }
    final scope = QlypLandingScope.of(context);
    final totalMs = scope.controller.duration?.inMilliseconds ?? 1;
    final start = delay.inMilliseconds / totalMs;
    final end =
        (delay.inMilliseconds + kDurLand.inMilliseconds) / totalMs;

    return AnimatedBuilder(
      animation: scope.controller,
      builder: (context, child) {
        final t = _intervalT(scope.controller.value, start, end);
        final land = kQlypLand.transform(t);
        return Opacity(
          opacity: land.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(QlypStyle.landOffset * (1 - land), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Révélation de texte : clip gauche → droite + opacité.
class QlypTextReveal extends StatelessWidget {
  const QlypTextReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      return child;
    }
    final scope = QlypLandingScope.of(context);
    final totalMs = scope.controller.duration?.inMilliseconds ?? 1;
    final start = delay.inMilliseconds / totalMs;
    final end =
        (delay.inMilliseconds + kDurTextReveal.inMilliseconds) / totalMs;

    return AnimatedBuilder(
      animation: scope.controller,
      builder: (context, child) {
        final t = _intervalT(scope.controller.value, start, end);
        final land = kQlypLand.transform(t);
        return Opacity(
          opacity: land.clamp(0.0, 1.0),
          child: ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: land.clamp(0.001, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Applique les délais carrousel (carte ou texte) pour l'accueil 10C.
class QlypLandRow extends StatelessWidget {
  const QlypLandRow({
    super.key,
    required this.blockDelay,
    required this.index,
    required this.child,
    this.text = false,
  });

  final Duration blockDelay;
  final int index;
  final Widget child;
  final bool text;

  Duration get _delay {
    if (text) {
      return blockDelay +
          kDurLandTextOffset +
          Duration(milliseconds: kDurLandCardStep.inMilliseconds * index);
    }
    return blockDelay +
        kDurLandCardOffset +
        Duration(milliseconds: kDurLandCardStep.inMilliseconds * index);
  }

  @override
  Widget build(BuildContext context) {
    if (text) {
      return QlypTextReveal(delay: _delay, child: child);
    }
    return QlypLandIn(delay: _delay, child: child);
  }
}

double _intervalT(double controllerValue, double start, double end) {
  if (controllerValue <= start) return 0;
  if (controllerValue >= end) return 1;
  if (end <= start) return 1;
  return (controllerValue - start) / (end - start);
}
