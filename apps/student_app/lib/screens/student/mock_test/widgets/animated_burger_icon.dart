import 'package:flutter/material.dart';

import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';

/// Animatsiyali burger menyu tugmasi.
///
/// [progress] qiymati `0` bo'lganda uchta gorizontal chiziq (hamburger) shaklida,
/// `1` bo'lganda esa "X" shaklida ko'rinadi. Oraliq qiymatlarda ikki shakl
/// orasida silliq animatsiya bilan o'tadi (`AnimatedIcons.menu_close`).
///
/// Animatsiya davomiyligini chaqiruvchi tomon ([progress] manbasini boshqaruvchi
/// `AnimationController`) belgilaydi — Requirement 3.4 bo'yicha ≤400 ms bo'lishi
/// kerak.
class AnimatedBurgerIcon extends StatelessWidget {
  const AnimatedBurgerIcon({
    super.key,
    required this.progress,
    required this.onTap,
    this.tooltip,
  });

  /// Burger → X o'tish progressi: `0` = uchta chiziq, `1` = "X".
  final Animation<double> progress;

  /// Tugma bosilganda chaqiriladigan callback (drawer'ni ochadi/yopadi).
  final VoidCallback onTap;

  /// Ixtiyoriy tooltip matni (lokalizatsiya qilingan bo'lishi mumkin).
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final iconColor = isDark ? Colors.white : AppColors.duoTextDark;

    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      splashRadius: 22,
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: progress,
        color: iconColor,
        size: 26,
      ),
    );
  }
}
