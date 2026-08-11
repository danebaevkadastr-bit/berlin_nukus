import 'package:flutter/foundation.dart';

/// Bitta og'zaki nutq xatosini tuzatish modeli.
@immutable
class SprechenMistakeCorrection {
  final String originalText;
  final String correctedText;
  final String explanation;

  const SprechenMistakeCorrection({
    required this.originalText,
    required this.correctedText,
    required this.explanation,
  });

  factory SprechenMistakeCorrection.fromJson(Map<String, dynamic> json) {
    return SprechenMistakeCorrection(
      originalText: (json['originalText'] ?? json['original'] ?? '').toString().trim(),
      correctedText: (json['correctedText'] ?? json['correction'] ?? '').toString().trim(),
      explanation: (json['explanation'] ?? json['reason'] ?? '').toString().trim(),
    );
  }
}

/// Gemini Live suhbati yakunlangach, ikkinchi AI chiqargan TELC B1 baholash natijasi.
@immutable
class SprechenLiveEvaluation {
  final int score;
  final int maxScore;
  final String gradeLabel;
  final String status;
  final Map<String, String> criteriaScores;
  final List<SprechenMistakeCorrection> corrections;
  final String overallFeedback;
  final List<String> strengths;
  final List<String> suggestedRedemittel;

  const SprechenLiveEvaluation({
    required this.score,
    required this.maxScore,
    required this.gradeLabel,
    required this.status,
    required this.criteriaScores,
    required this.corrections,
    required this.overallFeedback,
    required this.strengths,
    required this.suggestedRedemittel,
  });

  factory SprechenLiveEvaluation.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is double) return v.round();
      if (v != null) {
        final parsed = int.tryParse(v.toString().replaceAll(RegExp(r'[^\d]'), ''));
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final rawCriteria = json['criteriaScores'];
    final Map<String, String> criteria = {};
    if (rawCriteria is Map) {
      rawCriteria.forEach((k, v) {
        criteria[k.toString()] = v.toString();
      });
    }

    final rawCorrections = json['corrections'];
    final List<SprechenMistakeCorrection> corrs = [];
    if (rawCorrections is List) {
      for (final item in rawCorrections) {
        if (item is Map) {
          corrs.add(SprechenMistakeCorrection.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    List<String> toStrList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    return SprechenLiveEvaluation(
      score: toInt(json['score'], 22),
      maxScore: toInt(json['maxScore'], 30),
      gradeLabel: (json['gradeLabel'] ?? 'TELC B1 - Gut Bestanden').toString(),
      status: (json['status'] ?? 'Bestanden').toString(),
      criteriaScores: criteria,
      corrections: corrs,
      overallFeedback: (json['overallFeedback'] ?? json['feedback'] ?? '').toString(),
      strengths: toStrList(json['strengths']),
      suggestedRedemittel: toStrList(json['suggestedRedemittel']),
    );
  }
}
