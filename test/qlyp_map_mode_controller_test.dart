import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/services/qlyp_map_mode_controller.dart';

void main() {
  setUp(() {
    QlypMapModeController.instance.debugReset();
    qlypMapModeNow = () => DateTime(2026, 10, 6, 12);
  });

  tearDown(() {
    qlypMapModeNow = DateTime.now;
  });

  group('qlypLightPresetForTime', () {
    test('5:59 is night', () {
      expect(qlypLightPresetForTime(DateTime(2026, 10, 6, 5, 59)), 'night');
    });
    test('6:00 is day', () {
      expect(qlypLightPresetForTime(DateTime(2026, 10, 6, 6)), 'day');
    });
    test('19:59 is day', () {
      expect(qlypLightPresetForTime(DateTime(2026, 10, 6, 19, 59)), 'day');
    });
    test('20:00 is night', () {
      expect(qlypLightPresetForTime(DateTime(2026, 10, 6, 20)), 'night');
    });
  });

  group('resolveQlypMapLightPreset', () {
    test('forced day and night', () {
      expect(
        resolveQlypMapLightPreset(
          mode: QlypMapMode.day,
          time: DateTime(2026, 10, 6, 23),
        ),
        'day',
      );
      expect(
        resolveQlypMapLightPreset(
          mode: QlypMapMode.night,
          time: DateTime(2026, 10, 6, 10),
        ),
        'night',
      );
    });
  });

  group('QlypMapModeController', () {
    test('persists driver choice', () async {
      String? stored;
      await QlypMapModeController.instance.restoreFromPreferences(
        read: () => 'night',
        write: (v) async {
          stored = v;
        },
      );
      expect(QlypMapModeController.instance.mode, QlypMapMode.night);
      await QlypMapModeController.instance.setMode(QlypMapMode.day);
      expect(stored, 'day');
    });

    test('auto boundary notifies at 20:00', () {
      qlypMapModeNow = () => DateTime(2026, 10, 6, 19, 59);
      final ctrl = QlypMapModeController.instance..debugReset();
      expect(ctrl.effectiveLightPreset, 'day');

      var notified = 0;
      ctrl.addListener(() => notified++);

      qlypMapModeNow = () => DateTime(2026, 10, 6, 20);
      ctrl.debugTriggerBoundaryTimer();

      expect(ctrl.effectiveLightPreset, 'night');
      expect(notified, 1);
    });
  });

  group('storage parsing', () {
    test('parses known values only', () {
      expect(qlypMapModeFromStorage('auto'), QlypMapMode.auto);
      expect(qlypMapModeFromStorage('day'), QlypMapMode.day);
      expect(qlypMapModeFromStorage('night'), QlypMapMode.night);
      expect(qlypMapModeFromStorage('invalid'), isNull);
    });
  });
}
