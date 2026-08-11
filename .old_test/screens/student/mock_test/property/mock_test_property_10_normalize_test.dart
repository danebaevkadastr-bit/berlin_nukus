// Feature: b1-mock-test, Property 10: Point normalization
//
// *For any* correct count between 0 and the total presented Questions, the
// normalized Section points fall within `[0, sectionMax]`, equal 0 when the
// correct count is 0, equal `sectionMax` when all Questions are correct, and
// never decrease as the correct count increases.
//
// Validates: Requirements 9.2
//
// Code under test: MockTestScorer.normalize(correct, total, max).
//
// Property-based tests use `glados` with a seeded `Random` and run a minimum of
// 100 iterations (the glados default `numRuns`). Inputs are constrained with
// smart generators so `correct` always lies within `[0, total]`, `total` is a
// positive presented-Question count, and `max` is a positive Section maximum.

import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_scorer.dart';
import 'package:glados/glados.dart';

void main() {
  group('Property 10: point normalization', () {
    // Range: the normalized points always fall within [0, max].
    Glados3<int, int, int>(any.int, any.int, any.int).test(
      'normalize result lies within [0, max] for any correct in [0, total]',
      (rawTotal, rawCorrect, rawMax) {
        final total = 1 + (rawTotal.abs() % 60); // 1..60 presented Questions
        final max = 1 + (rawMax.abs() % 125); // 1..125 Section maximum
        final correct = rawCorrect.abs() % (total + 1); // 0..total

        final points = MockTestScorer.normalize(correct, total, max);

        expect(points, inInclusiveRange(0, max));
      },
    );

    // Lower boundary: zero correct answers map to zero points.
    Glados2<int, int>(any.int, any.int).test(
      'normalize returns 0 when the correct count is 0',
      (rawTotal, rawMax) {
        final total = 1 + (rawTotal.abs() % 60);
        final max = 1 + (rawMax.abs() % 125);

        expect(MockTestScorer.normalize(0, total, max), 0);
      },
    );

    // Upper boundary: all correct answers map to the full Section maximum.
    Glados2<int, int>(any.int, any.int).test(
      'normalize returns max when every Question is correct (correct == total)',
      (rawTotal, rawMax) {
        final total = 1 + (rawTotal.abs() % 60);
        final max = 1 + (rawMax.abs() % 125);

        expect(MockTestScorer.normalize(total, total, max), max);
      },
    );

    // Monotonicity: the points never decrease as the correct count increases.
    Glados2<int, int>(any.int, any.int).test(
      'normalize is monotonic non-decreasing in the correct count',
      (rawTotal, rawMax) {
        final total = 1 + (rawTotal.abs() % 60);
        final max = 1 + (rawMax.abs() % 125);

        var previous = MockTestScorer.normalize(0, total, max);
        for (var correct = 1; correct <= total; correct++) {
          final current = MockTestScorer.normalize(correct, total, max);
          expect(
            current,
            greaterThanOrEqualTo(previous),
            reason: 'points decreased from $previous to $current when '
                'correct went to $correct (total=$total, max=$max)',
          );
          previous = current;
        }
      },
    );
  });
}
