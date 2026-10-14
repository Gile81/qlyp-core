import 'package:flutter/material.dart';

import '../models/ride_tip_option_view.dart';
import '../money/qlyp_money.dart';
import 'qlyp_buttons.dart';
import 'qlyp_chip.dart';
import 'qlyp_text_field.dart';

/// Post-ride tip UI — preset amounts from server, no client-side tip math.
class QlypTipSelector extends StatefulWidget {
  const QlypTipSelector({
    super.key,
    required this.options,
    required this.languageCode,
    this.onGive,
    this.onLater,
    this.onDecline,
  });

  final List<RideTipOptionView> options;
  final String languageCode;
  final ValueChanged<double>? onGive;
  final VoidCallback? onLater;
  final VoidCallback? onDecline;

  @override
  State<QlypTipSelector> createState() => _QlypTipSelectorState();
}

class _QlypTipSelectorState extends State<QlypTipSelector> {
  static const _customKey = -1;

  int _selectedIndex = 0;
  final TextEditingController _customController = TextEditingController();

  bool get _fr => widget.languageCode.toLowerCase().startsWith('fr');

  String _optionLabel(RideTipOptionView option) {
    final money =
        QlypMoney.format(option.amount, languageCode: widget.languageCode);
    return '${option.pct} % · $money';
  }

  String get _otherAmountLabel => _fr ? 'Autre montant' : 'Other amount';

  String _giveLabel(double amount) {
    final money =
        QlypMoney.format(amount, languageCode: widget.languageCode);
    return _fr ? 'Donner $money' : 'Give $money';
  }

  String get _laterLabel => _fr ? 'Plus tard' : 'Later';

  String get _declineLabel => _fr ? 'Non merci' : 'No thanks';

  double? get _selectedAmount {
    if (_selectedIndex == _customKey) {
      final raw = _customController.text.trim().replaceAll(',', '.');
      if (raw.isEmpty) return null;
      return double.tryParse(raw);
    }
    if (_selectedIndex < 0 || _selectedIndex >= widget.options.length) {
      return null;
    }
    return widget.options[_selectedIndex].amount;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final amount = _selectedAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < options.length; i++)
              QlypChip(
                label: _optionLabel(options[i]),
                selected: _selectedIndex == i,
                onSelected: (_) => setState(() => _selectedIndex = i),
              ),
            QlypChip(
              label: _otherAmountLabel,
              selected: _selectedIndex == _customKey,
              onSelected: (_) => setState(() => _selectedIndex = _customKey),
            ),
          ],
        ),
        if (_selectedIndex == _customKey) ...[
          const SizedBox(height: 12),
          QlypTextField(
            labelText: _otherAmountLabel,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: _customController,
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: 16),
        QlypPrimaryButton(
          label: amount != null ? _giveLabel(amount) : (_fr ? 'Donner' : 'Give'),
          onPressed: amount != null && widget.onGive != null
              ? () => widget.onGive!(amount)
              : null,
        ),
        const SizedBox(height: 8),
        QlypSecondaryButton(
          label: _laterLabel,
          size: QlypButtonSize.medium,
          style: QlypSecondaryButtonStyle.subtle,
          onPressed: widget.onLater,
        ),
        const SizedBox(height: 8),
        QlypSecondaryButton(
          label: _declineLabel,
          size: QlypButtonSize.medium,
          style: QlypSecondaryButtonStyle.outlined,
          onPressed: widget.onDecline,
        ),
      ],
    );
  }
}
