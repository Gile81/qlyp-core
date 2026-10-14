import 'package:flutter/material.dart';

import '../config/typography.dart';
import '../money/qlyp_money.dart';

class QlypPayoutLabel extends StatelessWidget {
  const QlypPayoutLabel({
    super.key,
    required this.amount,
    required this.languageCode,
    this.estimated = false,
    this.tollAmount,
    this.taxesToRemit,
    this.brightness = Brightness.light,
  });

  final double? amount;
  final String languageCode;
  final bool estimated;
  final double? tollAmount;
  final double? taxesToRemit;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final fr = languageCode.toLowerCase().startsWith('fr');
    final title = fr ? 'Payé à vous' : 'Paid to you';
    final estimatedSuffix = estimated ? (fr ? ' (estimé)' : ' (estimated)') : '';
    final headline = QlypTypography.h3(brightness: brightness);
    final secondary = QlypTypography.secondaryDescription(
      brightness: brightness,
    );

    final amountText = amount != null
        ? QlypMoney.format(amount, languageCode: languageCode)
        : (fr ? 'Montant à confirmer' : 'Amount to be confirmed');

    final subParts = <String>[];
    if (tollAmount != null && tollAmount! > 0) {
      final tollFmt = QlypMoney.format(tollAmount, languageCode: languageCode);
      subParts.add(
        fr
            ? 'dont péage $tollFmt (vous payez la facture du péage)'
            : 'incl. toll $tollFmt (you pay the toll bill)',
      );
    }
    if (taxesToRemit != null && taxesToRemit! > 0) {
      final taxFmt =
          QlypMoney.format(taxesToRemit, languageCode: languageCode);
      subParts.add(fr ? 'taxes à remettre $taxFmt' : 'taxes to remit $taxFmt');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                '$title$estimatedSuffix',
                style: headline,
              ),
            ),
            Text(amountText, style: headline),
          ],
        ),
        if (subParts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subParts.join(fr ? ' · ' : ' · '),
              style: secondary,
            ),
          ),
      ],
    );
  }
}
