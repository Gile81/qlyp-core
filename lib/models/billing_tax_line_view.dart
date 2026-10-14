import 'billing_map_helpers.dart';

class BillingTaxLineView {
  const BillingTaxLineView({
    this.id,
    this.labelFr,
    this.labelEn,
    this.rate,
    this.amount,
  });

  final String? id;
  final String? labelFr;
  final String? labelEn;
  final double? rate;
  final double? amount;

  factory BillingTaxLineView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const BillingTaxLineView();
    }
    return BillingTaxLineView(
      id: billingOptionalString(raw['id']),
      labelFr: billingOptionalString(raw['label_fr']),
      labelEn: billingOptionalString(raw['label_en']),
      rate: billingAsDouble(raw['rate']),
      amount: billingAsDouble(raw['amount']),
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
