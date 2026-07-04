// Property test for the auto-graded review derivation `buildReview().autoGraded`,
// checked model-based against the unchanged domain-core scorer.
//
// Feature: b1-mock-test-redesign, Property 1: Auto-graded review per-savol
// to'g'riligi (scorer bilan model-based) — For any assembled MockTestAttempt and
// any map of recorded answers, buildReview().autoGraded contains exactly one
// QuestionReview for every Question of every auto-graded Teil (Leseverstehen,
// Sprachbausteine, Hörverstehen), where each row's correctOption equals that
// Question's correctAnswer, its selectedOption equals answerFor(key) (null when
// unanswered), its outcome equals resolveOutcome(selected, correct) (unanswered
// => unanswered, never correct), and the total number of `correct` outcomes
// equals MockTestScorer.autoGradeCount over the same questions and answers.
//
// Validates: Requirements 7.1, 7.2, 7.3, 7.4
//
// Oracle: MockTestScorer.autoGradeCount(List<({String correct})>, Map<int, String?>)
// — the unchanged scorer's per-Test correct counter (R10.1 cross-check).
//
// Strategy: glados drives a List<List<int>> — one inner list per Teil, one int
// per Question. Each int is decoded into a (correctOption, studentAnswer) pair
// (4 options, plus an "unanswered" state), giving a uniform mix of correct,
// incorrect and blank answers including the all-correct / all-incorrect /
// all-blank / empty-Teil edges (also pinned by explicit example tests). Each
// generated attempt cycles its auto-graded sections through Leseverstehen
// (Lesen test), Sprachbausteine (Lesen test) and Hörverstehen (Hören test) so
// both auto-graded selected-test shapes are exercised. Runs the glados default
// of 100 inputs.

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test;

import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_review_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_review.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_scorer.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';

// ── Fixed option set used by every synthetic Question ─────────────────────────
const _options = ['opt0', 'opt1', 'opt2', 'opt3'];

// The three auto-graded sections, cycled per Teil. Leseverstehen and
// Sprachbausteine are backed by SelectedLesenTest; Hörverstehen by
// SelectedHorenTest.
const _autoGradedCycle = [
  MockSection.leseverstehen,
  MockSection.sprachbausteine,
  MockSection.hoerverstehen,
];

// ── Pure decode of one generated question-code ────────────────────────────────

/// The Question's correct option, decoded from [code].
String _correctOf(int code) => 'opt${code % 4}';

/// The student's selected option for [code], or `null` when left unanswered.
///
/// The low bits choose the correct option; the next bits choose an answer state
/// in `0..4`: `0` means unanswered, `1..4` select options `opt0..opt3` (so the
/// correct option and every wrong option, plus blank, are all reachable).
String? _selectedOf(int code) {
  final answerState = (code ~/ 4) % 5;
  return answerState == 0 ? null : 'opt${answerState - 1}';
}

/// Builds a synthetic attempt whose Teile are all auto-graded, one inner list of
/// [teileCodes] per Teil and one code per Question.
MockTestAttempt _buildAttempt(List<List<int>> teileCodes) {
  final teile = <MockTeil>[];
  for (var t = 0; t < teileCodes.length; t++) {
    final section = _autoGradedCycle[t % _autoGradedCycle.length];
    final codes = teileCodes[t];
    final SelectedTest test;
    if (section == MockSection.hoerverstehen) {
      test = SelectedHorenTest(
        questions: [
          for (var i = 0; i < codes.length; i++)
            HorenQuestion(
              audioTitle: 'Aufgabe ${i + 1}',
              audioUrl: '',
              question: 'Frage $t-$i',
              options: _options,
              correctAnswer: _correctOf(codes[i]),
            ),
        ],
      );
    } else {
      test = SelectedLesenTest(
        questions: [
          for (var i = 0; i < codes.length; i++)
            LesenQuestion(
              prompt: 'Frage $t-$i',
              options: _options,
              correctAnswer: _correctOf(codes[i]),
            ),
        ],
      );
    }
    teile.add(MockTeil(section: section, teilNumber: t + 1, test: test));
  }
  return MockTestAttempt(teile);
}

/// Builds a controller for [teileCodes] and records the decoded answers.
MockTestController _controllerFor(List<List<int>> teileCodes) {
  final controller = MockTestController(attempt: _buildAttempt(teileCodes));
  for (var t = 0; t < teileCodes.length; t++) {
    final codes = teileCodes[t];
    for (var i = 0; i < codes.length; i++) {
      final selected = _selectedOf(codes[i]);
      if (selected != null) {
        controller.selectAnswer(AnswerKey(t, i), selected);
      }
    }
  }
  return controller;
}

