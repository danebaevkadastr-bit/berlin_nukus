import '../models/grammar_game_round.dart';

/// AI ishlamaganda ishlatiladigan tayyor grammatik raundlar.
class GrammarFallback {
  static final List<GrammarGameRound> rounds = [
    // Article - Der/Die/Das tanlash
    GrammarGameRound(
      type: GrammarRoundType.article,
      question: '___ Buch',
      questionUz: '___ kitob (der/die/das)',
      options: ['Der', 'Die', 'Das', 'Den'],
      correctAnswer: 'Das',
      explanationUz: 'Buch - neytral, shuning uchun "das" ishlatiladi.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.article,
      question: '___ Hund',
      questionUz: '___ it (der/die/das)',
      options: ['Der', 'Die', 'Das', 'Den'],
      correctAnswer: 'Der',
      explanationUz: 'Hund - maskulin, shuning uchun "der" ishlatiladi.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.article,
      question: '___ Katze',
      questionUz: '___ mushuk (der/die/das)',
      options: ['Der', 'Die', 'Das', 'Den'],
      correctAnswer: 'Die',
      explanationUz: 'Katze - feminin, shuning uchun "die" ishlatiladi.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.article,
      question: '___ Tisch',
      questionUz: '___ stul (der/die/das)',
      options: ['Der', 'Die', 'Das', 'Den'],
      correctAnswer: 'Der',
      explanationUz: 'Tisch - maskulin, shuning uchun "der" ishlatiladi.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.article,
      question: '___ Auto',
      questionUz: '___ mashina (der/die/das)',
      options: ['Der', 'Die', 'Das', 'Den'],
      correctAnswer: 'Das',
      explanationUz: 'Auto - neytral, shuning uchun "das" ishlatiladi.',
    ),

    // Verb - Fe'l shaklini tanlash
    GrammarGameRound(
      type: GrammarRoundType.verb,
      question: 'Ich ___ Apfel',
      questionUz: 'Men ___ olma (yeyaman)',
      options: ['esse', 'isst', 'essen', 'ißt'],
      correctAnswer: 'esse',
      explanationUz: 'Ich (men) uchun "esse" - 1-shaxs singular.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.verb,
      question: 'Du ___ Apfel',
      questionUz: 'Sen ___ olma (yesan)',
      options: ['esse', 'isst', 'essen', 'ißt'],
      correctAnswer: 'isst',
      explanationUz: 'Du (sen) uchun "isst" - 2-shaxs singular.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.verb,
      question: 'Er ___ Apfel',
      questionUz: 'U ___ olma (yeydi)',
      options: ['esse', 'isst', 'essen', 'ißt'],
      correctAnswer: 'isst',
      explanationUz: 'Er (u/erkak) uchun "isst" - 3-shaxs singular.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.verb,
      question: 'Wir ___ Apfel',
      questionUz: 'Biz ___ olma (yeymiz)',
      options: ['esse', 'isst', 'essen', 'ißt'],
      correctAnswer: 'essen',
      explanationUz: 'Wir (biz) uchun "essen" - 1-shaxs plural.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.verb,
      question: 'Sie ___ Apfel',
      questionUz: 'Ular ___ olma (yeydilar)',
      options: ['esse', 'isst', 'essen', 'ißt'],
      correctAnswer: 'essen',
      explanationUz: 'Sie (ular) uchun "essen" - 3-shaxs plural.',
    ),

    // Preposition - Präposition tanlash
    GrammarGameRound(
      type: GrammarRoundType.preposition,
      question: 'Ich gehe ___ Schule',
      questionUz: 'Men ___ maktabga boraman',
      options: ['zur', 'zu', 'in', 'auf'],
      correctAnswer: 'zur',
      explanationUz: 'Zur = zu + der. "Ich gehe zur Schule" - maktabga boraman.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.preposition,
      question: 'Ich bin ___ Hause',
      questionUz: 'Men ___ uyda',
      options: ['zu', 'im', 'in', 'am'],
      correctAnswer: 'zu',
      explanationUz: '"Ich bin zu Hause" - men uyda.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.preposition,
      question: 'Ich arbeite ___ Berlin',
      questionUz: 'Men ___ Berlinda ishlayman',
      options: ['in', 'im', 'zu', 'auf'],
      correctAnswer: 'in',
      explanationUz: '"Ich arbeite in Berlin" - men Berlinda ishlayman.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.preposition,
      question: 'Ich sitze ___ Tisch',
      questionUz: 'Men ___ stulda o\'tiraman',
      options: ['am', 'an', 'im', 'in'],
      correctAnswer: 'am',
      explanationUz: 'Am = an + dem. "Ich sitze am Tisch" - men stulda o\'tiraman.',
    ),
    GrammarGameRound(
      type: GrammarRoundType.preposition,
      question: 'Ich fahre ___ Stadt',
      questionUz: 'Men ___ shaharga ketaman',
      options: ['in', 'im', 'zu', 'auf'],
      correctAnswer: 'in',
      explanationUz: '"Ich fahre in die Stadt" - men shaharga ketaman.',
    ),

    // FillBlank - Gapni to'ldirish
    GrammarGameRound(
      type: GrammarRoundType.fillBlank,
      question: 'Der Mann ___ im Park',
      questionUz: 'Erkak ___ parkda',
      options: ['läuft', 'laufen', 'lief', 'gelaufen'],
      correctAnswer: 'läuft',
      explanationUz: 'Der Mann (3-shaxs singular) + läuft (hozirgi zamon).',
    ),
    GrammarGameRound(
      type: GrammarRoundType.fillBlank,
      question: 'Die Frau ___ ein Buch',
      questionUz: 'Ayol ___ kitob',
      options: ['liest', 'lesen', 'las', 'gelesen'],
      correctAnswer: 'liest',
      explanationUz: 'Die Frau (3-shaxs singular) + liest (hozirgi zamon).',
    ),
    GrammarGameRound(
      type: GrammarRoundType.fillBlank,
      question: 'Das Kind ___ Fußball',
      questionUz: 'Bola ___ futbol',
      options: ['spielt', 'spielen', 'spielte', 'gespielt'],
      correctAnswer: 'spielt',
      explanationUz: 'Das Kind (3-shaxs singular) + spielt (hozirgi zamon).',
    ),
    GrammarGameRound(
      type: GrammarRoundType.fillBlank,
      question: 'Wir ___ Deutsch',
      questionUz: 'Biz ___ nemis tilida',
      options: ['sprechen', 'sprichst', 'spricht', 'gesprochen'],
      correctAnswer: 'sprechen',
      explanationUz: 'Wir (1-shaxs plural) + sprechen (hozirgi zamon).',
    ),
    GrammarGameRound(
      type: GrammarRoundType.fillBlank,
      question: 'Sie ___ Kaffee',
      questionUz: 'Ular ___ qahva',
      options: ['trinken', 'trinkst', 'trinkt', 'getrunken'],
      correctAnswer: 'trinken',
      explanationUz: 'Sie (3-shaxs plural) + trinken (hozirgi zamon).',
    ),
  ];

  static List<GrammarGameRound> sample({required int count}) {
    final copy = List<GrammarGameRound>.from(rounds)..shuffle();
    while (copy.length < count) {
      copy.addAll(rounds);
      copy.shuffle();
    }
    return copy.take(count).toList();
  }
}
