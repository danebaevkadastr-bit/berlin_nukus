import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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

class NoLessonsEmptyState extends StatelessWidget {
  final VoidCallback? onAction;

  const NoLessonsEmptyState({super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '📚',
      title: l.noLessonsYet,
      subtitle: l.noLessonsSubtitle,
      actionText: l.viewGames,
      onAction: onAction,
    );
  }
}

class NoHomeworkEmptyState extends StatelessWidget {
  const NoHomeworkEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '✅',
      title: l.allHomeworkDone,
      subtitle: l.allHomeworkDoneSubtitle,
    );
  }
}

class NoGamesEmptyState extends StatelessWidget {
  const NoGamesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '🎮',
      title: l.noGamesYet,
      subtitle: l.noGamesSubtitle,
    );
  }
}

class NoMessagesEmptyState extends StatelessWidget {
  const NoMessagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '💬',
      title: l.noMessagesTitle,
      subtitle: l.noMessagesSubtitle,
    );
  }
}

class NoGroupsEmptyState extends StatelessWidget {
  final VoidCallback? onAction;

  const NoGroupsEmptyState({super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '👥',
      title: l.noGroupsTitle,
      subtitle: l.noGroupsSubtitle,
      actionText: l.joinGroup,
      onAction: onAction,
    );
  }
}

class NoAchievementsEmptyState extends StatelessWidget {
  const NoAchievementsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '🏆',
      title: l.noAchievementsYet,
      subtitle: l.noAchievementsSubtitle,
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
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '😕',
      title: l.genericError,
      subtitle: message ?? l.failedToLoadData,
      actionText: l.retry,
      onAction: onRetry,
    );
  }
}

class NoInternetEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      emoji: '📡',
      title: l.noInternetTitle,
      subtitle: l.noInternetMessage,
      actionText: l.retry,
      onAction: onRetry,
    );
  }
}
