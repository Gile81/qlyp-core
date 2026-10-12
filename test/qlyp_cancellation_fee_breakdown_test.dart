import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/cancellation_view.dart';
import 'package:qlyp_core/widgets/qlyp_cancellation_fee_breakdown.dart';

void main() {
  testWidgets('QlypCancellationFeeBreakdown shows HT, taxes, total', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QlypCancellationFeeBreakdown(
            feeHt: 10,
            feeTtc: 11.5,
            languageCode: 'fr',
            subtotalLabel: 'Avant taxes',
            totalLabel: 'Total',
            feeTaxes: const [
              CancellationTaxLineView(
                key: 'gst',
                labelFr: 'TPS',
                labelEn: 'GST',
                rate: 0.05,
                amount: 0.5,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.textContaining('TPS'), findsOneWidget);
    expect(find.textContaining('11,50'), findsOneWidget);
  });
}
