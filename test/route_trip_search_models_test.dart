import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/route_trip_search_models.dart';

void main() {
  test('RouteTripSearchResult parses server pricing fields', () {
    final result = RouteTripSearchResult.fromJson({
      'tripId': 't1',
      'departureAt': '2026-10-01T14:00:00.000Z',
      'durationMin': 120,
      'origin': {'label': 'Laval'},
      'destination': {'label': 'Trois-Rivières'},
      'pickupPoint': {'lat': 45.55, 'lng': -73.45, 'label': 'Ramassage'},
      'pickupDetourKm': 3.2,
      'dropoffDetourKm': 1.1,
      'seatsAvailable': 2,
      'pricePerPassengerNow': 26.32,
      'bookingFeePerPassenger': 3.95,
      'totalPerPassenger': 30.27,
      'totalForRequest': 30.27,
      'pricePerSeatIfFull': 22.0,
      'priceMayDrop': true,
      'seatPriceToDriver': 26.32,
      'instantBook': false,
      'preferences': {'smoking': false, 'luggage': true, 'animals': false},
      'driver': {
        'firstName': 'Alex',
        'lastInitial': 'T',
        'photoUrl': 'https://example.com/p.jpg',
        'ratingAvg': 4.8,
        'ratingCount': 12,
        'verified': true,
      },
      'vehicle': {'make': 'Toyota', 'model': 'Corolla', 'color': 'Grey'},
    });

    expect(result.totalPerPassenger, 30.27);
    expect(result.priceMayDrop, isTrue);
    expect(result.driver.firstName, 'Alex');
    expect(result.vehicle.make, 'Toyota');
  });

  test('RouteTripDetail includes polyline and cancellation policy', () {
    final detail = RouteTripDetail.fromJson({
      'tripId': 't1',
      'departureAt': '2026-10-01T14:00:00.000Z',
      'durationMin': 90,
      'origin': {'label': 'A'},
      'destination': {'label': 'B'},
      'pickupPoint': {'lat': 1, 'lng': 2, 'label': 'P'},
      'pickupDetourKm': 0,
      'dropoffDetourKm': 0,
      'seatsAvailable': 3,
      'pricePerPassengerNow': 10,
      'bookingFeePerPassenger': 1.5,
      'totalPerPassenger': 11.5,
      'totalForRequest': 11.5,
      'pricePerSeatIfFull': 9,
      'priceMayDrop': true,
      'seatPriceToDriver': 10,
      'instantBook': true,
      'preferences': {},
      'driver': {
        'firstName': 'Jo',
        'lastInitial': 'D',
        'photoUrl': '',
        'ratingCount': 0,
        'verified': true,
      },
      'vehicle': {'make': 'Honda', 'model': 'Civic', 'color': 'Blue'},
      'routePolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
      'waypoints': [
        {'lat': 45.5, 'lng': -73.57, 'label': ''},
      ],
      'pickupPoints': [],
      'priceBySeatsBooked': [12.0, 10.5, 9.0],
      'cancellationPolicyFr': 'Politique FR',
      'cancellationPolicyEn': 'Policy EN',
    });

    expect(detail.routePolyline, isNotEmpty);
    expect(detail.priceBySeatsBooked, [12.0, 10.5, 9.0]);
    expect(detail.cancellationPolicyForLanguage('fr'), 'Politique FR');
    expect(detail.cancellationPolicyForLanguage('en'), 'Policy EN');
  });
}
