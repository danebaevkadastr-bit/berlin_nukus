// B1 Mock Test — immutable attempt models and selected-test wrappers.
//
// An assembled attempt is frozen: every list is wrapped with
// `List.unmodifiable` and every field is `final`, so once the attempt has been
// built it cannot be mutated. Only the student's answers (held elsewhere on the
// controller) are mutable state.

import 'package:flutter/foundation.dart';

import '../../horen/horen_data.dart';
import '../../lesen/lesen_data.dart';
import '../../sprechen/sprechen_data.dart';
import '../../../../models/schreiben_task.dart';
import 'mock_test_structure.dart';

/// The Test selected for a single Teil. Sealed hierarchy: every concrete
/// selected-test type is one of [SelectedLesenTest], [SelectedHorenTest],
/// [SelectedSchreibenTest], or [SelectedSprechenTest].
@immutable
sealed class SelectedTest {
  const SelectedTest();
}

/// A selected Leseverstehen / Sprachbausteine Test: a contiguous group of
/// [LesenQuestion]s plus the per-test text and image that align with it.
@immutable
final class SelectedLesenTest extends SelectedTest {
  final List<LesenQuestion> questions;
  final String? text;
  final String? imageUrl;

  SelectedLesenTest({
    required List<LesenQuestion> questions,
    this.text,
    this.imageUrl,
  }) : questions = List.unmodifiable(questions);
}

/// A selected Hörverstehen Test: a contiguous group of [HorenQuestion]s.
/// Audio is intrinsic to each question.
@immutable
final class SelectedHorenTest extends SelectedTest {
  final List<HorenQuestion> questions;

  SelectedHorenTest({required List<HorenQuestion> questions})
      : questions = List.unmodifiable(questions);
}

/// A selected Schriftlicher Ausdruck Test: one complete [SchreibenTask].
@immutable
final class SelectedSchreibenTest extends SelectedTest {
  final SchreibenTask task;

  const SelectedSchreibenTest({required this.task});
}

/// A selected Mündlicher Ausdruck Test: an optional theme plus a contiguous
/// group of [SprechenAufgabe]s.
@immutable
final class SelectedSprechenTest extends SelectedTest {
  final String? thema;
  final List<SprechenAufgabe> aufgaben;

  SelectedSprechenTest({
    this.thema,
    required List<SprechenAufgabe> aufgaben,
  }) : aufgaben = List.unmodifiable(aufgaben);
}

/// One Teil of an assembled attempt: which [MockSection] it belongs to, its
/// `teilNumber`, and the [SelectedTest] chosen for it.
@immutable
final class MockTeil {
  final MockSection section;
  final int teilNumber;
  final SelectedTest test;

  const MockTeil({
    required this.section,
    required this.teilNumber,
    required this.test,
  });
}

/// A frozen, assembled mock-test attempt. The [teile] list is already ordered
/// by official Section order then ascending `teilNumber`, and is unmodifiable.
@immutable
final class MockTestAttempt {
  final List<MockTeil> teile;

  MockTestAttempt(List<MockTeil> teile) : teile = List.unmodifiable(teile);

  /// The Teile that belong to [section], in their existing (already-ordered)
  /// sequence.
  Iterable<MockTeil> sectionTeile(MockSection section) =>
      teile.where((t) => t.section == section);
}

/// Value-equality key identifying a single answerable Question within an
/// attempt: the index into [MockTestAttempt.teile] and the index of the
/// Question within that Teil's selected Test.
@immutable
final class AnswerKey {
  final int teilIndex;
  final int questionIndex;

  const AnswerKey(this.teilIndex, this.questionIndex);

  @override
  bool operator ==(Object other) =>
      other is AnswerKey &&
      other.teilIndex == teilIndex &&
      other.questionIndex == questionIndex;

  @override
  int get hashCode => Object.hash(teilIndex, questionIndex);

  @override
  String toString() => 'AnswerKey($teilIndex, $questionIndex)';
}
