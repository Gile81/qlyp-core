import 'package:flutter/material.dart';

import '../config/typography.dart';
import '../models/cancellation_view.dart';
import '../money/qlyp_money.dart';

class QlypCancellationFeeBreakdown extends StatelessWidget {
  const QlypCancellationFeeBreakdown({
    super.key,
    required this.feeHt,
    required this.feeTtc,
    required this.feeTaxes,
    required this.languageCode,
    required this.subtotalLabel,
    required this.totalLabel,
    this.brightness = Brightness.light,
  });

  final double feeHt;
  final double feeTtc;
  final List<CancellationTaxLineView> feeTaxes;
  final String languageCode;
  final String subtotalLabel;
  final String totalLabel;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final secondary = QlypTypography.secondaryDescription(
      brightness: brightness,
    );
    final body = QlypTypography.body(brightness: brightness);
    final totalStyle = QlypTypography.h3(brightness: brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AmountRow(
          label: subtotalLabel,
          amount: QlypMoney.format(feeHt, languageCode: languageCode),
          labelStyle: secondary,
          amountStyle: body,
        ),
        for (final tax in feeTaxes)
          _AmountRow(
            label: tax.labelForLanguage(languageCode),
            amount: QlypMoney.format(tax.amount, languageCode: languageCode),
            labelStyle: secondary,
            amountStyle: body,
          ),
        const SizedBox(height: 8),
        _AmountRow(
          label: totalLabel,
          amount: QlypMoney.format(feeTtc, languageCode: languageCode),
          labelStyle: totalStyle,
          amountStyle: totalStyle,
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    required this.labelStyle,
    required this.amountStyle,
  });

  final String label;
  final String amount;
  final TextStyle labelStyle;
  final TextStyle amountStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Text(
            amount,
            style: amountStyle,
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
