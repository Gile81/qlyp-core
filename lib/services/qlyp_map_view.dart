import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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

/// Mapbox Standard map with QLYP light presets (pearl = auto by time, midnight = night).
class QlypMapView extends StatefulWidget {
  const QlypMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 14.0,
    this.theme = QlypMapTheme.pearl,
    this.onMapCreated,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final QlypMapTheme theme;
  final void Function(MapboxMap map)? onMapCreated;

  @override
  State<QlypMapView> createState() => _QlypMapViewState();
}

class _QlypMapViewState extends State<QlypMapView> {
  MapboxMap? _mapboxMap;
  Timer? _presetTimer;

  String get _lightPreset => widget.theme == QlypMapTheme.midnight
      ? 'night'
      : qlypLightPresetForTime();

  Future<void> _applyTheme(MapboxMap map) {
    return map.style.setStyleImportConfigProperty(
      'basemap',
      'lightPreset',
      _lightPreset,
    );
  }

  void _syncPresetTimer() {
    _presetTimer?.cancel();
    _presetTimer = null;
    if (widget.theme != QlypMapTheme.pearl) {
      return;
    }
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
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    await _applyTheme(mapboxMap);
    widget.onMapCreated?.call(mapboxMap);
  }

  @override
  void didUpdateWidget(covariant QlypMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme) {
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
    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      viewport: CameraViewportState(
        center: Point(
          coordinates: Position(widget.longitude, widget.latitude),
        ),
        zoom: widget.zoom,
      ),
      onMapCreated: _onMapCreated,
    );
  }
}