// Feature: b1-mock-test, Property 11: Result totals, pass thresholds, and unavailable sections
//
// For any completed Attempt, the written-part total equals the sum of the
// written Section points (bounded by 225) and the oral-part total equals the
// oral Section points (bounded by 75); the written and oral pass flags are true
// exactly when their points reach 60% of the available points; and when an AI
// evaluation is missing for a Section, that Section is flagged unavailable while
// every other Section still receives a valid score.
//
// Validates: Requirements 8.3, 9.1, 9.3, 9.4
//
// Strategy: glados drives a seed and a per-Teil "tests available" bound. From
// those we deterministically build *synthetic* source models and assemble a
// full attempt (one Test per teilSpec). A second, derived RNG decides, for
// every auto-graded Question, whether it is answered correctly, answered
// incorrectly, or left unanswered, and decides whether each AI Section's
// evaluation is present (a parseable "X/20" score) or missing/unparseable. We
// then call MockTestScorer.score and assert the totals, the bounds, the 60%
// pass thresholds (pinned to the concrete 135/225 and 45/75 boundaries), and
// the unavailable-section flagging — while confirming every auto-graded Section
// is still scored.

import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_recording_models.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_scorer.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect;

/// Bundles the synthetic sources used for one assembly.
class _Sources {
  final LesenLevel lesen;
  final HorenLevel horen;
  final List<SchreibenTask> schreiben;
  final SprechenLevel sprechen;

  _Sources(this.lesen, this.horen, this.schreiben, this.sprechen);
}

const _autoGraded = [
  MockSection.leseverstehen,
  MockSection.sprachbausteine,
  MockSection.hoerverstehen,
];

