import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';

/// Interaktiv, vizual loading widget — zerikishli doira o'rniga.
/// Rangli to'plar sakraydi + tipslar almashadi.
class FunLoading extends StatefulWidget {
  /// Sarlavha matni (masalan: "Grammatika — B1").
  final String? title;

  /// Tips ro'yxati — har 2 sekundda almashadi.
  final List<String> tips;

  /// Asosiy rang (to'plar rangi). Berilmasa default 4 rang ishlatiladi.
  final Color? color;

  const FunLoading({
    super.key,
    this.title,
    this.tips = const [],
    this.color,
  });

  /// O'yinlar uchun default tips.
  static const gameTips = [
    'AI savollar tayyorlayapti...',
    'Qiziqarli savollar tanlanmoqda 🎯',
    'Grammatikani o\'ynab o\'rganamiz!',
    'Har kuni mashq — katta natija!',
    'Biroz sabr — zo\'r narsa keladi!',
  ];

  @override
  State<FunLoading> createState() => _FunLoadingState();
}

class _FunLoadingState extends State<FunLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _tipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    if (widget.tips.isNotEmpty) {
      _tipTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (mounted) {
          setState(() => _tipIndex = (_tipIndex + 1) % widget.tips.length);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated bouncing dots
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final delay = i * 0.2;
                  final t = ((_controller.value + delay) % 1.0);
                  final y = -14 * math.sin(t * math.pi);
                  final colors = widget.color != null
                      ? [widget.color!, widget.color!.withValues(alpha: 0.8),
                         widget.color!.withValues(alpha: 0.6), widget.color!.withValues(alpha: 0.4)]
                      : [AppColors.duoGreen, AppColors.duoBlue,
                         AppColors.duoOrange, AppColors.duoRed];
                  return Transform.translate(
                    offset: Offset(0, y),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors[i].withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          if (widget.title != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
          ],
          if (widget.tips.isNotEmpty) ...[
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Padding(
                key: ValueKey<int>(_tipIndex),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.tips[_tipIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppColors.duoTextLight,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
