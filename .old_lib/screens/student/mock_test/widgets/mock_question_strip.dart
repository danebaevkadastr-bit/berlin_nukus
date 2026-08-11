// B1 Mock Test — horizontal question navigation strip.
//
// Renders the questions of the active Teil as a horizontally scrollable row of
// circular indicators (Requirement 4.1). Tapping an indicator activates that
// question (Requirement 4.2), and answered vs unanswered questions are
// visually distinguished (Requirement 4.4).
//
// The visuals generalize `horen_mock_view._buildQuestionButton`: the active
// question uses the current `ThemeManager` accent (Requirement 1.3), answered
// questions use a green-filled pill, and unanswered questions use a neutral
// surface that adapts to dark mode (Requirements 1.1, 1.2, 8.7).
//
// This widget is purely presentational: it owns no question state and only
// reports selections through [onSelect]. The runner / section views remain the
// source of truth for the active index and answered status.

import 'package:flutter/material.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/theme_manager.dart';

/// A horizontal, scrollable strip of question indicators for one Teil.
///
/// * [count] — number of questions in the active Teil.
/// * [activeIndex] — currently focused question index.
/// * [isAnswered] — returns whether the question at a given index has an answer.
/// * [onSelect] — invoked with the tapped question index.
class MockQuestionStrip extends StatelessWidget {
  final int count;
  final int activeIndex;
  final bool Function(int index) isAnswered;
  final void Function(int index) onSelect;

  const MockQuestionStrip({
    super.key,
    required this.count,
    required this.activeIndex,
    required this.isAnswered,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: count,
        itemBuilder: (context, i) => _buildIndicator(i, isDark),
      ),
    );
  }

  Widget _buildIndicator(int index, bool isDark) {
    final accent = ThemeManager.accent;
    final accentShadow = ThemeManager.accentShadow;
    final bool selected = index == activeIndex;
    final bool answered = isAnswered(index);

    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (selected) {
      // Active question — accent filled (Requirement 1.3).
      bgColor = accent;
      borderColor = accentShadow;
      textColor = Colors.white;
    } else if (answered) {
      // Answered question — green pill (Requirement 4.4).
      bgColor = AppColors.duoGreen.withValues(alpha: 0.2);
      borderColor = AppColors.duoGreen;
      textColor = AppColors.duoGreen;
    } else {
      // Unanswered question — neutral surface, dark-mode aware (Req 1.2, 4.4).
      bgColor =
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.2) : Colors.white;
      borderColor = isDark ? Colors.white24 : AppColors.duoCardGrayShadow;
      textColor = isDark ? Colors.white70 : AppColors.duoTextDark;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelect(index),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: selected
                ? [BoxShadow(color: accentShadow, offset: const Offset(0, 3))]
                : null,
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              // Small answered marker on unselected, answered indicators so the
              // distinction stays clear even at a glance (Requirement 4.4).
              if (answered && !selected)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.duoGreen,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
