import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/billing/billing_section_titles.dart';
import 'package:qlyp_core/config/typography.dart';
import 'package:qlyp_core/models/billing_invoice_view.dart';
import 'package:qlyp_core/models/billing_statement_view.dart';
import 'package:qlyp_core/widgets/qlyp_billing_lines.dart';

import '../design_test_helpers.dart';
import '../pill_golden_fonts.dart';
import 'billing_golden_harness.dart';


Future<Map<String, dynamic>> loadBillingDoc(String name) async {
  final raw = await rootBundle.loadString('test/fixtures/billing_docs/${name}');
  return jsonDecode(raw) as Map<String, dynamic>;
}


void main() {
  setUpAll(() async {
    await loadPillGoldenFonts();
  });

    testWidgets('golden', (tester) async {
      configureBillingGoldenSurface(tester);
      final invoice = BillingInvoiceView.fromMap(
        await loadBillingDoc('e_invoice.json'),
      );
      await tester.pumpWidget(
        wrapDesignTest(
          child: billingGoldenScroll(invoiceGoldenBody(invoice, 'fr')),
        ),
      );
      await expectLater(
        find.byKey(billingGoldenKey),
        matchesGoldenFile('../goldens/qlyp_billing_invoice_e_fr.png'),
      );
    });
}
