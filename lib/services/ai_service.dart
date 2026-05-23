import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/strange_sentences_round.dart';
import '../models/story_game_round.dart';
import '../utils/chat_sanitize.dart';
import '../utils/strange_sentences_fallback.dart';

class AIService {
  static String get _qwenApiKey => dotenv.env['QWEN_API_KEY']?.trim() ?? '';
  static String get _qwenBaseUrl =>
      (dotenv.env['QWEN_BASE_URL'] ?? '').trim().replaceAll(RegExp(r'/+$'), '');
  static String get _qwenModel =>
      dotenv.env['QWEN_MODEL']?.trim() ?? 'qwen-plus-latest';

  static String get _cerebrasApiKey => dotenv.env['CEREBRAS_API_KEY']?.trim() ?? '';
  static String get _cerebrasBaseUrl =>
      (dotenv.env['CEREBRAS_BASE_URL'] ?? '').trim().replaceAll(RegExp(r'/+$'), '');
  static String get _cerebrasModel =>
      dotenv.env['CEREBRAS_MODEL']?.trim() ?? 'llama3.1-8b';

  static String get _mistralApiKey => dotenv.env['MISTRAL_API_KEY']?.trim() ?? '';
  static String get _mistralBaseUrl =>
      (dotenv.env['MISTRAL_BASE_URL'] ?? 'https://api.mistral.ai/v1').trim().replaceAll(RegExp(r'/+$'), '');
  static String get _mistralModel =>
      dotenv.env['MISTRAL_MODEL']?.trim() ?? 'mistral-small-latest';

  static Future<String> _chat({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  }) async {
    // Avval Qwenni sinash
    try {
      final result = await _chatWithProvider(
        apiKey: _qwenApiKey,
        baseUrl: _qwenBaseUrl,
        model: _qwenModel,
        messages: messages,
        temperature: temperature,
        providerName: 'Qwen',
      );
      return result;
    } catch (e) {
      debugPrint('Qwen failed: $e');
      
      // Qwen xatolik bo'lsa, Cerebrasga o'tish
      try {
        if (_cerebrasApiKey.isEmpty || _cerebrasBaseUrl.isEmpty) {
          throw Exception('Cerebras konfiguratsiyasi topilmadi');
        }
        
        debugPrint('Falling back to Cerebras...');
        return await _chatWithProvider(
          apiKey: _cerebrasApiKey,
          baseUrl: _cerebrasBaseUrl,
          model: _cerebrasModel,
          messages: messages,
          temperature: temperature,
          providerName: 'Cerebras',
        );
      } catch (e2) {
        debugPrint('Cerebras failed: $e2');
        
        // Cerebras ham xatolik bo'lsa, Mistralga o'tish
        if (_mistralApiKey.isEmpty || _mistralBaseUrl.isEmpty) {
          throw Exception(
            'Qwen va Cerebras ishlamadi, Mistral konfiguratsiyasi ham topilmadi',
          );
        }
        
        debugPrint('Falling back to Mistral...');
        return await _chatWithProvider(
          apiKey: _mistralApiKey,
          baseUrl: _mistralBaseUrl,
          model: _mistralModel,
          messages: messages,
          temperature: temperature,
          providerName: 'Mistral',
        );
      }
    }
  }

