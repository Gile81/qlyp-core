export 'qlyp_bottom_sheet.dart'
    show QlypBottomSheetVariant, QlypSheetLayout, showQlypBottomSheet;

import 'package:flutter/material.dart';

import 'qlyp_bottom_sheet.dart';

/// Feuille glass PRD §3.4 — API sémantique autour de [showQlypBottomSheet].
class QlypGlassSheet {
  QlypGlassSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    QlypBottomSheetVariant variant = QlypBottomSheetVariant.light,
    QlypSheetLayout layout = QlypSheetLayout.floating,
    bool isScrollControlled = true,
  }) =>
      showQlypBottomSheet<T>(
        context: context,
        builder: builder,
        variant: variant,
        layout: layout,
        isScrollControlled: isScrollControlled,
      );
}
