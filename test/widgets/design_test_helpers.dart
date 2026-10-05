import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/config/qlyp_theme.dart';

Widget wrapDesignTest({
  required Widget child,
  Locale locale = const Locale('fr', 'CA'),
  bool disableAnimations = false,
}) {
  return MaterialApp(
    locale: locale,
    theme: qlypLightTheme(),
    darkTheme: qlypDarkTheme(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  );
}

Future<void> pressCenter(WidgetTester tester, Finder target) async {
  final gesture = await tester.startGesture(tester.getCenter(target));
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

Finder firstAnimatedScale() => find.byType(AnimatedScale).first;