/// Asserts the full Property 1 contract for one generated [teileCodes].
void _assertAutoGradedReview(List<List<int>> teileCodes) {
  final controller = _controllerFor(teileCodes);
  final review = controller.buildReview();

  // Every Teil is auto-graded here, so there is exactly one TeilReview per Teil,
  // in order.
  expect(
    review.autoGraded.length,
    teileCodes.length,
    reason: 'one TeilReview per auto-graded Teil',
  );

  var actualCorrect = 0;
  var oracleCorrect = 0;

  for (var t = 0; t < teileCodes.length; t++) {
    final codes = teileCodes[t];
    final teilReview = review.autoGraded[t];

    // The section follows the generated cycle (R7 ordering is preserved).
    expect(teilReview.section, _autoGradedCycle[t % _autoGradedCycle.length]);

    // Exactly one QuestionReview per Question of this Teil.
    expect(
      teilReview.questions.length,
      codes.length,
      reason: 'one QuestionReview per Question',
    );

    for (var i = 0; i < codes.length; i++) {
      final row = teilReview.questions[i];
      final expectedSelected = _selectedOf(codes[i]);
      final expectedCorrect = _correctOf(codes[i]);

      // Rows are in question order and indexed correctly.
      expect(row.questionIndex, i, reason: 'questionIndex in order');

      // correctOption == the Question's correctAnswer (R7.3).
      expect(row.correctOption, expectedCorrect);

      // selectedOption == answerFor(key), null when unanswered (R7.2, R7.3).
      expect(row.selectedOption, expectedSelected);
      expect(row.selectedOption, controller.answerFor(AnswerKey(t, i)));

      // outcome == resolveOutcome(selected, correct); unanswered is never
      // reported as correct (R7.1, R7.2, R7.4).
      expect(row.outcome, resolveOutcome(expectedSelected, expectedCorrect));
      if (expectedSelected == null) {
        expect(row.outcome, QuestionOutcome.unanswered);
        expect(row.outcome, isNot(QuestionOutcome.correct));
      }

      if (row.outcome == QuestionOutcome.correct) actualCorrect++;
    }

    // Oracle: the unchanged scorer's per-Test correct counter over the same
    // questions and answers (R10.1 cross-check).
    final oracleQuestions = [
      for (final code in codes) (correct: _correctOf(code)),
    ];
    final oracleAnswers = <int, String?>{
      for (var i = 0; i < codes.length; i++) i: _selectedOf(codes[i]),
    };
    oracleCorrect +=
        MockTestScorer.autoGradeCount(oracleQuestions, oracleAnswers);
  }

  // The number of `correct` review rows equals the scorer's count (R7.1, R7.4).
  expect(
    actualCorrect,
    oracleCorrect,
    reason: 'correct-outcome count must equal MockTestScorer.autoGradeCount',
  );
}

void main() {
  // Feature: b1-mock-test-redesign, Property 1: Auto-graded review per-savol
  // to'g'riligi (scorer bilan model-based).
  Glados<List<List<int>>>(
    any.listWithLengthInRange(
      1,
      7, // 1..6 Teile
      any.listWithLengthInRange(0, 12, any.intInRange(0, 1000)), // 0..11 Qs
    ),
  ).test(
    'Property 1: each auto-graded row matches its correctAnswer/selection/'
    'outcome and the correct count equals MockTestScorer.autoGradeCount',
    _assertAutoGradedReview,
  );

  // Explicit edge cases required by the task, deterministically covered.
  group('Property 1: explicit edge cases', () {
    test('all answers correct → every outcome correct, count == total', () {
      // answerState 1..4 selecting the matching option: encode correct=ci and
      // answer index = ci, i.e. code where code%4==ci and (code~/4)%5 == ci+1.
      // Simplest: pick code so correct='opt0' and selected='opt0'.
      // correct: code%4 == 0; selected: (code~/4)%5 == 1 → answerState 1 → opt0.
      const code = 4; // 4%4=0 → opt0 ; (4~/4)%5=1 → opt0
      final controller = _controllerFor([
        [code, code, code],
      ]);
      final review = controller.buildReview();
      final rows = review.autoGraded.single.questions;
      expect(rows.every((r) => r.outcome == QuestionOutcome.correct), isTrue);
      expect(rows.where((r) => r.outcome == QuestionOutcome.correct).length, 3);
    });

    test('all answers wrong → no correct outcomes', () {
      // correct: opt0 (code%4==0); selected: opt1 (answerState 2 → code~/4%5==2).
      const code = 8; // 8%4=0 → opt0 ; (8~/4)%5=2 → opt1
      final controller = _controllerFor([
        [code, code],
      ]);
      final review = controller.buildReview();
      final rows = review.autoGraded.single.questions;
      expect(rows.any((r) => r.outcome == QuestionOutcome.correct), isFalse);
      expect(rows.every((r) => r.outcome == QuestionOutcome.incorrect), isTrue);
    });

    test('all unanswered → every outcome unanswered, none correct', () {
      // answerState 0 → unanswered (code~/4%5==0), e.g. code 0..3.
      const code = 0;
      final controller = _controllerFor([
        [code, code, code],
      ]);
      final review = controller.buildReview();
      final rows = review.autoGraded.single.questions;
      expect(
        rows.every((r) => r.outcome == QuestionOutcome.unanswered),
        isTrue,
      );
      expect(rows.every((r) => r.selectedOption == null), isTrue);
      expect(rows.any((r) => r.outcome == QuestionOutcome.correct), isFalse);
    });

    test('empty Teil → empty question rows', () {
      final controller = _controllerFor([<int>[]]);
      final review = controller.buildReview();
      expect(review.autoGraded.single.questions, isEmpty);
    });

    test('correct-outcome count equals MockTestScorer.autoGradeCount', () {
      // Mixed: opt0 correct + select opt0 (4), opt0 correct + blank (0),
      // opt0 correct + select opt1 (8).
      _assertAutoGradedReview([
        [4, 0, 8],
      ]);
    });
  });
}
