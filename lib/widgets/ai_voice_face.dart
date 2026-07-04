import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ovozli AI botning holati (gapirish/tinglash jarayoni).
enum AiFaceState {
  /// Bo'sh turibdi (kutmoqda).
  idle,

  /// Foydalanuvchini tinglamoqda — yengil puls.
  listening,

  /// O'ylamoqda (javob tayyorlamoqda).
  thinking,

  /// Gapirmoqda — og'iz qimirlaydi.
  speaking,
}

/// Botning his-tuyg'usi (yuz ifodasi).
enum AiFaceEmotion {
  neutral,
  happy,
  laughing,
  angry,
  sad,
  surprised,
  sneezing, // aksirish (Hatschi!)
  coughing, // yo'talish (Hust!)
}

/// ielts.gg / Pingo uslubidagi jonli AI "yuzi": pirpiraydigan ko'zlar,
/// gapirganda qimirlaydigan og'iz va turli his-tuyg'ular (xursand, kuladi,
/// jahli chiqqan, xafa, hayron). Jahl chiqqanda yuz qizaradi va ko'zlar
/// qiyshiq/kichik bo'ladi.
class AiVoiceFace extends StatefulWidget {
  final AiFaceState state;
  final AiFaceEmotion emotion;
  final double size;
  final Color color;
  final double? level;

  const AiVoiceFace({
    super.key,
    required this.state,
    this.emotion = AiFaceEmotion.neutral,
    this.size = 220,
    this.color = const Color(0xFF2F6BFF),
    this.level,
  });

  @override
  State<AiVoiceFace> createState() => _AiVoiceFaceState();
}

class _AiVoiceFaceState extends State<AiVoiceFace>
    with TickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );
  late final AnimationController _talk = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..repeat(reverse: true);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);
  // Emotsiya o'zgarishini silliq qilish uchun.
  late final AnimationController _emo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: 1,
  );

  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(covariant AiVoiceFace old) {
    super.didUpdateWidget(old);
    if (old.emotion != widget.emotion) {
      _emo.forward(from: 0);
    }
  }

  void _scheduleBlink() {
    final ms = 2000 + _rnd.nextInt(3000);
    Future.delayed(Duration(milliseconds: ms), () async {
      if (!mounted) return;
      // Kulish/aksirishda ko'zlar allaqachon yumuq — pirpirash shart emas.
      if (widget.emotion != AiFaceEmotion.laughing &&
          widget.emotion != AiFaceEmotion.sneezing) {
        await _blink.forward();
        await _blink.reverse();
      }
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _blink.dispose();
    _talk.dispose();
    _pulse.dispose();
    _emo.dispose();
    super.dispose();
  }

  Color _emotionColor() {
    switch (widget.emotion) {
      case AiFaceEmotion.angry:
        return const Color(0xFFE23B3B);
      case AiFaceEmotion.sad:
        return const Color(0xFF5B7BB0);
      case AiFaceEmotion.sneezing:
        return const Color(0xFFEB6B6B); // yumshoq qizil
      case AiFaceEmotion.coughing:
        return const Color(0xFF7C8AA6); // kulrang-ko'k
      case AiFaceEmotion.happy:
      case AiFaceEmotion.laughing:
      case AiFaceEmotion.surprised:
      case AiFaceEmotion.neutral:
        return widget.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blink, _talk, _pulse, _emo]),
      builder: (context, _) {
        var eyeOpen = 1.0 - _blink.value * 0.92;
        if (widget.state == AiFaceState.thinking) eyeOpen *= 0.6;
        // Jahl chiqqanda ko'zlar biroz kichrayadi.
        if (widget.emotion == AiFaceEmotion.angry) eyeOpen *= 0.8;
        // Yo'talganda ko'zlar yarim yumuq.
        if (widget.emotion == AiFaceEmotion.coughing) eyeOpen *= 0.5;

        double mouthOpen;
        if (widget.state == AiFaceState.speaking) {
          mouthOpen = widget.level != null
              ? widget.level!.clamp(0.0, 1.0)
              : (0.25 + _talk.value * 0.75);
        } else {
          mouthOpen = 0.0;
        }

        final scale = widget.state == AiFaceState.listening
            ? 1.0 + _pulse.value * 0.04
            : 1.0;
        // Jahl/aksirish/yo'tal holatida yengil "titrash/kattalashish".
        final shakeEmo = widget.emotion == AiFaceEmotion.angry ||
            widget.emotion == AiFaceEmotion.sneezing ||
            widget.emotion == AiFaceEmotion.coughing;
        // Aksirish — kuchli "silkinish" (achoo!).
        final shakeAmp =
            widget.emotion == AiFaceEmotion.sneezing ? 0.12 : 0.06;
        final emoScale = shakeEmo ? 1.0 + (1 - _emo.value) * shakeAmp : 1.0;

        return Transform.scale(
          scale: scale * emoScale,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _FacePainter(
              color: _emotionColor(),
              emotion: widget.emotion,
              eyeOpen: eyeOpen.clamp(0.05, 1.0),
              mouthOpen: mouthOpen,
              speaking: widget.state == AiFaceState.speaking,
              glow: widget.state == AiFaceState.listening
                  ? _pulse.value
                  : (widget.state == AiFaceState.speaking ? 0.6 : 0.3),
            ),
          ),
        );
      },
    );
  }
}

