import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';

/// Entree Spring (echelle legere + opacite) pour overlays et alertes entrantes.
class QlypOverlayEntrance extends StatefulWidget {
  const QlypOverlayEntrance({
    super.key,
    required this.child,
    this.visible = true,
    this.duration = kDurOverlay,
  });

  final Widget child;
  final bool visible;
  final Duration duration;

  @override
  State<QlypOverlayEntrance> createState() => _QlypOverlayEntranceState();
}

class _QlypOverlayEntranceState extends State<QlypOverlayEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scale = Tween<double>(
      begin: QlypStyle.overlayEntranceScaleFrom,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: kQlypSpring));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: kQlypSpring),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant QlypOverlayEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) _sync();
  }

  void _sync() {
    final dur = QlypMotionAccessibility.duration(context, widget.duration);
    _controller.duration = dur;
    if (!widget.visible) {
      _controller.value = 0;
      return;
    }
    if (dur == Duration.zero) {
      _controller.value = 1;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}