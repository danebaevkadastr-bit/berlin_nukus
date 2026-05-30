import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedWord {
  final String germanWord;
  final List<WordMeaning> meanings;
  final DateTime savedAt;
  int learningStage; // 0: yangi, 1-2: o'rganilayotgan, 3: o'zlashtirilgan

  SavedWord({
    required this.germanWord,
    required this.meanings,
    required this.savedAt,
    this.learningStage = 0,
  });

  Map<String, dynamic> toMap() => {
        'germanWord': germanWord,
        'meanings': meanings.map((m) => m.toMap()).toList(),
        'savedAt': savedAt.toIso8601String(),
        'learningStage': learningStage,
      };

  factory SavedWord.fromMap(Map<String, dynamic> map) {
    return SavedWord(
      germanWord: map['germanWord']?.toString() ?? '',
      meanings: (map['meanings'] as List<dynamic>?)
              ?.map((e) => WordMeaning.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      savedAt: DateTime.tryParse(map['savedAt']?.toString() ?? '') ?? DateTime.now(),
      learningStage: map['learningStage'] as int? ?? 0,
    );
  }
}

class WordMeaning {
  final String translation;
  final String exampleGerman;
  final String exampleUzbek;

  WordMeaning({
    required this.translation,
    required this.exampleGerman,
    required this.exampleUzbek,
  });

  Map<String, dynamic> toMap() => {
        'translation': translation,
        'exampleGerman': exampleGerman,
        'exampleUzbek': exampleUzbek,
      };

  factory WordMeaning.fromMap(Map<String, dynamic> map) {
    return WordMeaning(
      translation: map['translation']?.toString() ?? '',
      exampleGerman: map['exampleGerman']?.toString() ?? '',
      exampleUzbek: map['exampleUzbek']?.toString() ?? '',
    );
  }
}

class VocabularyService {
  static const String _key = 'saved_vocabulary';

  static Future<List<SavedWord>> getSavedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '[]';
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedWord.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveWords(List<SavedWord> words) async {
    final prefs = await SharedPreferences.getInstance();
    final list = words.map((w) => w.toMap()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<void> addWord(SavedWord word) async {
    final words = await getSavedWords();
    // Check if word already exists
    if (!words.any((w) => w.germanWord.toLowerCase() == word.germanWord.toLowerCase())) {
      words.insert(0, word);
      await saveWords(words);
    }
  }
}
