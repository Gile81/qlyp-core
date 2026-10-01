import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/hub_er_status.dart';
import 'package:qlyp_core/models/hub_event.dart';
import 'package:qlyp_core/utils/hub_live_display.dart';

/// Matches `writeOneEvent` payload in functions/src/hub-live/ingest-events-core.ts
Map<String, dynamic> sampleHubEventFirestoreMap({
  DateTime? startAt,
  DateTime? endAt,
  bool timeKnown = true,
  bool endEstimated = false,
  bool hidden = false,
  String? supersededBy,
  double? lat,
  double? lng,
  String category = 'concert',
  String expectedSize = 'large',
}) {
  final start = startAt ?? DateTime.utc(2026, 10, 15, 23, 30);
  final end = endAt ?? DateTime.utc(2026, 10, 16, 2, 0);
  final now = DateTime.utc(2026, 10, 1, 12, 0);
  return {
    'source': 'tm_events',
    'sourceId': 'T1',
    'title': 'Grand concert du centre',
    'venue': 'Centre Bell',
    'address': '1909 Avenue des Canadiens-de-Montreal',
    'lat': lat,
    'lng': lng,
    'startAt': Timestamp.fromDate(start),
    'endAt': Timestamp.fromDate(end),
    'timeKnown': timeKnown,
    'endEstimated': endEstimated,
    'zoneIds': ['zone_qc'],
    'category': category,
    'expectedSize': expectedSize,
    'url': 'https://ticketmaster.example/event/1',
    'attribution_fr': 'Source Ticketmaster',
    'attribution_en': 'Source Ticketmaster',
    'ingestedAt': Timestamp.fromDate(now),
    'expireAt': Timestamp.fromDate(end.add(const Duration(days: 1))),
    if (hidden) 'hidden': true,
    if (supersededBy != null) 'supersededBy': supersededBy,
  };
}

/// Matches hub_er_status write in functions/src/hub-live/ingest-er-core.ts
Map<String, dynamic> sampleHubErStatusFirestoreMap() {
  final now = DateTime.utc(2026, 10, 1, 12, 0);
  return {
    'sourceExtractAt': Timestamp.fromDate(now),
    'ingestedAt': Timestamp.fromDate(now),
    'stale': false,
    'items': [
      {
        'facilityId': 'chum',
        'name': 'CHUM',
        'occupancyPct': 85,
        'onStretcher': null,
        'over24h': null,
        'level': 'red',
      },
      {
        'facilityId': 'unknown',
        'name': 'Hopital X',
        'occupancyPct': null,
        'onStretcher': null,
        'over24h': null,
        'level': null,
      },
    ],
    'attribution_fr': 'Ministere de la Sante et des Services sociaux',
    'attribution_en': 'Ministry of Health and Social Services',
  };
}

