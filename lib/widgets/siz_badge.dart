import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';

/// SIZ belgisi - joriy foydalanuvchini ko'rsatuvchi yaxshilangan belgi
/// 
/// Gradient fon (duoBlue → duoPurple), yumshoq soya effekti va
/// pulsatsiya animatsiyasi bilan foydalanuvchini boshqalardan ajratib ko'rsatadi.
/// Dark va light temalarda to'g'ri ko'rinish uchun soya parametrlari moslashtirilgan.
/// 
/// Requirements: 5.1, 5.2, 5.3, 5.4, 5.5
class SizBadge extends StatefulWidget {
  /// Pulsatsiya animatsiyasini yoqish/o'chirish
  final bool animate;

  const SizBadge({
    super.key,
    this.animate = true,
  });

  @override
  State<SizBadge> createState() => _SizBadgeState();
}

class _SizBadgeState extends State<SizBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    // AnimationController: 2000ms davomiylik
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animatsiyasi: 1.0 → 1.1 → 1.0 (Curves.easeInOut)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    // Animatsiyani boshlash (agar animate = true bo'lsa)
    if (widget.animate) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(SizBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // animate parametri o'zgarganda animatsiyani boshqarish
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    
    // Dark temada soya ko'proq ko'rinadi (glow effekti), light temada kamroq
    final shadowOpacity = isDark ? 0.6 : 0.4;
    final shadowSpreadRadius = isDark ? 3.0 : 2.0;
    final shadowBlurRadius = isDark ? 10.0 : 8.0;
    
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.duoBlue, AppColors.duoPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.duoBlue.withValues(alpha: shadowOpacity),
            blurRadius: shadowBlurRadius,
            spreadRadius: shadowSpreadRadius,
          ),
        ],
      ),
      child: const Text(
        'SIZ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );

    // Animatsiya yoqilgan bo'lsa ScaleTransition ishlatish
    if (widget.animate) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: badge,
      );
    }

    return badge;
  }
}
