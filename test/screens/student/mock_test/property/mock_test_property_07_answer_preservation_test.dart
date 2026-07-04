// Feature: b1-mock-test, Property 7: Answer preservation across navigation
//
// Property 7 (design.md): For any sequence of answer selections interleaved
// with forward/backward navigation, every answered Question retains its most
// recently selected option regardless of how the student moves between Teile.
//
// Validates: Requirements 4.3
//
// Strategy: build a synthetic B1 source model (always exposing at least one
// Test per required Teil so assembly succeeds), assemble a frozen attempt with
// a seeded `Random`, and drive a `MockTestController` through a generated
// sequence of `next`/`previous`/`selectAnswer` actions. We maintain an
// independent oracle map of the latest option selected for each answered
// `AnswerKey`. After every interleaved navigation+answer step — and again at
// the end — the controller's `answerFor(key)` must equal the oracle's latest
// value for every answered key, and unanswered keys must remain `null`. The
// `selectAnswer` calls deliberately target Questions across many different
// Teile (not just the current one) and re-answer the same Question multiple
// times, so the property exercises preservation across back-and-forth
// navigation and last-write-wins replacement. Runs a minimum of 100 `glados`
// iterations.

import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect;

/// Returns a Test-count in `[1, 4]` derived from [counts] at position [i],
/// safe regardless of the generated list length (never zero, never throws).
int _testCount(List<int> counts, int i) {
  if (counts.isEmpty) return 1;
  return (counts[i % counts.length].abs() % 4) + 1;
}

/// Builds a synthetic `LesenLevel` covering teilNumbers 1..5 with the chunk
/// sizes the official structure expects (5, 5, 10, 10, 10). Each Teil holds
/// `nTests` whole Tests' worth of questions plus aligned per-test texts/images.
LesenLevel _buildLesen(List<int> counts) {
  const perTestByTeil = {1: 5, 2: 5, 3: 10, 4: 10, 5: 10};
  final teile = <LesenTeil>[];
  for (var teilNumber = 1; teilNumber <= 5; teilNumber++) {
    final perTest = perTestByTeil[teilNumber]!;
    final nTests = _testCount(counts, teilNumber - 1);
    final questions = [
      for (var q = 0; q < perTest * nTests; q++)
        LesenQuestion(
          prompt: 'L$teilNumber-Q$q',
          options: const ['a', 'b', 'c'],
          correctAnswer: 'a',
        ),
    ];
    teile.add(LesenTeil(
      teilNumber: teilNumber,
      questionsPerTest: perTest,
      sharedText: 'shared-$teilNumber',
      testTexts: [for (var t = 0; t < nTests; t++) 'text-$teilNumber-$t'],
      testImages: [for (var t = 0; t < nTests; t++) 'img-$teilNumber-$t'],
      questions: questions,
    ));
  }
  return LesenLevel(level: 'B1', teile: teile);
}

/// Builds a synthetic `HorenLevel` covering teilNumbers 1..3 with chunk sizes
/// 5, 10, 5. Each Teil holds `nTests` whole Tests' worth of questions.
HorenLevel _buildHoren(List<int> counts) {
  const perTestByTeil = {1: 5, 2: 10, 3: 5};
  final teile = <HorenTeil>[];
  for (var teilNumber = 1; teilNumber <= 3; teilNumber++) {
    final perTest = perTestByTeil[teilNumber]!;
    final nTests = _testCount(counts, 5 + (teilNumber - 1));
    final questions = [
      for (var q = 0; q < perTest * nTests; q++)
        HorenQuestion(
          audioTitle: 'H$teilNumber-A$q',
          audioUrl: 'audio-$teilNumber-$q.mp3',
          question: 'H$teilNumber-Q$q',
          options: const ['a', 'b', 'c'],
          correctAnswer: 'a',
        ),
    ];
    teile.add(HorenTeil(teilNumber: teilNumber, questions: questions));
  }
  return HorenLevel(level: 'B1', teile: teile);
}

/// Builds a synthetic `schreibenTasksB1`-style list with `nTests` whole Tasks.
List<SchreibenTask> _buildSchreiben(List<int> counts) {
  final nTests = _testCount(counts, 8);
  return [
    for (var i = 0; i < nTests; i++)
      SchreibenTask(
        id: i,
        task: 'Schreiben task $i',
        points: const ['p1', 'p2', 'p3', 'p4'],
        style: 'formal',
        minWords: 80,
        level: 'B1',
        letter: 'Sehr geehrte Damen und Herren,',
      ),
  ];
}