void main() {
  group('HubEvent.fromFirestore', () {
    test('reads full server payload', () {
      final start = DateTime.utc(2026, 10, 15, 23, 30);
      final end = DateTime.utc(2026, 10, 16, 2, 0);
      final event = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(startAt: start, endAt: end),
        'tm_events_T1',
      );
      expect(event.source, 'tm_events');
      expect(event.title, 'Grand concert du centre');
      expect(event.lat, isNull);
      expect(event.lng, isNull);
      expect(event.timeKnown, isTrue);
      expect(event.category, HubEventCategory.concert);
      expect(event.expectedSize, HubEventExpectedSize.large);
      expect(event.zoneIds, ['zone_qc']);
    });

    test('lat lng null and unknown category maps to other', () {
      final map = sampleHubEventFirestoreMap(
        lat: null,
        lng: null,
        category: 'unknown_cat',
        expectedSize: 'huge',
      );
      final event = HubEvent.fromFirestore(map, 'x');
      expect(event.lat, isNull);
      expect(event.lng, isNull);
      expect(event.category, HubEventCategory.other);
      expect(event.expectedSize, isNull);
    });
  });

  group('filterHubEventsForDisplay', () {
    test('drops hidden and superseded', () {
      final now = DateTime.utc(2026, 10, 1, 12, 0);
      final visible = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: DateTime.utc(2026, 10, 5, 23, 30),
          endAt: DateTime.utc(2026, 10, 6, 2, 0),
        ),
        'a',
      );
      final hidden = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(hidden: true),
        'b',
      );
      final superseded = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(supersededBy: 'tm_events_T2'),
        'c',
      );
      final out = filterHubEventsForDisplay(
        events: [visible, hidden, superseded],
        now: now,
      );
      expect(out.map((e) => e.id), ['a']);
    });
  });

  group('HubErStatus', () {
    test('null occupancy stays null', () {
      final status = HubErStatus.fromFirestore(
        sampleHubErStatusFirestoreMap(),
        'zone_qc',
      );
      expect(status.items[1].occupancyPct, isNull);
      expect(status.items[1].level, isNull);
      expect(status.items[0].occupancyPct, 85);
    });
  });

  group('hubEventTimeDisplay', () {
    test('all day single local day', () {
      final start = DateTime.parse('2026-10-15T04:00:00.000Z');
      final end = DateTime.parse('2026-10-16T03:59:59.999Z');
      final event = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: start,
          endAt: end,
          timeKnown: false,
        ),
        'fest',
      );
      final display = hubEventTimeDisplay(
        event,
        now: DateTime.parse('2026-10-15T12:00:00.000Z'),
      );
      expect(display.kind, HubEventTimeDisplayKind.allDay);
      expect(display.endAt, isNull);
    });

    test('until date for multi-day without clock times', () {
      final start = DateTime.parse('2026-10-02T04:00:00.000Z');
      final end = DateTime.parse('2026-10-11T03:59:59.999Z');
      final event = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: start,
          endAt: end,
          timeKnown: false,
        ),
        'fest',
      );
      final display = hubEventTimeDisplay(
        event,
        now: DateTime.parse('2026-10-08T12:00:00.000Z'),
      );
      expect(display.kind, HubEventTimeDisplayKind.untilDate);
      expect(display.inProgress, isTrue);
    });

    test('timed with estimated end', () {
      final event = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(endEstimated: true),
        'tm',
      );
      final display = hubEventTimeDisplay(event);
      expect(display.kind, HubEventTimeDisplayKind.timed);
      expect(display.endEstimated, isTrue);
      expect(display.endAt, isNotNull);
    });
  });

  group('tonightEvents', () {
    test('includes ongoing festival and excludes tomorrow evening', () {
      final now = DateTime.parse('2026-10-08T16:00:00.000Z');
      final festival = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: DateTime.parse('2026-10-05T04:00:00.000Z'),
          endAt: DateTime.parse('2026-10-11T03:59:59.999Z'),
          timeKnown: false,
        ),
        'fest',
      );
      final tomorrow = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: DateTime.parse('2026-10-10T00:30:00.000Z'),
          endAt: DateTime.parse('2026-10-10T03:30:00.000Z'),
        ),
        'tomorrow',
      );
      final tonight = tonightEvents([festival, tomorrow], now);
      expect(tonight.map((e) => e.id), ['fest']);
    });

    test('orders timed before all-day and sorts by start/title', () {
      final now = DateTime.parse('2026-10-08T16:00:00.000Z');
      final timedLate = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: DateTime.parse('2026-10-08T23:00:00.000Z'),
          endAt: DateTime.parse('2026-10-09T02:00:00.000Z'),
        ),
        'late',
      );
      final timedEarly = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: DateTime.parse('2026-10-08T21:00:00.000Z'),
          endAt: DateTime.parse('2026-10-09T00:00:00.000Z'),
        ),
        'early',
      );
      final allDay = HubEvent.fromFirestore(
        sampleHubEventFirestoreMap(
          startAt: DateTime.parse('2026-10-08T04:00:00.000Z'),
          endAt: DateTime.parse('2026-10-09T03:59:59.999Z'),
          timeKnown: false,
        ),
        'all_day',
      );
      final out = tonightEvents([timedLate, allDay, timedEarly], now);
      expect(out.map((e) => e.id), ['early', 'late', 'all_day']);
    });
  });

  group('sortErItems', () {
    test('null occupancy last', () {
      final items = sortErItems([
        const HubErItem(
          facilityId: 'a',
          name: 'A',
          occupancyPct: null,
          onStretcher: null,
          over24h: null,
          level: null,
        ),
        const HubErItem(
          facilityId: 'b',
          name: 'B',
          occupancyPct: 40,
          onStretcher: null,
          over24h: null,
          level: HubErLevel.orange,
        ),
        const HubErItem(
          facilityId: 'c',
          name: 'C',
          occupancyPct: 90,
          onStretcher: null,
          over24h: null,
          level: HubErLevel.red,
        ),
      ]);
      expect(items.map((e) => e.facilityId), ['c', 'b', 'a']);
    });
  });

  test('Firestore snapshot errors propagate through map (CastRepository pattern)', () async {
    Object? captured;
    final stream = Stream<QuerySnapshot<Map<String, dynamic>>>.error(
      Exception('firestore unavailable'),
    ).map((snap) => snap.docs.length);
    final sub = stream.listen(
      (_) {},
      onError: (e) => captured = e,
    );
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(captured, isA<Exception>());
  });
}
