import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../config/typography.dart';
import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';

class QlypMenuBentoTile extends StatefulWidget {
  const QlypMenuBentoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.showChevron = true,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool showChevron;
  final bool compact;

  @override
  State<QlypMenuBentoTile> createState() => _QlypMenuBentoTileState();
}

class _QlypMenuBentoTileState extends State<QlypMenuBentoTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final iconColor =
        isDark ? QlypColors.onDarkPrimary : QlypColors.midnightQlyp;
    final chevronColor =
        isDark ? QlypColors.onDarkSecondary : QlypColors.grey400;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: kDurXS,
        curve: kQlypSpring,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 10 : 14,
            vertical: widget.compact ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: isDark ? QlypColors.midnight : Colors.white,
            borderRadius: BorderRadius.circular(QlypStyle.bentoRadius),
            border: Border.all(
              color: isDark
                  ? QlypColors.glassNavDriverBorder
                  : QlypColors.grayLight,
            ),
            boxShadow: isDark ? null : QlypStyle.floatingShadowLight,
          ),
          child: Row(
            children: [
              PhosphorIcon(
                widget.icon,
                size: widget.compact ? 20 : 22,
                color: iconColor,
              ),
              SizedBox(width: widget.compact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QlypTypography.buttonLabel(brightness: brightness),
                    ),
                    if (widget.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: QlypTypography.secondaryDescription(
                          brightness: brightness,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.showChevron)
                PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  size: 18,
                  color: chevronColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}