/// Builds a synthetic `SprechenLevel` covering teilNumbers 1..3. Teile with an
/// even count expose `tests` (multiple `SprechenTest`s); the rest expose a
/// single `aufgaben` group. Every Teil always exposes at least one Test.
SprechenLevel _buildSprechen(List<int> counts) {
  final teile = <SprechenTeil>[];
  for (var teilNumber = 1; teilNumber <= 3; teilNumber++) {
    final nTests = _testCount(counts, 9 + (teilNumber - 1));
    SprechenAufgabe aufgabe(int i) => SprechenAufgabe(
          title: 'S$teilNumber-Aufgabe$i',
          instruction: 'instruction $i',
        );

    if (nTests.isEven) {
      teile.add(SprechenTeil(
        teilNumber: teilNumber,
        title: 'Teil $teilNumber',
        description: 'desc',
        tests: [
          for (var t = 0; t < nTests; t++)
            SprechenTest(thema: 'Thema $teilNumber-$t', aufgaben: [aufgabe(t)]),
        ],
      ));
    } else {
      teile.add(SprechenTeil(
        teilNumber: teilNumber,
        title: 'Teil $teilNumber',
        description: 'desc',
        aufgaben: [aufgabe(0)],
      ));
    }
  }
  return SprechenLevel(level: 'B1', teile: teile);
}

/// The number of presented Questions in the selected Test of [teil] — used to
/// pick valid `questionIndex` targets for `selectAnswer`.
int _questionCount(MockTeil teil) {
  final test = teil.test;
  return switch (test) {
    SelectedLesenTest() => test.questions.length,
    SelectedHorenTest() => test.questions.length,
    SelectedSchreibenTest() => 1,
    SelectedSprechenTest() => test.aufgaben.length,
  };
}

void main() {
  // Inputs:
  //   * seed      — drives the (deterministic) assembly selection.
  //   * counts    — varies how many Tests each required Teil exposes.
  //   * actions   — a sequence of step codes; each code is decomposed into a
  //                 navigation move and an optional answer write. Generating a
  //                 list of ints lets glados vary both the length and the shape
  //                 of the interleaved navigate/answer sequence, and lets it
  //                 shrink failing sequences.
  Glados3<int, List<int>, List<int>>(
    any.int,
    any.listWithLength(12, any.intInRange(1, 5)),
    any.list(any.intInRange(0, 1 << 20)),
    ExploreConfig(numRuns: 100), // minimum 100 iterations
  ).test(
    'Property 7: answered questions retain their latest option across '
    'interleaved navigation',
    (seed, counts, actions) {
      final attempt = MockTestAssembler.assemble(
        rng: Random(seed),
        lesen: _buildLesen(counts),
        horen: _buildHoren(counts),
        schreiben: _buildSchreiben(counts),
        sprechen: _buildSprechen(counts),
      );

      final controller = MockTestController(attempt: attempt);

      // Oracle: the latest option we expect the controller to report for each
      // key we have answered. Last write wins, mirroring `selectAnswer`.
      final expected = <AnswerKey, String>{};

      void assertConsistent() {
        // Every answered key still reports its most recently selected option.
        expected.forEach((key, option) {
          expect(controller.answerFor(key), option,
              reason: 'answered question $key must retain its latest option '
                  'regardless of navigation');
        });
      }

      for (var step = 0; step < actions.length; step++) {
        final code = actions[step];

        // Navigation move, interleaved with answering: 0 -> next, 1 -> previous,
        // 2/3 -> stay (answer-only step).
        switch (code & 0x3) {
          case 0:
            controller.next();
          case 1:
            controller.previous();
          default:
            break; // stay on the current Teil
        }

        // Answer write. We deliberately target a Teil that may differ from the
        // current position so the oracle accumulates answers spread across the
        // whole attempt; preservation must hold no matter where the student is.
        final teilIndex = (code >> 2) % controller.teilCount;
        final qCount = _questionCount(attempt.teile[teilIndex]);
        final questionIndex = (code >> 7) % qCount;
        final key = AnswerKey(teilIndex, questionIndex);
        // Option value varies per step so re-answering the same key exercises
        // last-write-wins replacement.
        final option = 'opt-$step-${code & 0x7}';

        controller.selectAnswer(key, option);
        expected[key] = option;

        // After every interleaved step the invariant must hold.
        assertConsistent();
      }

      // Final navigation sweep with no further answering: walk to the first
      // Teil and then to the last, confirming answers survive pure navigation.
      for (var i = 0; i < controller.teilCount; i++) {
        controller.previous();
      }
      assertConsistent();
      for (var i = 0; i < controller.teilCount; i++) {
        controller.next();
      }
      assertConsistent();

      // Unanswered keys never spontaneously gain a value.
      for (var t = 0; t < controller.teilCount; t++) {
        final qCount = _questionCount(attempt.teile[t]);
        for (var q = 0; q < qCount; q++) {
          final key = AnswerKey(t, q);
          if (!expected.containsKey(key)) {
            expect(controller.answerFor(key), isNull,
                reason: 'a question that was never answered must stay null');
          }
        }
      }
    },
  );
}
