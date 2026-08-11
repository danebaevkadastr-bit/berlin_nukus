// Sprechen audio yozish funksiyasi uchun vaqtinchalik (ephemeral) modellar.
// Bu modellar faqat sessiya davomida xotirada saqlanadi — hech qayerda
// (Firestore, shared_preferences) saqlanmaydi. Ekrandan chiqilganda tashlanadi.

import 'package:flutter/foundation.dart';

/// Har bir Aufgabe uchun yozish holatini kalitlash uchun identifikator.
/// Kandidat A va B, har test va har Teil mustaqil bo'lishi uchun value equality.
@immutable
class AufgabeKey {
  final int teilNumber;
  final int testIndex; // ko'p testli Teil uchun (aks holda 0)
  final int aufgabeIndex; // joriy ro'yxatdagi tartib

  const AufgabeKey({
    required this.teilNumber,
    required this.testIndex,
    required this.aufgabeIndex,
  });

  @override
  bool operator ==(Object other) =>
      other is AufgabeKey &&
      other.teilNumber == teilNumber &&
      other.testIndex == testIndex &&
      other.aufgabeIndex == aufgabeIndex;

  @override
  int get hashCode => Object.hash(teilNumber, testIndex, aufgabeIndex);

  @override
  String toString() =>
      'AufgabeKey(teil:$teilNumber, test:$testIndex, aufgabe:$aufgabeIndex)';
}

/// Yozish jarayonining holati (state machine).
enum RecordingPhase {
  idle, // hali yozilmagan
  recording, // hozir yozilyapti
  recorded, // yozildi, yuborishga tayyor
  uploading, // audio yuborilyapti
  evaluating, // AI baholayapti
  done, // fikr keldi
  error, // xato
}

/// AI baholash xatosining turlari.
enum SprechenErrorType {
  recordStartFailed, // yozishni boshlab bo'lmadi
  recordingFailed, // yozish vaqtida xato
  micDenied, // mikrofon ruxsati rad etildi
  micPermanentlyDenied, // butunlay rad etildi (sozlamalar kerak)
  unsupportedPlatform, // platforma yozishni qo'llab-quvvatlamaydi
  uploadFailed, // tarmoq/yuborish xatosi
  evaluationFailed, // AI xatosi
  timeout, // javob kelmadi
  parseError, // javobni o'qib bo'lmadi
}

/// Typed xato — UI uni lokalizatsiya qilingan xabarga aylantiradi.
@immutable
class SprechenError implements Exception {
  final SprechenErrorType type;
  final String? detail;

  const SprechenError(this.type, [this.detail]);

  @override
  String toString() => 'SprechenError($type${detail != null ? ': $detail' : ''})';
}

/// AI (Gemini) qaytargan baholash natijasi. Ball AI tomonidan chiqariladi.
@immutable
class AudioEvaluation {
  final String score; // masalan "16/20" yoki "B1 erreicht" — AI chiqaradi
  final String pronunciation; // talaffuz bo'yicha izoh
  final String fluency; // ravonlik
  final String grammar; // grammatika
  final String content; // mavzuga moslik
  final String overall; // umumiy xulosa

  const AudioEvaluation({
    required this.score,
    required this.pronunciation,
    required this.fluency,
    required this.grammar,
    required this.content,
    required this.overall,
  });

  /// Gemini'ning JSON javobidan parse qiladi. Maydonlar yetishmasa bo'sh string.
  factory AudioEvaluation.fromJson(Map<String, dynamic> json) {
    String s(String key) {
      final v = json[key];
      if (v == null) return '';
      return v.toString().trim();
    }

    return AudioEvaluation(
      score: s('score'),
      pronunciation: s('pronunciation'),
      fluency: s('fluency'),
      grammar: s('grammar'),
      content: s('content'),
      overall: s('overall'),
    );
  }

  /// Test/round-trip uchun JSON ko'rinishi.
  Map<String, dynamic> toJson() => {
        'score': score,
        'pronunciation': pronunciation,
        'fluency': fluency,
        'grammar': grammar,
        'content': content,
        'overall': overall,
      };

  /// Kamida bitta mazmunli maydon bormi (bo'sh javobni aniqlash uchun).
  bool get hasContent =>
      score.isNotEmpty ||
      pronunciation.isNotEmpty ||
      fluency.isNotEmpty ||
      grammar.isNotEmpty ||
      content.isNotEmpty ||
      overall.isNotEmpty;
}

/// Bitta Aufgabe uchun yozish holati (vaqtinchalik).
@immutable
class SprechenRecordingState {
  final RecordingPhase phase;
  final int elapsedSeconds; // yozish davomida o'tgan vaqt
  final String? filePathOrBlobUrl; // yozilgan audio joyi (native: yo'l, web: blob)
  final String? mimeType; // 'audio/mp4' | 'audio/webm'
  final bool reachedMaxLength; // 240s da avtomatik to'xtadimi
  final AudioEvaluation? feedback; // phase == done bo'lganda
  final SprechenError? error; // phase == error bo'lganda

  const SprechenRecordingState({
    this.phase = RecordingPhase.idle,
    this.elapsedSeconds = 0,
    this.filePathOrBlobUrl,
    this.mimeType,
    this.reachedMaxLength = false,
    this.feedback,
    this.error,
  });

  /// Yozilgan (yuborishga tayyor) audio bormi.
  bool get hasRecording =>
      filePathOrBlobUrl != null && filePathOrBlobUrl!.isNotEmpty;

  /// Submit tugmasi yoqilishi kerakmi: tugallangan yozuv bor va hozir
  /// yuborilmayotgan bo'lsa.
  bool get canSubmit =>
      hasRecording &&
      phase != RecordingPhase.idle &&
      phase != RecordingPhase.recording &&
      phase != RecordingPhase.uploading &&
      phase != RecordingPhase.evaluating;

  /// Hozir yuborilyaptimi (ikkilamchi submit'ni bloklash uchun).
  bool get isBusy =>
      phase == RecordingPhase.uploading || phase == RecordingPhase.evaluating;

  SprechenRecordingState copyWith({
    RecordingPhase? phase,
    int? elapsedSeconds,
    String? filePathOrBlobUrl,
    String? mimeType,
    bool? reachedMaxLength,
    AudioEvaluation? feedback,
    SprechenError? error,
    bool clearFeedback = false,
    bool clearError = false,
    bool clearRecording = false,
  }) {
    return SprechenRecordingState(
      phase: phase ?? this.phase,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      filePathOrBlobUrl:
          clearRecording ? null : (filePathOrBlobUrl ?? this.filePathOrBlobUrl),
      mimeType: clearRecording ? null : (mimeType ?? this.mimeType),
      reachedMaxLength: reachedMaxLength ?? this.reachedMaxLength,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
