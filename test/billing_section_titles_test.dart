import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/billing/billing_section_titles.dart';

void main() {
  test('billingInvoiceDocumentTitle v1 ride FR/EN', () {
    expect(billingInvoiceDocumentTitle('fr', 'ride'), 'Facture');
    expect(billingInvoiceDocumentTitle('en', 'ride'), 'Invoice');
  });

  test('billingInvoiceDocumentTitle v2 ride FR/EN', () {
    expect(
      billingInvoiceDocumentTitle('fr', 'ride', version: 2),
      'Facture — version 2',
    );
    expect(
      billingInvoiceDocumentTitle('en', 'ride', version: 2),
      'Invoice — version 2',
    );
  });
}
