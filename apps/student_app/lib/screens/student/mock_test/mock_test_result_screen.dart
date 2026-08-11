// B1 Mock Test — result screen.
//
// Presents the end-of-attempt [MockResult]: per-Section points normalized to
// the official TELC Deutsch B1 maxima, the written-part and oral-part totals,
// and pass/fail badges for each part (60% Pass_Threshold, evaluated by the
// scorer). Any AI Section whose evaluation could not be completed is shown with
// an "evaluation unavailable" note while every other Section is still
// presented with its score.
//
// All app-authored interface text is routed through [AppLocalizations] (which
// delegates to the private `_t` fallback helper). The German exam section names
// (Leseverstehen, Sprachbausteine, Hörverstehen, Schriftlicher Ausdruck,
// Mündlicher Ausdruck) stay German regardless of the active locale, per the
// localization requirements (mirrors the runner via [mockSectionGermanName]).

import 'package:flutter/material.dart';

import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import 'model/mock_test_labels.dart' show mockSectionGermanName;
import 'model/mock_test_review.dart';
import 'model/mock_test_scorer.dart';
import 'model/mock_test_structure.dart';

/// Result summary for a completed B1 Mock Test attempt.
///
/// Renders two stacked sections:
///
/// 1. The score summary — the hero banner, the written / oral totals and the
///    per-Section point cards built from [result]. This block is preserved
///    exactly as it was before the redesign (Requirement 7.7).
/// 2. The per-question review built from [review]: every auto-graded Question
///    shows its German prompt, the student's selected option and the correct
///    option with a correct (green) / incorrect-or-unanswered (red) outcome,
///    while each AI Section shows its score and feedback or an "evaluation
///    unavailable" note (Requirements 7.1–7.6).
class MockTestResultScreen extends StatelessWidget {
  final MockResult result;
  final MockReview review;
  final String? schreibenAnswer;

