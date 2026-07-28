import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Clay Matte Yonuvchi Olov (Aynan Duolingo Rasmiga 100% Mos).
///
/// 1. Dastlab kulrang bo'lib turadi.
/// 2. Pastdan yuqoriga qarab 3D to'q sariq va sariq rangga aylanadi (Ignition).
/// 3. Yonib bo'lgach, sekin to'lqinlanadi va pulsatsiyalanadi (Idle Loop).
class AnimatedFlameWidget extends StatefulWidget {
  final double size;
  final VoidCallback? onIgnited;

  const AnimatedFlameWidget({
    super.key,
    this.size = 220.0,
    this.onIgnited,
  });

  @override
  State<AnimatedFlameWidget> createState() => _AnimatedFlameWidgetState();
}

class _AnimatedFlameWidgetState extends State<AnimatedFlameWidget>
    with TickerProviderStateMixin {
  late final AnimationController _ignitionCtrl;
  late final Animation<double> _ignitionAnim;
  late final AnimationController _idleCtrl;

  @override
  void initState() {
    super.initState();

    _ignitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _ignitionAnim = CurvedAnimation(
      parent: _ignitionCtrl,
      curve: Curves.easeInOutCubic,
    );

    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _ignitionCtrl.forward().then((_) {
          widget.onIgnited?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _ignitionCtrl.dispose();
    _idleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ignitionCtrl, _idleCtrl]),
      builder: (context, child) {
        final ignitionProgress = _ignitionAnim.value;
        final idleValue = _idleCtrl.value;

        final scale = 1.0 + 0.03 * math.sin(idleValue * math.pi);
        final swayAngle = 0.03 * math.sin(idleValue * math.pi * 2);

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: swayAngle,
            child: CustomPaint(
              size: Size(widget.size, widget.size * 1.15),
              painter: _Duolingo3DFlamePainter(
                ignitionProgress: ignitionProgress,
                idleProgress: idleValue,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Duolingo3DFlamePainter extends CustomPainter {
  final double ignitionProgress;
  final double idleProgress;

  _Duolingo3DFlamePainter({
    required this.ignitionProgress,
    required this.idleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final tipSway = 5.0 * math.sin(idleProgress * math.pi * 2);
    final notchSway = 3.0 * math.cos(idleProgress * math.pi * 2);

    // ----------------------------------------------------
    // 1. PASSIQ 3D YUMSHOQ SOYA (Bottom Soft Drop Shadow)
    // ----------------------------------------------------
    final shadowPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.black.withValues(alpha: 0.14 * ignitionProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawOval(
      Rect.fromLTWH(w * 0.20, h * 0.82, w * 0.60, h * 0.12),
      shadowPaint,
    );

    // ----------------------------------------------------
    // 2. ASOSIY 3D CLAY OLOV (Volumetric Outer Flame)
    // ----------------------------------------------------
    final outerPath = Path();

    // Tepasi (Main Tip)
    final topX = w * 0.46 + tipSway;
    final topY = h * 0.08;

    // O'ng shoxcha (Right Notch)
    final notchX = w * 0.78 + notchSway;
    final notchY = h * 0.38;

    outerPath.moveTo(topX, topY);

    // Tepa uchdan o'ng shoxchagacha
    outerPath.cubicTo(
      w * 0.60, h * 0.16,
      w * 0.70, h * 0.26,
      notchX, notchY,
    );

    // O'ng shoxchadan pastki sharsimon asosgacha
    outerPath.cubicTo(
      w * 0.94, h * 0.48,
      w * 0.90, h * 0.78,
      w * 0.50, h * 0.82,
    );

    // Pastki sharsimon asosdan chap elka tomongacha
    outerPath.cubicTo(
      w * 0.10, h * 0.78,
      w * 0.08, h * 0.44,
      w * 0.28, h * 0.22,
    );

    // Chap elkadan tepa uchga
    outerPath.cubicTo(
      w * 0.36, h * 0.14,
      w * 0.40, h * 0.10,
      topX, topY,
    );

    outerPath.close();

    // 3D Clay Gradient (Kulrang -> Duolingo Issiq To'q Sariq Clay)
    final outerPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    outerPaint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: const [
        Color(0xFFFF7A00), // Tubi: To'q issiq sariq-olov
        Color(0xFFFFA000), // O'rtasi: Duolingo soft clay orange
        Color(0xFFFFB74D), // Tepasi: Yumshoq 3D och sariq
        Color(0xFFB0BEC5), // Kulrang (Yonmagan)
        Color(0xFF78909C), // To'q kulrang
      ],
      stops: [
        0.0,
        (ignitionProgress * 0.55).clamp(0.0, 1.0),
        (ignitionProgress * 0.90).clamp(0.0, 1.0),
        (ignitionProgress + 0.01).clamp(0.0, 1.0),
        1.0,
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(outerPath, outerPaint);

    // 3D Hajmli Yorug'lik (Soft Top-Left Radial Specular Light)
    if (ignitionProgress > 0.1) {
      final ambientLight = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.75,
          colors: [
            Colors.white.withValues(alpha: 0.28 * ignitionProgress),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      canvas.drawPath(outerPath, ambientLight);
    }

    // ----------------------------------------------------
    // 3. ICHKI 3D TOMCHI (Inner 3D Yellow Core Bulb)
    // ----------------------------------------------------
    final innerPath = Path();
    final innerTopX = w * 0.50 + tipSway * 0.3;
    final innerTopY = h * 0.44;

    innerPath.moveTo(innerTopX, innerTopY);
    innerPath.cubicTo(
      w * 0.64, h * 0.54,
      w * 0.62, h * 0.76,
      w * 0.50, h * 0.78,
    );
    innerPath.cubicTo(
      w * 0.38, h * 0.76,
      w * 0.36, h * 0.54,
      innerTopX, innerTopY,
    );
    innerPath.close();

    final innerPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    innerPaint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: const [
        Color(0xFFFFCA28), // Asosi: Oltin sariq 3D clay
        Color(0xFFFFE082), // Tepasi: Yumshoq kayfiyatli oq-sariq
        Color(0xFFCFD8DC), // Kulrang (Yonmagan)
      ],
      stops: [
        0.0,
        (ignitionProgress * 0.90).clamp(0.0, 1.0),
        (ignitionProgress + 0.04).clamp(0.0, 1.0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Ichki 3D tomchi soyasi va shakli
    canvas.drawPath(innerPath, innerPaint);

    // Ichki tomchi ustidagi 3D hajmli yorug'lik nuqtasi (Bulb Specular)
    if (ignitionProgress > 0.25) {
      final bulbHighlight = Paint()
        ..isAntiAlias = true
        ..color = Colors.white.withValues(alpha: 0.35 * ignitionProgress);

      canvas.drawOval(
        Rect.fromLTWH(w * 0.44, h * 0.52, w * 0.08, h * 0.08),
        bulbHighlight,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Duolingo3DFlamePainter oldDelegate) {
    return oldDelegate.ignitionProgress != ignitionProgress ||
        oldDelegate.idleProgress != idleProgress;
  }
}
