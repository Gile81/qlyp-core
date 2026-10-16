import 'package:flutter/material.dart';

import '../config/typography.dart';
import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import 'qlyp_loading.dart';
import 'qlyp_pressable.dart';

enum QlypButtonSize { large, medium, small }

enum QlypButtonTone { normal, danger, accent }

enum QlypSecondaryButtonStyle { outlined, subtle }

extension QlypButtonSizeTokens on QlypButtonSize {
  double get height => switch (this) {
        QlypButtonSize.large => QlypStyle.buttonHeightLarge,
        QlypButtonSize.medium => QlypStyle.buttonHeightMedium,
        QlypButtonSize.small => QlypStyle.buttonHeightSmall,
      };

  double get horizontalPadding => switch (this) {
        QlypButtonSize.large => QlypStyle.buttonPaddingHorizontalLarge,
        QlypButtonSize.medium => QlypStyle.buttonPaddingHorizontalMedium,
        QlypButtonSize.small => QlypStyle.buttonPaddingHorizontalSmall,
      };

  double get iconSize => switch (this) {
        QlypButtonSize.large => QlypStyle.buttonIconSizeLarge,
        QlypButtonSize.medium => QlypStyle.buttonIconSizeMedium,
        QlypButtonSize.small => QlypStyle.buttonIconSizeSmall,
      };

  bool get defaultExpanded => this == QlypButtonSize.large;

  TextStyle labelStyle(BuildContext context) => switch (this) {
        QlypButtonSize.small =>
          QlypTypography.buttonLabelSmall(brightness: Theme.of(context).brightness),
        _ => Theme.of(context).textTheme.labelLarge!,
      };
}

/// CTA principal (52 px pleine largeur en bas d’écran ou de feuille) — dégradé brand, un seul par écran.
class QlypPrimaryButton extends StatelessWidget {
  const QlypPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = QlypButtonSize.large,
    this.expanded,
    this.stackedCaption,
    this.stackedDetail,
    this.endLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final QlypButtonSize size;
  final bool? expanded;
  /// Second line (e.g. « Prix indicatif ») with [stackedDetail] below.
  final String? stackedCaption;
  final String? stackedDetail;
  /// Trailing text on the same row as [label] (e.g. price next to « Réserver »).
  final String? endLabel;

  bool get _enabled => onPressed != null && !isLoading;

  bool get _expanded => expanded ?? size.defaultExpanded;

  double get _height {
    if (stackedCaption != null || stackedDetail != null) {
      return QlypStyle.buttonHeightStacked;
    }
    return size.height;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = size.labelStyle(context).copyWith(color: QlypColors.white);
    final captionStyle = QlypTypography.caption(brightness: Theme.of(context).brightness)
        .copyWith(
      color: QlypColors.onDarkSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final detailStyle = QlypTypography.buttonLabelSmall(
      brightness: Theme.of(context).brightness,
    ).copyWith(
      color: QlypColors.white,
      fontWeight: FontWeight.w800,
      fontSize: 13,
    );

    Widget content = isLoading
        ? const QlypLoading(size: QlypLoadingSize.button)
        : _buildLabelContent(textStyle, captionStyle, detailStyle);

    final shell = AnimatedContainer(
      duration: kDurPress,
      curve: kQlypSpring,
      height: _height,
      width: _expanded ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
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
    );

    return QlypPressable(
      enabled: _enabled,
      semanticsLabel: label,
      onTap: _enabled ? onPressed : null,
      child: _expanded ? shell : IntrinsicWidth(child: shell),
    );
  }

  Widget _buildLabelContent(
    TextStyle textStyle,
    TextStyle captionStyle,
    TextStyle detailStyle,
  ) {
    if (stackedCaption != null || stackedDetail != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          if (stackedCaption != null) ...[
            const SizedBox(height: 2),
            Text(
              stackedCaption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: captionStyle,
            ),
          ],
          if (stackedDetail != null)
            Text(
              stackedDetail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: detailStyle,
            ),
        ],
      );
    }
    if (endLabel != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: size.iconSize, color: QlypColors.white),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Text(
            endLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: size.iconSize, color: QlypColors.white),
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
  }
}

/// Action secondaire (44 px dans une carte, contour ou discret) ; [tone] danger = contour rouge, pas de dégradé.
class QlypSecondaryButton extends StatefulWidget {
  const QlypSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = QlypButtonSize.large,
    this.expanded,
    this.style = QlypSecondaryButtonStyle.outlined,
    this.tone = QlypButtonTone.normal,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final QlypButtonSize size;
  final bool? expanded;
  final QlypSecondaryButtonStyle style;
  final QlypButtonTone tone;

  @override
  State<QlypSecondaryButton> createState() => _QlypSecondaryButtonState();
}

