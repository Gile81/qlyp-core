import '../models/cast_item.dart';
import 'zone_visibility.dart';

/// Target app for Cast audience filtering (`casts.category`).
enum CastAudience { customer, driver }

/// Closed list of Cast tab topics (Firestore `casts.topic`).
enum CastTopic {
  offers,
  training,
  events,
  tourism,
  news,
}

/// Translation keys for Cast tabs (apps provide FR/EN strings).
const String castTabKeyAll = 'cast_tab_all';
const String castTabKeyOffers = 'cast_tab_offers';
const String castTabKeyTraining = 'cast_tab_training';
const String castTabKeyEvents = 'cast_tab_events';
const String castTabKeyTourism = 'cast_tab_tourism';
const String castTabKeyNews = 'cast_tab_news';

const List<CastTopic> castTopicDisplayOrder = [
  CastTopic.offers,
  CastTopic.events,
  CastTopic.tourism,
  CastTopic.training,
  CastTopic.news,
];

String castTopicFirestoreValue(CastTopic topic) {
  switch (topic) {
    case CastTopic.offers:
      return 'offers';
    case CastTopic.training:
      return 'training';
    case CastTopic.events:
      return 'events';
    case CastTopic.tourism:
      return 'tourism';
    case CastTopic.news:
      return 'news';
  }
}

String castTopicTabKey(CastTopic topic) {
  switch (topic) {
    case CastTopic.offers:
      return castTabKeyOffers;
    case CastTopic.training:
      return castTabKeyTraining;
    case CastTopic.events:
      return castTabKeyEvents;
    case CastTopic.tourism:
      return castTabKeyTourism;
    case CastTopic.news:
      return castTabKeyNews;
  }
}

CastTopic? castTopicFromFirestore(String? raw) {
  final value = (raw ?? '').trim().toLowerCase();
  if (value.isEmpty) return null;
  for (final topic in CastTopic.values) {
    if (castTopicFirestoreValue(topic) == value) {
      return topic;
    }
  }
  return null;
}

bool castMatchesAudience(String? category, CastAudience audience) {
  final cat = (category ?? '').trim().toLowerCase();
  if (cat.isEmpty) return false;
  if (cat == 'both') return true;
  switch (audience) {
    case CastAudience.driver:
      return cat == 'driver';
    case CastAudience.customer:
      return cat == 'customer';
  }
}

bool castVisibleInUserZones(CastItem item, List<String> userZoneIds) {
  return visibleInZones(item.zoneIds, userZoneIds: userZoneIds);
}

/// Items with no structured [CastItem.topic] appear only under [castTabKeyAll].
bool castItemMatchesTab(CastItem item, String tabKey) {
  if (tabKey == castTabKeyAll) return true;
  if (tabKey == castTabKeyOffers) {
    return item.topic == 'offers' || item.isOffer;
  }
  final topic = castTopicFromFirestore(item.topic);
  if (topic == null) return false;
  return castTopicTabKey(topic) == tabKey;
}

bool castItemHasTopicContent(CastItem item, CastTopic topic) {
  switch (topic) {
    case CastTopic.offers:
      return item.topic == 'offers' || item.isOffer;
    case CastTopic.training:
    case CastTopic.events:
    case CastTopic.tourism:
    case CastTopic.news:
      return item.topic == castTopicFirestoreValue(topic);
  }
}

/// `all` first, then only topics that have at least one visible item.
List<String> castTabs(Iterable<CastItem> items) {
  final tabs = <String>[castTabKeyAll];
  for (final topic in castTopicDisplayOrder) {
    if (items.any((item) => castItemHasTopicContent(item, topic))) {
      tabs.add(castTopicTabKey(topic));
    }
  }
  return tabs;
}

/// Lower [CastItem.position] first, then newer [CastItem.createdAt].
int compareCastItems(CastItem a, CastItem b) {
  final byPosition = a.position.compareTo(b.position);
  if (byPosition != 0) return byPosition;
  return b.createdAt.compareTo(a.createdAt);
}

List<CastItem> filterCastItems({
  required Iterable<CastItem> items,
  required CastAudience audience,
  required List<String> userZoneIds,
}) {
  final list = <CastItem>[];
  for (final item in items) {
    if (!item.enable || item.isDeleted) continue;
    if (!castMatchesAudience(item.category, audience)) continue;
    if (!castVisibleInUserZones(item, userZoneIds)) continue;
    list.add(item);
  }
  list.sort(compareCastItems);
  return list;
}

List<CastItem> filterCastItemsByTab(List<CastItem> items, String tabKey) {
  return items.where((item) => castItemMatchesTab(item, tabKey)).toList();
}
