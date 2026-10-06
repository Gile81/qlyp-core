import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';
import 'qlyp_pressable.dart';

/// Interrupteur QLYP (vert actif) — Spring kDurPress + retour haptique.
class QlypSwitch extends StatelessWidget {
  const QlypSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticsLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackOn = QlypColors.emerald;
    final trackOff =
        isDark ? QlypColors.midnightMid : QlypColors.grayLight;
    final dur = QlypMotionAccessibility.duration(context, kDurPress);

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticsLabel,
      child: QlypPressable(
        enabled: enabled,
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onChanged!(!value);
              }
            : null,
        child: AnimatedContainer(
          duration: dur,
          curve: kQlypSpring,
          width: QlypStyle.switchTrackWidth,
          height: QlypStyle.switchTrackHeight,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? trackOn : trackOff,
            borderRadius: BorderRadius.circular(QlypStyle.switchTrackHeight),
          ),
          child: AnimatedAlign(
            duration: dur,
            curve: kQlypSpring,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: QlypStyle.switchThumbSize,
              height: QlypStyle.switchThumbSize,
              decoration: BoxDecoration(
                color: QlypColors.white,
                borderRadius: BorderRadius.circular(QlypStyle.switchThumbSize),
                boxShadow: QlypStyle.floatingShadowLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}