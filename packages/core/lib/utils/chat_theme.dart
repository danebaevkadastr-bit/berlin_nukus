import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'theme_manager.dart';

/// Sprechen AI chat UI colors — matches Berlin-Nukus gamified style.
class ChatTheme {
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentShadow;
  final Color userBubble;
  final Color hintBg;
  final Color hintBorder;
  final Color hintText;

  const ChatTheme({
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentShadow,
    required this.userBubble,
    required this.hintBg,
    required this.hintBorder,
    required this.hintText,
  });

  static ChatTheme of(BuildContext context) {
    final isDark = ThemeManager.isDark;
    return ChatTheme(
      background: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      surface: isDark ? const Color(0xFF1E2A32) : Colors.white,
      surfaceSoft: isDark
          ? AppColors.duoCardGray.withValues(alpha: 0.12)
          : const Color(0xFFF0F7FF),
      border: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
      textPrimary: isDark ? Colors.white : AppColors.duoTextDark,
      textSecondary: isDark ? Colors.white70 : AppColors.duoTextLight,
      accent: AppColors.duoBlue,
      accentShadow: AppColors.duoBlueShadow,
      userBubble: AppColors.duoBlue,
      hintBg: isDark
          ? AppColors.duoOrange.withValues(alpha: 0.15)
          : const Color(0xFFFFF8E7),
      hintBorder: isDark
          ? AppColors.duoOrange.withValues(alpha: 0.35)
          : const Color(0xFFFFE0A3),
      hintText: isDark ? const Color(0xFFFFE082) : const Color(0xFF6E5D2A),
    );
  }
}
