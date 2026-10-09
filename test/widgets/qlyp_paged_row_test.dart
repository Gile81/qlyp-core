import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/widgets/qlyp_paged_row.dart';

void main() {
  test('outerHeightForItemHeight adds shadow insets', () {
    expect(QlypPagedRow.outerHeightForItemHeight(168), 196);
  });

  testWidgets('ClipRect spans viewport width and clears shadow insets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 390,
              height: QlypPagedRow.outerHeightForItemHeight(168),
              child: QlypPagedRow(
                hint: false,
                itemCount: 3,
                itemBuilder: (context, index) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: QlypStyle.floatingShadowLight,
                  ),
                  child: const SizedBox(height: 168),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(QlypPagedRow)).width, 390);

    final cardFinder = find.descendant(
      of: find.byType(QlypPagedRow),
      matching: find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).boxShadow != null,
      ),
    );
    final card = tester.getRect(cardFinder.first);
    final clip = tester.getRect(
      find.descendant(
        of: find.byType(QlypPagedRow),
        matching: find.byWidgetPredicate(
          (w) =>
              w is ClipRect &&
              w.child is Padding &&
              (w.child as Padding).padding ==
                  const EdgeInsets.only(
                    top: QlypStyle.floatingShadowClipTop,
                    bottom: QlypStyle.floatingShadowClipBottom,
                  ),
        ),
      ),
    );

    expect(card.top - clip.top, closeTo(QlypStyle.floatingShadowClipTop, 1));
    expect(
      clip.bottom - card.bottom,
      closeTo(QlypStyle.floatingShadowClipBottom, 1),
    );
  });
}