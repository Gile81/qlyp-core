import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../constants/qlyp_colors.dart';

/// OTP / SMS code entry with visible boxes only (no themed [TextField] rectangle).
class QlypOtpField extends StatelessWidget {
  const QlypOtpField({
    super.key,
    required this.length,
    required this.controller,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
    this.autoFocus = false,
    this.focusNode,
  });

  final int length;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool hasError;

  /// When true, requests focus when the field is first built (pilote code screens).
  final bool autoFocus;

  /// Optional focus node (e.g. refocus after clearing on validation error).
  final FocusNode? focusNode;

  static const double _boxWidth = 44;
  static const double _boxHeight = 48;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final neutralFieldTheme = baseTheme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        isCollapsed: true,
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.transparent,
      ),
    );

    final inactiveBorder =
        hasError ? QlypColors.red : QlypColors.grayLight;
    final activeBorder = hasError ? QlypColors.red : QlypColors.deepQlyp;

    return AutofillGroup(
      child: Theme(
      data: neutralFieldTheme,
      child: PinCodeTextField(
        length: length,
        appContext: context,
        controller: controller,
        focusNode: focusNode,
        autoFocus: autoFocus,
        enabled: enabled,
        autoDisposeControllers: false,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        enableActiveFill: true,
        cursorColor: Colors.transparent,
        cursorWidth: 0,
        animationType: AnimationType.none,
        pinTheme: PinTheme(
          fieldHeight: _boxHeight,
          fieldWidth: _boxWidth,
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          activeColor: activeBorder,
          selectedColor: activeBorder,
          inactiveColor: inactiveBorder,
          activeFillColor: QlypColors.white,
          selectedFillColor: QlypColors.white,
          inactiveFillColor: QlypColors.white,
          disabledColor: QlypColors.grayLight,
        ),
        onChanged: onChanged ?? (_) {},
        onCompleted: onCompleted,
      ),
    ),
    );
  }
}
