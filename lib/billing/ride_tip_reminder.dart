import '../constants/billing_contract.dart';
import '../models/ride_tip_option_view.dart';

/// Whether the passenger app may show the post-ride tip reminder card.
bool canShowRideTipReminder({
  required List<RideTipOptionView> tipOptions,
  required Object? tipAmount,
  required String? tipDeadlineAtIso,
  required String? tipPromptState,
  required DateTime now,
}) {
  if (tipOptions.isEmpty) return false;
  if (tipAmount != null) return false;
  final deadlineRaw = tipDeadlineAtIso?.trim() ?? '';
  if (deadlineRaw.isEmpty) return false;
  final deadline = DateTime.tryParse(deadlineRaw);
  if (deadline == null || !now.isBefore(deadline)) return false;
  final state = tipPromptState?.trim() ?? '';
  return state == BillingContract.tipPromptStatePending ||
      state == BillingContract.tipPromptStateLater;
}

bool canShowRideTipReminderFromOrder(
  Map<String, dynamic> order, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now().toUtc();
  return canShowRideTipReminder(
    tipOptions: RideTipOptionView.listFromOrderField(
      order[BillingContract.fieldTipOptions],
    ),
    tipAmount: order[BillingContract.fieldTipAmount],
    tipDeadlineAtIso:
        order[BillingContract.fieldTipDeadlineAt]?.toString(),
    tipPromptState:
        order[BillingContract.fieldTipPromptState]?.toString(),
    now: clock,
  );
}
