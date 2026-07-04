// Feature: b1-mock-test, Property 3: Valid and reachable random selection
//
// *For any* random seed and any Teil, the selected Test index lies within the
// range of Tests available for that Teil; when a Teil exposes exactly one Test
// that Test is always selected; and across the space of seeds every available
// Test index for a Teil is reachable.
//
// Validates: Requirements 2.1, 2.3, 2.4
//
// Code under test: MockTestAssembler.selectIndex and MockTestAssembler.assemble.
//
// Property-based tests use `glados` with a seeded `Random` and run a minimum of
// 100 iterations (the glados default `numRuns`). The pure selection helper
// `selectIndex` is exercised directly for the range/boundary/reachability
// facets, and `assemble` is exercised over synthetic multi-Test and
// single-Test sources to confirm the same guarantees hold end to end.

import 'dart:math';

import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:glados/glados.dart';

/// Extracts the synthetic group index `g` embedded in a marker string of the
/// form `grp<g>` (optionally followed by other text). Returns -1 when absent.
int groupOf(String marker) {
  final match = RegExp(r'grp(\d+)').firstMatch(marker);
  return match == null ? -1 : int.parse(match.group(1)!);
}

/// Builds a synthetic [LesenLevel] whose every Teil exposes exactly [k] Tests.
///
/// Chunk sizes mirror `MockTestStructure.teilSpecs` (teile 1–2 → 5, teil 3 → 10,
/// teile 4–5 → 10), so the assembler splits each Teil's flat question list into
/// exactly [k] contiguous Tests. Each Test's text/image and its questions carry
/// a `grp<g>` marker so the selected group index can be recovered.
LesenLevel synthLesen(int k) {
  LesenTeil teil(int n, int per) => LesenTeil(
        teilNumber: n,
        questionsPerTest: per,
        sharedText: 'shared$n',
        testTexts: [for (var g = 0; g < k; g++) 'grp$g'],
        testImages: [for (var g = 0; g < k; g++) 'grp${g}img'],
        questions: [
          for (var g = 0; g < k; g++)
            for (var i = 0; i < per; i++)
              LesenQuestion(
                prompt: 'grp$g#$i',
                options: const ['a', 'b'],
                correctAnswer: 'a',
              ),
        ],
      );
  return LesenLevel(
    level: 'B1',
    teile: [teil(1, 5), teil(2, 5), teil(3, 10), teil(4, 10), teil(5, 10)],
  );
}

/// Builds a synthetic [HorenLevel] whose every Teil exposes exactly [k] Tests
/// (teile 1 & 3 → 5 questions per Test, teil 2 → 10).
HorenLevel synthHoren(int k) {
  HorenTeil teil(int n, int per) => HorenTeil(
        teilNumber: n,
        questions: [
          for (var g = 0; g < k; g++)
            for (var i = 0; i < per; i++)
              HorenQuestion(
                audioTitle: 'audio',
                audioUrl: 'url',
                question: 'grp$g#$i',
                options: const ['a', 'b'],
                correctAnswer: 'a',
              ),
        ],
      );
  return HorenLevel(
    level: 'B1',
    teile: [teil(1, 5), teil(2, 10), teil(3, 5)],
  );
}

/// Builds a synthetic Schreiben source of exactly [k] Tests; each task's `id`
/// records its group index.
List<SchreibenTask> synthSchreiben(int k) => [
      for (var g = 0; g < k; g++)
        SchreibenTask(
          id: g,
          task: 'grp$g',
          points: const ['p'],
          style: 'formal',
          minWords: 50,
          level: 'B1',
          letter: 'L',
        ),
    ];

