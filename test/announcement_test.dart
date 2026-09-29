// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/announcement.dart';
import 'package:qlyp_core/services/maintenance_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

int _future() =>
    (DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch ~/
        1000);

int _past() =>
    (DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/
        1000);

int _recentStart() =>
    (DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000);

Announcement _makeAnnouncement({
  String id = 'ann1',
  String audience = 'all',
  List<String> zoneIds = const [],
  String display = 'banner',
  String level = 'info',
  int? startAt,
  int? endAt,
  bool enable = true,
  bool isDeleted = false,
}) {
  return Announcement.fromFirestore(
    {
      'title_fr': 'Titre FR',
      'title_en': 'Title EN',
      'body_fr': 'Corps FR',
      'body_en': 'Body EN',
      'audience': audience,
      'zone_ids': zoneIds,
      'display': display,
      'level': level,
      'start_at': startAt ?? _recentStart(),
      'end_at': endAt ?? _future(),
      'enable': enable,
      'isDeleted': isDeleted,
    },
    id,
  );
}

void main() {
  // -------------------------------------------------------------------------
  // Announcement.fromFirestore -- default values
  // -------------------------------------------------------------------------

  group('Announcement.fromFirestore defaults', () {
    test('missing audience defaults to all', () {
      final a = Announcement.fromFirestore({}, 'x');
      expect(a.audience, 'all');
    });

    test('missing display defaults to banner', () {
      final a = Announcement.fromFirestore({}, 'x');
      expect(a.display, 'banner');
    });

    test('missing level defaults to info', () {
      final a = Announcement.fromFirestore({}, 'x');
      expect(a.level, 'info');
    });

    test('missing zone_ids defaults to empty list', () {
      final a = Announcement.fromFirestore({}, 'x');
      expect(a.zoneIds, isEmpty);
    });

    test('enable defaults to true when absent', () {
      final a = Announcement.fromFirestore({}, 'x');
      expect(a.enable, isTrue);
    });

    test('isDeleted defaults to false when absent', () {
      final a = Announcement.fromFirestore({}, 'x');
      expect(a.isDeleted, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Localised text helpers
  // -------------------------------------------------------------------------

  group('Announcement localised title/body', () {
    final a = _makeAnnouncement();

    test('title(french:true) returns FR', () {
      expect(a.title(french: true), 'Titre FR');
    });

    test('title(french:false) returns EN', () {
      expect(a.title(french: false), 'Title EN');
    });

    test('body(french:true) returns FR', () {
      expect(a.body(french: true), 'Corps FR');
    });

    test('body(french:false) returns EN', () {
      expect(a.body(french: false), 'Body EN');
    });

    test('title falls back to EN when FR empty', () {
      final a2 = Announcement.fromFirestore(
        {'title_fr': '', 'title_en': 'EN Only', 'body_fr': '', 'body_en': ''},
        'x',
      );
      expect(a2.title(french: true), 'EN Only');
    });
  });

  // -------------------------------------------------------------------------
  // Audience filtering
  // -------------------------------------------------------------------------

  group('Announcement.visibleFor -- audience filtering', () {
    test('customer audience visible for customer', () {
      expect(_makeAnnouncement(audience: 'customer').visibleFor('customer'), isTrue);
    });

    test('customer audience NOT visible for driver', () {
      expect(_makeAnnouncement(audience: 'customer').visibleFor('driver'), isFalse);
    });

    test('driver audience visible for driver', () {
      expect(_makeAnnouncement(audience: 'driver').visibleFor('driver'), isTrue);
    });

    test('driver audience NOT visible for customer', () {
      expect(_makeAnnouncement(audience: 'driver').visibleFor('customer'), isFalse);
    });

    test('all audience visible for customer', () {
      expect(_makeAnnouncement(audience: 'all').visibleFor('customer'), isTrue);
    });

    test('all audience visible for driver', () {
      expect(_makeAnnouncement(audience: 'all').visibleFor('driver'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Zone filtering
  // -------------------------------------------------------------------------

  group('Announcement.matchesZone -- zone filtering', () {
    test('empty zone_ids matches any zone', () {
      expect(_makeAnnouncement(zoneIds: []).matchesZone('zone-1'), isTrue);
    });

    test('empty zone_ids matches null zone (all-zones announcement)', () {
      expect(_makeAnnouncement(zoneIds: []).matchesZone(null), isTrue);
    });

    test('empty zone_ids matches empty string zone', () {
      expect(_makeAnnouncement(zoneIds: []).matchesZone(''), isTrue);
    });

    test('non-empty zone_ids matches when user zone is in list', () {
      expect(
        _makeAnnouncement(zoneIds: ['zone-1', 'zone-2']).matchesZone('zone-1'),
        isTrue,
      );
    });

    test('non-empty zone_ids does NOT match when user zone is absent', () {
      expect(
        _makeAnnouncement(zoneIds: ['zone-1']).matchesZone('zone-2'),
        isFalse,
      );
    });

    test('non-empty zone_ids does NOT match null user zone', () {
      expect(_makeAnnouncement(zoneIds: ['zone-1']).matchesZone(null), isFalse);
    });

    test('non-empty zone_ids does NOT match empty user zone', () {
      expect(_makeAnnouncement(zoneIds: ['zone-1']).matchesZone(''), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // isCurrentlyActive -- date window
  // -------------------------------------------------------------------------

  group('Announcement.isCurrentlyActive -- time window', () {
    test('active when inside window', () {
      expect(_makeAnnouncement().isCurrentlyActive, isTrue);
    });

    test('not active when end_at is in the past', () {
      expect(
        _makeAnnouncement(startAt: _past(), endAt: _past()).isCurrentlyActive,
        isFalse,
      );
    });

    test('not active when start_at is in the future', () {
      expect(
        _makeAnnouncement(startAt: _future(), endAt: _future()).isCurrentlyActive,
        isFalse,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Sorting
  // -------------------------------------------------------------------------

  group('Announcement.compare -- sorting', () {
    test('alert sorts before warning', () {
      final list = [
        _makeAnnouncement(id: 'w', level: 'warning'),
        _makeAnnouncement(id: 'a', level: 'alert'),
      ]..sort(Announcement.compare);
      expect(list.first.level, 'alert');
    });

    test('warning sorts before info', () {
      final list = [
        _makeAnnouncement(id: 'i', level: 'info'),
        _makeAnnouncement(id: 'w', level: 'warning'),
      ]..sort(Announcement.compare);
      expect(list.first.level, 'warning');
    });

    test('same level: newer startAt sorts first', () {
      final older = _makeAnnouncement(id: 'old', level: 'info', startAt: _past());
      final newer = _makeAnnouncement(id: 'new', level: 'info');
      final list = [older, newer]..sort(Announcement.compare);
      expect(list.first.id, 'new');
    });

    test('levelPriority: alert=0, warning=1, info=2', () {
      expect(Announcement.levelPriority('alert'), 0);
      expect(Announcement.levelPriority('warning'), 1);
      expect(Announcement.levelPriority('info'), 2);
      expect(Announcement.levelPriority('unknown'), 2);
    });
  });

  // -------------------------------------------------------------------------
  // Timestamp parsing -- int (epoch seconds) for unit tests
  // -------------------------------------------------------------------------

  group('Announcement timestamp parsing from int', () {
    test('parses int epoch seconds for startAt', () {
      final epochSec = DateTime(2025, 1, 1, 12).millisecondsSinceEpoch ~/ 1000;
      final a = Announcement.fromFirestore(
        {'start_at': epochSec, 'end_at': epochSec + 3600},
        'x',
      );
      expect(a.startAt.year, 2025);
      expect(a.startAt.month, 1);
    });
  });

  // -------------------------------------------------------------------------
  // MaintenanceState
  // -------------------------------------------------------------------------

  group('MaintenanceState.fromFirestore', () {
    test('parses all fields', () {
      final s = MaintenanceState.fromFirestore({
        'customer_enabled': true,
        'driver_enabled': false,
        'message_fr': 'Maintenance FR',
        'message_en': 'Maintenance EN',
        'bypass_uids': ['uid1', 'uid2'],
      });
      expect(s.customerEnabled, isTrue);
      expect(s.driverEnabled, isFalse);
      expect(s.messageFr, 'Maintenance FR');
      expect(s.messageEn, 'Maintenance EN');
      expect(s.bypassUids, ['uid1', 'uid2']);
    });

    test('defaults to not enabled when fields absent', () {
      final s = MaintenanceState.fromFirestore({});
      expect(s.customerEnabled, isFalse);
      expect(s.driverEnabled, isFalse);
      expect(s.bypassUids, isEmpty);
    });

    test('message(french:true) returns FR', () {
      final s = MaintenanceState.fromFirestore(
          {'message_fr': 'FR msg', 'message_en': 'EN msg'});
      expect(s.message(french: true), 'FR msg');
    });

    test('message(french:false) returns EN', () {
      final s = MaintenanceState.fromFirestore(
          {'message_fr': 'FR msg', 'message_en': 'EN msg'});
      expect(s.message(french: false), 'EN msg');
    });

    test('message falls back to EN when FR empty', () {
      final s = MaintenanceState.fromFirestore(
          {'message_fr': '', 'message_en': 'EN only'});
      expect(s.message(french: true), 'EN only');
    });
  });

  // -------------------------------------------------------------------------
  // MaintenanceService.isBlocked
  // -------------------------------------------------------------------------

  group('MaintenanceService.isBlocked', () {
    final blocked = MaintenanceState.fromFirestore({
      'customer_enabled': true,
      'driver_enabled': true,
      'bypass_uids': ['bypass-uid'],
    });

    test('null state => not blocked', () {
      expect(
        MaintenanceService.isBlocked(null, appType: 'customer', uid: 'any-uid'),
        isFalse,
      );
    });

    test('customer blocked when customer_enabled is true', () {
      expect(
        MaintenanceService.isBlocked(blocked, appType: 'customer', uid: 'regular-uid'),
        isTrue,
      );
    });

    test('driver blocked when driver_enabled is true', () {
      expect(
        MaintenanceService.isBlocked(blocked, appType: 'driver', uid: 'regular-uid'),
        isTrue,
      );
    });

    test('bypass_uid is never blocked', () {
      expect(
        MaintenanceService.isBlocked(blocked, appType: 'customer', uid: 'bypass-uid'),
        isFalse,
      );
    });

    test('driver not blocked when only customer_enabled', () {
      final customerOnly = MaintenanceState.fromFirestore({
        'customer_enabled': true,
        'driver_enabled': false,
      });
      expect(
        MaintenanceService.isBlocked(customerOnly, appType: 'driver', uid: 'any-uid'),
        isFalse,
      );
    });

    test('customer not blocked when only driver_enabled', () {
      final driverOnly = MaintenanceState.fromFirestore({
        'customer_enabled': false,
        'driver_enabled': true,
      });
      expect(
        MaintenanceService.isBlocked(driverOnly, appType: 'customer', uid: 'any-uid'),
        isFalse,
      );
    });

    test('no one blocked when both disabled', () {
      final noneEnabled = MaintenanceState.fromFirestore({
        'customer_enabled': false,
        'driver_enabled': false,
      });
      expect(
        MaintenanceService.isBlocked(noneEnabled, appType: 'customer', uid: 'any-uid'),
        isFalse,
      );
      expect(
        MaintenanceService.isBlocked(noneEnabled, appType: 'driver', uid: 'any-uid'),
        isFalse,
      );
    });
  });
}