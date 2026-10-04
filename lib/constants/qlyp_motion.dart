import 'package:flutter/material.dart';

/// Shared motion curves and durations (PRD-locked).
const Curve kQlypSpring = Cubic(0.34, 1.56, 0.64, 1.0);
const Curve kQlypFluid = Cubic(0.25, 1.0, 0.5, 1.0);
const Duration kDurXS = Duration(milliseconds: 120);
const Duration kDurS = Duration(milliseconds: 250);
const Duration kDurM = Duration(milliseconds: 320);
const Duration kDurL = Duration(milliseconds: 380);
const Duration kDurXL = Duration(milliseconds: 400);
const Duration kDurSheet = Duration(milliseconds: 340);
const Duration kDurSlideIn = Duration(milliseconds: 300);
const Duration kDurProgress = Duration(milliseconds: 280);
