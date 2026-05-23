import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';
import 'lottie_animation.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? emoji;
  final String? lottieAsset;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji,
    this.lottieAsset,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              const EmptyStateAnimation(size: 200)
            else if (emoji != null)
              Text(
                emoji!,
                style: const TextStyle(fontSize: 80),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.duoTextLight,
                height: 1.5,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.duoBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined empty states for common use cases
class NoLessonsEmptyState extends StatelessWidget {
  final VoidCallback? onAction;

  const NoLessonsEmptyState({super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '📚',
      title: 'Hozircha darslar yo\'q',
      subtitle: 'Tez orada yangi darslar qo\'shiladi.\nKuting yoki qo\'shimcha mashq qiling!',
      actionText: 'O\'yinlarni ko\'rish',
      onAction: onAction,
    );
  }
}

class NoHomeworkEmptyState extends StatelessWidget {
  const NoHomeworkEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '✅',
      title: 'Barcha vazifalar tugatildi!',
      subtitle: 'Ajoyib! Siz barcha uyga vazifalarni bajardingiz.',
    );
  }
}

class NoGamesEmptyState extends StatelessWidget {
  const NoGamesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '🎮',
      title: 'O\'yinlar yo\'q',
      subtitle: 'Hozircha mavjud o\'yinlar yo\'q.\nTez orada yangilari qo\'shiladi.',
    );
  }
}

class NoMessagesEmptyState extends StatelessWidget {
  const NoMessagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '💬',
      title: 'Xabarlar yo\'q',
      subtitle: 'Suhbatni boshlash uchun biror narsa yozing.',
    );
  }
}

class NoGroupsEmptyState extends StatelessWidget {
  final VoidCallback? onAction;

  const NoGroupsEmptyState({super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '👥',
      title: 'Guruhlar yo\'q',
      subtitle: 'Siz hali hech qanday guruhga qo\'shilmagansiz.\nGuruhga qo\'shiling va darslarni boshlang!',
      actionText: 'Guruhga qo\'shilish',
      onAction: onAction,
    );
  }
}

class NoAchievementsEmptyState extends StatelessWidget {
  const NoAchievementsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '🏆',
      title: 'Yutuqlar yo\'q',
      subtitle: 'O\'yinlarda qatnashib yutuqlarni qo\'lga kiting!',
    );
  }
}

class ErrorEmptyState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorEmptyState({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '😕',
      title: 'Xatolik yuz berdi',
      subtitle: message ?? 'Ma\'lumotlarni yuklab bo\'lmadi.',
      actionText: 'Qayta urinish',
      onAction: onRetry,
    );
  }
}

class NoInternetEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '📡',
      title: 'Internet aloqasi yo\'q',
      subtitle: 'Internet aloqasini tekshiring va qayta urining.',
      actionText: 'Qayta urinish',
      onAction: onRetry,
    );
  }
}
