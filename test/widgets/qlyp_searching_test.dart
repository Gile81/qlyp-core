import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/widgets/qlyp_loading.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypSearching renders', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(child: const QlypSearching(size: 80)),
    );
    expect(find.byType(QlypSearching), findsOneWidget);
  });

  testWidgets('QlypSearching reduce motion uses QlypLoading fallback',
      (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: const QlypSearching(size: 80),
      ),
    );
    expect(find.byType(QlypLoading), findsOneWidget);
  });
}