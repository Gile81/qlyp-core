import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/billing/ride_tip_reminder.dart';
import 'package:qlyp_core/constants/billing_contract.dart';
import 'package:qlyp_core/models/ride_tip_option_view.dart';

void main() {
  final options = [const RideTipOptionView(pct: 10, amount: 5)];
  final deadline =
      DateTime.utc(2026, 6, 1, 12).add(const Duration(hours: 72)).toIso8601String();
  final beforeDeadline = DateTime.utc(2026, 6, 2);

  test('canShowRideTipReminder true for pending with options and no tip', () {
    expect(
      canShowRideTipReminder(
        tipOptions: options,
        tipAmount: null,
        tipDeadlineAtIso: deadline,
        tipPromptState: BillingContract.tipPromptStatePending,
        now: beforeDeadline,
      ),
      isTrue,
    );
  });

  test('canShowRideTipReminder true for later', () {
    expect(
      canShowRideTipReminder(
        tipOptions: options,
        tipAmount: null,
        tipDeadlineAtIso: deadline,
        tipPromptState: BillingContract.tipPromptStateLater,
        now: beforeDeadline,
      ),
      isTrue,
    );
  });

  test('canShowRideTipReminder false without tip_options', () {
    expect(
      canShowRideTipReminder(
        tipOptions: const [],
        tipAmount: null,
        tipDeadlineAtIso: deadline,
        tipPromptState: BillingContract.tipPromptStatePending,
        now: beforeDeadline,
      ),
      isFalse,
    );
  });

  test('canShowRideTipReminder false when tip_amount set', () {
    expect(
      canShowRideTipReminder(
        tipOptions: options,
        tipAmount: 4,
        tipDeadlineAtIso: deadline,
        tipPromptState: BillingContract.tipPromptStatePending,
        now: beforeDeadline,
      ),
      isFalse,
    );
  });

  test('canShowRideTipReminder false after deadline', () {
    expect(
      canShowRideTipReminder(
        tipOptions: options,
        tipAmount: null,
        tipDeadlineAtIso: deadline,
        tipPromptState: BillingContract.tipPromptStatePending,
        now: DateTime.utc(2026, 6, 10),
      ),
      isFalse,
    );
  });

  test('canShowRideTipReminder false for reminded/declined/completed', () {
    for (final state in [
      BillingContract.tipPromptStateReminded,
      BillingContract.tipPromptStateDeclined,
      BillingContract.tipPromptStateCompleted,
    ]) {
      expect(
        canShowRideTipReminder(
          tipOptions: options,
          tipAmount: null,
          tipDeadlineAtIso: deadline,
          tipPromptState: state,
          now: beforeDeadline,
        ),
        isFalse,
        reason: state,
      );
    }
  });

  test('canShowRideTipReminderFromOrder reads order map', () {
    expect(
      canShowRideTipReminderFromOrder(
        {
          BillingContract.fieldTipOptions: [
            {BillingContract.tipOptionPct: 10, BillingContract.tipOptionAmount: 5},
          ],
          BillingContract.fieldTipDeadlineAt: deadline,
          BillingContract.fieldTipPromptState: BillingContract.tipPromptStatePending,
        },
        now: beforeDeadline,
      ),
      isTrue,
    );
  });
}
