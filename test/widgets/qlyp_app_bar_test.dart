import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/widgets/qlyp_app_bar.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypAppBar title FR and EN', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: Scaffold(appBar: QlypAppBar(title: 'Accueil'), body: const SizedBox.shrink()),
      ),
    );
    expect(find.text('Accueil'), findsOneWidget);

    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: Scaffold(appBar: QlypAppBar(title: 'Home'), body: const SizedBox.shrink()),
      ),
    );
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('QlypAppBar reduce motion', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: Scaffold(appBar: QlypAppBar(title: 'Titre'), body: const SizedBox.shrink()),
      ),
    );
    expect(find.text('Titre'), findsOneWidget);
  });
}