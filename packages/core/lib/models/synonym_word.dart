import 'dart:math';

/// Sinonim so'z ma'lumotlari modeli
/// 
/// Bu model nemis so'zlari va ularning sinonimlarini saqlash uchun ishlatiladi.
/// Har bir so'z uchun o'zbek tilidagi tarjima va qiyinlik darajasi ham saqlanadi.
class SynonymWord {
  /// Nemis so'zi (masalan: "schnell")
  final String word;

  /// O'zbek tilidagi tarjima (masalan: "tez")
  final String translation;

  /// To'g'ri sinonimlar ro'yxati (kamida 1 ta)
  final List<String> synonyms;

  /// Qiyinlik darajasi: "easy", "medium", "hard"
  final String difficulty;

  const SynonymWord({
    required this.word,
    required this.translation,
    required this.synonyms,
    required this.difficulty,
  });

  /// Tasodifiy sinonim olish
  /// 
  /// Sinonimlar ro'yxatidan tasodifiy bitta sinonimni qaytaradi.
  /// Bu savol generatsiya qilishda to'g'ri javobni tanlash uchun ishlatiladi.
  String get randomSynonym => synonyms[Random().nextInt(synonyms.length)];
}
