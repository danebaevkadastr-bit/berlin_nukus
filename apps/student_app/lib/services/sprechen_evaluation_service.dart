import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../screens/student/sprechen/sprechen_data.dart';
import '../screens/student/sprechen/sprechen_recording_models.dart';

/// Yozilgan audioni Gemini'ga yuborib, og'zaki nutqni baholaydigan xizmat.
/// AIService uslubida: barcha maxfiy kalitlar Cloudflare Worker ichida.
class SprechenEvaluationService {
  static String get _proxyUrl =>
      (dotenv.env['CF_WORKER_URL'] ?? '').trim().replaceAll(RegExp(r'/+$'), '');

  static String get _appToken => dotenv.env['APP_TOKEN']?.trim() ?? '';

  /// Worker'da default `gemini-2.5-flash` ishlatiladi; bu yerda env orqali
  /// boshqasini majburlash mumkin (ixtiyoriy).
  static String get _audioModel =>
      dotenv.env['GEMINI_AUDIO_MODEL']?.trim() ?? '';

  /// Audio og'irroq — 60 soniyalik timeout.
  static const Duration _timeout = Duration(seconds: 60);

  /// Yozilgan audioni baholaydi.
  static Future<AudioEvaluation> evaluate({
    required Uint8List audioBytes,
    required String mimeType,
    required SprechenAufgabe aufgabe,
    required String level,
    required String uiLangCode,
  }) async {
    if (_proxyUrl.isEmpty) {
      throw const SprechenError(
          SprechenErrorType.uploadFailed, 'CF_WORKER_URL sozlanmagan');
    }

    final prompt = _buildPrompt(
      aufgabe: aufgabe,
      level: level,
      uiLangCode: uiLangCode,
    );
    final audioBase64 = base64Encode(audioBytes);

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_proxyUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-Proxy-Target': 'gemini-audio',
              if (_appToken.isNotEmpty) 'X-App-Token': _appToken,
            },
            body: jsonEncode({
              if (_audioModel.isNotEmpty) 'model': _audioModel,
              'audioBase64': audioBase64,
              'mimeType': mimeType,
              'prompt': prompt,
            }),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const SprechenError(SprechenErrorType.timeout);
    } catch (e) {
      throw SprechenError(SprechenErrorType.uploadFailed, e.toString());
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final snippet = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      debugPrint('gemini-audio error ${response.statusCode}: ${response.body}');
      throw SprechenError(
        SprechenErrorType.evaluationFailed,
        '(${response.statusCode}) $snippet',
      );
    }

    // Gemini generateContent javobidan matnni ajratamiz, keyin JSON parse.
    final text = _extractGeminiText(response.body);
    if (text.isEmpty) {
      throw const SprechenError(SprechenErrorType.parseError, 'Bo\'sh javob');
    }

    try {
      final decoded = jsonDecode(_extractJson(text));
      if (decoded is! Map) {
        throw const SprechenError(SprechenErrorType.parseError);
      }
      final evaluation =
          AudioEvaluation.fromJson(Map<String, dynamic>.from(decoded));
      if (!evaluation.hasContent) {
        throw const SprechenError(SprechenErrorType.parseError);
      }
      return evaluation;
    } on SprechenError {
      rethrow;
    } catch (e) {
      throw SprechenError(SprechenErrorType.parseError, e.toString());
    }
  }

  /// Aufgabe kontekstidan baholash promptini quradi.
  static String _buildPrompt({
    required SprechenAufgabe aufgabe,
    required String level,
    required String uiLangCode,
  }) {
    final lang = _langName(uiLangCode);

    final isB2 = level.toUpperCase().contains('B2');
    final isTeil1B1 = aufgabe.title.toLowerCase().contains('vorstellen') ||
        aufgabe.instruction.toLowerCase().contains('vorstellen') ||
        aufgabe.title.toLowerCase().contains('kontaktaufnahme');

    final int maxScore;
    if (isB2) {
      maxScore = 25; // TELC B2 Sprechen Teil max: 25 Points
    } else if (isTeil1B1) {
      maxScore = 15; // TELC B1 Sprechen Teil 1 max: 15 Points
    } else {
      maxScore = 30; // TELC B1 Sprechen Teil 2 & Teil 3 max: 30 Points
    }

    final contextLines = <String>[
      'Niveau (TELC): $level',
      'Aufgabe: ${aufgabe.title}',
      'Anweisung: ${aufgabe.instruction}',
    ];
    if (aufgabe.partner.isNotEmpty) {
      contextLines.add('Kandidat/in: ${aufgabe.partner}');
    }
    if (aufgabe.meinung != null && aufgabe.meinung!.trim().isNotEmpty) {
      contextLines.add('Meinung/Thema: ${aufgabe.meinung}');
    }

    return '''
Du bist ein erfahrener Prüfer für die mündliche TELC-Deutschprüfung ($level).
Im Audio spricht ein Lernender Deutsch zu der unten beschriebenen Aufgabe.
Höre das Audio an und bewerte die gesprochene Leistung fair und streng nach offiziellen TELC-Kriterien.

KONTEXT:
${contextLines.join('\n')}

BEWERTUNGSKRITERIEN (TELC $level mündliche Prüfung):
1. Aussprache: Deutliche, verständliche Aussprache.
2. Flüssigkeit: Natürliches Sprechtempo ohne übermäßige Pausen.
3. Grammatik: Korrekte Satzstruktur, Verbkonjugation, Kasus.
4. Inhalt: Relevanz zur Aufgabe. Wenn der Inhalt NICHT zum Thema passt → 0 Punkte.

WICHTIG:
- Wenn der Lernende NICHT Deutsch spricht (andere Sprache, Stille, Lärm) → score "0/$maxScore".
- Wenn der Inhalt NICHT zum Thema passt → Inhalt = 0, Gesamtnote niedrig.
- Sei ehrlich und fair. Überbewerte nicht.
- score muss im Format "X/$maxScore" sein (offizielles TELC $level System, Max: $maxScore Punkte).

Antworte AUSSCHLIESSLICH in der Sprache "$lang" (für die Feedback-Texte)
und gib NUR gültiges JSON zurück, ohne Markdown, ohne zusätzlichen Text.
Struktur:
{
  "score": "X/$maxScore — streng und fair bewerten",
  "pronunciation": "Feedback zur Aussprache in $lang",
  "fluency": "Feedback zur Flüssigkeit in $lang",
  "grammar": "Feedback zur Grammatik in $lang",
  "content": "Feedback zur inhaltlichen Relevanz in $lang",
  "overall": "kurze Gesamteinschätzung in $lang"
}
''';
  }

  static String _langName(String code) {
    switch (code) {
      case 'ru':
        return 'Russisch';
      case 'kaa':
        return 'Karakalpakisch';
      case 'de':
        return 'Deutsch';
      case 'uz':
      default:
        return 'Usbekisch';
    }
  }

  /// Gemini generateContent javobidan matn qismini ajratadi.
  /// Format: { candidates: [ { content: { parts: [ { text: "..." } ] } } ] }
  static String _extractGeminiText(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        final candidates = data['candidates'];
        if (candidates is List && candidates.isNotEmpty) {
          final content = (candidates.first as Map)['content'];
          if (content is Map) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              final buffer = StringBuffer();
              for (final p in parts) {
                if (p is Map && p['text'] != null) {
                  buffer.write(p['text'].toString());
                }
              }
              return buffer.toString().trim();
            }
          }
        }
        // Ba'zan worker to'g'ridan-to'g'ri JSON qaytarishi mumkin.
        if (data.containsKey('score')) {
          return body;
        }
      }
    } catch (_) {}
    return '';
  }

  /// Markdown fence yoki ortiqcha matndan JSON qismini ajratadi
  /// (AIService._extractJson bilan bir xil mantiq).
  static String _extractJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('```')) {
      return trimmed
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    final start = trimmed.indexOf('{');
    final listStart = trimmed.indexOf('[');
    if (start == -1 && listStart == -1) return trimmed;
    if (start == -1) return trimmed.substring(listStart);
    if (listStart == -1) return trimmed.substring(start);
    return trimmed.substring(start < listStart ? start : listStart);
  }
}
