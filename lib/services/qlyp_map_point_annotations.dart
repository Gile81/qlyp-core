import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Upsert/remove point annotations on a Mapbox map (shared client booking + tracking).
class QlypMapPointAnnotationController {
  QlypMapPointAnnotationController();

  PointAnnotationManager? _manager;
  final Map<String, PointAnnotation> _byKey = {};

  PointAnnotationManager? get manager => _manager;

  Future<void> attach(MapboxMap map) async {
    _manager ??= await map.annotations.createPointAnnotationManager();
  }

  Future<void> upsert({
    required String key,
    required double lat,
    required double lng,
    required String iconImage,
    IconAnchor iconAnchor = IconAnchor.CENTER,
  }) async {
    final manager = _manager;
    if (manager == null) return;
    final geometry = Point(coordinates: Position(lng, lat));
    final existing = _byKey[key];
    if (existing != null) {
      existing.geometry = geometry;
      existing.iconImage = iconImage;
      existing.iconAnchor = iconAnchor;
      await manager.update(existing);
      return;
    }
    final created = await manager.create(
      PointAnnotationOptions(
        geometry: geometry,
        iconImage: iconImage,
        iconAnchor: iconAnchor,
      ),
    );
    _byKey[key] = created;
  }

  Future<void> remove(String key) async {
    final existing = _byKey.remove(key);
    final manager = _manager;
    if (existing == null || manager == null) return;
    try {
      await manager.delete(existing);
    } catch (_) {}
  }

  Future<void> removeKeys(Iterable<String> keys) async {
    for (final key in keys) {
      await remove(key);
    }
  }

  void clearKeys() => _byKey.clear();
}
