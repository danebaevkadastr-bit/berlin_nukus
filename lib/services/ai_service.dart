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
  static String get _qwenChatModel =>
      dotenv.env['QWEN_CHAT_MODEL']?.trim() ?? 'qwen3.5-122b-a10b';
  static String get _qwenGameModel =>
      dotenv.env['QWEN_GAME_MODEL']?.trim() ?? 'qwen-plus-latest';

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

  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
  static String get _geminiBaseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/openai';
  static String get _geminiModel =>
      dotenv.env['GEMINI_MODEL']?.trim() ?? 'gemini-2.0-flash';

  static Future<String> _chat({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    bool isGame = false,
  }) async {
    // Avval Qwenni sinash
    try {
      final result = await _chatWithProvider(
        apiKey: _qwenApiKey,
        baseUrl: _qwenBaseUrl,
        model: isGame ? _qwenGameModel : _qwenChatModel,
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
        try {
          if (_mistralApiKey.isEmpty || _mistralBaseUrl.isEmpty) {
            throw Exception('Mistral konfiguratsiyasi topilmadi');
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
        } catch (e3) {
          debugPrint('Mistral failed: $e3');

          // Hammasi ishlamasa — Gemini
          if (_geminiApiKey.isEmpty) {
            throw Exception(
              'Barcha AI provayderlar ishlamadi (Qwen, Cerebras, Mistral, Gemini)',
            );
          }

          debugPrint('Falling back to Gemini...');
          return await _chatWithProvider(
            apiKey: _geminiApiKey,
            baseUrl: _geminiBaseUrl,
            model: _geminiModel,
            messages: messages,
            temperature: temperature,
            providerName: 'Gemini',
          );
        }
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

    final proxyUrl = dotenv.env['CF_WORKER_URL']?.trim() ?? '';
    const isWeb = kIsWeb;

    Uri uri;
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    if (isWeb && proxyUrl.isNotEmpty) {
      uri = Uri.parse(proxyUrl);
      requestHeaders['X-Target-Url'] = '$baseUrl/chat/completions';
    } else {
      uri = Uri.parse('$baseUrl/chat/completions');
    }

    final response = await http
        .post(
          uri,
          headers: requestHeaders,
          body: jsonEncode({
            'model': model,
            'temperature': temperature,
            'messages': messages,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('$providerName so\'rov vaqti tugadi (30s)'),
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
        isGame: true,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili grammatik o'yin yaratuvchisisan. O'yin nomi: "G'alati Gaplar".
Faqat JSON qaytaring: {"rounds":[...]} — boshqa matn yo'q.

KONSEPT: Har bir gap GRAMMATIK TO'G'RI lekin MANTIQAN ABSURD/G'ALATI bo'lishi kerak.
(Masalan: "Mein Hund schreibt jeden Morgen eine E-Mail." — grammatik to'g'ri, lekin safsata!)

Har raund:
- type: "pick" yoki "order" (aralash, yarim-yarim)
- difficulty: "$difficultyStr"
- correctSentence: grammatik TO'G'RI, mantiqan G'ALATI nemischa gap
- explanationUz: o'zbekcha — nima uchun grammatik to'g'ri ekanligini tushuntir (qoidani ayt)

"type":"pick" uchun:
- options: aynan 3 ta gap. FAQAT BITTASI to'g'ri (correctSentence).
- Qolgan 2 tasi: grammatik XATO (fe'l shaklida xato, artikl xato, so'z tartibi buzilgan)
- Variantlar tartibini ARALASHTIRIB yuboring — to'g'ri javob doim 1-bo'lmasin

"type":"order" uchun:
- shuffledWords: correctSentence so'zlarga bo'linib, HAR DOIM ARALASHTIRILGAN massiv
- So'zlar soni correctSentence bilan to'liq mos bo'lsin

DARAJALAR:

difficulty "easy" — A1 darajasi:
Mavzular: Präsens (oddiy fe'llar), der/die/das artikl, Nominativ/Akkusativ, Modal fe'llar (kann, muss, möchte)
Gap uzunligi: 5-8 so'z
Misol g'alati gaplar:
• "Der Kühlschrank singt eine Oper." (Nominativ, Präsens, Akkusativ — muzlatgich opera kuylaydi)
• "Meine Katze kann fließend Russisch sprechen." (Modal + Infinitiv — mushuk rus tilida gapiradigan)
• "Das Buch trinkt jeden Abend Kaffee." (Das bilan, Präsens — kitob qahva ichadi)
• "Ich muss heute die Wolken zählen." (Modal, Akkusativ — bulutlarni sanash)

difficulty "medium" — A2 darajasi:
Mavzular: Perfekt, Präteritum (sein/haben), Dativ, Wechselpräpositionen, Reflexive Verben, Komparativ, weil/dass/wenn gaplari
Gap uzunligi: 9-14 so'z
Misol g'alati gaplar:
• "Mein Stuhl hat sich gestern mit mir gestritten, weil ich zu lange gesessen habe." (Perfekt, Reflexiv, weil)
• "Der Mond ist schneller als mein Fahrrad, weil er jeden Abend vor mir da ist." (Komparativ, weil)
• "Sie hat dem Regen gedankt, weil er ihr Auto gewaschen hat." (Dativ, Perfekt, weil)
• "Das Sofa hat sich auf den Tisch gesetzt und Zeitung gelesen." (Wechselpräp, Perfekt, Reflexiv)

difficulty "hard" — B1 darajasi:
Mavzular: Passiv, Konjunktiv II, Plusquamperfekt, Relativsätze, um/ohne/damit Infinitiv, Modalpartikeln, Nebensatz (obwohl/nachdem/bevor/während)
Gap uzunligi: 14-20 so'z
Misol g'alati gaplar:
• "Die Pizza, die von meinem Drucker gebacken wurde, schmeckt besser als alles, was ich je probiert habe." (Passiv, Relativsatz)
• "Obwohl meine Tastatur täglich Sport treibt, wird sie immer langsamer." (obwohl, Passiv Komparativ)
• "Der Tisch hatte bereits geschlafen, bevor die Stühle nach Hause gekommen waren." (Plusquamperfekt, bevor)
• "Ich würde gerne wissen, ob mein Schatten ein eigenes Leben führt, während ich schlafe." (Konjunktiv II, ob, während)

MUHIM QOIDALAR:
1. G'alati gap GRAMMATIK JIHATDAN MUTLAQO TO'G'RI bo'lishi SHART
2. Mantiqan esa bema'ni/qiziqarli/kulgili bo'lishi kerak — kundalik hayotda bo'lmaydigan narsa
3. Xato variantlarda ANIQ grammatik xatolar bo'lsin (fe'l noto'g'ri tuslanishi, artikl, tartib)
4. Har bir raund UNIQUE bo'lsin — mavzular va gaplar takrorlanmasin
5. $count ta raund, hammasi "$difficultyStr" darajasida, lekin HAR BIRI BOSHQA GRAMMATIK MAVZUDAN''',
          },
          {
            'role': 'user',
            'content': '$count ta yangi raund yarating. Har bir gap: 1) GRAMMATIK TO\'G\'RI 2) MANTIQAN G\'ALATI/KULGILI bo\'lsin. Mavzular aralashtirilsin. Har biri UNIQUE bo\'lsin.',
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
        isGame: true,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili A1-B2 grammatik o'yin yaratuvchisisan.
Faqat JSON qaytaring: {"rounds":[...]} — boshqa matn yo'q.

Har raund:
- type: "verb", "preposition", yoki "fillBlank"
- question: nemischa gap (ichida bitta bo'sh joy ___ bo'lsin)
- questionUz: o'zbekcha tarjima yoki gapning ma'nosi
- options: aynan 4 ta variant. FAQAT BITTASI to'g'ri.
- correctAnswer: to'g'ri variant (options ichidan)
- explanationUz: o'zbekcha izoh (nima uchun bu javob to'g'riligini va qoidani tushuntiring)

MAVZULAR (Shulardan erkin va aralashtirib foydalaning):
1. Dativ / Akkusativ / Genitiv kelishiklari (dem, den, des, einem, einen...)
2. Wechselpräpositionen (in, an, auf, unter... — qachon Dativ, qachon Akkusativ)
3. Temporale Präpositionen (vor, nach, seit, während, bis, ab — vaqt predloglari)
4. Kausale/Konzessive Konnektoren (deshalb, trotzdem, obwohl, deswegen, daher...)
5. Fe'llarning barcha zamonda turlanishi (Präsens, Perfekt, Präteritum, Futur I)
6. Modalverben (können, müssen, wollen, sollen, dürfen, mögen — to'g'ri shakli)
7. Trennbare va untrennbare Verben (aufmachen/anrufen vs. verstehen/besuchen)
8. Reflexive Verben (sich freuen, sich erinnern, sich waschen — to'g'ri shakli)
9. Nebensatz: dass, weil, wenn, ob, als, während, bevor, nachdem...
10. Relativsätze (Ich kenne den Mann, ___ hier wohnt)
11. zu + Infinitiv (Es ist wichtig, gesund ___ essen. / Ich versuche, früh aufzu___)
12. Adjektivdeklination (ein ___ Mann, dem ___ Kind, die ___ Frau)
13. Komparativ und Superlativ (schnell → schneller → am schnellsten)
14. Passiv (Das Buch ___ gelesen. / Die Tür wurde ___)
15. Konjunktiv II (würde, hätte, wäre — iltimos va shartli gaplar)
16. Indirekte Frage (Ich weiß nicht, ___ er kommt. / Weißt du, wo ___ ist?)
17. Zweiteilige Konnektoren (entweder...oder, weder...noch, sowohl...als auch, zwar...aber)
18. Lokale Präpositionen nozik farqlari (gegenüber, entlang, innerhalb, außerhalb...)
19. Genitivpräpositionen (wegen, trotz, während, statt + Genitiv)
20. Infinitivsatz bilan um...zu, ohne...zu, anstatt...zu

QAT'IY TAQIQLANADI:
- Oddiy "Der, Die, Das" (Nominativ artikelini topish) o'yinini QO'SHMANG! Buning uchun alohida o'yin bor.

MUHIM:
- Yuqoridagi mavzulardan HAR SAFAR boshqasini tanlang — bir xil mavzu ketma-ket kelmasin.
- Savollar qiziqarli, hayotiy va HAR SAFAR yangi fe'l/otlardan iborat bo'lsin.
- Variantlar orasida o'quvchini adashtiradigan mantiqiy xato javoblar bo'lsin.
- Har bir raundni mutlaqo UNIQUE qiling, takrorlamang.
- $count ta raund, har biri BOSHQA mavzudan.''',
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
        isGame: true,
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
