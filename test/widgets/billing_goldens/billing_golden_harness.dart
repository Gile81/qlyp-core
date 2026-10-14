import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/billing/billing_section_titles.dart';
import 'package:qlyp_core/config/typography.dart';
import 'package:qlyp_core/models/billing_invoice_view.dart';
import 'package:qlyp_core/widgets/qlyp_billing_lines.dart';

const billingGoldenKey = Key('billing_golden_root');

/// Fixed logical surface for billing/payout goldens (400×1200 @ 1.0 DPR).
void configureBillingGoldenSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget billingGoldenScroll(Widget child) {
  return Align(
    alignment: Alignment.topLeft,
    child: SizedBox(
      width: 400,
      height: 1200,
      child: SingleChildScrollView(
        child: KeyedSubtree(key: billingGoldenKey, child: child),
      ),
    ),
  );
}

Widget invoiceGoldenBody(
  BillingInvoiceView invoice,
  String languageCode,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        billingInvoiceDocumentTitle(
          languageCode,
          invoice.type ?? 'ride',
          version: invoice.version ?? 1,
        ),
        style: QlypTypography.h3(),
      ),
      const SizedBox(height: 8),
      QlypBillingLines.invoice(
        invoiceLines: invoice.displayLines,
        languageCode: languageCode,
      ),
    ],
  );
}