class _QlypSecondaryButtonState extends State<QlypSecondaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  bool get _expanded => widget.expanded ?? widget.size.defaultExpanded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDanger = widget.tone == QlypButtonTone.danger;

    final fg = !_enabled
        ? QlypColors.grayDisabled
        : isDanger
            ? QlypColors.red
            : (isDark ? QlypColors.onDarkPrimary : QlypColors.midnightQlyp);

    final textStyle = widget.size.labelStyle(context).copyWith(color: fg);

    Widget content = widget.isLoading
        ? QlypLoading(size: QlypLoadingSize.button, color: fg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.size.iconSize, color: fg),
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
      final borderColor = !_enabled
          ? QlypColors.grayLight
          : isDanger
              ? QlypColors.red
              : (_pressed ? QlypColors.emerald : QlypColors.grayLight);
      border = Border.all(color: borderColor, width: 1.5);
      shadow = _enabled && !isDanger ? QlypStyle.floatingShadowLight : null;
    }

    final shell = AnimatedContainer(
      duration: kDurPress,
      curve: kQlypSpring,
      height: widget.size.height,
      width: _expanded ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: widget.size.horizontalPadding),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill ?? QlypColors.transparent,
        border: border,
        boxShadow: shadow,
        borderRadius: BorderRadius.circular(QlypStyle.buttonRadius),
      ),
      child: content,
    );

    return QlypPressable(
      enabled: _enabled,
      semanticsLabel: widget.label,
      onTap: _enabled ? widget.onPressed : null,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: _expanded ? shell : IntrinsicWidth(child: shell),
      ),
    );
  }
}

/// Lien sans fond (Plus tard, Passer, Voir le détail) — rebond 0,95, pas d’ondulation Material.
class QlypTextButton extends StatelessWidget {
  const QlypTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = QlypButtonTone.normal,
    this.onDark = false,
    this.underlined = false,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final QlypButtonTone tone;
  final bool onDark;
  final bool underlined;
  /// Secondary coverflow / home links (gray, not brand midnight).
  final bool muted;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final color = !_enabled
        ? QlypColors.grayDisabled
        : tone == QlypButtonTone.danger
            ? QlypColors.red
            : tone == QlypButtonTone.accent
                ? QlypColors.amber
                : muted
                    ? QlypColors.gray
                    : (onDark
                        ? QlypColors.onDarkPrimary
                        : QlypColors.midnightQlyp);

    TextStyle? style =
        Theme.of(context).textTheme.labelLarge?.copyWith(color: color);
    if (muted || underlined || tone == QlypButtonTone.accent) {
      style = style?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: muted ? 11 : 14,
        decoration: underlined ? TextDecoration.underline : null,
        decorationColor: color,
      );
    }

    return QlypPressable(
      enabled: _enabled,
      semanticsLabel: label,
      onTap: _enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }
}

/// Bouton rond 44 px (Appeler, Chat, Fermer, Recentrer) — icône 20 px, fond gris clair ou verre sombre.
class QlypIconButton extends StatelessWidget {
  const QlypIconButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
    this.tone = QlypButtonTone.normal,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;
  final QlypButtonTone tone;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = !_enabled
        ? QlypColors.grayDisabled
        : tone == QlypButtonTone.danger
            ? QlypColors.red
            : (isDark ? QlypColors.onDarkPrimary : QlypColors.midnightQlyp);

    final fill = isDark ? QlypColors.glassNavDriver : QlypColors.grayVeryLight;

    return QlypPressable(
      enabled: _enabled,
      semanticsLabel: semanticsLabel,
      onTap: _enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: kDurPress,
        curve: kQlypSpring,
        width: QlypStyle.iconButtonSize,
        height: QlypStyle.iconButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: isDark
              ? Border.all(color: QlypColors.glassNavDriverBorder)
              : null,
          boxShadow: _enabled ? QlypStyle.floatingShadowLight : null,
        ),
        child: Icon(icon, size: QlypStyle.iconButtonIconSize, color: fg),
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
    this.size = QlypButtonSize.large,
    this.expanded,
    this.stackedCaption,
    this.stackedDetail,
    this.endLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final QlypButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final QlypButtonSize size;
  final bool? expanded;
  final String? stackedCaption;
  final String? stackedDetail;
  final String? endLabel;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case QlypButtonVariant.primary:
        return QlypPrimaryButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          size: size,
          expanded: expanded,
          stackedCaption: stackedCaption,
          stackedDetail: stackedDetail,
          endLabel: endLabel,
        );
      case QlypButtonVariant.secondary:
        return QlypSecondaryButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          size: size,
          expanded: expanded,
        );
      case QlypButtonVariant.ghost:
        return QlypSecondaryButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          size: size,
          expanded: expanded,
          style: QlypSecondaryButtonStyle.subtle,
        );
    }
  }
}
