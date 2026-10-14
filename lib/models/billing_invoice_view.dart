import '../constants/billing_contract.dart';
import 'billing_display_line_view.dart';
import 'billing_document_header_view.dart';
import 'billing_map_helpers.dart';
import 'billing_tax_line_view.dart';

class BillingDocumentPaymentView {
  const BillingDocumentPaymentView({
    this.method,
    this.status,
    this.labelFr,
    this.labelEn,
  });

  final String? method;
  final String? status;
  final String? labelFr;
  final String? labelEn;

  factory BillingDocumentPaymentView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingDocumentPaymentView();
    }
    return BillingDocumentPaymentView(
      method: billingOptionalString(raw['method']),
      status: billingOptionalString(raw['status']),
      labelFr: billingOptionalString(raw['label_fr']),
      labelEn: billingOptionalString(raw['label_en']),
    );
  }

  String labelForLanguage(String languageCode) {
    return billingLabelForLanguage(
      languageCode: languageCode,
      labelFr: labelFr ?? '',
      labelEn: labelEn ?? '',
    );
  }
}

class BillingInvoiceView {
  const BillingInvoiceView({
    this.documentNumber,
    this.type,
    this.language,
    this.issuedAt,
    this.header,
    this.displayLines = const [],
    this.rideSubtotalTaxableHt,
    this.rideTaxes = const [],
    this.rideTotalTtc,
    this.tip,
    this.passengerTotalTtc,
    this.payment,
    this.legal,
    this.pdfStatus,
  });

  final String? documentNumber;
  final String? type;
  final String? language;
  final String? issuedAt;
  final BillingDocumentHeaderView? header;
  final List<BillingDisplayLineView> displayLines;
  final double? rideSubtotalTaxableHt;
  final List<BillingTaxLineView> rideTaxes;
  final double? rideTotalTtc;
  final double? tip;
  final double? passengerTotalTtc;
  final BillingDocumentPaymentView? payment;
  final Map<String, dynamic>? legal;
  final String? pdfStatus;

  factory BillingInvoiceView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingInvoiceView();
    }
    final linesRaw = raw[BillingContract.invoiceFieldDisplayLines];
    final lines = <BillingDisplayLineView>[];
    if (linesRaw is List) {
      for (final item in linesRaw) {
        if (item is Map) {
          lines.add(
            BillingDisplayLineView.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final taxesRaw = raw[BillingContract.invoiceFieldRideTaxes];
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
    return BillingInvoiceView(
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
      displayLines: lines,
      rideSubtotalTaxableHt: billingAsDouble(
        raw[BillingContract.invoiceFieldRideSubtotalTaxableHt],
      ),
      rideTaxes: taxes,
      rideTotalTtc:
          billingAsDouble(raw[BillingContract.invoiceFieldRideTotalTtc]),
      tip: billingAsDouble(raw[BillingContract.invoiceFieldTip]),
      passengerTotalTtc:
          billingAsDouble(raw[BillingContract.invoiceFieldPassengerTotalTtc]),
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

  bool get isCancellation => type == 'cancellation';
}
