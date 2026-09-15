import 'package:flutter/material.dart';

/// Shared motion curves and durations (PRD-locked).
const Curve kQlypSpring = Cubic(0.34, 1.56, 0.64, 1.0);
const Curve kQlypFluid = Cubic(0.25, 1.0, 0.5, 1.0);
const Duration kDurXS = Duration(milliseconds: 120);
const Duration kDurS = Duration(milliseconds: 250);
const Duration kDurM = Duration(milliseconds: 320);
