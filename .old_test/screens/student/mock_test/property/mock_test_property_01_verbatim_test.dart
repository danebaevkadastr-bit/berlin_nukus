// Feature: b1-mock-test, Property 1: Whole-unit verbatim selection
//
// For any random seed, the selected Test for every Teil consists of exactly one
// contiguous group of Questions taken verbatim — same Question objects, same
// order — from that Teil's source data model, with no Questions added, removed,
// reordered, or combined across Tests.
//
// Validates: Requirements 1.1, 1.3, 2.2, 3.1, 3.2, 3.3, 3.5
//
// Strategy: glados drives a seed and a per-Teil "tests available" bound. From
// those we deterministically build *synthetic* source models (LesenLevel,
// HorenLevel, List<SchreibenTask>, SprechenLevel) whose Question/Test objects
// are all distinct instances, then call MockTestAssembler.assemble with a
// seeded Random over those exact sources. Because every source object is a
// unique instance, "verbatim" is checked by object identity: each selected
// Test must be element-wise `identical` to exactly one contiguous source group.

import 'dart:math';

import 'package:core/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect;

/// Bundles the synthetic sources used for one assembly so the property body can
/// verify the assembled attempt against the exact objects that fed it.
class _Sources {
  final LesenLevel lesen;
  final HorenLevel horen;
  final List<SchreibenTask> schreiben;
  final SprechenLevel sprechen;

  _Sources(this.lesen, this.horen, this.schreiben, this.sprechen);
}

void main() {
  // Feature: b1-mock-test, Property 1: Whole-unit verbatim selection
  Glados2<int, int>(
    any.int,
    any.intInRange(1, 5), // upper bound on tests per Teil: 1..4
    ExploreConfig(numRuns: 100), // minimum 100 iterations
  ).test('Property 1: whole-unit verbatim selection', (seed, maxTests) {
    final sources = _buildSources(seed, maxTests);

    final attempt = MockTestAssembler.assemble(
      rng: Random(seed),
      lesen: sources.lesen,
      horen: sources.horen,
      schreiben: sources.schreiben,
      sprechen: sources.sprechen,
    );

    // The assembler emits one Teil per spec, in spec order.
    expect(attempt.teile.length, MockTestStructure.teilSpecs.length);

    for (var i = 0; i < attempt.teile.length; i++) {
      final spec = MockTestStructure.teilSpecs[i];
      final teil = attempt.teile[i];
      _verifyTeil(spec, teil, sources);
    }
  });
}

// ── Verification ────────────────────────────────────────────────────────────

void _verifyTeil(TeilSpec spec, MockTeil teil, _Sources sources) {
  switch (spec.section) {
    case MockSection.leseverstehen:
    case MockSection.sprachbausteine:
      final test = teil.test as SelectedLesenTest;
      final source = _lesenTeil(sources.lesen, spec.teilNumber);
      final groups =
          MockTestAssembler.chunk(source.questions, spec.questionsPerTest);
      _expectMatchesExactlyOneGroup(test.questions, groups);

    case MockSection.hoerverstehen:
      final test = teil.test as SelectedHorenTest;
      final source = _horenTeil(sources.horen, spec.teilNumber);
      final groups =
          MockTestAssembler.chunk(source.questions, spec.questionsPerTest);
      _expectMatchesExactlyOneGroup(test.questions, groups);

    case MockSection.schriftlicherAusdruck:
      final test = teil.test as SelectedSchreibenTest;
      // The selected task must be exactly one of the source tasks (verbatim,
      // not synthesized).
      final matches =
          sources.schreiben.where((t) => identical(t, test.task)).length;
      expect(matches, 1,
          reason: 'Schreiben task must be exactly one verbatim source task');

    case MockSection.muendlicherAusdruck:
      final test = teil.test as SelectedSprechenTest;
      final source = _sprechenTeil(sources.sprechen, spec.teilNumber);
      final candidateGroups = <List<SprechenAufgabe>>[
        if (source.tests.isNotEmpty)
          for (final t in source.tests) t.aufgaben
        else
          source.aufgaben,
      ];
      _expectMatchesExactlyOneGroup(test.aufgaben, candidateGroups);
  }
}

/// Asserts [selected] is element-wise `identical` to exactly one of [groups]
/// — i.e. a verbatim, in-order, uncombined copy of a single source group.
void _expectMatchesExactlyOneGroup<T>(
  List<T> selected,
  List<List<T>> groups,
) {
  expect(selected, isNotEmpty, reason: 'a selected Test is never empty');

  final matchCount =
      groups.where((g) => _identicalInOrder(selected, g)).length;
  expect(matchCount, 1,
      reason: 'selected questions must equal exactly one contiguous source '
          'group, verbatim and in order, with no items added, removed, '
          'reordered, or combined across Tests');
}

/// True when [a] and [b] hold the same object instances in the same order.
bool _identicalInOrder<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!identical(a[i], b[i])) return false;
  }
  return true;
}

LesenTeil _lesenTeil(LesenLevel level, int teilNumber) =>
    level.teile.firstWhere((t) => t.teilNumber == teilNumber);

