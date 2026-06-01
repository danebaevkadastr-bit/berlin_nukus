import '../models/strange_sentences_round.dart';

/// AI ishlamaganda ishlatiladigan tayyor raundlar.
/// Har bir gap: GRAMMATIK TO'G'RI + MANTIQAN G'ALATI
class StrangeSentencesFallback {
  static const List<StrangeSentencesRound> rounds = [

    // ─────────────────────────────────────────────────────
    // EASY — A1 (Präsens, Modal, Nominativ/Akkusativ, der/die/das)
    // ─────────────────────────────────────────────────────

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Kühlschrank singt eine Oper.',
      pickOptions: [
        'Der Kühlschrank singt eine Oper.',
        'Der Kühlschrank singen eine Oper.',
        'Kühlschrank der singt Oper eine.',
      ],
      explanationUz: '"singt" — er/sie/es bilan to\'g\'ri Präsens shakli (singen → singt).',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Meine Katze kann fließend Russisch sprechen.',
      shuffledWords: ['Meine', 'kann', 'fließend', 'Russisch', 'Katze', 'sprechen.'],
      explanationUz: 'Modal fe\'l "kann" + Infinitiv "sprechen" gap oxirida — to\'g\'ri qurilish.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Das Buch trinkt jeden Abend Kaffee.',
      pickOptions: [
        'Das Buch trinkt jeden Abend Kaffee.',
        'Das Buch trinken jeden Abend Kaffee.',
        'Buch das trinkt Abend jeden Kaffee.',
      ],
      explanationUz: '"trinkt" — das Buch (neytral, er/sie/es) bilan mos shakl.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Ich muss heute die Wolken zählen.',
      shuffledWords: ['Ich', 'muss', 'die', 'zählen.', 'heute', 'Wolken'],
      explanationUz: '"muss" + Infinitiv oxirida. "die Wolken" — Akkusativ ko\'plik.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Stuhl möchte Arzt werden.',
      pickOptions: [
        'Der Stuhl möchte Arzt werden.',
        'Der Stuhl möchten Arzt werden.',
        'Stuhl der möchte werden Arzt.',
      ],
      explanationUz: '"möchte" — Modal fe\'l, 3-shaxs birlik. Infinitiv "werden" oxirida.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Die Sonne schläft bis neun Uhr.',
      shuffledWords: ['Die', 'schläft', 'neun', 'bis', 'Sonne', 'Uhr.'],
      explanationUz: '"schläft" — die Sonne (ayol) bilan to\'g\'ri Präsens shakli.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Das Fahrrad liest jeden Morgen die Zeitung.',
      pickOptions: [
        'Das Fahrrad liest jeden Morgen die Zeitung.',
        'Das Fahrrad lesen jeden Morgen die Zeitung.',
        'Fahrrad das liest Morgen jeden Zeitung die.',
      ],
      explanationUz: '"liest" — nomuntazam fe\'l (lesen → er liest), das Fahrrad bilan mos.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Der Mond kann sehr gut tanzen.',
      shuffledWords: ['Der', 'kann', 'gut', 'tanzen.', 'Mond', 'sehr'],
      explanationUz: '"kann" + Infinitiv "tanzen" — Modal fe\'l to\'g\'ri ishlatilgan.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Die Tür spricht fünf Sprachen.',
      pickOptions: [
        'Die Tür spricht fünf Sprachen.',
        'Die Tür sprechen fünf Sprachen.',
        'Tür die spricht Sprachen fünf.',
      ],
      explanationUz: '"spricht" — nomuntazam (sprechen → er/sie spricht), die Tür bilan to\'g\'ri.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.easy,
      correctSentence: 'Mein Hund schreibt jeden Tag einen Brief.',
      shuffledWords: ['Mein', 'schreibt', 'Tag', 'einen', 'Hund', 'jeden', 'Brief.'],
      explanationUz: '"schreibt" — Präsens. "einen Brief" — Akkusativ erkak (ein→einen).',
    ),

