import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';
import 'animated_button.dart';

class ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final String? emoji;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showIllustration;

  const ErrorCard({
    super.key,
    required this.title,
    required this.message,
    this.emoji,
    this.onRetry,
    this.retryText,
    this.showIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.duoCardGray.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIllustration)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.duoRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji ?? '😕',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          if (showIllustration) const SizedBox(height: 20),
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
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.duoTextLight,
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            AnimatedButton(
              onPressed: onRetry,
              backgroundColor: AppColors.duoBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              borderRadius: BorderRadius.circular(12),
              child: Text(
                retryText ?? l.retry,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NetworkErrorCard extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorCard({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ErrorCard(
      emoji: '📡',
      title: l.noInternetTitle,
      message: l.noInternetMessage,
      onRetry: onRetry,
      retryText: l.retry,
    );
  }
}

class ServerErrorCard extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorCard({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ErrorCard(
      emoji: '🔧',
      title: l.serverErrorTitle,
      message: l.serverErrorMessage,
      onRetry: onRetry,
      retryText: l.retry,
    );
  }
}

class TimeoutErrorCard extends StatelessWidget {
  final VoidCallback? onRetry;

  const TimeoutErrorCard({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ErrorCard(
      emoji: '⏱️',
      title: l.timeoutTitle,
      message: l.timeoutMessage,
      onRetry: onRetry,
      retryText: l.retry,
    );
  }
}

class GenericErrorCard extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const GenericErrorCard({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ErrorCard(
      emoji: '😕',
      title: l.genericError,
      message: message ?? l.unknownErrorMessage,
      onRetry: onRetry,
      retryText: l.retry,
    );
  }
}

class NoDataErrorCard extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoDataErrorCard({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ErrorCard(
      emoji: '📭',
      title: l.dataNotFoundTitle,
      message: l.dataNotFoundMessage,
      onRetry: onRetry,
      retryText: l.retry,
    );
  }
}

class PermissionErrorCard extends StatelessWidget {
  final String permission;
  final VoidCallback? onRetry;

  const PermissionErrorCard({
    super.key,
    required this.permission,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ErrorCard(
      emoji: '🔒',
      title: l.permissionRequiredTitle,
      message: l.permissionRequiredMessage(permission),
      onRetry: onRetry,
      retryText: l.grantPermission,
    );
  }
}
