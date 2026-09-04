import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qlyp_core/services/firestore_service.dart';
import 'package:qlyp_core/services/map_service.dart';

/// Reads admin-published service to SVG marker mappings from Firestore.
///
/// Document: settings/service_markers with fields markers and active
/// (published by qlyp-admin). Keys are Firestore service document ids today;
/// stable service_key values (PRD 28.4) will replace ids in Sprint 2.
class QlypServiceMarkerRegistry {
  QlypServiceMarkerRegistry({FirebaseFirestore? firestore})
      : _firestore = firestore ?? QlypFirestoreService.firestore;

  final FirebaseFirestore _firestore;

  static const String collection = 'settings';
  static const String documentId = 'service_markers';

  Map<String, String>? _cached;

  Map<String, String>? get cached => _cached == null ? null : Map.unmodifiable(_cached!);

  Future<Map<String, String>> fetch({bool forceRefresh = false}) async {
    if (forceRefresh || _cached == null) {
      _cached = await _loadFromFirestore();
    }
    return Map.unmodifiable(_cached!);
  }

  Future<Map<String, String>> refresh() => fetch(forceRefresh: true);

  void clearCache() => _cached = null;

  Future<String?> filenameForService(String serviceId) async {
    final map = await fetch();
    return map[serviceId];
  }

  static String assetPathForFilename(String filename) {
    if (filename.contains('/')) {
      return filename;
    }
    return '${QlypMapService.markersPath}/$filename';
  }

  Future<Map<String, String>> _loadFromFirestore() async {
    try {
      final snap = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      if (snap.exists) {
        final data = snap.data();
        if (data != null && data.isNotEmpty) {
          return _parseDocument(data);
        }
      }
    } catch (_) {
      // Missing doc, permission, or network — caller gets empty map.
    }
    return {};
  }

  static Map<String, String> _parseDocument(Map<String, dynamic> data) {
    final markersField = data['markers'];
    if (markersField is! Map) {
      return _parseLegacyFlatMap(data);
    }

    final markers = <String, String>{};
    markersField.forEach((key, value) {
      if (key is String && value is String && value.trim().isNotEmpty) {
        markers[key] = value.trim();
      }
    });

    final activeField = data['active'];
    if (activeField is! Map) {
      return markers;
    }

    return Map.fromEntries(
      markers.entries.where((entry) {
        final active = activeField[entry.key];
        if (active == null) {
          return true;
        }
        return active == true;
      }),
    );
  }

  static Map<String, String> _parseLegacyFlatMap(Map<String, dynamic> data) {
    final result = <String, String>{};
    data.forEach((key, value) {
      if (key == 'markers' || key == 'active') {
        return;
      }
      if (value is String && value.trim().endsWith('.svg')) {
        result[key] = value.trim();
      }
    });
    return result;
  }
}
