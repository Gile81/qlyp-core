import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../config/typography.dart';
import '../constants/qlyp_colors.dart';

class QlypAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QlypAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? QlypColors.midnight : QlypColors.pearl,
      foregroundColor:
          isDark ? QlypColors.onDarkPrimary : QlypColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: Text(
        title,
        style: QlypTypography.h3(brightness: brightness),
      ),
      actions: actions,
    );
  }
}

IconData qlypAppBarBackIcon() => PhosphorIcons.caretLeft();