HorenTeil _horenTeil(HorenLevel level, int teilNumber) =>
    level.teile.firstWhere((t) => t.teilNumber == teilNumber);

SprechenTeil _sprechenTeil(SprechenLevel level, int teilNumber) =>
    level.teile.firstWhere((t) => t.teilNumber == teilNumber);

// ── Synthetic source builders ────────────────────────────────────────────────
//
// Built deterministically from (seed, maxTests). Every Question/Test object is
// a fresh, distinct instance so identity checks unambiguously prove verbatim
// selection. Each chunked Teil holds an exact multiple of its chunk size, so
// every group is full and selection can match a whole group.

_Sources _buildSources(int seed, int maxTests) {
  // A separate builder RNG so source shape varies independently of the seed the
  // assembler consumes.
  final br = Random(seed.hashCode ^ 0x5bd1e995);
  int testCount() => 1 + br.nextInt(maxTests); // 1..maxTests

  final lesen = LesenLevel(
    level: 'B1',
    teile: [
      for (final spec in MockTestStructure.teilSpecs
          .where((s) =>
              s.section == MockSection.leseverstehen ||
              s.section == MockSection.sprachbausteine))
        _buildLesenTeil(spec.teilNumber, spec.questionsPerTest, testCount()),
    ],
  );

  final horen = HorenLevel(
    level: 'B1',
    teile: [
      for (final spec in MockTestStructure.teilSpecs
          .where((s) => s.section == MockSection.hoerverstehen))
        _buildHorenTeil(spec.teilNumber, spec.questionsPerTest, testCount()),
    ],
  );

  final schreiben = <SchreibenTask>[
    for (var i = 0; i < testCount(); i++) _buildSchreibenTask(i),
  ];

  final sprechen = SprechenLevel(
    level: 'B1',
    teile: [
      for (final spec in MockTestStructure.teilSpecs
          .where((s) => s.section == MockSection.muendlicherAusdruck))
        _buildSprechenTeil(spec.teilNumber, testCount(), br),
    ],
  );

  return _Sources(lesen, horen, schreiben, sprechen);
}

LesenTeil _buildLesenTeil(int teilNumber, int perTest, int tests) {
  final total = perTest * tests;
  return LesenTeil(
    teilNumber: teilNumber,
    questionsPerTest: perTest,
    testTexts: [for (var g = 0; g < tests; g++) 'L$teilNumber-text-$g'],
    testImages: [for (var g = 0; g < tests; g++) 'L$teilNumber-img-$g'],
    questions: [
      for (var q = 0; q < total; q++)
        LesenQuestion(
          passage: 'L$teilNumber-q$q-passage',
          prompt: 'L$teilNumber-q$q',
          options: const ['a', 'b', 'c'],
          correctAnswer: 'a',
        ),
    ],
  );
}

HorenTeil _buildHorenTeil(int teilNumber, int perTest, int tests) {
  final total = perTest * tests;
  return HorenTeil(
    teilNumber: teilNumber,
    questions: [
      for (var q = 0; q < total; q++)
        HorenQuestion(
          audioTitle: 'H$teilNumber-q$q',
          audioUrl: 'https://example.test/h$teilNumber-q$q.mp3',
          question: 'H$teilNumber-q$q',
          options: const ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
    ],
  );
}

SchreibenTask _buildSchreibenTask(int i) => SchreibenTask(
      id: i,
      task: 'task-$i',
      points: ['p$i-1', 'p$i-2', 'p$i-3', 'p$i-4'],
      style: 'formal',
      minWords: 80,
      level: 'B1',
      letter: 'letter-$i',
    );

SprechenTeil _buildSprechenTeil(int teilNumber, int tests, Random br) {
  // Teil 2 may expose multiple `tests`; the others expose a single `aufgaben`
  // group. Randomly let Teil 2 fall back to the aufgaben-only shape too, so
  // both selection branches are exercised across the seed space.
  final useTests = teilNumber == 2 && br.nextBool();

  if (useTests) {
    return SprechenTeil(
      teilNumber: teilNumber,
      title: 'S$teilNumber',
      description: 'S$teilNumber-desc',
      tests: [
        for (var g = 0; g < tests; g++)
          SprechenTest(
            thema: 'S$teilNumber-thema-$g',
            aufgaben: [
              _buildSprechenAufgabe(teilNumber, g, 0),
              _buildSprechenAufgabe(teilNumber, g, 1),
            ],
          ),
      ],
    );
  }

  return SprechenTeil(
    teilNumber: teilNumber,
    title: 'S$teilNumber',
    description: 'S$teilNumber-desc',
    aufgaben: [
      _buildSprechenAufgabe(teilNumber, 0, 0),
      _buildSprechenAufgabe(teilNumber, 0, 1),
    ],
  );
}

SprechenAufgabe _buildSprechenAufgabe(int teilNumber, int group, int idx) =>
    SprechenAufgabe(
      title: 'S$teilNumber-g$group-a$idx',
      instruction: 'instruction-$teilNumber-$group-$idx',
      keywords: const ['k1', 'k2'],
      examples: const ['e1'],
    );
