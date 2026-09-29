import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/announcement.dart';

/// Real-time stream of active [Announcement]s from Firestore (S4-6c-1).
///
/// Filtering applied client-side (Firestore only pre-filters enable == true):
///   - not deleted
///   - time window: start_at <= now < end_at
///   - audience matches [appType]
///   - zone matches (see Announcement.matchesZones)
///
/// Results are sorted via Announcement.compare (alert first, then newer first).
/// Network failures are swallowed -- the stream emits an empty list on error.
class AnnouncementService {
  const AnnouncementService._();

  static const _collection = 'announcements';

  /// Streams active announcements visible to [appType] in the given zone(s).
  ///
  /// [appType]     : 'customer' | 'driver'
  /// [userZoneIds] : all ZRS zones of the user (e.g. driver registered in
  ///                 several zones).  Empty list = zone unknown; only
  ///                 all-zone announcements are returned.
  /// [zoneId]      : convenience single-zone parameter (kept for backward
  ///                 compat with customer callers).  When [userZoneIds] is
  ///                 provided it takes precedence; otherwise [zoneId] is
  ///                 wrapped into a one-element list.
  static Stream<List<Announcement>> streamActiveFor({
    required String appType,
    String? zoneId,
    List<String>? userZoneIds,
  }) {
    // Resolve effective zone list once; userZoneIds wins over zoneId.
    final zones = userZoneIds ??
        (zoneId == null || zoneId.trim().isEmpty
            ? const <String>[]
            : [zoneId.trim()]);

    return FirebaseFirestore.instance
        .collection(_collection)
        .where('enable', isEqualTo: true)
        .snapshots()
        .map((snap) => _filter(snap, appType, zones))
        .handleError((Object e) {
      debugPrint('AnnouncementService.streamActiveFor: $e');
      return <Announcement>[];
    });
  }

  static List<Announcement> _filter(
    QuerySnapshot<Map<String, dynamic>> snap,
    String appType,
    List<String> userZoneIds,
  ) {
    final now = DateTime.now();
    final list = <Announcement>[];
    for (final doc in snap.docs) {
      final a = Announcement.fromFirestore(doc.data(), doc.id);
      if (a.isDeleted) continue;
      if (!now.isAfter(a.startAt) || !now.isBefore(a.endAt)) continue;
      if (!a.visibleFor(appType)) continue;
      if (!a.matchesZones(userZoneIds)) continue;
      list.add(a);
    }
    list.sort(Announcement.compare);
    return list;
  }
}