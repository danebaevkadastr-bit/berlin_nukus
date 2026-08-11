/// Der / Die / Das o'yini qoidalari va sozlamalari.
class DerDieDasRules {
  static const String gameTitle = 'Der, Die, Das';
  static const int questionsPerRound = 10;
  static const int secondsPerQuestion = 12;
  static const int pointsPerCorrect = 10;
  static const int streakBonusEvery = 3;
  static const int streakBonusPoints = 5;

  static const String howToPlayTitle = 'O\'yin qoidalari';

  static String get howToPlayText => '''
• Har raundda $questionsPerRound ta so'z beriladi.
• Ot artiklsiz ko'rsatiladi — siz DER, DIE yoki DAS ni tanlaysiz.
• Har savol uchun $secondsPerQuestion soniya vaqt bor.
• To'g'ri javob: +$pointsPerCorrect ball.
• Ketma-ket $streakBonusEvery ta to'g'ri javob: qo'shimcha +$streakBonusPoints ball.
• So'zlar bazadan tasodifiy tanlanadi va aralashtiriladi.
''';

  static const List<ArticleRuleSection> articleSections = [
    ArticleRuleSection(
      article: 'der',
      colorName: 'blue',
      emoji: '🔵',
      title: 'DER — erkil (maskulin)',
      tips: [
        'Erkak shaxslar va kasblar: der Mann, der Lehrer, der Arzt',
        'Kunlar, oylar (aprel dan tashqari ba\'zilari), fasillar: der Montag, der Januar, der Sommer',
        'Yo\'nalishlar va shamollar: der Norden, der Wind',
        'Daraxt va meva turlari (olma, nok): der Apfel, der Baum',
        'Ichidan -er/-ling/-ig tugaydigan ko\'plab otlar: der Lehrer, der König',
        'Alkogol va ichimliklar (ko\'pincha): der Wein, der Kaffee, der Tee',
        'Transport vositalari: der Bus, der Zug, der Wagen',
      ],
    ),
    ArticleRuleSection(
      article: 'die',
      colorName: 'red',
      emoji: '🔴',
      title: 'DIE — urg\'u (feminin)',
      tips: [
        'Ayol shaxslar va kasblar: die Frau, die Lehrerin, die Ärztin',
        'Ko\'plik shakl (barcha artikllar): die Männer, die Kinder, die Häuser',
        '-ung, -heit, -keit, -schaft, -tät, -ik, -ei, -in (kasb): die Wohnung, die Freiheit, die Universität',
        'Darajalar va raqamlar (ko\'pincha): die erste, die Million',
        'Oylar (aprel): der April — istisno; qolganlari ko\'pincha die: die Januar istisnolar bor',
        'Gullar va daraxtlar (ko\'pincha): die Rose, die Birne',
        'Zamonlar (ko\'pincha): die Nacht, die Zeit, die Woche',
      ],
    ),
    ArticleRuleSection(
      article: 'das',
      colorName: 'green',
      emoji: '🟢',
      title: 'DAS — neytral (neytr)',
      tips: [
        'Kichikot shakllari -chen / -lein: das Mädchen, das Häuschen, das Büchlein',
        'Infinitivdan hosil bo\'lgan otlar: das Lesen, das Schwimmen, das Leben',
        'Yosh shaxslar va hayvonlar (neytr): das Baby, das Kind, das Lamm',
        'Kimyo elementlari va metallar: das Gold, das Eisen, das Wasser',
        'Geografik nomlar (mamlakat/shahar ko\'pincha): das Deutschland, das Berlin',
        'Ko\'plab -ment, -um, -nis, -tum: das Dokument, das Museum, das Ereignis',
        'Mädchen har doim DAS (qiz bola — neytr shakl)!',
      ],
    ),
  ];

  static const List<String> memoryTricks = [
    'Yodda tuting: Mädchen (qiz bola) — har doim DAS, chunki -chen qoidasi ustun.',
    'Kasb -in bilan tugasa (Lehrerin) — odatda DIE.',
    'Ko\'plik har doim DIE (die + ot).',
    'Yangi so\'zni o\'rganayotganda artiklni birga yodlang — faqat ot emas!',
    'Shubhali bo\'lsa, lug\'atda artiklni tekshiring; o\'yin xatolardan o\'rgatadi.',
  ];
}

class ArticleRuleSection {
  final String article;
  final String colorName;
  final String emoji;
  final String title;
  final List<String> tips;

  const ArticleRuleSection({
    required this.article,
    required this.colorName,
    required this.emoji,
    required this.title,
    required this.tips,
  });
}
