import 'package:cloud_firestore/cloud_firestore.dart';

/// CMS Cast item (`casts/{id}`), shared by client and pilote apps.
class CastItem {
  const CastItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.mediaUrl,
    required this.thumbnail,
    required this.externalLink,
    required this.offerCode,
    required this.isOffer,
    required this.enable,
    required this.isDeleted,
    required this.createdAt,
    required this.category,
    required this.position,
    required this.zoneIds,
    required this.topic,
  });

  final String id;
  final String title;
  final String description;

  /// `image` | `video` | `document` | `link` (admin values).
  final String type;
  final String mediaUrl;
  final String thumbnail;
  final String externalLink;
  final String offerCode;
  final bool isOffer;
  final bool enable;
  final bool isDeleted;
  final DateTime createdAt;

  /// Firestore `category`: `customer` | `driver` | `both`.
  final String category;
  final int position;

  /// Empty = visible in all zones.
  final List<String> zoneIds;

  /// Structured tab subject from admin (`offers`, `training`, …). Empty when unset.
  final String topic;

  factory CastItem.fromFirestore(Map<String, dynamic> data, String docId) {
    final createdAtValue = data['createdAt'];
    final DateTime createdAt = createdAtValue is Timestamp
        ? createdAtValue.toDate()
        : DateTime.fromMillisecondsSinceEpoch(0);

    final rawZoneIds = data['zone_ids'];
    final List<String> zoneIds = rawZoneIds is List
        ? rawZoneIds.whereType<String>().toList()
        : <String>[];

    final topicRaw = _readString(data, ['topic']).toLowerCase();

    return CastItem(
      id: docId.isNotEmpty ? docId : _readString(data, ['id']),
      title: _readString(data, ['title', 'name', 'headline'],
          fallback: 'Qlyp Cast'),
      description: _readString(data, ['description', 'content', 'summary']),
      type: _readString(data, ['type'], fallback: 'image'),
      mediaUrl: _readString(data, ['mediaUrl', 'imageUrl', 'thumbnailUrl']),
      thumbnail: _readString(data, ['thumbnail']),
      externalLink: _readString(data, ['externalLink', 'link']),
      offerCode: _readString(data, ['offerCode', 'promoCode', 'code']),
      isOffer: data['isOffer'] == true,
      enable: data['enable'] != false,
      isDeleted: data['isDeleted'] == true,
      createdAt: createdAt,
      category: _readString(data, ['category']),
      position: _readInt(data['position']),
      zoneIds: zoneIds,
      topic: topicRaw,
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }
}
