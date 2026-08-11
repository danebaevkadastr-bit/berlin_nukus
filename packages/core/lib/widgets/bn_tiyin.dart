import 'dart:math' as math;
import 'package:flutter/material.dart';

/// BN-Tiyin — Berlin-Nukus tangasi.
/// Aylanuvchi animatsiyali tanga widget'i.
/// [size] — diametr (default 32).
/// [spinning] — doimiy aylanish (default false, faqat yarim-aylanish effekti).
class BnTiyin extends StatefulWidget {
  final double size;
  final bool spinning;

  const BnTiyin({super.key, this.size = 32, this.spinning = false});

  @override
  State<BnTiyin> createState() => _BnTiynState();
}

class _BnTiynState extends State<BnTiyin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spin;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _spin = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.spinning) {
      _controller.repeat();
    } else {
      // Bir marta yarim aylanib to'xtaydi — idle flip effekti
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, child) {
        // Horizontal 3D coin flip (X-axis perspective)
        final angle = _spin.value * 2 * math.pi;
        // Squish effect: width shrinks to 0 at 90° and 270°
        final scaleX = math.cos(angle).abs();
        final showFront = math.cos(angle) >= 0;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(scaleX, 1.0),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CoinPainter(showFront: showFront),
            ),
          ),
        );
      },
    );
  }
}

/// Tanga rassamchisi — old va orqa tomonlarni chizadi.
class _CoinPainter extends CustomPainter {
  final bool showFront;
  _CoinPainter({required this.showFront});

  // Tanga ranglari
  static const _gold = Color(0xFFD4A017);
  static const _goldDark = Color(0xFFB8860B);
  static const _goldLight = Color(0xFFFFD700);
  static const _goldHighlight = Color(0xFFFFF0A0);
  static const _goldRim = Color(0xFF8B6914);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Qirrali tanga effekti — tashqi doira
    final rimPaint = Paint()
      ..shader = RadialGradient(
        colors: [_goldLight, _goldDark, _goldRim],
        stops: const [0.7, 0.85, 1.0],
        center: Alignment.topLeft,
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r, rimPaint);

