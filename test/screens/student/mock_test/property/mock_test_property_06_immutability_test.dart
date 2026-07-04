// Feature: b1-mock-test, Property 6: Attempt immutability
//
// Property 6 (design.md): For any assembled Attempt and any sequence of
// navigation and answering operations, the selected Tests and their Questions
// remain identical to the moment of assembly (re-reading any Teil yields the
// same Questions in the same order).
//
// Validates: Requirements 4.1, 4.2
//
// Strategy: glados drives a seed (which feeds the assembler's selection), a
// per-Teil "tests available" count list (so the source shape varies across
// runs), and a list of navigation/answering actions. From those we build
// synthetic B1 source models whose Question/Test objects are all distinct
// instances, assemble one frozen attempt, and snapshot — by object identity —
// the exact Question/Aufgabe instances and their order for every Teil. We then
// drive the generated action sequence through a MockTestController (mixing
// next/previous/selectAnswer) and afterwards re-read every Teil, asserting each
// still exposes the very same Question instances in the very same order as at
// assembly time. Identity (not just equality) is checked so any replacement,
// reordering, addition, or removal of content would be detected.

import 'dart:math';

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

/// An identity-based snapshot of one Teil's selected content: the concrete
/// objects (and their order) that make up the selected Test. Captured at
/// assembly time and re-compared after navigation/answering.
class _TeilSnapshot {
  final SelectedTest test;
  final List<Object> items; // Question/Aufgabe instances, in order
  final Object? aux; // Schreiben task / Lesen text+image marker

  _TeilSnapshot(this.test, this.items, this.aux);
}

void main() {
  // Inputs:
  //  * seed       — drives the assembler's selection RNG.
  //  * counts     — one slot per teilSpec; varies how many Tests each Teil
  //                 exposes so different selections are exercised.
  //  * actions    — a sequence of navigation/answer actions (0 = next,
  //                 1 = previous, 2 = answer current Teil's first question).
  Glados3<int, List<int>, List<int>>(
    any.int,
    any.listWithLength(12, any.intInRange(1, 5)),
    any.list(any.intInRange(0, 3)),
    ExploreConfig(numRuns: 100), // minimum 100 iterations
  ).test(
    'Property 6: assembled content is immutable across navigation and answering',
    (seed, counts, actions) {
      final attempt = MockTestAssembler.assemble(
        rng: Random(seed),
        lesen: _buildLesen(counts),
        horen: _buildHoren(counts),
        schreiben: _buildSchreiben(counts),
        sprechen: _buildSprechen(counts),
      );

      // Snapshot every Teil's selected content by object identity, in order,
      // at the moment of assembly.
      final snapshots = [
        for (final teil in attempt.teile) _snapshot(teil.test),
      ];

      // Drive the generated navigation + answering sequence. Answering must
      // never change content; navigation only moves the position.
      final controller = MockTestController(attempt: attempt);
      var answerSalt = 0;
      for (final action in actions) {
        switch (action) {
          case 0:
            controller.next();
          case 1:
            controller.previous();
          default:
            controller.selectAnswer(
              AnswerKey(controller.currentTeilIndex, 0),
              'choice-${answerSalt++}',
            );
        }
      }

      // Re-read every Teil and assert its selected content is identical — same
      // object instances, same order, same auxiliary content — as at assembly.
      expect(attempt.teile.length, snapshots.length);
      for (var i = 0; i < attempt.teile.length; i++) {
        final after = _snapshot(attempt.teile[i].test);
        final before = snapshots[i];

        // Same selected-Test instance (the attempt never swaps it out).
        expect(identical(after.test, before.test), isTrue,
            reason: 'Teil $i selected Test instance changed after navigation');

        // Same questions/aufgaben, in the same order, by identity.
        expect(after.items.length, before.items.length,
            reason: 'Teil $i question count changed after navigation');
        for (var q = 0; q < before.items.length; q++) {
          expect(identical(after.items[q], before.items[q]), isTrue,
              reason: 'Teil $i question $q changed (identity/order) after '
                  'navigation');
        }

        // Auxiliary content (Lesen text+image, Schreiben task) unchanged.
        expect(after.aux, before.aux,
            reason: 'Teil $i auxiliary content changed after navigation');
      }
    },
  );
}

/// Builds an identity snapshot of a selected Test: its ordered Question/Aufgabe
/// instances plus a marker for any auxiliary content.
_TeilSnapshot _snapshot(SelectedTest test) {
  switch (test) {
    case SelectedLesenTest():
      return _TeilSnapshot(
        test,
        List<Object>.from(test.questions),
        'text=${test.text};img=${test.imageUrl}',
      );
    case SelectedHorenTest():
      return _TeilSnapshot(test, List<Object>.from(test.questions), null);
    case SelectedSchreibenTest():
      return _TeilSnapshot(test, const [], test.task);
    case SelectedSprechenTest():
      return _TeilSnapshot(
        test,
        List<Object>.from(test.aufgaben),
        'thema=${test.thema}',
      );
  }
}

// ── Synthetic source builders ────────────────────────────────────────────────
//
// Built deterministically from the generated `counts`. Every Question/Test
// object is a fresh, distinct instance so identity checks unambiguously prove
// content has not been replaced. Each chunked Teil holds an exact multiple of
// its chunk size and always exposes at least one Test, so every required Teil
// can be assembled.

LesenLevel _buildLesen(List<int> counts) {
  const perTestByTeil = {1: 5, 2: 5, 3: 10, 4: 10, 5: 10};
  final teile = <LesenTeil>[];
  for (var teilNumber = 1; teilNumber <= 5; teilNumber++) {
    final perTest = perTestByTeil[teilNumber]!;
    final nTests = _testCount(counts, teilNumber - 1);
    teile.add(LesenTeil(
      teilNumber: teilNumber,
      questionsPerTest: perTest,
      sharedText: 'shared-$teilNumber',
      testTexts: [for (var t = 0; t < nTests; t++) 'text-$teilNumber-$t'],
      testImages: [for (var t = 0; t < nTests; t++) 'img-$teilNumber-$t'],
      questions: [
        for (var q = 0; q < perTest * nTests; q++)
          LesenQuestion(
            prompt: 'L$teilNumber-Q$q',
            options: const ['a', 'b', 'c'],
            correctAnswer: 'a',
          ),
      ],
    ));
  }
  return LesenLevel(level: 'B1', teile: teile);
}

HorenLevel _buildHoren(List<int> counts) {
  const perTestByTeil = {1: 5, 2: 10, 3: 5};
  final teile = <HorenTeil>[];
  for (var teilNumber = 1; teilNumber <= 3; teilNumber++) {
    final perTest = perTestByTeil[teilNumber]!;
    final nTests = _testCount(counts, 5 + (teilNumber - 1));
    teile.add(HorenTeil(
      teilNumber: teilNumber,
      questions: [
        for (var q = 0; q < perTest * nTests; q++)
          HorenQuestion(
            audioTitle: 'H$teilNumber-A$q',
            audioUrl: 'audio-$teilNumber-$q.mp3',
            question: 'H$teilNumber-Q$q',
            options: const ['a', 'b', 'c'],
            correctAnswer: 'a',
          ),
      ],
    ));
  }
  return HorenLevel(level: 'B1', teile: teile);
}

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
