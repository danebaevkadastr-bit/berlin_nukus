// B1 Mock Test — pure, deterministic assembler.
//
// The assembler performs the feature's defining behavior: **test-level random
// selection**. It is intentionally pure and side-effect-free, deriving all
// randomness from an injected [Random] so the selection logic is deterministic
// given a seed and therefore directly property-testable.
//
// This file provides the two low-level selection helpers — [chunk] and
// [selectIndex] — and the [assemble] entry point that builds a complete,
// frozen attempt by selecting one Test per Teil from the existing B1 source
// data models.
//
// Pure Dart: no Flutter or I/O dependency so the domain core can be imported
// and property-tested in isolation.

import 'dart:math';

import '../../../../models/schreiben_task.dart';
import '../../../../utils/schreiben_tasks_b1.dart';
import '../../horen/horen_data.dart';
import '../../lesen/lesen_data.dart';
import '../../sprechen/sprechen_data.dart';
import 'mock_test_attempt.dart';
import 'mock_test_exceptions.dart';
import 'mock_test_structure.dart';

/// Pure helpers and the entry point for assembling a frozen mock-test attempt
/// from the existing B1 source data models.
class MockTestAssembler {
  const MockTestAssembler._();

  /// Builds one frozen [MockTestAttempt] by selecting a single Test, at random,
  /// for every Teil defined by [MockTestStructure.teilSpecs].
  ///
  /// All randomness is derived from the injected [rng], so assembly is
  /// deterministic given a seed and therefore directly property-testable.
  /// Production callers pass `Random()` / `Random.secure()`; tests pass a
  /// seeded `Random`.
  ///
  /// Sources default to the app's shipped B1 content (`lesenB1`, `horenB1`,
  /// `schreibenTasksB1`, `sprechenB1`); tests may inject synthetic sources.
  /// (The defaults are resolved in the body because `horenB1` and
  /// `schreibenTasksB1` are not compile-time constants.)
  ///
  /// The returned [MockTestAttempt.teile] is already ordered by official
  /// Section order then ascending `teilNumber` — the same order as
  /// [MockTestStructure.teilSpecs].
  ///
  /// Throws [MockAssemblyException] (carrying the offending [MockSection] and
  /// `teilNumber`) when any required Teil exposes zero Tests in its source.
  ///
  /// _Requirements: 1.1, 1.3, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 3.5,
  /// 5.1, 5.2, 5.3, 12.1, 12.2_
  static MockTestAttempt assemble({
    required Random rng,
    LesenLevel? lesen,
    HorenLevel? horen,
    List<SchreibenTask>? schreiben,
    SprechenLevel? sprechen,
  }) {
    final lesenSource = lesen ?? lesenB1;
    final horenSource = horen ?? horenB1;
    final schreibenSource = schreiben ?? schreibenTasksB1;
    final sprechenSource = sprechen ?? sprechenB1;

    final teile = <MockTeil>[];

    for (final spec in MockTestStructure.teilSpecs) {
      final SelectedTest test;
      switch (spec.section) {
        case MockSection.leseverstehen:
        case MockSection.sprachbausteine:
          test = _selectLesen(rng, spec, lesenSource);
        case MockSection.hoerverstehen:
          test = _selectHoren(rng, spec, horenSource);
        case MockSection.schriftlicherAusdruck:
          test = _selectSchreiben(rng, spec, schreibenSource);
        case MockSection.muendlicherAusdruck:
          test = _selectSprechen(rng, spec, sprechenSource);
      }

      teile.add(MockTeil(
        section: spec.section,
        teilNumber: spec.teilNumber,
        test: test,
      ));
    }

    return MockTestAttempt(teile);
  }

  /// Selects one Leseverstehen / Sprachbausteine Test for [spec] from [lesen].
  ///
  /// Chunks the matching `LesenTeil`'s flat `questions` by
  /// [TeilSpec.questionsPerTest], picks group `g`, and carries the per-test
  /// text (`testTexts[g]`, falling back to `sharedText`) and image
  /// (`testImages[g]`) that align with that group.
  static SelectedLesenTest _selectLesen(
    Random rng,
    TeilSpec spec,
    LesenLevel lesen,
  ) {
    final teil = _firstWhereOrNull(
      lesen.teile,
      (t) => t.teilNumber == spec.teilNumber,
    );
    final groups =
        teil == null ? const [] : chunk(teil.questions, spec.questionsPerTest);
    if (teil == null || groups.isEmpty) {
      throw MockAssemblyException(
        section: spec.section,
        teilNumber: spec.teilNumber,
      );
    }

    final g = selectIndex(rng, groups.length);
    final text = _elementAtOrNull(teil.testTexts, g) ?? teil.sharedText;
    final imageUrl = _elementAtOrNull(teil.testImages, g);

    return SelectedLesenTest(
      questions: groups[g],
      text: text,
      imageUrl: imageUrl,
    );
  }

