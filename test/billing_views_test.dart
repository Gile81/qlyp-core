import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/billing_contract.dart';
import 'package:qlyp_core/models/billing_invoice_view.dart';
import 'package:qlyp_core/models/billing_statement_view.dart';
import 'package:qlyp_core/models/driver_payout_view.dart';
import 'package:qlyp_core/models/ride_financials_view.dart';

void main() {
  test('BillingInvoiceView.fromMap tolerates empty and partial maps', () {
    expect(BillingInvoiceView.fromMap(null).documentNumber, isNull);
    final view = BillingInvoiceView.fromMap({
      BillingContract.invoiceFieldDocumentNumber: 'QLP-2026-1',
      BillingContract.invoiceFieldDisplayLines: [
        {
          BillingContract.lineKey: 'ride_total',
          BillingContract.lineLabelFr: 'Total de la course',
          BillingContract.lineLabelEn: 'Ride total',
          BillingContract.lineAmount: 27.59,
          BillingContract.lineSection: 'ride_total',
        },
      ],
    });
    expect(view.documentNumber, 'QLP-2026-1');
    expect(view.displayLines, hasLength(1));
    expect(view.displayLines.first.amount, 27.59);
  });

  test('RideFinancialsView reads nested financials on order', () {
    final fin = RideFinancialsView.fromOrderMap({
      BillingContract.fieldFinancials: {
        BillingContract.rideFinancialsPaidToDriver: 19.88,
        BillingContract.rideFinancialsDriverRevenue: 16.73,
      },
    });
    expect(fin.paidToDriver, 19.88);
    expect(fin.driverRevenue, 16.73);
  });

  test('DriverPayoutView reads order and bid maps', () {
    const payload = {
      BillingContract.fieldDriverPayoutEstimate: 49.61,
      BillingContract.fieldDriverPayoutToll: 12.21,
      BillingContract.fieldDriverCourseTaxesToRemit: 5.93,
      BillingContract.fieldDriverNetEstimate: 35.47,
    };
    expect(DriverPayoutView.fromOrderMap(payload).driverPayoutEstimate, 49.61);
    expect(DriverPayoutView.fromBidMap(payload).driverPayoutToll, 12.21);
  });

  test('BillingStatementView.fromMap does not throw on garbage', () {
    expect(
      () => BillingStatementView.fromMap({'unexpected': Object()}),
      returnsNormally,
    );
  });
}
