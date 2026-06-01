import 'dart:math';

import '../models/synonym_word.dart';

/// Sinonim ma'lumotlari utility class
///
/// Bu class nemis so'zlari va ularning sinonimlarini saqlaydi.
/// O'yin uchun so'zlarni aralashtirish va variantlar generatsiya qilish
/// metodlarini taqdim etadi.
class SynonymData {
  /// Barcha sinonim so'zlar ro'yxati (55+ so'z)
  /// Qiyinlik darajalari: easy (~20), medium (~20), hard (~15)
  static const List<SynonymWord> allWords = [
    // ===== OSON (Easy) - 20 ta =====
    // Kundalik hayotda ko'p ishlatiladigan oddiy so'zlar
    SynonymWord(
      word: 'schnell',
      translation: 'tez',
      synonyms: ['rasch', 'flink', 'zügig'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'groß',
      translation: 'katta',
      synonyms: ['riesig', 'gewaltig', 'enorm'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'klein',
      translation: 'kichik',
      synonyms: ['winzig', 'gering', 'minimal'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'gut',
      translation: 'yaxshi',
      synonyms: ['prima', 'toll', 'super'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'schlecht',
      translation: 'yomon',
      synonyms: ['mies', 'übel', 'miserabel'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'schön',
      translation: 'chiroyli',
      synonyms: ['hübsch', 'attraktiv', 'wunderschön'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'alt',
      translation: 'eski/keksa',
      synonyms: ['betagt', 'antik', 'uralt'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'neu',
      translation: 'yangi',
      synonyms: ['frisch', 'modern', 'aktuell'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'kalt',
      translation: 'sovuq',
      synonyms: ['kühl', 'frostig', 'eisig'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'warm',
      translation: 'iliq',
      synonyms: ['heiß', 'mild', 'lauwarm'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'laut',
      translation: 'baland (ovoz)',
      synonyms: ['lärmend', 'geräuschvoll', 'schrill'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'leise',
      translation: 'past (ovoz)',
      synonyms: ['still', 'ruhig', 'gedämpft'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'hell',
      translation: 'yorug\'',
      synonyms: ['leuchtend', 'strahlend', 'licht'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'dunkel',
      translation: 'qorong\'i',
      synonyms: ['finster', 'düster', 'trüb'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'schwer',
      translation: 'og\'ir',
      synonyms: ['gewichtig', 'massiv', 'wuchtig'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'leicht',
      translation: 'yengil',
      synonyms: ['federleicht', 'mühelos', 'simpel'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'lang',
      translation: 'uzun',
      synonyms: ['ausgedehnt', 'langgestreckt', 'endlos'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'kurz',
      translation: 'qisqa',
      synonyms: ['knapp', 'kompakt', 'bündig'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'nah',
      translation: 'yaqin',
      synonyms: ['nahe', 'benachbart', 'angrenzend'],
      difficulty: 'easy',
    ),
    SynonymWord(
      word: 'weit',
      translation: 'uzoq',
      synonyms: ['fern', 'entfernt', 'abgelegen'],
      difficulty: 'easy',
    ),

    // ===== O'RTA (Medium) - 20 ta =====
    // Biroz murakkab, lekin tez-tez ishlatiladigan so'zlar
    SynonymWord(
      word: 'verstehen',
      translation: 'tushunmoq',
      synonyms: ['begreifen', 'kapieren', 'erfassen'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'sprechen',
      translation: 'gapirmoq',
      synonyms: ['reden', 'plaudern', 'kommunizieren'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'arbeiten',
      translation: 'ishlamoq',
      synonyms: ['schaffen', 'wirken', 'tätig sein'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'beginnen',
      translation: 'boshlamoq',
      synonyms: ['anfangen', 'starten', 'einleiten'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'beenden',
      translation: 'tugatmoq',
      synonyms: ['abschließen', 'vollenden', 'fertigstellen'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'helfen',
      translation: 'yordam bermoq',
      synonyms: ['unterstützen', 'beistehen', 'assistieren'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'kaufen',
      translation: 'sotib olmoq',
      synonyms: ['erwerben', 'anschaffen', 'besorgen'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'verkaufen',
      translation: 'sotmoq',
      synonyms: ['veräußern', 'absetzen', 'vertreiben'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'wichtig',
      translation: 'muhim',
      synonyms: ['bedeutend', 'wesentlich', 'relevant'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'möglich',
      translation: 'mumkin',
      synonyms: ['machbar', 'realisierbar', 'denkbar'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'schwierig',
      translation: 'qiyin',
      synonyms: ['kompliziert', 'anspruchsvoll', 'knifflig'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'einfach',
      translation: 'oson',
      synonyms: ['simpel', 'unkompliziert', 'problemlos'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'glücklich',
      translation: 'baxtli',
      synonyms: ['froh', 'zufrieden', 'erfreut'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'traurig',
      translation: 'g\'amgin',
      synonyms: ['betrübt', 'niedergeschlagen', 'bekümmert'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'müde',
      translation: 'charchagan',
      synonyms: ['erschöpft', 'matt', 'abgespannt'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'hungrig',
      translation: 'och',
      synonyms: ['ausgehungert', 'heißhungrig', 'gierig'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'interessant',
      translation: 'qiziqarli',
      synonyms: ['spannend', 'fesselnd', 'faszinierend'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'langweilig',
      translation: 'zerikarli',
      synonyms: ['öde', 'monoton', 'eintönig'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'freundlich',
      translation: 'do\'stona',
      synonyms: ['nett', 'liebenswürdig', 'herzlich'],
      difficulty: 'medium',
    ),
    SynonymWord(
      word: 'böse',
      translation: 'yomon/g\'azablangan',
      synonyms: ['wütend', 'zornig', 'verärgert'],
      difficulty: 'medium',
    ),

    // ===== QIYIN (Hard) - 15 ta =====
    // Murakkab va kam ishlatiladigan so'zlar
    SynonymWord(
      word: 'beeindruckend',
      translation: 'ta\'sirli',
      synonyms: ['imposant', 'eindrucksvoll', 'überwältigend'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'außergewöhnlich',
      translation: 'g\'ayrioddiy',
      synonyms: ['ungewöhnlich', 'einzigartig', 'exzeptionell'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'hervorragend',
      translation: 'ajoyib',
      synonyms: ['ausgezeichnet', 'exzellent', 'vorzüglich'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'zuverlässig',
      translation: 'ishonchli',
      synonyms: ['verlässlich', 'vertrauenswürdig', 'beständig'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'verantwortlich',
      translation: 'mas\'ul',
      synonyms: ['zuständig', 'haftbar', 'rechenschaftspflichtig'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'selbstständig',
      translation: 'mustaqil',
      synonyms: ['unabhängig', 'eigenständig', 'autonom'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'gründlich',
      translation: 'puxta',
      synonyms: ['sorgfältig', 'gewissenhaft', 'akribisch'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'offensichtlich',
      translation: 'aniq/ravshan',
      synonyms: ['augenscheinlich', 'ersichtlich', 'evident'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'wahrscheinlich',
      translation: 'ehtimol',
      synonyms: ['vermutlich', 'voraussichtlich', 'mutmaßlich'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'notwendig',
      translation: 'zarur',
      synonyms: ['erforderlich', 'unerlässlich', 'unabdingbar'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'überraschen',
      translation: 'hayratga solmoq',
      synonyms: ['verblüffen', 'erstaunen', 'verwundern'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'überzeugen',
      translation: 'ishontirmoq',
      synonyms: ['überreden', 'bekehren', 'umstimmen'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'entwickeln',
      translation: 'rivojlantirmoq',
      synonyms: ['entfalten', 'ausarbeiten', 'konzipieren'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'verbessern',
      translation: 'yaxshilamoq',
      synonyms: ['optimieren', 'perfektionieren', 'verfeinern'],
      difficulty: 'hard',
    ),
    SynonymWord(
      word: 'berücksichtigen',
      translation: 'hisobga olmoq',
      synonyms: ['beachten', 'einbeziehen', 'erwägen'],
      difficulty: 'hard',
    ),
  ];

  /// Jami so'zlar soni
  static int get totalWords => allWords.length;

  /// Qiyinlik darajasi bo'yicha so'zlar soni
  static int get easyWordsCount =>
      allWords.where((w) => w.difficulty == 'easy').length;
  static int get mediumWordsCount =>
      allWords.where((w) => w.difficulty == 'medium').length;
  static int get hardWordsCount =>
      allWords.where((w) => w.difficulty == 'hard').length;

  /// Tasodifiy aralashtrilgan so'zlar olish
  ///
  /// [limit] - qaytariladigan so'zlar soni (default: 10)
  /// Agar limit jami so'zlar sonidan katta bo'lsa, barcha so'zlar qaytariladi.
  static List<SynonymWord> shuffledWords({int limit = 10}) {
    final shuffled = List<SynonymWord>.from(allWords)..shuffle(Random());
    return shuffled.take(limit.clamp(1, allWords.length)).toList();
  }

  /// Noto'g'ri variantlar (distractors) generatsiya qilish
  ///
  /// [word] - joriy so'z (uning sinonimlaridan tashqari)
  /// [count] - kerakli noto'g'ri variantlar soni
  ///
  /// Boshqa so'zlarning sinonimlaridan tasodifiy tanlab qaytaradi.
  /// Joriy so'zning sinonimlarini o'z ichiga olmaydi.
  static List<String> generateDistractors(SynonymWord word, int count) {
    // Barcha so'zlardan sinonimlarni yig'ish (joriy so'znikidan tashqari)
    final allSynonyms = <String>[];
    for (final w in allWords) {
      if (w.word != word.word) {
        // Joriy so'zning sinonimlarini qo'shmaslik
        for (final synonym in w.synonyms) {
          if (!word.synonyms.contains(synonym)) {
            allSynonyms.add(synonym);
          }
        }
      }
    }

    // Takrorlanishlarni olib tashlash
    final uniqueSynonyms = allSynonyms.toSet().toList();

    // Tasodifiy aralashtirish va kerakli miqdorni olish
    uniqueSynonyms.shuffle(Random());
    return uniqueSynonyms.take(count.clamp(1, uniqueSynonyms.length)).toList();
  }

  /// Savol uchun 4 ta variant yaratish (1 to'g'ri + 3 noto'g'ri)
  ///
  /// [word] - savol so'zi
  ///
  /// Qaytarilgan ro'yxatda faqat bitta to'g'ri sinonim bo'ladi,
  /// qolgan 3 tasi boshqa so'zlarning sinonimlaridan olinadi.
  /// Variantlar tasodifiy tartibda joylashtiriladi.
  static List<String> generateOptions(SynonymWord word) {
    // To'g'ri sinonimni olish
    final correctSynonym = word.randomSynonym;

    // 3 ta noto'g'ri variant olish
    final distractors = generateDistractors(word, 3);

    // Barcha variantlarni birlashtirish va aralashtirish
    final options = [correctSynonym, ...distractors];
    options.shuffle(Random());

    return options;
  }

  /// Qiyinlik darajasi bo'yicha so'zlarni olish
  ///
  /// [difficulty] - qiyinlik darajasi: "easy", "medium", "hard"
  static List<SynonymWord> getWordsByDifficulty(String difficulty) {
    return allWords.where((w) => w.difficulty == difficulty).toList();
  }
}
