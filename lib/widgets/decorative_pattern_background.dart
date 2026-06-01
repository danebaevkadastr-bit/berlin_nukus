import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// O'quv/o'yin ekranlari uchun yumshoq bezakli fon (der, die, das va h.k.).
enum DecorativePatternVariant {
  derDieDas,
  synonymBattle,
}

enum _GlyphKind { text, shapeX, shapeO }

class _PatternGlyph {
  final double x; // 0..1
  final double y;
  final double rotation;
  final double scale;
  final _GlyphKind kind;
  final String? text;
  final Color color;

  const _PatternGlyph({
    required this.x,
    required this.y,
    required this.rotation,
    required this.scale,
    required this.kind,
    this.text,
    required this.color,
  });

  const _PatternGlyph.text({
    required double x,
    required double y,
    required double rotation,
    required double scale,
    required String text,
    required Color color,
  }) : this(
          x: x,
          y: y,
          rotation: rotation,
          scale: scale,
          kind: _GlyphKind.text,
          text: text,
          color: color,
        );

  const _PatternGlyph.shapeX({
    required double x,
    required double y,
    required double rotation,
    required double scale,
    required Color color,
  }) : this(
          x: x,
          y: y,
          rotation: rotation,
          scale: scale,
          kind: _GlyphKind.shapeX,
          color: color,
        );

  const _PatternGlyph.shapeO({
    required double x,
    required double y,
    required double rotation,
    required double scale,
    required Color color,
  }) : this(
          x: x,
          y: y,
          rotation: rotation,
          scale: scale,
          kind: _GlyphKind.shapeO,
          color: color,
        );
}

class DecorativePatternBackground extends StatelessWidget {
  final Widget child;
  final DecorativePatternVariant variant;
  final bool isDark;

  const DecorativePatternBackground({
    super.key,
    required this.child,
    this.variant = DecorativePatternVariant.derDieDas,
    required this.isDark,
  });

