import 'package:flutter/material.dart';

import '../constants/qlyp_animations.dart';
import '../constants/qlyp_colors.dart';
import '../services/qlyp_lottie_view.dart';

enum QlypLoadingSize { button, inline, fullscreen }

/// Lottie `loading.json` — tailles bouton (20), inline (40), plein écran (80).
class QlypLoading extends StatelessWidget {
  const QlypLoading({
    super.key,
    this.size = QlypLoadingSize.inline,
    this.color,
  });

  final QlypLoadingSize size;
  final Color? color;

  double get _dimension {
    switch (size) {
      case QlypLoadingSize.button:
        return 20;
      case QlypLoadingSize.inline:
        return 40;
      case QlypLoadingSize.fullscreen:
        return 80;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return SizedBox(
        width: _dimension,
        height: _dimension,
        child: CircularProgressIndicator(
          strokeWidth: size == QlypLoadingSize.button ? 2 : 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return QlypLottieView(
      assetPath: QlypAnimations.loading,
      width: _dimension,
      height: _dimension,
      repeat: true,
    );
  }
}

/// Attente chauffeur — `searching_driver.json`.
class QlypSearching extends StatelessWidget {
  const QlypSearching({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return QlypLoading(size: QlypLoadingSize.inline);
    }

    return QlypLottieView(
      assetPath: QlypAnimations.searchingDriver,
      width: size,
      height: size,
      repeat: true,
    );
  }
}

/// Overlay plein écran pour remplacer EasyLoading / showLoader.
class QlypLoadingOverlay extends StatelessWidget {
  const QlypLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: QlypColors.midnightQlyp.withValues(alpha: 0.35),
      child: const Center(
        child: QlypLoading(size: QlypLoadingSize.fullscreen),
      ),
    );
  }
}
