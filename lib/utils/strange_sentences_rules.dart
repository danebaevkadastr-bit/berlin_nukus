/// G'alati gaplar o'yini qoidalari.
class StrangeSentencesRules {
  static const int roundsPerSession = 8;
  static const int secondsPerRound = 45;
  static const int pointsPerCorrect = 10;
  static const int streakBonusEvery = 3;
  static const int streakBonusPoints = 5;

  static String get howToPlayText => '''
• Har sessiyada $roundsPerSession ta raund (AI yoki tayyor savollar).
• Raund turi tasodifiy: ba'zida 3 gapdan to'g'risini tanlaysiz, ba'zida so'zlarni tartibga solasiz.
• Har raund uchun $secondsPerRound soniya vaqt.
• To'g'ri javob: +$pointsPerCorrect yulduz.
• Ketma-ket $streakBonusEvery ta to'g'ri: +$streakBonusPoints bonus.
• Gap grammatik jihatdan to'g'ri bo'lishi kerak — ma'no g'alati bo'lishi mumkin!
''';
}
