import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';

enum QlypSnackbarType { success, error, warning, info }

class QlypSnackbar {
  QlypSnackbar._();

  static OverlayEntry? _entry;
  static Timer? _timer;
  static _QlypSnackbarOverlayState? _overlayState;

  static void show(
    String message, {
    QlypSnackbarType type = QlypSnackbarType.info,
    String? title,
    Duration? duration,
  }) {
    final String text = message.trim();
    if (text.isEmpty) return;

    final BuildContext? ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    _dismiss(immediate: true);

    _entry = OverlayEntry(
      builder: (overlayContext) => _QlypSnackbarOverlay(
        message: text,
        title: title?.trim().isEmpty == true ? null : title?.trim(),
        type: type,
        onDismiss: () => _dismiss(immediate: false),
        onReady: (state) => _overlayState = state,
      ),
    );

    Overlay.of(ctx, rootOverlay: true).insert(_entry!);

    _timer = Timer(duration ?? _readingDuration(text), () {
      _dismiss(immediate: false);
    });
  }

  static Duration _readingDuration(String message) {
    final int length = message.length;
    final int ms = 3200 + (length * 70);
    return Duration(milliseconds: ms.clamp(3200, 9000));
  }

  static Future<void> _dismiss({required bool immediate}) async {
    _timer?.cancel();
    _timer = null;

    if (_entry == null) return;

    if (!immediate && _overlayState != null) {
      await _overlayState!.animateOut();
    }

    _entry?.remove();
    _entry = null;
    _overlayState = null;
  }

  static _SnackbarPalette _palette(QlypSnackbarType type, bool isDark) {
    switch (type) {
      case QlypSnackbarType.success:
        return _SnackbarPalette(
          accent: isDark ? const Color(0xFF1BAF52) : QlypColors.emerald,
          icon: PhosphorIconsFill.checkCircle,
          tint: isDark
              ? QlypColors.emerald.withValues(alpha: 0.14)
              : QlypColors.glassSuccess,
          border: isDark
              ? QlypColors.emerald.withValues(alpha: 0.35)
              : QlypColors.glassSuccessBorder,
        );
      case QlypSnackbarType.error:
        return _SnackbarPalette(
          accent: QlypColors.red,
          icon: PhosphorIconsFill.xCircle,
          tint: QlypColors.red.withValues(alpha: isDark ? 0.16 : 0.08),
          border: QlypColors.red.withValues(alpha: 0.28),
        );
      case QlypSnackbarType.warning:
        return _SnackbarPalette(
          accent: QlypColors.amber,
          icon: PhosphorIconsFill.warning,
          tint: QlypColors.amber.withValues(alpha: isDark ? 0.16 : 0.10),
          border: QlypColors.amber.withValues(alpha: 0.30),
        );
      case QlypSnackbarType.info:
        return _SnackbarPalette(
          accent: QlypColors.blue,
          icon: PhosphorIconsFill.info,
          tint: QlypColors.blue.withValues(alpha: isDark ? 0.16 : 0.08),
          border: QlypColors.blue.withValues(alpha: 0.26),
        );
    }
  }
}

class _SnackbarPalette {
  final Color accent;
  final IconData icon;
  final Color tint;
  final Color border;

  const _SnackbarPalette({
    required this.accent,
    required this.icon,
    required this.tint,
    required this.border,
  });
}

class _QlypSnackbarOverlay extends StatefulWidget {
  final String message;
  final String? title;
  final QlypSnackbarType type;
  final VoidCallback onDismiss;
  final void Function(_QlypSnackbarOverlayState state) onReady;

  const _QlypSnackbarOverlay({
    required this.message,
    required this.title,
    required this.type,
    required this.onDismiss,
    required this.onReady,
  });

  @override
  State<_QlypSnackbarOverlay> createState() => _QlypSnackbarOverlayState();
}

class _QlypSnackbarOverlayState extends State<_QlypSnackbarOverlay> {
  static const double _slideDistance = 72;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady(this);
      animateIn();
    });
  }

  Future<void> animateIn() async {
    if (!mounted) return;
    setState(() => _visible = true);
  }

  Future<void> animateOut() async {
    if (!mounted) return;
    setState(() => _visible = false);
    await Future<void>.delayed(kDurSheet);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final _SnackbarPalette palette =
        QlypSnackbar._palette(widget.type, isDark);

    final Color surface = isDark ? QlypColors.midnight : QlypColors.white;
    final Color messageColor =
        isDark ? QlypColors.onDarkPrimary : QlypColors.textPrimary;
    final Color titleColor =
        isDark ? QlypColors.white : QlypColors.textPrimary;
    final textTheme = Theme.of(context).textTheme;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: widget.onDismiss,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AnimatedContainer(
                duration: kDurSheet,
                curve: kQlypFluid,
                transform: Matrix4.translationValues(
                  0,
                  _visible ? 0 : _slideDistance,
                  0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.border),
                      boxShadow: [
                        BoxShadow(
                          color: QlypColors.midnightQlyp
                              .withValues(alpha: isDark ? 0.40 : 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: palette.tint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                palette.icon,
                                color: palette.accent,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.title != null) ...[
                                  Text(
                                    widget.title!,
                                    style: textTheme.headlineSmall
                                        ?.copyWith(color: titleColor),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  widget.message,
                                  style: textTheme.bodyLarge
                                      ?.copyWith(color: messageColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
