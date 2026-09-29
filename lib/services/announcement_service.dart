import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/announcement.dart';

/// Real-time stream of active [Announcement]s from Firestore (S4-6c-1).
///
/// Filtering applied client-side (Firestore only pre-filters enable == true):
///   - not deleted
///   - time window: start_at <= now < end_at
///   - audience matches [appType]
///   - zone matches [zoneId] (see Announcement.matchesZone)
///
/// Results are sorted via Announcement.compare (alert first, then newer first).
/// Network failures are swallowed -- the stream emits an empty list on error.
class AnnouncementService {
  const AnnouncementService._();

  static const _collection = 'announcements';

  /// Streams active announcements visible to [appType] in [zoneId].
  ///
  /// [appType] : 'customer' | 'driver'
  /// [zoneId]  : current zone ID, or null/empty when unknown
  ///             (only all-zone announcements shown when zoneId is empty)
  static Stream<List<Announcement>> streamActiveFor({
    required String appType,
    String? zoneId,
  }) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('enable', isEqualTo: true)
        .snapshots()
        .map((snap) => _filter(snap, appType, zoneId))
        .handleError((Object e) {
      debugPrint('AnnouncementService.streamActiveFor: $e');
      return <Announcement>[];
    });
  }

  static List<Announcement> _filter(
    QuerySnapshot<Map<String, dynamic>> snap,
    String appType,
    String? zoneId,
  ) {
    final now = DateTime.now();
    final list = <Announcement>[];
    for (final doc in snap.docs) {
      final a = Announcement.fromFirestore(doc.data(), doc.id);
      if (a.isDeleted) continue;
      if (!now.isAfter(a.startAt) || !now.isBefore(a.endAt)) continue;
      if (!a.visibleFor(appType)) continue;
      if (!a.matchesZone(zoneId)) continue;
      list.add(a);
    }
    list.sort(Announcement.compare);
    return list;
  }
}