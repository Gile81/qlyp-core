import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';

enum QlypBottomSheetVariant { light, darkFrosted }

Future<T?> showQlypBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  QlypBottomSheetVariant variant = QlypBottomSheetVariant.light,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    sheetAnimationStyle: AnimationStyle(
      duration: kDurSheet,
      reverseDuration: kDurSheet,
      curve: kQlypFluid,
      reverseCurve: kQlypFluid,
    ),
    builder: (ctx) {
      final media = MediaQuery.of(ctx);
      final child = builder(ctx);
      const radius = BorderRadius.vertical(top: Radius.circular(20));
      if (variant == QlypBottomSheetVariant.darkFrosted) {
        return ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: QlypColors.blurOverlay,
              sigmaY: QlypColors.blurOverlay,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: QlypColors.glassNavDriver,
                borderRadius: radius,
              ),
              child: _SheetChrome(media: media, child: child),
            ),
          ),
        );
      }
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: QlypColors.blurBottomSheet,
            sigmaY: QlypColors.blurBottomSheet,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: QlypColors.glassBottomSheet,
              borderRadius: radius,
              border: Border.all(color: QlypColors.glassBottomSheetBorder),
            ),
            child: _SheetChrome(media: media, child: child),
          ),
        ),
      );
    },
  );
}

class _SheetChrome extends StatelessWidget {
  const _SheetChrome({required this.media, required this.child});

  final MediaQueryData media;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
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
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