class _FacePainter extends CustomPainter {
  final Color color;
  final AiFaceEmotion emotion;
  final double eyeOpen;
  final double mouthOpen;
  final bool speaking;
  final double glow;

  _FacePainter({
    required this.color,
    required this.emotion,
    required this.eyeOpen,
    required this.mouthOpen,
    required this.speaking,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Porlash.
    canvas.drawCircle(
      c,
      r * 0.98,
      Paint()
        ..color = color.withValues(alpha: 0.25 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    // Yuz doirasi.
    canvas.drawCircle(
      c,
      r * 0.92,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.12)!,
            color,
            Color.lerp(color, Colors.black, 0.12)!,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final white = Paint()..color = Colors.white.withValues(alpha: 0.95);

    final eyeY = c.dy - r * 0.12;
    final eyeDx = r * 0.34;
    _drawEye(canvas, Offset(c.dx - eyeDx, eyeY), true, r, white);
    _drawEye(canvas, Offset(c.dx + eyeDx, eyeY), false, r, white);

    _drawMouth(canvas, c, r, white);
  }

  void _drawEye(Canvas canvas, Offset center, bool isLeft, double r, Paint p) {
    final w = r * 0.26;
    final h = r * 0.42 * eyeOpen;

    switch (emotion) {
      case AiFaceEmotion.laughing:
        // Kuladigan ko'zlar — yuqoriga qarab egilgan yoy (∩).
        final stroke = Paint()
          ..color = p.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.09
          ..strokeCap = StrokeCap.round;
        final rect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.04),
          width: w * 1.3,
          height: h * 1.1,
        );
        canvas.drawArc(rect, math.pi, math.pi, false, stroke);
        return;

      case AiFaceEmotion.angry:
        // Jahl — qiyshiq, ichki tomoni yuqoriroq o'tkir ko'z.
        final hw = w * 0.62;
        final hh = (r * 0.34 * eyeOpen);
        final innerSign = isLeft ? 1.0 : -1.0; // ichki tomon markazga
        final path = Path();
        final outerX = center.dx - innerSign * hw;
        final innerX = center.dx + innerSign * hw;
        path.moveTo(outerX, center.dy + hh * 0.15); // tashqi-yuqori (pastroq)
        path.lineTo(innerX, center.dy - hh * 0.7); // ichki-yuqori (baland, o'tkir)
        path.lineTo(innerX, center.dy + hh * 0.25);
        path.quadraticBezierTo(
          center.dx,
          center.dy + hh * 0.9,
          outerX,
          center.dy + hh * 0.15,
        );
        path.close();
        canvas.drawPath(path, p);
        return;

      case AiFaceEmotion.sad:
        // Xafa — ichki tomoni yuqoriroq (osilgan) oddiy ko'z, biroz burilgan.
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate((isLeft ? -1 : 1) * 0.28);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: w,
          height: math.max(h, w * 0.2),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(w)),
          p,
        );
        canvas.restore();
        return;

      case AiFaceEmotion.surprised:
        // Hayron — kattaroq dumaloq ko'zlar.
        canvas.drawCircle(center, w * 0.72, p);
        return;

      case AiFaceEmotion.sneezing:
        // Aksirish — ko'zlar mahkam yumilgan (kuchli qisilgan "^" yoy).
        final stroke = Paint()
          ..color = p.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.10
          ..strokeCap = StrokeCap.round;
        final rect = Rect.fromCenter(
          center: Offset(center.dx, center.dy - r * 0.02),
          width: w * 1.2,
          height: r * 0.22,
        );
        // Pastga egilgan yoy (>‿< qisilgan ko'z).
        canvas.drawArc(rect, math.pi + 0.3, math.pi - 0.6, false, stroke);
        return;

      case AiFaceEmotion.coughing:
      case AiFaceEmotion.happy:
      case AiFaceEmotion.neutral:
        final rect = Rect.fromCenter(
          center: center,
          width: w,
          height: math.max(h, w * 0.18),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(w)),
          p,
        );
        return;
    }
  }

  void _drawMouth(Canvas canvas, Offset c, double r, Paint p) {
    final mouthY = c.dy + r * 0.34;
    final mouthW = r * 0.5;

    // Gapirganda og'iz ochiladi (his-tuyg'udan qat'i nazar).
    if (speaking && mouthOpen >= 0.06) {
      final h = r * (0.10 + 0.34 * mouthOpen);
      final rect = Rect.fromCenter(center: Offset(c.dx, mouthY), width: mouthW, height: h);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(mouthW * 0.5)), p);
      return;
    }

    switch (emotion) {
      case AiFaceEmotion.laughing:
        // Katta ochiq tabassum (kulgi).
        final rect = Rect.fromCenter(
          center: Offset(c.dx, mouthY - r * 0.02),
          width: mouthW * 1.15,
          height: r * 0.42,
        );
        final path = Path()..addArc(rect, 0.05, math.pi - 0.1);
        path.close();
        canvas.drawPath(path, p);
        return;

      case AiFaceEmotion.happy:
        final rect = Rect.fromCenter(
          center: Offset(c.dx, mouthY - r * 0.06),
          width: mouthW * 1.1,
          height: r * 0.4,
        );
        canvas.drawPath(Path()..addArc(rect, 0.1, math.pi - 0.2), p);
        return;

      case AiFaceEmotion.angry:
        // Kichik, tekis og'iz.
        final rect = Rect.fromCenter(
          center: Offset(c.dx, mouthY + r * 0.02),
          width: mouthW * 0.55,
          height: r * 0.09,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.05)), p);
        return;

      case AiFaceEmotion.sad:
        // Qayg'uli — yuqoriga qaragan yoy (burilgan).
        final stroke = Paint()
          ..color = p.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.07
          ..strokeCap = StrokeCap.round;
        final rect = Rect.fromCenter(
          center: Offset(c.dx, mouthY + r * 0.08),
          width: mouthW * 0.9,
          height: r * 0.3,
        );
        canvas.drawArc(rect, math.pi, math.pi, false, stroke);
        return;

      case AiFaceEmotion.surprised:
        // Kichik "o".
        canvas.drawCircle(Offset(c.dx, mouthY), r * 0.11, p);
        return;

      case AiFaceEmotion.sneezing:
        // Aksirish — katta ochiq og'iz (Hatschi!).
        final rect = Rect.fromCenter(
          center: Offset(c.dx, mouthY + r * 0.02),
          width: mouthW * 0.75,
          height: r * 0.5,
        );
        canvas.drawOval(rect, p);
        return;

      case AiFaceEmotion.coughing:
        // Yo'tal — kichik-o'rta ochiq og'iz.
        final rect = Rect.fromCenter(
          center: Offset(c.dx, mouthY),
          width: mouthW * 0.42,
          height: r * 0.22,
        );
        canvas.drawOval(rect, p);
        return;

      case AiFaceEmotion.neutral:
        final rect = Rect.fromCenter(
          center: Offset(c.dx, mouthY - r * 0.06),
          width: mouthW,
          height: r * 0.34,
        );
        canvas.drawPath(Path()..addArc(rect, 0.15, math.pi - 0.3), p);
        return;
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) =>
      old.eyeOpen != eyeOpen ||
      old.mouthOpen != mouthOpen ||
      old.emotion != emotion ||
      old.speaking != speaking ||
      old.glow != glow ||
      old.color != color;
}
