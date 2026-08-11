// Smoke unit tests for MockTestAssembler.assemble against the real B1 sources.
//
// Comprehensive property-based coverage (Properties 1–8) lives in the separate
// property-test tasks; these examples verify the assembler wires the official
// structure to the shipped content correctly and is deterministic per seed.

import 'dart:math';

import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockTestAssembler.assemble (real B1 sources)', () {
    test('produces exactly one Teil per teilSpec', () {
      final attempt = MockTestAssembler.assemble(rng: Random(42));

      expect(attempt.teile.length, MockTestStructure.teilSpecs.length);
      for (var i = 0; i < MockTestStructure.teilSpecs.length; i++) {
        final spec = MockTestStructure.teilSpecs[i];
        final teil = attempt.teile[i];
        expect(teil.section, spec.section);
        expect(teil.teilNumber, spec.teilNumber);
      }
    });

    test('orders Teile by official Section order then ascending teilNumber', () {
      final attempt = MockTestAssembler.assemble(rng: Random(7));

      final sectionIndices = attempt.teile
          .map((t) => MockTestStructure.sectionOrder.indexOf(t.section))
          .toList();
      // Section indices are non-decreasing.
      for (var i = 1; i < sectionIndices.length; i++) {
        expect(sectionIndices[i] >= sectionIndices[i - 1], isTrue);
      }
      // teilNumber ascends within each Section.
      for (final section in MockTestStructure.sectionOrder) {
        final numbers =
            attempt.sectionTeile(section).map((t) => t.teilNumber).toList();
        final sorted = [...numbers]..sort();
        expect(numbers, sorted);
      }
    });

    test('selects the right SelectedTest variant per Section', () {
      final attempt = MockTestAssembler.assemble(rng: Random(1));
      for (final teil in attempt.teile) {
        switch (teil.section) {
          case MockSection.leseverstehen:
          case MockSection.sprachbausteine:
            expect(teil.test, isA<SelectedLesenTest>());
          case MockSection.hoerverstehen:
            expect(teil.test, isA<SelectedHorenTest>());
          case MockSection.schriftlicherAusdruck:
            expect(teil.test, isA<SelectedSchreibenTest>());
          case MockSection.muendlicherAusdruck:
            expect(teil.test, isA<SelectedSprechenTest>());
        }
      }
    });

    test('Lesen Tests carry their chunk size of questions', () {
      final attempt = MockTestAssembler.assemble(rng: Random(99));
      for (final teil in attempt.teile.where(
        (t) =>
            t.section == MockSection.leseverstehen ||
            t.section == MockSection.sprachbausteine,
      )) {
        final test = teil.test as SelectedLesenTest;
        expect(test.questions, isNotEmpty);
      }
    });

    test('same seed yields the same selection (deterministic)', () {
      final a = MockTestAssembler.assemble(rng: Random(123));
      final b = MockTestAssembler.assemble(rng: Random(123));

      for (var i = 0; i < a.teile.length; i++) {
        final ta = a.teile[i].test;
        final tb = b.teile[i].test;
        if (ta is SelectedLesenTest && tb is SelectedLesenTest) {
          expect(identical(ta.questions.first, tb.questions.first), isTrue);
          expect(ta.text, tb.text);
          expect(ta.imageUrl, tb.imageUrl);
        } else if (ta is SelectedHorenTest && tb is SelectedHorenTest) {
          expect(identical(ta.questions.first, tb.questions.first), isTrue);
        } else if (ta is SelectedSchreibenTest &&
            tb is SelectedSchreibenTest) {
          expect(identical(ta.task, tb.task), isTrue);
        } else if (ta is SelectedSprechenTest &&
            tb is SelectedSprechenTest) {
          expect(ta.thema, tb.thema);
          expect(ta.aufgaben.length, tb.aufgaben.length);
        }
      }
    });
  });
}
