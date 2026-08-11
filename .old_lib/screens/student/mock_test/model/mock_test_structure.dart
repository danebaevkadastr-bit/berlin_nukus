// Official TELC Deutsch B1 exam structure for the B1 Mock Test feature.
//
// This file is the single source of truth that maps the official TELC B1 layout
// onto the app's existing B1 source data models (`lesenB1`, `horenB1`,
// `schreibenTasksB1`, `sprechenB1`). It holds **no** question content — only
// which source Teile feed which Section, the official presentation order, the
// official point values, and the per-Teil test chunk sizes.
//
// Pure Dart: this file intentionally has no Flutter or I/O dependency so the
// domain core can be imported and property-tested in isolation.

/// One of the five TELC B1 exam areas, in their conceptual grouping.
///
/// Leseverstehen and Sprachbausteine are sourced from `lesenB1` (teile 1–3 and
/// 4–5 respectively); Hörverstehen from `horenB1`; Schriftlicher Ausdruck from
/// `schreibenTasksB1`; Mündlicher Ausdruck from `sprechenB1`.
enum MockSection {
  /// `lesenB1` teile 1–3 — 75 points.
  leseverstehen,

  /// `lesenB1` teile 4–5 — 30 points.
  sprachbausteine,

  /// `horenB1` teile 1–3 — 75 points.
  hoerverstehen,

  /// `schreibenTasksB1` (single Teil) — 45 points.
  schriftlicherAusdruck,

  /// `sprechenB1` teile 1–3 — 75 points.
  muendlicherAusdruck,
}

/// Describes one Teil the exam must contain and how to slice it out of its
/// source data model.
///
/// [questionsPerTest] is the contiguous chunk size used to split a source
/// Teil's flat question list into selectable Tests. A value of `0` marks a
/// whole-unit Teil (Schriftlicher Ausdruck / Mündlicher Ausdruck), where the
/// selectable Tests are the source elements themselves rather than chunks of a
/// flat question list.
class TeilSpec {
  final MockSection section;

  /// Matches the `teilNumber` field on the corresponding source Teil.
  final int teilNumber;

  /// Contiguous chunk size; `0` means whole-unit selection.
  final int questionsPerTest;

  const TeilSpec({
    required this.section,
    required this.teilNumber,
    required this.questionsPerTest,
  });
}

/// The official TELC B1 exam definition: order, points, and Teil layout.
class MockTestStructure {
  const MockTestStructure._();

  /// Total examination value across all sections.
  static const int totalPoints = 300;

  /// Total number of auto-graded questions across every Teil. Whole-unit
  /// Schriftlicher/Mündlicher Ausdruck Teile have no questions and contribute
  /// zero. (5+5+10 + 10+10 + 5+10+5 = 60.)
  static int get totalQuestionCount =>
      teilSpecs.fold(0, (sum, spec) => sum + spec.questionsPerTest);

  /// The item count shown for [section] on overview screens: the auto-graded
  /// question count for question Sections, or the number of Teile/tasks for
  /// whole-unit Sections (Schriftlicher/Mündlicher Ausdruck).
  static int questionCountForSection(MockSection section) {
    final specs = teilSpecs.where((s) => s.section == section).toList();
    final autoGraded =
        specs.fold(0, (sum, s) => sum + s.questionsPerTest);
    return autoGraded > 0 ? autoGraded : specs.length;
  }

  /// Official TELC B1 point value for each Section.
  static const Map<MockSection, int> sectionMaxPoints = {
    MockSection.leseverstehen: 75,
    MockSection.sprachbausteine: 30,
    MockSection.hoerverstehen: 75,
    MockSection.schriftlicherAusdruck: 45,
    MockSection.muendlicherAusdruck: 75,
  };

  /// Official TELC B1 Mündlicher Ausdruck point value per Teil:
  /// Teil 1 = 15, Teil 2 = 30, Teil 3 = 30 (jami 75). Har Teil alohida
  /// baholanadi va bahosi shu maksimumga moslashtiriladi.
  static const Map<int, int> sprechenTeilMax = {1: 15, 2: 30, 3: 30};

  /// Official presentation order (written part first, oral part last).
  static const List<MockSection> sectionOrder = [
    MockSection.leseverstehen,
    MockSection.sprachbausteine,
    MockSection.hoerverstehen,
    MockSection.schriftlicherAusdruck,
    MockSection.muendlicherAusdruck,
  ];

  /// The four written-part Sections (scored together against the written
  /// Pass_Threshold).
  static const Set<MockSection> writtenSections = {
    MockSection.leseverstehen,
    MockSection.sprachbausteine,
    MockSection.hoerverstehen,
    MockSection.schriftlicherAusdruck,
  };

  /// The single oral-part Section (scored against the oral Pass_Threshold).
  static const MockSection oralSection = MockSection.muendlicherAusdruck;

  /// Every Teil the exam must contain, already in official Section order and,
  /// within each Section, in ascending `teilNumber`.
  ///
  /// Chunk sizes mirror the existing section screens:
  /// - Lesen: teil 1 → 5, teil 2 → 5, teil 3 → 10 (Leseverstehen);
  ///   teil 4 → 10, teil 5 → 10 (Sprachbausteine).
  /// - Hören: teil 1 → 5, teil 2 → 10, teil 3 → 5.
  /// - Schreiben / Sprechen: `0` (whole-unit selection).
  static const List<TeilSpec> teilSpecs = [
    // ── Leseverstehen (lesenB1 teile 1–3) ──────────────────────────────────
    TeilSpec(
      section: MockSection.leseverstehen,
      teilNumber: 1,
      questionsPerTest: 5,
    ),
    TeilSpec(
      section: MockSection.leseverstehen,
      teilNumber: 2,
      questionsPerTest: 5,
    ),
    TeilSpec(
      section: MockSection.leseverstehen,
      teilNumber: 3,
      questionsPerTest: 10,
    ),

    // ── Sprachbausteine (lesenB1 teile 4–5) ────────────────────────────────
    TeilSpec(
      section: MockSection.sprachbausteine,
      teilNumber: 4,
      questionsPerTest: 10,
    ),
    TeilSpec(
      section: MockSection.sprachbausteine,
      teilNumber: 5,
      questionsPerTest: 10,
    ),

    // ── Hörverstehen (horenB1 teile 1–3) ───────────────────────────────────
    TeilSpec(
      section: MockSection.hoerverstehen,
      teilNumber: 1,
      questionsPerTest: 5,
    ),
    TeilSpec(
      section: MockSection.hoerverstehen,
      teilNumber: 2,
      questionsPerTest: 10,
    ),
    TeilSpec(
      section: MockSection.hoerverstehen,
      teilNumber: 3,
      questionsPerTest: 5,
    ),

    // ── Schriftlicher Ausdruck (schreibenTasksB1, single Teil) ─────────────
    TeilSpec(
      section: MockSection.schriftlicherAusdruck,
      teilNumber: 1,
      questionsPerTest: 0,
    ),

    // ── Mündlicher Ausdruck (sprechenB1 teile 1–3) ─────────────────────────
    TeilSpec(
      section: MockSection.muendlicherAusdruck,
      teilNumber: 1,
      questionsPerTest: 0,
    ),
    TeilSpec(
      section: MockSection.muendlicherAusdruck,
      teilNumber: 2,
      questionsPerTest: 0,
    ),
    TeilSpec(
      section: MockSection.muendlicherAusdruck,
      teilNumber: 3,
      questionsPerTest: 0,
    ),
  ];
}
