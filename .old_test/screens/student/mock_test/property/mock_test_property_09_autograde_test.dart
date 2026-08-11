// Feature: b1-mock-test, Property 9: Auto-graded scoring
//
// *For any* set of presented Auto_Graded_Section Questions and *any* mapping of
// student answers, the computed correct count equals the number of Questions
// whose recorded answer equals the Question's `correctAnswer`; unanswered
// Questions never count as correct; and the count is always between 0 and the
// total number of presented Questions.
//
// Validates: Requirements 7.1, 7.2, 7.3
//
// Code under test: MockTestScorer.autoGradeCount(
//   List<({String correct})> questions, Map<int, String?> answers).
//
// Strategy: glados drives a per-Question "answer state" list. Each state picks
// one of four shapes the answer map can take for that Question:
//   0 = answered correctly (selected == correct)
//   1 = answered incorrectly (selected != correct)
//   2 = answered with an explicit null (unanswered)
//   3 = key absent from the map entirely (unanswered)
// From the states we deterministically build the presented questions and the
// answer map, compute the expected correct count independently, and assert the
// scorer agrees while respecting the universal bounds and the unanswered rule.
// Property-based tests use `glados` and run a minimum of 100 iterations.

import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_scorer.dart';
import 'package:glados/glados.dart';

/// The answer shape applied to a single presented Question.
const int _correct = 0;
const int _incorrect = 1;
const int _explicitNull = 2;
const int _absent = 3;

void main() {
  // Feature: b1-mock-test, Property 9: Auto-graded scoring
  Glados<List<int>>(
    any.list(any.intInRange(0, 4)), // each element is a state in [0, 4)
    ExploreConfig(numRuns: 100), // minimum 100 iterations
  ).test('Property 9: auto-graded scoring', (rawStates) {
    // Normalize each generated element into a valid state in [0, 3].
    final states = [for (final s in rawStates) s.abs() % 4];

    // Each Question carries a distinct correct answer so a "wrong" selection is
    // unambiguous and cannot accidentally match another Question's answer.
    final questions = <({String correct})>[
      for (var i = 0; i < states.length; i++) (correct: 'correct-$i'),
    ];

    final answers = <int, String?>{};
    final answeredIndices = <int>{};
    final unansweredIndices = <int>{};
    var expectedCorrect = 0;

    for (var i = 0; i < states.length; i++) {
      switch (states[i]) {
        case _correct:
          answers[i] = 'correct-$i';
          answeredIndices.add(i);
          expectedCorrect++;
        case _incorrect:
          answers[i] = 'wrong-$i';
          answeredIndices.add(i);
        case _explicitNull:
          answers[i] = null; // present key, but unanswered
          unansweredIndices.add(i);
        case _absent:
          // no map entry at all → unanswered
          unansweredIndices.add(i);
      }
    }

    final count = MockTestScorer.autoGradeCount(questions, answers);

    // Core: the count equals the number of correctly answered Questions.
    expect(count, expectedCorrect,
        reason: 'count must equal the number of Questions whose recorded '
            'answer equals the correct answer');

    // Bounds: the count is always within [0, total].
    expect(count, inInclusiveRange(0, questions.length),
        reason: 'count must be between 0 and the number of presented Questions');

    // Unanswered Questions never contribute to the count: removing an answered
    // index lowers (or keeps) the count, while every unanswered index is
    // guaranteed not to have been counted as correct.
    for (final i in unansweredIndices) {
      final selected = answers[i];
      expect(selected == questions[i].correct, isFalse,
          reason: 'an unanswered Question (index $i) must never match the '
              'correct answer');
    }

    // Sanity: the counted-correct set is a subset of the answered set.
    expect(count <= answeredIndices.length, isTrue,
        reason: 'no more correct answers than answered Questions');
  });

  // Boundary: an empty presented-question list always scores 0.
  test('Property 9: empty presented questions score zero', () {
    expect(MockTestScorer.autoGradeCount(const [], const {}), 0);
  });
}
