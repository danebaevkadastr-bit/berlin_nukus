import '../models/strange_sentences_round.dart';

/// AI ishlamaganda ishlatiladigan tayyor raundlar.
class StrangeSentencesFallback {
  static const List<StrangeSentencesRound> rounds = [
    // EASY - oddiy gaplar, qisqa, asosiy grammatika
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Hund trinkt Kaffee.',
      pickOptions: [
        'Der Hund trinkt Kaffee.',
        'Der Hund trinken Kaffee.',
        'Hund der trinkt Kaffee.',
      ],
      explanationUz: "Fe'l \"trinkt\" ega bilan mos (er/singular).",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Die Katze schläft.',
      shuffledWords: ['schläft', 'Die', 'Katze'],
      explanationUz: "Subyekt + fe'l.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Das Kind spielt.',
      pickOptions: [
        'Das Kind spielt.',
        'Das Kind spielen.',
        'Kind das spielt.',
      ],
      explanationUz: "\"spielt\" — das Kind uchun to'g'ri shakl.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Mann isst.',
      shuffledWords: ['isst', 'Der', 'Mann'],
      explanationUz: "Oddiy gap, asosiy grammatika.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Die Frau liest.',
      pickOptions: [
        'Die Frau liest.',
        'Die Frau lesen.',
        'Frau die liest.',
      ],
      explanationUz: "Die Frau + liest — to'g'ri juftlik.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Das Auto fährt.',
      shuffledWords: ['fährt', 'Das', 'Auto'],
      explanationUz: "Subyekt + fe'l.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Junge läuft.',
      pickOptions: [
        'Der Junge läuft.',
        'Der Junge laufen.',
        'Junge der läuft.',
      ],
      explanationUz: "Der Junge + läuft — to'g'ri.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Die Blume wächst.',
      shuffledWords: ['wächst', 'Die', 'Blume'],
      explanationUz: "Oddiy gap.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Das Haus steht.',
      pickOptions: [
        'Das Haus steht.',
        'Das Haus stehen.',
        'Haus das steht.',
      ],
      explanationUz: "Das Haus + steht.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Vogel singt.',
      shuffledWords: ['singt', 'Der', 'Vogel'],
      explanationUz: "Subyekt + fe'l.",
    ),

    // MEDIUM - o'rtacha gaplar, biroz murakkabroq grammatika
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Der Hund trinkt den Kaffee.',
      pickOptions: [
        'Der Hund trinkt den Kaffee.',
        'Der Hund trinken den Kaffee.',
        'Hund der trinkt Kaffee den.',
      ],
      explanationUz: "Akkusativ \"den Kaffee\" to'g'ri.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Die Katze schläft auf dem Sofa.',
      shuffledWords: ['auf', 'dem', 'Sofa.', 'Die', 'schläft', 'Katze'],
      explanationUz: "Subyekt + fe'l + joy (dativ).",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Das Kind spielt mit dem Ball.',
      pickOptions: [
        'Das Kind spielt mit dem Ball.',
        'Das Kind spielen mit dem Ball.',
        'Kind das spielt mit Ball dem.',
      ],
      explanationUz: "\"spielt\" + dativ \"dem Ball\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Der Mann isst den Apfel.',
      shuffledWords: ['den', 'Apfel.', 'Der', 'isst', 'Mann'],
      explanationUz: "Akkusativ ishlatilgan.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Die Frau liest das Buch.',
      pickOptions: [
        'Die Frau liest das Buch.',
        'Die Frau lesen das Buch.',
        'Frau die liest Buch das.',
      ],
      explanationUz: "Die Frau + liest + akkusativ.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Das Auto fährt in die Stadt.',
      shuffledWords: ['in', 'die', 'Stadt.', 'fährt', 'Das', 'Auto'],
      explanationUz: "Akkusativ \"die Stadt\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Der Junge läuft im Park.',
      pickOptions: [
        'Der Junge läuft im Park.',
        'Der Junge laufen im Park.',
        'Junge der läuft Park im.',
      ],
      explanationUz: "Dativ \"im Park\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Die Blume wächst im Garten.',
      shuffledWords: ['wächst', 'Die', 'Garten.', 'im', 'Blume'],
      explanationUz: "Dativ ishlatilgan.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Das Haus steht am Berg.',
      pickOptions: [
        'Das Haus steht am Berg.',
        'Das Haus stehen am Berg.',
        'Haus das steht Berg am.',
      ],
      explanationUz: "Präposition \"am\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Der Vogel singt im Baum.',
      shuffledWords: ['singt', 'Der', 'Baum.', 'im', 'Vogel'],
      explanationUz: "Dativ ishlatilgan.",
    ),

    // HARD - murakkab gaplar, qiyinroq grammatika
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Der Hund hat den Kaffee getrunken.',
      pickOptions: [
        'Der Hund hat den Kaffee getrunken.',
        'Der Hund haben den Kaffee getrunken.',
        'Hund der hat Kaffee den getrunken.',
      ],
      explanationUz: "Perfekt: hat + Partizip II.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Die Katze hat auf dem Sofa geschlafen.',
      shuffledWords: ['hat', 'auf', 'dem', 'Sofa.', 'Die', 'geschlafen', 'Katze'],
      explanationUz: "Perfekt + dativ.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Das Kind hat mit dem Ball gespielt.',
      pickOptions: [
        'Das Kind hat mit dem Ball gespielt.',
        'Das Kind haben mit dem Ball gespielt.',
        'Kind das hat mit Ball dem gespielt.',
      ],
      explanationUz: "Perfekt + dativ.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Der Mann aß den Apfel gestern.',
      shuffledWords: ['den', 'Apfel.', 'Der', 'aß', 'Mann', 'gestern'],
      explanationUz: "Präteritum \"aß\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Die Frau hat das Buch gelesen.',
      pickOptions: [
        'Die Frau hat das Buch gelesen.',
        'Die Frau haben das Buch gelesen.',
        'Frau die hat Buch das gelesen.',
      ],
      explanationUz: "Perfekt + Partizip II.",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Das Auto ist in die Stadt gefahren.',
      shuffledWords: ['ist', 'in', 'die', 'Stadt.', 'gefahren', 'Das', 'Auto'],
      explanationUz: "Perfekt \"ist gefahren\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Der Junge muss im Park laufen.',
      pickOptions: [
        'Der Junge muss im Park laufen.',
        'Der Junge müssen im Park laufen.',
        'Junge der muss Park im laufen.',
      ],
      explanationUz: "Modal fe'l \"muss\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Die Blume will im Garten wachsen.',
      shuffledWords: ['wachsen', 'Die', 'Garten.', 'will', 'im', 'Blume'],
      explanationUz: "Modal fe'l \"will\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Das Haus kann am Berg stehen.',
      pickOptions: [
        'Das Haus kann am Berg stehen.',
        'Das Haus können am Berg stehen.',
        'Haus das kann Berg am stehen.',
      ],
      explanationUz: "Modal fe'l \"kann\".",
    ),
    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Der Vogel soll im Baum singen.',
      shuffledWords: ['singen', 'Der', 'Baum.', 'soll', 'im', 'Vogel'],
      explanationUz: "Modal fe'l \"soll\".",
    ),
  ];

  static List<StrangeSentencesRound> sample({required int count, required StrangeDifficulty difficulty}) {
    // Faqat berilgan darajadagi raundlarni olish
    final filteredRounds = rounds.where((r) => r.difficulty == difficulty).toList();
    final copy = filteredRounds.map((round) {
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
      copy.addAll(filteredRounds.map((round) {
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
