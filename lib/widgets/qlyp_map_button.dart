import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import 'qlyp_pressable.dart';

enum QlypMapButtonVariant { light, dark, danger }

/// Bouton rond sur la carte — placer dans un coin (haut/bas + gauche/droite), jamais au centre.
class QlypMapButton extends StatelessWidget {
  const QlypMapButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.variant = QlypMapButtonVariant.light,
    this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final QlypMapButtonVariant variant;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final isDanger = variant == QlypMapButtonVariant.danger;
    final isDark = variant == QlypMapButtonVariant.dark;
    final bg = isDanger
        ? QlypColors.red
        : (isDark ? QlypColors.glassCardOnMap : QlypColors.glassTrackingCard);
    final border = isDanger
        ? QlypColors.red
        : (isDark ? QlypColors.glassCardOnMapBorder : QlypColors.glassNavClientBorder);
    final iconColor = isDanger
        ? QlypColors.white
        : (isDark ? QlypColors.onDarkPrimary : QlypColors.midnightQlyp);
    final blur = isDark ? QlypColors.blurOverlay : QlypColors.blurTrackingCard;

    return QlypPressable(
      semanticsLabel: semanticsLabel,
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: QlypStyle.mapButtonSize,
            height: QlypStyle.mapButtonSize,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border),
              boxShadow: QlypStyle.floatingShadowLight,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}