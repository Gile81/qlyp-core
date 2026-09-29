/// Shared zone visibility filter (S4-6g-2).
///
/// A content item is visible when:
///   - [zoneIds] is empty (content targets all zones), OR
///   - [userZoneIds] is non-empty AND at least one element of [userZoneIds]
///     is contained in [zoneIds].
///
/// "Zone inconnue" rule: when [userZoneIds] is empty (zone cannot be
/// determined), only content targeting all zones ([zoneIds] empty) is shown.
bool visibleInZones(
  List<String> zoneIds, {
  required List<String> userZoneIds,
}) {
  if (zoneIds.isEmpty) return true;
  if (userZoneIds.isEmpty) return false;
  return zoneIds.any(userZoneIds.contains);
}