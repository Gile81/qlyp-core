import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/qlyp_colors.dart';

/// PRD §3.2 — Inter, échelle complète.
TextTheme qlypTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.10,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.20,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.30,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.50,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.40,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.35,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      height: 1.00,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.8,
      height: 1.35,
    ),
  );
}

TextStyle get qlypLight => GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.2,
      height: 1.55,
    );

TextStyle get qlypPrice => GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.10,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

TextStyle get qlypMeter => GoogleFonts.inter(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.00,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// Helpers PRD (display → light).
class QlypTypography {
  const QlypTypography._();

  static TextStyle buttonLabel({
    Color? color,
    Brightness brightness = Brightness.light,
  }) {
    return qlypTextTheme().labelLarge!.copyWith(
          color: color ??
              (brightness == Brightness.dark
                  ? QlypColors.onDarkPrimary
                  : QlypColors.textPrimary),
        );
  }

  static TextStyle secondaryDescription({
    Brightness brightness = Brightness.light,
  }) {
    return qlypTextTheme().bodyMedium!.copyWith(
          color: brightness == Brightness.dark
              ? QlypColors.onDarkSecondary
              : QlypColors.gray,
        );
  }

  static TextStyle display({Brightness brightness = Brightness.light}) =>
      qlypTextTheme().displayLarge!.copyWith(
            color: brightness == Brightness.dark
                ? QlypColors.onDarkPrimary
                : QlypColors.textPrimary,
          );

  static TextStyle h1({Brightness brightness = Brightness.light}) =>
      qlypTextTheme().headlineLarge!.copyWith(
            color: brightness == Brightness.dark
                ? QlypColors.onDarkPrimary
                : QlypColors.textPrimary,
          );

  static TextStyle h2({Brightness brightness = Brightness.light}) =>
      qlypTextTheme().headlineMedium!.copyWith(
            color: brightness == Brightness.dark
                ? QlypColors.onDarkPrimary
                : QlypColors.textPrimary,
          );

  static TextStyle h3({Brightness brightness = Brightness.light}) =>
      qlypTextTheme().headlineSmall!.copyWith(
            color: brightness == Brightness.dark
                ? QlypColors.onDarkPrimary
                : QlypColors.textPrimary,
          );

  static TextStyle body({Brightness brightness = Brightness.light}) =>
      qlypTextTheme().bodyLarge!.copyWith(
            color: brightness == Brightness.dark
                ? QlypColors.onDarkPrimary
                : QlypColors.textPrimary,
          );

  static TextStyle caption({Brightness brightness = Brightness.light}) =>
      qlypTextTheme().bodySmall!.copyWith(
            color: brightness == Brightness.dark
                ? QlypColors.onDarkSecondary
                : QlypColors.gray,
          );

  static TextStyle labelCaps({Brightness brightness = Brightness.light}) =>
      qlypTextTheme().labelSmall!.copyWith(
            color: brightness == Brightness.dark
                ? QlypColors.onDarkSecondary
                : QlypColors.gray,
          );
}
