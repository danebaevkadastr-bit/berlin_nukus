// B1 Mock Test — pure scorer and result model.
//
// The scorer turns a completed attempt (the assembled [MockTestAttempt], the
// student's auto-graded answers, and the AI results captured during the
// attempt) into a [MockResult]: per-Section points normalized to the official
// TELC B1 maxima, the written/oral totals and maxima, and the written/oral
// pass flags evaluated at the 60% Pass_Threshold.
//
// All functions are pure and side-effect-free so the scoring rules are
// deterministic and directly property-testable.
//
// Pure Dart: no Flutter or I/O dependency so the domain core can be imported
// and property-tested in isolation.

import 'package:flutter/foundation.dart';

import '../../sprechen/sprechen_recording_models.dart';
import 'mock_test_attempt.dart';
import 'mock_test_structure.dart';

/// TELC B1 rasmiy baho (Note), umumiy ballga qarab. Imtihon topshirilmasa
/// (biror qism 60% dan past bo'lsa) [nichtBestanden].
///
/// Rasmiy chegaralar (Gesamtpunktzahl 300 dan):
/// - 300–270: sehr gut
/// - 269,5–240: gut
/// - 239,5–210: befriedigend
/// - 209,5–180: ausreichend
enum MockGrade {
  sehrGut,
  gut,
  befriedigend,
  ausreichend,
  nichtBestanden,
}

/// The end-of-attempt scoring summary.
///
/// [sectionPoints] holds the normalized points for every Section that could be
/// scored. An AI Section whose evaluation could not be completed is omitted
/// from [sectionPoints] and listed in [unavailableSections] instead; every
/// other Section still receives a valid score.
@immutable
class MockResult {
  /// Normalized points per Section (TELC B1 maxima). Unavailable AI Sections
  /// are absent from this map.
  final Map<MockSection, int> sectionPoints;

  /// AI Sections whose evaluation could not be completed.
  final Set<MockSection> unavailableSections;

  /// Sum of the written-part Section points (bounded by [writtenMax]).
  final int writtenPoints;

  /// Total available written-part points (225).
  final int writtenMax;

  /// Oral-part Section points (bounded by [oralMax]).
  final int oralPoints;

  /// Total available oral-part points (75).
  final int oralMax;

  MockResult({
    required Map<MockSection, int> sectionPoints,
    required Set<MockSection> unavailableSections,
    required this.writtenPoints,
    required this.writtenMax,
    required this.oralPoints,
    required this.oralMax,
  })  : sectionPoints = Map.unmodifiable(sectionPoints),
        unavailableSections = Set.unmodifiable(unavailableSections);

  /// Whether the written part met the 60% Pass_Threshold.
  bool get writtenPassed => writtenPoints >= 0.6 * writtenMax;

  /// Whether the oral part met the 60% Pass_Threshold.
  bool get oralPassed => oralPoints >= 0.6 * oralMax;

  /// Umumiy ball (yozma + og'zaki), maksimal 300.
  int get totalPoints => writtenPoints + oralPoints;

  /// Umumiy maksimal ball (225 + 75 = 300).
  int get totalMax => writtenMax + oralMax;

  /// Imtihon topshirildimi. TELC qoidasi: HAM yozma HAM og'zaki qism
  /// alohida-alohida kamida 60% (135 va 45 ball) to'plashi SHART. Faqat
  /// umumiy 180 ball yetarli emas.
  bool get passed => writtenPassed && oralPassed;

  /// TELC B1 rasmiy bahosi. Imtihon topshirilmasa [MockGrade.nichtBestanden].
  /// Topshirilsa umumiy ballga qarab beriladi (topshirilgan bo'lsa jami har
  /// doim >= 180 bo'ladi, chunki 135 + 45 = 180).
  MockGrade get grade {
    if (!passed) return MockGrade.nichtBestanden;
    final t = totalPoints;
    if (t >= 270) return MockGrade.sehrGut;
    if (t >= 240) return MockGrade.gut;
    if (t >= 210) return MockGrade.befriedigend;
    return MockGrade.ausreichend;
  }
}

/// Pure scoring helpers and the [score] entry point for a completed attempt.
class MockTestScorer {
  const MockTestScorer._();

  /// The Sections scored automatically against each Question's `correctAnswer`.
  static const List<MockSection> autoGradedSections = [
    MockSection.leseverstehen,
    MockSection.sprachbausteine,
    MockSection.hoerverstehen,
  ];

