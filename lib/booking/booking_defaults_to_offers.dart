import '../pricing/zone_service_activation.dart';

/// Whether the booking UI should default to offer mode (not dispatch mode).
///
/// Uses catalog activation keys (same as server tier activation), not GoRide
/// category names.
bool bookingDefaultsToOffers({
  String? pillarKey,
  String? groupKey,
}) {
  final group = normActivationKey(groupKey);
  if (group == 'livraison_express') return false;
  if (group == 'logistique' || group == 'demenagement') return true;
  // [pillarKey] kept for API stability; tier group slugs are authoritative today.
  return false;
}

/// First logistics / moving / express group key on a tier document.
String? primaryGroupActivationKey(Map<String, dynamic>? serviceDoc) {
  for (final key in activationKeysForService(serviceDoc)) {
    if (groupActivationKeys.contains(key)) return key;
  }
  return null;
}

String? activationKeyForMainServiceId(String? mainServiceId) {
  final id = (mainServiceId ?? '').trim();
  if (id.isEmpty) return null;
  return mainServiceIdToActivationKey[id];
}

bool readBiddingEnabledFromZoneDoc(Map<String, dynamic> zoneDoc) {
  final services = zoneDoc['services'];
  if (services is Map) {
    final raw = services['bidding_enabled'] ?? services['biddingEnabled'];
    if (raw != null) return _asBool(raw);
  }
  final root = zoneDoc['bidding_enabled'] ?? zoneDoc['biddingEnabled'];
  if (root != null) return _asBool(root);
  return false;
}

bool _asBool(Object? raw) {
  if (raw is bool) return raw;
  if (raw is num) return raw != 0;
  final s = raw?.toString().trim().toLowerCase();
  return s == 'true' || s == '1' || s == 'yes';
}
