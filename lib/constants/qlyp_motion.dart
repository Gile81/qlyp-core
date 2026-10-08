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

/// Contenu qui glisse depuis la droite (PRD §3.6, 250–300 ms).
const Duration kDurSlideIn = Duration(milliseconds: 280);

/// Décalage entre lignes en cascade (accordéon cockpit).
const Duration kDurSlideInStagger = Duration(milliseconds: 40);

Duration kDurSlideInStaggerAt(int index) {
  if (index <= 0) return Duration.zero;
  return Duration(milliseconds: kDurSlideInStagger.inMilliseconds * index);
}

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

/// PRD GamePlan Sprint 6 — tween GPS véhicule (3 s par défaut entre deux fixes).
const Duration kDurMarkerTween = Duration(milliseconds: 3000);
const Duration kDurMarkerTweenMin = Duration(milliseconds: 1000);
const Duration kDurMarkerTweenMax = Duration(milliseconds: 5000);
const Duration kDurMarkerFrame = Duration(milliseconds: 33);

/// S6-9b — nearby vehicle Firestore projection write interval (marker tween target).
const Duration kDurNearbyVehicleServerWrite = Duration(seconds: 10);

/// Position live considérée périmée au-delà de 30 s sans `positionAt`.
const Duration kRideLiveStalePosition = Duration(seconds: 30);

/// Saut GPS : placement direct sans glisser (téléportation / perte de signal).
const double kVehicleTeleportDistanceMeters = 500;

/// En dessous de ce débit, le cap ne pivote pas (véhicule à l’arrêt).
const double kVehicleBearingSpeedThresholdMps = 0.5;

/// Exception validée par Gile 07/10 — accueil 10C : atterrissage en cascade.
const Curve kQlypLand = Cubic(0.22, 1.0, 0.36, 1.0);

/// Exception validée par Gile 07/10 — accueil 10C : atterrissage d'un bloc.
const Duration kDurLand = Duration(milliseconds: 1000);

/// Exception validée par Gile 07/10 — accueil 10C : révélation d'un texte.
const Duration kDurTextReveal = Duration(milliseconds: 1100);

/// Exception validée par Gile 07/10 — accueil 10C : écart entre cartes d'un carrousel.
const Duration kDurLandCardStep = Duration(milliseconds: 110);

/// Exception validée par Gile 07/10 — accueil 10C : première carte après son bloc.
const Duration kDurLandCardOffset = Duration(milliseconds: 120);

/// Exception validée par Gile 07/10 — accueil 10C : texte après son bloc.
const Duration kDurLandTextOffset = Duration(milliseconds: 260);

/// Exception validée par Gile 07/10 — accueil 10C : pilule et barre compacte.
const Duration kDurNavHide = Duration(milliseconds: 520);

/// Exception validée par Gile 07/10 — accueil 10C : photo pilier.
const Duration kDurPhotoReveal = Duration(milliseconds: 950);

/// Exception validée par Gile 07/10 — accueil 10C : zoom lent photo pilier.
const Duration kDurPhotoZoom = Duration(seconds: 10);

/// Exception validée par Gile 07/10 — accueil 10C : demi-cycle illustrations flottantes.
const Duration kDurFloatHalf = Duration(seconds: 3);

/// Exception validée par Gile 07/10 — accueil 10C : indice carrousel piliers.
const Duration kDurHintDelay = Duration(milliseconds: 1800);
const Duration kDurHint = Duration(milliseconds: 1900);

/// Exception validée par Gile 07/10 — accueil 10C : squelettes.
const Duration kDurSkeletonMin = Duration(milliseconds: 2000);
const Duration kDurSkeletonShimmer = Duration(milliseconds: 1500);

/// Exception validée par Gile 07/10 — accueil 10C : tirer pour rafraîchir.
const Duration kDurRefreshPull = Duration(milliseconds: 650);

/// Exception validée par Gile 07/10 — accueil 10C : logo au rafraîchissement.
const Duration kDurLogoDraw = Duration(milliseconds: 1100);
const Duration kDurLogoStroke = Duration(milliseconds: 450);
const Duration kDurLogoStrokeDelay = Duration(milliseconds: 1050);

/// Exception validée par Gile 07/10 — accueil 10C : voiture popup niveau de service.
const Duration kDurHeroIn = Duration(milliseconds: 680);
const Duration kDurHeroOut = Duration(milliseconds: 460);

/// Exception validée par Gile 07/10 — accueil 10C : popups accueil / badge cloche.
const Duration kDurPopIn = Duration(milliseconds: 750);

/// Carrousel offre Cast accueil 10C (spec §2.6).
const Duration kDurHomeBannerInterval = Duration(seconds: 4);
const Duration kDurHomeBannerPage = Duration(milliseconds: 450);
const Duration kDurBadgePop = Duration(milliseconds: 900);
const Duration kDurBadgePopDelay = Duration(milliseconds: 1200);

/// Exception validée par Gile 07/10 — accueil 10C : popup niveau de service.
const Duration kDurPopupDimIn = Duration(milliseconds: 240);
const Duration kDurPopupIn = Duration(milliseconds: 420);
const Duration kDurPopupOut = Duration(milliseconds: 420);

/// Alias legacy — encore utilisé par qlyp-client (S5-6-apps le remplacera).
@Deprecated('Use kDurTab')
const Duration kDurS = kDurTab;
