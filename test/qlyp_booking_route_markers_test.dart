import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/services/qlyp_booking_route_markers.dart';

void main() {
  group('bookingRouteMarkerLabel', () {
    test('pickup and destination', () {
      expect(
        bookingRouteMarkerLabel(BookingRouteMarkerRole.pickup),
        'A',
      );
      expect(
        bookingRouteMarkerLabel(BookingRouteMarkerRole.destination),
        'B',
      );
    });

    test('numbered stops are 1-based', () {
      expect(
        bookingRouteMarkerLabel(
          BookingRouteMarkerRole.intermediateStop,
          stopIndex: 0,
        ),
        '1',
      );
      expect(
        bookingRouteMarkerLabel(
          BookingRouteMarkerRole.intermediateStop,
          stopIndex: 9,
        ),
        '10',
      );
    });
  });

  test('renderBookingRouteMarkerPng returns PNG bytes', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final day = await renderBookingRouteMarkerPng(
      label: 'A',
      nightMode: false,
    );
    final night = await renderBookingRouteMarkerPng(
      label: '2',
      nightMode: true,
    );
    expect(day.length, greaterThan(8));
    expect(night.length, greaterThan(8));
    expect(day[0], 0x89);
    expect(day[1], 0x50);
  });
}