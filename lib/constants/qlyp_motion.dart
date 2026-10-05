import 'package:flutter/material.dart';

/// PRD §3.6 + règles fixes « Design premium QLYP » — courbes partagées.
const Curve kQlypSpring = Cubic(0.34, 1.56, 0.64, 1.0);
const Curve kQlypFluid = Cubic(0.25, 1.0, 0.5, 1.0);

/// Pression bouton / chip (120 ms).
const Duration kDurPress = Duration(milliseconds: 120);

/// Changement d’onglet nav (250 ms).
const Duration kDurTab = Duration(milliseconds: 250);

/// Listes / accordéons (280 ms).
const Duration kDurList = Duration(milliseconds: 280);

/// Transitions de page / focus champ (300 ms).
const Duration kDurPage = Duration(milliseconds: 300);
const Duration kDurOverlay = Duration(milliseconds: 300);
const Duration kDurFocus = Duration(milliseconds: 300);

/// Sheets intermédiaires (320 ms).
const Duration kDurM = Duration(milliseconds: 320);

/// Bottom sheet slide-up (340 ms).
const Duration kDurSheet = Duration(milliseconds: 340);

/// Shared element / hero (380 ms).
const Duration kDurHero = Duration(milliseconds: 380);

/// Slide-to-online / glissière (400 ms).
const Duration kDurSlider = Duration(milliseconds: 400);

/// Radar cockpit (2200 ms).
const Duration kDurRadarPulse = Duration(milliseconds: 2200);

/// Alias legacy (pilote / apps en migration).
@Deprecated('Use kDurPress')
const Duration kDurXS = kDurPress;
@Deprecated('Use kDurTab')
const Duration kDurS = kDurTab;
@Deprecated('Use kDurList')
const Duration kDurProgress = kDurList;
@Deprecated('Use kDurHero')
const Duration kDurL = kDurHero;
@Deprecated('Use kDurSlider')
const Duration kDurXL = kDurSlider;
