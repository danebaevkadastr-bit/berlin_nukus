// Property test for the AI-Section review derivation `buildReview().aiSections`,
// checked model-based against the unchanged domain-core scorer.
//
// Feature: b1-mock-test-redesign, Property 2: AI Section review mavjudligi
// (scorer bilan model-based) — For any assembled attempt and any
// schreibenFeedback string and any sprechenEvaluation, each AiSectionReview
// produced by buildReview() has
// available == (MockTestScorer.parseAiFraction(raw) != null) for its raw AI
// score, the set of AI sections with available == false equals
// buildResult().unavailableSections, and the presence or absence of any AI
// evaluation never removes or alters the auto-graded review rows.
//
// Validates: Requirements 7.5, 7.6
//
// Oracle: MockTestScorer.parseAiFraction(String?) and the unchanged scorer's
// MockResult.unavailableSections (via buildResult()) — the AI availability
// classification is cross-checked against the domain core (R10.1).
//
// Strategy: glados drives three ints — a structure/answers seed and one code
// per AI Section. The seed builds a synthetic attempt (auto-graded
// Leseverstehen / Sprachbausteine / Hörverstehen Teile plus AI Schreiben /
// Sprechen Teile) and a random mix of answered/unanswered/invalid auto-graded
// answers, deterministically from a seeded Random. Each AI code is decoded into
// one of six raw-score shapes covering all the required categories: null,
// parseable rubric "X/20", parseable bare "X/75", two unparseable forms (no
// fraction at all, and a number with no slash), and a zero-denominator "X/0"
// that parseAiFraction must reject. The Sprechen evaluation is left null when
// its raw is null and otherwise carries the generated score, so both the
// "no evaluation" and "unparseable evaluation" cases are exercised. Runs the
// glados default of 100 inputs.

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test;

import 'package:core/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_review_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_review.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_scorer.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_recording_models.dart';

const _options = ['A', 'B', 'C', 'D'];

/// Builds a synthetic, frozen [MockTestAttempt] covering both auto-graded
/// (Leseverstehen / Sprachbausteine / Hörverstehen) and AI (Schriftlicher /
/// Mündlicher Ausdruck) Teile, with per-Teil question counts and correct
/// answers derived from [rng].
MockTestAttempt _buildAttempt(Random rng) {
  final teile = <MockTeil>[];

  LesenQuestion lesenQ() => LesenQuestion(
        prompt: 'Frage ${rng.nextInt(1000)}',
        options: _options,
        correctAnswer: _options[rng.nextInt(_options.length)],
      );

  HorenQuestion horenQ() => HorenQuestion(
        audioTitle: 'Audio',
        audioUrl: 'https://example.test/a.mp3',
        question: 'Frage ${rng.nextInt(1000)}',
        options: _options,
        correctAnswer: _options[rng.nextInt(_options.length)],
      );

  // Auto-graded Lesen Teile (Leseverstehen + Sprachbausteine).
  for (final spec in const [
    (MockSection.leseverstehen, 1),
    (MockSection.leseverstehen, 2),
    (MockSection.sprachbausteine, 4),
  ]) {
    final qCount = 1 + rng.nextInt(6); // 1..6
    teile.add(
      MockTeil(
        section: spec.$1,
        teilNumber: spec.$2,
        test: SelectedLesenTest(
          questions: List.generate(qCount, (_) => lesenQ()),
        ),
      ),
    );
  }

  // Auto-graded Hören Teile.
  for (final teilNumber in const [1, 2]) {
    final qCount = 1 + rng.nextInt(6); // 1..6
    teile.add(
      MockTeil(
        section: MockSection.hoerverstehen,
        teilNumber: teilNumber,
        test: SelectedHorenTest(
          questions: List.generate(qCount, (_) => horenQ()),
        ),
      ),
    );
  }

  // AI Schreiben Teil (whole-unit, no auto-graded questions).
  teile.add(
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
  );

  // AI Sprechen Teil (whole-unit, no auto-graded questions).
  teile.add(
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
  );

  return MockTestAttempt(teile);
}