  static List<_PatternGlyph> _glyphsFor(DecorativePatternVariant variant) {
    switch (variant) {
      case DecorativePatternVariant.derDieDas:
        return const [
          // Artikllar
          _PatternGlyph.text(x: 0.06, y: 0.07, rotation: -0.35, scale: 1.0, text: 'der', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.84, y: 0.05, rotation: 0.25, scale: 0.95, text: 'die', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.12, y: 0.20, rotation: 0.15, scale: 0.78, text: 'das', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.90, y: 0.17, rotation: -0.2, scale: 1.08, text: 'DER', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.03, y: 0.40, rotation: 0.42, scale: 0.88, text: 'DIE', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.94, y: 0.36, rotation: -0.48, scale: 0.82, text: 'DAS', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.20, y: 0.55, rotation: -0.12, scale: 0.72, text: 'der', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.76, y: 0.50, rotation: 0.32, scale: 0.98, text: 'die', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.08, y: 0.70, rotation: 0.22, scale: 1.02, text: 'das', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.68, y: 0.66, rotation: -0.28, scale: 0.84, text: 'der', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.38, y: 0.86, rotation: -0.38, scale: 0.92, text: 'die', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.56, y: 0.76, rotation: 0.18, scale: 0.76, text: 'das', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.50, y: 0.10, rotation: 0.55, scale: 0.62, text: 'der', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.28, y: 0.32, rotation: -0.18, scale: 0.58, text: 'die', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.72, y: 0.24, rotation: 0.08, scale: 0.64, text: 'das', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.46, y: 0.48, rotation: -0.52, scale: 0.54, text: 'DER', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.62, y: 0.14, rotation: 0.12, scale: 0.56, text: 'DIE', color: AppColors.duoRed),
          // Belgilar va emoji
          _PatternGlyph.text(x: 0.18, y: 0.12, rotation: 0.1, scale: 0.9, text: '?', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.48, y: 0.22, rotation: -0.3, scale: 0.85, text: '?', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.82, y: 0.72, rotation: 0.4, scale: 0.8, text: '?', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.32, y: 0.62, rotation: -0.15, scale: 0.75, text: '⭐', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.88, y: 0.48, rotation: 0.2, scale: 0.7, text: '⭐', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.14, y: 0.88, rotation: -0.25, scale: 0.65, text: '⭐', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.52, y: 0.62, rotation: 0.35, scale: 0.68, text: '📘', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.06, y: 0.52, rotation: -0.4, scale: 0.6, text: '📘', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.74, y: 0.88, rotation: 0.15, scale: 0.62, text: '📘', color: AppColors.duoBlue),
          _PatternGlyph.text(x: 0.42, y: 0.38, rotation: 0.0, scale: 0.72, text: '✓', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.64, y: 0.42, rotation: 0.5, scale: 0.65, text: '✓', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.24, y: 0.44, rotation: -0.45, scale: 0.6, text: '✗', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.58, y: 0.30, rotation: 0.25, scale: 0.58, text: '✗', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.92, y: 0.62, rotation: -0.1, scale: 0.55, text: 'DE', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.04, y: 0.24, rotation: 0.3, scale: 0.5, text: 'DE', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.36, y: 0.08, rotation: -0.2, scale: 0.48, text: 'abc', color: AppColors.duoTextLight),
          _PatternGlyph.text(x: 0.78, y: 0.08, rotation: 0.35, scale: 0.45, text: 'abc', color: AppColors.duoTextLight),
          // X va O shakllari
          _PatternGlyph.shapeX(x: 0.26, y: 0.18, rotation: 0.4, scale: 0.9, color: AppColors.duoRed),
          _PatternGlyph.shapeX(x: 0.70, y: 0.58, rotation: -0.2, scale: 0.75, color: AppColors.duoRed),
          _PatternGlyph.shapeX(x: 0.44, y: 0.92, rotation: 0.6, scale: 0.65, color: AppColors.duoRed),
          _PatternGlyph.shapeX(x: 0.96, y: 0.28, rotation: -0.5, scale: 0.55, color: AppColors.duoRed),
          _PatternGlyph.shapeO(x: 0.54, y: 0.52, rotation: 0.0, scale: 0.85, color: AppColors.duoBlue),
          _PatternGlyph.shapeO(x: 0.16, y: 0.36, rotation: 0.15, scale: 0.7, color: AppColors.duoBlue),
          _PatternGlyph.shapeO(x: 0.86, y: 0.14, rotation: -0.3, scale: 0.6, color: AppColors.duoBlue),
          _PatternGlyph.shapeO(x: 0.10, y: 0.78, rotation: 0.45, scale: 0.55, color: AppColors.duoGreen),
          _PatternGlyph.shapeO(x: 0.66, y: 0.34, rotation: -0.15, scale: 0.5, color: AppColors.duoGreen),
        ];
      case DecorativePatternVariant.synonymBattle:
        return const [
          // Sinonim so'zlar va belgilar
          _PatternGlyph.text(x: 0.06, y: 0.07, rotation: -0.35, scale: 1.0, text: '⚔️', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.84, y: 0.05, rotation: 0.25, scale: 0.95, text: 'SYN', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.12, y: 0.20, rotation: 0.15, scale: 0.78, text: '≈', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.90, y: 0.17, rotation: -0.2, scale: 1.08, text: '⚔️', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.03, y: 0.40, rotation: 0.42, scale: 0.88, text: '≈', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.94, y: 0.36, rotation: -0.48, scale: 0.82, text: 'SYN', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.20, y: 0.55, rotation: -0.12, scale: 0.72, text: '⚔️', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.76, y: 0.50, rotation: 0.32, scale: 0.98, text: '≈', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.08, y: 0.70, rotation: 0.22, scale: 1.02, text: 'SYN', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.68, y: 0.66, rotation: -0.28, scale: 0.84, text: '⚔️', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.38, y: 0.86, rotation: -0.38, scale: 0.92, text: '≈', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.56, y: 0.76, rotation: 0.18, scale: 0.76, text: 'SYN', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.50, y: 0.10, rotation: 0.55, scale: 0.62, text: '⚔️', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.28, y: 0.32, rotation: -0.18, scale: 0.58, text: '≈', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.72, y: 0.24, rotation: 0.08, scale: 0.64, text: 'SYN', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.46, y: 0.48, rotation: -0.52, scale: 0.54, text: '⚔️', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.62, y: 0.14, rotation: 0.12, scale: 0.56, text: '≈', color: AppColors.duoGreen),
          // Belgilar va emoji
          _PatternGlyph.text(x: 0.18, y: 0.12, rotation: 0.1, scale: 0.9, text: '?', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.48, y: 0.22, rotation: -0.3, scale: 0.85, text: '?', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.82, y: 0.72, rotation: 0.4, scale: 0.8, text: '?', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.32, y: 0.62, rotation: -0.15, scale: 0.75, text: '⭐', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.88, y: 0.48, rotation: 0.2, scale: 0.7, text: '⭐', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.14, y: 0.88, rotation: -0.25, scale: 0.65, text: '⭐', color: AppColors.duoOrange),
          _PatternGlyph.text(x: 0.52, y: 0.62, rotation: 0.35, scale: 0.68, text: '📘', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.06, y: 0.52, rotation: -0.4, scale: 0.6, text: '📘', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.74, y: 0.88, rotation: 0.15, scale: 0.62, text: '📘', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.42, y: 0.38, rotation: 0.0, scale: 0.72, text: '✓', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.64, y: 0.42, rotation: 0.5, scale: 0.65, text: '✓', color: AppColors.duoGreen),
          _PatternGlyph.text(x: 0.24, y: 0.44, rotation: -0.45, scale: 0.6, text: '✗', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.58, y: 0.30, rotation: 0.25, scale: 0.58, text: '✗', color: AppColors.duoRed),
          _PatternGlyph.text(x: 0.92, y: 0.62, rotation: -0.1, scale: 0.55, text: 'DE', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.04, y: 0.24, rotation: 0.3, scale: 0.5, text: 'DE', color: AppColors.duoPurple),
          _PatternGlyph.text(x: 0.36, y: 0.08, rotation: -0.2, scale: 0.48, text: 'abc', color: AppColors.duoTextLight),
          _PatternGlyph.text(x: 0.78, y: 0.08, rotation: 0.35, scale: 0.45, text: 'abc', color: AppColors.duoTextLight),
          // X va O shakllari
          _PatternGlyph.shapeX(x: 0.26, y: 0.18, rotation: 0.4, scale: 0.9, color: AppColors.duoRed),
          _PatternGlyph.shapeX(x: 0.70, y: 0.58, rotation: -0.2, scale: 0.75, color: AppColors.duoRed),
          _PatternGlyph.shapeX(x: 0.44, y: 0.92, rotation: 0.6, scale: 0.65, color: AppColors.duoRed),
          _PatternGlyph.shapeX(x: 0.96, y: 0.28, rotation: -0.5, scale: 0.55, color: AppColors.duoRed),
          _PatternGlyph.shapeO(x: 0.54, y: 0.52, rotation: 0.0, scale: 0.85, color: AppColors.duoPurple),
          _PatternGlyph.shapeO(x: 0.16, y: 0.36, rotation: 0.15, scale: 0.7, color: AppColors.duoPurple),
          _PatternGlyph.shapeO(x: 0.86, y: 0.14, rotation: -0.3, scale: 0.6, color: AppColors.duoPurple),
          _PatternGlyph.shapeO(x: 0.10, y: 0.78, rotation: 0.45, scale: 0.55, color: AppColors.duoGreen),
          _PatternGlyph.shapeO(x: 0.66, y: 0.34, rotation: -0.15, scale: 0.5, color: AppColors.duoGreen),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _DecorativePatternPainter(
            glyphs: _glyphsFor(variant),
            isDark: isDark,
          ),
        ),
        child,
      ],
    );
  }
}

