import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/qlyp_colors.dart' show QlypColors, QlypStyle;
import 'qlyp_page_transitions.dart';
import 'typography.dart';

/// Thèmes clair / sombre (alias explicites pour les apps).
ThemeData qlypLightTheme() => QlypTheme.light();
ThemeData qlypDarkTheme() => QlypTheme.dark();

/// Themes QLYP — Material 3 (Pearl clair / Midnight sombre).
class QlypTheme {
  const QlypTheme._();

  static ThemeData light() {
    final textTheme = qlypTextTheme().apply(
      bodyColor: QlypColors.textPrimary,
      displayColor: QlypColors.textPrimary,
    );

    const colorScheme = ColorScheme.light(
      primary: QlypColors.emerald,
      onPrimary: QlypColors.white,
      primaryContainer: QlypColors.emeraldDark,
      onPrimaryContainer: QlypColors.white,
      secondary: QlypColors.midnightQlyp,
      onSecondary: QlypColors.white,
      secondaryContainer: QlypColors.midnightMid,
      onSecondaryContainer: QlypColors.white,
      surface: QlypColors.white,
      onSurface: QlypColors.textPrimary,
      surfaceTint: Colors.transparent,
      error: QlypColors.red,
      onError: QlypColors.white,
      outline: QlypColors.grayLight,
      outlineVariant: QlypColors.blueGray,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      pageTransitionsTheme: qlypPageTransitionsTheme(),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: QlypColors.pearl,
      canvasColor: QlypColors.pearl,
      dividerColor: QlypColors.grayLight,
      disabledColor: QlypColors.grayDisabled,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: QlypColors.pearl,
        foregroundColor: QlypColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: QlypColors.grayLight,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: QlypColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: QlypColors.midnightQlyp.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QlypStyle.bentoRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QlypColors.emerald,
          foregroundColor: QlypColors.white,
          disabledBackgroundColor: QlypColors.grayDisabled,
          disabledForegroundColor: QlypColors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QlypColors.midnightQlyp,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: QlypColors.grayLight),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: QlypColors.emerald,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QlypColors.white,
        hintStyle: textTheme.bodyLarge?.copyWith(color: QlypColors.gray),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide: const BorderSide(color: QlypColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide: const BorderSide(color: QlypColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide: const BorderSide(color: QlypColors.emerald, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide: const BorderSide(color: QlypColors.red),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(QlypStyle.sheetRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: QlypColors.grayVeryLight,
        labelStyle: textTheme.bodySmall,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QlypStyle.chipRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: QlypColors.midnightQlyp,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: QlypColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QlypStyle.bentoRadius),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final textTheme = qlypTextTheme().apply(
      bodyColor: QlypColors.onDarkPrimary,
      displayColor: QlypColors.onDarkPrimary,
    );

    const colorScheme = ColorScheme.dark(
      primary: QlypColors.emeraldLight,
      onPrimary: QlypColors.deepQlyp,
      primaryContainer: QlypColors.emerald,
      onPrimaryContainer: QlypColors.white,
      secondary: QlypColors.steelBlue,
      onSecondary: QlypColors.midnightQlyp,
      secondaryContainer: QlypColors.midnightMid,
      onSecondaryContainer: QlypColors.onDarkPrimary,
      surface: QlypColors.midnightQlyp,
      onSurface: QlypColors.onDarkPrimary,
      surfaceTint: Colors.transparent,
      error: QlypColors.red,
      onError: QlypColors.white,
      outline: QlypColors.glassNavDriverBorder,
      outlineVariant: QlypColors.midnightMid,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      pageTransitionsTheme: qlypPageTransitionsTheme(),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: QlypColors.midnight,
      canvasColor: QlypColors.midnight,
      dividerColor: QlypColors.glassNavDriverBorder,
      disabledColor: QlypColors.onDarkDisabled,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: QlypColors.midnight,
        foregroundColor: QlypColors.onDarkPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: QlypColors.glassNavDriverBorder,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: QlypColors.midnightQlyp,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QlypStyle.bentoRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QlypColors.emerald,
          foregroundColor: QlypColors.white,
          disabledBackgroundColor: QlypColors.midnightMid,
          disabledForegroundColor: QlypColors.onDarkDisabled,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QlypColors.onDarkPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: QlypColors.glassNavDriverBorder),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: QlypColors.emeraldLight,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QlypColors.midnightQlyp,
        hintStyle:
            textTheme.bodyLarge?.copyWith(color: QlypColors.onDarkSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide: const BorderSide(color: QlypColors.glassNavDriverBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide: const BorderSide(color: QlypColors.glassNavDriverBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide:
              const BorderSide(color: QlypColors.emeraldLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QlypStyle.inputRadius),
          borderSide: const BorderSide(color: QlypColors.red),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(QlypStyle.sheetRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: QlypColors.midnightMid,
        labelStyle: textTheme.bodySmall,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QlypStyle.chipRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: QlypColors.midnightMid,
        contentTextStyle: textTheme.bodyMedium
            ?.copyWith(color: QlypColors.onDarkPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QlypStyle.bentoRadius),
        ),
      ),
    );
  }
}
