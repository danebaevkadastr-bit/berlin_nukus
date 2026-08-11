/// Sinonimlar Jangi o'yini qoidalari va sozlamalari.
class SynonymRules {
  /// O'yin sarlavhasi
  static const String gameTitle = 'Sinonimlar Jangi';

  /// Har bir raund uchun savollar soni
  static const int questionsPerRound = 10;

  /// Har bir savol uchun vaqt (soniyalarda)
  static const int secondsPerQuestion = 10;

  /// To'g'ri javob uchun ball
  static const int pointsPerCorrect = 10;

  /// Streak bonus har nechta to'g'ri javobda beriladi
  static const int streakBonusEvery = 5;

  /// Streak bonus miqdori
  static const int streakBonusPoints = 5;

  /// Qizil timer chegarasi (soniyalarda)
  static const int timerWarningThreshold = 4;

  /// Qoidalar sarlavhasi
  static const String howToPlayTitle = 'QANDAY O\'YNALADI?';

  /// Qoidalar matni
  static const String howToPlayText = '''
Ekranda nemis so'zi va uning o'zbek tarjimasi ko'rsatiladi.
Sizning vazifangiz - to'rtta variant orasidan to'g'ri sinonimni topish.
Har bir savol uchun 10 soniya vaqtingiz bor.
  ''';

  /// Ball tizimi sarlavhasi
  static const String scoringTitle = 'BALL TIZIMI';

  /// Ball tizimi matni
  static const String scoringText = '''
• Har bir to'g'ri javob: +10 ⭐
• Ketma-ket 5 ta to'g'ri javob: +5 bonus ⭐
• Noto'g'ri javob yoki vaqt tugashi: 0 ball
  ''';

  /// O'yinni boshlash tugmasi matni
  static const String startButtonText = 'O\'YINNI BOSHLASH';

  /// Yana o'ynash tugmasi matni
  static const String playAgainButtonText = 'YANA O\'YNASH';

  /// Orqaga tugmasi matni
  static const String backButtonText = 'ORQAGA';

  /// To'g'ri javob xabari
  static const String correctAnswerMessage = 'To\'g\'ri!';

  /// Vaqt tugadi xabari
  static const String timeoutMessage = 'Vaqt tugadi!';

  /// Noto'g'ri javob xabari prefiksi
  static const String wrongAnswerPrefix = 'Noto\'g\'ri! To\'g\'ri javob:';

  /// Natijalar ekrani sarlavhasi
  static const String resultsTitle = 'NATIJALAR';

  /// To'g'ri javoblar matni
  static const String correctLabel = 'To\'g\'ri';

  /// Noto'g'ri javoblar matni
  static const String wrongLabel = 'Noto\'g\'ri';

  /// Aniqlik matni
  static const String accuracyLabel = 'Aniqlik';

  /// Jami yulduzlar matni
  static const String totalStarsLabel = 'Jami yulduzlar';

  /// Raund balli matni
  static const String roundScoreLabel = 'Raund balli';

  /// Motivatsion xabarlar
  static String getMotivationalMessage(int accuracyPercent) {
    if (accuracyPercent >= 90) {
      return 'Ajoyib natija! Siz haqiqiy ustasiz! 🏆';
    } else if (accuracyPercent >= 70) {
      return 'Yaxshi ish! Davom eting! ⭐';
    } else if (accuracyPercent >= 50) {
      return 'Yomon emas! Mashq qiling! 💪';
    } else {
      return 'Ko\'proq mashq qiling! 📘';
    }
  }

  /// Natija emojisi
  static String getResultEmoji(int accuracyPercent) {
    if (accuracyPercent >= 90) {
      return '🏆';
    } else if (accuracyPercent >= 70) {
      return '⭐';
    } else if (accuracyPercent >= 50) {
      return '💪';
    } else {
      return '📘';
    }
  }
}
