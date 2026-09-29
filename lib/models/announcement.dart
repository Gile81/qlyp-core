import 'package:cloud_firestore/cloud_firestore.dart';

/// CMS announcement (S4-6c-1).
///
/// Firestore collection: `announcements`
///
/// audience : 'customer' | 'driver' | 'all'
/// display  : 'banner'   | 'modal'
/// level    : 'info'     | 'warning' | 'alert'
/// zone_ids : [] = all zones; non-empty = specific ZRS zone IDs.
class Announcement {
  const Announcement({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.bodyFr,
    required this.bodyEn,
    required this.audience,
    required this.zoneIds,
    required this.display,
    required this.level,
    required this.startAt,
    required this.endAt,
    required this.enable,
    required this.isDeleted,
  });

  final String id;
  final String titleFr;
  final String titleEn;
  final String bodyFr;
  final String bodyEn;

  /// 'customer' | 'driver' | 'all'
  final String audience;

  /// Empty list = visible in all zones.
  final List<String> zoneIds;

  /// 'banner' | 'modal'
  final String display;

  /// 'info' | 'warning' | 'alert'
  final String level;

  final DateTime startAt;
  final DateTime endAt;
  final bool enable;
  final bool isDeleted;

  // -----------------------------------------------------------------------
  // Localised text helpers
  // -----------------------------------------------------------------------

  /// Localised title -- falls back to the other language if the primary is empty.
  String title({required bool french}) {
    final fr = titleFr.trim();
    final en = titleEn.trim();
    return french ? (fr.isNotEmpty ? fr : en) : (en.isNotEmpty ? en : fr);
  }

  /// Localised body text -- falls back to the other language if the primary is empty.
  String body({required bool french}) {
    final fr = bodyFr.trim();
    final en = bodyEn.trim();
    return french ? (fr.isNotEmpty ? fr : en) : (en.isNotEmpty ? en : fr);
  }

  // -----------------------------------------------------------------------
  // Filtering helpers
  // -----------------------------------------------------------------------

  /// True when the current time is inside [startAt, endAt).
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startAt) && now.isBefore(endAt);
  }

  /// True when this announcement is visible to [appType] ('customer' / 'driver').
  bool visibleFor(String appType) =>
      audience == appType || audience == 'all';

  /// True when this announcement applies to [userZoneId].
  ///
  /// - [zoneIds] empty       => visible everywhere (all zones).
  /// - [userZoneId] null/empty => only visible if [zoneIds] is empty.
  bool matchesZone(String? userZoneId) {
    if (zoneIds.isEmpty) return true;
    final zone = (userZoneId ?? '').trim();
    if (zone.isEmpty) return false;
    return zoneIds.contains(zone);
  }

  // -----------------------------------------------------------------------
  // Sorting
  // -----------------------------------------------------------------------

  /// Numeric priority for [level]: alert (0) > warning (1) > info / unknown (2).
  static int levelPriority(String level) {
    switch (level) {
      case 'alert':
        return 0;
      case 'warning':
        return 1;
      default:
        return 2;
    }
  }

  int get _levelPriority => levelPriority(level);

  /// Comparator: primary = level priority (alert first),
  ///             secondary = startAt descending (newer first).
  static int compare(Announcement a, Announcement b) {
    final lp = a._levelPriority.compareTo(b._levelPriority);
    if (lp != 0) return lp;
    return b.startAt.compareTo(a.startAt);
  }

  // -----------------------------------------------------------------------
  // Factory
  // -----------------------------------------------------------------------

  factory Announcement.fromFirestore(Map<String, dynamic> json, String docId) {
    return Announcement(
      id: docId,
      titleFr: (json['title_fr'] as String? ?? '').trim(),
      titleEn: (json['title_en'] as String? ?? '').trim(),
      bodyFr: (json['body_fr'] as String? ?? '').trim(),
      bodyEn: (json['body_en'] as String? ?? '').trim(),
      audience: (json['audience'] as String? ?? 'all'),
      zoneIds: _parseZoneIds(json['zone_ids']),
      display: (json['display'] as String? ?? 'banner'),
      level: (json['level'] as String? ?? 'info'),
      startAt: _parseTimestamp(json['start_at']) ?? DateTime(2000),
      endAt: _parseTimestamp(json['end_at']) ?? DateTime(2100),
      enable: json['enable'] != false,
      isDeleted: json['isDeleted'] == true,
    );
  }

  static List<String> _parseZoneIds(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  /// Accepts:
  ///   - [Timestamp]  -- Firestore native
  ///   - [DateTime]   -- already converted
  ///   - [int]        -- Unix epoch seconds (used in unit tests)
  static DateTime? _parseTimestamp(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    return null;
  }
}