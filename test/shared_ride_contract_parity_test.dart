import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/shared_ride_contract.dart';

void main() {
  late Map<String, dynamic> contract;

  setUpAll(() {
    final path = '${Directory.current.path}/test/fixtures/shared_ride_contract.json';
    contract = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  });

  List<String> keysOf(Map<String, dynamic> section) =>
      section.keys.toList()..sort();

  test('contract version is 2', () {
    expect(contract['version'], SharedRideContract.contractVersion);
  });

  test('order clientWrite keys match constants', () {
    final orderFields = contract['orderFields'] as Map<String, dynamic>;
    final client = orderFields['clientWrite'] as Map<String, dynamic>;
    expect(keysOf(client), [
      SharedRideContract.fieldSharedRideOptIn,
      SharedRideContract.fieldSharedRideSeats,
    ]);
  });

  test('order serverWrite keys match constants', () {
    final orderFields = contract['orderFields'] as Map<String, dynamic>;
    final server = orderFields['serverWrite'] as Map<String, dynamic>;
    expect(keysOf(server), [
      SharedRideContract.fieldQuoteSharedTotal,
      SharedRideContract.fieldQuoteSharedTotalBeforeCoupon,
      SharedRideContract.fieldQuoteSoloTotal,
      SharedRideContract.fieldQuoteSoloTotalBeforeCoupon,
      SharedRideContract.fieldSharedTripId,
      SharedRideContract.fieldSharedRideBoardedAt,
      SharedRideContract.fieldSharedRideDispatchPhase,
      SharedRideContract.fieldSharedRideDroppedAt,
      SharedRideContract.fieldSharedRideFallback,
      SharedRideContract.fieldSharedRideFinalRideTotal,
      SharedRideContract.fieldSharedRideSeats,
      SharedRideContract.fieldSharedRideStatus,
      SharedRideContract.fieldSharedRideView,
      SharedRideContract.fieldSharedRideWasShared,
    ]);
  });

  test('priceQuoteRideFields keys match constants', () {
    final pq = contract['priceQuoteRideFields'] as Map<String, dynamic>;
    expect(keysOf(pq), [
      SharedRideContract.fieldQuoteSharedTotal,
      SharedRideContract.fieldQuoteSoloTotal,
      SharedRideContract.fieldSharedRideAvailable,
      SharedRideContract.fieldSharedRideDiscountPct,
    ]);
  });

  test('sharedRideView keys match constants', () {
    final view = contract['sharedRideView'] as Map<String, dynamic>;
    expect(keysOf(view), [
      SharedRideContract.viewIsShared,
      SharedRideContract.viewOtherPassengerFirstName,
      SharedRideContract.viewOtherPassengerOnBoard,
      SharedRideContract.viewPriceIfShared,
      SharedRideContract.viewPriceIfSolo,
      SharedRideContract.viewSharedRideFallback,
      SharedRideContract.viewStopsBeforeMyDropoff,
      SharedRideContract.viewStopsBeforeMyPickup,
    ]);
  });

  test('sharedTripDocument includes nextStopIndex and collection', () {
    final doc = contract['sharedTripDocument'] as Map<String, dynamic>;
    expect(doc['collection'], SharedRideContract.sharedTripsCollection);
    final fields = doc['fields'] as Map<String, dynamic>;
    expect(fields.containsKey(SharedRideContract.tripFieldNextStopIndex), isTrue);
    expect(keysOf(fields), [
      SharedRideContract.tripFieldBookings,
      SharedRideContract.tripFieldDriverId,
      SharedRideContract.tripFieldJoinOpen,
      SharedRideContract.tripFieldLockVersion,
      SharedRideContract.tripFieldNextStopIndex,
      SharedRideContract.tripFieldSeatCapacity,
      SharedRideContract.tripFieldSeatsUsed,
      SharedRideContract.tripFieldServiceId,
      SharedRideContract.tripFieldStatus,
      SharedRideContract.tripFieldStops,
      SharedRideContract.tripFieldZoneId,
    ]);
  });

  test('sharedTripStop and booking keys match constants', () {
    final stop = contract['sharedTripStop'] as Map<String, dynamic>;
    expect(keysOf(stop), [
      SharedRideContract.stopFieldAddress,
      SharedRideContract.stopFieldKind,
      SharedRideContract.stopFieldLat,
      SharedRideContract.stopFieldLng,
      SharedRideContract.stopFieldOrderId,
      SharedRideContract.stopFieldStatus,
    ]);
    final booking = contract['sharedTripBooking'] as Map<String, dynamic>;
    expect(keysOf(booking), [
      SharedRideContract.bookingFieldBoardedAt,
      SharedRideContract.bookingFieldDroppedAt,
      SharedRideContract.bookingFieldOrderId,
      SharedRideContract.bookingFieldPlannedDurationS,
      SharedRideContract.bookingFieldSeats,
      SharedRideContract.bookingFieldSoloDurationS,
      SharedRideContract.bookingFieldStatus,
      SharedRideContract.bookingFieldUserId,
    ]);
  });

  test('notification types and channels match constants', () {
    final notifications = contract['notifications'] as Map<String, dynamic>;
    final passenger = notifications['passenger'] as Map<String, dynamic>;
    expect(passenger['type'], SharedRideContract.notificationTypeSharedRideCoPassenger);
    expect(
      passenger['channelId'],
      SharedRideContract.notificationChannelRideUpdates,
    );
    final fallback = notifications['passengerMarketplaceFallback'] as Map<String, dynamic>;
    expect(
      fallback['type'],
      SharedRideContract.notificationTypeSharedRideMarketplaceFallback,
    );
    final driver = notifications['driver'] as Map<String, dynamic>;
    expect(
      driver['type'],
      SharedRideContract.notificationTypeSharedRidePassengerJoined,
    );
    expect(driver['channelId'], SharedRideContract.notificationChannelDispatch);
  });

  test('every jsonObjectKeys constant appears in the JSON contract', () {
    final blob = jsonEncode(contract);
    for (final key in SharedRideContract.jsonObjectKeys) {
      expect(blob.contains('"$key"'), isTrue, reason: 'missing key $key in JSON');
    }
  });

  test('every jsonEnumValues constant appears in the JSON contract', () {
    final blob = jsonEncode(contract);
    for (final value in SharedRideContract.jsonEnumValues) {
      expect(blob.contains('"$value"'), isTrue, reason: 'missing enum $value in JSON');
    }
  });
}
