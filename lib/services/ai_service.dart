import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/strange_sentences_round.dart';
import '../models/story_game_round.dart';
import '../models/grammar_game_round.dart';
import '../utils/chat_sanitize.dart';
import '../utils/strange_sentences_fallback.dart';
import '../utils/grammar_fallback.dart';

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
    String targetLang = 'uz',
  }) async {
    final langInstruction = targetLang == 'ru'
        ? 'Объясни ошибки на русском языке. Поле "explanationUz" и "reasonUz" заполни на русском.'
        : 'Xatolarni o\'zbek tilida tushuntir. "explanationUz" va "reasonUz" maydonlarini o\'zbek tilida to\'ldir.';

    final raw = await _chat(
      temperature: 0.2,
      messages: [
        {
          'role': 'system',
          'content':
              'Sen nemis tili o\'qituvchisisan. Foydalanuvchi nemis tilidagi gapidagi xatolarni tekshir. $langInstruction '
              'MUHIM: "correctedText" maydoni NEMIS TILIDA bo\'lsin — foydalanuvchining to\'g\'rilangan nemischa gapi. '
              '"wrong" va "correct" maydonlari ham NEMIS TILIDA bo\'lsin. '
              'Faqat JSON qaytaring, boshqa matn yo\'q. Format: '
              '{"hasMistake":true/false,"correctedText":"nemischa to\'g\'rilangan gap","explanationUz":"tushuntirish (maqsadli tilda)","mistakes":[{"wrong":"xato nemischa","correct":"to\'g\'ri nemischa","reasonUz":"sabab (maqsadli tilda)"}]}',
        },
        {'role': 'user', 'content': text},
      ],
    );

    return _parseJsonObject(raw);
  }

  static Future<String> translateGermanText({
    required String text,
    String targetLang = 'uz',
  }) async {
    final langInstruction = targetLang == 'ru'
        ? 'Переведи следующий немецкий текст на русский язык. Напиши только перевод.'
        : 'Quyidagi nemis matnini o\'zbek tiliga tarjima qiling. Faqat tarjima matnini yozing.';

    return _chat(
      temperature: 0.3,
      messages: [
        {
          'role': 'system',
          'content': langInstruction,
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
O'quvchi javobini O'ZBEK tilida bahola. Haqiqiy o'qituvchidek yoz — oddiy, aniq, quruq.
Hech qanday emoji, yulduzcha (*), qo'shtirnoq belgisi ('), markdown formatlashtirish ishlatma.
Faqat oddiy matn va raqamlar.

Quyidagi tuzilmada yoz:

1. QISQA XULOSA
So'zlar soni: [son] / $minWords talab
Majburiy punktlar: [har birini bajarilgan yoki bajarilmagan deb yoz]
Stil: [to'g'ri ($style talab) yoki noto'g'ri]
Umumiy izoh: 1-2 gap

2. XATOLAR VA TO'G'RILASH
Xatolar bo'lsa har birini yoz. Bo'lmasa: "Ahamiyatli xato topilmadi."
Har xato uchun: xato so'z yoki gap, keyin to'g'risi, keyin qisqa izoh.

3. BAHOLASH
Inhalt (mazmun): X/6
Stil (uslub): X/4
Grammatik va Wortschatz: X/6
Aufbau (tuzilish): X/2
Wortzahl (so'zlar soni): X/2
Jami: X/20

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
        temperature: 0.9,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili A1-A2 o'yin yaratuvchisisan.
Faqat JSON qaytaring: {"rounds":[...]} — boshqa matn yo'q.

Har raund:
- type: "pick" yoki "order" (aralash, taxminan yarim-yarim)
- difficulty: "$difficultyStr" (har bir raundda difficulty qo'ying)
- correctSentence: nemischa, grammatik TO'G'RI, lekin mantiqan absurdt/g'alati (1 gap, Present)
- explanationUz: o'zbekcha, 1 qisqa gap nima uchun to'g'ri

"type":"pick" uchun:
- options: aynan 3 ta nemischa gap. FAQAT BITTASI correctSentence bilan bir xil.
- Qolgan 2 tasi grammatik XATO (fe'l, artikl, tartib).
- Variantlarni HAR DOIM ARALASHTIRING, to'g'ri javob har doim birinchi bo'lmasligi kerak.

"type":"order" uchun:
- shuffledWords: correctSentence so'zlariga bo'lingan massiv, HAR DOIM ARALASHTIRILGAN.
- So'zlar soni va tarkibi correctSentence bilan mos bo'lsin.

Difficulty bo'yicha:
- easy: oddiy gaplar, qisqa (5-7 so'z), asosiy grammatika (der/die/das, oddiy fe'llar)
- medium: o'rtacha gaplar (8-12 so'z), biroz murakkabroq grammatika (akkusativ, dativ)
- hard: murakkab gaplar (13-18 so'z), qiyinroq grammatika (perfekt, präteritum, modal fe'llar)

MUHIM:
- Har bir raundni BOSHQACHA va UNIQUE qiling - gaplar qaytalanmasin
- $count ta raund, barchasi "$difficultyStr" darajasida, lekin har biri BOSHQACHA mazmunda.''',
          },
          {
            'role': 'user',
            'content': '$count ta yangi, BOSHQACHA raund yarating. Har bir gap unique bo\'lishi kerak.',
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

    return StrangeSentencesFallback.sample(count: count, difficulty: difficulty);
  }

  /// Grammatik o'yin uchun raundlar yaratish
  static Future<List<GrammarGameRound>> generateGrammarRounds({
    int count = 8,
  }) async {
    try {
      final raw = await _chat(
        temperature: 0.9,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili A1-A2 grammatik o'yin yaratuvchisisan.
Faqat JSON qaytaring: {"rounds":[...]} — boshqa matn yo'q.

Har raund:
- type: "article", "verb", "preposition", yoki "fillBlank" (aralash)
- question: nemischa savol yoki gap
- questionUz: o'zbekcha tarjima yoki izoh
- options: aynan 4 ta variant. FAQAT BITTASI to'g'ri.
- correctAnswer: to'g'ri variant (options ichidan)
- explanationUz: o'zbekcha izoh nima uchun to'g'ri

"type":"article" uchun:
- Der/Die/Das tanlash
- Masalan: "___ Buch" -> options: ["Der", "Die", "Das", "Den"]

"type":"verb" uchun:
- Fe'l shaklini tanlash
- Masalan: "Ich ___ Apfel" -> options: ["esse", "isst", "essen", "ißt"]

"type":"preposition" uchun:
- Präposition tanlash
- Masalan: "Ich gehe ___ Schule" -> options: ["zur", "zu", "in", "auf"]

"type":"fillBlank" uchun:
- Gapni to'ldirish
- Masalan: "Der Mann ___ im Park" -> options: ["läuft", "laufen", "lief", "gelaufen"]

MUHIM:
- Har bir raundni BOSHQACHA va UNIQUE qiling - savollar qaytalanmasin
- $count ta raund, har biri BOSHQACHA mazmunda.''',
          },
          {
            'role': 'user',
            'content': '$count ta yangi, BOSHQACHA grammatik raund yarating.',
          },
        ],
      );

      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is! Map) throw Exception('Invalid JSON root');

      final list = decoded['rounds'];
      if (list is! List || list.isEmpty) throw Exception('Empty rounds');

      final rounds = <GrammarGameRound>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final round = GrammarGameRound.fromJson(item);
            if (round.isValid) {
              rounds.add(round);
            }
          } catch (e) {
            debugPrint('Error parsing grammar round: $e');
          }
        }
      }

      if (rounds.length >= count) {
        rounds.shuffle(Random());
        return rounds.take(count).toList();
      }
    } catch (e) {
      debugPrint('generateGrammarRounds: $e');
    }

    return GrammarFallback.sample(count: count);
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
    String difficulty = 'medium',
    String? theme,
  }) async {
    try {
      final themePrompt = theme != null 
          ? 'Barcha so\'zlar "$theme" mavzusiga tegishli bo\'lishi kerak (masalan: oila, maktab, tabiat, shahar, hayvonlar, kiyimlar, oziq-ovqat kabi).' 
          : 'So\'zlar bir-biri bilan bog\'liq mavzuga tegishli bo\'lishi kerak, shunda hikoya yozish osonroq bo\'ladi.';

      final raw = await _chat(
        temperature: 0.8,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili A1-A2 o'yin yaratuvchisisan.
Faqat JSON qaytaring: {"words":[...],"minWords":$minWords,"maxWords":$maxWords,"theme":"..."} — boshqa matn yo'q.

$wordCount ta nemischa so'z ber:
- So'z turlari: ot (noun), fe'l (verb), sifat (adjective), ravish (adverb), olg'ovchi (preposition).
- Otlar uchun artikl (der/die/das) ko'rsatilishi kerak, lekin "word" maydonida faqat o'zini yozing (masalan: "word":"Hund", "article":"der").
- Fe'llar infinitiv shaklda bo'lishi kerak (masalan: "essen", "gehen").
- Sifatlar, ravishlar va olg'ovchilar uchun "article" bo'sh bo'lishi kerak.
- $themePrompt
- So'zlar kundalik hayotda ishlatiladigan oddiy so'zlar bo'lishi kerak.
- Har so'z uchun: "word" (nemischa, artiklsiz), "type" ("noun", "verb", "adjective", "adverb", "preposition"), "article" (faqat otlar uchun, der/die/das).

MUHIM: "word" maydoniga artiklni kiritmang! Masalan, "word":"Hund" emas "word":"der Hund".

Foydalanuvchi shu so'zlardan foydalanib $minWords-$maxWords so'zdan iborat hikoya yozishi kerak.''',
          },
          {
            'role': 'user',
            'content': '$wordCount ta yangi so\'z yarating. Mavzu: ${theme ?? "ixtiyoriy"}',
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

MUHIM QOIDALAR:
- Otlar uchun artikl o'zgartirishga ruxsat beriladi. Masalan, "das Buch" berilgan bo'lsa, "ein Buch" yoki "mein Buch" deb yozish xato emas.
- Fe'llar uchun shakl o'zgartirishga ruxsat beriladi. Masalan, "lesen" berilgan bo'lsa, "ich lese", "du liest", "er liest" kabi shakllarda ishlatish xato emas.
- Asosiysi - so'zning ildizi (root) ishlatilgan bo'lishi kerak.

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
