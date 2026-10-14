import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/billing_invoice_view.dart';
import 'package:qlyp_core/models/billing_statement_view.dart';

Future<Map<String, dynamic>> _loadBillingDoc(String name) async {
  final raw = await rootBundle.loadString('test/fixtures/billing_docs/$name');
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('server billing documents (build-billing-documents maquettes)', () {
    test('maquette A card invoice and statement totals', () async {
      final invoice =
          BillingInvoiceView.fromMap(await _loadBillingDoc('a_card_invoice.json'));
      final statement = BillingStatementView.fromMap(
        await _loadBillingDoc('a_card_statement.json'),
      );

      expect(invoice.passengerTotalTtc, 27.59);
      expect(statement.passengerPaidTotalTtc, 27.59);
      expect(statement.paidToDriver, 19.88);
      expect(statement.driverRevenue, 16.73);
      expect(statement.yourRideLines, isNotEmpty);
      expect(statement.yourRideSubtotalHt, 21.1);
    });

    test('maquette E v1 without tip', () async {
      final invoice = BillingInvoiceView.fromMap(
        await _loadBillingDoc('e_invoice_v1.json'),
      );
      final statement = BillingStatementView.fromMap(
        await _loadBillingDoc('e_statement_v1.json'),
      );

      expect(invoice.version, 1);
      expect(invoice.previousVersionId, isNull);
      expect(invoice.passengerTotalTtc, 66.8);
      expect(statement.version, 1);
      expect(statement.previousVersionId, isNull);
      expect(statement.passengerPaidTotalTtc, 66.8);
      expect(statement.paidToDriver, 49.61);
    });

    test('maquette E v2 with tip after payment', () async {
      final invoice = BillingInvoiceView.fromMap(
        await _loadBillingDoc('e_invoice.json'),
      );
      final statement = BillingStatementView.fromMap(
        await _loadBillingDoc('e_statement.json'),
      );

      expect(invoice.version, 2);
      expect(invoice.previousVersionId, 'e_v1_invoice_doc');
      expect(invoice.passengerTotalTtc, 70.8);
      expect(statement.version, 2);
      expect(statement.previousVersionId, 'e_v1_statement_doc');
      expect(statement.passengerPaidTotalTtc, 70.8);
      expect(statement.paidToDriver, 53.61);
    });

    test('maquette D cancellation', () async {
      final invoice =
          BillingInvoiceView.fromMap(await _loadBillingDoc('d_invoice.json'));
      final statement = BillingStatementView.fromMap(
        await _loadBillingDoc('d_statement.json'),
      );

      expect(invoice.passengerTotalTtc, 2.35);
      expect(invoice.type, 'cancellation');
      expect(statement.paidToDriver, 1.88);
    });

    test('maquette A cash statement cash summary lines', () async {
      final statement = BillingStatementView.fromMap(
        await _loadBillingDoc('a_cash_statement.json'),
      );

      expect(statement.cashCollectedByDriver, isTrue);
      expect(statement.cashDueToQlyp, 7.71);

      final cashLines = statement.statementLines
          .where((l) => l.section == 'cash_summary')
          .toList();
      expect(
        cashLines.any((l) => (l.labelFr ?? '').contains('Encaiss')),
        isTrue,
      );
      expect(
        cashLines.any(
          (l) => (l.labelFr ?? '').contains('QLYP') && l.amount == 7.71,
        ),
        isTrue,
      );
    });

  });
}
