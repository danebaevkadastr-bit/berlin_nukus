// Feature: b1-mock-test, Property 8: Fresh, independent assembly per Attempt
//
// Property 8 (design.md): For any two independent random sources, the two
// resulting Attempts are each internally valid and independent — answering or
// navigating one never alters the other, and each new Attempt is produced by a
// fresh selection.
//
// Validates: Requirements 4.4
//
// Strategy: drive `MockTestAssembler.assemble` twice, with two independent
// seeded `Random` sources, against the same synthetic B1 source models. The
// sources always expose at least one Test per required Teil, so both
// assemblies succeed. We then assert, across a minimum of 100 `glados`
// iterations:
//   * Internal validity — each Attempt has exactly the Teile that
//     `MockTestStructure.teilSpecs` defines, in order, each carrying a
//     non-empty selected Test of the correct variant.
//   * Independence — the two Attempts are distinct object graphs (no shared
//     `MockTeil` instances), and exercising one through a `MockTestController`
//     (a sequence of `next`/`previous`/`selectAnswer`) never changes the
//     content of the other Attempt nor leaks answers into the other's
//     controller.
//   * Fresh selection — re-assembling with a fresh `Random` of the same seed
//     reproduces the very same selection, confirming each Attempt is the
//     product of its own self-contained selection pass.

import 'dart:math';

import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
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

/// A stable, comparable description of an Attempt's *content* — the selected
/// Section/Teil for each Teil plus an identifier per selected Question — so two
/// content snapshots can be compared for equality without relying on object
/// identity.
String _describe(MockTestAttempt attempt) {
  final buffer = StringBuffer();
  for (final teil in attempt.teile) {
    buffer.write('${teil.section.name}#${teil.teilNumber}{');
    final test = teil.test;
    switch (test) {
      case SelectedLesenTest():
        buffer.write('text=${test.text};img=${test.imageUrl};');
        buffer.write(test.questions.map((q) => q.prompt).join(','));
      case SelectedHorenTest():
        buffer.write(test.questions.map((q) => q.question).join(','));
      case SelectedSchreibenTest():
        buffer.write('task=${test.task.id}:${test.task.task}');
      case SelectedSprechenTest():
        buffer.write('thema=${test.thema};');
        buffer.write(test.aufgaben.map((a) => a.title).join(','));
    }
    buffer.write('}|');
  }
  return buffer.toString();
}

/// Asserts an Attempt is internally valid: exactly the Teile that `teilSpecs`
/// defines, in order, each carrying a non-empty selected Test of the variant
/// expected for its Section.
void _assertInternallyValid(MockTestAttempt attempt) {
  final specs = MockTestStructure.teilSpecs;
  expect(attempt.teile.length, specs.length);
  for (var i = 0; i < specs.length; i++) {
    final spec = specs[i];
    final teil = attempt.teile[i];
    expect(teil.section, spec.section);
    expect(teil.teilNumber, spec.teilNumber);

    final test = teil.test;
    switch (spec.section) {
      case MockSection.leseverstehen:
      case MockSection.sprachbausteine:
        expect(test, isA<SelectedLesenTest>());
        expect((test as SelectedLesenTest).questions, isNotEmpty);
      case MockSection.hoerverstehen:
        expect(test, isA<SelectedHorenTest>());
        expect((test as SelectedHorenTest).questions, isNotEmpty);
      case MockSection.schriftlicherAusdruck:
        expect(test, isA<SelectedSchreibenTest>());
      case MockSection.muendlicherAusdruck:
        expect(test, isA<SelectedSprechenTest>());
        expect((test as SelectedSprechenTest).aufgaben, isNotEmpty);
    }
  }
}

void main() {
  // Inputs: two independent seeds drive two independent random sources; the
  // counts list varies how many Tests each required Teil exposes across runs.
  // listWithLength(12, ...) gives one count slot per teilSpec; `_testCount`
  // guards against any length surprises.
  Glados3<int, int, List<int>>(
    any.int,
    any.int,
    any.listWithLength(12, any.intInRange(1, 5)),
    ExploreConfig(numRuns: 100),
  ).test(
    'two independent rng sources yield internally valid, independent attempts',
    (seedA, seedB, counts) {
      final lesen = _buildLesen(counts);
      final horen = _buildHoren(counts);
      final schreiben = _buildSchreiben(counts);
      final sprechen = _buildSprechen(counts);

      final attemptA = MockTestAssembler.assemble(
        rng: Random(seedA),
        lesen: lesen,
        horen: horen,
        schreiben: schreiben,
        sprechen: sprechen,
      );
      final attemptB = MockTestAssembler.assemble(
        rng: Random(seedB),
        lesen: lesen,
        horen: horen,
        schreiben: schreiben,
        sprechen: sprechen,
      );

      // Each attempt is internally valid on its own.
      _assertInternallyValid(attemptA);
      _assertInternallyValid(attemptB);

      // The two attempts are distinct object graphs: separate MockTestAttempt
      // instances built from independent selection passes, sharing no MockTeil
      // instance. (A fresh Assembly per attempt — Requirement 4.4.)
      expect(identical(attemptA, attemptB), isFalse);
      for (final teilA in attemptA.teile) {
        for (final teilB in attemptB.teile) {
          expect(identical(teilA, teilB), isFalse);
        }
      }

      // Snapshot B's content before touching A.
      final descBBefore = _describe(attemptB);
      final descABefore = _describe(attemptA);

      // Drive a navigation + answering sequence through A's controller. Actions
      // are derived deterministically from the two seeds so the run is
      // reproducible. None of this may affect attemptB or its controller.
      final controllerA = MockTestController(attempt: attemptA);
      final controllerB = MockTestController(attempt: attemptB);
      final actionRng = Random(seedA ^ (seedB << 1) ^ 0x5f3759df);
      for (var step = 0; step < 25; step++) {
        switch (actionRng.nextInt(3)) {
          case 0:
            controllerA.next();
          case 1:
            controllerA.previous();
          default:
            final teilIndex = controllerA.currentTeilIndex;
            controllerA.selectAnswer(AnswerKey(teilIndex, 0), 'choice-$step');
        }
      }

      // Independence: attemptB's content is untouched, and B's controller never
      // received any of A's answers.
      expect(_describe(attemptB), descBBefore,
          reason: 'navigating/answering attempt A must not alter attempt B');
      expect(controllerB.answers, isEmpty,
          reason: 'answers recorded on A must not leak into B');

      // Immutability: attemptA's content is also unchanged by navigation —
      // only position and answers (held off the attempt) ever change.
      expect(_describe(attemptA), descABefore,
          reason: 'navigation must not alter the assembled content of A');

      // Fresh selection: re-running assembly with a fresh Random of the same
      // seed reproduces the identical selection, confirming each attempt is the
      // product of its own self-contained, repeatable selection pass.
      final attemptAReplay = MockTestAssembler.assemble(
        rng: Random(seedA),
        lesen: lesen,
        horen: horen,
        schreiben: schreiben,
        sprechen: sprechen,
      );
      expect(_describe(attemptAReplay), descABefore,
          reason: 'a fresh Assembly with the same seed is reproducible');
    },
  );
}