  /// Selects one Hörverstehen Test for [spec] from [horen] by chunking the
  /// matching `HorenTeil`'s flat `questions` by [TeilSpec.questionsPerTest].
  /// Audio is intrinsic to each `HorenQuestion`.
  static SelectedHorenTest _selectHoren(
    Random rng,
    TeilSpec spec,
    HorenLevel horen,
  ) {
    final teil = _firstWhereOrNull(
      horen.teile,
      (t) => t.teilNumber == spec.teilNumber,
    );
    final groups =
        teil == null ? const [] : chunk(teil.questions, spec.questionsPerTest);
    if (teil == null || groups.isEmpty) {
      throw MockAssemblyException(
        section: spec.section,
        teilNumber: spec.teilNumber,
      );
    }

    final g = selectIndex(rng, groups.length);
    return SelectedHorenTest(questions: groups[g]);
  }

  /// Selects one Schriftlicher Ausdruck Test: the available Tests are the
  /// elements of [schreiben] (each a whole `SchreibenTask`); picks one.
  static SelectedSchreibenTest _selectSchreiben(
    Random rng,
    TeilSpec spec,
    List<SchreibenTask> schreiben,
  ) {
    if (schreiben.isEmpty) {
      throw MockAssemblyException(
        section: spec.section,
        teilNumber: spec.teilNumber,
      );
    }
    final index = selectIndex(rng, schreiben.length);
    return SelectedSchreibenTest(task: schreiben[index]);
  }

  /// Selects one Mündlicher Ausdruck Test for [spec] from [sprechen].
  ///
  /// When the matching `SprechenTeil` exposes `tests`, those `SprechenTest`s
  /// are the selectable Tests (pick one). Otherwise its single `aufgaben`
  /// group is the only Test.
  static SelectedSprechenTest _selectSprechen(
    Random rng,
    TeilSpec spec,
    SprechenLevel sprechen,
  ) {
    final teil = _firstWhereOrNull(
      sprechen.teile,
      (t) => t.teilNumber == spec.teilNumber,
    );

    if (teil != null && teil.tests.isNotEmpty) {
      final index = selectIndex(rng, teil.tests.length);
      final test = teil.tests[index];
      return SelectedSprechenTest(thema: test.thema, aufgaben: test.aufgaben);
    }

    if (teil != null && teil.aufgaben.isNotEmpty) {
      return SelectedSprechenTest(aufgaben: teil.aufgaben);
    }

    throw MockAssemblyException(
      section: spec.section,
      teilNumber: spec.teilNumber,
    );
  }

  /// Returns the first element of [items] matching [test], or `null` when none
  /// match. (Avoids `firstWhere`'s throw-on-empty behavior.)
  static T? _firstWhereOrNull<T>(List<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Returns `list[index]` when [list] is non-null and [index] is in range;
  /// otherwise `null`.
  static String? _elementAtOrNull(List<String>? list, int index) {
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  /// Splits a Teil's flat [questions] list into contiguous Tests of [perTest]
  /// items each.
  ///
  /// Each returned inner list preserves the source order of [questions] and
  /// contains a verbatim slice — questions are never reordered, dropped, or
  /// combined across Tests. Slices are contiguous and non-overlapping, so
  /// concatenating the result in order reproduces [questions].
  ///
  /// If the length of [questions] is not an exact multiple of [perTest], the
  /// final Test holds the remaining (fewer than [perTest]) items.
  ///
  /// [perTest] must be greater than zero. Whole-unit Teile (Schriftlicher
  /// Ausdruck / Mündlicher Ausdruck) do not chunk a flat list and therefore do
  /// not use this helper.
  ///
  /// _Requirements: 2.1, 2.3_
  static List<List<T>> chunk<T>(List<T> questions, int perTest) {
    if (perTest <= 0) {
      throw ArgumentError.value(
        perTest,
        'perTest',
        'chunk size must be greater than zero',
      );
    }

    final groups = <List<T>>[];
    for (var start = 0; start < questions.length; start += perTest) {
      final end = min(start + perTest, questions.length);
      groups.add(questions.sublist(start, end));
    }
    return groups;
  }

  /// Selects one index uniformly at random in the range `[0, count)`.
  ///
  /// When [count] is exactly `1` this always returns `0`, so a Teil that
  /// exposes a single Test always selects that Test. For larger [count] every
  /// valid index has a non-zero, uniform probability of being chosen, so every
  /// available Test is reachable across the seed space.
  ///
  /// [count] must be greater than zero; a Teil with zero Tests cannot be
  /// assembled and is handled by the caller.
  ///
  /// _Requirements: 2.1, 2.3, 2.4_
  static int selectIndex(Random rng, int count) {
    if (count <= 0) {
      throw ArgumentError.value(
        count,
        'count',
        'cannot select an index from zero options',
      );
    }
    if (count == 1) return 0;
    return rng.nextInt(count);
  }
}
