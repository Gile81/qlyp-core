import '../models/hub_er_status.dart';
import '../models/hub_event.dart';

enum HubEventTimeDisplayKind { timed, allDay, untilDate }

class HubEventTimeDisplay {
  const HubEventTimeDisplay({
    required this.kind,
    required this.startAt,
    this.endAt,
    this.endEstimated = false,
    this.inProgress = false,
  });

  final HubEventTimeDisplayKind kind;
  final DateTime startAt;
  final DateTime? endAt;
  final bool endEstimated;
  final bool inProgress;
}

class HubEventsDayGroup {
  const HubEventsDayGroup({required this.localDay, required this.events});

  final DateTime localDay;
  final List<HubEvent> events;
}

DateTime hubLiveLocalDate(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day);

DateTime hubLiveEndOfLocalDay(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

/// Pure display metadata (no user-facing strings).
HubEventTimeDisplay hubEventTimeDisplay(
  HubEvent event, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final startLocal = hubLiveLocalDate(event.startAt.toLocal());
  final endLocal = hubLiveLocalDate(event.endAt.toLocal());
  final inProgress = !clock.isBefore(event.startAt) &&
      !clock.isAfter(event.endAt);

  if (!event.timeKnown) {
    if (startLocal != endLocal) {
      return HubEventTimeDisplay(
        kind: HubEventTimeDisplayKind.untilDate,
        startAt: event.startAt,
        endAt: event.endAt,
        inProgress: inProgress,
      );
    }
    return HubEventTimeDisplay(
      kind: HubEventTimeDisplayKind.allDay,
      startAt: event.startAt,
      inProgress: inProgress,
    );
  }

  return HubEventTimeDisplay(
    kind: HubEventTimeDisplayKind.timed,
    startAt: event.startAt,
    endAt: event.endAt,
    endEstimated: event.endEstimated,
    inProgress: inProgress,
  );
}

/// Events in progress or starting before the end of the local day.
List<HubEvent> tonightEvents(List<HubEvent> events, DateTime now) {
  final endOfToday = hubLiveEndOfLocalDay(now.toLocal());
  final filtered = events.where((e) {
    final inProgress =
        !now.isBefore(e.startAt) && !now.isAfter(e.endAt);
    if (inProgress) return true;
    if (e.endAt.isBefore(now)) return false;
    if (e.startAt.isAfter(endOfToday)) return false;
    return true;
  }).toList();

  filtered.sort((a, b) {
    if (a.timeKnown != b.timeKnown) {
      return a.timeKnown ? -1 : 1;
    }
    if (a.timeKnown && b.timeKnown) {
      return a.startAt.compareTo(b.startAt);
    }
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
  return filtered;
}

/// Upcoming events grouped by local start day (within [days] from [now]).
List<HubEventsDayGroup> upcomingEvents(
  List<HubEvent> events,
  DateTime now,
  int days,
) {
  if (days <= 0) return const [];
  final horizonEnd = now.add(Duration(days: days));
  final eligible = events.where((e) {
    return !e.endAt.isBefore(now) && !e.startAt.isAfter(horizonEnd);
  }).toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));

  final groups = <DateTime, List<HubEvent>>{};
  for (final e in eligible) {
    final day = hubLiveLocalDate(e.startAt.toLocal());
    groups.putIfAbsent(day, () => []).add(e);
  }

  final keys = groups.keys.toList()..sort();
  return keys
      .map((d) => HubEventsDayGroup(localDay: d, events: groups[d]!))
      .toList();
}

List<HubErItem> sortErItems(List<HubErItem> items) {
  final copy = List<HubErItem>.from(items);
  copy.sort((a, b) {
    final ao = a.occupancyPct;
    final bo = b.occupancyPct;
    if (ao == null && bo == null) return 0;
    if (ao == null) return 1;
    if (bo == null) return -1;
    return bo.compareTo(ao);
  });
  return copy;
}

/// In-memory filters matching server query + app display rules.
List<HubEvent> filterHubEventsForDisplay({
  required List<HubEvent> events,
  required DateTime now,
  int horizonDays = 14,
}) {
  final horizonEnd = now.add(Duration(days: horizonDays));
  return events.where((e) {
    if (e.hidden) return false;
    if (e.supersededBy != null && e.supersededBy!.isNotEmpty) return false;
    if (e.startAt.isAfter(horizonEnd)) return false;
    return true;
  }).toList();
}
