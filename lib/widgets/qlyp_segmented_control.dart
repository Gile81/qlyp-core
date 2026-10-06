import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';
import 'qlyp_pressable.dart';

enum QlypSegmentedControlVariant { light, dark }

/// 2 a 4 choix avec pastille glissante (mode carte Auto / Jour / Nuit).
class QlypSegmentedControl extends StatelessWidget {
  const QlypSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.variant = QlypSegmentedControlVariant.light,
  }) : assert(labels.length >= 2 && labels.length <= 4);

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final QlypSegmentedControlVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark = variant == QlypSegmentedControlVariant.dark;
    final bg = isDark ? QlypColors.midnightMid : QlypColors.grayVeryLight;
    final pill = isDark ? QlypColors.emerald.withValues(alpha: 0.25) : QlypColors.activeTabPill;
    final labelColor =
        isDark ? QlypColors.onDarkPrimary : QlypColors.textPrimary;
    final dur = QlypMotionAccessibility.duration(context, kDurTab);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / labels.length;
        return Container(
          height: QlypStyle.segmentedControlHeight,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(QlypStyle.segmentedControlHeight),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: dur,
                curve: kQlypFluid,
                left: itemWidth * selectedIndex + 4,
                top: 4,
                width: itemWidth - 8,
                height: QlypStyle.segmentedControlHeight - 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pill,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: QlypPressable(
                        semanticsLabel: labels[i],
                        onTap: () => onChanged(i),
                        child: Center(
                          child: Text(
                            labels[i],
                            style: (i == selectedIndex
                                    ? Theme.of(context).textTheme.labelLarge
                                    : Theme.of(context).textTheme.labelMedium)
                                ?.copyWith(color: labelColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}