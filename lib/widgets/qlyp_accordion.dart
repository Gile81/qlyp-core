import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';
import 'qlyp_pressable.dart';
import 'qlyp_slide_in.dart';

enum QlypAccordionVariant { light, dark }

/// Section repliable (FAQ, preferences) — Fluid kDurList + contenu QlypSlideIn.
class QlypAccordion extends StatefulWidget {
  QlypAccordion({
    super.key,
    required this.title,
    this.child,
    this.children = const [],
    this.subtitle,
    this.variant = QlypAccordionVariant.light,
    this.isExpanded,
    this.onExpansionChanged,
    this.initiallyExpanded = false,
  }) : assert(child != null || children.isNotEmpty);

  final String title;
  final String? subtitle;
  final Widget? child;
  final List<Widget> children;
  final QlypAccordionVariant variant;
  final bool? isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool initiallyExpanded;

  @override
  State<QlypAccordion> createState() => _QlypAccordionState();
}

class _QlypAccordionState extends State<QlypAccordion>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _sizeController;
  late Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isExpanded ?? widget.initiallyExpanded;
    _sizeController = AnimationController(vsync: this);
    _sizeFactor = CurvedAnimation(parent: _sizeController, curve: kQlypFluid);
    if (_expanded) _sizeController.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sizeController.duration =
        QlypMotionAccessibility.duration(context, kDurList);
  }

  @override
  void didUpdateWidget(covariant QlypAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != null && widget.isExpanded != _expanded) {
      _setExpanded(widget.isExpanded!);
    }
  }

  void _setExpanded(bool value) {
    if (_expanded == value) return;
    setState(() => _expanded = value);
    if (QlypMotionAccessibility.reduceMotionOf(context)) {
      _sizeController.value = value ? 1 : 0;
    } else if (value) {
      _sizeController.forward();
    } else {
      _sizeController.reverse();
    }
    widget.onExpansionChanged?.call(value);
  }

  List<Widget> _bodyChildren() {
    final items = widget.children.isNotEmpty
        ? widget.children
        : [if (widget.child != null) widget.child!];
    return [
      for (var i = 0; i < items.length; i++)
        QlypSlideIn(
          key: ValueKey('acc-line-$i'),
          delay: kDurSlideInStaggerAt(i),
          visible: _expanded,
          child: Padding(
            padding: EdgeInsets.only(bottom: i < items.length - 1 ? 8 : 0),
            child: items[i],
          ),
        ),
    ];
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.variant == QlypAccordionVariant.dark;
    final titleColor =
        isDark ? QlypColors.onDarkPrimary : QlypColors.textPrimary;
    final subtitleColor =
        isDark ? QlypColors.onDarkSecondary : QlypColors.gray;
    final borderColor =
        isDark ? QlypColors.glassNavDriverBorder : QlypColors.grayLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QlypPressable(
          semanticsLabel: widget.title,
          onTap: () => _setExpanded(!_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: titleColor,
                            ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: subtitleColor,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: QlypMotionAccessibility.duration(context, kDurList),
                  curve: kQlypFluid,
                  child: Icon(
                    PhosphorIcons.caretDown(),
                    color: subtitleColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeFactor,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _bodyChildren(),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: borderColor),
      ],
    );
  }
}