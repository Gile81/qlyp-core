import '../constants/billing_contract.dart';
import 'billing_map_helpers.dart';

/// Server payout fields on an order or marketplace bid document.
class DriverPayoutView {
  const DriverPayoutView({
    this.driverPayoutEstimate,
    this.driverPayoutToll,
    this.driverCourseTaxesToRemit,
    this.driverNetEstimate,
  });

  final double? driverPayoutEstimate;
  final double? driverPayoutToll;
  final double? driverCourseTaxesToRemit;
  final double? driverNetEstimate;

  bool get hasEstimate => driverPayoutEstimate != null;

  factory DriverPayoutView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const DriverPayoutView();
    }
    return DriverPayoutView(
      driverPayoutEstimate: billingAsDouble(
        raw[BillingContract.fieldDriverPayoutEstimate],
      ),
      driverPayoutToll:
          billingAsDouble(raw[BillingContract.fieldDriverPayoutToll]),
      driverCourseTaxesToRemit: billingAsDouble(
        raw[BillingContract.fieldDriverCourseTaxesToRemit],
      ),
      driverNetEstimate:
          billingAsDouble(raw[BillingContract.fieldDriverNetEstimate]),
    );
  }

  factory DriverPayoutView.fromOrderMap(Map<String, dynamic>? order) {
    return DriverPayoutView.fromMap(order);
  }

  factory DriverPayoutView.fromBidMap(Map<String, dynamic>? bid) {
    return DriverPayoutView.fromMap(bid);
  }
}
