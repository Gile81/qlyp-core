import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:qlyp_core/models/geo_lat_lng.dart';
import 'package:qlyp_core/ride_tracking/route_geometry.dart';

import 'geohash_query_bounds.dart';
import 'nearby_vehicle_marker_resolve.dart';
import 'nearby_vehicle_models.dart';
import 'nearby_vehicles_constants.dart';

/// Listens to `nearby_vehicles` around a passenger point inside a zone.
class QlypNearbyVehiclesController extends ChangeNotifier {
  QlypNearbyVehiclesController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  final Map<String, NearbyVehicleSnapshot> _byPresenceId = {};
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _subs =
      [];

  bool _listening = false;
  String? _zoneId;
  double? _lat;
  double? _lng;
  String? _filterServiceId;

  List<NearbyVehicleSnapshot> _visible = const [];

  List<NearbyVehicleSnapshot> get vehicles => _visible;
  bool get isListening => _listening;

  void start({
    required String zoneId,
    required double lat,
    required double lng,
    String? filterServiceId,
  }) {
    final trimmedZone = zoneId.trim();
    if (trimmedZone.isEmpty) {
      stop();
      return;
    }

    final sameQuery = _listening &&
        _zoneId == trimmedZone &&
        _lat == lat &&
        _lng == lng &&
        _filterServiceId == filterServiceId?.trim();
    if (sameQuery) return;

    stop();

    _zoneId = trimmedZone;
    _lat = lat;
    _lng = lng;
    _filterServiceId = filterServiceId?.trim();
    _listening = true;

    final bounds = geohashQueryBounds(
      lat: lat,
      lng: lng,
      radiusMeters: kNearbyVehiclesRadiusMeters,
      precision: kNearbyVehiclesGeohashPrecision,
    );

    for (final (start, end) in bounds) {
      Query<Map<String, dynamic>> query = _firestore
          .collection(kNearbyVehiclesCollection)
          .where('zoneId', isEqualTo: trimmedZone)
          .where('geohash', isGreaterThanOrEqualTo: start)
          .where('geohash', isLessThanOrEqualTo: end);

      final tier = _filterServiceId;
      if (tier != null && tier.isNotEmpty) {
        query = query.where('serviceIds', arrayContains: tier);
      }

      final sub = query.snapshots().listen(
        (snap) => _onQuerySnapshot(snap),
        onError: (_) => _recomputeVisible(),
      );
      _subs.add(sub);
    }

    _recomputeVisible();
  }

  void stop() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    _subs.clear();
    _listening = false;
    _zoneId = null;
    _lat = null;
    _lng = null;
    _filterServiceId = null;
    _byPresenceId.clear();
    if (_visible.isNotEmpty) {
      _visible = const [];
      notifyListeners();
    }
  }

  void _onQuerySnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    final lat = _lat;
    final lng = _lng;
    if (lat == null || lng == null) return;

    for (final change in snap.docChanges) {
      final doc = change.doc;
      if (change.type == DocumentChangeType.removed) {
        _byPresenceId.remove(doc.id);
        continue;
      }
      final parsed = NearbyVehicleSnapshot.fromFirestoreDoc(
        doc,
        passengerLat: lat,
        passengerLng: lng,
      );
      if (parsed == null) {
        _byPresenceId.remove(doc.id);
      } else {
        _byPresenceId[doc.id] = parsed;
      }
    }
    _recomputeVisible();
  }

  void _recomputeVisible() {
    final lat = _lat;
    final lng = _lng;
    if (lat == null || lng == null) return;

    final refreshed = _byPresenceId.values.map((vehicle) {
      return NearbyVehicleSnapshot(
        presenceId: vehicle.presenceId,
        lat: vehicle.lat,
        lng: vehicle.lng,
        heading: vehicle.heading,
        primaryServiceId: vehicle.primaryServiceId,
        serviceIds: vehicle.serviceIds,
        zoneId: vehicle.zoneId,
        updatedAt: vehicle.updatedAt,
        distanceMeters: haversineDistanceMeters(
          GeoLatLng(lat, lng),
          GeoLatLng(vehicle.lat, vehicle.lng),
        ),
      );
    });

    final next = selectNearestNearbyVehicles(
      refreshed,
      maxRadiusMeters: kNearbyVehiclesRadiusMeters,
      maxCount: kNearbyVehiclesMaxCount,
    );

    if (nearbyVehicleListEquals(_visible, next)) return;
    _visible = next;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

bool nearbyVehicleListEquals(
  List<NearbyVehicleSnapshot> a,
  List<NearbyVehicleSnapshot> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left.presenceId != right.presenceId) return false;
    if (left.lat != right.lat || left.lng != right.lng) return false;
    if (left.heading != right.heading) return false;
  }
  return true;
}
