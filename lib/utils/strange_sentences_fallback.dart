import '../models/strange_sentences_round.dart';

/// AI ishlamaganda ishlatiladigan tayyor raundlar.
class StrangeSentencesFallback {
  static const List<StrangeSentencesRound> rounds = [
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Hund trinkt Kaffee im Büro.',
      pickOptions: [
        'Der Hund trinkt Kaffee im Büro.',
        'Der Hund trinken Kaffee im Büro.',
        'Hund der trinkt Kaffee Büro im.',
      ],
      explanationUz: "Fe'l \"trinkt\" ega bilan mos (er/singular).",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Die Oma isst die Hausaufgabe auf dem Mond.',
      shuffledWords: ['auf', 'die', 'Mond.', 'Die', 'isst', 'Oma', 'dem', 'Hausaufgabe'],
      explanationUz: "So'z tartibi: Subyekt + fe'l + to'ldiruvchi + joy.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Das Kind fährt mit dem Fahrrad in der Küche.',
      pickOptions: [
        'Das Kind fährt mit dem Fahrrad in der Küche.',
        'Das Kind fahren mit dem Fahrrad in der Küche.',
        'Kind das fährt mit Fahrrad die Küche in.',
      ],
      explanationUz: "\"fährt\" — das Kind uchun to'g'ri shakl.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Der Fisch liest ein Buch im Kino.',
      shuffledWords: ['ein', 'Der', 'im', 'Fisch', 'Buch', 'liest', 'Kino.'],
      explanationUz: "Mantiqsiz, lekin grammatik to'g'ri gap.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Die Katze schreibt einen Brief am Montag.',
      pickOptions: [
        'Die Katze schreibt einen Brief am Montag.',
        'Die Katze schreiben einen Brief am Montag.',
        'Katze die schreibt Brief einen Montag am.',
      ],
      explanationUz: "Die Katze + schreibt — to'g'ri juftlik.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Mein Bruder kocht Pizza im Bett.',
      shuffledWords: ['im', 'Mein', 'Pizza', 'Bruder', 'Bett.', 'kocht'],
      explanationUz: "Pizza yotoqda pishiriladi — g'alati, lekin tartib to'g'ri.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Der Lehrer tanzt mit der Tasche.',
      pickOptions: [
        'Der Lehrer tanzt mit der Tasche.',
        'Der Lehrer tanzen mit der Tasche.',
        'Lehrer der tanzt Tasche mit der.',
      ],
      explanationUz: "Der Lehrer + tanzt — Present Simple to'g'ri.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Das Auto schläft heute im Garten.',
      shuffledWords: ['schläft', 'Das', 'heute', 'Auto', 'Garten.', 'im'],
      explanationUz: "Subyekt + fe'l + vaqt + joy.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Die Blume riecht nach Schokolade.',
      pickOptions: [
        'Die Blume riecht nach Schokolade.',
        'Die Blume riechen nach Schokolade.',
        'Blume die riecht Schokolade nach.',
      ],
      explanationUz: "Die Blume + riecht — fe'l kelishishi to'g'ri.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Ich esse den Computer zum Frühstück.',
      shuffledWords: ['den', 'Ich', 'esse', 'Computer', 'Frühstück.', 'zum'],
      explanationUz: "Akkusativ \"den Computer\" to'g'ri qo'llangan.",
    ),
  ];

  static List<StrangeSentencesRound> sample({required int count}) {
    final copy = rounds.map((round) {
      if (round.type == StrangeRoundType.pick && round.pickOptions.length >= 3) {
        // Variantlarni aralashtirish
        final shuffledOptions = List<String>.from(round.pickOptions)..shuffle();
        return StrangeSentencesRound(
          type: round.type,
          difficulty: round.difficulty,
          correctSentence: round.correctSentence,
          pickOptions: shuffledOptions,
          shuffledWords: round.shuffledWords,
          explanationUz: round.explanationUz,
        );
      }
      return round;
    }).toList()..shuffle();

    while (copy.length < count) {
      copy.addAll(rounds.map((round) {
        if (round.type == StrangeRoundType.pick && round.pickOptions.length >= 3) {
          final shuffledOptions = List<String>.from(round.pickOptions)..shuffle();
          return StrangeSentencesRound(
            type: round.type,
            difficulty: round.difficulty,
            correctSentence: round.correctSentence,
            pickOptions: shuffledOptions,
            shuffledWords: round.shuffledWords,
            explanationUz: round.explanationUz,
          );
        }
        return round;
      }).toList());
    }
    return copy.take(count).toList();
  }
}
