import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// ── Style asset ────────────────────────────────────────────────────────────

/// Package-qualified asset path for the QLYP Pearl style JSON.
/// Used as [MapWidget.styleUri] — Mapbox accepts inline JSON strings as
/// style URIs in addition to `mapbox://` / `https://` URLs.
const String qlypPearlStyleAsset =
    'packages/qlyp_core/assets/styles/style_qlyp_pearl_final.json';

/// Reads and returns the QLYP Pearl style JSON string.
///
/// [rootBundle] caches assets internally, so repeated calls are cheap.
Future<String> loadQlypPearlStyleJson() =>
    rootBundle.loadString(qlypPearlStyleAsset);

// ── QLYP layer colour presets ───────────────────────────────────────────────
//
// Pearl  (day / dusk) : warm light background with tinted water and parks.
// Midnight (night)    : deep-navy palette, aligned with QlypColors.deepQlyp.
//
// Values are CSS hex strings accepted by Mapbox paint properties.
// The basemap Standard import handles roads / buildings / POI in each mode;
// only the three custom layers below need explicit colour switches.

const Map<String, String> _qlypBgByPreset = {
  'day': '#F4F7FA',
  'dusk': '#F4F7FA',
  'night': '#152838',
};

const Map<String, String> _qlypWaterByPreset = {
  'day': '#B8D4E8',
  'dusk': '#B8D4E8',
  'night': '#0C1C2E',
};

const Map<String, String> _qlypParksByPreset = {
  'day': '#CCDFC8',
  'dusk': '#CCDFC8',
  'night': '#0E2A1C',
};

/// Pushes the QLYP custom-layer colours for [preset] ('day' | 'dusk' | 'night').
///
/// Called automatically by [QlypMapView._applyTheme] and can be called
/// manually by any screen that uses [MapWidget] directly (e.g. the map picker
/// in qlyp-client). Errors are swallowed — a missing layer (e.g. when the
/// STANDARD fallback style is active) is silently ignored.
Future<void> applyQlypLayerColors(MapboxMap map, String preset) async {
  try {
    await map.style.setStyleLayerProperty(
      'qlyp-bg',
      'background-color',
      _qlypBgByPreset[preset] ?? '#F4F7FA',
    );
    await map.style.setStyleLayerProperty(
      'qlyp-water',
      'fill-color',
      _qlypWaterByPreset[preset] ?? '#B8D4E8',
    );
    await map.style.setStyleLayerProperty(
      'qlyp-parks',
      'fill-color',
      _qlypParksByPreset[preset] ?? '#CCDFC8',
    );
  } catch (e) {
    debugPrint('applyQlypLayerColors[$preset]: $e');
  }
}

// ── Time → light preset ─────────────────────────────────────────────────────

enum QlypMapTheme {
  pearl,
  midnight,
}

/// Returns the Mapbox Standard light preset for [time] (defaults to local now).
///
/// 6h–20h → day, 20h–22h → dusk, 22h–6h → night.
String qlypLightPresetForTime([DateTime? time]) {
  final hour = (time ?? DateTime.now()).hour;
  if (hour >= 6 && hour < 20) {
    return 'day';
  }
  if (hour >= 20 && hour < 22) {
    return 'dusk';
  }
  return 'night';
}

// ── QlypMapView widget ──────────────────────────────────────────────────────

/// Mapbox Standard map pre-configured for QLYP:
/// — Pearl style (bg/water/parks) with auto day/dusk/night preset cycling.
/// — Midnight override (all-night) for dark-context screens.
///
/// The Pearl style JSON is loaded from [qlypPearlStyleAsset] and passed
/// directly as [MapWidget.styleUri]; Mapbox accepts inline JSON strings.
/// A blank [SizedBox] is shown for the < 50 ms while the asset is loading.
class QlypMapView extends StatefulWidget {
  const QlypMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 14.0,
    // PRD Section 15 "Pitch par contexte":
    //   booking 0°, tracking-client 35°, pilote cruise 0°, pilote nav 55°.
    // Each screen passes the right value — no silent default here.
    this.pitch = 0.0,
    this.theme = QlypMapTheme.pearl,
    // Language for Mapbox labels (streets outside QC, POI, controls).
    // Pass LocalizationService.getSavedLocale().languageCode explicitly;
    // null = Mapbox default (no explicit config — avoids a silent choice).
    this.language,
    this.onMapCreated,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final double pitch;
  final QlypMapTheme theme;
  final String? language;
  final void Function(MapboxMap map)? onMapCreated;

  @override
  State<QlypMapView> createState() => _QlypMapViewState();
}

class _QlypMapViewState extends State<QlypMapView> {
  MapboxMap? _mapboxMap;
  Timer? _presetTimer;

  /// Pearl style JSON, pre-loaded in [initState] so the [MapWidget] receives
  /// it immediately when the [FutureBuilder] resolves.
  Future<String>? _styleFuture;

  String get _lightPreset => widget.theme == QlypMapTheme.midnight
      ? 'night'
      : qlypLightPresetForTime();

  /// Applies the current light preset to the basemap import + pushes the
  /// matching colours to the three QLYP custom layers (bg / water / parks).
  Future<void> _applyTheme(MapboxMap map) async {
    final preset = _lightPreset;

    // Standard basemap: day/dusk/night roads, buildings, POI.
    await map.style.setStyleImportConfigProperty(
      'basemap',
      'lightPreset',
      preset,
    );

    // Language for map labels.
    final lang = widget.language;
    if (lang != null && lang.isNotEmpty) {
      await map.style.setStyleImportConfigProperty(
        'basemap',
        'language',
        lang,
      );
    }

    // QLYP custom layer colours for the active preset.
    await applyQlypLayerColors(map, preset);
  }

  void _syncPresetTimer() {
    _presetTimer?.cancel();
    _presetTimer = null;
    if (widget.theme != QlypMapTheme.pearl) {
      return;
    }
    // Refresh preset every 5 minutes to handle day → dusk → night transitions.
    _presetTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final map = _mapboxMap;
      if (map != null && widget.theme == QlypMapTheme.pearl) {
        _applyTheme(map);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _syncPresetTimer();
    _styleFuture = loadQlypPearlStyleJson();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    // Style is already applied (passed as styleUri to MapWidget).
    // Only dynamic properties need to be pushed: light preset + layer colours.
    await _applyTheme(mapboxMap);
    widget.onMapCreated?.call(mapboxMap);
  }

  @override
  void didUpdateWidget(covariant QlypMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme ||
        oldWidget.language != widget.language) {
      _syncPresetTimer();
      if (_mapboxMap != null) {
        _applyTheme(_mapboxMap!);
      }
    }
  }

  @override
  void dispose() {
    _presetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _styleFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Style asset still loading (< 50 ms typically).
          return const SizedBox.expand();
        }
        return MapWidget(
          // Mapbox accepts inline JSON strings as styleUri in addition to
          // mapbox:// URIs — the platform loadStyle() call handles both.
          styleUri: snapshot.data!,
          viewport: CameraViewportState(
            center: Point(
              coordinates: Position(widget.longitude, widget.latitude),
            ),
            zoom: widget.zoom,
            pitch: widget.pitch,
          ),
          onMapCreated: _onMapCreated,
        );
      },
    );
  }
}
