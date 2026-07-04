// Unit tests for MockTestController navigation and answer recording.
//
// Task 6.4: Test next/previous/isOnFinalTeil transitions and answer recording.
// Requirements: 6.1 (advance through Teile), 6.2 (current position), 6.3 (reach
// completion on the final Teil).
//
// These are example-based unit tests (not property tests). A small synthetic
// MockTestAttempt is constructed directly from the immutable attempt models so
// the controller can be exercised without running the assembler.

import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test fixtures ────────────────────────────────────────────────────────────

LesenQuestion _lesenQ(String tag) => LesenQuestion(
      passage: '$tag-passage',
      prompt: '$tag-prompt',
      options: const ['a', 'b', 'c'],
      correctAnswer: 'a',
    );

HorenQuestion _horenQ(String tag) => HorenQuestion(
      audioTitle: tag,
      audioUrl: 'https://example.test/$tag.mp3',
      question: '$tag-question',
      options: const ['Richtig', 'Falsch'],
      correctAnswer: 'Richtig',
    );

SprechenAufgabe _sprechenA(String tag) => SprechenAufgabe(
      title: tag,
      instruction: '$tag-instruction',
      keywords: const ['k1'],
      examples: const ['e1'],
    );

/// Builds a small four-Teil attempt spanning the auto-graded and AI sections,
/// in official order: Leseverstehen, Hörverstehen, Schriftlicher Ausdruck,
/// Mündlicher Ausdruck.
MockTestAttempt _buildAttempt() {
  return MockTestAttempt([
    MockTeil(
      section: MockSection.leseverstehen,
      teilNumber: 1,
      test: SelectedLesenTest(
        questions: [_lesenQ('L1-0'), _lesenQ('L1-1')],
        text: 'L1-text',
        imageUrl: 'L1-img',
      ),
    ),
    MockTeil(
      section: MockSection.hoerverstehen,
      teilNumber: 1,
      test: SelectedHorenTest(
        questions: [_horenQ('H1-0'), _horenQ('H1-1')],
      ),
    ),
    MockTeil(
      section: MockSection.schriftlicherAusdruck,
      teilNumber: 1,
      test: const SelectedSchreibenTest(
        task: SchreibenTask(
          id: 0,
          task: 'task-0',
          points: ['p1', 'p2', 'p3', 'p4'],
          style: 'formal',
          minWords: 80,
          level: 'B1',
          letter: 'letter-0',
        ),
      ),
    ),
    MockTeil(
      section: MockSection.muendlicherAusdruck,
      teilNumber: 1,
      test: SelectedSprechenTest(
        thema: 'S1-thema',
        aufgaben: [_sprechenA('S1-0')],
      ),
    ),
  ]);
}

void main() {
  group('MockTestController navigation', () {
    test('starts on the first Teil', () {
      final controller = MockTestController(attempt: _buildAttempt());

      expect(controller.currentTeilIndex, 0);
      expect(controller.teilCount, 4);
      expect(controller.isOnFirstTeil, isTrue);
      expect(controller.isOnFinalTeil, isFalse);
      expect(controller.currentTeil.section, MockSection.leseverstehen);
    });

    test('next() advances one Teil at a time in official order', () {
      final controller = MockTestController(attempt: _buildAttempt());

      controller.next();
      expect(controller.currentTeilIndex, 1);
      expect(controller.currentTeil.section, MockSection.hoerverstehen);

      controller.next();
      expect(controller.currentTeilIndex, 2);
      expect(controller.currentTeil.section, MockSection.schriftlicherAusdruck);
    });

    test('next() does not advance past the final Teil', () {
      final controller = MockTestController(attempt: _buildAttempt());

      controller.next();
      controller.next();
      controller.next();
      expect(controller.currentTeilIndex, 3);
      expect(controller.isOnFinalTeil, isTrue);

      // Already on the final Teil — next() is a no-op.
      controller.next();
      expect(controller.currentTeilIndex, 3);
      expect(controller.isOnFinalTeil, isTrue);
    });

    test('previous() moves back and clamps at the first Teil', () {
      final controller = MockTestController(attempt: _buildAttempt());

      controller.next();
      controller.next();
      expect(controller.currentTeilIndex, 2);

      controller.previous();
      expect(controller.currentTeilIndex, 1);
      expect(controller.isOnFirstTeil, isFalse);

      controller.previous();
      expect(controller.currentTeilIndex, 0);
      expect(controller.isOnFirstTeil, isTrue);

      // Already on the first Teil — previous() is a no-op.
      controller.previous();
      expect(controller.currentTeilIndex, 0);
      expect(controller.isOnFirstTeil, isTrue);
    });

    test('isOnFinalTeil and isOnFirstTeil track the current position', () {
      final controller = MockTestController(attempt: _buildAttempt());

      expect(controller.isOnFirstTeil, isTrue);
      expect(controller.isOnFinalTeil, isFalse);

      controller.next(); // index 1
      expect(controller.isOnFirstTeil, isFalse);
      expect(controller.isOnFinalTeil, isFalse);

      controller.next(); // index 2
      controller.next(); // index 3 (final)
      expect(controller.isOnFirstTeil, isFalse);
      expect(controller.isOnFinalTeil, isTrue);
    });

    test('navigation notifies listeners on real moves only', () {
      final controller = MockTestController(attempt: _buildAttempt());
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.next(); // moves -> notifies
      expect(notifications, 1);

      controller.previous(); // moves -> notifies
      expect(notifications, 2);

      controller.previous(); // already first -> no notify
      expect(notifications, 2);
    });
  });

  group('MockTestController answer recording', () {
    test('selectAnswer records an option retrievable via answerFor', () {
      final controller = MockTestController(attempt: _buildAttempt());
      const key = AnswerKey(0, 0);

      expect(controller.answerFor(key), isNull);

      controller.selectAnswer(key, 'b');
      expect(controller.answerFor(key), 'b');
      expect(controller.answers[key], 'b');
    });

    test('selectAnswer replaces the previous option for the same key', () {
      final controller = MockTestController(attempt: _buildAttempt());
      const key = AnswerKey(1, 0);

      controller.selectAnswer(key, 'Richtig');
      controller.selectAnswer(key, 'Falsch');

      expect(controller.answerFor(key), 'Falsch');
      expect(controller.answers.length, 1);
    });

    test('answers are preserved across navigation', () {
      final controller = MockTestController(attempt: _buildAttempt());
      const keyA = AnswerKey(0, 0);
      const keyB = AnswerKey(0, 1);

      controller.selectAnswer(keyA, 'a');
      controller.selectAnswer(keyB, 'c');

      // Navigate away and back.
      controller.next();
      controller.next();
      controller.previous();
      controller.previous();
      expect(controller.currentTeilIndex, 0);

      expect(controller.answerFor(keyA), 'a');
      expect(controller.answerFor(keyB), 'c');
    });

    test('answers for distinct keys are recorded independently', () {
      final controller = MockTestController(attempt: _buildAttempt());
      const lesenKey = AnswerKey(0, 0);
      const horenKey = AnswerKey(1, 0);

      controller.selectAnswer(lesenKey, 'a');
      controller.selectAnswer(horenKey, 'Richtig');

      expect(controller.answerFor(lesenKey), 'a');
      expect(controller.answerFor(horenKey), 'Richtig');
      expect(controller.answers.length, 2);
    });

    test('selectAnswer notifies listeners', () {
      final controller = MockTestController(attempt: _buildAttempt());
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.selectAnswer(const AnswerKey(0, 0), 'a');
      expect(notifications, 1);
    });
  });
}
