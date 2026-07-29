import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'video_data.dart';
import '../../../services/ai_service.dart';

class VideoAiService {
  /// Epizod subtitri va mavzusi asosida Gemini AI orqali real vaqtda 3-4 ta Quiz savollarini yaratadi.
  static Future<List<VideoQuizQuestion>> generateQuizQuestions({
    required GermanVideo video,
    required String langCode, // uz, kaa, ru
  }) async {
    final subtitleText = video.subtitles.map((s) => s.textDe).join('\n');
    final targetLangName = (langCode == 'kaa')
        ? 'Karakalpak (Qaraqalpaqsha)'
        : (langCode == 'ru' ? 'Russian (Русский)' : 'Uzbek (O\'zbekcha)');

    final prompt = '''
Du bist ein Deutschlehrer. Basierend auf diesem Video-Transkript erstelle 3 kurze Verständnisfragen (Multiple-Choice-Quiz).

[VIDEO DETAILS]
Title: ${video.title}
Level: ${video.level}
Transcript:
$subtitleText

[PFLICHT-REGELN]
1. Die Fragen, Antwortoptionen und Erklärungen MÜSSEN in der Sprache "$targetLangName" verfasst sein.
2. Gib NUR ein gültiges JSON-Array zurück (KEIN Markdown, KEINE Erklärungen außerhalb des JSON).
3. JSON Format:
[
  {
    "question": "Savol matni...",
    "options": ["Variant 1", "Variant 2", "Variant 3"],
    "correctIndex": 1,
    "explanation": "To'g'ri javob tushuntirishi..."
  }
]
''';

    try {
      final responseText = await AIService.sendMessage(
        message: prompt,
        history: [],
        context: 'Du bist ein KI-Deutschlehrer. Antworte NUR im gültigen JSON-Format.',
      );

      // JSON tozalash (markdown ```json ... ``` bo'lsa olib tashlash)
      final cleanJson = responseText
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final List<dynamic> decoded = jsonDecode(cleanJson);
      final List<VideoQuizQuestion> generatedQuestions = [];

      for (var item in decoded) {
        final qText = item['question'] as String? ?? '';
        final opts = List<String>.from(item['options'] ?? []);
        final correctIdx = (item['correctIndex'] as num?)?.toInt() ?? 0;
        final expl = item['explanation'] as String? ?? '';

        if (qText.isNotEmpty && opts.length >= 2) {
          generatedQuestions.add(
            VideoQuizQuestion(
              questionText: {langCode: qText, 'uz': qText},
              options: {langCode: opts, 'uz': opts},
              correctAnswerIndex: correctIdx < opts.length ? correctIdx : 0,
              explanation: {langCode: expl, 'uz': expl},
            ),
          );
        }
      }

      if (generatedQuestions.isNotEmpty) {
        return generatedQuestions;
      }
    } catch (e) {
      debugPrint('VideoAiService quiz generation error: $e');
    }

    // Fallback: Agar AI bo'lmasa yoki xato bo'lsa, videoning o'zida bor tayyor savollarni qaytarish
    return video.quizQuestions;
  }
}
