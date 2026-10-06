import 'package:flutter/material.dart';

import '../constants/qlyp_motion.dart';

/// Passage tuile vers fiche : Hero QLYP (aligner la route sur [flightDuration]).
class QlypHero extends StatelessWidget {
  const QlypHero({
    super.key,
    required this.tag,
    required this.child,
    this.placeholder,
  });

  final Object tag;
  final Widget child;
  final Widget Function(BuildContext context, Size size, Widget child)? placeholder;

  static const Duration flightDuration = kDurHero;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      placeholderBuilder: placeholder,
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: child,
    );
  }
}