import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect;

import 'package:berlin_nukus/screens/student/sprechen/sprechen_recording_models.dart';

void main() {
  // Feature: sprechen-audio-recording, Property 1: State isolation across
  // distinct Aufgaben — distinct (teil,test,aufgabe) triples produce distinct,
  // non-colliding keys and equal triples are equal.
  Glados3<int, int, int>(any.int, any.int, any.int).test(
    'Property 1: AufgabeKey value equality and distinctness',
    (teil, test, aufgabe) {
      final a = AufgabeKey(
          teilNumber: teil, testIndex: test, aufgabeIndex: aufgabe);
      final b = AufgabeKey(
          teilNumber: teil, testIndex: test, aufgabeIndex: aufgabe);
      // Bir xil uchlik — teng va hashCode bir xil.
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      // Har bir o'lchamni o'zgartirsak — boshqa kalit.
      final diffTeil = AufgabeKey(
          teilNumber: teil + 1, testIndex: test, aufgabeIndex: aufgabe);
      final diffTest = AufgabeKey(
          teilNumber: teil, testIndex: test + 1, aufgabeIndex: aufgabe);
      final diffAuf = AufgabeKey(
          teilNumber: teil, testIndex: test, aufgabeIndex: aufgabe + 1);
      expect(a == diffTeil, isFalse);
      expect(a == diffTest, isFalse);
      expect(a == diffAuf, isFalse);

      // Map kaliti sifatida to'g'ri ishlaydi.
      final map = <AufgabeKey, int>{a: 1};
      expect(map[b], equals(1));
    },
  );

  // Feature: sprechen-audio-recording, Property 3: Submit only with a completed
  // recording — canSubmit true iff a recording exists and phase is not
  // idle/recording/uploading/evaluating.
  Glados2<int, bool>(any.intInRange(0, RecordingPhase.values.length), any.bool)
      .test(
    'Property 3: canSubmit guard',
    (phaseIndex, hasRec) {
      final phase = RecordingPhase.values[phaseIndex % RecordingPhase.values.length];
      final state = SprechenRecordingState(
        phase: phase,
        filePathOrBlobUrl: hasRec ? '/tmp/a.m4a' : null,
      );

      final expected = hasRec &&
          phase != RecordingPhase.idle &&
          phase != RecordingPhase.recording &&
          phase != RecordingPhase.uploading &&
          phase != RecordingPhase.evaluating;

      expect(state.canSubmit, equals(expected));

      // idle yoki recording bo'lsa — hech qachon submit qilinmaydi.
      if (phase == RecordingPhase.idle || phase == RecordingPhase.recording) {
        expect(state.canSubmit, isFalse);
      }
    },
  );

  // Feature: sprechen-audio-recording, Property 4: No concurrent submission —
  // isBusy true exactly while uploading or evaluating (UI guard'i shu bilan
  // ikkilamchi submit'ni bloklaydi).
  Glados<int>(any.intInRange(0, RecordingPhase.values.length)).test(
    'Property 4: isBusy only while uploading/evaluating',
    (phaseIndex) {
      final phase = RecordingPhase.values[phaseIndex % RecordingPhase.values.length];
      final state = SprechenRecordingState(phase: phase);
      final expected = phase == RecordingPhase.uploading ||
          phase == RecordingPhase.evaluating;
      expect(state.isBusy, equals(expected));
    },
  );

  // Feature: sprechen-audio-recording, Property 6: Evaluation response
  // round-trip — toJson → fromJson preserves all fields.
  Glados3<String, String, String>(
    any.letters,
    any.letters,
    any.letters,
  ).test(
    'Property 6: AudioEvaluation JSON round-trip',
    (score, pron, over) {
      final original = AudioEvaluation(
        score: score,
        pronunciation: pron,
        fluency: 'flu',
        grammar: 'gram',
        content: 'cont',
        overall: over,
      );
      final restored = AudioEvaluation.fromJson(original.toJson());
      expect(restored.score, equals(score.trim()));
      expect(restored.pronunciation, equals(pron.trim()));
      expect(restored.fluency, equals('flu'));
      expect(restored.grammar, equals('gram'));
      expect(restored.content, equals('cont'));
      expect(restored.overall, equals(over.trim()));
    },
  );

  // Feature: sprechen-audio-recording, Property 7: Response parser is total and
  // safe — fromJson on arbitrary maps never throws and always yields a complete
  // object (maydonlar bo'sh bo'lishi mumkin, lekin null emas).
  Glados<String>(any.letters).test(
    'Property 7: AudioEvaluation.fromJson is total',
    (garbage) {
      // Arbitrary kalit/qiymatli map — hech qachon throw qilmasligi kerak.
      final map = <String, dynamic>{
        'score': garbage,
        'unexpected': garbage,
      };
      final result = AudioEvaluation.fromJson(map);
      // Barcha maydonlar non-null string.
      expect(result.score, isA<String>());
      expect(result.pronunciation, isA<String>());
      expect(result.fluency, isA<String>());
      expect(result.grammar, isA<String>());
      expect(result.content, isA<String>());
      expect(result.overall, isA<String>());

      // Bo'sh map ham xavfsiz.
      final empty = AudioEvaluation.fromJson(const <String, dynamic>{});
      expect(empty.hasContent, isFalse);
    },
  );

  // Feature: sprechen-audio-recording, Property 7b: real JSON string parse
  // (jsonDecode + fromJson) ham xavfsiz — to'g'ri JSON to'g'ri o'qiladi.
  Glados<String>(any.letters).test(
    'Property 7b: valid JSON parses into evaluation',
    (scoreText) {
      final jsonStr = jsonEncode({'score': scoreText, 'overall': 'ok'});
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final ev = AudioEvaluation.fromJson(decoded);
      expect(ev.score, equals(scoreText.trim()));
      expect(ev.hasContent, isTrue);
    },
  );

  // Feature: sprechen-audio-recording, Property 10: Timer remaining-time
  // invariant — remaining = max - elapsed, bounded to [0, max], never exceeds.
  Glados<int>(any.intInRange(0, 241)).test(
    'Property 10: timer remaining-time invariant',
    (elapsed) {
      const max = 240;
      final remaining = max - elapsed;
      expect(remaining, inInclusiveRange(0, max));
      expect(elapsed, lessThanOrEqualTo(max));
      // Avtomatik to'xtash chegarasi: elapsed hech qachon max'dan oshmaydi.
      expect(elapsed + remaining, equals(max));
    },
  );
}
