import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/billing_contract.dart';
import 'package:qlyp_core/models/ride_tip_view.dart';

void main() {
  test('RideTipView.fromMap tolerates partial order fields', () {
    final view = RideTipView.fromOrderMap({
      BillingContract.fieldTipOptions: [
        {BillingContract.tipOptionPct: 10, BillingContract.tipOptionAmount: 5.46},
      ],
      BillingContract.fieldTipPromptState: BillingContract.tipPromptStatePending,
      BillingContract.fieldTipDeadlineAt: '2026-12-01T00:00:00.000Z',
    });
    expect(view.tipOptions, hasLength(1));
    expect(view.tipAmount, isNull);
    expect(
      view.canShowReminder(now: DateTime.utc(2026, 6, 1)),
      isTrue,
    );
  });
}
