import 'package:flutter/material.dart';
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
                retryText ?? 'Qayta urinish',
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
    return ErrorCard(
      emoji: '📡',
      title: 'Internet aloqasi yo\'q',
      message: 'Internet aloqasini tekshiring va qayta urining.',
      onRetry: onRetry,
      retryText: 'Qayta urinish',
    );
  }
}

class ServerErrorCard extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorCard({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorCard(
      emoji: '🔧',
      title: 'Server xatosi',
      message: 'Serverda xatolik yuz berdi. Iltimos, keyinroq qayta urining.',
      onRetry: onRetry,
      retryText: 'Qayta urinish',
    );
  }
}

class TimeoutErrorCard extends StatelessWidget {
  final VoidCallback? onRetry;

  const TimeoutErrorCard({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorCard(
      emoji: '⏱️',
      title: 'Vaqt tugadi',
      message: 'So\'rov tugadi. Internet aloqasini tekshiring va qayta urining.',
      onRetry: onRetry,
      retryText: 'Qayta urinish',
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
    return ErrorCard(
      emoji: '😕',
      title: 'Xatolik yuz berdi',
      message: message ?? 'Noma\'lum xatolik yuz berdi.',
      onRetry: onRetry,
      retryText: 'Qayta urinish',
    );
  }
}

class NoDataErrorCard extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoDataErrorCard({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorCard(
      emoji: '📭',
      title: 'Ma\'lumot topilmadi',
      message: 'So\'ralgan ma\'lumotlar topilmadi.',
      onRetry: onRetry,
      retryText: 'Qayta urinish',
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
    return ErrorCard(
      emoji: '🔒',
      title: 'Ruxsat kerak',
      message: '$permission ruxsatini berishingiz kerak.',
      onRetry: onRetry,
      retryText: 'Ruxsat berish',
    );
  }
}
