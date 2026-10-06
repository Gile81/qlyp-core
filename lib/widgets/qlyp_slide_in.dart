import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';

/// Contenu qui entre depuis la droite (decalage + opacite), Fluid — sections depliees, listes.
class QlypSlideIn extends StatefulWidget {
  const QlypSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = kDurSlideIn,
    this.offset = QlypStyle.slideInOffset,
    this.visible = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;
  final bool visible;

  @override
  State<QlypSlideIn> createState() => _QlypSlideInState();
}

class _QlypSlideInState extends State<QlypSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _t = CurvedAnimation(parent: _controller, curve: kQlypFluid);
    if (!widget.visible) {
      _controller.value = 0;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncAnimation();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        QlypMotionAccessibility.duration(context, widget.duration);
  }

  @override
  void didUpdateWidget(covariant QlypSlideIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible ||
        oldWidget.duration != widget.duration ||
        oldWidget.delay != widget.delay) {
      _controller.duration =
          QlypMotionAccessibility.duration(context, widget.duration);
      _syncAnimation();
    }
  }

  Future<void> _syncAnimation() async {
    final dur = _controller.duration ?? widget.duration;
    if (!widget.visible) {
      if (dur == Duration.zero) {
        _controller.value = 0;
        return;
      }
      if (_controller.isAnimating) {
        await _controller.reverse();
      } else if (_controller.value > 0) {
        await _controller.reverse(from: _controller.value);
      }
      return;
    }

    if (dur == Duration.zero) {
      _controller.value = 1;
      return;
    }

    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      if (!mounted || !widget.visible) return;
    }
    if (!mounted) return;
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final progress = _t.value;
        return Transform.translate(
          offset: Offset(widget.offset * (1 - progress), 0),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: widget.child,
    );
  }
}
