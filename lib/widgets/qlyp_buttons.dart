import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import 'qlyp_loading.dart';
import 'qlyp_pressable.dart';

enum QlypSecondaryButtonStyle { outlined, subtle }

/// CTA principal — dégradé Brand, texte blanc, rayon 12, ombre flottante.
class QlypPrimaryButton extends StatelessWidget {
  const QlypPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  static const double _height = 52;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: QlypColors.white,
        );

    Widget content = isLoading
        ? const QlypLoading(size: QlypLoadingSize.button)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: QlypColors.white),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
            ],
          );

    return QlypPressable(
      enabled: _enabled,
      semanticsLabel: label,
      onTap: _enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: kDurPress,
        curve: kQlypSpring,
        height: _height,
        width: expanded ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: _enabled
              ? QlypStyle.brandGradient
              : LinearGradient(
                  colors: [
                    QlypColors.grayDisabled,
                    QlypColors.grayDisabled,
                  ],
                ),
          boxShadow: _enabled ? QlypStyle.floatingShadow : null,
          borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
        ),
        child: content,
      ),
    );
  }
}

/// Action secondaire (contour) ou discrète (fond léger).
class QlypSecondaryButton extends StatefulWidget {
  const QlypSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.style = QlypSecondaryButtonStyle.outlined,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;
  final QlypSecondaryButtonStyle style;

  @override
  State<QlypSecondaryButton> createState() => _QlypSecondaryButtonState();
}

class _QlypSecondaryButtonState extends State<QlypSecondaryButton> {
  static const double _height = 52;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = _enabled
        ? (isDark ? QlypColors.onDarkPrimary : QlypColors.midnightQlyp)
        : QlypColors.grayDisabled;

    final textStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(color: fg);

    Widget content = widget.isLoading
        ? QlypLoading(size: QlypLoadingSize.button, color: fg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
            ],
          );

    Color? fill;
    BoxBorder? border;
    List<BoxShadow>? shadow;

    if (widget.style == QlypSecondaryButtonStyle.subtle) {
      fill = isDark ? QlypColors.midnightMid : QlypColors.grayVeryLight;
    } else {
      border = Border.all(
        color: _enabled
            ? (_pressed ? QlypColors.emerald : QlypColors.grayLight)
            : QlypColors.grayLight,
        width: 1.5,
      );
      shadow = _enabled ? QlypStyle.floatingShadowLight : null;
    }

    return QlypPressable(
      enabled: _enabled,
      semanticsLabel: widget.label,
      onTap: _enabled ? widget.onPressed : null,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: kDurPress,
          curve: kQlypSpring,
          height: _height,
          width: widget.expanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill ?? QlypColors.transparent,
            border: border,
            boxShadow: shadow,
            borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Variantes legacy client (primary / secondary / ghost).
enum QlypButtonVariant { primary, secondary, ghost }

/// Alias de migration — préférer [QlypPrimaryButton] / [QlypSecondaryButton].
class QlypButton extends StatelessWidget {
  const QlypButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = QlypButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final QlypButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case QlypButtonVariant.primary:
        return QlypPrimaryButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          expanded: expanded,
        );
      case QlypButtonVariant.secondary:
        return QlypSecondaryButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          expanded: expanded,
        );
      case QlypButtonVariant.ghost:
        return QlypSecondaryButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          expanded: expanded,
          style: QlypSecondaryButtonStyle.subtle,
        );
    }
  }
}
