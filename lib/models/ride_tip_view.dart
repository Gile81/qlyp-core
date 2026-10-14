import '../billing/ride_tip_reminder.dart';
import '../constants/billing_contract.dart';
import 'billing_map_helpers.dart';
import 'ride_tip_option_view.dart';

/// Passenger tip prompt state on an order (server fields only).
class RideTipView {
  const RideTipView({
    this.tipAmount,
    this.tipStatus,
    this.tipOptions = const [],
    this.tipDeadlineAt,
    this.tipPromptState,
  });

  final double? tipAmount;
  final String? tipStatus;
  final List<RideTipOptionView> tipOptions;
  final String? tipDeadlineAt;
  final String? tipPromptState;

  factory RideTipView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const RideTipView();
    }
    return RideTipView(
      tipAmount: billingAsDouble(raw[BillingContract.fieldTipAmount]),
      tipStatus: billingOptionalString(raw[BillingContract.fieldTipStatus]),
      tipOptions: RideTipOptionView.listFromOrderField(
        raw[BillingContract.fieldTipOptions],
      ),
      tipDeadlineAt:
          billingOptionalString(raw[BillingContract.fieldTipDeadlineAt]),
      tipPromptState:
          billingOptionalString(raw[BillingContract.fieldTipPromptState]),
    );
  }

  factory RideTipView.fromOrderMap(Map<String, dynamic> order) =>
      RideTipView.fromMap(order);

  bool canShowReminder({DateTime? now}) {
    return canShowRideTipReminder(
      tipOptions: tipOptions,
      tipAmount: tipAmount,
      tipDeadlineAtIso: tipDeadlineAt,
      tipPromptState: tipPromptState,
      now: now ?? DateTime.now().toUtc(),
    );
  }
}
