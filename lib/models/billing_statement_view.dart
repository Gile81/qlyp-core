import '../constants/billing_contract.dart';
import 'billing_display_line_view.dart';
import 'billing_document_header_view.dart';
import 'billing_invoice_view.dart';
import 'billing_map_helpers.dart';
import 'billing_tax_line_view.dart';

class BillingStatementView {
  const BillingStatementView({
    this.version,
    this.previousVersionId,
    this.documentNumber,
    this.type,
    this.language,
    this.issuedAt,
    this.header,
    this.yourRideLines = const [],
    this.yourRideSubtotalHt,
    this.statementLines = const [],
    this.passengerPaidTotalTtc,
    this.retainedTotal,
    this.tollTotalTtc,
    this.tip,
    this.paidToDriver,
    this.driverRevenue,
    this.driverTaxesToRemit = const [],
    this.driverTaxesToRemitTotal,
    this.qlypPromoSubsidy,
    this.cashCollectedByDriver,
    this.cashDueToQlyp,
    this.cashCollectedLabelFr,
    this.cashCollectedLabelEn,
    this.cashDueLabelFr,
    this.cashDueLabelEn,
    this.payment,
    this.legal,
    this.pdfStatus,
  });

  final int? version;
  final String? previousVersionId;
  final String? documentNumber;
  final String? type;
  final String? language;
  final String? issuedAt;
  final BillingDocumentHeaderView? header;
  final List<BillingYourRideLineView> yourRideLines;
  final double? yourRideSubtotalHt;
  final List<BillingStatementLineView> statementLines;
  final double? passengerPaidTotalTtc;
  final double? retainedTotal;
  final double? tollTotalTtc;
  final double? tip;
  final double? paidToDriver;
  final double? driverRevenue;
  final List<BillingTaxLineView> driverTaxesToRemit;
  final double? driverTaxesToRemitTotal;
  final double? qlypPromoSubsidy;
  final bool? cashCollectedByDriver;
  final double? cashDueToQlyp;
  final String? cashCollectedLabelFr;
  final String? cashCollectedLabelEn;
  final String? cashDueLabelFr;
  final String? cashDueLabelEn;
  final BillingDocumentPaymentView? payment;
  final Map<String, dynamic>? legal;
  final String? pdfStatus;

  factory BillingStatementView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingStatementView();
    }
    final rideLinesRaw = raw[BillingContract.statementFieldYourRideLines];
    final rideLines = <BillingYourRideLineView>[];
    if (rideLinesRaw is List) {
      for (final item in rideLinesRaw) {
        if (item is Map) {
          rideLines.add(
            BillingYourRideLineView.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final linesRaw = raw[BillingContract.statementFieldStatementLines];
    final lines = <BillingStatementLineView>[];
    if (linesRaw is List) {
      for (final item in linesRaw) {
        if (item is Map) {
          lines.add(
            BillingStatementLineView.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final taxesRaw = raw[BillingContract.statementFieldDriverTaxesToRemit];
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
    final headerRaw = raw[BillingContract.invoiceFieldHeader];
    final paymentRaw = raw[BillingContract.invoiceFieldPayment];
    final legalRaw = raw[BillingContract.invoiceFieldLegal];
    final tollRaw = raw[BillingContract.invoiceFieldToll];
    double? tollTotal;
    if (tollRaw is Map) {
      tollTotal = billingAsDouble(
        (tollRaw as Map<String, dynamic>)['total_ttc'],
      );
    }
    final versionRaw = raw[BillingContract.invoiceFieldVersion];
    int? version;
    if (versionRaw is num) {
      version = versionRaw.round();
    } else if (versionRaw != null) {
      version = int.tryParse(versionRaw.toString().trim());
    }
    return BillingStatementView(
      version: version,
      previousVersionId: billingOptionalString(
        raw[BillingContract.invoiceFieldPreviousVersionId],
      ),
      documentNumber:
          billingOptionalString(raw[BillingContract.invoiceFieldDocumentNumber]),
      type: billingOptionalString(raw[BillingContract.invoiceFieldType]),
      language: billingOptionalString(raw[BillingContract.invoiceFieldLanguage]),
      issuedAt: billingOptionalString(raw[BillingContract.invoiceFieldIssuedAt]),
      header: headerRaw is Map
          ? BillingDocumentHeaderView.fromMap(
              Map<String, dynamic>.from(headerRaw),
            )
          : null,
      yourRideLines: rideLines,
      yourRideSubtotalHt: billingAsDouble(
        raw[BillingContract.statementFieldYourRideSubtotalHt],
      ),
      statementLines: lines,
      passengerPaidTotalTtc: billingAsDouble(
        raw[BillingContract.statementFieldPassengerPaidTotalTtc],
      ),
      retainedTotal:
          billingAsDouble(raw[BillingContract.statementFieldRetainedTotal]),
      tollTotalTtc: tollTotal,
      tip: billingAsDouble(raw[BillingContract.invoiceFieldTip]),
      paidToDriver:
          billingAsDouble(raw[BillingContract.statementFieldPaidToDriver]),
      driverRevenue:
          billingAsDouble(raw[BillingContract.rideFinancialsDriverRevenue]),
      driverTaxesToRemit: taxes,
      driverTaxesToRemitTotal: billingAsDouble(
        raw[BillingContract.statementFieldDriverTaxesToRemitTotal],
      ),
      qlypPromoSubsidy:
          billingAsDouble(raw[BillingContract.statementFieldQlypPromoSubsidy]),
      cashCollectedByDriver: billingAsBool(
        raw[BillingContract.statementFieldCashCollectedByDriver],
      ),
      cashDueToQlyp:
          billingAsDouble(raw[BillingContract.statementFieldCashDueToQlyp]),
      cashCollectedLabelFr: billingOptionalString(
        raw[BillingContract.statementFieldCashCollectedLabelFr],
      ),
      cashCollectedLabelEn: billingOptionalString(
        raw[BillingContract.statementFieldCashCollectedLabelEn],
      ),
      cashDueLabelFr:
          billingOptionalString(raw[BillingContract.statementFieldCashDueLabelFr]),
      cashDueLabelEn:
          billingOptionalString(raw[BillingContract.statementFieldCashDueLabelEn]),
      payment: paymentRaw is Map
          ? BillingDocumentPaymentView.fromMap(
              Map<String, dynamic>.from(paymentRaw),
            )
          : null,
      legal: legalRaw is Map ? Map<String, dynamic>.from(legalRaw) : null,
      pdfStatus:
          billingOptionalString(raw[BillingContract.invoiceFieldPdfStatus]),
    );
  }
}
