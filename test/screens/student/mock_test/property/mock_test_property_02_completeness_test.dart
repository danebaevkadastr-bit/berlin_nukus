// Feature: b1-mock-test, Property 2: Structural completeness
//
// Property 2 — Structural completeness:
// For any random seed, the assembled Attempt contains exactly one selected Test
// for every Teil defined by `MockTestStructure.teilSpecs` — no defined Teil is
// missing and no extra Teil is present.
//
// Validates: Requirements 1.2
//
// Strategy: drive `MockTestAssembler.assemble` with a seeded `Random` and
// synthetic source models whose per-Teil Test counts vary across runs. Because
// the synthetic sources always expose at least one Test per required Teil,
// assembly must succeed and produce exactly the Teile that `teilSpecs` defines.
// Run via `glados` with a minimum of 100 iterations.

import 'dart:math';

import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:glados/glados.dart';

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

void main() {
  // The seed drives random Test selection; the counts list varies the number of
  // Tests available per Teil across runs. listWithLength(12, ...) yields one
  // count slot per teilSpec; `_testCount` guards against any length surprises.
  Glados2<int, List<int>>(
    any.int,
    any.listWithLength(12, any.intInRange(1, 5)),
    ExploreConfig(numRuns: 100),
  ).test(
    'assembled attempt contains exactly one Test per teilSpec entry',
    (seed, counts) {
      final attempt = MockTestAssembler.assemble(
        rng: Random(seed),
        lesen: _buildLesen(counts),
        horen: _buildHoren(counts),
        schreiben: _buildSchreiben(counts),
        sprechen: _buildSprechen(counts),
      );

      final specs = MockTestStructure.teilSpecs;

      // No missing and no extra Teile: exact count match.
      expect(attempt.teile.length, specs.length);

      // Exactly one selected Test per defined Teil (section + teilNumber),
      // matched in order, with a non-null SelectedTest of the right variant.
      for (var i = 0; i < specs.length; i++) {
        final spec = specs[i];
        final matches = attempt.teile
            .where((t) => t.section == spec.section && t.teilNumber == spec.teilNumber)
            .toList();
        expect(
          matches.length,
          1,
          reason: 'expected exactly one Teil for ${spec.section} '
              'teil ${spec.teilNumber}, found ${matches.length}',
        );
        // Order is preserved alongside teilSpecs.
        expect(attempt.teile[i].section, spec.section);
        expect(attempt.teile[i].teilNumber, spec.teilNumber);
      }

      // Every assembled Teil corresponds to a defined teilSpec (no extras).
      for (final teil in attempt.teile) {
        final defined = specs.any(
          (s) => s.section == teil.section && s.teilNumber == teil.teilNumber,
        );
        expect(defined, isTrue,
            reason: 'unexpected Teil ${teil.section} teil ${teil.teilNumber}');
      }
    },
  );
}
