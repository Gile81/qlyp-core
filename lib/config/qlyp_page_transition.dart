import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/qlyp_motion.dart';

/// Constantes GetX pour [GetMaterialApp].
abstract final class QlypPageTransition {
  static const Transition getx = Transition.rightToLeft;
  static const Duration getxDuration = kDurPage;
  static const Curve getxCurve = kQlypFluid;
}