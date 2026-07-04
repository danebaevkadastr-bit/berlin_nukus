// Feature: b1-mock-test, Property 4: Lesen auxiliary content alignment
//
// *For any* random seed, when a selected Leseverstehen or Sprachbausteine Test
// corresponds to group index `g`, the Test's presented text equals
// `testTexts[g]` (or the Teil's `sharedText` when no per-test text exists) and
// its presented image equals `testImages[g]` when such an entry exists.
//
// Validates: Requirements 3.4
//
// Strategy: drive `MockTestAssembler.assemble` with synthetic `LesenLevel`
// sources whose questions encode their owning group index in the `prompt`
// (`q-<teilNumber>-<group>`). The Hören/Schreiben/Sprechen sources default to
// the shipped B1 content so the whole attempt assembles. After assembly we
// recover the selected group `g` directly from the selected Test's question
// content, then assert that the carried `text`/`imageUrl` align with the source
// `testTexts`/`testImages`/`sharedText` for that exact group. A seeded `Random`
// makes both the synthetic source shape and the selection deterministic, and
// glados explores ≥100 seeds (its default), covering the per-test-text,
// shared-text-fallback, with-image, and no-image variants.

import 'dart:math';

import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect;

/// The teilNumbers sourced from `lesenB1` (Leseverstehen 1–3, Sprachbausteine
/// 4–5).
const _lesenTeilNumbers = [1, 2, 3, 4, 5];

/// Returns the official chunk size for a Lesen Teil, as the assembler uses it.
int _chunkSizeFor(int teilNumber) {
  final spec = MockTestStructure.teilSpecs.firstWhere(
    (s) =>
        (s.section == MockSection.leseverstehen ||
            s.section == MockSection.sprachbausteine) &&
        s.teilNumber == teilNumber,
  );
  return spec.questionsPerTest;
}

/// Builds a synthetic `LesenLevel` whose questions encode their owning group
/// index. The shape (group count per Teil, presence of per-test texts/images)
/// is derived deterministically from [structSeed] so different seeds exercise
/// the per-test-text, shared-text-fallback, with-image, and no-image variants.
LesenLevel _buildSyntheticLesen(int structSeed) {
  final r = Random(structSeed);
  final teile = <LesenTeil>[];

  for (final tn in _lesenTeilNumbers) {
    final chunkSize = _chunkSizeFor(tn);
    final groupCount = 1 + r.nextInt(4); // 1..4 selectable Tests
    final hasTexts = r.nextBool();
    final hasImages = r.nextBool();

    final questions = <LesenQuestion>[];
    for (var g = 0; g < groupCount; g++) {
      for (var k = 0; k < chunkSize; k++) {
        questions.add(LesenQuestion(
          prompt: 'q-$tn-$g',
          passage: 'p-$tn-$g-$k',
          options: const ['A', 'B'],
          correctAnswer: 'A',
        ));
      }
    }

    teile.add(LesenTeil(
      teilNumber: tn,
      sharedText: 'shared-$tn',
      testTexts:
          hasTexts ? [for (var g = 0; g < groupCount; g++) 'text-$tn-$g'] : null,
      testImages:
          hasImages ? [for (var g = 0; g < groupCount; g++) 'img-$tn-$g'] : null,
      questionsPerTest: chunkSize,
      questions: questions,
    ));
  }

  return LesenLevel(level: 'B1', teile: teile);
}

/// Recovers the group index encoded in a selected Test's questions.
int _groupOf(SelectedLesenTest test) {
  final parts = test.questions.first.prompt.split('-'); // ['q', tn, g]
  return int.parse(parts[2]);
}

void main() {
  Glados<int>(any.int).test(
    'Property 4: selected Lesen Test text/image align with its group',
    (seed) {
      final lesen = _buildSyntheticLesen(seed);
      final attempt = MockTestAssembler.assemble(rng: Random(seed), lesen: lesen);

      final lesenTeile = attempt.teile.where(
        (t) =>
            t.section == MockSection.leseverstehen ||
            t.section == MockSection.sprachbausteine,
      );

      for (final teil in lesenTeile) {
        final selected = teil.test as SelectedLesenTest;
        final src =
            lesen.teile.firstWhere((t) => t.teilNumber == teil.teilNumber);

        // Recover which group was selected from the question content.
        final g = _groupOf(selected);

        // The selected Test is exactly one whole group: every question belongs
        // to group g and the chunk has the official size.
        expect(selected.questions.length, _chunkSizeFor(teil.teilNumber));
        for (final q in selected.questions) {
          expect(q.prompt, 'q-${teil.teilNumber}-$g');
        }

        // Text aligns with testTexts[g], falling back to sharedText when there
        // is no per-test text for that group.
        final expectedText =
            (src.testTexts != null && g < src.testTexts!.length)
                ? src.testTexts![g]
                : src.sharedText;
        expect(selected.text, expectedText);

        // Image aligns with testImages[g] when such an entry exists, else null.
        final expectedImage =
            (src.testImages != null && g < src.testImages!.length)
                ? src.testImages![g]
                : null;
        expect(selected.imageUrl, expectedImage);
      }
    },
  );
}
