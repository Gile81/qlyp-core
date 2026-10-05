import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/widgets/qlyp_text_field.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypTextField label FR and EN', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypTextField(labelText: 'Courriel', hintText: 'a@b.ca'),
      ),
    );
    expect(find.text('Courriel'), findsOneWidget);

    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: const QlypTextField(labelText: 'Email', hintText: 'a@b.ca'),
      ),
    );
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('QlypTextField shows error message', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypTextField(labelText: 'Nom', errorText: 'Requis'),
      ),
    );
    expect(find.text('Requis'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Requis')).style?.color, QlypColors.red);
  });

  testWidgets('QlypTextField disabled state', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(child: const QlypTextField(labelText: 'Champ', enabled: false)),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('QlypTextField reduce motion renders', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: const QlypTextField(labelText: 'Fixe'),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
  });
}