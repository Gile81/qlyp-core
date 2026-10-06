import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'qlyp_map_mode_controller.dart';

export 'qlyp_map_basemap.dart';
export 'qlyp_map_mode_controller.dart';

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

// ── QlypMapView widget ──────────────────────────────────────────────────────

/// Mapbox Standard map pre-configured for QLYP Pearl:
/// auto day/night via [QlypMapModeController] (06:00–20:00 local = day).
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
    /// Override map label language; when null, uses [Localizations.localeOf].
    this.language,
    this.onMapCreated,
    /// When false, disables pinch/pan/rotate (static preview tiles).
    this.interactive = true,
    /// When true, allows two-finger pitch on the map.
    this.enablePitch = false,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final double pitch;
  final String? language;
  final void Function(MapboxMap map)? onMapCreated;
  final bool interactive;
  final bool enablePitch;

  @override
  State<QlypMapView> createState() => _QlypMapViewState();
}

class _QlypMapViewState extends State<QlypMapView> {
  MapboxMap? _mapboxMap;
  QlypMapModeController get _modeCtrl => QlypMapModeController.instance;

  /// Pearl style JSON, pre-loaded in [initState] so the [MapWidget] receives
  /// it immediately when the [FutureBuilder] resolves.
  Future<String>? _styleFuture;

  String _languageFor(BuildContext context) {
    final explicit = widget.language?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    return Localizations.localeOf(context).languageCode;
  }

  Future<void> _applyTheme(MapboxMap map, BuildContext context) async {
    final lang = _languageFor(context);
    _modeCtrl.updateMapLanguage(map, lang);
    await _modeCtrl.applyToMap(map, language: lang);
  }

  void _onModeControllerChanged() {
    final map = _mapboxMap;
    if (map == null || !mounted) return;
    unawaited(_applyTheme(map, context));
  }

  @override
  void initState() {
    super.initState();
    _modeCtrl.addListener(_onModeControllerChanged);
    _styleFuture = loadQlypPearlStyleJson();
  }

  Future<void> _applyGestureSettings(MapboxMap mapboxMap) async {
    if (!widget.interactive) {
      await mapboxMap.gestures.updateSettings(
        GesturesSettings(
          scrollEnabled: false,
          pinchToZoomEnabled: false,
          rotateEnabled: false,
          pitchEnabled: false,
          doubleTapToZoomInEnabled: false,
          doubleTouchToZoomOutEnabled: false,
          quickZoomEnabled: false,
        ),
      );
      return;
    }

    await mapboxMap.gestures.updateSettings(
      GesturesSettings(
        scrollEnabled: true,
        pinchToZoomEnabled: true,
        rotateEnabled: true,
        pitchEnabled: widget.enablePitch,
        doubleTapToZoomInEnabled: true,
        doubleTouchToZoomOutEnabled: true,
        quickZoomEnabled: true,
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _modeCtrl.registerMap(mapboxMap, language: widget.language);
    await _applyTheme(mapboxMap, context);
    await _applyGestureSettings(mapboxMap);
    widget.onMapCreated?.call(mapboxMap);
  }

  @override
  void didUpdateWidget(covariant QlypMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      if (_mapboxMap != null) {
        _applyTheme(_mapboxMap!, context);
      }
    }
    if (oldWidget.interactive != widget.interactive ||
        oldWidget.enablePitch != widget.enablePitch) {
      if (_mapboxMap != null) {
        _applyGestureSettings(_mapboxMap!);
      }
    }
  }

  @override
  void dispose() {
    _modeCtrl.removeListener(_onModeControllerChanged);
    final map = _mapboxMap;
    if (map != null) {
      _modeCtrl.unregisterMap(map);
    }
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
          // Required when MapWidget sits inside a ScrollView — otherwise the
          // parent scroll view wins the gesture arena and the map feels frozen.
          gestureRecognizers: widget.interactive
              ? <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                }
              : const <Factory<OneSequenceGestureRecognizer>>{},
          onMapCreated: _onMapCreated,
        );
      },
    );
  }
}
