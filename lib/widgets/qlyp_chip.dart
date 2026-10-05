import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import 'qlyp_pressable.dart';

class QlypChip extends StatelessWidget {
  const QlypChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? QlypColors.emerald.withValues(alpha: isDark ? 0.22 : 0.12)
        : (isDark ? QlypColors.midnightMid : QlypColors.grayVeryLight);
    final fg = selected
        ? (isDark ? QlypColors.emeraldLight : QlypColors.emeraldDark)
        : (isDark ? QlypColors.onDarkPrimary : QlypColors.textPrimary);

    return QlypPressable(
      semanticsLabel: label,
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: kDurPress,
        curve: kQlypSpring,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(QlypStyle.chipRadius),
          border: selected
              ? Border.all(color: QlypColors.emerald.withValues(alpha: 0.5))
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
