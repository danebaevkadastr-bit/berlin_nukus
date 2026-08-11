import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ai_service.dart';

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

  bool get isMastered => learningStage >= 3;

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
  final String grammar;
  final String exampleGerman;
  final String exampleUzbek;

  WordMeaning({
    required this.translation,
    this.grammar = '',
    required this.exampleGerman,
    required this.exampleUzbek,
  });

  Map<String, dynamic> toMap() => {
        'translation': translation,
        'grammar': grammar,
        'exampleGerman': exampleGerman,
        'exampleUzbek': exampleUzbek,
      };

  factory WordMeaning.fromMap(Map<String, dynamic> map) {
    return WordMeaning(
      translation: map['translation']?.toString() ?? '',
      grammar: map['grammar']?.toString() ?? '',
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
    List<SavedWord> localWords = [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      localWords = list
          .map((e) => SavedWord.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {}

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('data')
            .doc('vocabulary')
            .get();
        if (doc.exists && doc.data() != null) {
          final rawList = doc.data()!['words'] as List<dynamic>?;
          if (rawList != null) {
            final remoteWords = rawList
                .map((e) => SavedWord.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList();

            final map = <String, SavedWord>{};
            for (final w in remoteWords) {
              map[w.germanWord.toLowerCase()] = w;
            }
            for (final w in localWords) {
              map[w.germanWord.toLowerCase()] = w;
            }
            final merged = map.values.toList();
            merged.sort((a, b) => b.savedAt.compareTo(a.savedAt));
            final listEncoded = merged.map((w) => w.toMap()).toList();
            await prefs.setString(_key, jsonEncode(listEncoded));
            return merged;
          }
        }
      } catch (e) {
        debugPrint('Firestore vocabulary get error: $e');
      }
    }

    return localWords;
  }

  static Future<void> saveWords(List<SavedWord> words) async {
    final prefs = await SharedPreferences.getInstance();
    final list = words.map((w) => w.toMap()).toList();
    await prefs.setString(_key, jsonEncode(list));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('data')
            .doc('vocabulary')
            .set({'words': list}, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore vocabulary save error: $e');
      }
    }
  }

  static Future<void> addWord(SavedWord word) async {
    await addWordsBatch([word]);
  }

  /// Bir vaqtda bir nechta so'zni xavfsiz saqlash
  static Future<void> addWordsBatch(List<SavedWord> newWords) async {
    if (newWords.isEmpty) return;
    final words = await getSavedWords();
    for (final newW in newWords) {
      if (!words.any((w) => w.germanWord.toLowerCase() == newW.germanWord.toLowerCase())) {
        words.insert(0, newW);
      }
    }
    await saveWords(words);
  }

  /// Nemischa so'zni foydalanuvchi kiritganda Gemini AI orqali avtomatik tarjima qilib saqlaydi.
  static Future<SavedWord> addWordWithAi({
    required String germanWord,
    required String uiLangCode,
  }) async {
    final cleanWord = germanWord.trim();
    final analyzed = await AIService.analyzeWord(cleanWord, uiLangCode);

    final meaningsList = (analyzed['meanings'] as List<dynamic>?)
            ?.map((m) => WordMeaning.fromMap(Map<String, dynamic>.from(m as Map)))
            .toList() ??
        [
          WordMeaning(
            translation: analyzed['translation']?.toString() ?? 'Tarjima qilib bo\'lmadi',
            exampleGerman: '',
            exampleUzbek: '',
          )
        ];

    final saved = SavedWord(
      germanWord: analyzed['original']?.toString() ?? cleanWord,
      meanings: meaningsList,
      savedAt: DateTime.now(),
      learningStage: 0,
    );

    await addWord(saved);
    return saved;
  }

  /// Ko'plab so'zlarni yoki matnni AI orqali bir vaqtda tahlil qilib lug'atga qo'shadi
  static Future<int> addBulkWordsWithAi({
    required String text,
    required String uiLangCode,
  }) async {
    final cleanInput = text.trim();
    if (cleanInput.isEmpty) return 0;

    final analyzedList = await AIService.analyzeBulkWords(cleanInput, uiLangCode);
    if (analyzedList.isEmpty) {
      // Agar AI ajrata olmasa, bitta so'z deb harakat qilib ko'ramiz
      await addWordWithAi(germanWord: cleanInput, uiLangCode: uiLangCode);
      return 1;
    }

    final newWordsToSave = <SavedWord>[];
    for (final analyzed in analyzedList) {
      final topTranslation = analyzed['translation']?.toString().trim() ?? '';
      final topGrammar = analyzed['grammar']?.toString().trim() ?? '';

      var meaningsList = (analyzed['meanings'] as List<dynamic>?)
              ?.map((m) => WordMeaning.fromMap(Map<String, dynamic>.from(m as Map)))
              .toList() ??
          [];

      if (meaningsList.isEmpty) {
        meaningsList = [
          WordMeaning(
            translation: topTranslation.isNotEmpty ? topTranslation : 'Tarjima qilib bo\'lmadi',
            grammar: topGrammar,
            exampleGerman: '',
            exampleUzbek: '',
          )
        ];
      } else {
        meaningsList = meaningsList.map((m) {
          final tr = m.translation.trim().isNotEmpty
              ? m.translation.trim()
              : (topTranslation.isNotEmpty ? topTranslation : 'Tarjima qilib bo\'lmadi');
          final gr = m.grammar.trim().isNotEmpty ? m.grammar.trim() : topGrammar;
          return WordMeaning(
            translation: tr,
            grammar: gr,
            exampleGerman: m.exampleGerman,
            exampleUzbek: m.exampleUzbek,
          );
        }).toList();
      }

      final german = analyzed['original']?.toString().trim() ?? '';
      if (german.isNotEmpty) {
        newWordsToSave.add(
          SavedWord(
            germanWord: german,
            meanings: meaningsList,
            savedAt: DateTime.now(),
            learningStage: 0,
          ),
        );
      }
    }

    await addWordsBatch(newWordsToSave);
    return newWordsToSave.length;
  }

  /// So'zni lug'atdan o'chirish
  static Future<void> deleteWord(String germanWord) async {
    final words = await getSavedWords();
    words.removeWhere((w) => w.germanWord.toLowerCase() == germanWord.toLowerCase());
    await saveWords(words);
  }

  /// So'zni "Bugun yod olish kerak" va "Yod olib bo'linganlar" holatlari o'rtasida o'tkazish
  static Future<void> toggleMastered(String germanWord) async {
    final words = await getSavedWords();
    final idx = words.indexWhere((w) => w.germanWord.toLowerCase() == germanWord.toLowerCase());
    if (idx != -1) {
      if (words[idx].learningStage >= 3) {
        words[idx].learningStage = 0; // Yangi
      } else {
        words[idx].learningStage = 3; // O'zlashtirilgan
      }
      await saveWords(words);
    }
  }
}
