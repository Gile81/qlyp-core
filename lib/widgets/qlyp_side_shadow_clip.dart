import 'package:flutter/material.dart';

/// Horizontal clip only; top and bottom stay open so card shadows are not cut.
class QlypSideShadowClip extends StatelessWidget {
  const QlypSideShadowClip({
    super.key,
    required this.left,
    required this.right,
    required this.child,
  });

  final double left;
  final double right;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _SideClipper(left: left, right: right),
      child: child,
    );
  }
}

class _SideClipper extends CustomClipper<Path> {
  _SideClipper({required this.left, required this.right});

  final double left;
  final double right;

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTRB(left, -10000, right, size.height + 10000));
  }

  @override
  bool shouldReclip(covariant _SideClipper oldClipper) {
    return oldClipper.left != left || oldClipper.right != right;
  }
}
