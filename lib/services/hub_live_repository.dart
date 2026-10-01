import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/hub_er_status.dart';
import '../models/hub_event.dart';
import '../utils/hub_live_display.dart';

/// Read-only hub live feeds (`hub_events`, `hub_er_status`).
class HubLiveRepository {
  HubLiveRepository({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  static const _eventsCollection = 'hub_events';
  static const _erCollection = 'hub_er_status';

  /// Firestore `arrayContainsAny` supports at most 30 values.
  static const maxZoneIdsForQuery = 30;

  Stream<List<HubEvent>> eventsStream({
    required List<String> zoneIds,
    DateTime? now,
    int limit = 60,
    int horizonDays = 14,
  }) {
    final ids = zoneIds.map((z) => z.trim()).where((z) => z.isNotEmpty).toList();
    if (ids.isEmpty) {
      return Stream.value(const <HubEvent>[]);
    }

    final effectiveIds = ids.length > maxZoneIdsForQuery
        ? ids.sublist(0, maxZoneIdsForQuery)
        : ids;
    if (ids.length > maxZoneIdsForQuery) {
      debugPrint(
        'HubLiveRepository.eventsStream: truncated zoneIds from '
        '${ids.length} to $maxZoneIdsForQuery',
      );
    }

    final clock = now ?? DateTime.now();
    final query = _buildEventsQuery(effectiveIds, clock, limit);

    return query.snapshots().map((snap) {
      final parsed = snap.docs
          .map((doc) => HubEvent.fromFirestore(doc.data(), doc.id))
          .toList();
      return filterHubEventsForDisplay(
        events: parsed,
        now: clock,
        horizonDays: horizonDays,
      );
    });
  }

  Query<Map<String, dynamic>> _buildEventsQuery(
    List<String> zoneIds,
    DateTime now,
    int limit,
  ) {
    final endAtLower = Timestamp.fromDate(now);
    final collection = _firestore.collection(_eventsCollection);

    if (zoneIds.length == 1) {
      return collection
          .where('zoneIds', arrayContains: zoneIds.first)
          .where('endAt', isGreaterThanOrEqualTo: endAtLower)
          .orderBy('endAt')
          .limit(limit);
    }

    return collection
        .where('zoneIds', arrayContainsAny: zoneIds)
        .where('endAt', isGreaterThanOrEqualTo: endAtLower)
        .orderBy('endAt')
        .limit(limit);
  }

  Stream<HubErStatus?> erStatusStream(String zoneId) {
    final id = zoneId.trim();
    if (id.isEmpty) {
      return Stream.value(null);
    }
    return _firestore.collection(_erCollection).doc(id).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return HubErStatus.fromFirestore(snap.data()!, snap.id);
    });
  }

  /// Reads `hub_er_status/{zoneId}` for each work zone (`whereIn` document id).
  Stream<List<HubErStatus>> erStatusesStream(List<String> zoneIds) {
    final ids = zoneIds.map((z) => z.trim()).where((z) => z.isNotEmpty).toList();
    if (ids.isEmpty) {
      return Stream.value(const <HubErStatus>[]);
    }

    final effectiveIds = ids.length > maxZoneIdsForQuery
        ? ids.sublist(0, maxZoneIdsForQuery)
        : ids;
    if (ids.length > maxZoneIdsForQuery) {
      debugPrint(
        'HubLiveRepository.erStatusesStream: truncated zoneIds from '
        '${ids.length} to $maxZoneIdsForQuery',
      );
    }

    return _firestore
        .collection(_erCollection)
        .where(FieldPath.documentId, whereIn: effectiveIds)
        .snapshots()
        .map((snap) {
      return snap.docs
          .where((doc) => doc.data().isNotEmpty)
          .map((doc) => HubErStatus.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
}
