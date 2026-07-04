// Widget + unit tests for the B1 Mock Test result-screen review (Task 11.2).
//
// These tests drive a real [MockTestController] over an assembled attempt that
// covers all five Sections (auto-graded Leseverstehen / Hörverstehen plus the
// AI-evaluated Schriftlicher / Mündlicher Ausdruck), then exercise the review
// built by `controller.buildReview()` against the redesigned
// [MockTestResultScreen].
//
//   * Unit: `buildReview().result` preserves the existing scoring summary —
//     it is field-by-field equal to `buildResult()` (totals, maxima, pass/fail,
//     per-Section points and the unavailable-Section set). (Requirement 7.7)
//   * Widget: every auto-graded Question renders a review row showing the
//     student's answer and the correct answer, including the "not answered"
//     label for an unanswered Question. (Requirements 7.1, 7.4)
//   * Widget: an AI Section whose evaluation is unavailable shows the
//     "evaluation unavailable" note while every other Section — the available
//     AI Section and all auto-graded rows — is still presented. (Requirements
//     7.5, 7.6)
//
// The screen localizes its app-authored text through `AppLocalizations.of`,
// which reads a `ValueNotifier<AppLocale>` from a Provider; the tests mirror the
// app's `ChangeNotifierProvider.value` wiring and pin the locale to the Uzbek
// (`uz`) default so the asserted labels are deterministic. The German exam
// content (prompts, Section names) stays German regardless of locale.

import 'package:flutter/foundation.dart' show mapEquals, setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:berlin_nukus/l10n/locale_manager.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_result_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_review_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_recording_models.dart';

// ── Synthetic fixture (mirrors test/models/mock_test_review_invariants_test.dart) ──

const _options = ['A', 'B', 'C', 'D'];

/// Builds a frozen synthetic [MockTestAttempt] covering all five Sections: two
/// auto-graded Teile (one Leseverstehen, one Hörverstehen) with known prompts
/// and correct answers, plus the whole-unit AI Teile (Schriftlicher and
/// Mündlicher Ausdruck). Prompts are fixed strings so the review rows can be
/// found in the widget tests.
MockTestAttempt _buildAttempt() {
  return MockTestAttempt([
    // Auto-graded Leseverstehen Teil with two questions.
    MockTeil(
      section: MockSection.leseverstehen,
      teilNumber: 1,
      test: SelectedLesenTest(
        questions: [
          LesenQuestion(
            prompt: 'Lesen Frage Eins',
            options: _options,
            correctAnswer: 'A',
          ),
          LesenQuestion(
            prompt: 'Lesen Frage Zwei',
            options: _options,
            correctAnswer: 'C',
          ),
        ],
      ),
    ),
    // Auto-graded Hörverstehen Teil with two questions.
    MockTeil(
      section: MockSection.hoerverstehen,
      teilNumber: 1,
      test: SelectedHorenTest(
        questions: [
          HorenQuestion(
            audioTitle: 'Audio',
            audioUrl: 'https://example.test/a.mp3',
            question: 'Hören Frage Eins',
            options: _options,
            correctAnswer: 'B',
          ),
          HorenQuestion(
            audioTitle: 'Audio',
            audioUrl: 'https://example.test/b.mp3',
            question: 'Hören Frage Zwei',
            options: _options,
            correctAnswer: 'D',
          ),
        ],
      ),
    ),
    // AI Schriftlicher Ausdruck Teil (whole-unit, no auto-graded questions).
    const MockTeil(
      section: MockSection.schriftlicherAusdruck,
      teilNumber: 1,
      test: SelectedSchreibenTest(
        task: SchreibenTask(
          id: 1,
          task: 'Schreiben Sie einen Brief.',
          points: ['Punkt 1', 'Punkt 2'],
          style: 'formell',
          minWords: 80,
          level: 'B1',
        ),
      ),
    ),
    // AI Mündlicher Ausdruck Teil (whole-unit, no auto-graded questions).
    MockTeil(
      section: MockSection.muendlicherAusdruck,
      teilNumber: 1,
      test: SelectedSprechenTest(
        aufgaben: const [
          SprechenAufgabe(
            title: 'Sich vorstellen',
            instruction: 'Stellen Sie sich vor.',
          ),
        ],
      ),
    ),
  ]);
}

