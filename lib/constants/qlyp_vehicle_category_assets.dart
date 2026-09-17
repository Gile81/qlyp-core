/// Bundled vehicle category preview assets and service-tier hierarchy.
class QlypVehicleCategoryAssets {
  QlypVehicleCategoryAssets._();

  static const String packagePrefix =
      'packages/qlyp_core/assets/images/vehicles/';

  static int rankForCategoryKey(String? rawKey) {
    final key = normalizeCategoryKey(rawKey);
    return _rankByKey[key] ?? 0;
  }

  static String normalizeCategoryKey(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'core';
    var key = raw.trim().toLowerCase();
    key = key.replaceAll('-', '_').replaceAll(' ', '_');
    if (key.startsWith('squad5')) key = 'squad_5';
    if (key.startsWith('squad6')) key = 'squad_6';
    return key;
  }

  static String assetPathForCategoryKey(String? rawKey) {
    final key = normalizeCategoryKey(rawKey);
    final filename = _filenameByKey[key] ?? 'core.webp';
    return '$packagePrefix$filename';
  }

  /// Maps Laravel `fallback_category` body types (sedan/suv/…) to bundled tier assets.
  static String resolvePreviewCategoryKey({
    String? apiCategory,
    required String serviceTierFallback,
  }) {
    final apiKey = normalizeCategoryKey(apiCategory);
    if (apiKey.isNotEmpty) {
      if (_filenameByKey.containsKey(apiKey)) return apiKey;
      final mapped = _bodyClassToTierAsset[apiKey];
      if (mapped != null) return mapped;
    }
    return normalizeCategoryKey(serviceTierFallback);
  }

  /// Returns [raw] when it looks like a numeric MySQL id, otherwise null.
  static String? numericIdOrNull(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;
    return int.tryParse(text) != null ? text : null;
  }

  static String categoryKeyFromServiceReference({
    String? serviceId,
    String? serviceTitle,
  }) {
    final haystack = '${serviceId ?? ''} ${serviceTitle ?? ''}'.toLowerCase();
    if (_containsAny(haystack, ['luxe', 'galaxy'])) return 'luxe';
    if (_containsAny(haystack, ['mega', 'max'])) return 'mega';
    if (_containsAny(haystack, ['squad_6', 'squad6', 'squad 6'])) {
      return 'squad_6';
    }
    if (_containsAny(haystack, ['squad_5', 'squad5', 'squad 5'])) {
      return 'squad_5';
    }
    if (_containsAny(haystack, ['relax_e', 'relax e'])) return 'relax_e';
    if (_containsAny(haystack, ['relax'])) return 'relax';
    if (_containsAny(haystack, ['volt', 'core', 'nano', 'byte'])) {
      return 'core';
    }
    if (_containsAny(haystack, ['access'])) return 'access';
    if (_containsAny(haystack, ['titan'])) return 'titan';
    if (_containsAny(haystack, ['tera'])) return 'tera';
    if (_containsAny(haystack, ['cargo'])) return 'cargo';
    if (_containsAny(haystack, ['apex'])) return 'apex';
    if (_containsAny(haystack, ['zenith'])) return 'zenith';
    if (_containsAny(haystack, ['bloc_hd', 'bloc hd'])) return 'bloc_hd';
    if (_containsAny(haystack, ['dbloc', 'd-bloc'])) return 'dbloc';
    if (_containsAny(haystack, ['qlyp_bite', 'qlyp bite', 'bite'])) {
      return 'qlyp_bite';
    }
    if (_containsAny(haystack, ['towing', 'remorquage'])) {
      if (_containsAny(haystack, ['heavy', 'hd', 'lourd'])) return 'towing_hd';
      return 'towing_light';
    }
    if (_containsAny(haystack, [
      'boost',
      'dépannage',
      'depannage',
      'jump',
      'boost_jump',
    ])) {
      if (_containsAny(haystack, ['heavy', 'hd', 'lourd'])) return 'boost_hd';
      return 'boost_light';
    }
    if (_containsAny(haystack, ['qlyp_parcel', 'parcel', 'colis'])) {
      return 'qlyp_parcel';
    }
    if (_containsAny(haystack, ['zip'])) return 'zip';
    return 'core';
  }

  static String highestCategoryKeyFromServices({
    required Iterable<({String serviceId, String serviceName})> services,
  }) {
    String best = 'core';
    var bestRank = -1;
    for (final row in services) {
      final key = categoryKeyFromServiceReference(
        serviceId: row.serviceId,
        serviceTitle: row.serviceName,
      );
      final rank = rankForCategoryKey(key);
      if (rank > bestRank) {
        bestRank = rank;
        best = key;
      }
    }
    return best;
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final needle in needles) {
      if (haystack.contains(needle)) return true;
    }
    return false;
  }

  static const Map<String, int> _rankByKey = {
    'core': 10,
    'volt': 10,
    'nano': 10,
    'byte': 10,
    'access': 10,
    'access_e': 10,
    'access_xl': 10,
    'cargo': 10,
    'relax': 20,
    'relax_e': 20,
    'squad_5': 30,
    'squad_6': 30,
    'mega': 40,
    'max': 40,
    'luxe': 50,
    'galaxy': 50,
  };

  static const Map<String, String> _bodyClassToTierAsset = {
    'sedan': 'relax',
    'suv': 'squad_5',
    'truck': 'cargo',
    'van': 'access_xl',
    'coupe': 'luxe',
    'hatchback': 'byte',
    'wagon': 'relax',
  };

  static const Map<String, String> _filenameByKey = {
    'core': 'core.webp',
    'volt': 'volt.webp',
    'nano': 'nano.webp',
    'byte': 'byte.webp',
    'access': 'access.webp',
    'access_e': 'access_e.webp',
    'access_xl': 'access_xl.webp',
    'cargo': 'cargo.webp',
    'relax': 'relax.webp',
    'relax_e': 'relax_e.webp',
    'squad_5': 'squad_5.webp',
    'squad_6': 'squad_6.webp',
    'mega': 'mega.webp',
    'max': 'max.webp',
    'luxe': 'luxe.webp',
    'galaxy': 'galaxy.webp',
    'volt_hd': 'volt.webp',
    'towing': 'towing_light.webp',
    'towing_light': 'towing_light.webp',
    'towing_hd': 'towing_hd.webp',
    'towing_heavy': 'towing_hd.webp',
    'boost': 'boost_light.webp',
    'boost_light': 'boost_light.webp',
    'boost_hd': 'boost_hd.webp',
    'boost_jump': 'boost_light.webp',
    'parcel': 'qlyp_parcel.webp',
    'qlyp_parcel': 'qlyp_parcel.webp',
    'zip': 'zip.webp',
    'apex': 'apex.webp',
    'bloc_hd': 'bloc_hd.webp',
    'dbloc': 'dbloc.webp',
    'qlyp_bite': 'qlyp_bite.webp',
    'tera': 'tera.webp',
    'titan': 'titan.webp',
    'zenith': 'zenith.webp',
  };
}