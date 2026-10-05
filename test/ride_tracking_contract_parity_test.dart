import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/ride_tracking_contract.dart';

void main() {
  test('RideTrackingContract exposes stable wire names', () {
    expect(RideTrackingContract.phaseDriverEnRoute, 'driver_en_route');
    expect(RideTrackingContract.liveDriverDoc, 'driver');
    expect(RideTrackingContract.fieldRoutePolyline6, 'routePolyline6');
    expect(RideTrackingContract.callableCompleteRide, 'completeRide');
  });
}
