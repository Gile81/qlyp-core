import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QlypLottieView extends StatelessWidget {
  const QlypLottieView({
    super.key,
    required this.assetPath,
    this.repeat = true,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final bool repeat;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      repeat: repeat,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}