// dart run tool/generate_game_word_i18n.dart
import 'dart:convert';
import 'dart:io';

final _src = File('lib/utils/game_words.dart');
final _out = File('lib/utils/game_words_i18n.dart');

final _entryRe = RegExp(
  r"\{'word': '((?:\\'|[^'])*)', 'article': '((?:\\'|[^'])*)', 'translation': '((?:\\'|[^'])*)'\}",
);

String _unescape(String s) => s.replaceAll(r"\'", "'");

String _escape(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

Future<String?> _translate(String text, String from, String to) async {
  if (text.trim().isEmpty) return text;
  final uri = Uri.parse(
    'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$from|$to',
  );
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final data = json['responseData'] as Map<String, dynamic>?;
    final translated = data?['translatedText'] as String?;
    if (translated == null || translated.toUpperCase() == text.toUpperCase()) {
      return null;
    }
    return translated;
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

List<String> args = [];

Future<void> main(List<String> arguments) async {
  args = arguments;
  final text = _src.readAsStringSync();
  final entries = <Map<String, String>>[];
  for (final m in _entryRe.allMatches(text)) {
    entries.add({
      'word': _unescape(m.group(1)!),
      'article': _unescape(m.group(2)!),
      'uz': _unescape(m.group(3)!),
    });
  }
  stdout.writeln('Parsed ${entries.length} entries');

  final cachePath = File('tool/translation_cache.json');
  Map<String, dynamic> cache = {};
  if (cachePath.existsSync()) {
    cache = jsonDecode(cachePath.readAsStringSync()) as Map<String, dynamic>;
  }

  final uzTexts = entries.map((e) => e['uz']!).toSet().toList();
  final ruByUz = Map<String, String>.from(
    (cache['ru'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as String)) ?? {},
  );
  final kaaByUz = Map<String, String>.from(
    (cache['kaa'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as String)) ?? {},
  );

  final skipApi = args.contains('--cache-only');
  if (skipApi) stdout.writeln('Using cache only (--cache-only)');

  for (var i = 0; i < uzTexts.length; i++) {
    final uz = uzTexts[i];
    if (skipApi) continue;
    if (!ruByUz.containsKey(uz)) {
      stdout.writeln('RU ${i + 1}/${uzTexts.length}: $uz');
      ruByUz[uz] = await _translate(uz, 'uz', 'ru') ?? uz;
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
  }
  for (var i = 0; i < uzTexts.length; i++) {
    final uz = uzTexts[i];
    if (skipApi) continue;
    if (!kaaByUz.containsKey(uz)) {
      stdout.writeln('KAA ${i + 1}/${uzTexts.length}: $uz');
      // Qaraqalpaq: kk (qozoq) yoki uz fallback
      kaaByUz[uz] = await _translate(uz, 'uz', 'kk') ?? uz;
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
  }

  cache['ru'] = ruByUz;
  cache['kaa'] = kaaByUz;
  cachePath.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(cache));

  final buffer = StringBuffer('''
// GENERATED — dart run tool/generate_game_word_i18n.dart
import 'game_words.dart';

class GameWordsI18n {
  static String localized(Map<String, String> entry, String localeCode) {
    final uz = entry['uz'] ?? entry['translation'] ?? '';
    switch (localeCode) {
      case 'ru':
        return entry['ru'] ?? _ruByUz[uz] ?? uz;
      case 'kaa':
        return entry['kaa'] ?? _kaaByUz[uz] ?? uz;
      case 'de':
        return entry['de'] ?? GameWords.nounWithoutArticle(entry);
      default:
        return uz;
    }
  }

  static const Map<String, String> _ruByUz = {
''');

  for (final uz in uzTexts) {
    final ru = _escape(ruByUz[uz] ?? uz);
    buffer.writeln("    '${_escape(uz)}': '$ru',");
  }

  buffer.writeln('  };\n');
  buffer.writeln('  static const Map<String, String> _kaaByUz = {');
  for (final uz in uzTexts) {
    final kaa = _escape(kaaByUz[uz] ?? uz);
    buffer.writeln("    '${_escape(uz)}': '$kaa',");
  }
  buffer.writeln('  };');
  buffer.writeln('}');

  _out.writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote ${_out.path}');
}
