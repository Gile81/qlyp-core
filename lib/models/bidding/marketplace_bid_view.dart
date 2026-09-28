import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-only view of a single bid document in `active_rides/{orderId}/bids`.
///
/// All fields are nullable — display what exists, never crash on missing data.
/// The server is the sole source of all price/ETA values.
class MarketplaceBidView {
  const MarketplaceBidView({
    required this.bidId,
    this.driverName,
    this.driverPhotoUrl,
    this.driverRating,
    this.vehicleLabel,
    this.etaMinutes,
    this.amount,
    this.status,
    this.round,
    this.expiresAt,
  });

  final String bidId;
  final String? driverName;
  final String? driverPhotoUrl;
  final double? driverRating;
  final String? vehicleLabel;
  final int? etaMinutes;

  /// Amount TTC (all taxes included) — server-written.
  final double? amount;

  final String? status;

  /// Bid round (1 = initial, 2 = counter, ...).
  final int? round;

  final DateTime? expiresAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory MarketplaceBidView.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return MarketplaceBidView(bidId: doc.id);
    return MarketplaceBidView.fromMap(doc.id, data);
  }

  factory MarketplaceBidView.fromMap(String id, Map<String, dynamic> data) {
    double? n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    int? ni(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse('$v');
    }

    final display = data['driver_display'];
    final displayMap = display is Map
        ? Map<String, dynamic>.from(display)
        : <String, dynamic>{};

    DateTime? expiresAt;
    final raw = data['expires_at'];
    if (raw is Timestamp) {
      expiresAt = raw.toDate();
    } else if (raw is int) {
      expiresAt = DateTime.fromMillisecondsSinceEpoch(raw);
    }

    return MarketplaceBidView(
      bidId: id,
      driverName: displayMap['name']?.toString(),
      driverPhotoUrl: displayMap['photo_url']?.toString(),
      driverRating: n(displayMap['rating']),
      vehicleLabel: displayMap['vehicle_label']?.toString(),
      etaMinutes: ni(data['eta_minutes']),
      amount: n(data['amount']),
      status: data['status']?.toString(),
      round: ni(data['round']),
      expiresAt: expiresAt,
    );
  }
}