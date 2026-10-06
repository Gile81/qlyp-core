import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';

enum QlypBottomSheetVariant { light, darkFrosted }

/// `floating` : popup marges 12 px, 4 coins arrondis ; `fullWidth` : bord a bord, coins du haut seulement.
enum QlypSheetLayout { floating, fullWidth }

Future<T?> showQlypBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  QlypBottomSheetVariant variant = QlypBottomSheetVariant.light,
  QlypSheetLayout layout = QlypSheetLayout.floating,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: QlypColors.transparent,
    barrierColor: QlypColors.scrim54,
    sheetAnimationStyle: AnimationStyle(
      duration: kDurSheet,
      reverseDuration: kDurSheet,
      curve: kQlypFluid,
      reverseCurve: kQlypFluid,
    ),
    builder: (ctx) {
      final media = MediaQuery.of(ctx);
      final child = builder(ctx);
      final maxSheetHeight = media.size.height * QlypStyle.sheetMaxHeightFraction;

      final borderRadius = layout == QlypSheetLayout.floating
          ? BorderRadius.circular(QlypStyle.sheetRadius)
          : const BorderRadius.vertical(
              top: Radius.circular(QlypStyle.sheetRadius),
            );

      Widget sheetBody = _buildGlassSheet(
        variant: variant,
        borderRadius: borderRadius,
        maxHeight: maxSheetHeight,
        child: child,
      );

      if (layout == QlypSheetLayout.floating) {
        sheetBody = Padding(
          padding: const EdgeInsets.fromLTRB(
            QlypStyle.sheetFloatingMargin,
            0,
            QlypStyle.sheetFloatingMargin,
            QlypStyle.sheetFloatingMargin,
          ),
          child: sheetBody,
        );
      }

      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: sheetBody,
        ),
      );
    },
  );
}

Widget _buildGlassSheet({
  required QlypBottomSheetVariant variant,
  required BorderRadius borderRadius,
  required double maxHeight,
  required Widget child,
}) {
  final chrome = _SheetChrome(maxHeight: maxHeight, child: child);

  if (variant == QlypBottomSheetVariant.darkFrosted) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: QlypColors.blurOverlay,
          sigmaY: QlypColors.blurOverlay,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: QlypColors.glassNavDriver,
            borderRadius: borderRadius,
          ),
          child: chrome,
        ),
      ),
    );
  }

  return ClipRRect(
    borderRadius: borderRadius,
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: QlypColors.blurBottomSheet,
        sigmaY: QlypColors.blurBottomSheet,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: QlypColors.glassBottomSheet,
          borderRadius: borderRadius,
          border: Border.all(color: QlypColors.glassBottomSheetBorder),
        ),
        child: chrome,
      ),
    ),
  );
}

class _SheetChrome extends StatelessWidget {
  const _SheetChrome({required this.maxHeight, required this.child});

  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: QlypColors.grayLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
