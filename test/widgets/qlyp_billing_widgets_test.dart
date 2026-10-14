import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/billing_display_line_view.dart';
import 'package:qlyp_core/widgets/qlyp_billing_lines.dart';
import 'package:qlyp_core/widgets/qlyp_payout_label.dart';

import 'design_test_helpers.dart';

List<BillingDisplayLineView> _maquetteALines(String lang) {
  final fr = lang.startsWith('fr');
  return [
    BillingDisplayLineView(
      key: 'strategy_base',
      labelFr: 'Course',
      labelEn: 'Ride',
      amount: 21.1,
      section: 'ride_detail',
    ),
    BillingDisplayLineView(
      key: 'platform_fee',
      labelFr: 'Frais de plateforme Qlyp',
      labelEn: 'Qlyp platform fee',
      amount: 2,
      section: 'fee_detail',
    ),
    BillingDisplayLineView(
      key: 'taxable_subtotal',
      labelFr: 'Sous-total taxable',
      labelEn: 'Taxable subtotal',
      amount: 24,
      section: 'taxable_subtotal',
    ),
    BillingDisplayLineView(
      key: 'gst',
      labelFr: 'TPS (5 %)',
      labelEn: 'GST (5 %)',
      amount: 1.2,
      section: 'tax',
    ),
    BillingDisplayLineView(
      key: 'qst',
      labelFr: 'TVQ (9,975 %)',
      labelEn: 'QST (9.975 %)',
      amount: 2.39,
      section: 'tax',
    ),
    BillingDisplayLineView(
      key: 'ride_total',
      labelFr: 'Total de la course',
      labelEn: 'Ride total',
      amount: 27.59,
      section: 'ride_total',
    ),
    BillingDisplayLineView(
      key: 'grand_total',
      labelFr: fr ? 'TOTAL PAYÉ' : 'TOTAL PAID',
      labelEn: 'TOTAL PAID',
      amount: 27.59,
      section: 'grand_total',
    ),
  ];
}

List<BillingDisplayLineView> _maquetteELines() {
  return [
    ..._maquetteALines('fr').where((l) => l.section != 'grand_total'),
    BillingDisplayLineView(
      key: 'toll_bridge',
      labelFr: 'Péage — Pont A-25',
      labelEn: 'Toll — A-25 bridge',
      amount: 10.62,
      section: 'toll',
    ),
    BillingDisplayLineView(
      key: 'toll_total',
      labelFr: 'Total péage',
      labelEn: 'Toll total',
      amount: 12.21,
      section: 'toll',
    ),
    BillingDisplayLineView(
      key: 'tip',
      labelFr: 'Pourboire (volontaire)',
      labelEn: 'Tip (voluntary)',
      amount: 4,
      section: 'tip',
    ),
    BillingDisplayLineView(
      key: 'grand_total',
      labelFr: 'TOTAL PAYÉ',
      labelEn: 'TOTAL PAID',
      amount: 70.8,
      section: 'grand_total',
    ),
  ];
}

void main() {
  testWidgets('QlypPayoutLabel shows Payé à vous and amount', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypPayoutLabel(
          amount: 19.88,
          languageCode: 'fr',
          estimated: true,
          tollAmount: 12.21,
          taxesToRemit: 5.93,
        ),
      ),
    );
    expect(find.textContaining('Payé à vous'), findsOneWidget);
    expect(find.textContaining('19,88'), findsOneWidget);
  });

  testWidgets('QlypBillingLines maquette A FR golden', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('fr', 'CA'),
        child: QlypBillingLines.invoice(
          invoiceLines: _maquetteALines('fr'),
          languageCode: 'fr',
        ),
      ),
    );
    await expectLater(
      find.byType(QlypBillingLines),
      matchesGoldenFile('goldens/qlyp_billing_lines_maquette_a_fr.png'),
    );
  });

  testWidgets('QlypBillingLines maquette A EN golden', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: QlypBillingLines.invoice(
          invoiceLines: _maquetteALines('en'),
          languageCode: 'en',
        ),
      ),
    );
    await expectLater(
      find.byType(QlypBillingLines),
      matchesGoldenFile('goldens/qlyp_billing_lines_maquette_a_en.png'),
    );
  });

  testWidgets('QlypBillingLines maquette E FR golden', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('fr', 'CA'),
        child: QlypBillingLines.invoice(
          invoiceLines: _maquetteELines(),
          languageCode: 'fr',
        ),
      ),
    );
    await expectLater(
      find.byType(QlypBillingLines),
      matchesGoldenFile('goldens/qlyp_billing_lines_maquette_e_fr.png'),
    );
  });

  testWidgets('QlypPayoutLabel maquette E EN golden', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: const QlypPayoutLabel(
          amount: 49.61,
          languageCode: 'en',
          tollAmount: 12.21,
          taxesToRemit: 5.93,
        ),
      ),
    );
    await expectLater(
      find.byType(QlypPayoutLabel),
      matchesGoldenFile('goldens/qlyp_payout_label_maquette_e_en.png'),
    );
  });
}