/// Builds a synthetic [SprechenLevel] whose every Teil exposes exactly [k]
/// Tests via `tests`; each test's `thema` records its group index.
SprechenLevel synthSprechen(int k) {
  SprechenTeil teil(int n) => SprechenTeil(
        teilNumber: n,
        title: 'title',
        description: 'desc',
        tests: [
          for (var g = 0; g < k; g++)
            SprechenTest(
              thema: 'grp$g',
              aufgaben: const [
                SprechenAufgabe(title: 'x', instruction: 'y'),
              ],
            ),
        ],
      );
  return SprechenLevel(level: 'B1', teile: [teil(1), teil(2), teil(3)]);
}

/// Recovers the selected group index for a Teil's [SelectedTest].
int selectedGroupIndex(SelectedTest test) {
  return switch (test) {
    SelectedLesenTest(:final text) => groupOf(text ?? ''),
    SelectedHorenTest(:final questions) => groupOf(questions.first.question),
    SelectedSchreibenTest(:final task) => task.id,
    SelectedSprechenTest(:final thema) => groupOf(thema ?? ''),
  };
}

void main() {
  group('Property 3: valid and reachable random selection (selectIndex)', () {
    // Single-Test boundary: a Teil exposing exactly one Test always selects it.
    Glados<int>(any.int).test(
      'selectIndex always returns 0 when there is exactly one Test',
      (seed) {
        expect(MockTestAssembler.selectIndex(Random(seed), 1), 0);
      },
    );

    // Validity: the selected index always lies within [0, count).
    Glados2<int, int>(any.int, any.int).test(
      'selectIndex returns an index within [0, count) for any count >= 1',
      (seed, rawCount) {
        final count = 1 + (rawCount.abs() % 50);
        final index = MockTestAssembler.selectIndex(Random(seed), count);
        expect(index, inInclusiveRange(0, count - 1));
      },
    );

    // Reachability: across the seed space every available index is reachable.
    Glados<int>(any.int).test(
      'every index in [0, count) is reachable across the seed space',
      (rawCount) {
        final count = 1 + (rawCount.abs() % 12);
        final rng = Random(0xC0FFEE);
        final seen = <int>{};
        // Far more draws than indices guarantees full coverage for a uniform
        // selector while keeping the test deterministic.
        final draws = count * 200 + 500;
        for (var i = 0; i < draws; i++) {
          seen.add(MockTestAssembler.selectIndex(rng, count));
        }
        expect(seen, {for (var g = 0; g < count; g++) g});
      },
    );
  });

  group('Property 3: valid and reachable random selection (assemble)', () {
    // Validity end to end: every Teil's selected Test index is within range of
    // the Tests available for that Teil.
    Glados2<int, int>(any.int, any.int).test(
      'assemble selects an in-range Test for every Teil',
      (seed, rawK) {
        final k = 2 + (rawK.abs() % 5); // 2..6 Tests per Teil
        final attempt = MockTestAssembler.assemble(
          rng: Random(seed),
          lesen: synthLesen(k),
          horen: synthHoren(k),
          schreiben: synthSchreiben(k),
          sprechen: synthSprechen(k),
        );

        expect(attempt.teile.length, MockTestStructure.teilSpecs.length);
        for (final teil in attempt.teile) {
          final g = selectedGroupIndex(teil.test);
          expect(
            g,
            inInclusiveRange(0, k - 1),
            reason: 'selected index out of range for '
                '${teil.section} Teil ${teil.teilNumber}',
          );
        }
      },
    );

    // Single-Test boundary end to end: when every Teil exposes exactly one
    // Test, assembly always selects that single Test (group index 0).
    Glados<int>(any.int).test(
      'assemble selects the single available Test when a Teil has one Test',
      (seed) {
        final attempt = MockTestAssembler.assemble(
          rng: Random(seed),
          lesen: synthLesen(1),
          horen: synthHoren(1),
          schreiben: synthSchreiben(1),
          sprechen: synthSprechen(1),
        );

        for (final teil in attempt.teile) {
          expect(
            selectedGroupIndex(teil.test),
            0,
            reason: 'expected the only Test for '
                '${teil.section} Teil ${teil.teilNumber}',
          );
        }
      },
    );
  });
}
