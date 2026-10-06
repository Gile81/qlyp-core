import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../config/typography.dart';
import '../constants/qlyp_colors.dart';
import 'qlyp_pressable.dart';

/// Ligne de liste — icone, titre, sous-titre, chevron ou valeur.
class QlypListTile extends StatelessWidget {
  const QlypListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onDark = false,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final titleStyle = QlypTypography.body(
      brightness: onDark ? Brightness.dark : Brightness.light,
    );
    final subStyle = QlypTypography.secondaryDescription(
      brightness: onDark ? Brightness.dark : Brightness.light,
    );
    final iconColor =
        onDark ? QlypColors.onDarkPrimary : QlypColors.midnightQlyp;
    final divider = onDark ? QlypColors.glassNavDriverBorder : QlypColors.grayLight;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, color: iconColor, size: QlypStyle.buttonIconSizeMedium),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: subStyle),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onTap != null)
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              color: iconColor,
              size: 18,
            ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onTap == null)
          row
        else
          QlypPressable(semanticsLabel: title, onTap: onTap, child: row),
        Divider(height: 1, thickness: 1, color: divider),
      ],
    );
  }
}