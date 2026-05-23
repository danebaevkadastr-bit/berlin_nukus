import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';

class LinearProgressBar extends StatelessWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool animated;

  const LinearProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 8,
    this.borderRadius,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final bgColor = backgroundColor ?? 
        (isDark ? Colors.white12 : AppColors.duoCardGray);
    final progColor = progressColor ?? AppColors.duoBlue;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(
            height: height,
            color: bgColor,
          ),
          AnimatedContainer(
            duration: animated ? const Duration(milliseconds: 500) : Duration.zero,
            curve: Curves.easeInOut,
            width: (progress.clamp(0.0, 1.0)) * double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: progColor,
              borderRadius: borderRadius ?? BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressBar extends StatelessWidget {
  final double progress;
  final double size;
  final Color? backgroundColor;
  final Color? progressColor;
  final double strokeWidth;
  final bool animated;

  const CircularProgressBar({
    super.key,
    required this.progress,
    this.size = 60,
    this.backgroundColor,
    this.progressColor,
    this.strokeWidth = 6,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final bgColor = backgroundColor ?? 
        (isDark ? Colors.white12 : AppColors.duoCardGray);
    final progColor = progressColor ?? AppColors.duoBlue;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress.clamp(0.0, 1.0),
              backgroundColor: bgColor,
              progressColor: progColor,
              strokeWidth: strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      const startAngle = -90.0 * 3.14159 / 180.0;
      final sweepAngle = progress * 2 * 3.14159;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final active = activeColor ?? AppColors.duoBlue;
    final inactive = inactiveColor ?? 
        (isDark ? Colors.white12 : AppColors.duoCardGray);
    final completed = completedColor ?? AppColors.duoGreen;

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;
            final isLast = index == totalSteps - 1;

            return Row(
              children: [
                _buildStepDot(
                  isCompleted: isCompleted,
                  isActive: isActive,
                  activeColor: active,
                  inactiveColor: inactive,
                  completedColor: completed,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isCompleted ? completed : inactive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        if (stepLabels != null && stepLabels!.length == totalSteps)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index == currentStep;
                final isLast = index == totalSteps - 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: isLast ? 0 : 16,
                    ),
                    child: Text(
                      stepLabels![index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                        color: isActive ? active : inactive,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildStepDot({
    required bool isCompleted,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required Color completedColor,
  }) {
    final dotColor = isCompleted ? completedColor : (isActive ? activeColor : inactiveColor);
    final borderColor = isActive ? activeColor : inactiveColor;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              )
            : isActive
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  )
                : null,
      ),
    );
  }
}

class LessonProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback? onTap;

  const LessonProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.completedLessons,
    required this.totalLessons,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.duoCardGray.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                ),
                Text(
                  '$completedLessons/$totalLessons',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.duoBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressBar(
              progress: progress,
              height: 8,
              progressColor: AppColors.duoBlue,
            ),
          ],
        ),
      ),
    );
  }
}
