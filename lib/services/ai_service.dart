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
  /// Maxfiy kalitlar endi ilovada SAQLANMAYDI. Barcha so'rovlar Cloudflare
  /// Worker proksisi orqali yuboriladi; kalitlar o'sha yerda (Worker Secrets)
  /// turadi. Ilovada faqat maxfiy bo'lmagan ma'lumotlar qoladi:
  /// proksi URL va model nomlari.
  static String get _proxyUrl =>
      (dotenv.env['CF_WORKER_URL'] ?? '').trim().replaceAll(RegExp(r'/+$'), '');

  static String get _appToken => dotenv.env['APP_TOKEN']?.trim() ?? '';

  // Model nomlari (maxfiy emas) — kerak bo'lsa env orqali o'zgartirsa bo'ladi.
  static String get _qwenChatModel =>
      dotenv.env['QWEN_CHAT_MODEL']?.trim() ?? 'qwen3.5-122b-a10b';
  static String get _qwenGameModel =>
      dotenv.env['QWEN_GAME_MODEL']?.trim() ?? 'qwen-plus-latest';
  static String get _cerebrasModel =>
      dotenv.env['CEREBRAS_MODEL']?.trim() ?? 'gpt-oss-120b';
  static String get _mistralModel =>
      dotenv.env['MISTRAL_MODEL']?.trim() ?? 'mistral-small-latest';
  static String get _geminiModel =>
      dotenv.env['GEMINI_MODEL']?.trim() ?? 'gemini-2.0-flash';

  /// AI provayder identifikatorlari (worker'ga X-Provider header sifatida
  /// yuboriladi — kichik harflarda).
  static const String _pQwen = 'qwen';
  static const String _pCerebras = 'cerebras';
  static const String _pMistral = 'mistral';
  static const String _pGemini = 'gemini';

  /// Provayder uchun ishlatiladigan model nomini qaytaradi.
  static String _modelFor(String provider, bool isGame) {
    switch (provider) {
      case _pQwen:
        return isGame ? _qwenGameModel : _qwenChatModel;
      case _pCerebras:
        return _cerebrasModel;
      case _pMistral:
        return _mistralModel;
      case _pGemini:
        return _geminiModel;
      default:
        throw Exception('Noma\'lum provayder: $provider');
    }
  }

  /// Bitta provayderga (proksi orqali) so'rov yuboradi. Xatolik bo'lsa
  /// exception tashlaydi va zanjir keyingi provayderga o'tadi.
  static Future<String> _callProvider(
    String provider, {
    required List<Map<String, String>> messages,
    required double temperature,
    required bool isGame,
  }) async {
    return _chatViaProxy(
      provider: provider,
      model: _modelFor(provider, isGame),
      messages: messages,
      temperature: temperature,
    );
  }

  /// Provayderlarni berilgan tartibda sinab ko'radi; birortasi ishlasa
  /// natijani qaytaradi, hammasi xato bo'lsa exception tashlaydi.
  static Future<String> _chatOrdered({
    required List<String> order,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    bool isGame = false,
  }) async {
    Object? lastError;
    for (final provider in order) {
      try {
        return await _callProvider(
          provider,
          messages: messages,
          temperature: temperature,
          isGame: isGame,
        );
      } catch (e) {
        lastError = e;
        debugPrint('$provider failed: $e');
      }
    }
    throw Exception(
      'Barcha AI provayderlar ishlamadi (${order.join(", ")}). Oxirgi xato: $lastError',
    );
  }

  /// Standart fallback tartibi (chat, o'yinlar va h.k. uchun).
  static const List<String> _defaultOrder = [
    _pQwen,
    _pCerebras,
    _pMistral,
    _pGemini,
  ];

  /// Maqsadli til bo'yicha tarjima uchun eng mos provayder tartibi.
  /// - rus tili → Qwen birinchi (ruschada kuchli)
  /// - boshqa (o'zbek) → Gemini birinchi (kam resursli tillarda kuchli)
  static List<String> _translationOrder(String targetLang) {
    if (targetLang == 'ru') {
      return const [_pQwen, _pGemini, _pMistral, _pCerebras];
    }
    return const [_pGemini, _pQwen, _pCerebras, _pMistral];
  }

  static Future<String> _chat({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    bool isGame = false,
  }) {
    return _chatOrdered(
      order: _defaultOrder,
      messages: messages,
      temperature: temperature,
      isGame: isGame,
    );
  }

  /// So'rovni Cloudflare Worker proksisi orqali yuboradi.
  /// Ilova hech qanday API kalit yubormaydi — kalit worker ichida.
  static Future<String> _chatViaProxy({
    required String provider,
    required String model,
    required List<Map<String, String>> messages,
    required double temperature,
  }) async {
    if (_proxyUrl.isEmpty) {
      throw Exception('CF_WORKER_URL sozlanmagan');
    }

    final response = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Proxy-Target': 'ai',
            'X-Provider': provider,
            if (_appToken.isNotEmpty) 'X-App-Token': _appToken,
          },
          body: jsonEncode({
            'model': model,
            'temperature': temperature,
            'messages': messages,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('$provider so\'rov vaqti tugadi (30s)'),
        );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final bodySnippet = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      debugPrint('$provider error ${response.statusCode}: ${response.body}');
      throw Exception('$provider javob bermadi (${response.statusCode}): $bodySnippet');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('$provider javob bo\'sh');
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

  /// Yozilgan audioni matnga aylantiradi (Groq Whisper, Cloudflare Worker
  /// orqali). Nemis tili uchun `language: 'de'`. Brauzer/qurilma STT'siga
  /// bog'liq emas — web va telefonda bir xil ishlaydi.
  static Future<String> transcribeAudio({
    required Uint8List audioBytes,
    required String mimeType,
    String language = 'de',
  }) async {
    if (_proxyUrl.isEmpty) {
      throw Exception('CF_WORKER_URL sozlanmagan');
    }
    final response = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Proxy-Target': 'stt',
            if (_appToken.isNotEmpty) 'X-App-Token': _appToken,
          },
          body: jsonEncode({
            'audioBase64': base64Encode(audioBytes),
            'mimeType': mimeType,
            'language': language,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('STT javob bermadi (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['text'] ?? '').toString().trim();
  }

  /// Gemini Live real-time WebSocket URL'i (Cloudflare Worker proksisi).
  /// Zaxira: Worker proksi audio oqimida barqaror emas — asosan
  /// [liveDirectWebSocketUrl] ishlatiladi.
  static String liveWebSocketUrl({String apiVersion = 'v1beta'}) {
    if (_proxyUrl.isEmpty) {
      throw Exception('CF_WORKER_URL sozlanmagan');
    }
    final httpUri = Uri.parse(_proxyUrl);
    final wsUri = httpUri.replace(
      scheme: httpUri.scheme == 'http' ? 'ws' : 'wss',
      path: httpUri.path.isEmpty ? '/' : httpUri.path,
      queryParameters: {
        ...httpUri.queryParameters,
        'lv': apiVersion,
        if (_appToken.isNotEmpty) 't': _appToken,
      },
    );
    return wsUri.toString();
  }

  /// Ephemeral token bilan to'g'ridan-to'g'ri Gemini Live WebSocket URL'i.
  /// API kalit ilovaga chiqmaydi — faqat qisqa muddatli token ishlatiladi.
  /// Token [fetchGeminiLiveToken] orqali Worker'dan olinadi.
  static String liveDirectWebSocketUrl({required String token}) {
    const host = 'generativelanguage.googleapis.com';
    const path =
        '/ws/google.ai.generativelanguage.v1alpha.GenerativeService'
        '.BidiGenerateContent';
    return Uri(
      scheme: 'wss',
      host: host,
      path: path,
      queryParameters: {'access_token': token},
    ).toString();
  }

  /// Gemini Live (real-time ovozli AI) uchun qisqa muddatli token oladi.
  /// Token WebSocket ulanishida `access_token` sifatida ishlatiladi.
  static Future<String> fetchGeminiLiveToken() async {
    if (_proxyUrl.isEmpty) {
      throw Exception('CF_WORKER_URL sozlanmagan');
    }
    final response = await http.post(
      Uri.parse(_proxyUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-Proxy-Target': 'gemini-live-token',
        if (_appToken.isNotEmpty) 'X-App-Token': _appToken,
      },
      body: '{}',
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Live token olinmadi (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = (data['token'] ?? '').toString();
    if (token.isEmpty) throw Exception('Live token bo\'sh');
    return token;
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
    final isRu = targetLang == 'ru';
    final systemPrompt = isRu
        ? '''Ты профессиональный переводчик с немецкого на русский язык.
Переведи текст естественно и грамотно, сохраняя смысл, тон и стиль оригинала.
Не переводи дословно — передавай естественные формулировки русского языка.
Имена собственные оставляй без изменений.
Ответь ТОЛЬКО переводом, без пояснений, кавычек и дополнительного текста.'''
        : '''Sen nemis tilidan o'zbek tiliga tarjima qiluvchi professional tarjimonsan.
Matnni tabiiy va to'g'ri o'zbek tilida tarjima qil, ma'no, ohang va uslubni saqla.
So'zma-so'z tarjima qilma — o'zbek tilining tabiiy iboralarini ishlat.
Atoqli otlarni (ism, joy nomlari) o'zgartirmasdan qoldir.
FAQAT tarjimani yoz, izoh, qo'shtirnoq yoki qo'shimcha matn yo'q.''';

    return _chatOrdered(
      order: _translationOrder(targetLang),
      temperature: 0.2,
      messages: [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': text},
      ],
    );
  }

  static Future<Map<String, dynamic>> translateWithMeanings({
    required String text,
    String targetLang = 'uz',
  }) async {
    final isRu = targetLang == 'ru';

    final systemPrompt = isRu
        ? '''Ты немецко-русский лексикограф. Проанализируй немецкое слово или выражение и ответь в формате JSON.

Правила качества:
- Учитывай ВСЕ распространённые значения слова, каждое — отдельным элементом массива "meanings".
- Если это существительное, ОБЯЗАТЕЛЬНО укажи артикль и форму множественного числа в поле "grammar" (например: "der Tisch, -e").
- Если это глагол, укажи в "grammar" управление и форму Perfekt (например: "kommen, kam, ist gekommen").
- Пример предложения должен быть простым (уровень A1–B1) и естественным.
- "translation" — точный русский перевод значения.

Ответь ТОЛЬКО валидным JSON, без markdown и пояснений. Формат:
{
  "original": "немецкое слово",
  "meanings": [
    {
      "translation": "русский перевод",
      "grammar": "грамматическая информация (артикль/мн.число/управление)",
      "exampleGerman": "пример предложения на немецком",
      "exampleUzbek": "перевод примера на русский"
    }
  ]
}'''
        : '''Sen nemis-o'zbek lug'atshunosisan. Berilgan nemis so'z yoki iborani tahlil qilib, JSON formatida javob ber.

Sifat qoidalari:
- So'zning BARCHA keng tarqalgan ma'nolarini hisobga ol, har birini "meanings" massivida alohida element qil.
- Agar bu ot bo'lsa, "grammar" maydonida artikl va ko'plik shaklini ALBATTA ko'rsat (masalan: "der Tisch, -e").
- Agar bu fe'l bo'lsa, "grammar" maydonida fe'l boshqaruvi va Perfekt shaklini ko'rsat (masalan: "kommen, kam, ist gekommen").
- Misol gap oddiy (A1–B1 daraja) va tabiiy bo'lsin.
- "translation" — ma'noning aniq o'zbekcha tarjimasi.

FAQAT to'g'ri JSON qaytar, markdown yoki izohsiz. Format:
{
  "original": "nemischa so'z",
  "meanings": [
    {
      "translation": "o'zbekcha tarjima",
      "grammar": "grammatik ma'lumot (artikl/ko'plik/boshqaruv)",
      "exampleGerman": "nemischa misol gap",
      "exampleUzbek": "misolning o'zbekcha tarjimasi"
    }
  ]
}''';

    final raw = await _chatOrdered(
      order: _translationOrder(targetLang),
      temperature: 0.2,
      messages: [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': text},
      ],
    );

    try {
      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        if (!map.containsKey('original') ||
            map['original'] == null ||
            map['original'].toString().isEmpty) {
          map['original'] = text;
        }
        return map;
      }
    } catch (_) {}

    // Fallback: oddiy tarjima
    return {
      'original': text,
      'meanings': [
        {
          'translation': await translateGermanText(text: text, targetLang: targetLang),
          'grammar': '',
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
    required int wordCount,
    String level = 'B1',
    String? letter,
  }) async {
    final pointsBlock = points.map((p) => '• $p').join('\n');
    final letterBlock = (letter != null && letter.trim().isNotEmpty)
        ? '\nKIRISH XATI (o\'quvchi shunga javob yozadi):\n$letter\n'
        : '';

    // Baholash rubrikasi darajaga bog'liq. B1 (TELC Schriftlicher Ausdruck)
    // jami 45 ballga, A2 esa jami 20 ballga baholanadi.
    final scoringBlock = level == 'B1'
        ? '''
3. BAHOLASH (TELC B1 mezonlari, jami 45 ball)
Inhalt (barcha 4 majburiy punkt to'liq va mos yoritilgani): X/15
Kommunikative Gestaltung (stil/registr to'g'riligi, Anrede va Gruss, matnning bog'liqligi): X/10
Sprachliche Richtigkeit (grammatika, lug'at, imlo): X/15
Wortzahl (kamida $minWords so'z yozilgani): X/5
Jami: X/45'''
        : '''
3. BAHOLASH
Inhalt (mazmun): X/6
Stil (uslub): X/4
Grammatik va Wortschatz: X/6
Aufbau (tuzilish): X/2
Wortzahl (so'zlar soni): X/2
Jami: X/20''';

    return _chat(
      temperature: 0.2,
      messages: [
        {
          'role': 'system',
          'content': '''
Sen TELC $level Schriftlicher Ausdruck (Schreiben) imtihon tekshiruvchisisiz.
O'quvchi javobini O'ZBEK tilida bahola. Haqiqiy, tajribali o'qituvchidek yoz — halol, aniq va adolatli.
Hech qanday emoji, yulduzcha, qo'shtirnoq belgisi, markdown formatlashtirish (#, **, _) ishlatma.
Faqat oddiy matn va raqamlar.

DARAJA: $level.
MUHIM: So'zlar soni allaqachon aniq sanab berilgan: $wordCount ta so'z (talab: $minWords).

MAVZU TEKSHIRUVI (ENG MUHIM):
- Agar o'quvchi javobida berilgan topshiriqqa umuman mos kelmasa (butunlay boshqa mavzuda, bo'sh, yoki safsata), Inhalt uchun 0 ball ber va ochiq yoz.
- Agar 1-2 majburiy punkt bajarilmagan bo'lsa, Inhalt dan mos ravishda chegir.
- Agar mazmun to'liq mos bo'lsa, adolatli ball ber — lekin hech qachon 15/15 bera ko'rma, chunki kamchilik har doim topiladi.

XATOLARNI ANIQLASHDA JUDA ANIQ BO'L (soxta xato = jiddiy kamchilik):
- Faqat HAQIQIY grammatik/imlo xatolarini ko'rsat. To'g'ri yozilgan gapni XATO deb belgilama.
- Nemis grammatikasini puxta bil, quyidagilar TO'G'RI (bularni xato deb hisoblama):
  • Modalverb + Infinitiv: "ich möchte das Konzert besuchen", "ich kann morgen kommen", "wir sollen helfen" — infinitiv (besuchen/kommen/helfen) gapning OXIRIDA turadi. Buni "asosiy fe'l yo'q" yoki "fe'l to'liq emas" deb XATO deb ko'rsatma.
  • Nebensatz'da fe'l oxirida: "..., weil ich müde bin", "..., dass er kommt" — to'g'ri.
  • Perfekt: "ich habe es gemacht", "sie ist gekommen" — to'g'ri.
  • Trennbare Verben: "ich rufe dich an", "wir kaufen ein" — to'g'ri.
- Agar biror qismga ISHONCHING KOMIL bo'lmasa, uni xato deb YOZMA.
- Agar matnda ahamiyatli xato yo'q bo'lsa, "Ahamiyatli xato topilmadi" deb yoz va Sprachliche Richtigkeit uchun yuqori ball ber. Xato yo'q joyda xato o'ylab topma.

BAHOLASH QOʻLLANMASI (TELC B1, jami 45 ball):

Inhalt (0-15):
  15: Barcha 4 punkt to'liq, mavzuga mos, aniq va batafsil.
  10-14: 3-4 punkt bor, lekin ayrimlari yuzaki.
  5-9: 2 punt bor, qolganlar yo'q yoki mavzusiz.
  0-4: 0-1 punt bor yoki mavzuga umuman mos emas.

Kommunikative Gestaltung (0-10):
  10: Anrede, Gruss, matn oqimi a'lo, stil ($style) to'liq mos.
  7-9: Stil asosan to'g'ri, kichik kamchiliklar.
  4-6: Anrede yoki Gruss yo'q, stilga amal qilinmagan.
  0-3: Struktura yo'q, safsata yoki boshqa til.

Sprachliche Richtigkeit (0-15):
  13-15: Ozgina xato, mazmun tushuniladi.
  8-12: O'rtacha xatolar, lekin tushuniladi.
  3-7: Ko'p xato, tushunish qiyin.
  0-2: Deyarli hammasi noto'g'ri.

Wortzahl (0-5):
  5: $minWords yoki undan ko'p so'z.
  3: ${(minWords * 0.8).round()} dan ko'p so'z.
  0: ${(minWords * 0.8).round()} dan kam so'z.

Quyidagi tuzilmada yoz:

1. QISQA XULOSA
So'zlar soni: $wordCount / $minWords talab
Majburiy punktlar: har birini alohida — bajarilgan yoki bajarilmagan, qisqa sabab
Stil: to'g'ri ($style talab) yoki noto'g'ri
Mavzu muvofiqligi: mos yoki mos emas (agar mos emas bo'lsa, Inhalt = 0 sababi)
Umumiy izoh: 1-2 gap

2. XATOLAR VA TO'G'RILASH
Har bir muhim xatoni raqamlangan holda yoz:
Xato: noto'g'ri yozilgan qism.
To'g'risi: to'g'ri varianti.
Nega: grammatik qoida tushuntirmasi (artikl, kelishik, fe'l tuslanishi, so'z tartibi va h.k.)

Agar xato yo'q: Ahamiyatli xato topilmadi.

$scoringBlock

ESLATMA: Adolatli bo'l. Mavzudan chetga chiqqan yoki bo'sh javob uchun Inhalt = 0.
Grammatik xatolar ko'p bo'lsa Sprachliche Richtigkeit kam bo'lsin.
Hech qachon ball oshira ko'rma — bu real imtihon bahosi.''',
        },
        {
          'role': 'user',
          'content': '''
AUFGABE (Topshiriq):
$taskText
$letterBlock
MAJBURIY PUNKTLAR:
$pointsBlock

STIL: $style
MIN WÖRTER: $minWords
O'QUVCHI YOZGAN SO'ZLAR SONI (aniq sanalgan): $wordCount

O'QUVCHI JAVOBI (nemis tilida):
$answer
''',
        },
      ],
    );
  }

  /// Mock test Sprechen Teil 3 ("Gemeinsam etwas planen") — AI hamkor bilan
  /// bo'lgan butun suhbatni baholaydi. Audio emas, chat tarixiga asoslanadi.
  /// JSON qaytaradi: {score, pronunciation, fluency, grammar, content, overall}.
  static Future<Map<String, dynamic>> evaluateSprechenPlanung({
    required String situation,
    required List<String> keywords,
    required List<Map<String, dynamic>> history,
    String level = 'B1',
  }) async {
    final keywordsBlock = keywords.isNotEmpty
        ? keywords.map((k) => '- $k').join('\n')
        : '- (nuqtalar berilmagan)';

    // Suhbat tarixini "A" (o'quvchi) va "B" (AI hamkor) sifatida formatlaymiz.
    final transcript = StringBuffer();
    for (final item in history) {
      final role = (item['role'] ?? 'user').toString();
      final text = (item['text'] ?? '').toString().trim();
      if (text.isEmpty) continue;
      final speaker = role == 'assistant' ? 'Teilnehmer B (AI)' : 'Teilnehmer A (o\'quvchi)';
      transcript.writeln('$speaker: $text');
    }

    final raw = await _chat(
      temperature: 0.2,
      messages: [
        {
          'role': 'system',
          'content': '''
Sen TELC $level Sprechen Teil 3 ("Gemeinsam etwas planen") imtihon tekshiruvchisisiz.
Faqat JSON qaytaring — boshqa matn yo'q. Hech qanday emoji, markdown, qo'shtirnoq belgisi ishlatma.

Format (barcha maydonlar o'zbek tilida, faqat "score" — X/30 ko'rinishida):
{"score":"X/30","pronunciation":"...","fluency":"...","grammar":"...","content":"...","overall":"..."}

Maydonlar:
- score: umumiy ball "X/30" ko'rinishida (TELC B1 Sprechen Teil 3 = 30 ball).
- content: qaysi nuqtalar muhokama qilindi, qaysilari qoldi. Reja to'liqmi.
- grammar: grammatik xatolar — har birini to'g'risi bilan (agar bo'lsa). Xato yo'q bo'lsa shuni yoz.
- fluency: gaplarning ravonligi, hamkor bilan tabiiy muloqot, iboralar boyligi.
- pronunciation: bu chat mashqi (yozma), shuning uchun "Talaffuz baholanmadi (yozma mashq)" deb yoz.
- overall: 1-2 gaplik umumiy xulosa va tavsiya.

Ball mezonlari (score, jami 30 ball):
- 27-30: Barcha nuqtalar muhokama qilindi, grammatika yaxshi, iboralar boy, tabiiy muloqot.
- 21-26: Ko'p nuqtalar muhokama qilindi, kichik xatolar bor.
- 15-20: Asosiy nuqtalar bor, lekin grammatik xatolar ko'p.
- 8-14: Kam muhokama, ko'p xato, sodda gaplar.
- 0-7: Deyarli ishtirok etmadi, mavzudan chiqib ketdi yoki tushunarsiz.

ADOLATLI bo'l: o'quvchi kam gapirsa yoki nuqtalarni muhokama qilmasa, past ball ber.
Faqat o'quvchining (Teilnehmer A) gaplarini bahola — AI hamkorning gaplarini emas.''',
        },
        {
          'role': 'user',
          'content': '''
SITUATION (Topshiriq):
$situation

MUHOKAMA QILINISHI KERAK BO'LGAN NUQTALAR:
$keywordsBlock

SUHBAT TARIXI:
$transcript
''',
        },
      ],
    );

    return _parseJsonObject(raw);
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
    String difficulty = 'A1-B2',
  }) async {
    try {
      final difficultyGuide = switch (difficulty) {
        'A1' => 'Faqat A1 daraja: oddiy Präsens, einfache Satzstruktur, Nominativ/Akkusativ, einfache Präpositionen (in, auf, mit), haben/sein.',
        'A2' => 'Faqat A2 daraja: Perfekt, Dativ, Modalverben, trennbare Verben, weil/dass Nebensatz, Reflexivverben (einfach).',
        'B1' => 'Faqat B1 daraja: Präteritum, Konjunktiv II, Relativsätze, Passiv (einfach), Adjektivdeklination, Infinitiv mit zu.',
        'B2' => 'Faqat B2 daraja: Passiv (alle Zeiten), Konjunktiv I/II, Partizipialattribute, Nominalisierung, Genitivpräpositionen, zweiteilige Konnektoren.',
        _ => 'Aralash A1-B2: har xil daraja.',
      };

      final raw = await _chat(
        temperature: 0.9,
        isGame: true,
        messages: [
          {
            'role': 'system',
            'content': '''
Sen nemis tili grammatik o'yin yaratuvchisisan.
DARAJA: $difficulty
$difficultyGuide

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
- $count ta raund, har biri BOSHQA mavzudan.
- Savollar faqat $difficulty darajasiga mos bo'lsin — oson ham, qiyin ham qilmang.''',
          },
          {
            'role': 'user',
            'content': '$count ta yangi, BOSHQACHA grammatik raund yarating ($difficulty daraja).',
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
    final res = await _chat(
      temperature: 0.4,
      messages: [
        {
          'role': 'system',
          'content':
              'Nemis so\'zini o\'zbek tilida qisqa tushuntiring: ma\'nosi, artikl (der/die/das), 1 misol gap. MATNDA HECH QANDAY YULDUZCHA (*) YOKI BOLD (**) ISHLATMA. Oddiy matn formatida yoz.',
        },
        {'role': 'user', 'content': word},
      ],
    );
    return res.replaceAll('*', '');
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
    final startObj = trimmed.indexOf('{');
    final endObj = trimmed.lastIndexOf('}');
    final startArr = trimmed.indexOf('[');
    final endArr = trimmed.lastIndexOf(']');
    
    if (startObj != -1 && endObj != -1 && (startArr == -1 || startObj < startArr)) {
      return trimmed.substring(startObj, endObj + 1);
    }
    if (startArr != -1 && endArr != -1) {
      return trimmed.substring(startArr, endArr + 1);
    }
    return trimmed;
  }
}
