import 'package:flutter/material.dart';

import '../constants/qlyp_motion.dart';

/// Durées et courbes effectives selon [MediaQuery.disableAnimations].
class QlypMotionAccessibility {
  const QlypMotionAccessibility._();

  static bool reduceMotionOf(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  static Duration duration(
    BuildContext context,
    Duration preferred, {
    Duration reduced = Duration.zero,
  }) {
    if (reduceMotionOf(context)) return reduced;
    return preferred;
  }

  static Curve curve(BuildContext context, Curve preferred) {
    if (reduceMotionOf(context)) return Curves.linear;
    return preferred;
  }

  static Duration get press => kDurPress;
  static Duration get list => kDurList;
  static Duration get slideIn => kDurSlideIn;
  static Duration get page => kDurPage;
  static Duration get overlay => kDurOverlay;
  static Duration get hero => kDurHero;
}
