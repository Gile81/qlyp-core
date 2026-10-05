import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/widgets/qlyp_loading.dart';

void main() {
  testWidgets('QlypLoading respects reduce motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(
            body: QlypLoading(size: QlypLoadingSize.inline),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
