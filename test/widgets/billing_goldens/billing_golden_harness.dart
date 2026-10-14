import 'package:flutter/material.dart';
import 'package:qlyp_core/billing/billing_section_titles.dart';
import 'package:qlyp_core/config/typography.dart';
import 'package:qlyp_core/models/billing_invoice_view.dart';
import 'package:qlyp_core/widgets/qlyp_billing_lines.dart';

const billingGoldenKey = Key('billing_golden_root');

Widget billingGoldenScroll(Widget child) {
  return SizedBox(
    width: 400,
    height: 1200,
    child: SingleChildScrollView(
      child: KeyedSubtree(key: billingGoldenKey, child: child),
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
        billingInvoiceDocumentTitle(languageCode, invoice.type ?? 'ride'),
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
