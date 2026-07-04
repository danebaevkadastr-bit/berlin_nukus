import 'dart:math' as math;

import 'package:flutter/material.dart';

/// AI "yozyapti" effekti — uchta nuqta ketma-ket sakrab, xiralashib turadi.
/// Chat ekranlarida AI javob tayyorlayotganda ko'rsatiladi.
class TypingDots extends StatefulWidget {
  /// Har bir nuqta rangi (odatda 3 ta). Bittadan ko'p rang berilsa navbat bilan
  /// ishlatiladi.
  final List<Color> colors;
  final double dotSize;
  final double spacing;

  const TypingDots({
    super.key,
    required this.colors,
    this.dotSize = 8,
    this.spacing = 6,
  });

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.colors.length;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            // Har bir nuqta biroz kechikish bilan harakatlanadi (staggered).
            final t = (_controller.value + i * 0.18) % 1.0;
            final wave = (math.sin(t * 2 * math.pi) + 1) / 2; // 0..1
            final dy = -5.0 * wave; // yuqoriga sakrash
            final opacity = 0.35 + 0.65 * wave;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: widget.colors[i % count],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