    // Asosiy tanga yuzi — gradient
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: showFront
            ? [_goldHighlight, _gold, _goldDark]
            : [_goldHighlight, _goldDark, _gold],
        stops: const [0.0, 0.6, 1.0],
        center: showFront ? const Alignment(-0.3, -0.3) : const Alignment(0.3, -0.3),
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.88));

    canvas.drawCircle(Offset(cx, cy), r * 0.88, facePaint);

    // Chekkadagi tishli qirralar (numizmatik effekt)
    _drawRimSerrations(canvas, cx, cy, r);

    if (showFront) {
      _drawFront(canvas, cx, cy, r * 0.88);
    } else {
      _drawBack(canvas, cx, cy, r * 0.88);
    }
  }

  /// Tanga chetidagi tishchalar
  void _drawRimSerrations(Canvas canvas, double cx, double cy, double r) {
    final rimPaint = Paint()
      ..color = _goldRim.withValues(alpha: 0.5)
      ..strokeWidth = r * 0.03
      ..style = PaintingStyle.stroke;

    const teeth = 36;
    for (int i = 0; i < teeth; i++) {
      final angle = (i / teeth) * 2 * math.pi;
      final r1 = r * 0.89;
      final r2 = r * 0.96;
      canvas.drawLine(
        Offset(cx + r1 * math.cos(angle), cy + r1 * math.sin(angle)),
        Offset(cx + r2 * math.cos(angle), cy + r2 * math.sin(angle)),
        rimPaint,
      );
    }
  }

  /// OLD: Brandenburg darvozasi + o'tov silhouette
  void _drawFront(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()
      ..color = _goldDark.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final scale = r / 50;

    // Brandenburg darvozasi — sodda siluet
    // Ustki ustunlar (5 ta)
    for (int i = 0; i < 5; i++) {
      final x = cx + (-16 + i * 8) * scale;
      final top = cy - 20 * scale;
      final bot = cy - 8 * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 2.5 * scale, top, 5 * scale, bot - top),
          Radius.circular(1 * scale),
        ),
        p,
      );
    }
    // Gorizontal perron
    canvas.drawRect(
      Rect.fromLTWH(cx - 22 * scale, cy - 22 * scale, 44 * scale, 4 * scale),
      p,
    );
    // Kvadriga (tepada otlar) — oddiy uchburchak
    final quad = Path()
      ..moveTo(cx, cy - 28 * scale)
      ..lineTo(cx - 8 * scale, cy - 22 * scale)
      ..lineTo(cx + 8 * scale, cy - 22 * scale)
      ..close();
    canvas.drawPath(quad, p);
    // Darvoza yon devorlar
    canvas.drawRect(Rect.fromLTWH(cx - 22 * scale, cy - 8 * scale, 6 * scale, 10 * scale), p);
    canvas.drawRect(Rect.fromLTWH(cx + 16 * scale, cy - 8 * scale, 6 * scale, 10 * scale), p);
    // Markaziy eshik arkasi
    final arch = Path()
      ..moveTo(cx - 6 * scale, cy + 2 * scale)
      ..lineTo(cx - 6 * scale, cy - 6 * scale)
      ..arcToPoint(Offset(cx + 6 * scale, cy - 6 * scale), radius: Radius.circular(6 * scale))
      ..lineTo(cx + 6 * scale, cy + 2 * scale)
      ..close();
    canvas.drawPath(arch, p..style = PaintingStyle.stroke..strokeWidth = 1.5 * scale);
    p.style = PaintingStyle.fill;

    // O'TOV — pastda
    // Gumbaz
    final yurtDome = Path()
      ..moveTo(cx - 12 * scale, cy + 10 * scale)
      ..quadraticBezierTo(cx, cy + 2 * scale, cx + 12 * scale, cy + 10 * scale)
      ..close();
    canvas.drawPath(yurtDome, p);
    // Eshik
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 9 * scale), width: 5 * scale, height: 7 * scale),
      p..style = PaintingStyle.stroke..strokeWidth = 1.5 * scale,
    );
    p.style = PaintingStyle.fill;
    // Yurt tanasi
    canvas.drawRect(
      Rect.fromLTWH(cx - 12 * scale, cy + 10 * scale, 24 * scale, 5 * scale),
      p,
    );

    // Pastki yozuv chizig'i
    _drawArcText(canvas, cx, cy, r * 0.82, 'DEUTSCHLAND · QARAQALPAQSTAN', scale);
  }

  /// ORQA: BN monogram + o'tov + barglar
  void _drawBack(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()
      ..color = _goldDark.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final scale = r / 50;

    // Tashqi doira chizig'i
    canvas.drawCircle(Offset(cx, cy), r * 0.82, Paint()
      ..color = _goldDark.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale);

    // BN monogram (yuqorida)
    _drawBnMonogram(canvas, cx, cy - 14 * scale, 10 * scale, p);

    // O'tov — markazda
    final yurtDome = Path()
      ..moveTo(cx - 14 * scale, cy + 4 * scale)
      ..quadraticBezierTo(cx, cy - 8 * scale, cx + 14 * scale, cy + 4 * scale)
      ..close();
    canvas.drawPath(yurtDome, p);
    canvas.drawRect(
      Rect.fromLTWH(cx - 14 * scale, cy + 4 * scale, 28 * scale, 6 * scale),
      p,
    );
    // Eshik
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 6 * scale), width: 6 * scale, height: 8 * scale),
      p..style = PaintingStyle.stroke..strokeWidth = 1.5 * scale,
    );
    p.style = PaintingStyle.fill;

    // Zangori barglar (chap va o'ng)
    _drawLeafBranch(canvas, cx - 18 * scale, cy, scale, p, left: true);
    _drawLeafBranch(canvas, cx + 18 * scale, cy, scale, p, left: false);
  }

  /// BN monogram
  void _drawBnMonogram(Canvas canvas, double cx, double cy, double r, Paint p) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'BN',
        style: TextStyle(
          fontSize: r * 1.4,
          fontWeight: FontWeight.w900,
          color: _goldDark.withValues(alpha: 0.6),
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    // Doira
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.1,
      p..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    p.style = PaintingStyle.fill;
  }

  /// Barg shoxchasi
  void _drawLeafBranch(Canvas canvas, double x, double y, double scale, Paint p, {required bool left}) {
    final sign = left ? -1.0 : 1.0;
    for (int i = 0; i < 4; i++) {
      final angle = (left ? math.pi * 0.15 : math.pi * 0.85) + sign * i * 0.25;
      final ox = x + sign * i * 3 * scale;
      final oy = y - i * 3 * scale;
      final leaf = Path()
        ..moveTo(ox, oy)
        ..quadraticBezierTo(
          ox + 4 * scale * math.cos(angle - 0.5),
          oy - 4 * scale * math.sin(angle - 0.5),
          ox + 8 * scale * math.cos(angle),
          oy - 8 * scale * math.sin(angle),
        )
        ..quadraticBezierTo(
          ox + 4 * scale * math.cos(angle + 0.5),
          oy - 4 * scale * math.sin(angle + 0.5),
          ox, oy,
        );
      canvas.drawPath(leaf, p..style = PaintingStyle.fill..color = _goldDark.withValues(alpha: 0.45));
    }
    p.color = _goldDark.withValues(alpha: 0.55);
    p.style = PaintingStyle.fill;
  }

  /// Doira bo'ylab yozuv (oddiy pastki yoy)
  void _drawArcText(Canvas canvas, double cx, double cy, double r, String text, double scale) {
    // Pastki qismga chiziq bo'ylab joylashtirish
    const startAngle = math.pi * 0.15;
    const sweepAngle = math.pi * 0.70;
    const charCount = 30;
    final chars = text.split('');
    for (int i = 0; i < chars.length && i < charCount; i++) {
      final angle = startAngle + (i / (chars.length - 1)) * sweepAngle;
      canvas.save();
      canvas.translate(
        cx + r * math.cos(angle),
        cy + r * math.sin(angle),
      );
      canvas.rotate(angle + math.pi / 2);
      final ctp = TextPainter(
        text: TextSpan(
          text: chars[i],
          style: TextStyle(
            fontSize: 4.5 * scale,
            fontWeight: FontWeight.w700,
            color: _goldDark.withValues(alpha: 0.65),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      ctp.paint(canvas, Offset(-ctp.width / 2, -ctp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) => old.showFront != showFront;
}
