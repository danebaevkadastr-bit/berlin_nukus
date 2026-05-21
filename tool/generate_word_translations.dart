// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// game_words.dart dan ru/kaa tarjimalarni generatsiya qiladi.
/// Ishga tushirish: dart run tool/generate_word_translations.dart
Future<void> main() async {
  final source = File('lib/utils/game_words.dart').readAsStringSync();
  final wordRe = RegExp(
    r"\{'word': '((?:\\'|[^'])*)', 'article': '((?:\\'|[^'])*)', 'translation': '((?:\\'|[^'])*)'\}",
  );

  final entries = <({String word, String uz})>[];
  for (final m in wordRe.allMatches(source)) {
    entries.add((
      word: _unescape(m.group(1)!),
      uz: _unescape(m.group(3)!),
    ));
  }

  print('Topildi: ${entries.length} ta so\'z');

  final ru = <String, String>{};
  final kaa = <String, String>{};

  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    stdout.write('\r${i + 1}/${entries.length}');
    ru[e.word] = await _translate(e.uz, 'uz', 'ru');
    await Future.delayed(const Duration(milliseconds: 120));
    kaa[e.word] = await _translate(e.uz, 'uz', 'kk'); // qaraqalpaq — kk yaqin
    await Future.delayed(const Duration(milliseconds: 120));
  }
  print('\nYozilmoqda...');

  final buffer = StringBuffer('''
// GENERATED — qo\'lda tahrirlamang. Qayta: dart run tool/generate_word_translations.dart
// ignore_for_file: constant_identifier_names

class DerDieDasTranslations {
  DerDieDasTranslations._();

  static const Map<String, Map<String, String>> byWord = {
''');

  for (final e in entries) {
    buffer.writeln("    ${_dartStr(e.word)}: {");
    buffer.writeln("      'uz': ${_dartStr(e.uz)},");
    buffer.writeln("      'ru': ${_dartStr(ru[e.word] ?? e.uz)},");
    buffer.writeln("      'kaa': ${_dartStr(kaa[e.word] ?? e.uz)},");
    buffer.writeln('    },');
  }

  buffer.writeln('  };');
  buffer.writeln('}');

  await File('lib/data/der_die_das_translations.g.dart').writeAsString(buffer.toString());
  print('Saqlandi: lib/data/der_die_das_translations.g.dart');
}

String _unescape(String s) => s.replaceAll(r"\'", "'");

String _dartStr(String s) {
  final escaped = s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  return "'$escaped'";
}

Future<String> _translate(String text, String from, String to) async {
  final uri = Uri.parse(
    'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$from|$to',
  );
  try {
    final client = HttpClient();
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    client.close(force: true);
    final json = jsonDecode(body) as Map<String, dynamic>;
    final translated = (json['responseData'] as Map?)?['translatedText'] as String?;
    if (translated != null && translated.isNotEmpty) {
      return translated.trim();
    }
  } catch (e) {
    stderr.writeln(' Tarjima xato ($text): $e');
  }
  return text;
}