void main() {
  // Feature: b1-mock-test, Property 11: Result totals, pass thresholds, and unavailable sections
  Glados2<int, int>(
    any.int,
    any.intInRange(1, 5), // upper bound on tests per Teil: 1..4
    ExploreConfig(numRuns: 100), // minimum 100 iterations
  ).test('Property 11: totals, pass thresholds, and unavailable sections',
      (seed, maxTests) {
    final sources = _buildSources(seed, maxTests);

    final attempt = MockTestAssembler.assemble(
      rng: Random(seed),
      lesen: sources.lesen,
      horen: sources.horen,
      schreiben: sources.schreiben,
      sprechen: sources.sprechen,
    );

    // A separate RNG decides answers and AI availability, independent of the
    // RNG the assembler consumed.
    final dr = Random(seed ^ 0x27d4eb2f);

    // ── Build the student's auto-graded answers ──────────────────────────────
    final answers = <AnswerKey, String>{};
    for (var teilIndex = 0; teilIndex < attempt.teile.length; teilIndex++) {
      final test = attempt.teile[teilIndex].test;
      final List<({String correct, List<String> options})> qs;
      switch (test) {
        case SelectedLesenTest(:final questions):
          qs = [
            for (final q in questions)
              (correct: q.correctAnswer, options: q.options)
          ];
        case SelectedHorenTest(:final questions):
          qs = [
            for (final q in questions)
              (correct: q.correctAnswer, options: q.options)
          ];
        case SelectedSchreibenTest():
        case SelectedSprechenTest():
          continue; // AI sections carry no auto-gradable answers
      }
      for (var q = 0; q < qs.length; q++) {
        final roll = dr.nextInt(3); // 0 correct, 1 incorrect, 2 unanswered
        if (roll == 0) {
          answers[AnswerKey(teilIndex, q)] = qs[q].correct;
        } else if (roll == 1) {
          answers[AnswerKey(teilIndex, q)] = qs[q]
              .options
              .firstWhere((o) => o != qs[q].correct, orElse: () => qs[q].correct);
        }
        // roll == 2 leaves the question unanswered
      }
    }

    // ── Decide AI-section availability ───────────────────────────────────────
    final schreibenAvailable = dr.nextBool();
    final oralAvailable = dr.nextBool();

    final String? schreibenFeedback = schreibenAvailable
        ? 'Gute Arbeit. Jami: ${dr.nextInt(21)}/20'
        : (dr.nextBool() ? null : 'Keine Bewertung verfügbar');

    // Per-Teil Sprechen evaluations (Teil 1 = 15, Teil 2 = 30, Teil 3 = 30).
    // When the oral part is "available" every Teil carries a parseable "X/20"
    // score; otherwise no Teil is parseable (empty map, or an unparseable
    // score), so the Section is flagged unavailable.
    final Map<int, AudioEvaluation> sprechenEvaluations = oralAvailable
        ? {
            for (final teil in const [1, 2, 3])
              teil: AudioEvaluation(
                score: '${dr.nextInt(21)}/20',
                pronunciation: '',
                fluency: '',
                grammar: '',
                content: '',
                overall: '',
              ),
          }
        : (dr.nextBool()
            ? <int, AudioEvaluation>{}
            : {
                3: const AudioEvaluation(
                  score: 'keine Bewertung',
                  pronunciation: '',
                  fluency: '',
                  grammar: '',
                  content: '',
                  overall: '',
                ),
              });

    final result = MockTestScorer.score(
      attempt: attempt,
      answers: answers,
      schreibenFeedback: schreibenFeedback,
      sprechenEvaluations: sprechenEvaluations,
    );

    // ── Maxima are the official, fixed TELC B1 values ────────────────────────
    expect(result.writtenMax, 225);
    expect(result.oralMax, 75);

    // ── Every auto-graded Section is always scored with a valid value ────────
    for (final s in _autoGraded) {
      expect(result.sectionPoints.containsKey(s), isTrue,
          reason: '$s must always be scored');
      expect(result.unavailableSections.contains(s), isFalse,
          reason: 'auto-graded $s is never flagged unavailable');
      expect(result.sectionPoints[s]!,
          inInclusiveRange(0, MockTestStructure.sectionMaxPoints[s]!));
    }

    // ── AI Section availability flagging (Req 8.3) ───────────────────────────
    _expectAiSection(result, MockSection.schriftlicherAusdruck,
        available: schreibenAvailable);
    _expectAiSection(result, MockSection.muendlicherAusdruck,
        available: oralAvailable);

    // ── Written total equals the sum of written Section points, bounded by 225
    var expectedWritten = 0;
    for (final s in MockTestStructure.writtenSections) {
      expectedWritten += result.sectionPoints[s] ?? 0;
    }
    expect(result.writtenPoints, expectedWritten);
    expect(result.writtenPoints, inInclusiveRange(0, 225));

    // ── Oral total equals the oral Section points, bounded by 75 ─────────────
    final expectedOral =
        result.sectionPoints[MockTestStructure.oralSection] ?? 0;
    expect(result.oralPoints, expectedOral);
    expect(result.oralPoints, inInclusiveRange(0, 75));

    // ── Pass flags hold exactly at 60% of the available points ───────────────
    // 60% of 225 == 135; 60% of 75 == 45.
    expect(result.writtenPassed, result.writtenPoints >= 135);
    expect(result.oralPassed, result.oralPoints >= 45);
  });
}

/// Asserts an AI Section is scored within bounds when [available], and is
/// flagged unavailable (and absent from sectionPoints) otherwise.
void _expectAiSection(
  MockResult result,
  MockSection section, {
  required bool available,
}) {
  if (available) {
    expect(result.unavailableSections.contains(section), isFalse,
        reason: '$section has a parseable evaluation, so it is available');
    expect(result.sectionPoints.containsKey(section), isTrue);
    expect(result.sectionPoints[section]!,
        inInclusiveRange(0, MockTestStructure.sectionMaxPoints[section]!));
  } else {
    expect(result.unavailableSections.contains(section), isTrue,
        reason: '$section has no parseable evaluation, so it is unavailable');
    expect(result.sectionPoints.containsKey(section), isFalse,
        reason: 'an unavailable $section is omitted from sectionPoints');
  }
}

// ── Synthetic source builders ────────────────────────────────────────────────
//
// Built deterministically from (seed, maxTests). Each chunked Teil holds an
// exact multiple of its chunk size so every group is full and selectable.

_Sources _buildSources(int seed, int maxTests) {
  final br = Random(seed.hashCode ^ 0x5bd1e995);
  int testCount() => 1 + br.nextInt(maxTests); // 1..maxTests

  final lesen = LesenLevel(
    level: 'B1',
    teile: [
      for (final spec in MockTestStructure.teilSpecs.where((s) =>
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
