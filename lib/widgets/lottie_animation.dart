import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;
  final bool autoPlay;

  const LottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.repeat = true,
    this.autoPlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      animate: autoPlay,
      fit: BoxFit.contain,
    );
  }
}

// Predefined Lottie animations for common use cases
class LoadingAnimation extends StatelessWidget {
  final double? size;

  const LoadingAnimation({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/loading.json',
      width: size,
      height: size,
    );
  }
}

class SuccessAnimation extends StatelessWidget {
  final double? size;

  const SuccessAnimation({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/success.json',
      width: size,
      height: size,
      repeat: false,
    );
  }
}

class ErrorAnimation extends StatelessWidget {
  final double? size;

  const ErrorAnimation({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/error.json',
      width: size,
      height: size,
      repeat: false,
    );
  }
}

class EmptyStateAnimation extends StatelessWidget {
  final double? size;

  const EmptyStateAnimation({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/empty.json',
      width: size,
      height: size,
      repeat: true,
    );
  }
}

class CelebrationAnimation extends StatelessWidget {
  final double? size;

  const CelebrationAnimation({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/celebration.json',
      width: size,
      height: size,
      repeat: false,
    );
  }
}
