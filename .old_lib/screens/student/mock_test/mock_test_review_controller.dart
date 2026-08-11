// B1 Mock Test — read-only review + position-navigation extension.
//
// This extension augments [MockTestController] with exactly the read-only
// helpers the redesigned result screen needs (per-Question outcomes and a full
// [MockReview]) plus one position-navigation method used by the overview
// drawer. None of these members touch the assembled [MockTestAttempt], the
// recorded [MockTestController.answers], or the captured AI results — they only
// read existing state or move the cursor, so the domain core's scoring and
// assembly behavior is unchanged (Requirements 10.1, 10.2, 10.3).

import 'mock_test_controller.dart';
import 'model/mock_test_attempt.dart';
import 'model/mock_test_review.dart';
import 'model/mock_test_scorer.dart';
import 'model/mock_test_structure.dart';

/// Read-only review helpers and position navigation for an in-progress or
/// finished [MockTestController] attempt.
extension MockTestReview on MockTestController {
  // ── Navigatsiya (faqat pozitsiya) ──────────────────────────────────────────

  /// Moves the cursor to the Teil at [index], as selected from the overview
  /// drawer.
  ///
  /// Only the current position changes — the assembled content, the recorded
  /// answers, and the captured AI results are never altered. An out-of-range
  /// [index] is a no-op (the position is left exactly as it was). Delegates to
  /// the controller's existing [MockTestController.next] /
  /// [MockTestController.previous] cursor moves, so no domain-core state is
  /// touched (Requirements 2.5, 10.1).
  void goToTeil(int index) {
    if (index < 0 || index >= teilCount) return;
    while (currentTeilIndex < index) {
      next();
    }
    while (currentTeilIndex > index) {
      previous();
    }
  }

  // ── Read-only review yordamchilari ─────────────────────────────────────────

  /// The graded outcome of the auto-graded Question identified by [key].
  ///
  /// Pure derivation via [resolveOutcome]: an unanswered Question →
  /// [QuestionOutcome.unanswered]; a selection equal to the Question's
  /// `correctAnswer` → [QuestionOutcome.correct]; otherwise
  /// [QuestionOutcome.incorrect]. Reads existing state only — never mutates it
  /// (Requirements 7.1, 7.2, 7.3, 10.2).
  QuestionOutcome outcomeFor(AnswerKey key) {
    final correct = _correctAnswerAt(key.teilIndex, key.questionIndex);
    return resolveOutcome(answerFor(key), correct ?? '');
  }

  /// Builds the complete, immutable [MockReview] for the attempt.
  ///
  /// For every auto-graded Teil (Leseverstehen, Sprachbausteine, Hörverstehen)
  /// it produces a [TeilReview] with one [QuestionReview] per Question; for each
  /// AI Section (Schriftlicher / Mündlicher Ausdruck) it produces an
  /// [AiSectionReview] whose [AiSectionReview.available] mirrors
  /// [MockTestScorer.parseAiFraction]. The scoring summary comes from
  /// [MockTestController.buildResult]. Reads existing state only — never mutates
  /// it (Requirements 7.1–7.7, 10.1, 10.2, 10.3).
  MockReview buildReview() {
    final autoGraded = <TeilReview>[];

    for (var teilIndex = 0; teilIndex < attempt.teile.length; teilIndex++) {
      final teil = attempt.teile[teilIndex];
      if (!MockTestScorer.autoGradedSections.contains(teil.section)) continue;

      final rows = _autoGradedRowsOf(teil.test);
      final questions = <QuestionReview>[];
      for (var q = 0; q < rows.length; q++) {
        final selected = answerFor(AnswerKey(teilIndex, q));
        questions.add(
          QuestionReview(
            questionIndex: q,
            prompt: rows[q].prompt,
            selectedOption: selected,
            correctOption: rows[q].correct,
            outcome: resolveOutcome(selected, rows[q].correct),
          ),
        );
      }

      autoGraded.add(
        TeilReview(
          section: teil.section,
          teilNumber: teil.teilNumber,
          questions: questions,
        ),
      );
    }

    final aiSections = <AiSectionReview>[
      _schreibenReview(),
      _sprechenReview(),
    ];

    return MockReview(
      result: buildResult(),
      autoGraded: autoGraded,
      aiSections: aiSections,
    );
  }

  // ── Internal helpers (pure reads) ──────────────────────────────────────────

  /// The Schriftlicher Ausdruck review, sourced from the captured Schreiben
  /// feedback. Unavailable when its rubric fraction is missing/unparseable
  /// (Requirement 7.6).
  AiSectionReview _schreibenReview() {
    final feedback = schreibenFeedback;
    return AiSectionReview(
      section: MockSection.schriftlicherAusdruck,
      available: MockTestScorer.parseAiFraction(feedback) != null,
      feedback: feedback,
      score: null,
    );
  }

  /// The Mündlicher Ausdruck review, combined from the per-Teil Sprechen
  /// evaluations (Teil 1 = 15, Teil 2 = 30, Teil 3 = 30). The score badge shows
  /// the summed points out of 75; the feedback lists each Teil's points and its
  /// overall note. Unavailable only when no Teil has a parseable evaluation
  /// (Requirement 7.6).
  AiSectionReview _sprechenReview() {
    final oral = MockTestScorer.oralPointsFrom(sprechenEvaluations);
    final oralMax = MockTestStructure
        .sectionMaxPoints[MockSection.muendlicherAusdruck]!;

    if (oral == null) {
      return const AiSectionReview(
        section: MockSection.muendlicherAusdruck,
        available: false,
        feedback: null,
        score: null,
      );
    }

    final buffer = StringBuffer();
    MockTestStructure.sprechenTeilMax.forEach((teilNumber, teilMax) {
      final evaluation = sprechenEvaluations[teilNumber];
      final fraction = MockTestScorer.parseAiFraction(evaluation?.score);
      if (fraction != null) {
        final points = (fraction * teilMax).round().clamp(0, teilMax);
        final overall = (evaluation?.overall ?? '').trim();
        buffer.writeln(
          'Teil $teilNumber: $points/$teilMax${overall.isNotEmpty ? ' — $overall' : ''}',
        );
      } else {
        buffer.writeln('Teil $teilNumber: — (baholanmadi)');
      }
    });

    return AiSectionReview(
      section: MockSection.muendlicherAusdruck,
      available: true,
      feedback: buffer.toString().trim(),
      score: '$oral / $oralMax',
    );
  }

  /// The ordered `(prompt, correct)` rows of an auto-graded selected Test. AI
  /// Tests (Schreiben / Sprechen) carry no auto-gradable Questions.
  List<({String prompt, String correct})> _autoGradedRowsOf(SelectedTest test) {
    switch (test) {
      case SelectedLesenTest(:final questions):
        return [
          for (final q in questions)
            (prompt: q.prompt, correct: q.correctAnswer),
        ];
      case SelectedHorenTest(:final questions):
        return [
          for (final q in questions)
            (prompt: q.question, correct: q.correctAnswer),
        ];
      case SelectedSchreibenTest():
      case SelectedSprechenTest():
        return const [];
    }
  }

  /// The `correctAnswer` of the auto-graded Question at
  /// `(teilIndex, questionIndex)`, or `null` when the indices fall outside an
  /// auto-graded Question.
  String? _correctAnswerAt(int teilIndex, int questionIndex) {
    if (teilIndex < 0 || teilIndex >= attempt.teile.length) return null;
    final rows = _autoGradedRowsOf(attempt.teile[teilIndex].test);
    if (questionIndex < 0 || questionIndex >= rows.length) return null;
    return rows[questionIndex].correct;
  }
}