/// Populates [controller].answers with a random mix of answered (valid or
/// invalid option) and unanswered Questions across the auto-graded Teile.
void _seedAnswers(MockTestController controller, Random rng) {
  final attempt = controller.attempt;
  for (var t = 0; t < attempt.teile.length; t++) {
    final test = attempt.teile[t].test;
    final qCount = switch (test) {
      SelectedLesenTest(:final questions) => questions.length,
      SelectedHorenTest(:final questions) => questions.length,
      _ => 0,
    };
    for (var q = 0; q < qCount; q++) {
      final roll = rng.nextInt(3);
      if (roll == 0) continue; // leave unanswered
      final option = roll == 1
          ? _options[rng.nextInt(_options.length)] // possibly correct/incorrect
          : 'Z'; // an option outside the set (always incorrect)
      controller.selectAnswer(AnswerKey(t, q), option);
    }
  }
}

/// Decodes a generated [code] into one raw AI-score shape, covering every
/// required category: null, two parseable fractions, two unparseable forms, and
/// a zero-denominator fraction that [MockTestScorer.parseAiFraction] rejects.
String? _aiRaw(int code) {
  final c = code.abs();
  switch (c % 6) {
    case 0:
      return null; // missing evaluation
    case 1:
      return 'Yaxshi ish. Jami: ${c % 21}/20'; // parseable rubric
    case 2:
      return '${c % 76}/75'; // parseable bare fraction
    case 3:
      return 'B1 darajasiga yetdi'; // unparseable: no fraction
    case 4:
      return 'Ball: ${c % 100} foiz'; // unparseable: number, no slash
    default:
      return '${c % 30}/0'; // unparseable: zero denominator
  }
}

/// Builds a controller for [structureSeed] with seeded auto-graded answers and
/// the given AI state.
MockTestController _controllerFor(
  int structureSeed, {
  String? schreibenRaw,
  String? sprechenRaw,
}) {
  final attempt = _buildAttempt(Random(structureSeed.abs()));
  final controller = MockTestController(attempt: attempt);
  _seedAnswers(controller, Random(structureSeed.abs() ^ 0x5bd1e995));
  controller.schreibenFeedback = schreibenRaw;
  if (sprechenRaw != null) {
    // Store the single raw score under Teil 3 (the chat-based Teil). With one
    // Teil evaluated, oral availability still mirrors parseAiFraction.
    controller.recordSprechenEvaluation(
      3,
      AudioEvaluation(
        score: sprechenRaw,
        pronunciation: 'ok',
        fluency: 'ok',
        grammar: 'ok',
        content: 'ok',
        overall: 'Umumiy xulosa',
      ),
    );
  }
  return controller;
}

/// Asserts two auto-graded review lists are field-for-field identical, so the
/// AI state never removes or alters the auto-graded rows (R7.6).
void _expectSameAutoGraded(List<TeilReview> a, List<TeilReview> b) {
  expect(a.length, b.length, reason: 'same number of auto-graded Teile');
  for (var t = 0; t < a.length; t++) {
    expect(a[t].section, b[t].section);
    expect(a[t].teilNumber, b[t].teilNumber);
    expect(a[t].questions.length, b[t].questions.length,
        reason: 'same number of Question rows');
    for (var q = 0; q < a[t].questions.length; q++) {
      final x = a[t].questions[q];
      final y = b[t].questions[q];
      expect(x.questionIndex, y.questionIndex);
      expect(x.prompt, y.prompt);
      expect(x.selectedOption, y.selectedOption);
      expect(x.correctOption, y.correctOption);
      expect(x.outcome, y.outcome);
    }
  }
}

