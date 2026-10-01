import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cast_item.dart';
import '../utils/cast_feed.dart';

/// Real-time Cast feed from Firestore (`casts`).
///
/// Firestore query: `enable == true` only (no composite index).
/// Audience, deletion and zone filters are applied in memory.
class CastRepository {
  CastRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'casts';

  Stream<List<CastItem>> stream({
    required CastAudience audience,
    List<String> userZoneIds = const [],
  }) {
    return _firestore
        .collection(_collection)
        .where('enable', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => _mapSnapshot(
            snap,
            audience: audience,
            userZoneIds: userZoneIds,
          ),
        );
  }

  static List<CastItem> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snap, {
    required CastAudience audience,
    required List<String> userZoneIds,
  }) {
    final parsed = snap.docs
        .map((doc) => CastItem.fromFirestore(doc.data(), doc.id))
        .toList();
    return filterCastItems(
      items: parsed,
      audience: audience,
      userZoneIds: userZoneIds,
    );
  }
}
