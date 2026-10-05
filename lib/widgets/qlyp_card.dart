import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import 'qlyp_pressable.dart';

class QlypCard extends StatelessWidget {
  const QlypCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    final decoration = isDark
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [QlypColors.midnightQlyp, QlypColors.midnightMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(QlypStyle.bentoRadius),
            border: Border.all(color: QlypColors.glassNavDriverBorder),
          )
        : BoxDecoration(
            color: QlypColors.white,
            borderRadius: BorderRadius.circular(QlypStyle.bentoRadius),
            boxShadow: QlypStyle.floatingShadowLight,
          );

    final box = AnimatedContainer(
      duration: kDurPress,
      curve: kQlypSpring,
      decoration: decoration,
      child: content,
    );

    if (onTap == null) return box;
    return QlypPressable(onTap: onTap, child: box);
  }
}
