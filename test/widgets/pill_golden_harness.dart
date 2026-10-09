import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:qlyp_core/config/qlyp_theme.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/widgets/qlyp_floating_nav_pill.dart';
import 'package:qlyp_core/widgets/qlyp_nav_item.dart';

const kPillGoldenSize = Size(390, 844);

const materialNavItems = [
  QlypNavItem(icon: Icons.home_outlined, label: 'Accueil'),
  QlypNavItem(icon: Icons.timeline_outlined, label: 'Activite'),
  QlypNavItem(icon: Icons.payments_outlined, label: 'Gains'),
  QlypNavItem(icon: Icons.hub_outlined, label: 'Hub'),
  QlypNavItem(icon: Icons.person_outline, label: 'Compte'),
];

const phosphorNavItems = [
  QlypNavItem(icon: PhosphorIconsRegular.house, label: 'Accueil'),
  QlypNavItem(icon: PhosphorIconsRegular.squaresFour, label: 'Services'),
  QlypNavItem(icon: PhosphorIconsRegular.calendarBlank, label: 'Activite'),
  QlypNavItem(icon: PhosphorIconsRegular.usersThree, label: 'Cast'),
  QlypNavItem(icon: PhosphorIconsRegular.user, label: 'Compte'),
];

Widget fakeScrollBody({int lineCount = 48}) {
  return SafeArea(
    top: false,
    child: ListView.builder(
      itemCount: lineCount,
      itemBuilder: (context, index) {
        return ListTile(
          dense: true,
          title: Text(
            'Ligne ${index + 1}',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
          ),
        );
      },
    ),
  );
}

ThemeData pillGoldenTheme({bool dark = false}) {
  final base = dark ? qlypDarkTheme() : qlypLightTheme();
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'Inter'),
  );
}

Widget mediaQueryShell({
  required double viewBottom,
  required Widget child,
  bool disableAnimations = false,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: kPillGoldenSize,
      padding: EdgeInsets.only(bottom: viewBottom),
      viewPadding: EdgeInsets.only(bottom: viewBottom),
      disableAnimations: disableAnimations,
    ),
    child: child,
  );
}

Widget pillClientStackHarness({
  required int currentIndex,
  required double viewBottom,
  bool hidden = false,
  bool phosphor = true,
  bool disableAnimations = false,
}) {
  return mediaQueryShell(
    viewBottom: viewBottom,
    disableAnimations: disableAnimations,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: pillGoldenTheme(),
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            fakeScrollBody(),
            QlypFloatingNavPill(
              currentIndex: currentIndex,
              onTap: (_) {},
              items: phosphor ? phosphorNavItems : materialNavItems,
              hidden: hidden,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget pillPiloteScaffoldHarness({
  required int currentIndex,
  required double viewBottom,
  bool hidden = false,
  bool disableAnimations = false,
}) {
  return mediaQueryShell(
    viewBottom: viewBottom,
    disableAnimations: disableAnimations,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: pillGoldenTheme(dark: true),
      home: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF121212),
        body: fakeScrollBody(),
        bottomNavigationBar: QlypFloatingNavPill(
          currentIndex: currentIndex,
          onTap: (_) {},
          items: materialNavItems,
          variant: QlypFloatingNavPillVariant.dark,
          hidden: hidden,
        ),
      ),
    ),
  );
}

Widget pillTabsPlanche({
  required QlypFloatingNavPillVariant variant,
  required List<QlypNavItem> items,
  bool phosphor = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: pillGoldenTheme(dark: variant == QlypFloatingNavPillVariant.dark),
    home: Scaffold(
      backgroundColor: variant == QlypFloatingNavPillVariant.dark
          ? const Color(0xFF121212)
          : QlypColors.pearl,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < 5; i++) ...[
            Center(
              child: QlypFloatingNavPill(
                currentIndex: i,
                onTap: (_) {},
                items: items,
                variant: variant,
                bottomInset: 0,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    ),
  );
}