  static Future<String> _chatWithProvider({
    required String apiKey,
    required String baseUrl,
    required String model,
    required List<Map<String, String>> messages,
    required double temperature,
    required String providerName,
  }) async {
    if (apiKey.isEmpty || baseUrl.isEmpty) {
      throw Exception(
        '$providerName API konfiguratsiyasi topilmadi',
      );
    }

    final uri = Uri.parse('$baseUrl/chat/completions');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'temperature': temperature,
        'messages': messages,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('$providerName error ${response.statusCode}: ${response.body}');
      throw Exception('$providerName javob bermadi (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('$providerName javob bo\'sh');
    }
    final content =
        (choices.first as Map<String, dynamic>)['message']?['content'];
    return (content ?? '').toString().trim();
  }

  static Future<String> sendMessage({
    required String message,
    required List<Map<String, dynamic>> history,
    required String context,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': context},
    ];

    for (final item in history) {
      final role = (item['role'] ?? 'user').toString();
      final text = (item['text'] ?? '').toString();
      if (text.isEmpty) continue;
      messages.add({
        'role': role == 'assistant' ? 'assistant' : 'user',
        'content': text,
      });
    }

    messages.add({'role': 'user', 'content': message});
    final raw = await _chat(messages: messages);
    return ChatSanitize.clean(raw);
  }

  static Future<Map<String, dynamic>> checkMistakes({
    required String text,
  }) async {
    final raw = await _chat(
      temperature: 0.2,
      messages: [
        {
          'role': 'system',
          'content':
              'Sen nemis tili o\'qituvchisisan. Foydalanuvchi gapidagi xatolarni tekshir. '
              'Faqat JSON qaytaring, boshqa matn yo\'q. Format: '
              '{"hasMistake":true/false,"correctedText":"...","explanationUz":"...","mistakes":[{"wrong":"...","correct":"...","reasonUz":"..."}]}',
        },
        {'role': 'user', 'content': text},
      ],
    );

    return _parseJsonObject(raw);
  }

  static Future<String> translateGermanText({required String text}) async {
    return _chat(
      temperature: 0.3,
      messages: [
        {
          'role': 'system',
          'content':
              'Quyidagi nemis matnini o\'zbek tiliga tarjima qiling. Faqat tarjima matnini yozing.',
        },
        {'role': 'user', 'content': text},
      ],
    );
  }

  static Future<Map<String, dynamic>> translateWithMeanings({
    required String text,
  }) async {
    final raw = await _chat(
      temperature: 0.4,
      messages: [
        {
          'role': 'system',
          'content': '''
Sen nemis-uzbek tarjimonisiz. Quyidagi nemis so'z yoki iborani tahlil qilib, JSON formatida javob ber.
Agar so'z yoki iboraning bir nechta ma'nosi bo'lsa, barchasini ko'rsat.

Faqat JSON qaytaring, boshqa matn yo'q. Format:
{
  "original": "nemischa so'z",
  "meanings": [
    {
      "translation": "o'zbekcha tarjima",
      "exampleGerman": "nemischa misol gap",
      "exampleUzbek": "o'zbekcha misol tarjimasi"
    }
  ]
}

Agar bir nechta ma'nosi bo'lsa, "meanings" massivida barchasini yozing.
Har bir ma'no uchun alohida misol gap va uning tarjimasini ko'rsating.''',
        },
        {'role': 'user', 'content': text},
      ],
    );

    try {
      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}

    // Fallback: oddiy tarjima
    return {
      'original': text,
      'meanings': [
        {
          'translation': await translateGermanText(text: text),
          'exampleGerman': '',
          'exampleUzbek': '',
        }
      ],
    };
  }

  static Future<List<String>> getReplyHints({required String context}) async {
    final raw = await _chat(
      temperature: 0.8,
      messages: [
        {
          'role': 'system',
          'content':
              'Nemis tili suhbati uchun 3 ta qisqa javob taklifi bering. '
              'Har biri 1-2 gap, A1-B1 darajada, faqat mavzu bo\'yicha aniq va konkret. '
              'Emoji va smaylik ishlatma. Faqat JSON massiv: ["gap1","gap2","gap3"]',
        },
        {'role': 'user', 'content': context},
      ],
    );

    try {
      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is List) {
        return decoded
            .map((e) => ChatSanitize.clean(e.toString()))
            .where((s) => s.isNotEmpty)
            .take(3)
            .toList();
      }
    } catch (_) {}

    return raw
        .split('\n')
        .map((s) => s.replaceAll(RegExp(r'^[\d\.\-\*]+\s*'), '').trim())
        .where((s) => s.length > 3)
        .take(3)
        .toList();
  }

  static Future<String> evaluateSchreiben({
    required String taskText,
    required List<String> points,
    required String style,
    required int minWords,
    required String answer,
  }) async {
    final pointsBlock = points.map((p) => '• $p').join('\n');

    return _chat(
      temperature: 0.35,
      messages: [
        {
          'role': 'system',
          'content': '''
Sen nemis tili yozma ish (Schreiben, B1) tekshiruvchisisan.
O'quvchi javobini O'ZBEK tilida, quyidagi formatda bahola. Boshqa format ishlatma.

📊 **1. QISQA XULOSA**
- So'zlar soni: [son] / $minWords talab
- Majburiy punktlar: [bajarilgan/bajarilmagan — qisqa]
- Stil: [to'g'ri ($style talab) / noto'g'ri]
- Umumiy izoh: 1-2 gap

🔍 **2. XATOLAR VA TO'G'RILASH**
(Xatolar bo'lsa har birini yoz; bo'lmasa faqat: "Ahamiyatli xato topilmadi")

Har bir xato uchun:
• xato → to'g'risi
  *Izoh:* qisqa tushuntirish

⭐ **3. BAHOLASH**
- Inhalt (mazmun): X/6
- Stil (uslub): X/4
- Grammatik/Wortschatz: X/6
- Aufbau (tuzilish): X/2
- Wortzahl (so'zlar soni): X/2
- JAMI: X/20

Qat'iy, adolatli va qisqa bo'l.''',
        },
        {
          'role': 'user',
          'content': '''
AUFGABE:
$taskText

MAJBURIY PUNKTLAR:
$pointsBlock

STIL: $style
MIN WÖRTER: $minWords

O'QUVCHI JAVOBI (nemis tilida):
$answer
''',
        },
      ],
    );
  }

  /// G'alati gaplar o'yini uchun aralash raundlar (pick + order).
  static Future<List<StrangeSentencesRound>> generateStrangeSentenceRounds({
    int count = 8,
    StrangeDifficulty difficulty = StrangeDifficulty.medium,
  }) async {
    try {
      final difficultyStr = difficulty.toString().split('.').last;
      final raw = await _chat(
        temperature: 0.85,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili A1-A2 o'yin yaratuvchisisan.
Faqat JSON qaytaring: {"rounds":[...]} — boshqa matn yo'q.

Har raund:
- type: "pick" yoki "order" (aralash, taxminan yarim-yarim)
- difficulty: "$difficultyStr" (barcha raundlar shu darajada bo'lishi kerak)
- correctSentence: nemischa, grammatik TO'G'RI, lekin mantiqan absurdt/g'alati (1 gap, Present)
- explanationUz: o'zbekcha, 1 qisqa gap nima uchun to'g'ri

"type":"pick" uchun:
- options: aynan 3 ta nemischa gap. FAQAT BITTASI correctSentence bilan bir xil.
- Qolgan 2 tasi grammatik XATO (fe'l, artikl, tartib).
- Variantlarni ARALASHTIRING, to'g'ri javob har doim birinchi bo'lmasligi kerak.

"type":"order" uchun:
- shuffledWords: correctSentence so'zlariga bo'lingan massiv, ARALASHTIRILGAN.
- So'zlar soni va tarkibi correctSentence bilan mos bo'lsin.

Difficulty bo'yicha:
- easy: oddiy gaplar, qisqa, asosiy grammatika
- medium: o'rtacha gaplar, biroz murakkabroq
- hard: murakkab gaplar, ko'proq so'zlar, qiyinroq grammatika

$count ta raund, barchasi "$difficultyStr" darajasida.''',
          },
          {
            'role': 'user',
            'content': '$count ta yangi raund yarating.',
          },
        ],
      );

      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is! Map) throw Exception('Invalid JSON root');

      final list = decoded['rounds'];
      if (list is! List || list.isEmpty) throw Exception('Empty rounds');

      final rounds = <StrangeSentencesRound>[];
      for (final item in list) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final round = StrangeSentencesRound.fromJson(map);
        if (round.isValid) rounds.add(round);
      }

      if (rounds.length >= count) {
        rounds.shuffle(Random());
        return rounds.take(count).toList();
      }
    } catch (e) {
      debugPrint('generateStrangeSentenceRounds: $e');
    }

    return StrangeSentencesFallback.sample(count: count);
  }

  static Future<String> explainWord({required String word}) async {
    return _chat(
      temperature: 0.4,
      messages: [
        {
          'role': 'system',
          'content':
              'Nemis so\'zini o\'zbek tilida qisqa tushuntiring: ma\'nosi, artikl (der/die/das), 1 misol gap.',
        },
        {'role': 'user', 'content': word},
      ],
    );
  }

  /// Nemischa hikoya o'yini uchun so'zlar generatsiyasi.
  static Future<StoryGameRound> generateStoryWords({
    int wordCount = 10,
    int minWords = 30,
    int maxWords = 40,
  }) async {
    try {
      final raw = await _chat(
        temperature: 0.8,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili A1-A2 o'yin yaratuvchisisan.
Faqat JSON qaytaring: {"words":[...],"minWords":$minWords,"maxWords":$maxWords} — boshqa matn yo'q.

$wordCount ta nemischa so'z ber:
- Yarmini ot (noun), yarmini fe'l (verb).
- Otlar uchun artikl (der/die/das) ko'rsatilishi kerak.
- Fe'llar infinitiv shaklda bo'lishi kerak (masalan: "essen", "gehen").
- So'zlar kundalik hayotda ishlatiladigan oddiy so'zlar bo'lishi kerak.
- Har so'z uchun: "word" (nemischa), "type" ("noun" yoki "verb"), "article" (faqat otlar uchun).

Foydalanuvchi shu so'zlardan foydalanib $minWords-$maxWords so'zdan iborat hikoya yozishi kerak.''',
          },
          {
            'role': 'user',
            'content': '$wordCount ta yangi so\'z yarating.',
          },
        ],
      );

      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is! Map) throw Exception('Invalid JSON root');

      return StoryGameRound.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('generateStoryWords: $e');
      rethrow;
    }
  }

  /// Hikoyani baholash.
  static Future<StoryEvaluation> evaluateStory({
    required String story,
    required List<StoryWord> requiredWords,
    required int minWords,
    required int maxWords,
  }) async {
    try {
      final wordsList = requiredWords.map((w) => w.toJson()).toList();
      final raw = await _chat(
        temperature: 0.3,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili o'qituvchisisan. Foydalanuvchi yozgan hikoyani bahola.
Faqat JSON qaytaring: {"passed":true/false,"wordCount":soni,"feedbackUz":"...","score":ball} — boshqa matn yo'q.

Baholash mezonlari:
- Hikoya $minWords-$maxWords so'z orasida bo'lishi kerak.
- Berilgan so'zlardan kamida 70% ishlatilishi kerak.
- Grammatik jihatdan to'g'ri bo'lishi kerak.
- Mantiqan bog'liq bo'lishi kerak.

Ball:
- So'zlar soni mos kelganda: 30 ball
- So'zlar ishlatilganda: 40 ball
- Grammatik to'g'ri bo'lsa: 30 ball
- Jami: 100 ball

Feedback o'zbek tilida bo'lishi kerak.''',
          },
          {
            'role': 'user',
            'content': '''
Hikoya:
$story

Majburiy so'zlar:
${jsonEncode(wordsList)}

Min: $minWords, Max: $maxWords''',
          },
        ],
      );

      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is! Map) throw Exception('Invalid JSON root');

      return StoryEvaluation.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('evaluateStory: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _parseJsonObject(String raw) {
    try {
      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {'hasMistake': false};
  }

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
