// Property test for navigation + read-only review invariants.
//
// Feature: b1-mock-test-redesign, Property 3: Navigatsiya va read-only metodlar
// holatni o'zgartirmaydi — For any assembled MockTestAttempt, any recorded
// answers, and any finite sequence of operations drawn from
// { goToTeil(i), next(), previous(), outcomeFor(key), buildReview() }, after the
// sequence the answers map is deep-equal to its initial value,
// schreibenFeedback / sprechenEvaluation are unchanged, the attempt reference is
// identical, and currentTeilIndex is always within [0, teilCount)
// (out-of-range goToTeil indices are no-ops).
//
// Validates: Requirements 2.5, 6.2, 10.2
//
// Strategy: glados drives three dimensions — an attempt-structure seed, an
// answers seed, and a list of integer operation codes. The seeds build a
// synthetic attempt (auto-graded Lesen/Sprachbausteine/Hören Teile plus AI
// Schreiben/Sprechen Teile) and a random mix of answered/unanswered/invalid
// answers, deterministically from a seeded Random. Each operation code is
// decoded into one of the five operations; goToTeil indices are mapped into a
// range that includes out-of-range values so the no-op path is exercised. The
// invariants are checked after every operation (not just at the end) so any
// intermediate mutation is caught, and currentTeilIndex is asserted in range at
// each step. Runs at least 100 iterations (glados default).

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test;

import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_review_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:core/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_recording_models.dart';

const _options = ['A', 'B', 'C', 'D'];

/// Builds a synthetic, frozen [MockTestAttempt] covering both auto-graded
/// (Lesen / Sprachbausteine / Hören) and AI (Schreiben / Sprechen) Teile, with
/// per-Teil question counts and correct answers derived from [rng].
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
    MockTeil(
      section: MockSection.schriftlicherAusdruck,
      teilNumber: 1,
      test: const SelectedSchreibenTest(
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
          SprechenAufgabe(title: 'Sich vorstellen', instruction: 'Stellen Sie sich vor.'),
        ],
      ),
    ),
  );

  return MockTestAttempt(teile);
}

/// Populates [controller].answers with a random mix of answered (valid or
/// invalid option), and unanswered Questions across the auto-graded Teile.
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
      controller.answers[AnswerKey(t, q)] = option;
    }
  }
}

/// Optionally captures AI results so the invariant check exercises both the
/// present and absent cases.
void _seedAiResults(MockTestController controller, Random rng) {
  switch (rng.nextInt(3)) {
    case 0:
      break; // leave null
    case 1:
      controller.schreibenFeedback = 'Gut gemacht. Jami: ${rng.nextInt(21)}/20';
    case 2:
      controller.schreibenFeedback = 'kein bewertbarer Wert';
  }
  if (rng.nextBool()) {
    final teilNumber = 1 + rng.nextInt(3);
    controller.recordSprechenEvaluation(
      teilNumber,
      AudioEvaluation(
        score: rng.nextBool() ? '${rng.nextInt(31)}/30' : 'B1 erreicht',
        pronunciation: 'ok',
        fluency: 'ok',
        grammar: 'ok',
        content: 'ok',
        overall: 'ok',
      ),
    );
  }
}

/// Maps a raw operation code to a goToTeil target that includes out-of-range
/// indices (so the no-op path is exercised) within [-3, teilCount + 2].
int _goToTarget(int opCode, int teilCount) {
  final raw = opCode.abs() ~/ 5;
  return -3 + (raw % (teilCount + 6));
}

/// Maps a raw operation code to an AnswerKey (possibly out of range — outcomeFor
/// tolerates it as a pure read).
AnswerKey _keyFrom(int opCode, int teilCount) {
  final raw = opCode.abs() ~/ 5;
  final teilIndex = raw % teilCount;
  final questionIndex = (raw ~/ teilCount) % 8;
  return AnswerKey(teilIndex, questionIndex);
}

