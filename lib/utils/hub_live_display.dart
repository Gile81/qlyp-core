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

/// Driver Hub « Sorties à venir » (timed endings + in-progress all-day).
class DriverUpcomingExits {
  const DriverUpcomingExits({
    required this.endingSoon,
    required this.allDayInProgress,
  });

  /// Timed events with [timeKnown] whose [endAt] falls within the window.
  final List<HubEvent> endingSoon;

  /// All-day / date-only events currently in progress (max 5, sorted by title).
  final List<HubEvent> allDayInProgress;

  bool get isEmpty => endingSoon.isEmpty && allDayInProgress.isEmpty;
}

DriverUpcomingExits driverUpcomingExits(
  List<HubEvent> events,
  DateTime now, {
  int hours = 12,
}) {
  final windowEnd = now.add(Duration(hours: hours));
  final endingSoon = <HubEvent>[];
  final allDay = <HubEvent>[];

  for (final e in events) {
    if (e.timeKnown) {
      if (e.endAt.isBefore(now)) continue;
      if (e.endAt.isAfter(windowEnd)) continue;
      endingSoon.add(e);
    } else {
      final inProgress =
          !now.isBefore(e.startAt) && !now.isAfter(e.endAt);
      if (inProgress) allDay.add(e);
    }
  }

  endingSoon.sort((a, b) => a.endAt.compareTo(b.endAt));
  allDay.sort(
    (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
  );

  return DriverUpcomingExits(
    endingSoon: endingSoon,
    allDayInProgress: allDay.take(5).toList(),
  );
}

/// Merge multi-zone ER documents (dedupe facilities, combine stale flag).
HubErStatus mergeErStatuses(List<HubErStatus> statuses) {
  if (statuses.isEmpty) {
    throw ArgumentError.value(statuses, 'statuses', 'must not be empty');
  }
  final first = statuses.first;
  final byFacility = <String, HubErItem>{};

  for (final status in statuses) {
    for (final item in status.items) {
      final id = item.facilityId.trim();
      if (id.isEmpty) continue;
      final existing = byFacility[id];
      if (existing == null) {
        byFacility[id] = item;
        continue;
      }
      final eo = existing.occupancyPct;
      final no = item.occupancyPct;
      if (eo == null && no != null) {
        byFacility[id] = item;
      } else if (eo != null && no != null && no > eo) {
        byFacility[id] = item;
      }
    }
  }

  var sourceExtractAt = first.sourceExtractAt;
  var ingestedAt = first.ingestedAt;
  var stale = first.stale;
  for (final s in statuses) {
    if (s.sourceExtractAt.isAfter(sourceExtractAt)) {
      sourceExtractAt = s.sourceExtractAt;
    }
    if (s.ingestedAt.isAfter(ingestedAt)) {
      ingestedAt = s.ingestedAt;
    }
    stale = stale || s.stale;
  }

  return HubErStatus(
    zoneId: first.zoneId,
    sourceExtractAt: sourceExtractAt,
    ingestedAt: ingestedAt,
    stale: stale,
    items: sortErItems(byFacility.values.toList()),
    attributionFr: first.attributionFr,
    attributionEn: first.attributionEn,
  );
}
