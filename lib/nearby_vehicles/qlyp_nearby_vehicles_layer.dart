import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';
import 'package:qlyp_core/motion/qlyp_motion_accessibility.dart';
import 'package:qlyp_core/nearby_vehicles/nearby_vehicle_marker_resolve.dart';
import 'package:qlyp_core/nearby_vehicles/nearby_vehicles_constants.dart';
import 'package:qlyp_core/nearby_vehicles/qlyp_nearby_vehicles_controller.dart';
import 'package:qlyp_core/ride_tracking/vehicle_marker_motion.dart';
import 'package:qlyp_core/services/qlyp_marker_renderer.dart';
import 'package:qlyp_core/services/qlyp_service_marker_registry.dart';

/// Draws [QlypNearbyVehiclesController] vehicles on a Mapbox map (S6-9b).
///
/// Attach with [QlypNearbyVehiclesLayer.attachToMap] once [MapboxMap] is ready.
/// Listening starts when [visible] is true and stops on dispose / invisible.
class QlypNearbyVehiclesLayer {
  QlypNearbyVehiclesLayer({
    QlypNearbyVehiclesController? controller,
    QlypServiceMarkerRegistry? markerRegistry,
  })  : _controller = controller ?? QlypNearbyVehiclesController(),
        _markerRegistry = markerRegistry ?? QlypServiceMarkerRegistry();

  final QlypNearbyVehiclesController _controller;
  final QlypServiceMarkerRegistry _markerRegistry;

  MapboxMap? _map;
  PointAnnotationManager? _annotations;
  Timer? _frameTimer;
  bool _visible = false;
  bool _reduceMotion = false;

  String? _zoneId;
  String? _passengerSelectedTierId;

  Map<String, String>? _registryCache;
  final Map<String, Uint8List> _iconBytesByStyleId = {};
  final Map<String, _NearbyVehicleSlot> _slots = {};

  QlypNearbyVehiclesController get controller => _controller;

  void attachToMap(MapboxMap map) {
    _map = map;
    unawaited(_ensureAnnotationManager());
  }

  Future<void> _ensureAnnotationManager() async {
    final map = _map;
    if (map == null || _annotations != null) return;
    _annotations = await map.annotations.createPointAnnotationManager();
    _startFramePump();
  }

  void updateQuery({
    required BuildContext context,
    required bool visible,
    required String zoneId,
    required double lat,
    required double lng,
    String? passengerSelectedTierId,
  }) {
    _reduceMotion = QlypMotionAccessibility.reduceMotionOf(context);
    _visible = visible;
    _zoneId = zoneId.trim();
    _passengerSelectedTierId = passengerSelectedTierId?.trim();

    if (!_visible || _zoneId!.isEmpty) {
      _controller.stop();
      unawaited(_fadeOutAllSlots());
      return;
    }

    _controller.start(
      zoneId: _zoneId!,
      lat: lat,
      lng: lng,
      filterServiceId: _passengerSelectedTierId,
    );
    unawaited(_syncFromController());
  }

  void listenToController() {
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    unawaited(_syncFromController());
  }

  Future<void> _syncFromController() async {
    if (!_visible) return;
    final registry = _registryCache ??= await _markerRegistry.fetch();

    final activeIds = <String>{};
    for (final vehicle in _controller.vehicles) {
      activeIds.add(vehicle.presenceId);
      final markerServiceId = nearbyVehicleMarkerServiceId(
        passengerSelectedTierId: _passengerSelectedTierId,
        primaryServiceId: vehicle.primaryServiceId,
      );
      final filename = nearbyVehicleMarkerFilename(
        registry: registry,
        markerServiceId: markerServiceId,
      );
      if (filename == null) continue;

      final styleId = _styleIdForFilename(filename);
      await _ensureStyleImage(styleId, filename);

      var slot = _slots[vehicle.presenceId];
      if (slot == null) {
        slot = _NearbyVehicleSlot(
          presenceId: vehicle.presenceId,
          styleImageId: styleId,
        );
        _slots[vehicle.presenceId] = slot;
        slot.appearStartedAt = DateTime.now();
      } else if (slot.styleImageId != styleId) {
        slot.styleImageId = styleId;
      }

      slot.motion.applyGpsFix(
        lat: vehicle.lat,
        lng: vehicle.lng,
        bearing: vehicle.heading,
        speedMps: vehicle.heading != null ? 1.0 : null,
        positionAt: vehicle.updatedAt,
        disableAnimations: _reduceMotion,
        now: DateTime.now(),
        fixedTweenDuration: _reduceMotion
            ? Duration.zero
            : kNearbyVehiclesServerWriteInterval,
      );
    }

    for (final id in _slots.keys.toList()) {
      if (!activeIds.contains(id)) {
        final slot = _slots[id]!;
        slot.disappearStartedAt ??= DateTime.now();
      }
    }

    await _pushFrame(DateTime.now());
  }

  String _styleIdForFilename(String filename) {
    return 'nearby_${filename.hashCode.abs()}';
  }

  Future<void> _ensureStyleImage(String styleId, String filename) async {
    if (_iconBytesByStyleId.containsKey(styleId)) return;
    final assetPath = QlypServiceMarkerRegistry.assetPathForFilename(filename);
    final bytes =
        await QlypMarkerRenderer.renderSvgMarkerRaw(assetPath, sizePx: 64);
    if (bytes.isEmpty) return;
    _iconBytesByStyleId[styleId] = bytes;

    final map = _map;
    if (map == null) return;
    try {
      await map.style.addStyleImage(
        styleId,
        3.0,
        MbxImage(width: 64, height: 64, data: bytes),
        false,
        [],
        [],
        null,
      );
    } catch (_) {
      // Already registered.
    }
  }

