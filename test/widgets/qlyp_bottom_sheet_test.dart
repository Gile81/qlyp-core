import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/widgets/qlyp_bottom_sheet.dart';
import 'package:qlyp_core/widgets/qlyp_buttons.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('floating sheet has side margins and four rounded corners', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrapDesignTest(
        child: Builder(
          builder: (context) {
            return QlypPrimaryButton(
              label: 'Ouvrir',
              onPressed: () {
                showQlypBottomSheet<void>(
                  context: context,
                  builder: (_) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Contenu'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Padding &&
            w.padding == const EdgeInsets.fromLTRB(
              QlypStyle.sheetFloatingMargin,
              0,
              QlypStyle.sheetFloatingMargin,
              QlypStyle.sheetFloatingMargin,
            ),
      ),
      findsOneWidget,
    );

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(QlypStyle.sheetRadius));
  });

  testWidgets('fullWidth sheet uses top radius only', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: Builder(
          builder: (context) {
            return QlypTextButton(
              label: 'open',
              onPressed: () {
                showQlypBottomSheet<void>(
                  context: context,
                  layout: QlypSheetLayout.fullWidth,
                  builder: (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Liste'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(
      clip.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(QlypStyle.sheetRadius)),
    );
  });

  testWidgets('non-dismissible sheet ignores barrier tap', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: Builder(
          builder: (context) {
            return QlypTextButton(
              label: 'lock',
              onPressed: () {
                showQlypBottomSheet<void>(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  builder: (_) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Verrouillé'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('lock'));
    await tester.pumpAndSettle();
    expect(find.text('Verrouillé'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('Verrouillé'), findsOneWidget);
  });

  testWidgets('keyboard inset lifts floating sheet', (tester) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      wrapDesignTest(
        child: Builder(
          builder: (context) {
            return QlypTextButton(
              label: 'kb',
              onPressed: () {
                showQlypBottomSheet<void>(
                  context: context,
                  builder: (_) => const Text('Saisie'),
                );
              },
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('kb'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (w) => w is Padding && w.padding == const EdgeInsets.only(bottom: 280),
      ),
      findsOneWidget,
    );
  });
}