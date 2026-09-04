/// Chemins des animations Lottie partagées QLYP (fichiers .json, pas .lottie).
///
/// Les fichiers vivent une seule fois dans qlyp-core/assets/animations/ et
/// sont référencés depuis client + pilote via le préfixe `packages/qlyp_core/assets`
/// — même mécanisme déjà utilisé par [QlypMapService.markersPath] pour les
/// icônes véhicule SVG. Aucune copie locale requise dans les apps.
class QlypAnimations {
  const QlypAnimations._();

  static const String packageAssetPrefix = 'packages/qlyp_core/assets';
  static const String animationsPath = '$packageAssetPrefix/animations';

  static const String radarPulse = '$animationsPath/radar_pulse.json';
  static const String searchingDriver = '$animationsPath/searching_driver.json';
  static const String successCheck = '$animationsPath/success_check.json';
}
