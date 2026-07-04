// B1 Mock Test — attempt controller.
//
// Owns the only mutable state of an in-progress attempt: the current position
// within the assembled Teile, the student's auto-graded answers, and the AI
// results captured for the Schreiben and Sprechen Sections. The assembled
// [MockTestAttempt] held here is frozen at construction and is **never**
// replaced for the lifetime of the controller — a new attempt requires a new
// controller. Only answers, position, and AI results change as the student
// works through the exam, so navigating back to a previously visited Teil
// always re-displays the same Questions in the same order.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../sprechen/sprechen_data.dart';
import '../sprechen/sprechen_recording_models.dart';
import 'model/mock_test_attempt.dart';
import 'model/mock_test_scorer.dart';

/// Teil 1/2 uchun yozib olingan, lekin hali baholanmagan audio. Baholash test
/// yakunida (Schreiben kabi) bajariladi — shuning uchun bytes xotirada
/// saqlanadi (vaqtinchalik fayl navigatsiyada o'chib ketishi mumkin).
class PendingSprechenAudio {
  final Uint8List bytes;
  final String mimeType;
  final SprechenAufgabe aufgabe;
  final String level;

  const PendingSprechenAudio({
    required this.bytes,
    required this.mimeType,
    required this.aufgabe,
    this.level = 'B1',
  });
}

/// Drives a single mock-test attempt: navigation position, recorded answers,
/// and captured AI evaluations. Notifies listeners whenever the position, an
/// answer, or an AI result changes.
class MockTestController extends ChangeNotifier {
  /// The frozen, assembled attempt. Set once at construction and never replaced
  /// while the attempt is in progress.
  final MockTestAttempt attempt;

  int _currentTeilIndex = 0;

  /// Auto-graded answers keyed by `(teilIndex, questionIndex)`. The selected
  /// option string is compared against the Question's `correctAnswer` at
  /// scoring time.
  final Map<AnswerKey, String> answers = {};

  /// Raw Uzbek-language feedback captured from the Schreiben AI evaluation
  /// (ends with a `Jami: X/20` rubric). `null` until evaluated or when the
  /// evaluation could not be completed.
  String? schreibenFeedback;

  /// O'quvchining Schreiben javob matni — test tugagach tekshirishga yuboriladi.
  String? schreibenAnswer;

  /// Har Sprechen Teil uchun AI baholari (teilNumber → evaluation). Teil 1, 2
  /// va 3 alohida baholanadi va scorer'da mos maksimumga (15/30/30)
  /// moslashtiriladi. Baholanmagan Teil xaritada bo'lmaydi.
  final Map<int, AudioEvaluation> sprechenEvaluations = {};

  /// Teil 3 chat suhbatini yakunda baholash uchun hook. Chat view mount
  /// bo'lganda o'zini ro'yxatdan o'tkazadi; test tugaganda runner buni chaqirib,
  /// agar suhbat hali baholanmagan bo'lsa avtomatik baholaydi. `null` — chat
  /// view ochilmagan yoki allaqachon baholangan.
  Future<void> Function()? sprechenFinalizer;

  /// Teil 1/2 uchun yozib olingan, baholanishi kutilayotgan audiolar
  /// (teilNumber → audio). Test davomida faqat SAQLANADI; AI baholash test
  /// yakunida (Schreiben kabi) bajariladi — shunda o'quvchi kutmaydi.
  final Map<int, PendingSprechenAudio> pendingSprechenAudios = {};

  MockTestController({required this.attempt});

  /// The index of the Teil currently being presented, into [attempt].teile.
  int get currentTeilIndex => _currentTeilIndex;

  /// The Teil currently being presented.
  MockTeil get currentTeil => attempt.teile[_currentTeilIndex];

  /// The number of Teile in the attempt.
  int get teilCount => attempt.teile.length;

  /// Whether the student is on the final Teil of the attempt.
  bool get isOnFinalTeil => _currentTeilIndex >= attempt.teile.length - 1;

  /// Whether there is a Teil before the current one.
  bool get isOnFirstTeil => _currentTeilIndex <= 0;

  /// Records (or replaces) the student's selected [option] for the Question
  /// identified by [key]. The answer is preserved across navigation: moving to
  /// another Teil and back never clears it.
  void selectAnswer(AnswerKey key, String option) {
    answers[key] = option;
    notifyListeners();
  }

  /// The option the student selected for [key], or `null` if unanswered.
  String? answerFor(AnswerKey key) => answers[key];

  /// Advances to the next Teil in the official order, if any. Navigation only
  /// changes the position — it never alters the assembled content.
  void next() {
    if (_currentTeilIndex < attempt.teile.length - 1) {
      _currentTeilIndex++;
      notifyListeners();
    }
  }

  /// Returns to the previous Teil, if any. Navigation only changes the
  /// position — it never alters the assembled content.
  void previous() {
    if (_currentTeilIndex > 0) {
      _currentTeilIndex--;
      notifyListeners();
    }
  }

  /// Records the Schreiben AI feedback captured during the attempt.
  void recordSchreibenFeedback(String? feedback) {
    schreibenFeedback = feedback;
    notifyListeners();
  }

  /// O'quvchi yozgan Schreiben javobini saqlash.
  void recordSchreibenAnswer(String answer) {
    schreibenAnswer = answer;
  }

  /// Records the Sprechen AI evaluation for a specific [teilNumber] captured
  /// during the attempt. Each Teil is scored independently (15/30/30).
  void recordSprechenEvaluation(int teilNumber, AudioEvaluation evaluation) {
    sprechenEvaluations[teilNumber] = evaluation;
    notifyListeners();
  }

  /// Teil 1/2 audio javobini keyinroq (test yakunida) baholash uchun saqlaydi.
  void recordSprechenAudio(int teilNumber, PendingSprechenAudio audio) {
    pendingSprechenAudios[teilNumber] = audio;
  }

  /// Scores the completed attempt by delegating to [MockTestScorer], using the
  /// recorded answers and AI results.
  MockResult buildResult() => MockTestScorer.score(
        attempt: attempt,
        answers: Map.unmodifiable(answers),
        schreibenFeedback: schreibenFeedback,
        sprechenEvaluations: Map.unmodifiable(sprechenEvaluations),
      );
}
