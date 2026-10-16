import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/booking/booking_defaults_to_offers.dart';

void main() {
  group('bookingDefaultsToOffers', () {
    test('logistique group defaults to offers', () {
      expect(
        bookingDefaultsToOffers(groupKey: 'logistique'),
        isTrue,
      );
    });

    test('demenagement group defaults to offers', () {
      expect(
        bookingDefaultsToOffers(groupKey: 'demenagement'),
        isTrue,
      );
    });

    test('livraison express does not', () {
      expect(
        bookingDefaultsToOffers(groupKey: 'livraison_express'),
        isFalse,
      );
    });

    test('courses pillar does not', () {
      expect(
        bookingDefaultsToOffers(pillarKey: 'courses'),
        isFalse,
      );
    });

    test('unknown group is false', () {
      expect(
        bookingDefaultsToOffers(groupKey: 'towing'),
        isFalse,
      );
    });
  });

  group('primaryGroupActivationKey', () {
    test('reads group from mainServiceIDs', () {
      expect(
        primaryGroupActivationKey({
          'mainServiceIDs': ['c36QVpfmfiwPrbh3R0Oz'],
        }),
        'logistique',
      );
    });
  });

  group('readBiddingEnabledFromZoneDoc', () {
    test('reads services layer flag', () {
      expect(
        readBiddingEnabledFromZoneDoc({
          'services': {'bidding_enabled': true},
        }),
        isTrue,
      );
    });

    test('defaults false when absent', () {
      expect(readBiddingEnabledFromZoneDoc({}), isFalse);
    });
  });
}
