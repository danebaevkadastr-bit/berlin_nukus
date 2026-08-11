// Property test for the runner's Teil → Section view mapping.
//
// Feature: b1-mock-test-redesign, Property 5: Barcha Teile o'z Section
// ko'rinishiga to'liq xaritalanadi — For any assembled MockTestAttempt, visiting
// every Teil index in [0, teilCount) resolves the runner's Teil body to exactly
// the section view matching that Teil's SelectedTest subtype
// (SelectedLesenTest → LesenMockView, SelectedHorenTest → HorenMockView,
// SelectedSchreibenTest → SchreibenMockView, SelectedSprechenTest →
// SprechenMockView) with no unhandled case and no blank body.
//
// Validates: Requirements 9.1, 9.2, 9.3
//
// Strategy: glados drives a non-empty list of subtype codes (0..3) plus a seed.
// The codes determine, for each Teil, which SelectedTest subtype it carries; the
// seed deterministically fills the per-subtype exam content (questions / task /
// aufgaben). The resulting frozen MockTestAttempt therefore covers every
// possible ordering and mix of the four section types. For every Teil index in
// [0, teilCount) the test drives the controller to that index and resolves the
// runner's Teil body through `mockTeilViewFor` (the single source of truth the
// runner itself renders), then asserts the produced widget's runtime type equals
// exactly the section view for that Teil's subtype — never null, never a blank
// SizedBox. Resolving the body never pumps the heavy views (no audio / network /
// microphone), so the universal mapping is exercised purely. Runs at least 100
// iterations (glados default).

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test;

import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_review_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_runner_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/horen_mock_view.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/lesen_mock_view.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/schreiben_mock_view.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/sprechen_mock_view.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:core/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';

const _options = ['A', 'B', 'C', 'D'];

/// Builds a single [MockTeil] for the subtype identified by [code] (0..3),
/// using [rng] to fill its exam content. The [section]/[teilNumber] are chosen
/// to be plausible for the subtype but do not affect the view mapping (which is
/// driven solely by the [SelectedTest] subtype).
MockTeil _teilForCode(int code, Random rng) {
  switch (code & 3) {
    case 0:
      final qCount = 1 + rng.nextInt(5);
      return MockTeil(
        section: MockSection.leseverstehen,
        teilNumber: 1,
        test: SelectedLesenTest(
          questions: List.generate(
            qCount,
            (_) => LesenQuestion(
              prompt: 'Frage ${rng.nextInt(1000)}',
              options: _options,
              correctAnswer: _options[rng.nextInt(_options.length)],
            ),
          ),
        ),
      );
    case 1:
      final qCount = 1 + rng.nextInt(5);
      return MockTeil(
        section: MockSection.hoerverstehen,
        teilNumber: 1,
        test: SelectedHorenTest(
          questions: List.generate(
            qCount,
            (_) => HorenQuestion(
              audioTitle: 'Audio',
              audioUrl: 'https://example.test/a.mp3',
              question: 'Frage ${rng.nextInt(1000)}',
              options: _options,
              correctAnswer: _options[rng.nextInt(_options.length)],
            ),
          ),
        ),
      );
    case 2:
      return MockTeil(
        section: MockSection.schriftlicherAusdruck,
        teilNumber: 1,
        test: const SelectedSchreibenTest(
          task: SchreibenTask(
            id: 1,
            task: 'Schreiben Sie einen Brief.',
            points: ['Punkt 1', 'Punkt 2'],
            style: 'formell',
            minWords: 80,
            level: 'B1',
          ),
        ),
      );
    default:
      return MockTeil(
        section: MockSection.muendlicherAusdruck,
        teilNumber: 1,
        test: SelectedSprechenTest(
          aufgaben: const [
            SprechenAufgabe(
              title: 'Sich vorstellen',
              instruction: 'Stellen Sie sich vor.',
            ),
          ],
        ),
      );
  }
}

/// The section-view runtime type expected for the subtype identified by [code].
Type _expectedViewType(int code) {
  switch (code & 3) {
    case 0:
      return LesenMockView;
    case 1:
      return HorenMockView;
    case 2:
      return SchreibenMockView;
    default:
      return SprechenMockView;
  }
}

/// Builds a frozen attempt whose Teile carry the subtypes in [codes].
MockTestAttempt _buildAttempt(List<int> codes, Random rng) {
  return MockTestAttempt([for (final c in codes) _teilForCode(c, rng)]);
}

void main() {
  // Feature: b1-mock-test-redesign, Property 5: Barcha Teile o'z Section
  // ko'rinishiga to'liq xaritalanadi.
  Glados2<List<int>, int>(
    any.nonEmptyList(any.intInRange(0, 4)),
    any.int,
  ).test(
    'Property 5: every Teil index resolves to exactly the matching section view',
    (codes, seed) {
      final rng = Random(seed.abs());
      final attempt = _buildAttempt(codes, rng);
      final controller = MockTestController(attempt: attempt);

      expect(controller.teilCount, codes.length);

      for (var index = 0; index < controller.teilCount; index++) {
        // Drive the runner's cursor to this Teil, exactly as the overview drawer
        // would, then resolve the body the runner renders for it.
        controller.goToTeil(index);
        expect(controller.currentTeilIndex, index);

        final body = mockTeilViewFor(
          controller,
          controller.currentTeilIndex,
          activeQuestionIndex: 0,
        );

        // The body is never null/blank — every subtype is handled.
        expect(body, isNotNull);
        expect(body is SizedBox, isFalse,
            reason: 'the Teil body must never be a blank SizedBox');

        // The resolved widget is exactly the section view for this subtype.
        expect(
          body.runtimeType,
          _expectedViewType(codes[index]),
          reason: 'Teil $index (subtype code ${codes[index] & 3}) must map to '
              'its matching section view',
        );
      }
    },
  );

  // Explicit edge cases required by the property: a single attempt that contains
  // all four subtypes verifies the full mapping table and no unhandled case.
  group('Property 5: explicit coverage of all four subtypes', () {
    test('each subtype maps to its dedicated section view', () {
      final rng = Random(2024);
      final attempt = _buildAttempt(const [0, 1, 2, 3], rng);
      final controller = MockTestController(attempt: attempt);

      final expected = <int, Type>{
        0: LesenMockView,
        1: HorenMockView,
        2: SchreibenMockView,
        3: SprechenMockView,
      };

      for (var index = 0; index < controller.teilCount; index++) {
        controller.goToTeil(index);
        final body = mockTeilViewFor(controller, index, activeQuestionIndex: 0);
        expect(body.runtimeType, expected[index]);
      }
    });
  });
}
