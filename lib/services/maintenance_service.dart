import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Maintenance mode state from settings/maintenance (S4-6c-1).
class MaintenanceState {
  const MaintenanceState({
    required this.customerEnabled,
    required this.driverEnabled,
    required this.messageFr,
    required this.messageEn,
    required this.bypassUids,
  });

  final bool customerEnabled;
  final bool driverEnabled;
  final String messageFr;
  final String messageEn;
  final List<String> bypassUids;

  /// Localised message -- falls back to the other language if the primary is empty.
  String message({required bool french}) {
    final fr = messageFr.trim();
    final en = messageEn.trim();
    return french ? (fr.isNotEmpty ? fr : en) : (en.isNotEmpty ? en : fr);
  }

  factory MaintenanceState.fromFirestore(Map<String, dynamic> json) {
    return MaintenanceState(
      customerEnabled: json['customer_enabled'] == true,
      driverEnabled: json['driver_enabled'] == true,
      messageFr: (json['message_fr'] as String? ?? '').trim(),
      messageEn: (json['message_en'] as String? ?? '').trim(),
      bypassUids: _parseList(json['bypass_uids']),
    );
  }

  static List<String> _parseList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

/// Listens to settings/maintenance and exposes maintenance state (S4-6c-1).
///
/// Network failures are swallowed -- null state means not blocked.
class MaintenanceService {
  const MaintenanceService._();

  static const _collection = 'settings';
  static const _document = 'maintenance';

  /// Real-time stream of maintenance state. Emits null on error or missing doc.
  static Stream<MaintenanceState?> stream() {
    return FirebaseFirestore.instance
        .collection(_collection)
        .doc(_document)
        .snapshots()
        .map((snap) {
          final data = snap.data();
          if (data == null) return null;
          return MaintenanceState.fromFirestore(data);
        })
        .handleError((Object e) {
          debugPrint('MaintenanceService.stream: $e');
          return null;
        });
  }

  /// One-shot read of the current maintenance state.
  /// Returns null on network error (= not blocked).
  static Future<MaintenanceState?> fetch() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(_document)
          .get();
      final data = doc.data();
      if (data == null) return null;
      return MaintenanceState.fromFirestore(data);
    } catch (e) {
      debugPrint('MaintenanceService.fetch: $e');
      return null;
    }
  }

  /// Returns true when [uid] is blocked for [appType].
  ///
  /// Rules (in priority order):
  ///   1. [state] == null => not blocked (network error / document absent).
  ///   2. [uid] in [state.bypassUids] => not blocked.
  ///   3. appType == 'customer' => use state.customerEnabled.
  ///      appType == 'driver'   => use state.driverEnabled.
  static bool isBlocked(
    MaintenanceState? state, {
    required String appType,
    required String uid,
  }) {
    if (state == null) return false;
    if (state.bypassUids.contains(uid)) return false;
    return appType == 'customer'
        ? state.customerEnabled
        : state.driverEnabled;
  }
}