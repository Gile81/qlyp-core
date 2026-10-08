import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';

/// Illustration flottante (accueil 10C) — seul endroit autorise pour easeInOut.
class QlypFloat extends StatefulWidget {
  const QlypFloat({
    super.key,
    required this.child,
    this.phase = Duration.zero,
    this.amplitude = QlypStyle.floatAmplitude,
  });

  final Widget child;
  final Duration phase;
  final double amplitude;

  @override
  State<QlypFloat> createState() => _QlypFloatState();
}

class _QlypFloatState extends State<QlypFloat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kDurFloatHalf);
    _offset = Tween<double>(begin: 0, end: -widget.amplitude).animate(
      CurvedAnimation(
        parent: _controller,
        // Exception validee par Gile 07/10 — accueil 10C (illustrations piliers).
        curve: Curves.easeInOut,
      ),
    );
    if (widget.phase != Duration.zero) {
      _controller.value = _phaseFraction;
    }
    _controller.repeat(reverse: true);
  }

  double get _phaseFraction {
    final ms =
        widget.phase.inMilliseconds.abs() % kDurFloatHalf.inMilliseconds;
    return ms / kDurFloatHalf.inMilliseconds;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
