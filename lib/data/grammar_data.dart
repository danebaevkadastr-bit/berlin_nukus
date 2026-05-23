import '../models/grammar_level.dart';

class GrammarData {
  static List<GrammarLevel> get allLevels => [
    _a1Level,
    _a2Level,
    _b1Level,
    _b2Level,
  ];

  static GrammarLevel get a1Level => _a1Level;
  static GrammarLevel get a2Level => _a2Level;
  static GrammarLevel get b1Level => _b1Level;
  static GrammarLevel get b2Level => _b2Level;

  // A1 Daraja
  static final GrammarLevel _a1Level = GrammarLevel(
    id: 'a1',
    level: 'A1',
    title: 'Boshlang\'ich',
    description: 'Bu daraja kundalik hayotda oddiy jumlalarni tushunish va tuzish uchun asosiy grammatik poydevorni yaratadi.',
    emoji: '📚',
    categories: [
      GrammarCategory(
        id: 'a1_verbs',
        name: 'Fe\'llar (Verbs)',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'a1_prasens',
            title: 'Hozirgi zamon (Präsens)',
            description: 'Muntazam, nomuntazam va ajraluvchi fe\'llar; sein, haben fe\'llari',
            rules: [
              GrammarRule(
                id: 'a1_prasens_1',
                title: 'Muntazam fe\'llar',
                explanation: 'Muntazam fe\'llar -en tugaydi va quyidagicha tuslanadi: ich spreche, du sprichst, er/sie/es spricht, wir sprechen, ihr sprecht, sie sprechen.',
                examples: [
                  'Ich spreche Deutsch.',
                  'Du lernst viel.',
                  'Er arbeitet heute.',
                ],
              ),
              GrammarRule(
                id: 'a1_prasens_2',
                title: 'Nomuntazam fe\'llar',
                explanation: 'Nomuntazam fe\'llarning 2-shakli (o\'tgan zamon) va 3-shakli (Partizip II) o\'zgaradi. Masalan: sein (ist, war, gewesen), haben (hat, hatte, gehabt).',
                examples: [
                  'Ich bin Student.',
                  'Er hat ein Auto.',
                  'Sie geht nach Hause.',
                ],
              ),
              GrammarRule(
                id: 'a1_prasens_3',
                title: 'Ajraluvchi fe\'llar (Trennbare Verben)',
                explanation: 'Ajraluvchi fe\'llar prefiks bilan tugaydi (ab, an, auf, ein, fort, her, hin, mit, nach, vor, weg, zu). Gapda prefiks oxirga chiqadi.',
                examples: [
                  'Ich stehe um 7 Uhr auf.',
                  'Er kommt bald an.',
                  'Wir gehen heute aus.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_modal',
            title: 'Modal fe\'llar',
            description: 'können, müssen, dürfen, möchten',
            rules: [
              GrammarRule(
                id: 'a1_modal_1',
                title: 'Modal fe\'llarning tuslanishi',
                explanation: 'Modal fe\'llar -en tugaydi va 2-shakli o\'zgaradi: kann/konnte, muss/musste, darf/durfte, möchte/möchte.',
                examples: [
                  'Ich kann schwimmen.',
                  'Du musst lernen.',
                  'Er darf hier rauchen.',
                  'Wir möchten gehen.',
                ],
              ),
              GrammarRule(
                id: 'a1_modal_2',
                title: 'Modal fe\'llar bilan gap tuzish',
                explanation: 'Modal fe\'l + infinitiv gap oxirida turadi.',
                examples: [
                  'Ich kann Deutsch sprechen.',
                  'Du musst heute lernen.',
                  'Sie möchte Tee trinken.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_imperativ',
            title: 'Buyruq mayli (Imperativ)',
            description: 'Buyruq gaplar tuzish',
            rules: [
              GrammarRule(
                id: 'a1_imperativ_1',
                title: 'Imperativ shakllari',
                explanation: 'Du: komm! / Sie: kommen Sie! / Ihr: kommt! / Wir: kommen wir!',
                examples: [
                  'Komm hierher!',
                  'Gehen Sie bitte!',
                  'Kommt schnell!',
                  'Lassen Sie uns gehen!',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_prateritum',
            title: 'O\'tgan zamon (Präteritum)',
            description: 'sein va haben fe\'llari uchun',
            rules: [
              GrammarRule(
                id: 'a1_prateritum_1',
                title: 'sein va haben',
                explanation: 'sein: ich war, du warst, er war, wir waren, ihr wart, sie waren. haben: ich hatte, du hattest, er hatte, wir hatten, ihr hattet, sie hatten.',
                examples: [
                  'Ich war gestern im Kino.',
                  'Er hatte viel Zeit.',
                  'Wir waren zu Hause.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a1_nouns',
        name: 'Otlar va Artikllar',
        icon: '📝',
        topics: [
          GrammarTopic(
            id: 'a1_articles',
            title: 'Artikllar',
            description: 'Aniq (der/die/das), noaniq (ein/eine) va inkor (kein)',
            rules: [
              GrammarRule(
                id: 'a1_articles_1',
                title: 'Aniq artikllar',
                explanation: 'der - erkak otlar, die - ayol otlar, das - neytral otlar. Ko\'plik: die.',
                examples: [
                  'Der Mann, die Frau, das Kind.',
                  'Die Männer, die Frauen, die Kinder.',
                ],
              ),
              GrammarRule(
                id: 'a1_articles_2',
                title: 'Noaniq artikllar',
                explanation: 'ein - erkak/neytral, eine - ayol. Ko\'plikda yo\'q.',
                examples: [
                  'Ein Mann, eine Frau, ein Kind.',
                ],
              ),
              GrammarRule(
                id: 'a1_articles_3',
                title: 'Inkor artikllar',
                explanation: 'kein - "yo\'q" degan ma\'noni beradi. Tuslanishi ein kabi.',
                examples: [
                  'Ich habe kein Auto.',
                  'Sie hat keine Zeit.',
                  'Wir haben keine Bücher.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_plural',
            title: 'Ko\'plik shakllari',
            description: 'Otlarning ko\'plik shakllari',
            rules: [
              GrammarRule(
                id: 'a1_plural_1',
                title: 'Ko\'plik shakllari',
                explanation: '-e, -er, -en, -s, -n, o\'zgarishsiz. Ba\'zida umlaut (ä, ö, ü) qo\'shiladi.',
                examples: [
                  'Tisch - Tische',
                  'Haus - Häuser',
                  'Kind - Kinder',
                  'Buch - Bücher',
                  'Auto - Autos',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_possessive',
            title: 'Egalik artikllari',
            description: 'mein, dein, sein, ihr (Nominativ)',
            rules: [
              GrammarRule(
                id: 'a1_possessive_1',
                title: 'Egalik artikllari',
                explanation: 'mein (mening), dein (sening), sein (uning), ihr (uning - ayol), unser (bizning), euer (sizning), ihr (ularning).',
                examples: [
                  'Das ist mein Buch.',
                  'Das ist dein Auto.',
                  'Das ist ihr Haus.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a1_cases',
        name: 'Holatlar (Cases)',
        icon: '📋',
        topics: [
          GrammarTopic(
            id: 'a1_nominativ',
            title: 'Nominativ',
            description: 'Ega va kesim',
            rules: [
              GrammarRule(
                id: 'a1_nominativ_1',
                title: 'Nominativ ishlatilishi',
                explanation: 'Ega (wer?) va kesim (was?) savollariga javob. Fe\'lning 1-shakli bilan ishlaydi.',
                examples: [
                  'Der Mann kommt.',
                  'Das Kind spielt.',
                  'Ich bin Student.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_akkusativ',
            title: 'Akkusativ',
            description: 'To\'ldiruvchi, ba\'zi predloglar bilan',
            rules: [
              GrammarRule(
                id: 'a1_akkusativ_1',
                title: 'Akkusativ tuslanishi',
                explanation: 'der → den, ein → einen. die, das, eine o\'zgarmaydi. Ko\'plik: die.',
                examples: [
                  'Ich sehe den Mann.',
                  'Er hat ein Auto.',
                  'Wir kaufen das Buch.',
                ],
              ),
              GrammarRule(
                id: 'a1_akkusativ_2',
                title: 'Akkusativ predloglari',
                explanation: 'durch, für, gegen, ohne, um predloglari Akkusativ bilan keladi.',
                examples: [
                  'Ich gehe durch den Park.',
                  'Das ist für dich.',
                  'Ohne Wasser kann man nicht leben.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a1_pronouns',
        name: 'Olmoshlar (Pronouns)',
        icon: '👤',
        topics: [
          GrammarTopic(
            id: 'a1_personal',
            title: 'Kishilik olmoshlari',
            description: 'Nominativ va Akkusativ',
            rules: [
              GrammarRule(
                id: 'a1_personal_1',
                title: 'Kishilik olmoshlari',
                explanation: 'Nominativ: ich, du, er/sie/es, wir, ihr, sie/Sie. Akkusativ: mich, dich, ihn/sie/es, uns, euch, sie/Sie.',
                examples: [
                  'Ich sehe dich.',
                  'Er liebt sie.',
                  'Wir besuchen euch.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_question',
            title: 'So\'roq olmoshlari',
            description: 'wer, was, wie, wo',
            rules: [
              GrammarRule(
                id: 'a1_question_1',
                title: 'So\'roq olmoshlari',
                explanation: 'wer (kim), was (nima), wie (qanday), wo (qayerda).',
                examples: [
                  'Wer kommt?',
                  'Was machst du?',
                  'Wie geht es dir?',
                  'Wo wohnst du?',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a1_sentence',
        name: 'Gap Tuzilishi',
        icon: '💬',
        topics: [
          GrammarTopic(
            id: 'a1_statement',
            title: 'Darak gaplar',
            description: 'Asosiy gap tuzilishi',
            rules: [
              GrammarRule(
                id: 'a1_statement_1',
                title: 'Gap tartibi',
                explanation: 'Ega - Fe\'l - To\'ldiruvchi - Vaqt - Joy - Usul.',
                examples: [
                  'Ich lerne heute Deutsch.',
                  'Er geht morgen zur Schule.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_question',
            title: 'So\'roq gaplar',
            description: 'W-Fragen va Ja/Nein-Fragen',
            rules: [
              GrammarRule(
                id: 'a1_question_1',
                title: 'W-Fragen',
                explanation: 'So\'roq olmosh gap boshlanadi, fe\'l 2-o\'rinda turadi.',
                examples: [
                  'Wo wohnst du?',
                  'Was lernst du?',
                  'Wann kommst du?',
                ],
              ),
              GrammarRule(
                id: 'a1_question_2',
                title: 'Ja/Nein-Fragen',
                explanation: 'Fe\'l gap boshlanadi.',
                examples: [
                  'Lernst du Deutsch?',
                  'Kommst du heute?',
                  'Hast du Zeit?',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_connectors',
            title: 'Bog\'lovchilar',
            description: 'und, aber, oder, denn',
            rules: [
              GrammarRule(
                id: 'a1_connectors_1',
                title: 'Asosiy bog\'lovchilar',
                explanation: 'und (va), aber (lekin), oder (yoki), denn (chunki). Bog\'lovchidan keyin fe\'l 2-o\'rinda turadi.',
                examples: [
                  'Ich lerne und arbeite.',
                  'Er ist reich, aber glücklich.',
                  'Kommst du oder gehst du?',
                  'Ich bleibe zu Hause, denn ich bin krank.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a1_negation',
        name: 'Inkor (Negation)',
        icon: '❌',
        topics: [
          GrammarTopic(
            id: 'a1_nicht_kein',
            title: 'nicht va kein',
            description: 'Inkor qilish',
            rules: [
              GrammarRule(
                id: 'a1_nicht_kein_1',
                title: 'nicht ishlatilishi',
                explanation: 'nicht - fe\'llar, sifatlar, olmoshlar, predloglar bilan ishlaydi. Gap oxirida turadi.',
                examples: [
                  'Ich lerne nicht.',
                  'Er ist nicht zu Hause.',
                  'Das ist nicht mein Buch.',
                ],
              ),
              GrammarRule(
                id: 'a1_nicht_kein_2',
                title: 'kein ishlatilishi',
                explanation: 'kein - aniq artiklli otlar bilan ishlaydi. O\'t oldin turadi.',
                examples: [
                  'Ich habe kein Auto.',
                  'Sie hat keine Zeit.',
                  'Wir haben keine Bücher.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a1_adjectives',
        name: 'Sifatlar (Adjectives)',
        icon: '🎨',
        topics: [
          GrammarTopic(
            id: 'a1_predicative',
            title: 'Predikativ sifatlar',
            description: 'Das ist gut.',
            rules: [
              GrammarRule(
                id: 'a1_predicative_1',
                title: 'Predikativ sifatlar',
                explanation: 'Sifat gap oxirida, tuslanmagan holda keladi.',
                examples: [
                  'Das ist gut.',
                  'Er ist groß.',
                  'Das Auto ist schnell.',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // A2 Daraja
  static final GrammarLevel _a2Level = GrammarLevel(
    id: 'a2',
    level: 'A2',
    title: 'Boshlang\'ich O\'rta',
    description: 'A1 dagi asoslarni mustahkamlab, kundalik vaziyatlarda biroz murakkabroq jumlalar tuzishga o\'tiladi.',
    emoji: '📗',
    categories: [
      GrammarCategory(
        id: 'a2_verbs',
        name: 'Fe\'llar (Verbs)',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'a2_perfekt',
            title: 'O\'tgan zamon (Perfekt)',
            description: 'haben va sein yordamchi fe\'llari bilan',
            rules: [
              GrammarRule(
                id: 'a2_perfekt_1',
                title: 'Perfekt tuzilishi',
                explanation: 'haben/sein + Partizip II. haben - ko\'pchilik fe\'llar bilan, sein - harakat/joy o\'zgarish fe\'llari bilan.',
                examples: [
                  'Ich habe gegessen.',
                  'Er ist gegangen.',
                  'Wir haben gearbeitet.',
                  'Sie ist gekommen.',
                ],
              ),
              GrammarRule(
                id: 'a2_perfekt_2',
                title: 'Partizip II shakllari',
                explanation: 'Muntazam: ge-st-t. Nomuntazam: 3-shakl. Ajraluvchi: ge...t.',
                examples: [
                  'gearbeitet, gemacht, gekauft',
                  'gegessen, getrunken, gesehen',
                  'aufgestanden, eingekauft',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_modal_prateritum',
            title: 'Modal fe\'llarning o\'tgan zamoni',
            description: 'Präteritum',
            rules: [
              GrammarRule(
                id: 'a2_modal_prateritum_1',
                title: 'Modal fe\'llar Präteritum',
                explanation: 'konnte, musste, durfte, wollte, mochte.',
                examples: [
                  'Ich konnte nicht kommen.',
                  'Er musste lernen.',
                  'Sie durfte nicht gehen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_reflexive',
            title: 'Refleksiv (o\'zlik) fe\'llar',
            description: 'O\'zlik olmoshlari bilan',
            rules: [
              GrammarRule(
                id: 'a2_reflexive_1',
                title: 'Refleksiv fe\'llar',
                explanation: 'O\'zlik olmoshlari: mich, dich, sich, uns, euch, sich. Akkusativ yoki Dativ bilan ishlaydi.',
                examples: [
                  'Ich wasche mich.',
                  'Er freut sich.',
                  'Wir treffen uns.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_konjunktiv2',
            title: 'Konjunktiv II',
            description: 'Xushmuomala iltimoslar',
            rules: [
              GrammarRule(
                id: 'a2_konjunktiv2_1',
                title: 'würde, könnte',
                explanation: 'würde + infinitiv, könnte + infinitiv. Xushmuomala iltimoslar uchun.',
                examples: [
                  'Ich würde gerne helfen.',
                  'Könnten Sie mir helfen?',
                  'Er würde kommen.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a2_cases',
        name: 'Holatlar (Cases)',
        icon: '📋',
        topics: [
          GrammarTopic(
            id: 'a2_dativ',
            title: 'Dativ',
            description: 'To\'ldiruvchi va predloglar bilan',
            rules: [
              GrammarRule(
                id: 'a2_dativ_1',
                title: 'Dativ tuslanishi',
                explanation: 'der → dem, die → der, das → dem. ein → einem, eine → einer. Ko\'plik: den + -n.',
                examples: [
                  'Ich helfe dem Mann.',
                  'Er gibt der Frau das Buch.',
                  'Wir sprechen mit dem Kind.',
                ],
              ),
              GrammarRule(
                id: 'a2_dativ_2',
                title: 'Dativ predloglari',
                explanation: 'aus, bei, mit, nach, seit, von, zu predloglari Dativ bilan keladi.',
                examples: [
                  'Ich komme aus Deutschland.',
                  'Er ist bei mir.',
                  'Wir sprechen mit ihm.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_prepositions',
            title: 'Old qo\'shimchalar',
            description: 'Wechselpräpositionen',
            rules: [
              GrammarRule(
                id: 'a2_prepositions_1',
                title: 'Wechselpräpositionen',
                explanation: 'an, auf, in, neben, unter, vor, hinter, zwischen. Harakat - Akkusativ, joy - Dativ.',
                examples: [
                  'Ich gehe in das Haus. (Akkusativ)',
                  'Ich bin in dem Haus. (Dativ)',
                  'Er stellt das Buch auf den Tisch.',
                  'Das Buch liegt auf dem Tisch.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a2_adjectives',
        name: 'Sifatlar (Adjectives)',
        icon: '🎨',
        topics: [
          GrammarTopic(
            id: 'a2_declension',
            title: 'Sifatlarning tuslanishi',
            description: 'Adjektivdeklination',
            rules: [
              GrammarRule(
                id: 'a2_declension_1',
                title: 'Aniq artikl bilan',
                explanation: '-e (Nominativ erkak), -en (Akkusativ erkak/neytral, Dativ barcha, Genitiv barcha).',
                examples: [
                  'der gute Mann',
                  'den guten Mann',
                  'dem guten Mann',
                  'des guten Mannes',
                ],
              ),
              GrammarRule(
                id: 'a2_declension_2',
                title: 'Noaniq artikl bilan',
                explanation: '-er (Nominativ erkak), -es (Nominativ neytral), -e (Nominativ ayol/ko\'plik).',
                examples: [
                  'ein guter Mann',
                  'ein gutes Buch',
                  'eine gute Frau',
                ],
              ),
              GrammarRule(
                id: 'a2_declension_3',
                title: 'Artiklsiz',
                explanation: '-er (Nominativ erkak), -es (Nominativ neytral), -e (Nominativ ayol), -en (boshqa holatlar).',
                examples: [
                  'guter Mann',
                  'gutes Buch',
                  'gute Frau',
                  'guten Mannes',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_comparison',
            title: 'Qiyosiy va orttirma darajalar',
            description: 'Komparativ/Superlativ',
            rules: [
              GrammarRule(
                id: 'a2_comparison_1',
                title: 'Komparativ',
                explanation: '-er qo\'shiladi. Ba\'zida umlaut.',
                examples: [
                  'schneller, größer, besser',
                  'Er ist schneller als ich.',
                ],
              ),
              GrammarRule(
                id: 'a2_comparison_2',
                title: 'Superlativ',
                explanation: 'am -sten. Ba\'zida umlaut.',
                examples: [
                  'am schnellsten, am größten, am besten',
                  'Er ist am schnellsten.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a2_connectors',
        name: 'Bog\'lovchilar (Connectors)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'a2_subordinate',
            title: 'Ergashgan qo\'shma gaplar',
            description: 'weil, wenn, dass',
            rules: [
              GrammarRule(
                id: 'a2_subordinate_1',
                title: 'weil (chunki)',
                explanation: 'weil gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Ich komme nicht, weil ich keine Zeit habe.',
                  'Er ist glücklich, weil er Erfolg hat.',
                ],
              ),
              GrammarRule(
                id: 'a2_subordinate_2',
                title: 'wenn (agar/kachon)',
                explanation: 'wenn gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Wenn ich Zeit habe, komme ich.',
                  'Wenn es regnet, bleibe ich zu Hause.',
                ],
              ),
              GrammarRule(
                id: 'a2_subordinate_3',
                title: 'dass (ki)',
                explanation: 'dass gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Ich denke, dass er kommt.',
                  'Er sagt, dass er Deutsch lernt.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'a2_other',
        name: 'Boshqa',
        icon: '📌',
        topics: [
          GrammarTopic(
            id: 'a2_indirect',
            title: 'Bilvosita so\'roq gaplar',
            description: '',
            rules: [
              GrammarRule(
                id: 'a2_indirect_1',
                title: 'Bilvosita so\'roq gaplar',
                explanation: 'So\'roq gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Ich frage, ob er kommt.',
                  'Er weiß nicht, was das ist.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_relative',
            title: 'Nisbiy olmoshlar',
            description: 'Nominativ holati bilan tanishuv',
            rules: [
              GrammarRule(
                id: 'a2_relative_1',
                title: 'Nisbiy olmoshlar',
                explanation: 'der, die, das, die (ko\'plik). O\'t oldin keladi, tuslanadi.',
                examples: [
                  'Der Mann, der kommt, ist mein Freund.',
                  'Das Buch, das ich lese, ist interessant.',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // B1 Daraja
  static final GrammarLevel _b1Level = GrammarLevel(
    id: 'b1',
    level: 'B1',
    title: 'O\'rta',
    description: 'O\'z fikrini izchil ifodalash, tajribalar haqida hikoya qilish va asosli mulohazalar yuritish uchun grammatik vositalar boyitiladi.',
    emoji: '📙',
    categories: [
      GrammarCategory(
        id: 'b1_verbs',
        name: 'Fe\'llar (Verbs)',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'b1_all_tenses',
            title: 'Barcha zamon shakllari',
            description: 'Mustahkamlash',
            rules: [
              GrammarRule(
                id: 'b1_all_tenses_1',
                title: 'Zamon shakllari',
                explanation: 'Präsens, Präteritum, Perfekt, Plusquamperfekt, Futur I, Futur II.',
                examples: [
                  'Ich lerne (Präsens)',
                  'Ich lernte (Präteritum)',
                  'Ich habe gelernt (Perfekt)',
                  'Ich hatte gelernt (Plusquamperfekt)',
                  'Ich werde lernen (Futur I)',
                  'Ich werde gelernt haben (Futur II)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_plusquamperfekt',
            title: 'Plusquamperfekt',
            description: 'O\'tgan zamonning o\'tgandagi shakli',
            rules: [
              GrammarRule(
                id: 'b1_plusquamperfekt_1',
                title: 'Plusquamperfekt tuzilishi',
                explanation: 'hatte/war + Partizip II. O\'tgan zamondan oldin bo\'lgan harakat.',
                examples: [
                  'Ich hatte gegessen, als er kam.',
                  'Er war schon gegangen.',
                  'Wir hatten das Buch gelesen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_passiv',
            title: 'Majhul nisbat (Passiv)',
            description: 'Präsens Passiv',
            rules: [
              GrammarRule(
                id: 'b1_passiv_1',
                title: 'Präsens Passiv',
                explanation: 'werden + Partizip II. Obyektga e\'tibor beriladi.',
                examples: [
                  'Das Buch wird gelesen.',
                  'Das Haus wird gebaut.',
                  'Der Brief wird geschrieben.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_konjunktiv2_advanced',
            title: 'Konjunktiv II',
            description: 'Irreal istak va shartlar',
            rules: [
              GrammarRule(
                id: 'b1_konjunktiv2_advanced_1',
                title: 'Irreal istak',
                explanation: 'wäre, hätte, könnte, würde + Partizip II.',
                examples: [
                  'Ich wäre gerne reich.',
                  'Er hätte gerne ein Auto.',
                  'Sie könnte kommen.',
                ],
              ),
              GrammarRule(
                id: 'b1_konjunktiv2_advanced_2',
                title: 'Irreal shart',
                explanation: 'wenn + Konjunktiv II.',
                examples: [
                  'Wenn ich Zeit hätte, käme ich.',
                  'Wenn er reich wäre, würde er helfen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_lassen',
            title: 'lassen fe\'lining maxsus ishlatilishi',
            description: '',
            rules: [
              GrammarRule(
                id: 'b1_lassen_1',
                title: 'lassen + infinitiv',
                explanation: 'Qilishga ruxsat berish yoki qilishni buyurish.',
                examples: [
                  'Ich lasse ihn kommen.',
                  'Er lässt das Auto reparieren.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b1_connectors',
        name: 'Bog\'lovchilar (Connectors)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'b1_two_part',
            title: 'Ikki qismli bog\'lovchilar',
            description: 'entweder...oder, zwar...aber, sowohl...als auch',
            rules: [
              GrammarRule(
                id: 'b1_two_part_1',
                title: 'entweder...oder',
                explanation: 'yoki...yoki',
                examples: [
                  'Entweder du kommst, oder ich gehe.',
                ],
              ),
              GrammarRule(
                id: 'b1_two_part_2',
                title: 'zwar...aber',
                explanation: 'ha...lekin',
                examples: [
                  'Er ist zwar arm, aber glücklich.',
                ],
              ),
              GrammarRule(
                id: 'b1_two_part_3',
                title: 'sowohl...als auch',
                explanation: 'ham...ham',
                examples: [
                  'Er spricht sowohl Deutsch als auch Englisch.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_complex',
            title: 'Murakkab ergashtiruvchi bog\'lovchilar',
            description: 'obwohl, während, nachdem, bevor, falls, um...zu, damit',
            rules: [
              GrammarRule(
                id: 'b1_complex_1',
                title: 'obwohl (garchi)',
                explanation: 'obwohl gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Obwohl es regnet, gehe ich spazieren.',
                ],
              ),
              GrammarRule(
                id: 'b1_complex_2',
                title: 'während (vaqtida)',
                explanation: 'während gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Während ich esse, liest er.',
                ],
              ),
              GrammarRule(
                id: 'b1_complex_3',
                title: 'nachdem (keyin)',
                explanation: 'nachdem gapidan keyin fe\'l oxirga chiqadi. Plusquamperfekt ishlaydi.',
                examples: [
                  'Nachdem er gegessen war, ging er.',
                ],
              ),
              GrammarRule(
                id: 'b1_complex_4',
                title: 'bevor (oldin)',
                explanation: 'bevor gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Bevor er kommt, trinke ich Kaffee.',
                ],
              ),
              GrammarRule(
                id: 'b1_complex_5',
                title: 'falls (agar)',
                explanation: 'falls gapidan keyin fe\'l oxirga chiqadi.',
                examples: [
                  'Falls du kommst, rufe mich an.',
                ],
              ),
              GrammarRule(
                id: 'b1_complex_6',
                title: 'um...zu (uchun)',
                explanation: 'Maqsadni bildiradi. Subyekt bir xil bo\'lishi kerak.',
                examples: [
                  'Ich lerne, um die Prüfung zu bestehen.',
                ],
              ),
              GrammarRule(
                id: 'b1_complex_7',
                title: 'damit (uchun)',
                explanation: 'Maqsadni bildiradi. Subyekt har xil bo\'lishi mumkin.',
                examples: [
                  'Ich helfe dir, damit du die Prüfung bestehst.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b1_relative',
        name: 'Nisbiy olmoshlar (Relativsätze)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'b1_all_cases',
            title: 'Barcha holatlarda',
            description: 'Nominativ, Akkusativ, Dativ',
            rules: [
              GrammarRule(
                id: 'b1_all_cases_1',
                title: 'Nisbiy olmoshlar tuslanishi',
                explanation: 'Nominativ: der/die/das/die. Akkusativ: den/die/das/die. Dativ: dem/der/dem/den.',
                examples: [
                  'Der Mann, den ich sehe, ist mein Freund.',
                  'Das Buch, das ich lese, ist interessant.',
                  'Die Frau, der ich helfe, ist meine Mutter.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b1_nouns',
        name: 'Sifat va Otlar',
        icon: '📝',
        topics: [
          GrammarTopic(
            id: 'b1_nominalization',
            title: 'Sifatlarning otlashuvi',
            description: 'der/die Angestellte',
            rules: [
              GrammarRule(
                id: 'b1_nominalization_1',
                title: 'Sifatdosh otlar',
                explanation: 'Sifat + -e/-er. Aniq artikl bilan ishlaydi.',
                examples: [
                  'der Angestellte, die Angestellte',
                  'der Reisende, die Reisende',
                  'der Kranke, die Kranke',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_weak_declension',
            title: 'Zaif otlar turlanishi',
            description: 'N-Deklination',
            rules: [
              GrammarRule(
                id: 'b1_weak_declension_1',
                title: 'N-Deklination',
                explanation: '-n/-en qo\'shiladi. Erkak va neytral otlar. Masalan: Student, Name, Herr.',
                examples: [
                  'der Student, den Studenten, dem Studenten',
                  'der Name, den Namen, dem Namen',
                  'der Herr, den Herrn, dem Herrn',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b1_other',
        name: 'Boshqa',
        icon: '📌',
        topics: [
          GrammarTopic(
            id: 'b1_genitive_prepositions',
            title: 'Genitiv old qo\'simchalari',
            description: 'wegen, trotz, während',
            rules: [
              GrammarRule(
                id: 'b1_genitive_prepositions_1',
                title: 'Genitiv predloglari',
                explanation: 'wegen (sababli), trotz (ga qaramay), während (vaqtida).',
                examples: [
                  'Wegen des Regens bleibe ich zu Hause.',
                  'Trotz des Wetters gehen wir spazieren.',
                  'Während des Essens spricht er nicht.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_pronoun_compounds',
            title: 'Olmosh qo\'shimchalari',
            description: 'Da-/Wo- Komposita',
            rules: [
              GrammarRule(
                id: 'b1_pronoun_compounds_1',
                title: 'Da-/Wo- Komposita',
                explanation: 'da- + predlog (predlog harf bilan boshlansa), wo- + predlog (predlog undan boshlansa).',
                examples: [
                  'damit, davon, darüber',
                  'womit, wovon, worüber',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // B2 Daraja
  static final GrammarLevel _b2Level = GrammarLevel(
    id: 'b2',
    level: 'B2',
    title: 'Yuqori O\'rta',
    description: 'Bu daraja grammatikani yanada noziklashtirish, murakkab matnlarni tushunish va ravon, puxta mulohaza yuritish ko\'nikmalarini rivojlantirishga qaratilgan.',
    emoji: '📕',
    categories: [
      GrammarCategory(
        id: 'b2_verbs',
        name: 'Fe\'llar (Verbs)',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'b2_passiv_all',
            title: 'Majhul nisbatning barcha zamon shakllari',
            description: 'Passiversatzformen',
            rules: [
              GrammarRule(
                id: 'b2_passiv_all_1',
                title: 'Passiv zamon shakllari',
                explanation: 'Präsens Passiv, Präteritum Passiv, Perfekt Passiv, Plusquamperfekt Passiv, Futur Passiv.',
                examples: [
                  'Das Buch wird gelesen.',
                  'Das Buch wurde gelesen.',
                  'Das Buch ist gelesen worden.',
                  'Das Buch war gelesen worden.',
                  'Das Buch wird gelesen werden.',
                ],
              ),
              GrammarRule(
                id: 'b2_passiv_all_2',
                title: 'Passiversatzformen',
                explanation: 'sein + zu + Infinitiv, sich lassen.',
                examples: [
                  'Das Buch ist zu lesen.',
                  'Das lässt sich machen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_konjunktiv1',
            title: 'Konjunktiv I',
            description: 'Ko\'chirma gap (Indirect Speech)',
            rules: [
              GrammarRule(
                id: 'b2_konjunktiv1_1',
                title: 'Konjunktiv I shakllari',
                explanation: 'Er sagt, er komme (kommen). Ko\'chirma gaplarda ishlaydi.',
                examples: [
                  'Er sagt, er komme morgen.',
                  'Sie sagt, sie habe keine Zeit.',
                  'Er sagt, er sei krank.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_modal_subjective',
            title: 'Modal fe\'llarning subyektiv ma\'nolari',
            description: '',
            rules: [
              GrammarRule(
                id: 'b2_modal_subjective_1',
                title: 'Subyektiv modal fe\'llar',
                explanation: 'sollen (xabar), können (imkoniyat), müssen (taxmin), mögen (istak).',
                examples: [
                  'Er soll reich sein. (xabar)',
                  'Das kann wahr sein. (imkoniyat)',
                  'Er muss zu Hause sein. (taxmin)',
                  'Er mag hier sein. (istak)',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b2_nominalization',
        name: 'Nominalizatsiya (Nominal Style)',
        icon: '📝',
        topics: [
          GrammarTopic(
            id: 'b2_nominalization',
            title: 'Fe\'l va sifatlarning otlashuvi',
            description: 'Nominalisierung',
            rules: [
              GrammarRule(
                id: 'b2_nominalization_1',
                title: 'Nominalizatsiya',
                explanation: 'Fe\'l va sifatlarni otlarga aylantirish. Rasmiy va ilmiy matnlarda ishlaydi.',
                examples: [
                  'Das Lesen ist wichtig. (lesen → Das Lesen)',
                  'Die Entwicklung ist schnell. (entwickeln → Die Entwicklung)',
                  'Die Lösung ist einfach. (lösen → Die Lösung)',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b2_connectors',
        name: 'Bog\'lovchilar (Connectors)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'b2_complex',
            title: 'Murakkab bog\'lovchilar',
            description: 'Keng doiradagi bog\'lovchilar',
            rules: [
              GrammarRule(
                id: 'b2_complex_1',
                title: 'Murakkab bog\'lovchilar',
                explanation: 'indem, ohne dass, solange, sobald, je...desto.',
                examples: [
                  'Indem er arbeitet, verdient er Geld.',
                  'Ohne dass er es weiß, gehe ich.',
                  'Solange er hier ist, bleibe ich.',
                  'Sobald er kommt, beginnen wir.',
                  'Je mehr er lernt, desto besser wird er.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_modal',
            title: 'Modallikni ifodalovchi bog\'lovchilar',
            description: 'indem, ohne dass',
            rules: [
              GrammarRule(
                id: 'b2_modal_1',
                title: 'Modallik bog\'lovchilari',
                explanation: 'indem (shunday qilib), ohne dass (siz...siz).',
                examples: [
                  'Er lernt, indem er liest.',
                  'Er geht, ohne dass er sich verabschiedet.',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b2_adjectives',
        name: 'Sifatlar (Adjectives)',
        icon: '🎨',
        topics: [
          GrammarTopic(
            id: 'b2_participles',
            title: 'Partizip I va Partizip II',
            description: 'Sifatdosh sifat sifatida',
            rules: [
              GrammarRule(
                id: 'b2_participles_1',
                title: 'Partizip I',
                explanation: '-d. Davom etayotgan harakatni bildiradi.',
                examples: [
                  'das lachende Kind',
                  'die fließenden Wasser',
                ],
              ),
              GrammarRule(
                id: 'b2_participles_2',
                title: 'Partizip II',
                explanation: 'Tugagan harakatni bildiradi.',
                examples: [
                  'das gelesene Buch',
                  'die geschlossene Tür',
                ],
              ),
            ],
          ),
        ],
      ),
      GrammarCategory(
        id: 'b2_sentence',
        name: 'Gap Tuzilishi',
        icon: '💬',
        topics: [
          GrammarTopic(
            id: 'b2_word_order',
            title: 'So\'z tartibi',
            description: 'Modalpartikeln',
            rules: [
              GrammarRule(
                id: 'b2_word_order_1',
                title: 'Modalpartikeln',
                explanation: 'ja, doch, mal, schon, halt, eben. Emotsiyani ifodalaydi.',
                examples: [
                  'Das ist ja toll!',
                  'Komm mal her!',
                  'Das ist doch klar!',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_extended',
            title: 'Kengaytirilgan sifat qo\'shimchalari',
            description: '',
            rules: [
              GrammarRule(
                id: 'b2_extended_1',
                title: 'Kengaytirilgan sifat qo\'shimchalari',
                explanation: 'Sifat qo\'shimchalari bilan murakkab tuzilmalar.',
                examples: [
                  'Der sehr schnell laufende Hund.',
                  'Die von mir geschriebene E-Mail.',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