  /// Counts the correctly answered Questions among those presented.
  ///
  /// [questions] is the ordered list of presented Questions, each carrying its
  /// `correct` answer. [answers] maps a Question's index to the student's
  /// selected option (`null`, or a missing key, means unanswered). An
  /// unanswered Question is always counted as incorrect.
  ///
  /// The returned count is always within `[0, questions.length]`.
  ///
  /// _Requirements: 7.1, 7.2, 7.3_
  static int autoGradeCount(
    List<({String correct})> questions,
    Map<int, String?> answers,
  ) {
    var count = 0;
    for (var i = 0; i < questions.length; i++) {
      final selected = answers[i];
      if (selected != null && selected == questions[i].correct) {
        count++;
      }
    }
    return count;
  }

  /// Linearly normalizes a [correct] count out of [total] to the `[0, max]`
  /// range.
  ///
  /// Returns `0` when [total] is zero or negative. Returns `0` when [correct]
  /// is `0`, returns [max] when [correct] equals [total], and is monotonic
  /// non-decreasing in [correct]. The result is always clamped to `[0, max]`.
  ///
  /// _Requirements: 9.2_
  static int normalize(int correct, int total, int max) {
    if (total <= 0 || max <= 0) return 0;
    final raw = (correct / total) * max;
    return raw.round().clamp(0, max);
  }

  /// Parses an `"X/Y"` style AI score into a fraction in the range it implies
  /// (`X / Y`).
  ///
  /// The fraction may appear anywhere within [rawScore] (for example the
  /// `Jami: 15/20` rubric at the end of Schreiben feedback, or a bare `"16/20"`
  /// Sprechen score). Returns `null` when no fraction is present, when the
  /// denominator is zero, or when the value cannot be parsed.
  static double? parseAiFraction(String? rawScore) {
    if (rawScore == null) return null;
    final fractionRe =
        RegExp(r'(\d+(?:[.,]\d+)?)\s*/\s*(\d+(?:[.,]\d+)?)');

    // The Schreiben feedback contains several "X/Y" fragments (e.g. the word
    // count line "So'zlar soni: 85 / 80" and the per-criterion rubric), so we
    // must NOT take the first match. Prefer the explicit total ("Jami: X/Y");
    // otherwise fall back to the LAST fraction, which is the final score line
    // in both the Schreiben rubric and a bare Sprechen score ("16/20").
    final jamiMatch = RegExp(
      r'jami[^\d/]*(\d+(?:[.,]\d+)?)\s*/\s*(\d+(?:[.,]\d+)?)',
      caseSensitive: false,
    ).firstMatch(rawScore);

    final RegExpMatch? match;
    if (jamiMatch != null) {
      match = jamiMatch;
    } else {
      final all = fractionRe.allMatches(rawScore).toList();
      match = all.isEmpty ? null : all.last;
    }
    if (match == null) return null;

    final numerator = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    final denominator = double.tryParse(match.group(2)!.replaceAll(',', '.'));
    if (numerator == null || denominator == null || denominator == 0) {
      return null;
    }
    return numerator / denominator;
  }