/// Wraps [child] in a MaterialApp with the locale Provider the screen expects,
/// pinned to the Uzbek (`uz`) default so the asserted labels are deterministic.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('buildReview().result preserves the scoring summary (7.7)', () {
    test('every total / maximum / pass flag / Section map equals buildResult()',
        () {
      final controller = MockTestController(attempt: _buildAttempt());
      // A mix of correct, incorrect and unanswered auto-graded answers.
      controller.answers[const AnswerKey(0, 0)] = 'A'; // Lesen Q0 — correct
      controller.answers[const AnswerKey(0, 1)] = 'B'; // Lesen Q1 — incorrect
      // Hören Q0 left unanswered.
      controller.answers[const AnswerKey(1, 1)] = 'D'; // Hören Q1 — correct
      // Schriftlicher AI unavailable (no feedback); Mündlicher AI available
      // (Teil 3 evaluated, scaled to its 30-point maximum).
      controller.recordSprechenEvaluation(
        3,
        const AudioEvaluation(
          score: '24/30',
          pronunciation: 'ok',
          fluency: 'ok',
          grammar: 'ok',
          content: 'ok',
          overall: 'Gute Leistung insgesamt.',
        ),
      );

      final result = controller.buildResult();
      final reviewResult = controller.buildReview().result;

      expect(reviewResult.writtenPoints, result.writtenPoints);
      expect(reviewResult.writtenMax, result.writtenMax);
      expect(reviewResult.oralPoints, result.oralPoints);
      expect(reviewResult.oralMax, result.oralMax);
      expect(reviewResult.writtenPassed, result.writtenPassed);
      expect(reviewResult.oralPassed, result.oralPassed);
      expect(
        mapEquals(reviewResult.sectionPoints, result.sectionPoints),
        isTrue,
        reason: 'per-Section points must be preserved',
      );
      expect(
        setEquals(
          reviewResult.unavailableSections,
          result.unavailableSections,
        ),
        isTrue,
        reason: 'the unavailable-Section set must be preserved',
      );
      // The Schriftlicher AI Section is unavailable; Mündlicher is scored.
      expect(
        reviewResult.unavailableSections,
        contains(MockSection.schriftlicherAusdruck),
      );
      expect(
        reviewResult.unavailableSections,
        isNot(contains(MockSection.muendlicherAusdruck)),
      );
    });
  });

  group('Question_Review rendering', () {
    testWidgets(
        'renders a review row per auto-graded Question with the student and '
        'correct answers, including the unanswered label (7.1, 7.4)',
        (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      controller.answers[const AnswerKey(0, 0)] = 'A'; // Lesen Q0 — correct
      controller.answers[const AnswerKey(0, 1)] = 'B'; // Lesen Q1 — incorrect
      // Hören Q0 left unanswered → "not answered".
      controller.answers[const AnswerKey(1, 1)] = 'D'; // Hören Q1 — correct

      final review = controller.buildReview();

      await tester.pumpWidget(_wrap(
        MockTestResultScreen(result: controller.buildResult(), review: review),
      ));
      await tester.pump();

      // The review section header is shown.
      expect(find.text("Javoblarni ko'rib chiqish"), findsOneWidget);

      // Each auto-graded Question prompt (German) renders a review row.
      expect(find.textContaining('Lesen Frage Eins'), findsOneWidget);
      expect(find.textContaining('Lesen Frage Zwei'), findsOneWidget);
      expect(find.textContaining('Hören Frage Eins'), findsOneWidget);
      expect(find.textContaining('Hören Frage Zwei'), findsOneWidget);

      // The "your answer" / "correct answer" labels appear on every row.
      // These render inside a RichText, so match against rich text spans.
      expect(
        find.textContaining('Sizning javobingiz', findRichText: true),
        findsNWidgets(4),
      );
      expect(
        find.textContaining("To'g'ri javob", findRichText: true),
        findsNWidgets(4),
      );

      // The unanswered Hören Question surfaces the localized "not answered"
      // label rather than a blank selection (Requirement 7.2 surfaced in 7.4).
      expect(
        find.textContaining('Javob berilmagan', findRichText: true),
        findsOneWidget,
      );

      // There are exactly four auto-graded review rows (two Teile × two
      // questions), each with one outcome icon.
      expect(review.autoGraded.length, 2);
      expect(
        review.autoGraded.fold<int>(0, (n, t) => n + t.questions.length),
        4,
      );
    });

    testWidgets(
        'an unavailable AI Section shows the unavailable note while the other '
        'Sections still render (7.5, 7.6)', (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      controller.answers[const AnswerKey(0, 0)] = 'A'; // an auto-graded answer
      // Schriftlicher Ausdruck unavailable (no feedback captured).
      controller.schreibenFeedback = null;
      // Mündlicher Ausdruck available, with feedback text (Teil 3 evaluated).
      controller.recordSprechenEvaluation(
        3,
        const AudioEvaluation(
          score: '24/30',
          pronunciation: 'ok',
          fluency: 'ok',
          grammar: 'ok',
          content: 'ok',
          overall: 'Sehr gute muendliche Leistung.',
        ),
      );

      final review = controller.buildReview();

      await tester.pumpWidget(_wrap(
        MockTestResultScreen(result: controller.buildResult(), review: review),
      ));
      await tester.pump();

      // The model marks Schriftlicher unavailable and Mündlicher available.
      final schreiben = review.aiSections.firstWhere(
        (a) => a.section == MockSection.schriftlicherAusdruck,
      );
      final sprechen = review.aiSections.firstWhere(
        (a) => a.section == MockSection.muendlicherAusdruck,
      );
      expect(schreiben.available, isFalse);
      expect(sprechen.available, isTrue);

      // The unavailable note is shown (it appears for the Section score card
      // and the AI review card alike) — the AI failure does not suppress it.
      expect(find.text('Baholash mavjud emas'), findsWidgets);

      // The other AI Section still renders its feedback (not blocked, R7.6).
      expect(
        find.textContaining('Sehr gute muendliche Leistung.'),
        findsOneWidget,
      );

      // The auto-graded review rows still render despite the AI failure.
      expect(find.textContaining('Lesen Frage Eins'), findsOneWidget);
      expect(find.textContaining('Hören Frage Eins'), findsOneWidget);

      // Both AI Section names (German) are still listed.
      expect(find.text('Schriftlicher Ausdruck'), findsWidgets);
      expect(find.text('Mündlicher Ausdruck'), findsWidgets);
    });
  });
}
