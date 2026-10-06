import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'qlyp_map_basemap.dart';

/// SharedPreferences / local storage key (driver app writes this value).
const String kQlypMapModePreferenceKey = 'qlypMapModeKey';

/// How the Mapbox basemap chooses day vs night lighting.
enum QlypMapMode {
  auto,
  day,
  night,
}

/// Injectable clock for tests (device local time in production).
QlypNow qlypMapModeNow = DateTime.now;

typedef QlypNow = DateTime Function();

/// Parses persisted values: `auto`, `day`, `night` (unknown → null).
QlypMapMode? qlypMapModeFromStorage(String? raw) {
  switch (raw?.trim()) {
    case 'day':
      return QlypMapMode.day;
    case 'night':
      return QlypMapMode.night;
    case 'auto':
      return QlypMapMode.auto;
    default:
      return null;
  }
}

String qlypMapModeToStorage(QlypMapMode mode) => mode.name;

/// Mapbox Standard `lightPreset` from local time: day 06:00–19:59, night otherwise.
String qlypLightPresetForTime([DateTime? time]) {
  final hour = (time ?? qlypMapModeNow()).hour;
  if (hour >= 6 && hour < 20) {
    return 'day';
  }
  return 'night';
}

/// Resolves the active preset for [mode] and optional [time].
String resolveQlypMapLightPreset({
  QlypMapMode mode = QlypMapMode.auto,
  DateTime? time,
}) {
  switch (mode) {
    case QlypMapMode.day:
      return 'day';
    case QlypMapMode.night:
      return 'night';
    case QlypMapMode.auto:
      return qlypLightPresetForTime(time);
  }
}

/// Next local transition instant (06:00 or 20:00) strictly after [now].
DateTime qlypNextMapLightTransition(DateTime now) {
  final sixToday = DateTime(now.year, now.month, now.day, 6);
  final twentyToday = DateTime(now.year, now.month, now.day, 20);
  if (now.isBefore(sixToday)) {
    return sixToday;
  }
  if (now.isBefore(twentyToday)) {
    return twentyToday;
  }
  return sixToday.add(const Duration(days: 1));
}

/// Single app-wide map mode + one boundary timer (auto mode only).
class QlypMapModeController extends ChangeNotifier {
  QlypMapModeController._();

  static final QlypMapModeController instance = QlypMapModeController._();

  QlypMapMode _mode = QlypMapMode.auto;
  Timer? _boundaryTimer;
  final Map<int, _RegisteredMap> _maps = <int, _RegisteredMap>{};

  Future<void> Function(String value)? _persist;

  QlypMapMode get mode => _mode;

  String get effectiveLightPreset =>
      resolveQlypMapLightPreset(mode: _mode, time: qlypMapModeNow());

  /// Loads [read] once; optional [write] is called when the driver changes mode.
  Future<void> restoreFromPreferences({
    required String Function() read,
    Future<void> Function(String value)? write,
  }) async {
    _persist = write;
    final stored = qlypMapModeFromStorage(read());
    if (stored != null) {
      _mode = stored;
    }
    _rescheduleBoundaryTimer();
    notifyListeners();
    await _applyToAllMaps();
  }

  Future<void> setMode(QlypMapMode value) async {
    if (_mode == value) return;
    _mode = value;
    _rescheduleBoundaryTimer();
    notifyListeners();
    final persist = _persist;
    if (persist != null) {
      await persist(qlypMapModeToStorage(value));
    }
    await _applyToAllMaps();
  }

  void registerMap(MapboxMap map, {String? language}) {
    _maps[identityHashCode(map)] = _RegisteredMap(map, language);
    unawaited(
      applyQlypBasemapStyle(
        map,
        lightPreset: effectiveLightPreset,
        language: language,
      ),
    );
  }

  void updateMapLanguage(MapboxMap map, String language) {
    final entry = _maps[identityHashCode(map)];
    if (entry != null) {
      entry.language = language;
    }
  }

  void unregisterMap(MapboxMap map) {
    _maps.remove(identityHashCode(map));
  }

  Future<void> applyToMap(
    MapboxMap map, {
    String? language,
  }) async {
    if (language != null && language.isNotEmpty) {
      updateMapLanguage(map, language);
    }
    await applyQlypBasemapStyle(
      map,
      lightPreset: effectiveLightPreset,
      language: language ?? _maps[identityHashCode(map)]?.language,
    );
  }

  Future<void> _applyToAllMaps() async {
    final preset = effectiveLightPreset;
    for (final entry in _maps.values.toList()) {
      await applyQlypBasemapStyle(
        entry.map,
        lightPreset: preset,
        language: entry.language,
      );
    }
  }

  void _rescheduleBoundaryTimer() {
    _boundaryTimer?.cancel();
    _boundaryTimer = null;
    if (_mode != QlypMapMode.auto) {
      return;
    }
    final now = qlypMapModeNow();
    final next = qlypNextMapLightTransition(now);
    var delay = next.difference(now);
    if (delay.isNegative || delay == Duration.zero) {
      delay = const Duration(milliseconds: 1);
    }
    _boundaryTimer = Timer(delay, _onBoundaryReached);
  }

  void _onBoundaryReached() {
    if (_mode != QlypMapMode.auto) {
      return;
    }
    notifyListeners();
    unawaited(_applyToAllMaps());
    _rescheduleBoundaryTimer();
  }

  @visibleForTesting
  void debugReset({
    QlypMapMode mode = QlypMapMode.auto,
    Future<void> Function(String value)? persist,
  }) {
    _boundaryTimer?.cancel();
    _boundaryTimer = null;
    _mode = mode;
    _persist = persist;
    _maps.clear();
    _rescheduleBoundaryTimer();
  }

  @visibleForTesting
  void debugTriggerBoundaryTimer() {
    _boundaryTimer?.cancel();
    _onBoundaryReached();
  }
}

class _RegisteredMap {
  _RegisteredMap(this.map, this.language);

  final MapboxMap map;
  String? language;
}

final Map<int, String> _qlypMapLightPresets = <int, String>{};

/// Registers [preset] for [map] so route layers can match basemap lighting.
void registerQlypMapLightPreset(MapboxMap map, String preset) {
  _qlypMapLightPresets[identityHashCode(map)] = preset;
}

/// Returns the preset registered for [map], or [qlypLightPresetForTime] if unknown.
String qlypMapLightPreset(MapboxMap map) =>
    _qlypMapLightPresets[identityHashCode(map)] ?? qlypLightPresetForTime();

/// Applies Standard import preset, label language, and QLYP custom layer colours.
Future<void> applyQlypBasemapStyle(
  MapboxMap map, {
  required String lightPreset,
  String? language,
}) async {
  await map.style.setStyleImportConfigProperty(
    'basemap',
    'lightPreset',
    lightPreset,
  );
  final lang = language?.trim();
  if (lang != null && lang.isNotEmpty) {
    await map.style.setStyleImportConfigProperty(
      'basemap',
      'language',
      lang,
    );
  }
  await applyQlypLayerColors(map, lightPreset);
  registerQlypMapLightPreset(map, lightPreset);
}
