import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/typography.dart';
import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';
import 'qlyp_nav_item.dart';

/// Variante visuelle de la pilule flottante harmonisée client / pilote (10C).
enum QlypFloatingNavPillVariant { light, dark }

/// Pilule de navigation flottante 312 × 58 — spec accueil 10C §2.10.
class QlypFloatingNavPill extends StatefulWidget {
  const QlypFloatingNavPill({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.variant = QlypFloatingNavPillVariant.light,
    this.hidden = false,
    this.bottomInset,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<QlypNavItem> items;
  final QlypFloatingNavPillVariant variant;
  final bool hidden;
  final double? bottomInset;

  /// Position horizontale de la capsule active (spec §2.10).
  @visibleForTesting
  static double capsuleLeftForIndex(int index) {
    return QlypStyle.navPillCapsuleInset +
        QlypStyle.navPillColumnWidth * index;
  }

  @override
  State<QlypFloatingNavPill> createState() => _QlypFloatingNavPillState();
}

class _QlypFloatingNavPillState extends State<QlypFloatingNavPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _hideController;
  late Animation<double> _hideOffset;

  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(vsync: this, duration: kDurNavHide);
    _hideOffset = Tween<double>(begin: 0, end: QlypStyle.navHideOffset)
        .animate(CurvedAnimation(parent: _hideController, curve: kQlypFluid));
    if (widget.hidden) {
      _hideController.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hideController.duration =
        QlypMotionAccessibility.duration(context, kDurNavHide);
  }

  @override
  void didUpdateWidget(covariant QlypFloatingNavPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hidden != widget.hidden) {
      if (widget.hidden) {
        _hideController.forward();
      } else {
        _hideController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset =
        widget.bottomInset ?? MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset + QlypStyle.navPillGap),
      child: AnimatedBuilder(
        animation: _hideOffset,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _hideOffset.value),
            child: child,
          );
        },
        child: Center(
          child: SizedBox(
            width: QlypStyle.navPillWidth,
            height: QlypStyle.navPillHeight,
            child: _PillChrome(
              variant: widget.variant,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedPositioned(
                        duration: QlypMotionAccessibility.duration(
                          context,
                          kDurTab,
                        ),
                        curve: QlypMotionAccessibility.curve(
                          context,
                          kQlypFluid,
                        ),
                        left: QlypFloatingNavPill.capsuleLeftForIndex(
                          widget.currentIndex,
                        ),
                        top: QlypStyle.navPillCapsuleTop,
                        width: QlypStyle.navPillCapsuleWidth,
                        height: QlypStyle.navPillCapsuleHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.variant ==
                                    QlypFloatingNavPillVariant.light
                                ? QlypColors.activeTabPill
                                : QlypColors.emerald.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(
                              QlypStyle.navPillCapsuleRadius,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < widget.items.length; i++)
                            SizedBox(
                              width: QlypStyle.navPillColumnWidth,
                              child: _QlypFloatingNavTab(
                                item: widget.items[i],
                                isActive: i == widget.currentIndex,
                                variant: widget.variant,
                                onTap: () => widget.onTap(i),
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

class _PillChrome extends StatelessWidget {
  const _PillChrome({
    required this.variant,
    required this.child,
  });

  final QlypFloatingNavPillVariant variant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = variant == QlypFloatingNavPillVariant.light;
    final blur = isLight
        ? QlypColors.blurNavClient
        : QlypColors.blurNavDriver;
    return ClipRRect(
      borderRadius: BorderRadius.circular(QlypStyle.navPillRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isLight
                ? QlypColors.glassNavPillLight
                : QlypColors.glassNavDriver,
            borderRadius: BorderRadius.circular(QlypStyle.navPillRadius),
            boxShadow: isLight ? QlypStyle.navPillShadowLight : null,
            border: Border.all(
              color: isLight
                  ? QlypColors.glassNavPillLightBorder
                  : QlypColors.glassNavDriverBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _QlypFloatingNavTab extends StatelessWidget {
  const _QlypFloatingNavTab({
    required this.item,
    required this.isActive,
    required this.variant,
    required this.onTap,
  });

  final QlypNavItem item;
  final bool isActive;
  final QlypFloatingNavPillVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = variant == QlypFloatingNavPillVariant.light
        ? QlypColors.gray
        : QlypColors.onDarkSecondary;
    final activeColor = variant == QlypFloatingNavPillVariant.light
        ? QlypColors.emerald
        : QlypColors.emeraldLight;
    final labelStyle = QlypTypography.navPillActiveLabel(
      brightness: variant == QlypFloatingNavPillVariant.light
          ? Brightness.light
          : Brightness.dark,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isActive ? 1.15 : 1.0,
            duration: QlypMotionAccessibility.duration(context, kDurPress),
            curve: QlypMotionAccessibility.curve(context, kQlypSpring),
            child: Transform.translate(
              offset: isActive ? Offset.zero : const Offset(0, 6),
              child: Icon(
                item.icon,
                size: 22,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: QlypMotionAccessibility.duration(context, kDurTab),
            curve: QlypMotionAccessibility.curve(context, kQlypFluid),
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
