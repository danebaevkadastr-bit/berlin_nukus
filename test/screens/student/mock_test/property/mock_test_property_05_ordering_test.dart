// Feature: b1-mock-test, Property 5: Section and Teil ordering
//
// Property 5 (design.md): For any random seed, the Teile of the assembled
// Attempt appear grouped by Section in the official order (Leseverstehen,
// Sprachbausteine, Hörverstehen, Schriftlicher Ausdruck, Mündlicher Ausdruck)
// and, within each Section, in ascending `teilNumber`; consequently every
// written Section precedes the oral Section.
//
// Validates: Requirements 5.1, 5.2, 5.3
//
// The assembler chooses one Test per Teil at random, but ordering is invariant
// of that choice. To exercise the property across a varied input space we drive
// two dimensions through `glados`:
//   * `seed`      — feeds the injected `Random`, varying which Test is selected.
//   * `variation` — varies how many Tests each required Teil exposes, so the
//                   assembler runs against many differently-shaped sources.
// Every generated source still supplies all required Teile (teilNumbers
// 1–5 Lesen, 1–3 Hören, the single Schreiben list, 1–3 Sprechen) so assembly
// always succeeds and we can assert the ordering invariant.

import 'dart:math';

import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect;

/// Derives a Test count in `[1, 4]` for slot [slot] from the [variation] seed.
/// Each slot reads two bits, so distinct Teile vary independently.
int _countFor(int variation, int slot) => ((variation >> (slot * 2)) & 0x3) + 1;

/// Builds `n` placeholder [LesenQuestion]s.
List<LesenQuestion> _lesenQuestions(int n) => List.generate(
      n,
      (i) => LesenQuestion(
        prompt: 'frage $i',
        options: const ['a', 'b', 'c'],
        correctAnswer: 'a',
      ),
    );

/// Builds `n` placeholder [HorenQuestion]s.
List<HorenQuestion> _horenQuestions(int n) => List.generate(
      n,
      (i) => HorenQuestion(
        audioTitle: 'Aufgabe $i',
        audioUrl: 'audio://$i',
        question: 'frage $i',
        options: const ['Richtig', 'Falsch'],
        correctAnswer: 'Richtig',
      ),
    );

/// Builds a synthetic Lesen source whose Teile 1–5 each expose enough questions
/// to form the per-Teil number of Tests dictated by [variation].
LesenLevel _buildLesen(int variation) {
  // Chunk sizes match MockTestStructure.teilSpecs for the Lesen Teile.
  const perTest = {1: 5, 2: 5, 3: 10, 4: 10, 5: 10};
  final teile = <LesenTeil>[];
  for (final entry in perTest.entries) {
    final teilNumber = entry.key;
    final size = entry.value;
    final tests = _countFor(variation, teilNumber - 1); // slots 0..4
    teile.add(LesenTeil(
      teilNumber: teilNumber,
      questionsPerTest: size,
      questions: _lesenQuestions(size * tests),
    ));
  }
  return LesenLevel(level: 'B1', teile: teile);
}

/// Builds a synthetic Hören source whose Teile 1–3 each expose enough questions
/// to form the per-Teil number of Tests dictated by [variation].
HorenLevel _buildHoren(int variation) {
  const perTest = {1: 5, 2: 10, 3: 5};
  final teile = <HorenTeil>[];
  for (final entry in perTest.entries) {
    final teilNumber = entry.key;
    final size = entry.value;
    final tests = _countFor(variation, teilNumber + 4); // slots 5..7
    teile.add(HorenTeil(
      teilNumber: teilNumber,
      questions: _horenQuestions(size * tests),
    ));
  }
  return HorenLevel(level: 'B1', teile: teile);
}

/// Builds a synthetic Schreiben source with at least one Test.
List<SchreibenTask> _buildSchreiben(int variation) {
  final tests = _countFor(variation, 8); // slot 8
  return List.generate(
    tests,
    (i) => SchreibenTask(
      id: i,
      task: 'aufgabe $i',
      points: const ['p1', 'p2', 'p3', 'p4'],
      style: 'formell',
      minWords: 80,
      level: 'B1',
      letter: 'brief $i',
    ),
  );
}