  void _startFramePump() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(kDurMarkerFrame, (_) {
      unawaited(_pushFrame(DateTime.now()));
    });
  }

  Future<void> _pushFrame(DateTime now) async {
    final manager = _annotations;
    if (manager == null) return;

    final toRemove = <String>[];

    for (final entry in _slots.entries) {
      final slot = entry.value;
      final frame = slot.motion.frameAt(now);
      if (slot.motion.displayLat == null) continue;

      final fade = slot.fadeMultiplier(now);
      if (fade <= 0 && slot.disappearStartedAt != null) {
        toRemove.add(entry.key);
        if (slot.annotation != null) {
          try {
            await manager.delete(slot.annotation!);
          } catch (_) {}
          slot.annotation = null;
        }
        continue;
      }

      final opacity = (frame.opacity * fade).clamp(0.0, 1.0);
      final geometry =
          Point(coordinates: Position(frame.lng, frame.lat));

      final options = PointAnnotationOptions(
        geometry: geometry,
        iconImage: slot.styleImageId,
        iconRotate: frame.bearing,
        iconOpacity: opacity,
      );

      if (slot.annotation == null) {
        try {
          slot.annotation = await manager.create(options);
        } catch (_) {}
      } else {
        slot.annotation!.geometry = geometry;
        slot.annotation!.iconRotate = frame.bearing;
        slot.annotation!.iconOpacity = opacity;
        slot.annotation!.iconImage = slot.styleImageId;
        try {
          await manager.update(slot.annotation!);
        } catch (_) {}
      }
    }

    for (final id in toRemove) {
      _slots.remove(id);
    }
  }

  Future<void> _fadeOutAllSlots() async {
    final now = DateTime.now();
    for (final slot in _slots.values) {
      slot.disappearStartedAt ??= now;
    }
    await _pushFrame(now);
    _slots.clear();
  }

  Future<void> dispose() async {
    _controller.removeListener(_onControllerChanged);
    _frameTimer?.cancel();
    _frameTimer = null;
    _controller.stop();
    _controller.dispose();

    final manager = _annotations;
    if (manager != null) {
      for (final slot in _slots.values) {
        if (slot.annotation != null) {
          try {
            await manager.delete(slot.annotation!);
          } catch (_) {}
        }
      }
    }
    _slots.clear();
    _map = null;
    _annotations = null;
  }
}

class _NearbyVehicleSlot {
  _NearbyVehicleSlot({
    required this.presenceId,
    required this.styleImageId,
  });

  final String presenceId;
  String styleImageId;
  final VehicleMarkerMotion motion = VehicleMarkerMotion();
  PointAnnotation? annotation;
  DateTime? appearStartedAt;
  DateTime? disappearStartedAt;

  double fadeMultiplier(DateTime now) {
    if (disappearStartedAt != null) {
      final elapsed = now.difference(disappearStartedAt!);
      final t = 1 - (elapsed.inMilliseconds / kDurOverlay.inMilliseconds);
      return t.clamp(0.0, 1.0);
    }
    if (appearStartedAt != null) {
      final elapsed = now.difference(appearStartedAt!);
      final t = elapsed.inMilliseconds / kDurOverlay.inMilliseconds;
      return t.clamp(0.0, 1.0);
    }
    return 1;
  }
}

/// Host widget: keeps layer lifecycle tied to visibility and map attachment.
class QlypNearbyVehiclesLayerHost extends StatefulWidget {
  const QlypNearbyVehiclesLayerHost({
    super.key,
    required this.mapboxMap,
    required this.visible,
    required this.zoneId,
    required this.latitude,
    required this.longitude,
    this.passengerSelectedTierId,
    this.layer,
  });

  final MapboxMap? mapboxMap;
  final bool visible;
  final String zoneId;
  final double latitude;
  final double longitude;
  final String? passengerSelectedTierId;
  final QlypNearbyVehiclesLayer? layer;

  @override
  State<QlypNearbyVehiclesLayerHost> createState() =>
      _QlypNearbyVehiclesLayerHostState();
}

class _QlypNearbyVehiclesLayerHostState extends State<QlypNearbyVehiclesLayerHost> {
  QlypNearbyVehiclesLayer? _ownedLayer;

  QlypNearbyVehiclesLayer get _layer =>
      widget.layer ?? (_ownedLayer ??= QlypNearbyVehiclesLayer());

  @override
  void initState() {
    super.initState();
    if (widget.layer == null) {
      _layer.listenToController();
    }
    _apply();
  }

  @override
  void didUpdateWidget(covariant QlypNearbyVehiclesLayerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mapboxMap != null && widget.mapboxMap != oldWidget.mapboxMap) {
      _layer.attachToMap(widget.mapboxMap!);
    }
    _apply();
  }

  void _apply() {
    final map = widget.mapboxMap;
    if (map != null) {
      _layer.attachToMap(map);
    }
    _layer.updateQuery(
      context: context,
      visible: widget.visible,
      zoneId: widget.zoneId,
      lat: widget.latitude,
      lng: widget.longitude,
      passengerSelectedTierId: widget.passengerSelectedTierId,
    );
  }

  @override
  void dispose() {
    if (widget.layer == null) {
      unawaited(_ownedLayer?.dispose());
    } else {
      _layer.controller.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
