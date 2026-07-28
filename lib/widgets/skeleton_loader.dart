import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsets? padding;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      constraints: BoxConstraints(minHeight: height),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeManager.isDark 
            ? AppColors.duoCardGray.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeManager.isDark 
              ? Colors.white12 
              : AppColors.duoCardGrayShadow,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            width: double.infinity,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 150,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class SkeletonGameCard extends StatelessWidget {
  const SkeletonGameCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: ThemeManager.isDark 
            ? AppColors.duoCardGray.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeManager.isDark 
              ? Colors.white12 
              : AppColors.duoCardGrayShadow,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SkeletonLoader(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class SkeletonLessonCard extends StatelessWidget {
  const SkeletonLessonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.duoBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: double.infinity,
                      height: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoader(
                      width: 100,
                      height: 13,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 30,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 30,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 30,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonStatItem extends StatelessWidget {
  const SkeletonStatItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeManager.isDark 
            ? Colors.white12 
            : AppColors.duoBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SkeletonLoader(
            width: 32,
            height: 32,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 60,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          SkeletonLoader(
            width: 40,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class SkeletonLeaderboardItem extends StatelessWidget {
  const SkeletonLeaderboardItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeManager.isDark 
            ? Colors.white12 
            : AppColors.duoBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(width: 12),
          SkeletonLoader(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SkeletonLoader(
            width: 50,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class SkeletonChatMessage extends StatelessWidget {
  final bool isUser;

  const SkeletonChatMessage({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            SkeletonLoader(
              width: 36,
              height: 36,
              borderRadius: BorderRadius.circular(18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: isUser ? 200 : 250,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 6),
                SkeletonLoader(
                  width: isUser ? 150 : 200,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 6),
                SkeletonLoader(
                  width: isUser ? 100 : 180,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            SkeletonLoader(
              width: 36,
              height: 36,
              borderRadius: BorderRadius.circular(18),
            ),
          ],
        ],
      ),
    );
  }
}
