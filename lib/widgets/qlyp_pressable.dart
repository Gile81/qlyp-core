import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/qlyp_motion.dart';

/// Rebond 0,95 → 1, spring 120 ms + retour haptique léger au tap.
class QlypPressable extends StatefulWidget {
  const QlypPressable({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticsLabel;

  @override
  State<QlypPressable> createState() => _QlypPressableState();
}

class _QlypPressableState extends State<QlypPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      enabled: widget.enabled,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.enabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: kDurPress,
          curve: kQlypSpring,
          child: widget.child,
        ),
      ),
    );
  }
}