class _DecorativePatternPainter extends CustomPainter {
  final List<_PatternGlyph> glyphs;
  final bool isDark;

  _DecorativePatternPainter({
    required this.glyphs,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textOpacity = isDark ? 0.16 : 0.10;
    final shapeOpacity = isDark ? 0.12 : 0.08;

    for (final g in glyphs) {
      canvas.save();
      final cx = g.x * size.width;
      final cy = g.y * size.height;
      canvas.translate(cx, cy);
      canvas.rotate(g.rotation);

      switch (g.kind) {
        case _GlyphKind.text:
          _paintText(canvas, g, size, textOpacity);
        case _GlyphKind.shapeX:
          _paintX(canvas, g, size, shapeOpacity);
        case _GlyphKind.shapeO:
          _paintO(canvas, g, size, shapeOpacity);
      }

      canvas.restore();
    }

    final dotPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.duoTextDark)
          .withValues(alpha: isDark ? 0.05 : 0.07);
    const dots = [
      Offset(0.30, 0.16),
      Offset(0.67, 0.14),
      Offset(0.43, 0.64),
      Offset(0.17, 0.46),
      Offset(0.77, 0.44),
      Offset(0.53, 0.90),
      Offset(0.22, 0.26),
      Offset(0.81, 0.80),
      Offset(0.05, 0.62),
      Offset(0.95, 0.52),
    ];
    for (final d in dots) {
      canvas.drawCircle(
        Offset(d.dx * size.width, d.dy * size.height),
        size.width * 0.011,
        dotPaint,
      );
    }
  }

  void _paintText(Canvas canvas, _PatternGlyph g, Size size, double opacity) {
    final baseSize = size.shortestSide * 0.11 * g.scale;
    final textPainter = TextPainter(
      text: TextSpan(
        text: g.text,
        style: TextStyle(
          fontSize: baseSize.clamp(12.0, 44.0),
          fontWeight: FontWeight.w900,
          color: g.color.withValues(alpha: opacity),
          letterSpacing: (g.text?.length ?? 0) <= 2 ? 0 : 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _paintX(Canvas canvas, _PatternGlyph g, Size size, double opacity) {
    final s = size.shortestSide * 0.06 * g.scale;
    final paint = Paint()
      ..color = g.color.withValues(alpha: opacity)
      ..strokeWidth = s * 0.22
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(-s, -s), Offset(s, s), paint);
    canvas.drawLine(Offset(s, -s), Offset(-s, s), paint);
  }

  void _paintO(Canvas canvas, _PatternGlyph g, Size size, double opacity) {
    final r = size.shortestSide * 0.035 * g.scale;
    final paint = Paint()
      ..color = g.color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.45;

    canvas.drawCircle(Offset.zero, r, paint);
  }

  @override
  bool shouldRepaint(covariant _DecorativePatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