  /// Scores a completed [attempt].
  ///
  /// Auto-graded Sections (Leseverstehen, Sprachbausteine, Hörverstehen) are
  /// scored by comparing each recorded answer in [answers] against the
  /// Question's `correctAnswer`, then normalizing to the Section's TELC maximum.
  /// Schriftlicher Ausdruck is scored from [schreibenFeedback] and Mündlicher
  /// Ausdruck from the per-Teil [sprechenEvaluations] (each Teil scaled to its
  /// official maximum, then summed); when an AI result is missing or its score
  /// is unparseable, the Section is flagged unavailable while every other
  /// Section is still scored.
  ///
  /// _Requirements: 7.1, 7.2, 7.3, 8.3, 9.1, 9.2, 9.3, 9.4_
  static MockResult score({
    required MockTestAttempt attempt,
    required Map<AnswerKey, String> answers,
    String? schreibenFeedback,
    Map<int, AudioEvaluation> sprechenEvaluations = const {},
  }) {
    final sectionPoints = <MockSection, int>{};
    final unavailable = <MockSection>{};

    // ── Auto-graded sections ────────────────────────────────────────────────
    for (final section in autoGradedSections) {
      var correct = 0;
      var total = 0;
      for (var teilIndex = 0; teilIndex < attempt.teile.length; teilIndex++) {
        final teil = attempt.teile[teilIndex];
        if (teil.section != section) continue;
        final correctAnswers = _correctAnswersOf(teil.test);
        for (var q = 0; q < correctAnswers.length; q++) {
          total++;
          final selected = answers[AnswerKey(teilIndex, q)];
          if (selected != null && selected == correctAnswers[q]) {
            correct++;
          }
        }
      }
      sectionPoints[section] =
          normalize(correct, total, MockTestStructure.sectionMaxPoints[section]!);
    }

    // ── Schriftlicher Ausdruck (AI) ──────────────────────────────────────────
    _scoreAiSection(
      section: MockSection.schriftlicherAusdruck,
      fraction: parseAiFraction(schreibenFeedback),
      sectionPoints: sectionPoints,
      unavailable: unavailable,
    );

    // ── Mündlicher Ausdruck (AI) — har Teil alohida (15/30/30) ───────────────
    final oral = oralPointsFrom(sprechenEvaluations);
    if (oral == null) {
      unavailable.add(MockSection.muendlicherAusdruck);
    } else {
      sectionPoints[MockSection.muendlicherAusdruck] = oral;
    }

    // ── Totals ───────────────────────────────────────────────────────────────
    var writtenPoints = 0;
    var writtenMax = 0;
    for (final section in MockTestStructure.writtenSections) {
      writtenPoints += sectionPoints[section] ?? 0;
      writtenMax += MockTestStructure.sectionMaxPoints[section]!;
    }
    final oralPoints = sectionPoints[MockTestStructure.oralSection] ?? 0;
    final oralMax =
        MockTestStructure.sectionMaxPoints[MockTestStructure.oralSection]!;

    return MockResult(
      sectionPoints: sectionPoints,
      unavailableSections: unavailable,
      writtenPoints: writtenPoints,
      writtenMax: writtenMax,
      oralPoints: oralPoints,
      oralMax: oralMax,
    );
  }

  /// Computes the Mündlicher Ausdruck total from the per-Teil evaluations.
  ///
  /// Each Teil's `"X/Y"` score is parsed to a fraction and scaled to that
  /// Teil's official maximum ([MockTestStructure.sprechenTeilMax]: Teil 1 = 15,
  /// Teil 2 = 30, Teil 3 = 30). A Teil without a parseable evaluation
  /// contributes 0 points. Returns `null` only when **no** Teil has a parseable
  /// evaluation (so the Section is flagged unavailable); otherwise the summed
  /// points, clamped to the 75-point Section maximum.
  static int? oralPointsFrom(Map<int, AudioEvaluation> sprechenEvaluations) {
    var points = 0;
    var any = false;
    MockTestStructure.sprechenTeilMax.forEach((teilNumber, teilMax) {
      final fraction = parseAiFraction(sprechenEvaluations[teilNumber]?.score);
      if (fraction != null) {
        any = true;
        points += (fraction * teilMax).round();
      }
    });
    if (!any) return null;
    final oralMax =
        MockTestStructure.sectionMaxPoints[MockSection.muendlicherAusdruck]!;
    return points.clamp(0, oralMax);
  }

  /// Records the normalized points for an AI Section, or flags it unavailable
  /// when [fraction] is `null` (missing or unparseable evaluation).
  static void _scoreAiSection({
    required MockSection section,
    required double? fraction,
    required Map<MockSection, int> sectionPoints,
    required Set<MockSection> unavailable,
  }) {
    if (fraction == null) {
      unavailable.add(section);
      return;
    }
    final max = MockTestStructure.sectionMaxPoints[section]!;
    sectionPoints[section] = (fraction * max).round().clamp(0, max);
  }

  /// The ordered `correctAnswer` values of an auto-graded selected Test. AI
  /// Tests (Schreiben / Sprechen) have no auto-gradable Questions.
  static List<String> _correctAnswersOf(SelectedTest test) {
    switch (test) {
      case SelectedLesenTest(:final questions):
        return [for (final q in questions) q.correctAnswer];
      case SelectedHorenTest(:final questions):
        return [for (final q in questions) q.correctAnswer];
      case SelectedSchreibenTest():
      case SelectedSprechenTest():
        return const [];
    }
  }
}
