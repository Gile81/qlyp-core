import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/route_booking_models.dart';

void main() {
  test('RouteBookSeatResult parses booking response', () {
    final result = RouteBookSeatResult.fromJson({
      'bookingId': 'bk1',
      'status': 'confirmed',
      'pricePerPassenger': 26.32,
      'bookingFeeTotal': 7.89,
      'guestLinkUrl': 'https://example.com/guest?token=abc',
      'respondByAt': '2026-10-01T18:00:00.000Z',
    });
    expect(result.bookingId, 'bk1');
    expect(result.status, 'confirmed');
    expect(result.pricePerPassenger, 26.32);
    expect(result.bookingFeeTotal, 7.89);
    expect(result.guestLinkUrl, contains('token=abc'));
    expect(result.respondByAt?.toUtc().hour, 18);
  });

  test('RouteBookingCancelResult parses refund fields', () {
    final result = RouteBookingCancelResult.fromJson({
      'bookingId': 'bk2',
      'status': 'cancelled_by_passenger',
      'refundedAmount': 7.89,
      'refundPolicyApplied': 'full_fee_refund',
    });
    expect(result.refundedAmount, 7.89);
    expect(result.refundPolicyApplied, 'full_fee_refund');
  });

  test('RouteBookingPaymentConfirmResult parses status', () {
    final result = RouteBookingPaymentConfirmResult.fromJson({
      'bookingId': 'bk3',
      'status': 'pending_driver',
    });
    expect(result.status, 'pending_driver');
  });
}
