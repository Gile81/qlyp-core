import 'package:flutter/material.dart';

import '../constants/qlyp_motion.dart';

/// Transition Material droite vers gauche, Fluid, [kDurPage].
class QlypSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const QlypSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final offset = animation.drive(
      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: kQlypFluid)),
    );
    return SlideTransition(position: offset, child: child);
  }
}

PageTransitionsTheme qlypPageTransitionsTheme() {
  const builder = QlypSlidePageTransitionsBuilder();
  return const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: builder,
      TargetPlatform.iOS: builder,
      TargetPlatform.macOS: builder,
      TargetPlatform.linux: builder,
      TargetPlatform.windows: builder,
      TargetPlatform.fuchsia: builder,
    },
  );
}