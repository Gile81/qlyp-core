/// Zone tier activation (10 keys). Parity with functions zone-service-activation.ts.
library;

const zoneActivationKeys = [
  'courses',
  'transport_adapte',
  'limousines',
  'qlyp_route',
  'livraison_express',
  'logistique',
  'demenagement',
  'towing',
  'survoltage',
  'deverrouillage',
];

const legacyZoneActivationKeys = ['assistance', 'rideshare'];

const mainServiceIdToActivationKey = {
  'KME0X43zSpbDmt4TfuRH': 'courses',
  'zuPyze05L5XVsyLMAOB4': 'transport_adapte',
  'xYr1uu6vyQkYlfGEDmkv': 'limousines',
  'RtQlypRoute20260914': 'qlyp_route',
  'iPWQ4zlCxVpE3Ud8SnJP': 'livraison_express',
  'c36QVpfmfiwPrbh3R0Oz': 'logistique',
  'KIylmfHZMDUO2V1ogbVc': 'demenagement',
  'Hqj02VxsDNf8BW9NmgbQ': 'towing',
  'NSbTMfH2czZIyVcLUm7t': 'survoltage',
  'm78vuXGoqRgmMhsyni4v': 'deverrouillage',
};

const groupActivationKeys = {
  'livraison_express',
  'logistique',
  'demenagement',
  'towing',
  'survoltage',
  'deverrouillage',
};

String normActivationKey(Object? raw) =>
    (raw?.toString() ?? '').trim().toLowerCase().replaceAll('-', '_');

List<String> normalizeActivationKeys(Object? raw) {
  if (raw is! List) return [];
  final out = <String>[];
  for (final v in raw) {
    final k = normActivationKey(v);
    if (zoneActivationKeys.contains(k) && !out.contains(k)) out.add(k);
  }
  return out;
}

bool usesLegacyServicesEnabledFormat(Object? raw) {
  if (raw is! List) return false;
  final keys = raw.map(normActivationKey).toSet();
  if (legacyZoneActivationKeys.any(keys.contains)) return true;
  if (keys.contains('logistique') &&
      !keys.contains('livraison_express') &&
      !keys.contains('demenagement')) {
    return true;
  }
  return false;
}

List<String> migrateLegacyServicesEnabled(Object? raw) {
  final keys = <String>{};
  if (raw is List) {
    for (final v in raw) {
      keys.add(normActivationKey(v));
    }
  }
  final out = <String>{};
  for (final k in keys) {
    if (zoneActivationKeys.contains(k)) out.add(k);
  }
  if (keys.contains('logistique')) {
    out.addAll(['livraison_express', 'logistique', 'demenagement']);
  }
  if (keys.contains('assistance')) {
    out.addAll(['towing', 'survoltage', 'deverrouillage']);
  }
  if (keys.contains('rideshare')) {
    out.add('qlyp_route');
  }
  return zoneActivationKeys.where(out.contains).toList();
}

List<String> resolveServicesEnabledKeys(Object? raw) {
  if (usesLegacyServicesEnabledFormat(raw)) {
    return migrateLegacyServicesEnabled(raw);
  }
  return normalizeActivationKeys(raw);
}

Object? _rawServicesEnabledFromDoc(Map<String, dynamic> doc) {
  final services = doc['services'];
  Object? fromServices;
  if (services is Map) {
    fromServices = services['services_enabled'] ?? services['servicesEnabled'];
  }
  return doc['services_enabled'] ?? doc['servicesEnabled'] ?? fromServices;
}

List<String> readServicesEnabledFromZone(Map<String, dynamic> doc) {
  return resolveServicesEnabledKeys(_rawServicesEnabledFromDoc(doc));
}

List<String> readDisabledTierKeys(Map<String, dynamic> doc) {
  final services = doc['services'];
  Object? fromServices;
  if (services is Map) {
    fromServices = services['services_disabled_tiers'] ??
        services['servicesDisabledTiers'];
  }
  final raw =
      doc['services_disabled_tiers'] ?? doc['servicesDisabledTiers'] ?? fromServices;
  if (raw is! List) return [];
  return raw.map((e) => normActivationKey(e)).where((s) => s.isNotEmpty).toList();
}

List<String> readMainServiceIds(Map<String, dynamic>? serviceDoc) {
  if (serviceDoc == null) return [];
  final raw = serviceDoc['mainServiceIDs'] ??
      serviceDoc['main_service_ids'] ??
      serviceDoc['mainServiceIds'];
  if (raw is! List) return [];
  return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
}

List<String> activationKeysForService(Map<String, dynamic>? serviceDoc) {
  final keys = <String>[];
  for (final id in readMainServiceIds(serviceDoc)) {
    final mapped = mainServiceIdToActivationKey[id];
    if (mapped != null && !keys.contains(mapped)) keys.add(mapped);
  }
  return keys;
}

class TierActivationResult {
  const TierActivationResult.offered()
      : offered = true,
        reason = null,
        missingKey = null;
  const TierActivationResult.refused({
    required this.reason,
    this.missingKey,
  }) : offered = false;

  final bool offered;
  final String? reason;
  final String? missingKey;
}

TierActivationResult evaluateTierOfferedInZone({
  required Map<String, dynamic> zoneDoc,
  required Map<String, dynamic>? serviceDoc,
}) {
  final enabled = readServicesEnabledFromZone(zoneDoc);
  if (enabled.isEmpty) {
    return const TierActivationResult.refused(reason: 'no_activation_keys');
  }
  final disabled = readDisabledTierKeys(zoneDoc);
  final serviceId = normActivationKey(serviceDoc?['id']);
  final serviceKey =
      normActivationKey(serviceDoc?['service_key'] ?? serviceDoc?['serviceKey']);
  if ((serviceId.isNotEmpty && disabled.contains(serviceId)) ||
      (serviceKey.isNotEmpty && disabled.contains(serviceKey))) {
    return const TierActivationResult.refused(reason: 'tier_excluded');
  }
  final tierKeys = activationKeysForService(serviceDoc);
  if (tierKeys.isEmpty) {
    return const TierActivationResult.refused(reason: 'activation_key_missing');
  }
  final groupTierKeys =
      tierKeys.where((k) => groupActivationKeys.contains(k)).toList();
  final pillarTierKeys =
      tierKeys.where((k) => !groupActivationKeys.contains(k)).toList();
  if (groupTierKeys.isNotEmpty) {
    for (final k in groupTierKeys) {
      if (enabled.contains(k)) return const TierActivationResult.offered();
    }
    return TierActivationResult.refused(
      reason: 'activation_key_missing',
      missingKey: groupTierKeys.first,
    );
  }
  for (final k in pillarTierKeys) {
    if (!enabled.contains(k)) {
      return TierActivationResult.refused(
        reason: 'activation_key_missing',
        missingKey: k,
      );
    }
  }
  return const TierActivationResult.offered();
}