    // ─────────────────────────────────────────────────────
    // MEDIUM — A2 (Perfekt, Dativ, Wechselpräp, Reflexiv, weil/dass)
    // ─────────────────────────────────────────────────────

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Mein Stuhl hat sich gestern mit mir gestritten, weil ich zu lange gesessen habe.',
      pickOptions: [
        'Mein Stuhl hat sich gestern mit mir gestritten, weil ich zu lange gesessen habe.',
        'Mein Stuhl haben sich gestern mit mir gestritten, weil ich zu lange gesessen habe.',
        'Mein Stuhl hat sich gestern mit mir gestritten, weil ich zu lange gesessen bin.',
      ],
      explanationUz: '"hat gestritten" — Perfekt (haben bilan). "weil" gapida fe\'l oxirda: "gesessen habe".',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Der Mond ist schneller als mein Fahrrad.',
      shuffledWords: ['Der', 'ist', 'als', 'mein', 'Mond', 'schneller', 'Fahrrad.'],
      explanationUz: 'Komparativ: "schneller als" — ... dan tez. "ist" — sein fe\'li.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Sie hat dem Regen gedankt, weil er ihr Auto gewaschen hat.',
      pickOptions: [
        'Sie hat dem Regen gedankt, weil er ihr Auto gewaschen hat.',
        'Sie hat der Regen gedankt, weil er ihr Auto gewaschen hat.',
        'Sie hat dem Regen gedankt, weil er ihr Auto gewaschen haben.',
      ],
      explanationUz: '"danken" — Dativ talab qiladi (dem Regen). "weil" gapida fe\'l oxirda.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Das Sofa hat sich auf den Tisch gesetzt und Zeitung gelesen.',
      shuffledWords: ['Das', 'hat', 'sich', 'auf', 'den', 'Tisch', 'gesetzt', 'Sofa', 'und', 'Zeitung', 'gelesen.'],
      explanationUz: '"sich setzen" — refleksiv fe\'l. "auf den Tisch" — harakat = Akkusativ. Perfekt: hat gesetzt.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Meine Lampe hat sich beschwert, dass sie zu wenig Strom bekommt.',
      pickOptions: [
        'Meine Lampe hat sich beschwert, dass sie zu wenig Strom bekommt.',
        'Meine Lampe haben sich beschwert, dass sie zu wenig Strom bekommt.',
        'Meine Lampe hat sich beschwert, dass sie zu wenig Strom bekommen.',
      ],
      explanationUz: '"sich beschweren" — Refleksiv Perfekt (hat beschwert). "dass" gapida fe\'l oxirda.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Der Tisch war früher glücklicher als das Sofa.',
      shuffledWords: ['Der', 'war', 'früher', 'glücklicher', 'als', 'Tisch', 'Sofa.', 'das'],
      explanationUz: '"war" — Präteritum (sein). Komparativ: "glücklicher als".',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Ich habe dem Drucker erklärt, dass er keine Seelen drucken darf.',
      pickOptions: [
        'Ich habe dem Drucker erklärt, dass er keine Seelen drucken darf.',
        'Ich habe den Drucker erklärt, dass er keine Seelen drucken darf.',
        'Ich habe dem Drucker erklärt, dass er keine Seelen drucken hat.',
      ],
      explanationUz: '"erklären + Dativ" — kimga tushuntirmoq? dem Drucker (Dativ erkak).',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Die Wolke hat sich in meinem Zimmer versteckt, weil es draußen zu kalt war.',
      shuffledWords: ['Die', 'hat', 'sich', 'in', 'meinem', 'Zimmer', 'Wolke', 'versteckt,', 'weil', 'es', 'draußen', 'zu', 'kalt', 'war.'],
      explanationUz: '"sich verstecken" — Refleksiv Perfekt. "in meinem Zimmer" — joy = Dativ. "weil" + fe\'l oxirda.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Mein Schatten ist gestern ohne mich einkaufen gegangen.',
      pickOptions: [
        'Mein Schatten ist gestern ohne mich einkaufen gegangen.',
        'Mein Schatten hat gestern ohne mich einkaufen gegangen.',
        'Mein Schatten ist gestern ohne mich einkaufen gegangen haben.',
      ],
      explanationUz: '"gehen" — sein bilan Perfekt (ist gegangen). "einkaufen gehen" — birikma.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.medium,
      correctSentence: 'Das Bett hat mir geraten, früher schlafen zu gehen.',
      shuffledWords: ['Das', 'hat', 'mir', 'geraten,', 'früher', 'schlafen', 'Bett', 'zu', 'gehen.'],
      explanationUz: '"raten + Dativ" — mir (Dativ). "zu + Infinitiv" konstruksiyasi.',
    ),

    // ─────────────────────────────────────────────────────
    // HARD — B1 (Passiv, Konjunktiv II, Plusquamperfekt, Relativsatz, Nebensatz)
    // ─────────────────────────────────────────────────────

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Die Pizza, die von meinem Drucker gebacken wurde, schmeckt besser als alle anderen.',
      pickOptions: [
        'Die Pizza, die von meinem Drucker gebacken wurde, schmeckt besser als alle anderen.',
        'Die Pizza, die von meinem Drucker gebacken worden, schmeckt besser als alle anderen.',
        'Die Pizza, die von meinem Drucker gebacken hat, schmeckt besser als alle anderen.',
      ],
      explanationUz: 'Präteritum Passiv: "wurde gebacken". Relativsatz: "die...gebacken wurde" — fe\'l oxirda.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Obwohl meine Tastatur täglich Sport treibt, wird sie immer langsamer.',
      shuffledWords: ['Obwohl', 'meine', 'Tastatur', 'täglich', 'Sport', 'treibt,', 'wird', 'sie', 'immer', 'langsamer.'],
      explanationUz: '"obwohl" — Nebensatz, fe\'l oxirda ("treibt"). Asosiy gapda Präsens Passiv muqobili.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Der Tisch hatte bereits geschlafen, bevor die Stühle nach Hause gekommen waren.',
      pickOptions: [
        'Der Tisch hatte bereits geschlafen, bevor die Stühle nach Hause gekommen waren.',
        'Der Tisch hatte bereits geschlafen, bevor die Stühle nach Hause gekommen haben.',
        'Der Tisch hatte bereits geschlafen, bevor die Stühle nach Hause kamen.',
      ],
      explanationUz: 'Plusquamperfekt: "hatte geschlafen" va "gekommen waren" — ikki o\'tgan harakatdan avvalgisi.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Ich würde gerne wissen, ob mein Schatten ein eigenes Leben führt.',
      shuffledWords: ['Ich', 'würde', 'gerne', 'wissen,', 'ob', 'mein', 'Schatten', 'ein', 'eigenes', 'Leben', 'führt.'],
      explanationUz: 'Konjunktiv II: "würde wissen". Bilvosita so\'roq "ob" bilan — fe\'l oxirda.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Wenn mein Bett sprechen könnte, würde es mir viele Geheimnisse verraten.',
      pickOptions: [
        'Wenn mein Bett sprechen könnte, würde es mir viele Geheimnisse verraten.',
        'Wenn mein Bett sprechen konnte, würde es mir viele Geheimnisse verraten.',
        'Wenn mein Bett sprechen könnte, hätte es mir viele Geheimnisse verraten.',
      ],
      explanationUz: 'Irreal shart: "wenn...könnte" (Konjunktiv II). Natija: "würde...verraten".',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Das Buch, das mir gestern von der Bibliothek empfohlen wurde, liest sich von selbst.',
      shuffledWords: ['Das', 'Buch,', 'das', 'mir', 'gestern', 'von', 'der', 'Bibliothek', 'empfohlen', 'wurde,', 'liest', 'sich', 'von', 'selbst.'],
      explanationUz: 'Relativsatz bilan Passiv: "das...empfohlen wurde". "sich lesen" — refleksiv.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Nachdem die Sonne ihr Tagebuch geschrieben hatte, ging sie unter.',
      pickOptions: [
        'Nachdem die Sonne ihr Tagebuch geschrieben hatte, ging sie unter.',
        'Nachdem die Sonne ihr Tagebuch geschrieben hat, ging sie unter.',
        'Nachdem die Sonne ihr Tagebuch schrieb, war sie untergegangen.',
      ],
      explanationUz: '"nachdem" + Plusquamperfekt ("hatte geschrieben"), asosiy gapda Präteritum.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Mein Kühlschrank hat aufgehört zu reden, seitdem er beleidigt wurde.',
      shuffledWords: ['Mein', 'Kühlschrank', 'hat', 'aufgehört', 'zu', 'reden,', 'seitdem', 'er', 'beleidigt', 'wurde.'],
      explanationUz: '"aufhören + zu Infinitiv". "seitdem" — Nebensatz. Passiv: "beleidigt wurde".',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.pick,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Die Wolken, die jeden Abend über meiner Stadt streiten, konnten sich gestern nicht einigen.',
      pickOptions: [
        'Die Wolken, die jeden Abend über meiner Stadt streiten, konnten sich gestern nicht einigen.',
        'Die Wolken, die jeden Abend über meiner Stadt streiten, konnte sich gestern nicht einigen.',
        'Die Wolken, die jeden Abend über meiner Stadt streiten, konnten sich gestern nicht geeinigt.',
      ],
      explanationUz: 'Relativsatz: "die...streiten". "konnten" — Präteritum modal. "sich einigen" — refleksiv.',
    ),

    StrangeSentencesRound(
      type: StrangeRoundType.order,
      difficulty: StrangeDifficulty.hard,
      correctSentence: 'Ich versuche, meinen Schatten davon zu überzeugen, früher aufzustehen.',
      shuffledWords: ['Ich', 'versuche,', 'meinen', 'Schatten', 'davon', 'zu', 'überzeugen,', 'früher', 'aufzustehen.'],
      explanationUz: '"versuchen + zu Infinitiv". "davon überzeugen" — predlogli fe\'l. "aufzustehen" — trennbar + zu.',
    ),
  ];

  static List<StrangeSentencesRound> sample({required int count, required StrangeDifficulty difficulty}) {
    final filtered = rounds.where((r) => r.difficulty == difficulty).toList();

    final copy = filtered.map((round) {
      if (round.type == StrangeRoundType.pick && round.pickOptions.length >= 3) {
        final shuffled = List<String>.from(round.pickOptions)..shuffle();
        return StrangeSentencesRound(
          type: round.type,
          difficulty: round.difficulty,
          correctSentence: round.correctSentence,
          pickOptions: shuffled,
          shuffledWords: round.shuffledWords,
          explanationUz: round.explanationUz,
        );
      }
      return round;
    }).toList()..shuffle();

    while (copy.length < count) {
      copy.addAll(filtered.map((round) {
        if (round.type == StrangeRoundType.pick && round.pickOptions.length >= 3) {
          final shuffled = List<String>.from(round.pickOptions)..shuffle();
          return StrangeSentencesRound(
            type: round.type,
            difficulty: round.difficulty,
            correctSentence: round.correctSentence,
            pickOptions: shuffled,
            shuffledWords: round.shuffledWords,
            explanationUz: round.explanationUz,
          );
        }
        return round;
      }));
    }

    return copy.take(count).toList();
  }
}
