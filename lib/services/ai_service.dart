import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  static String get _apiKey => dotenv.env['QWEN_API_KEY']?.trim() ?? '';
  static String get _baseUrl =>
      (dotenv.env['QWEN_BASE_URL'] ?? '').trim().replaceAll(RegExp(r'/+$'), '');
  static String get _model =>
      dotenv.env['QWEN_MODEL']?.trim() ?? 'qwen-plus-latest';

  static Future<String> _chat({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  }) async {
    if (_apiKey.isEmpty || _baseUrl.isEmpty) {
      throw Exception(
        'QWEN_API_KEY yoki QWEN_BASE_URL .env faylida topilmadi',
      );
    }

    final uri = Uri.parse('$_baseUrl/chat/completions');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': temperature,
        'messages': messages,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('Qwen error ${response.statusCode}: ${response.body}');
      throw Exception('AI javob bermadi (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('AI javob bo\'sh');
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
    return _chat(messages: messages);
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

  static Future<List<String>> getReplyHints({required String context}) async {
    final raw = await _chat(
      temperature: 0.8,
      messages: [
        {
          'role': 'system',
          'content':
              'Nemis tili suhbati uchun 3 ta qisqa javob taklifi bering. '
              'Har biri 1-2 gap, A1-B1 darajada. Faqat JSON massiv: ["gap1","gap2","gap3"]',
        },
        {'role': 'user', 'content': context},
      ],
    );

    try {
      final decoded = jsonDecode(_extractJson(raw));
      if (decoded is List) {
        return decoded.map((e) => e.toString()).where((s) => s.isNotEmpty).take(3).toList();
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
