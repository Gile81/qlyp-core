import 'package:flutter/material.dart';

import '../billing/billing_section_titles.dart';
import '../config/typography.dart';
import '../models/billing_display_line_view.dart';
import '../models/billing_statement_view.dart';
import '../money/qlyp_money.dart';

enum QlypBillingLinesKind { invoice, statement }

class QlypBillingLines extends StatelessWidget {
  const QlypBillingLines.invoice({
    super.key,
    required this.invoiceLines,
    required this.languageCode,
    this.brightness = Brightness.light,
  })  : kind = QlypBillingLinesKind.invoice,
        statement = null;

  const QlypBillingLines.statement({
    super.key,
    required this.statement,
    required this.languageCode,
    this.brightness = Brightness.light,
  })  : kind = QlypBillingLinesKind.statement,
        invoiceLines = const [];

  final QlypBillingLinesKind kind;
  final List<BillingDisplayLineView> invoiceLines;
  final BillingStatementView? statement;
  final String languageCode;
  final Brightness brightness;

  static const _statementBoldKeys = {
    'passenger_paid_total',
    'retained_total',
    'paid_to_driver_total',
    'driver_revenue_total',
    'cancellation_revenue',
  };

  @override
  Widget build(BuildContext context) {
    final secondary = QlypTypography.secondaryDescription(
      brightness: brightness,
    );
    final body = QlypTypography.body(brightness: brightness);
    final bold = QlypTypography.h3(brightness: brightness);
    final caps = QlypTypography.labelCaps(brightness: brightness);

    if (kind == QlypBillingLinesKind.invoice) {
      return _buildInvoice(secondary, body, bold, caps);
    }
    return _buildStatement(secondary, body, bold, caps);
  }

  Widget _buildInvoice(
    TextStyle secondary,
    TextStyle body,
    TextStyle bold,
    TextStyle caps,
  ) {
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
          children.add(_SectionTitle(title: title, style: caps));
        }
        detailHeaderDone = true;
      } else if (title != null) {
        children.add(_SectionTitle(title: title, style: caps));
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

  Widget _buildStatement(
    TextStyle secondary,
    TextStyle body,
    TextStyle bold,
    TextStyle caps,
  ) {
    final view = statement ?? const BillingStatementView();
    final children = <Widget>[];
    final fr = languageCode.toLowerCase().startsWith('fr');

    final rideLines =
        view.yourRideLines.where((l) => (l.amountHt ?? 0) != 0).toList();
    if (rideLines.isNotEmpty) {
      final title = statementSectionTitle(languageCode, 'your_ride');
      if (title != null) {
        children.add(_SectionTitle(title: title, style: caps));
      }
      for (final line in rideLines) {
        children.add(
          _AmountRow(
            label: line.labelForLanguage(languageCode),
            amount: QlypMoney.format(line.amountHt, languageCode: languageCode),
            labelStyle: body,
            amountStyle: body,
          ),
        );
      }
      final subtotal = view.yourRideSubtotalHt;
      if (subtotal != null && subtotal > 0) {
        children.add(
          _AmountRow(
            label: fr
                ? 'Votre course (avant taxes)'
                : 'Your ride (before tax)',
            amount: QlypMoney.format(subtotal, languageCode: languageCode),
            labelStyle: bold,
            amountStyle: bold,
          ),
        );
      }
    }

    final sectionHeaderDone = <String>{};
    var declarationsIntroDone = false;

    for (final section in statementSectionOrder) {
      final sectionLines =
          view.statementLines.where((l) => l.section == section).toList();
      if (sectionLines.isEmpty) continue;

      for (final line in sectionLines) {
        String? title;
        if (section == 'declarations') {
          if (!declarationsIntroDone) {
            title = statementSectionTitle(languageCode, section, lineKey: line.key);
            declarationsIntroDone = true;
          }
        } else if (!sectionHeaderDone.contains(section)) {
          title = statementSectionTitle(
            languageCode,
            section,
            lineKey: line.key,
          );
          sectionHeaderDone.add(section);
        }

        if (title != null) {
          children.add(_SectionTitle(title: title, style: caps));
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

        final isBold =
            _statementBoldKeys.contains(line.key ?? '') ||
            section == 'paid_to_driver' ||
            section == 'driver_revenue';
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
      child: Text(title, style: style),
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
