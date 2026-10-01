import 'package:cloud_firestore/cloud_firestore.dart';

enum HubErLevel { green, orange, red }

/// Firestore `hub_er_status/{zoneId}`.
class HubErStatus {
  const HubErStatus({
    required this.zoneId,
    required this.sourceExtractAt,
    required this.ingestedAt,
    required this.stale,
    required this.items,
    required this.attributionFr,
    required this.attributionEn,
  });

  final String zoneId;
  final DateTime sourceExtractAt;
  final DateTime ingestedAt;
  final bool stale;
  final List<HubErItem> items;
  final String attributionFr;
  final String attributionEn;

  factory HubErStatus.fromFirestore(Map<String, dynamic> data, String zoneId) {
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => HubErItem.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <HubErItem>[];

    return HubErStatus(
      zoneId: zoneId,
      sourceExtractAt: _timestamp(data['sourceExtractAt']),
      ingestedAt: _timestamp(data['ingestedAt']),
      stale: data['stale'] == true,
      items: items,
      attributionFr: _string(data['attribution_fr']),
      attributionEn: _string(data['attribution_en']),
    );
  }

  static String _string(dynamic value) => (value ?? '').toString();

  static DateTime _timestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}

class HubErItem {
  const HubErItem({
    required this.facilityId,
    required this.name,
    required this.occupancyPct,
    required this.onStretcher,
    required this.over24h,
    required this.level,
  });

  final String facilityId;
  final String name;
  final int? occupancyPct;
  final int? onStretcher;
  final int? over24h;
  final HubErLevel? level;

  factory HubErItem.fromMap(Map<String, dynamic> data) {
    return HubErItem(
      facilityId: _string(data['facilityId']),
      name: _string(data['name']),
      occupancyPct: _nullableInt(data['occupancyPct']),
      onStretcher: _nullableInt(data['onStretcher']),
      over24h: _nullableInt(data['over24h']),
      level: _level(data['level']),
    );
  }

  static String _string(dynamic value) => (value ?? '').toString();

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static HubErLevel? _level(dynamic raw) {
    final value = (raw ?? '').toString().trim().toLowerCase();
    switch (value) {
      case 'green':
        return HubErLevel.green;
      case 'orange':
        return HubErLevel.orange;
      case 'red':
        return HubErLevel.red;
      default:
        return null;
    }
  }
}
