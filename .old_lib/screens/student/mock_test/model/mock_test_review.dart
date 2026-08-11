// B1 Mock Test — pure review models for the result screen.
//
// These models describe the per-question review shown after an attempt is
// finished. They are derived (read-only) from the assembled
// [MockTestAttempt], the recorded answers, and the AI evaluations — the
// derivation itself lives on the `MockTestReview` controller extension. Nothing
// here mutates domain-core state (Requirement 10.2).
//
// The models carry no UI or I/O logic; every field is `final` and every list is
// wrapped with `List.unmodifiable`, so a built review is frozen. The German
// exam content (prompts, options) is preserved verbatim and never localized
// (Requirement 11.2).

import 'package:flutter/foundation.dart';

import 'mock_test_scorer.dart' show MockResult;
import 'mock_test_structure.dart' show MockSection;

/// The graded outcome of a single auto-graded Question.
///
/// - [correct]: the student selected the Question's `correctAnswer`.
/// - [incorrect]: the student selected a different option.
/// - [unanswered]: the student left the Question blank (treated as incorrect
///   for scoring, but surfaced distinctly in the review — Requirement 7.2).
enum QuestionOutcome { correct, incorrect, unanswered }

/// Derives a [QuestionOutcome] from the student's [selected] option and the
/// Question's [correctAnswer].
///
/// Pure and total: `null` [selected] → [QuestionOutcome.unanswered]; an equal
/// value → [QuestionOutcome.correct]; otherwise [QuestionOutcome.incorrect]. An
/// unanswered Question is never reported as correct.
///
/// _Requirements: 7.1, 7.2, 7.3_
QuestionOutcome resolveOutcome(String? selected, String correctAnswer) {
  if (selected == null) return QuestionOutcome.unanswered;
  return selected == correctAnswer
      ? QuestionOutcome.correct
      : QuestionOutcome.incorrect;
}

/// One review row for a single auto-graded Question.
///
/// [prompt], [selectedOption] and [correctOption] hold the original German exam
/// content (Requirement 11.2). [selectedOption] is `null` when the Question was
/// left unanswered.
@immutable
class QuestionReview {
  /// Index of the Question within its Teil's selected Test.
  final int questionIndex;

  /// The German Question prompt (never localized — Requirement 11.2).
  final String prompt;

  /// The student's chosen option, or `null` when unanswered.
  final String? selectedOption;

  /// The Question's correct option (German content).
  final String correctOption;

  /// The graded outcome derived via [resolveOutcome].
  final QuestionOutcome outcome;

  const QuestionReview({
    required this.questionIndex,
    required this.prompt,
    required this.selectedOption,
    required this.correctOption,
    required this.outcome,
  });
}

/// The review of one Teil within an auto-graded Section.
@immutable
class TeilReview {
  /// The Section this Teil belongs to.
  final MockSection section;

  /// The official `teilNumber` of this Teil.
  final int teilNumber;

  /// One [QuestionReview] per auto-graded Question in this Teil, in order.
  final List<QuestionReview> questions;

  TeilReview({
    required this.section,
    required this.teilNumber,
    required List<QuestionReview> questions,
  }) : questions = List.unmodifiable(questions);
}

/// The review of one AI-evaluated Section (Schriftlicher / Mündlicher Ausdruck).
///
/// When [available] is `false` the AI evaluation could not be completed, and the
/// review surfaces an "evaluation unavailable" state for this Section without
/// blocking the others (Requirement 7.6).
@immutable
class AiSectionReview {
  /// The AI-evaluated Section.
  final MockSection section;

  /// Whether a parseable AI evaluation exists for this Section.
  final bool available;

  /// The AI feedback text (Schreiben feedback or Sprechen overall), if any.
  final String? feedback;

  /// A human-readable score such as `"16/20"`, when available.
  final String? score;

  const AiSectionReview({
    required this.section,
    required this.available,
    this.feedback,
    this.score,
  });
}

/// The complete, immutable review of a finished attempt.
///
/// Returned by `MockTestController.buildReview()`. [result] preserves the
/// existing totals / pass-fail summary (Requirement 7.7); [autoGraded] holds the
/// per-Teil auto-graded reviews; [aiSections] holds the AI-Section reviews.
@immutable
class MockReview {
  /// The scoring summary (totals and pass/fail), preserved as-is (R7.7).
  final MockResult result;

  /// Per-Teil reviews for the auto-graded Sections, in order.
  final List<TeilReview> autoGraded;

  /// Reviews for the AI-evaluated Sections, in order.
  final List<AiSectionReview> aiSections;

  MockReview({
    required this.result,
    required List<TeilReview> autoGraded,
    required List<AiSectionReview> aiSections,
  })  : autoGraded = List.unmodifiable(autoGraded),
        aiSections = List.unmodifiable(aiSections);
}
