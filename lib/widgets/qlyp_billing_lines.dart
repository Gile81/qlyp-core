import 'package:flutter/material.dart';

import '../billing/billing_section_titles.dart';
import '../config/typography.dart';
import '../models/billing_display_line_view.dart';
import '../money/qlyp_money.dart';

enum QlypBillingLinesKind { invoice, statement }

class QlypBillingLines extends StatelessWidget {
  const QlypBillingLines.invoice({
    super.key,
    required this.invoiceLines,
    required this.languageCode,
    this.brightness = Brightness.light,
  })  : kind = QlypBillingLinesKind.invoice,
        statementLines = const [];

  const QlypBillingLines.statement({
    super.key,
    required this.statementLines,
    required this.languageCode,
    this.brightness = Brightness.light,
  })  : kind = QlypBillingLinesKind.statement,
        invoiceLines = const [];

  final QlypBillingLinesKind kind;
  final List<BillingDisplayLineView> invoiceLines;
  final List<BillingStatementLineView> statementLines;
  final String languageCode;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final secondary = QlypTypography.secondaryDescription(
      brightness: brightness,
    );
    final body = QlypTypography.body(brightness: brightness);
    final bold = QlypTypography.h3(brightness: brightness);

    if (kind == QlypBillingLinesKind.invoice) {
      return _buildInvoice(secondary, body, bold);
    }
    return _buildStatement(secondary, body, bold);
  }

  Widget _buildInvoice(TextStyle secondary, TextStyle body, TextStyle bold) {
    final children = <Widget>[];
    var detailHeaderDone = false;

    for (final section in invoiceSectionOrder) {
      final sectionLines =
          invoiceLines.where((l) => l.section == section).toList();
      if (sectionLines.isEmpty) continue;

      if (section == 'grand_total') {
        final line = sectionLines.first;
        children.add(const Divider(height: 24));
        children.add(
          _AmountRow(
            label: line.labelForLanguage(languageCode),
            amount: QlypMoney.format(line.amount, languageCode: languageCode),
            labelStyle: bold,
            amountStyle: bold,
          ),
        );
        continue;
      }

      final title = invoiceSectionTitle(languageCode, section);
      if ((section == 'ride_detail' || section == 'fee_detail') &&
          !detailHeaderDone) {
        if (title != null) {
          children.add(_SectionTitle(title: title, style: secondary));
        }
        detailHeaderDone = true;
      } else if (title != null) {
        children.add(_SectionTitle(title: title, style: secondary));
      }

      for (final line in sectionLines) {
        final isBold = section == 'ride_total' ||
            line.key == 'toll_total' ||
            line.key == 'taxable_subtotal';
        final style = isBold ? bold : body;
        children.add(
          _AmountRow(
            label: line.labelForLanguage(languageCode),
            amount: QlypMoney.format(line.amount, languageCode: languageCode),
            labelStyle: style,
            amountStyle: style,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildStatement(TextStyle secondary, TextStyle body, TextStyle bold) {
    final children = <Widget>[];
    String? lastSection;

    for (final section in statementSectionOrder) {
      final sectionLines =
          statementLines.where((l) => l.section == section).toList();
      if (sectionLines.isEmpty) continue;

      for (final line in sectionLines) {
        if (line.section != lastSection) {
          final title = statementSectionTitle(
            languageCode,
            section,
            lineKey: line.key,
          );
          if (title != null) {
            children.add(_SectionTitle(title: title, style: secondary));
          }
          lastSection = line.section;
        }
        if (line.textOnly == true) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line.labelForLanguage(languageCode),
                style: body,
              ),
            ),
          );
          continue;
        }
        final isBold = section == 'paid_to_driver' || section == 'driver_revenue';
        final style = isBold ? bold : body;
        children.add(
          _AmountRow(
            label: line.labelForLanguage(languageCode),
            amount: QlypMoney.format(line.amount, languageCode: languageCode),
            labelStyle: style,
            amountStyle: style,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.style});

  final String title;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title,
        style: style.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
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
          const SizedBox(width: 8),
          Text(amount, style: amountStyle),
        ],
      ),
    );
  }
}
