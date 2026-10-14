import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/billing/billing_section_titles.dart';
import 'package:qlyp_core/config/typography.dart';
import 'package:qlyp_core/models/billing_invoice_view.dart';
import 'package:qlyp_core/models/billing_statement_view.dart';
import 'package:qlyp_core/widgets/qlyp_billing_lines.dart';
import 'package:qlyp_core/widgets/qlyp_payout_label.dart';

import 'design_test_helpers.dart';
import 'pill_golden_fonts.dart';


void main() {
  setUpAll(() async {
    await loadPillGoldenFonts();
  });

  testWidgets('QlypPayoutLabel shows Payé à vous and amount (fr)', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypPayoutLabel(
          amount: 19.88,
          languageCode: 'fr',
          estimated: true,
        ),
      ),
    );
    expect(find.textContaining('Payé à vous'), findsOneWidget);
    expect(find.textContaining('19,88'), findsOneWidget);
  });

  testWidgets('QlypPayoutLabel maquette E EN golden', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: const QlypPayoutLabel(
          amount: 53.61,
          languageCode: 'en',
          tollAmount: 12.21,
          taxesToRemit: 5.93,
        ),
      ),
    );
    await expectLater(
      find.byType(QlypPayoutLabel),
      matchesGoldenFile('goldens/qlyp_payout_label_e_en.png'),
    );
  });

  testWidgets('QlypPayoutLabel FR golden', (tester) async {
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
    await expectLater(
      find.byType(QlypPayoutLabel),
      matchesGoldenFile('goldens/qlyp_payout_label_fr.png'),
    );
  });

  testWidgets('QlypPayoutLabel Montant à confirmer', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypPayoutLabel(
          amount: null,
          languageCode: 'fr',
        ),
      ),
    );
    expect(find.textContaining('Montant à confirmer'), findsOneWidget);
    await expectLater(
      find.byType(QlypPayoutLabel),
      matchesGoldenFile('goldens/qlyp_payout_label_pending_fr.png'),
    );
  });
}
