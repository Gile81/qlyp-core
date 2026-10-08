import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';

/// Squelette shimmer accueil 10C.
class QlypSkeleton extends StatefulWidget {
  const QlypSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  const QlypSkeleton.block({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  const QlypSkeleton.line({
    super.key,
    required this.width,
    this.height = 14,
    this.borderRadius = 6,
  });

  const QlypSkeleton.card({
    super.key,
    required this.width,
    this.height = 120,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<QlypSkeleton> createState() => _QlypSkeletonState();
}

class _QlypSkeletonState extends State<QlypSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kDurSkeletonShimmer)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = QlypMotionAccessibility.duration(
      context,
      kDurSkeletonShimmer,
    );
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [
        QlypColors.skeletonBase,
        QlypColors.skeletonMid,
        QlypColors.skeletonBase,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = _controller.value * 2 - 1;
        return ShaderMask(
          shaderCallback: (bounds) {
            return gradient.createShader(
              Rect.fromLTWH(
                bounds.width * slide,
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: QlypColors.skeletonBase,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
