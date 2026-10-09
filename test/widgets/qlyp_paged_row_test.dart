import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/widgets/qlyp_paged_row.dart';

void main() {
  testWidgets('first tile starts at x=16 on 390px viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 390,
              height: 168,
              child: QlypPagedRow(
                hint: false,
                itemCount: 6,
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

    final card = tester.getRect(
      find.descendant(
        of: find.byType(QlypPagedRow),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).boxShadow != null,
        ),
      ).first,
    );
    expect(card.left, closeTo(QlypStyle.pagedRowHorizontalInset, 1));
  });
}
