import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';

/// Un onglet de la bottom navigation QLYP.
class QlypNavItem {
  final IconData icon;
  final String label;

  const QlypNavItem({required this.icon, required this.label});
}

/// Bottom navigation client — glass light blanc givre — PRD 3.5.
class QlypBottomNav extends StatelessWidget {
  static const double barHeight = 64;

  static const double _pillHeight = 44;
  static const double _pillInset = 6;

  static const List<QlypNavItem> defaultItems = [
    QlypNavItem(icon: Icons.home_outlined, label: 'Accueil'),
    QlypNavItem(icon: Icons.grid_view_outlined, label: 'Services'),
    QlypNavItem(icon: Icons.event_note_outlined, label: 'Réservations'),
    QlypNavItem(icon: Icons.groups_2_outlined, label: 'Cast'),
    QlypNavItem(icon: Icons.person_outline, label: 'Compte'),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<QlypNavItem> items;

  const QlypBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = defaultItems,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: QlypColors.blurNavClient,
          sigmaY: QlypColors.blurNavClient,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: QlypColors.glassNavClient,
            border: Border(
              top: BorderSide(color: QlypColors.glassNavClientBorder, width: 1),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SizedBox(
              height: barHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / items.length;

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: kDurTab,
                        curve: kQlypFluid,
                        left: itemWidth * currentIndex + _pillInset,
                        top: (barHeight - _pillHeight) / 2,
                        width: itemWidth - (_pillInset * 2),
                        height: _pillHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: QlypColors.activeTabPill,
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _QlypNavTab(
                                item: items[i],
                                isActive: i == currentIndex,
                                onTap: () => onTap(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QlypNavTab extends StatelessWidget {
  final QlypNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _QlypNavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: QlypColors.midnightQlyp,
          height: 1.0,
          letterSpacing: -0.1,
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isActive ? 1.15 : 1.0,
            duration: kDurPress,
            curve: kQlypSpring,
            child: Icon(
              item.icon,
              size: 22,
              color: isActive ? QlypColors.emerald : QlypColors.gray,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: kDurTab,
            curve: kQlypFluid,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: labelStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
