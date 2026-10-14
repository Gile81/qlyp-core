import '../constants/billing_contract.dart';
import 'billing_map_helpers.dart';
import 'billing_tax_line_view.dart';

/// Subset of server `orders.financials` for in-app ride summaries.
class RideFinancialsView {
  const RideFinancialsView({
    this.paidToDriver,
    this.driverPayoutToll,
    this.driverCourseTaxesToRemitTotal,
    this.driverRevenue,
    this.passengerTotalTtc,
    this.tip,
    this.cashCollectedByDriver,
    this.cashDueToQlyp,
    this.qlypPromoSubsidy,
    this.driverTaxesToRemit = const [],
  });

  final double? paidToDriver;
  final double? driverPayoutToll;
  final double? driverCourseTaxesToRemitTotal;
  final double? driverRevenue;
  final double? passengerTotalTtc;
  final double? tip;
  final bool? cashCollectedByDriver;
  final double? cashDueToQlyp;
  final double? qlypPromoSubsidy;
  final List<BillingTaxLineView> driverTaxesToRemit;

  factory RideFinancialsView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const RideFinancialsView();
    }
    final taxesRaw =
        raw[BillingContract.rideFinancialsDriverCourseTaxesToRemit];
    final taxes = <BillingTaxLineView>[];
    if (taxesRaw is List) {
      for (final item in taxesRaw) {
        if (item is Map) {
          taxes.add(
            BillingTaxLineView.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return RideFinancialsView(
      paidToDriver:
          billingAsDouble(raw[BillingContract.rideFinancialsPaidToDriver]),
      driverPayoutToll:
          billingAsDouble(raw[BillingContract.rideFinancialsDriverPayoutToll]),
      driverCourseTaxesToRemitTotal: billingAsDouble(
        raw[BillingContract.rideFinancialsDriverCourseTaxesToRemitTotal],
      ),
      driverRevenue:
          billingAsDouble(raw[BillingContract.rideFinancialsDriverRevenue]),
      passengerTotalTtc:
          billingAsDouble(raw[BillingContract.rideFinancialsPassengerTotalTtc]),
      tip: billingAsDouble(raw[BillingContract.rideFinancialsTip]),
      cashCollectedByDriver: billingAsBool(
        raw[BillingContract.rideFinancialsCashCollectedByDriver],
      ),
      cashDueToQlyp:
          billingAsDouble(raw[BillingContract.rideFinancialsCashDueToQlyp]),
      qlypPromoSubsidy:
          billingAsDouble(raw[BillingContract.rideFinancialsQlypPromoSubsidy]),
      driverTaxesToRemit: taxes,
    );
  }

  factory RideFinancialsView.fromOrderMap(Map<String, dynamic>? order) {
    if (order == null || order.isEmpty) {
      return const RideFinancialsView();
    }
    final fin = order[BillingContract.fieldFinancials];
    if (fin is Map) {
      return RideFinancialsView.fromMap(Map<String, dynamic>.from(fin));
    }
    return const RideFinancialsView();
  }
}
