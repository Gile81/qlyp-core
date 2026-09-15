import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/qlyp_colors.dart';

/// PRD-locked typography tokens shared across QLYP apps.
class QlypTypography {
  const QlypTypography._();

  /// Button / menu label — 16px, weight 500.
  static TextStyle buttonLabel({
    Color? color,
    Brightness brightness = Brightness.light,
  }) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.25,
      color: color ??
          (brightness == Brightness.dark
              ? QlypColors.onDarkPrimary
              : QlypColors.textPrimary),
    );
  }

  /// Secondary description — 14px, weight 400.
  static TextStyle secondaryDescription({
    Brightness brightness = Brightness.light,
  }) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.25,
      color: brightness == Brightness.dark
          ? QlypColors.onDarkSecondary
          : QlypColors.gray,
    );
  }
}