void main() {
  // Feature: b1-mock-test-redesign, Property 3: Navigatsiya va read-only
  // metodlar holatni o'zgartirmaydi.
  Glados3<int, int, List<int>>(
    any.int,
    any.int,
    any.list(any.int),
  ).test(
    'Property 3: navigation + read-only ops never mutate answers/AI/attempt and keep currentTeilIndex in range',
    (attemptSeed, answerSeed, opCodes) {
      final attempt = _buildAttempt(Random(attemptSeed.abs()));
      final controller = MockTestController(attempt: attempt);
      _seedAnswers(controller, Random(answerSeed.abs()));
      _seedAiResults(controller, Random(answerSeed.abs() ^ 0x5bd1e995));

      final teilCount = controller.teilCount;

      // Snapshot the initial state that must remain unchanged.
      final initialAnswers = Map<AnswerKey, String>.from(controller.answers);
      final initialFeedback = controller.schreibenFeedback;
      final initialEvaluations =
          Map<int, AudioEvaluation>.from(controller.sprechenEvaluations);

      void assertInvariants() {
        // currentTeilIndex stays within [0, teilCount).
        expect(
          controller.currentTeilIndex,
          inInclusiveRange(0, teilCount - 1),
          reason: 'currentTeilIndex must stay within [0, teilCount)',
        );
        // answers deep-equal to the initial snapshot.
        expect(
          mapEquals(controller.answers, initialAnswers),
          isTrue,
          reason: 'answers must be deep-equal to the initial value',
        );
        // AI results unchanged (string value and evaluation identity).
        expect(controller.schreibenFeedback, initialFeedback,
            reason: 'schreibenFeedback must be unchanged');
        expect(
          mapEquals(controller.sprechenEvaluations, initialEvaluations),
          isTrue,
          reason: 'sprechenEvaluations must be unchanged',
        );
        // attempt reference identical.
        expect(identical(controller.attempt, attempt), isTrue,
            reason: 'attempt reference must be identical');
      }

      // Invariants hold before any operation.
      assertInvariants();

      for (final opCode in opCodes) {
        switch (opCode.abs() % 5) {
          case 0:
            controller.goToTeil(_goToTarget(opCode, teilCount));
          case 1:
            controller.next();
          case 2:
            controller.previous();
          case 3:
            controller.outcomeFor(_keyFrom(opCode, teilCount));
          case 4:
            controller.buildReview();
        }
        // Invariants must hold after every operation.
        assertInvariants();
      }
    },
  );

  // Explicit edge cases required by the task: out-of-range goToTeil indices are
  // no-ops and the read-only helpers never mutate state.
  group('Property 3: explicit edge cases', () {
    test('out-of-range goToTeil indices are no-ops', () {
      final attempt = _buildAttempt(Random(123));
      final controller = MockTestController(attempt: attempt);
      controller.goToTeil(2);
      final before = controller.currentTeilIndex;

      controller.goToTeil(-1);
      expect(controller.currentTeilIndex, before);
      controller.goToTeil(controller.teilCount);
      expect(controller.currentTeilIndex, before);
      controller.goToTeil(9999);
      expect(controller.currentTeilIndex, before);
    });

    test('outcomeFor and buildReview do not mutate answers or position', () {
      final attempt = _buildAttempt(Random(7));
      final controller = MockTestController(attempt: attempt);
      controller.answers[const AnswerKey(0, 0)] = 'A';
      final snapshot = Map<AnswerKey, String>.from(controller.answers);
      final index = controller.currentTeilIndex;

      controller.outcomeFor(const AnswerKey(0, 0));
      controller.outcomeFor(const AnswerKey(999, 999)); // out of range read
      controller.buildReview();

      expect(mapEquals(controller.answers, snapshot), isTrue);
      expect(controller.currentTeilIndex, index);
    });

    test('goToTeil reaches every in-range Teil without altering answers', () {
      final attempt = _buildAttempt(Random(55));
      final controller = MockTestController(attempt: attempt);
      controller.answers[const AnswerKey(0, 0)] = 'B';
      final snapshot = Map<AnswerKey, String>.from(controller.answers);

      for (var i = 0; i < controller.teilCount; i++) {
        controller.goToTeil(i);
        expect(controller.currentTeilIndex, i);
      }
      expect(mapEquals(controller.answers, snapshot), isTrue);
    });
  });
}