/// Asserts the full Property 2 contract for one generated input.
void _assertAiReview(int structureSeed, int schreibenCode, int sprechenCode) {
  final schreibenRaw = _aiRaw(schreibenCode);
  final sprechenRaw = _aiRaw(sprechenCode);

  final controller = _controllerFor(
    structureSeed,
    schreibenRaw: schreibenRaw,
    sprechenRaw: sprechenRaw,
  );
  final review = controller.buildReview();

  // Exactly the two AI sections are reviewed, in official order.
  expect(
    review.aiSections.map((s) => s.section).toList(),
    const [MockSection.schriftlicherAusdruck, MockSection.muendlicherAusdruck],
    reason: 'one AiSectionReview per AI Section, in order',
  );

  final schreiben = review.aiSections
      .firstWhere((s) => s.section == MockSection.schriftlicherAusdruck);
  final sprechen = review.aiSections
      .firstWhere((s) => s.section == MockSection.muendlicherAusdruck);

  // ── (1) available mirrors parseAiFraction over the raw AI score (R7.5). ──
  expect(
    schreiben.available,
    MockTestScorer.parseAiFraction(schreibenRaw) != null,
    reason: 'Schreiben availability must mirror parseAiFraction',
  );
  // The Sprechen raw score is the Teil 3 evaluation's score (null when none).
  final sprechenScoreRaw = controller.sprechenEvaluations[3]?.score;
  expect(
    sprechen.available,
    MockTestScorer.parseAiFraction(sprechenScoreRaw) != null,
    reason: 'Sprechen availability must mirror parseAiFraction',
  );

  // ── (2) The unavailable set equals the scorer's unavailableSections. ──
  final unavailableFromReview = review.aiSections
      .where((s) => !s.available)
      .map((s) => s.section)
      .toSet();
  expect(
    unavailableFromReview,
    controller.buildResult().unavailableSections,
    reason: 'available==false set must equal buildResult().unavailableSections',
  );

  // ── (3) AI state never removes or alters the auto-graded review rows. ──
  // A baseline review with both AI evaluations cleared must have identical
  // auto-graded rows.
  final baseline = _controllerFor(structureSeed).buildReview();
  _expectSameAutoGraded(review.autoGraded, baseline.autoGraded);
}

void main() {
  // Feature: b1-mock-test-redesign, Property 2: AI Section review mavjudligi
  // (scorer bilan model-based).
  Glados3<int, int, int>(any.int, any.int, any.int).test(
    'Property 2: each AiSectionReview.available mirrors parseAiFraction, the '
    'unavailable set equals buildResult().unavailableSections, and AI state '
    'never alters the auto-graded rows',
    _assertAiReview,
  );

  // Explicit edge cases required by the task, deterministically covered.
  group('Property 2: explicit edge cases', () {
    test('both AI scores missing → both unavailable', () {
      final review = _controllerFor(11).buildReview();
      expect(review.aiSections.every((s) => !s.available), isTrue);
      final unavailable =
          review.aiSections.map((s) => s.section).toSet();
      expect(
        _controllerFor(11).buildResult().unavailableSections,
        unavailable,
      );
    });

    test('both AI scores parseable → both available, none unavailable', () {
      final controller = _controllerFor(
        11,
        schreibenRaw: 'Jami: 15/20',
        sprechenRaw: '60/75',
      );
      final review = controller.buildReview();
      expect(review.aiSections.every((s) => s.available), isTrue);
      expect(controller.buildResult().unavailableSections, isEmpty);
    });

    test('zero-denominator fraction is treated as unavailable', () {
      final controller = _controllerFor(
        11,
        schreibenRaw: 'Jami: 5/0',
        sprechenRaw: '10/0',
      );
      final review = controller.buildReview();
      expect(review.aiSections.every((s) => !s.available), isTrue);
    });

    test('one parseable + one missing → mixed availability matches scorer', () {
      final controller = _controllerFor(
        11,
        schreibenRaw: 'Jami: 12/20',
        sprechenRaw: null,
      );
      final review = controller.buildReview();
      final schreiben = review.aiSections
          .firstWhere((s) => s.section == MockSection.schriftlicherAusdruck);
      final sprechen = review.aiSections
          .firstWhere((s) => s.section == MockSection.muendlicherAusdruck);
      expect(schreiben.available, isTrue);
      expect(sprechen.available, isFalse);
      expect(
        controller.buildResult().unavailableSections,
        {MockSection.muendlicherAusdruck},
      );
    });

    test('AI state does not alter the auto-graded rows', () {
      final withAi = _controllerFor(
        42,
        schreibenRaw: 'Jami: 18/20',
        sprechenRaw: '70/75',
      ).buildReview();
      final withoutAi = _controllerFor(42).buildReview();
      _expectSameAutoGraded(withAi.autoGraded, withoutAi.autoGraded);
    });
  });
}
