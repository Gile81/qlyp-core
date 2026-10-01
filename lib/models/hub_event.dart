import 'package:cloud_firestore/cloud_firestore.dart';

enum HubEventCategory {
  concert,
  sport,
  theatre,
  festival,
  family,
  other,
}

enum HubEventExpectedSize {
  small,
  medium,
  large,
}

/// Firestore `hub_events/{source_sourceId}` (server-written, read-only in apps).
class HubEvent {
  const HubEvent({
    required this.id,
    required this.source,
    required this.sourceId,
    required this.title,
    required this.venue,
    required this.address,
    required this.lat,
    required this.lng,
    required this.startAt,
    required this.endAt,
    required this.timeKnown,
    required this.endEstimated,
    required this.zoneIds,
    required this.category,
    required this.expectedSize,
    required this.url,
    required this.attributionFr,
    required this.attributionEn,
    required this.ingestedAt,
    required this.expireAt,
    this.hidden = false,
    this.supersededBy,
    this.mergedFrom = const [],
  });

  final String id;
  final String source;
  final String sourceId;
  final String title;
  final String venue;
  final String address;
  final double? lat;
  final double? lng;
  final DateTime startAt;
  final DateTime endAt;
  final bool timeKnown;
  final bool endEstimated;
  final List<String> zoneIds;
  final HubEventCategory category;
  final HubEventExpectedSize? expectedSize;
  final String url;
  final String attributionFr;
  final String attributionEn;
  final DateTime ingestedAt;
  final DateTime expireAt;
  final bool hidden;
  final String? supersededBy;
  final List<String> mergedFrom;

  factory HubEvent.fromFirestore(Map<String, dynamic> data, String id) {
    return HubEvent(
      id: id,
      source: _string(data['source']),
      sourceId: _string(data['sourceId']),
      title: _string(data['title']),
      venue: _string(data['venue']),
      address: _string(data['address']),
      lat: _nullableDouble(data['lat']),
      lng: _nullableDouble(data['lng']),
      startAt: _timestamp(data['startAt']),
      endAt: _timestamp(data['endAt']),
      timeKnown: data['timeKnown'] == true,
      endEstimated: data['endEstimated'] == true,
      zoneIds: _stringList(data['zoneIds']),
      category: _category(data['category']),
      expectedSize: _expectedSize(data['expectedSize']),
      url: _string(data['url']),
      attributionFr: _string(data['attribution_fr']),
      attributionEn: _string(data['attribution_en']),
      ingestedAt: _timestamp(data['ingestedAt']),
      expireAt: _timestamp(data['expireAt']),
      hidden: data['hidden'] == true,
      supersededBy: _optionalString(data['supersededBy']),
      mergedFrom: _stringList(data['mergedFrom']),
    );
  }

  static String _string(dynamic value) => (value ?? '').toString();

  static String? _optionalString(dynamic value) {
    final s = (value ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime _timestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  static HubEventCategory _category(dynamic raw) {
    final value = (raw ?? '').toString().trim().toLowerCase();
    switch (value) {
      case 'concert':
        return HubEventCategory.concert;
      case 'sport':
        return HubEventCategory.sport;
      case 'theatre':
        return HubEventCategory.theatre;
      case 'festival':
        return HubEventCategory.festival;
      case 'family':
        return HubEventCategory.family;
      default:
        return HubEventCategory.other;
    }
  }

  static HubEventExpectedSize? _expectedSize(dynamic raw) {
    final value = (raw ?? '').toString().trim().toLowerCase();
    switch (value) {
      case 'small':
        return HubEventExpectedSize.small;
      case 'medium':
        return HubEventExpectedSize.medium;
      case 'large':
        return HubEventExpectedSize.large;
      default:
        return null;
    }
  }
}