  const MockTestResultScreen({
    super.key,
    required this.result,
    required this.review,
    this.schreibenAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, accent, _) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              l.mockResultTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero banner with the overall total.
                _buildHero(isDark: isDark, accent: accent, l: l),

                const SizedBox(height: 16),

                // Overall verdict + TELC grade (Note).
                _buildVerdictCard(isDark: isDark, l: l),

                const SizedBox(height: 28),

                // Written / oral part totals with pass/fail badges.
                _buildPartCard(
                  isDark: isDark,
                  label: l.mockResultWrittenLabel,
                  points: result.writtenPoints,
                  max: result.writtenMax,
                  passed: result.writtenPassed,
                  pointsSuffix: l.mockTestPointsSuffix,
                  passedLabel: l.mockResultPassed,
                  failedLabel: l.mockResultFailed,
                ),
                const SizedBox(height: 12),
                _buildPartCard(
                  isDark: isDark,
                  label: l.mockResultOralLabel,
                  points: result.oralPoints,
                  max: result.oralMax,
                  passed: result.oralPassed,
                  pointsSuffix: l.mockTestPointsSuffix,
                  passedLabel: l.mockResultPassed,
                  failedLabel: l.mockResultFailed,
                ),

                const SizedBox(height: 28),

                Text(
                  l.mockResultSectionsTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),

                // One card per Section, in official order.
                for (final section in MockTestStructure.sectionOrder) ...[
                  _buildSectionCard(
                    isDark: isDark,
                    accent: accent,
                    name: mockSectionGermanName(section),
                    max: MockTestStructure.sectionMaxPoints[section] ?? 0,
                    points: result.sectionPoints[section],
                    unavailable: result.unavailableSections.contains(section),
                    pointsSuffix: l.mockTestPointsSuffix,
                    unavailableLabel: l.mockResultUnavailable,
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 16),

                // ── Question_Review (Requirements 7.1–7.6) ──────────────────
                Text(
                  l.mockReviewTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Per-Teil auto-graded review: every Question shows the
                // selected/correct option and its outcome (R7.1–7.4).
                for (final teil in review.autoGraded) ...[
                  _buildTeilReviewCard(isDark: isDark, l: l, teil: teil),
                  const SizedBox(height: 12),
                ],

                // AI Section review: score + feedback, or the "evaluation
                // unavailable" note (R7.5, R7.6).
                for (final ai in review.aiSections) ...[
                  _buildAiSectionCard(isDark: isDark, l: l, ai: ai),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 16),

                // Done button — leaves the attempt and returns to the entry.
                SizedBox(
                  width: double.infinity,
                  child: GamifiedCard(
                    color: accent.color,
                    shadowColor: accent.shadow,
                    shadowDepth: 5,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onTap: () =>
                        Navigator.of(context).popUntil((route) => route.isFirst),
                    child: Center(
                      child: Text(
                        l.mockResultDoneButton.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero({
    required bool isDark,
    required AccentPreset accent,
    required AppLocalizations l,
  }) {
    final total = result.writtenPoints + result.oralPoints;
    return GamifiedCard(
      color: accent.color,
      shadowColor: accent.shadow,
      shadowDepth: 6,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, size: 44, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total / ${MockTestStructure.totalPoints} '
                  '${l.mockTestPointsSuffix}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.mockResultSubtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The overall verdict card: whether the whole exam is passed (both parts at
  /// 60%) and the official TELC B1 grade (Note). Also states the pass rule.
  Widget _buildVerdictCard({
    required bool isDark,
    required AppLocalizations l,
  }) {
    final passed = result.passed;
    final verdictColor = passed ? AppColors.duoGreen : AppColors.duoRed;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed
                    ? Icons.verified_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                size: 26,
                color: verdictColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  passed
                      ? l.mockResultOverallPassed
                      : l.mockResultOverallFailed,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: verdictColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grade (Note) row — German exam term.
          Row(
            children: [
              Text(
                '${l.mockResultGradeLabel}: ',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: verdictColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _gradeName(result.grade),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: verdictColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // The 60%-in-each-part rule, so the verdict is understandable.
          Text(
            l.mockResultPassRule,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
        ],
      ),
    );
  }

  /// The German TELC B1 grade term for [grade] (exam terminology — stays
  /// German regardless of the active locale).
  String _gradeName(MockGrade grade) {
    switch (grade) {
      case MockGrade.sehrGut:
        return 'sehr gut';
      case MockGrade.gut:
        return 'gut';
      case MockGrade.befriedigend:
        return 'befriedigend';
      case MockGrade.ausreichend:
        return 'ausreichend';
      case MockGrade.nichtBestanden:
        return 'nicht bestanden';
    }
  }

  /// A written-/oral-part total card with a pass/fail badge.
  Widget _buildPartCard({
    required bool isDark,
    required String label,
    required int points,
    required int max,
    required bool passed,
    required String pointsSuffix,
    required String passedLabel,
    required String failedLabel,
  }) {
    final badgeColor = passed ? AppColors.duoGreen : AppColors.duoRed;
    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$points / $max $pointsSuffix',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white60 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Badge(
            label: passed ? passedLabel : failedLabel,
            icon: passed
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: badgeColor,
          ),
        ],
      ),
    );
  }

  /// A per-Section card. When [unavailable] is true the points are replaced by
  /// the "evaluation unavailable" note; otherwise the normalized points out of
  /// the Section maximum are shown.
  Widget _buildSectionCard({
    required bool isDark,
    required AccentPreset accent,
    required String name,
    required int max,
    required int? points,
    required bool unavailable,
    required String pointsSuffix,
    required String unavailableLabel,
  }) {
    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (unavailable)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 15,
                    color: AppColors.duoOrange,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      unavailableLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.duoOrange,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${points ?? 0} / $max $pointsSuffix',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: accent.color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A review card for one auto-graded Teil: the German Section · Teil heading
  /// followed by one row per Question showing the selected and correct options
  /// with a colored outcome chip (Requirements 7.1, 7.2, 7.3, 7.4).
  Widget _buildTeilReviewCard({
    required bool isDark,
    required AppLocalizations l,
    required TeilReview teil,
  }) {
    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${mockSectionGermanName(teil.section)} · Teil ${teil.teilNumber}',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < teil.questions.length; i++) ...[
            if (i > 0)
              Divider(
                height: 20,
                thickness: 1,
                color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              ),
            _buildQuestionReviewRow(
              isDark: isDark,
              l: l,
              number: i + 1,
              question: teil.questions[i],
            ),
          ],
        ],
      ),
    );
  }

  /// A single Question review row: the German prompt, the student's answer, the
  /// correct answer, and a green/red outcome chip. An unanswered Question shows
  /// the localized "not answered" label and is colored red (Requirement 7.2).
  Widget _buildQuestionReviewRow({
    required bool isDark,
    required AppLocalizations l,
    required int number,
    required QuestionReview question,
  }) {
    final isCorrect = question.outcome == QuestionOutcome.correct;
    final outcomeColor = isCorrect ? AppColors.duoGreen : AppColors.duoRed;
    final isUnanswered = question.outcome == QuestionOutcome.unanswered;
    final yourAnswer =
        isUnanswered ? l.mockReviewUnanswered : (question.selectedOption ?? '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 18,
          color: outcomeColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // German exam prompt — never localized (Requirement 11.2).
              Text(
                '$number. ${question.prompt}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 6),
              _buildAnswerLine(
                isDark: isDark,
                label: l.mockReviewYourAnswer,
                value: yourAnswer,
                valueColor: outcomeColor,
                italicWhenEmpty: isUnanswered,
              ),
              const SizedBox(height: 2),
              _buildAnswerLine(
                isDark: isDark,
                label: l.mockReviewCorrectAnswer,
                value: question.correctOption,
                valueColor: AppColors.duoGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A "label: value" line used for the student's and the correct answer.
  Widget _buildAnswerLine({
    required bool isDark,
    required String label,
    required String value,
    required Color valueColor,
    bool italicWhenEmpty = false,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white60 : AppColors.duoTextLight,
        ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: valueColor,
              fontStyle: italicWhenEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// A review card for one AI-evaluated Section (Schriftlicher / Mündlicher
  /// Ausdruck). When the evaluation is available it shows the score and
  /// feedback; otherwise it shows the localized "evaluation unavailable" note
  /// without blocking the other Sections (Requirements 7.5, 7.6).
  Widget _buildAiSectionCard({
    required bool isDark,
    required AppLocalizations l,
    required AiSectionReview ai,
  }) {
    final isSchreiben = ai.section == MockSection.schriftlicherAusdruck;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mockSectionGermanName(ai.section),
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
              ),
              if (ai.available && ai.score != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.duoGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ai.score!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.duoGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // O'quvchi yozgan javob (Schreiben uchun)
          if (isSchreiben && schreibenAnswer != null && schreibenAnswer!.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.duoBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.yourAnswer,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    schreibenAnswer!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (!ai.available)
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: AppColors.duoOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.mockResultUnavailable,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.duoOrange,
                    ),
                  ),
                ),
              ],
            )
          else if (ai.feedback != null && ai.feedback!.isNotEmpty)
            Text(
              ai.feedback!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: isDark ? Colors.white70 : AppColors.duoTextLight,
              ),
            ),
        ],
      ),
    );
  }
}

/// A small pass/fail pill badge.
class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
