/// Official tier / pillar / group display order (PRD + decision 2026-09-24).
abstract final class OfficialServiceOrder {
  static const int missingOrderSentinel = 1 << 30;

  /// Pillar slugs in UI order (matches accueil PRD 6.1).
  static const List<String> pillarSlugs = [
    'courses',
    'transport_adapte',
    'limousines',
    'logistique',
    'assistance',
    'qlyp_route',
  ];

  static const Map<String, int> _pillarSequence = {
    'courses': 10,
    'transport_adapte': 20,
    'limousines': 30,
    'logistique': 40,
    'assistance': 50,
    'qlyp_route': 60,
  };

  static const Map<String, int> _groupSequence = {
    'livraison_express': 10,
    'logistique': 20,
    'demenagement': 30,
    'towing': 10,
    'survoltage': 20,
    'deverrouillage': 30,
  };

  /// Global tier rank (single sequence per service_key).
  static const Map<String, int> tierSequenceByKey = {
    'core': 10,
    'volt': 20,
    'relax': 30,
    'relax_e': 40,
    'squad_5': 50,
    'squad_6': 60,
    'mega': 70,
    'luxe': 80,
    'access': 90,
    'access_e': 100,
    'access_xl': 110,
    'zenith': 120,
    'titan': 130,
    'apex': 140,
    'galaxy': 150,
    'qlyp_bite': 160,
    'qlyp_parcel': 170,
    'byte': 180,
    'zip': 190,
    'bloc': 200,
    'max': 210,
    'tera': 220,
    'cargo': 230,
    'towing_light': 240,
    'towing_hd': 250,
    'boost_light': 260,
    'boost_hd': 270,
    'dbloc': 280,
  };

  static const Map<String, String> tierTitleEn = {
    'core': 'Core',
    'volt': 'Volt',
    'relax': 'Relax',
    'relax_e': 'Relax E',
    'squad_5': 'Squad 5',
    'squad_6': 'Squad 6',
    'mega': 'Mega',
    'luxe': 'Luxe',
    'access': 'Access',
    'access_e': 'Access E',
    'access_xl': 'Access HD',
    'zenith': 'Zénith',
    'titan': 'Titan',
    'apex': 'Apex',
    'galaxy': 'Galaxy',
    'qlyp_bite': 'Qlyp Bite',
    'qlyp_parcel': 'Qlyp Parcel',
    'byte': 'Byte',
    'zip': 'Zip',
    'bloc': 'Bloc',
    'max': 'Max',
    'tera': 'Tera',
    'cargo': 'Cargo',
    'towing_light': 'Towing Light',
    'towing_hd': 'Towing HD',
    'boost_light': 'Boost Light',
    'boost_hd': 'Boost HD',
    'dbloc': 'Dbloc',
  };

  static int? sequenceForTierKey(String normalizedKey) =>
      tierSequenceByKey[normalizedKey];

  static int sequenceForPillarSlug(String slug) =>
      _pillarSequence[slug] ?? missingOrderSentinel;

  static int sequenceForGroupSlug(String slug) =>
      _groupSequence[slug] ?? missingOrderSentinel;

  static String? officialTitleEn(String normalizedKey) => tierTitleEn[normalizedKey];

  /// Déménagement uses logistics tier order filtered to Bloc, Max, Tera, Cargo.
  static const List<String> demenagementTierKeys = [
    'bloc',
    'max',
    'tera',
    'cargo',
  ];
}
