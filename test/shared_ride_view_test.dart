import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/shared_ride_contract.dart';
import 'package:qlyp_core/models/shared_ride_view.dart';

void main() {
  test('fromMap full payload', () {
    final view = SharedRideView.fromMap({
      SharedRideContract.viewOtherPassengerFirstName: 'Alex',
      SharedRideContract.viewOtherPassengerOnBoard: true,
      SharedRideContract.viewStopsBeforeMyPickup: 1,
      SharedRideContract.viewStopsBeforeMyDropoff: 2,
      SharedRideContract.viewIsShared: true,
      SharedRideContract.viewPriceIfShared: 18.5,
      SharedRideContract.viewPriceIfSolo: 24.0,
    });
    expect(view.otherPassengerFirstName, 'Alex');
    expect(view.otherPassengerOnBoard, isTrue);
    expect(view.stopsBeforeMyPickup, 1);
    expect(view.stopsBeforeMyDropoff, 2);
    expect(view.isShared, isTrue);
    expect(view.priceIfShared, 18.5);
    expect(view.priceIfSolo, 24.0);
    expect(view.isMarketplaceFallback, isFalse);
  });

  test('fromMap partial and empty', () {
    expect(SharedRideView.fromMap(null), const SharedRideView());
    expect(SharedRideView.fromMap({}).isShared, isNull);
    final fallback = SharedRideView.fromMap({
      SharedRideContract.viewSharedRideFallback:
          SharedRideContract.sharedRideFallbackMarketplace,
    });
    expect(fallback.isMarketplaceFallback, isTrue);
  });
}
