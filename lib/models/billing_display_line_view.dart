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

class BillingYourRideLineView {
  const BillingYourRideLineView({
    this.key,
    this.labelFr,
    this.labelEn,
    this.amountHt,
  });

  final String? key;
  final String? labelFr;
  final String? labelEn;
  final double? amountHt;

  factory BillingYourRideLineView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingYourRideLineView();
    }
    return BillingYourRideLineView(
      key: billingOptionalString(raw[BillingContract.lineKey]),
      labelFr: billingOptionalString(raw[BillingContract.lineLabelFr]),
      labelEn: billingOptionalString(raw[BillingContract.lineLabelEn]),
      amountHt: billingAsDouble(raw[BillingContract.lineAmountHt]),
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
    this.notYoursFr,
    this.notYoursEn,
  });

  final String? key;
  final String? labelFr;
  final String? labelEn;
  final double? amount;
  final String? section;
  final bool? textOnly;
  final String? notYoursFr;
  final String? notYoursEn;

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
      notYoursFr: billingOptionalString(raw[BillingContract.lineNotYoursFr]),
      notYoursEn: billingOptionalString(raw[BillingContract.lineNotYoursEn]),
    );
  }

  String labelForLanguage(String languageCode) {
    final base = billingLabelForLanguage(
      languageCode: languageCode,
      labelFr: labelFr ?? '',
      labelEn: labelEn ?? '',
    );
    final fr = languageCode.toLowerCase().startsWith('fr');
    final ny = fr
        ? (notYoursFr ?? notYoursEn ?? '')
        : (notYoursEn ?? notYoursFr ?? '');
    if (ny.isEmpty) return base;
    return '$base $ny';
  }
}
