import '../constants/billing_contract.dart';
import 'billing_map_helpers.dart';

class BillingDisplayLineView {
  const BillingDisplayLineView({
    this.key,
    this.labelFr,
    this.labelEn,
    this.amount,
    this.section,
  });

  final String? key;
  final String? labelFr;
  final String? labelEn;
  final double? amount;
  final String? section;

  factory BillingDisplayLineView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingDisplayLineView();
    }
    return BillingDisplayLineView(
      key: billingOptionalString(raw[BillingContract.lineKey]),
      labelFr: billingOptionalString(raw[BillingContract.lineLabelFr]),
      labelEn: billingOptionalString(raw[BillingContract.lineLabelEn]),
      amount: billingAsDouble(raw[BillingContract.lineAmount]),
      section: billingOptionalString(raw[BillingContract.lineSection]),
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

class BillingStatementLineView {
  const BillingStatementLineView({
    this.key,
    this.labelFr,
    this.labelEn,
    this.amount,
    this.section,
    this.textOnly,
  });

  final String? key;
  final String? labelFr;
  final String? labelEn;
  final double? amount;
  final String? section;
  final bool? textOnly;

  factory BillingStatementLineView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingStatementLineView();
    }
    return BillingStatementLineView(
      key: billingOptionalString(raw[BillingContract.lineKey]),
      labelFr: billingOptionalString(raw[BillingContract.lineLabelFr]),
      labelEn: billingOptionalString(raw[BillingContract.lineLabelEn]),
      amount: billingAsDouble(raw[BillingContract.lineAmount]),
      section: billingOptionalString(raw[BillingContract.lineSection]),
      textOnly: billingAsBool(raw[BillingContract.lineTextOnly]),
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
