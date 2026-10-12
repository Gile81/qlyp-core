import '../constants/shared_ride_contract.dart';

/// Passenger-facing projection of a shared trip (`orders.shared_ride_view`).
class SharedRideView {
  const SharedRideView({
    this.otherPassengerFirstName,
    this.otherPassengerOnBoard,
    this.stopsBeforeMyPickup,
    this.stopsBeforeMyDropoff,
    this.isShared,
    this.priceIfShared,
    this.priceIfSolo,
    this.sharedRideFallback,
  });

  final String? otherPassengerFirstName;
  final bool? otherPassengerOnBoard;
  final int? stopsBeforeMyPickup;
  final int? stopsBeforeMyDropoff;
  final bool? isShared;
  final double? priceIfShared;
  final double? priceIfSolo;
  final String? sharedRideFallback;

  factory SharedRideView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const SharedRideView();
    }
    return SharedRideView(
      otherPassengerFirstName:
          _optionalString(raw[SharedRideContract.viewOtherPassengerFirstName]),
      otherPassengerOnBoard:
          _optionalBool(raw[SharedRideContract.viewOtherPassengerOnBoard]),
      stopsBeforeMyPickup:
          _optionalInt(raw[SharedRideContract.viewStopsBeforeMyPickup]),
      stopsBeforeMyDropoff:
          _optionalInt(raw[SharedRideContract.viewStopsBeforeMyDropoff]),
      isShared: _optionalBool(raw[SharedRideContract.viewIsShared]),
      priceIfShared:
          _optionalDouble(raw[SharedRideContract.viewPriceIfShared]),
      priceIfSolo: _optionalDouble(raw[SharedRideContract.viewPriceIfSolo]),
      sharedRideFallback:
          _optionalString(raw[SharedRideContract.viewSharedRideFallback]),
    );
  }

  bool get isMarketplaceFallback =>
      sharedRideFallback == SharedRideContract.sharedRideFallbackMarketplace;

  static String? _optionalString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static bool? _optionalBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v == 1 || v == '1' || v == 'true') return true;
    if (v == 0 || v == '0' || v == 'false') return false;
    return null;
  }

  static int? _optionalInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim());
  }

  static double? _optionalDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }
}