/// Builds a synthetic Sprechen source: Teil 1 and Teil 3 expose a single
/// `aufgaben` group, Teil 2 exposes a varying number of `tests`.
SprechenLevel _buildSprechen(int variation) {
  SprechenAufgabe aufgabe(int i) =>
      SprechenAufgabe(title: 'thema $i', instruction: 'sprich $i');

  final teil2Tests = _countFor(variation, 9); // slot 9
  return SprechenLevel(
    level: 'B1',
    teile: [
      SprechenTeil(
        teilNumber: 1,
        title: 'Teil 1',
        description: '',
        aufgaben: [aufgabe(0)],
      ),
      SprechenTeil(
        teilNumber: 2,
        title: 'Teil 2',
        description: '',
        tests: List.generate(
          teil2Tests,
          (i) => SprechenTest(thema: 'thema $i', aufgaben: [aufgabe(i)]),
        ),
      ),
      SprechenTeil(
        teilNumber: 3,
        title: 'Teil 3',
        description: '',
        aufgaben: [aufgabe(2)],
      ),
    ],
  );
}

void main() {
  // Feature: b1-mock-test, Property 5: Section and Teil ordering.
  Glados2<int, int>(any.int, any.intInRange(0, 1 << 20)).test(
    'Property 5: Teile are grouped by official Section order, ascending '
    'teilNumber within a Section, written before oral',
    (seed, variation) {
      final attempt = MockTestAssembler.assemble(
        rng: Random(seed),
        lesen: _buildLesen(variation),
        horen: _buildHoren(variation),
        schreiben: _buildSchreiben(variation),
        sprechen: _buildSprechen(variation),
      );

      final teile = attempt.teile;
      expect(teile, isNotEmpty);

      // (5.1) Section grouping/order: the official-order index of each Teil's
      // Section is non-decreasing across the list, so Sections appear grouped
      // and in the official order with no interleaving.
      final sectionRank = teile
          .map((t) => MockTestStructure.sectionOrder.indexOf(t.section))
          .toList();
      for (final rank in sectionRank) {
        expect(rank, greaterThanOrEqualTo(0)); // every Section is recognised
      }
      for (var i = 1; i < sectionRank.length; i++) {
        expect(
          sectionRank[i],
          greaterThanOrEqualTo(sectionRank[i - 1]),
          reason: 'Sections must appear in non-decreasing official order',
        );
      }

      // (5.2) Within each Section, teilNumber is strictly ascending.
      for (final section in MockTestStructure.sectionOrder) {
        final numbers =
            attempt.sectionTeile(section).map((t) => t.teilNumber).toList();
        for (var i = 1; i < numbers.length; i++) {
          expect(
            numbers[i],
            greaterThan(numbers[i - 1]),
            reason: 'teilNumber must ascend within $section',
          );
        }
      }

      // (5.3) Every written Section precedes the single oral Section: the last
      // index of any written-Section Teil is before the first oral-Section Teil.
      final writtenIndices = <int>[];
      final oralIndices = <int>[];
      for (var i = 0; i < teile.length; i++) {
        final section = teile[i].section;
        if (MockTestStructure.writtenSections.contains(section)) {
          writtenIndices.add(i);
        } else if (section == MockTestStructure.oralSection) {
          oralIndices.add(i);
        }
      }
      expect(oralIndices, isNotEmpty);
      expect(writtenIndices, isNotEmpty);
      expect(
        writtenIndices.reduce(max),
        lessThan(oralIndices.reduce(min)),
        reason: 'all written Sections must precede the oral Section',
      );

      // The assembled order matches the canonical teilSpecs order exactly,
      // which is the concrete realisation of the ordering rule.
      expect(teile.length, MockTestStructure.teilSpecs.length);
      for (var i = 0; i < teile.length; i++) {
        expect(teile[i].section, MockTestStructure.teilSpecs[i].section);
        expect(teile[i].teilNumber, MockTestStructure.teilSpecs[i].teilNumber);
      }
    },
  );
}
