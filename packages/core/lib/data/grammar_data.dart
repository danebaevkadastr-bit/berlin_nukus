import '../models/grammar_level.dart';
import '../models/grammar_explanation.dart';
import '../models/grammar_table.dart';
import '../models/grammar_example.dart';

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

  // ─────────────────────────────────────────────────────────
  // A1 Daraja
  // ─────────────────────────────────────────────────────────
  static final GrammarLevel _a1Level = GrammarLevel(
    id: 'a1',
    level: 'A1',
    title: 'Boshlang\'ich',
    description: 'Kundalik hayotda oddiy jumlalarni tushunish va tuzish uchun asosiy grammatik poydevorni yaratadi.',
    emoji: '📚',
    categories: [

      // ── 1. FE'LLAR ─────────────────────────────────────────
      GrammarCategory(
        id: 'a1_verbs',
        name: 'Fe\'llar (Verben)',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'a1_prasens',
            title: 'Hozirgi zamon (Präsens)',
            description: 'Muntazam, nomuntazam va ajraluvchi fe\'llar; sein, haben',
            rules: [
              GrammarRule(
                id: 'a1_prasens_1',
                title: 'Muntazam fe\'llar (reguläre Verben)',
                explanation: 'Asosga shaxs qo\'shimchalari qo\'shiladi:\n• ich -e → lerne\n• du -st → lernst\n• er/sie/es -t → lernt\n• wir -en → lernen\n• ihr -t → lernt\n• sie/Sie -en → lernen',
                examples: [
                  'Ich lerne Deutsch.',
                  'Du spielst Fußball.',
                  'Er arbeitet heute.',
                  'Wir wohnen in Berlin.',
                ],
                detailedExplanation: const GrammarExplanation(
                  theoryText: '''Nemis tilida hozirgi zamon (Präsens) fe'llarni tuslantirishda qo'llaniladi. Fe'l tuslanishi shaxs va songa qarab o'zgaradi.

**Fe'l tuslanishi qoidalari:**

1. **Infinitiv shakli** — fe'lning asosiy shakli bo'lib, -en yoki -n bilan tugaydi (lernen, arbeiten, sammeln).

2. **Asos (Stamm)** — infinitivdan -en yoki -n ni olib tashlash orqali hosil qilinadi:
   • lernen → lern-
   • arbeiten → arbeit-
   • spielen → spiel-

3. **Shaxs qo'shimchalari** — asosga qo'shiladi:
   • ich → -e
   • du → -st
   • er/sie/es → -t
   • wir → -en
   • ihr → -t
   • sie/Sie → -en

**Muhim qoidalar:**

• Agar asos -t, -d, -chn, -ffn, -gn bilan tugasa, du, er/sie/es va ihr shakllarida -e- qo'shiladi:
  arbeiten → du arbeitest, er arbeitet, ihr arbeitet

• Agar asos -s, -ß, -x, -z bilan tugasa, du shaklida faqat -t qo'shiladi:
  reisen → du reist (reisst emas)

**sein va haben fe'llari** — eng ko'p ishlatiladigan yordamchi fe'llar bo'lib, ular nomuntazam tuslanadi va alohida yodlash kerak.''',
                  tables: [
                    GrammarTable(
                      title: 'sein (bo\'lmoq) fe\'li tuslanishi',
                      headers: ['Shaxs', 'Tuslanish', 'Misol'],
                      rows: [
                        ['ich', 'bin', 'Ich bin Student.'],
                        ['du', 'bist', 'Du bist müde.'],
                        ['er/sie/es', 'ist', 'Er ist groß.'],
                        ['wir', 'sind', 'Wir sind hier.'],
                        ['ihr', 'seid', 'Ihr seid nett.'],
                        ['sie/Sie', 'sind', 'Sie sind Lehrer.'],
                      ],
                    ),
                    GrammarTable(
                      title: 'haben (ega bo\'lmoq) fe\'li tuslanishi',
                      headers: ['Shaxs', 'Tuslanish', 'Misol'],
                      rows: [
                        ['ich', 'habe', 'Ich habe ein Buch.'],
                        ['du', 'hast', 'Du hast Zeit.'],
                        ['er/sie/es', 'hat', 'Er hat Hunger.'],
                        ['wir', 'haben', 'Wir haben Geld.'],
                        ['ihr', 'habt', 'Ihr habt Glück.'],
                        ['sie/Sie', 'haben', 'Sie haben Kinder.'],
                      ],
                    ),
                    GrammarTable(
                      title: 'Muntazam fe\'llar tuslanishi (lernen, spielen, arbeiten)',
                      headers: ['Shaxs', 'lernen', 'spielen', 'arbeiten'],
                      rows: [
                        ['ich', 'lerne', 'spiele', 'arbeite'],
                        ['du', 'lernst', 'spielst', 'arbeitest'],
                        ['er/sie/es', 'lernt', 'spielt', 'arbeitet'],
                        ['wir', 'lernen', 'spielen', 'arbeiten'],
                        ['ihr', 'lernt', 'spielt', 'arbeitet'],
                        ['sie/Sie', 'lernen', 'spielen', 'arbeiten'],
                      ],
                    ),
                  ],
                  examples: [
                    GrammarExample(
                      german: 'Ich lerne jeden Tag Deutsch.',
                      uzbek: 'Men har kuni nemis tilini o\'rganaman.',
                      note: 'ich + lern + e = lerne',
                    ),
                    GrammarExample(
                      german: 'Du spielst sehr gut Fußball.',
                      uzbek: 'Sen futbolni juda yaxshi o\'ynaysan.',
                      note: 'du + spiel + st = spielst',
                    ),
                    GrammarExample(
                      german: 'Er arbeitet in einer Firma.',
                      uzbek: 'U firmada ishlaydi.',
                      note: 'arbeit + et (asos -t bilan tugagani uchun -e- qo\'shildi)',
                    ),
                    GrammarExample(
                      german: 'Wir wohnen in Berlin.',
                      uzbek: 'Biz Berlinda yashaymiz.',
                      note: 'wir + wohn + en = wohnen',
                    ),
                    GrammarExample(
                      german: 'Sie ist Lehrerin und er ist Arzt.',
                      uzbek: 'U (ayol) o\'qituvchi va u (erkak) shifokor.',
                      note: 'sein fe\'li: sie ist, er ist',
                    ),
                    GrammarExample(
                      german: 'Habt ihr morgen Zeit?',
                      uzbek: 'Sizlar ertaga vaqtingiz bormi?',
                      note: 'haben fe\'li: ihr habt',
                    ),
                  ],
                ),
              ),
              GrammarRule(
                id: 'a1_prasens_2',
                title: 'sein va haben — asosiy fe\'llar',
                explanation: 'sein: ich bin, du bist, er ist, wir sind, ihr seid, sie sind.\nhaben: ich habe, du hast, er hat, wir haben, ihr habt, sie haben.',
                examples: [
                  'Ich bin Student.',
                  'Er hat ein Auto.',
                  'Wir sind müde.',
                  'Habt ihr Zeit?',
                ],
              ),
              GrammarRule(
                id: 'a1_prasens_3',
                title: 'Ajraluvchi fe\'llar (Trennbare Verben)',
                explanation: 'Prefiks (auf-, an-, ein-, ab-, mit-, nach-, zu-, weg-, vor-) gapda oxirga chiqadi.',
                examples: [
                  'Ich stehe um 7 Uhr auf. (aufstehen)',
                  'Er ruft seine Mutter an. (anrufen)',
                  'Wir kaufen im Supermarkt ein. (einkaufen)',
                  'Der Unterricht fängt an. (anfangen)',
                ],
              ),
              GrammarRule(
                id: 'a1_prasens_4',
                title: 'Nomuntazam fe\'llar (unregelmäßige Verben)',
                explanation: 'Du va er/sie/es shaklida ildiz unli o\'zgaradi (Vokalwechsel): a→ä, e→i, e→ie.',
                examples: [
                  'lesen: ich lese, du liest, er liest',
                  'fahren: ich fahre, du fährst, er fährt',
                  'sprechen: ich spreche, du sprichst, er spricht',
                  'schlafen: ich schlafe, du schläfst, er schläft',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_modal',
            title: 'Modal fe\'llar (Modalverben)',
            description: 'können, müssen, dürfen, wollen, sollen, möchten',
            rules: [
              GrammarRule(
                id: 'a1_modal_1',
                title: 'Modal fe\'llarning tuslanishi',
                explanation: 'Modal fe\'l 2-o\'rinda, asosiy fe\'l infinitiv holda oxirida turadi.\nkönnen: ich kann, du kannst, er kann, wir können\nmüssen: ich muss, du musst, er muss, wir müssen\ndürfen: ich darf, du darfst, er darf, wir dürfen\nwollen: ich will, du willst, er will, wir wollen\nsollen: ich soll, du sollst, er soll, wir sollen',
                examples: [
                  'Ich kann schwimmen. (qila olaman)',
                  'Du musst lernen. (majburmiz)',
                  'Er darf hier rauchen. (ruxsat bor)',
                  'Wir wollen reisen. (xohlaymiz)',
                  'Sie möchten Tee trinken. (iltimosiy)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_imperativ',
            title: 'Buyruq mayli (Imperativ)',
            description: 'Buyruq va iltimos gaplar',
            rules: [
              GrammarRule(
                id: 'a1_imperativ_1',
                title: 'Imperativ shakllari',
                explanation: 'du: asosni ol, -e (ixtiyoriy) → Komm! Lerne!\nihr: gapning asosidir → Kommt! Lernt!\nSie: infinitiv + Sie → Kommen Sie! Lernen Sie!',
                examples: [
                  'Komm bitte her! (du)',
                  'Lest das Buch! (ihr)',
                  'Sprechen Sie langsamer, bitte! (Sie)',
                  'Steh auf! (aufstehen, du)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_prateritum_sein_haben',
            title: 'sein va haben — o\'tgan zamon',
            description: 'Präteritum: war, hatte',
            rules: [
              GrammarRule(
                id: 'a1_prateritum_1',
                title: 'war (sein) va hatte (haben)',
                explanation: 'sein → war, warst, war, waren, wart, waren\nhaben → hatte, hattest, hatte, hatten, hattet, hatten',
                examples: [
                  'Ich war gestern im Kino.',
                  'Er hatte viel Zeit.',
                  'Wir waren sehr müde.',
                  'Sie hatten Hunger.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 2. OTLAR VA ARTIKLLAR ──────────────────────────────
      GrammarCategory(
        id: 'a1_nouns',
        name: 'Otlar va Artikllar',
        icon: '📝',
        topics: [
          GrammarTopic(
            id: 'a1_articles',
            title: 'Artikllar (Artikel)',
            description: 'Aniq (der/die/das), noaniq (ein/eine), inkor (kein)',
            rules: [
              GrammarRule(
                id: 'a1_articles_1',
                title: 'Aniq artikllar (bestimmte Artikel)',
                explanation: 'der — erkak jins (Maskulinum)\ndie — ayol jins (Femininum)\ndas — o\'rta jins (Neutrum)\ndie — ko\'plik (Plural)',
                examples: [
                  'der Mann, der Tisch, der Hund',
                  'die Frau, die Schule, die Blume',
                  'das Kind, das Buch, das Haus',
                  'die Männer / die Frauen / die Kinder',
                ],
                detailedExplanation: const GrammarExplanation(
                  theoryText: '''Nemis tilida har bir ot (Substantiv/Nomen) o'z grammatik jinsiga ega va bu jins artikl orqali ko'rsatiladi. Artikl — otning oldida keladigan va uning jinsini, sonini hamda holatini ko'rsatadigan so'z.

**Uch xil grammatik jins mavjud:**
• Erkak jins (Maskulinum) — der
• Ayol jins (Femininum) — die
• O'rta jins (Neutrum) — das

**Muhim eslatma:** Grammatik jins biologik jins bilan har doim mos kelmaydi. Masalan, "das Mädchen" (qiz) — o'rta jinsda, chunki -chen qo'shimchasi har doim o'rta jins beradi.

**Artikl turlarini yodlash kerak**, chunki qoidalar har doim ishlamaydi. Yangi so'z o'rganayotganda artikl bilan birga yodlang: "der Tisch" (stol), "die Lampe" (chiroq), "das Buch" (kitob).

**Ko'plik shakli:** Barcha otlarning ko'plik shakli "die" artikli bilan keladi, jinsidan qat'i nazar.''',
                  tables: [
                    GrammarTable(
                      title: 'Aniq artikllar jadvali (Bestimmte Artikel)',
                      headers: ['Jins', 'Artikl', 'Misol', 'Tarjima'],
                      rows: [
                        ['Erkak (Maskulinum)', 'der', 'der Tisch', 'stol'],
                        ['Ayol (Femininum)', 'die', 'die Lampe', 'chiroq'],
                        ['O\'rta (Neutrum)', 'das', 'das Buch', 'kitob'],
                        ['Ko\'plik (Plural)', 'die', 'die Bücher', 'kitoblar'],
                      ],
                    ),
                  ],
                  examples: [
                    GrammarExample(
                      german: 'Der Lehrer erklärt die Grammatik.',
                      uzbek: 'O\'qituvchi grammatikani tushuntirmoqda.',
                      note: 'der Lehrer — erkak jins artikli',
                    ),
                    GrammarExample(
                      german: 'Die Frau kauft das Brot.',
                      uzbek: 'Ayol non sotib olmoqda.',
                      note: 'die Frau — ayol jins, das Brot — o\'rta jins',
                    ),
                    GrammarExample(
                      german: 'Das Kind spielt im Garten.',
                      uzbek: 'Bola bog\'da o\'ynayapti.',
                      note: 'das Kind — o\'rta jins artikli',
                    ),
                    GrammarExample(
                      german: 'Der Hund und die Katze sind Freunde.',
                      uzbek: 'It va mushuk do\'stlar.',
                      note: 'der Hund — erkak jins, die Katze — ayol jins',
                    ),
                    GrammarExample(
                      german: 'Die Kinder lernen Deutsch in der Schule.',
                      uzbek: 'Bolalar maktabda nemis tilini o\'rganmoqda.',
                      note: 'die Kinder — ko\'plik shakli (har doim die)',
                    ),
                  ],
                ),
              ),
              GrammarRule(
                id: 'a1_articles_2',
                title: 'Noaniq artikllar (unbestimmte Artikel)',
                explanation: 'ein — erkak va o\'rta jins\neine — ayol jins\nKo\'plikda noaniq artikel yo\'q.',
                examples: [
                  'Ein Mann, ein Kind (erkak/neytral)',
                  'Eine Frau, eine Schule (ayol)',
                  'Das ist ein Buch.',
                ],
              ),
              GrammarRule(
                id: 'a1_articles_3',
                title: 'Inkor artikli: kein / keine',
                explanation: 'kein — erkak/neytral. keine — ayol va ko\'plik.\nArtiklli otni inkor qilish uchun ishlatiladi.',
                examples: [
                  'Ich habe kein Auto.',
                  'Er hat keine Zeit.',
                  'Wir haben keine Bücher.',
                  'Das ist kein Problem.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_plural',
            title: 'Ko\'plik shakllari (Plural)',
            description: 'Otlarning ko\'plik hosil qilish usullari',
            rules: [
              GrammarRule(
                id: 'a1_plural_1',
                title: '6 xil ko\'plik shakli',
                explanation: '1. -e: der Tisch → die Tische\n2. -¨e (umlaut+e): der Vater → die Väter\n3. -er: das Kind → die Kinder\n4. -¨er: das Haus → die Häuser\n5. -(e)n: die Frau → die Frauen\n6. -s: das Auto → die Autos\n7. O\'zgarishsiz: der Lehrer → die Lehrer',
                examples: [
                  'Tisch – Tische | Buch – Bücher',
                  'Kind – Kinder | Haus – Häuser',
                  'Frau – Frauen | Auto – Autos',
                  'Lehrer – Lehrer (o\'zgarishsiz)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_possessive',
            title: 'Egalik artikllari (Possessivartikel)',
            description: 'mein, dein, sein, ihr — Nominativ',
            rules: [
              GrammarRule(
                id: 'a1_possessive_1',
                title: 'Egalik artikllari (Nominativ)',
                explanation: 'mein/meine — mening\ndein/deine — sening\nsein/seine — uning (erkak)\nihr/ihre — uning (ayol)\nunser/unsere — bizning\neuer/eure — sizning (ko\'p)\nihr/ihre — ularning\nIhr/Ihre — Sizning (rasmiy)',
                examples: [
                  'Das ist mein Buch. (erkak/neytral)',
                  'Das ist meine Tasche. (ayol)',
                  'Sein Auto ist rot.',
                  'Unser Lehrer ist nett.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 3. HOLATLAR (CASES) ────────────────────────────────
      GrammarCategory(
        id: 'a1_cases',
        name: 'Holatlar (Fälle)',
        icon: '📋',
        topics: [
          GrammarTopic(
            id: 'a1_nominativ',
            title: 'Nominativ — Kim? (Wer?)',
            description: 'Gapning egasi',
            rules: [
              GrammarRule(
                id: 'a1_nominativ_1',
                title: 'Nominativ ishlatilishi',
                explanation: 'Gap egasi (Subjekt) hamisha Nominativda turadi. "Wer? / Was?" savollariga javob beradi.',
                examples: [
                  'Der Mann kommt. (Kim kelayapti? — der Mann)',
                  'Die Frau lernt Deutsch.',
                  'Das Kind spielt.',
                  'Ich bin müde.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_akkusativ',
            title: 'Akkusativ — Nimani? (Was? Wen?)',
            description: 'To\'g\'ridan to\'g\'ri to\'ldiruvchi',
            rules: [
              GrammarRule(
                id: 'a1_akkusativ_1',
                title: 'Akkusativda o\'zgarish',
                explanation: 'Faqat erkak jins o\'zgaradi:\nder → den, ein → einen, kein → keinen\nAyol, neytral va ko\'plik o\'zgarmaydi.',
                examples: [
                  'Ich sehe den Mann. (der → den)',
                  'Er kauft einen Apfel. (ein → einen)',
                  'Wir essen die Suppe. (o\'zgarmaydi)',
                  'Sie liest das Buch. (o\'zgarmaydi)',
                ],
              ),
              GrammarRule(
                id: 'a1_akkusativ_2',
                title: 'Akkusativ predloglari',
                explanation: 'Bu predloglar HAMISHA Akkusativ bilan keladi:\ndurch (orqali), für (uchun), gegen (qarshi), ohne (siz), um (atrofida/soat)',
                examples: [
                  'Das ist für dich. (sen uchun)',
                  'Ich gehe durch den Park.',
                  'Ohne einen Freund bin ich traurig.',
                  'Der Zug fährt um den See.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 4. OLMOSHLAR ──────────────────────────────────────
      GrammarCategory(
        id: 'a1_pronouns',
        name: 'Olmoshlar (Pronomen)',
        icon: '👤',
        topics: [
          GrammarTopic(
            id: 'a1_personal',
            title: 'Kishilik olmoshlari',
            description: 'Nominativ va Akkusativ',
            rules: [
              GrammarRule(
                id: 'a1_personal_1',
                title: 'Kishilik olmoshlari jadvali',
                explanation: 'Nominativ → Akkusativ:\nich → mich\ndu → dich\ner → ihn\nsie (u, ayol) → sie\nes → es\nwir → uns\nihr → euch\nsie/Sie → sie/Sie',
                examples: [
                  'Ich sehe dich.',
                  'Er liebt sie.',
                  'Kennen Sie ihn?',
                  'Wir besuchen euch morgen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_question_words',
            title: 'So\'roq olmoshlari (Fragewörter)',
            description: 'wer, was, wie, wo, wann, warum, woher, wohin',
            rules: [
              GrammarRule(
                id: 'a1_question_words_1',
                title: 'Asosiy so\'roq so\'zlari',
                explanation: 'wer — kim\nwas — nima\nwie — qanday\nwo — qayerda\nwann — qachon\nwarum — nima uchun\nwoher — qayerdan\nwohin — qayerga',
                examples: [
                  'Wer bist du?',
                  'Was machst du?',
                  'Wo wohnst du?',
                  'Wann kommst du?',
                  'Warum lernst du Deutsch?',
                  'Woher kommst du?',
                  'Wohin gehst du?',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 5. GAP TUZILISHI ──────────────────────────────────
      GrammarCategory(
        id: 'a1_sentence',
        name: 'Gap Tuzilishi (Satzbau)',
        icon: '💬',
        topics: [
          GrammarTopic(
            id: 'a1_statement',
            title: 'Darak gap tartibi',
            description: 'Fe\'l HAMISHA 2-o\'rinda',
            rules: [
              GrammarRule(
                id: 'a1_statement_1',
                title: 'Fe\'l 2-o\'rinda (Verb-2-Regel)',
                explanation: 'Nemis tilida asosiy gap uchun qoida: fe\'l HAMISHA 2-o\'rinda turadi. 1-o\'rinda ega yoki vaqt/joy bo\'lishi mumkin.',
                examples: [
                  'Ich lerne heute Deutsch. (Ega — 1-o\'rin)',
                  'Heute lerne ich Deutsch. (Vaqt — 1-o\'rin, fe\'l 2-o\'rinda)',
                  'In Berlin wohne ich. (Joy — 1-o\'rin)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_questions',
            title: 'So\'roq gaplar',
            description: 'W-Fragen va Ja/Nein-Fragen',
            rules: [
              GrammarRule(
                id: 'a1_questions_1',
                title: 'W-Fragen (kim, nima, qayerda...)',
                explanation: 'So\'roq so\'z → Fe\'l → Ega → Boshqalar',
                examples: [
                  'Wo wohnst du?',
                  'Was lernst du?',
                  'Wann kommst du nach Hause?',
                ],
              ),
              GrammarRule(
                id: 'a1_questions_2',
                title: 'Ja/Nein-Fragen (ha/yo\'q savollar)',
                explanation: 'Fe\'l gap boshida turadi.',
                examples: [
                  'Lernst du Deutsch?',
                  'Kommst du heute?',
                  'Hast du Zeit?',
                  'Ist das dein Buch?',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_connectors',
            title: 'Asosiy bog\'lovchilar',
            description: 'und, aber, oder, denn, sondern',
            rules: [
              GrammarRule(
                id: 'a1_connectors_1',
                title: 'Koordinativ bog\'lovchilar',
                explanation: 'und (va), aber (lekin), oder (yoki), denn (chunki), sondern (balki — inkordan keyin).\nBu bog\'lovchilar gap tartibini o\'zgartirmaydi.',
                examples: [
                  'Ich lerne und arbeite.',
                  'Er ist müde, aber er arbeitet.',
                  'Kommst du oder gehst du?',
                  'Ich bleibe zu Hause, denn es regnet.',
                  'Er ist nicht krank, sondern müde.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 6. INKOR ──────────────────────────────────────────
      GrammarCategory(
        id: 'a1_negation',
        name: 'Inkor (Negation)',
        icon: '❌',
        topics: [
          GrammarTopic(
            id: 'a1_nicht_kein',
            title: 'nicht va kein',
            description: 'Qachon nicht, qachon kein?',
            rules: [
              GrammarRule(
                id: 'a1_nicht_1',
                title: 'nicht — fe\'l va sifatlarni inkor qilish',
                explanation: 'nicht — fe\'llar, sifatlar, olmoshlar, predlogli iboralar bilan. Odatda gap oxirida yoki inkor qilinadigan so\'z oldida turadi.',
                examples: [
                  'Ich lerne nicht. (fe\'l inkor)',
                  'Er ist nicht müde. (sifat inkor)',
                  'Das ist nicht mein Buch. (olmosh)',
                  'Ich fahre nicht nach Berlin.',
                ],
              ),
              GrammarRule(
                id: 'a1_kein_1',
                title: 'kein — artiklli ot va miqdorni inkor qilish',
                explanation: 'kein ishlatish: noaniq artikel (ein/eine) bilan kelgan ot, yoki artikelsiz ot.',
                examples: [
                  'Ich habe kein Auto. (ein Auto → kein Auto)',
                  'Sie hat keine Zeit. (keine = ayol/ko\'plik)',
                  'Wir haben keine Bücher.',
                  'Er trinkt keinen Kaffee.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 7. RAQAMLAR VA VAQT ───────────────────────────────
      GrammarCategory(
        id: 'a1_numbers_time',
        name: 'Raqamlar va Vaqt',
        icon: '🔢',
        topics: [
          GrammarTopic(
            id: 'a1_numbers',
            title: 'Raqamlar (Zahlen)',
            description: '0 dan 1000 gacha',
            rules: [
              GrammarRule(
                id: 'a1_numbers_1',
                title: '0–19',
                explanation: '0=null, 1=eins, 2=zwei, 3=drei, 4=vier, 5=fünf, 6=sechs, 7=sieben, 8=acht, 9=neun, 10=zehn, 11=elf, 12=zwölf, 13=dreizehn... 19=neunzehn',
                examples: [
                  'Ich habe drei Kinder.',
                  'Das kostet sieben Euro.',
                  'Sie ist elf Jahre alt.',
                ],
              ),
              GrammarRule(
                id: 'a1_numbers_2',
                title: '20–1000',
                explanation: '20=zwanzig, 30=dreißig, 40=vierzig, 50=fünfzig, 60=sechzig, 70=siebzig, 80=achtzig, 90=neunzig, 100=hundert, 1000=tausend.\n21=einundzwanzig (birlik+und+o\'nlik)',
                examples: [
                  'Er ist vierzig Jahre alt.',
                  'Das kostet dreiundzwanzig Euro.',
                  'Hundert Studenten lernen hier.',
                ],
              ),
              GrammarRule(
                id: 'a1_ordinal',
                title: 'Tartib sonlari (Ordinalzahlen)',
                explanation: '1–19: -(s)te. 20+: -ste.\n1. erste, 2. zweite, 3. dritte, 4. vierte, 7. siebte, 8. achte',
                examples: [
                  'Er wohnt im dritten Stock.',
                  'Heute ist der erste Mai.',
                  'Sie hat den zweiten Platz gewonnen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a1_time',
            title: 'Vaqt (Uhrzeit)',
            description: 'Soat aytish',
            rules: [
              GrammarRule(
                id: 'a1_time_1',
                title: 'Rasmiy va kundalik vaqt',
                explanation: 'Rasmiy: 14:30 → vierzehn Uhr dreißig\nKundalik: halb drei (2:30), Viertel vor drei (2:45), Viertel nach zwei (2:15)',
                examples: [
                  'Es ist drei Uhr. (3:00)',
                  'Es ist halb vier. (3:30)',
                  'Es ist Viertel nach fünf. (5:15)',
                  'Es ist Viertel vor sechs. (5:45)',
                ],
              ),
              GrammarRule(
                id: 'a1_time_2',
                title: 'Vaqt predloglari',
                explanation: 'um — aniq vaqt (um 3 Uhr)\nam — kunlar va kun qismi (am Montag, am Morgen)\nim — oylar va fasllar (im Januar, im Sommer)',
                examples: [
                  'Ich komme um 8 Uhr.',
                  'Am Dienstag habe ich Deutschkurs.',
                  'Im Winter ist es kalt.',
                  'Am Abend sehe ich fern.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 8. SIFATLAR ───────────────────────────────────────
      GrammarCategory(
        id: 'a1_adjectives',
        name: 'Sifatlar (Adjektive)',
        icon: '🎨',
        topics: [
          GrammarTopic(
            id: 'a1_predicative',
            title: 'Predikativ sifatlar (Prädikativum)',
            description: 'sein, werden, bleiben bilan — o\'zgarmaydi',
            rules: [
              GrammarRule(
                id: 'a1_predicative_1',
                title: 'Predikativ sifatlar',
                explanation: 'sein/werden/bleiben dan keyin kelganda sifat tuslanmaydi (qo\'shimcha olmaydi).',
                examples: [
                  'Das Wetter ist schön.',
                  'Er ist groß und stark.',
                  'Die Suppe bleibt warm.',
                  'Es wird kalt.',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // ─────────────────────────────────────────────────────────
  // A2 Daraja
  // ─────────────────────────────────────────────────────────
  static final GrammarLevel _a2Level = GrammarLevel(
    id: 'a2',
    level: 'A2',
    title: 'Boshlang\'ich O\'rta',
    description: 'A1 asoslarini mustahkamlab, kundalik vaziyatlarda biroz murakkabroq jumlalar tuzishga o\'tiladi.',
    emoji: '📗',
    categories: [

      // ── 1. FE'LLAR ─────────────────────────────────────────
      GrammarCategory(
        id: 'a2_verbs',
        name: 'Fe\'llar (Verben)',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'a2_perfekt',
            title: 'O\'tgan zamon — Perfekt',
            description: 'haben / sein + Partizip II',
            rules: [
              GrammarRule(
                id: 'a2_perfekt_1',
                title: 'Perfekt tuzilishi',
                explanation: 'haben yoki sein + Partizip II (gap oxirida).\nhaben — ko\'pchilik fe\'llar bilan.\nsein — harakat/o\'rin o\'zgarish bildiruvchi fe\'llar bilan (gehen, fahren, kommen, laufen, aufstehen...) hamda sein, werden, bleiben bilan.',
                examples: [
                  'Ich habe gegessen. (haben + ge...en)',
                  'Er ist gegangen. (sein + ge...en)',
                  'Wir haben gearbeitet. (ge...t)',
                  'Sie ist aufgestanden. (trennbar: ge boshida)',
                ],
              ),
              GrammarRule(
                id: 'a2_perfekt_2',
                title: 'Partizip II shakllari',
                explanation: 'Muntazam: ge- + asosiy qism + -(e)t → gemacht, gearbeitet\nNomuntazam: ge- + o\'zgargan asos + -en → gegessen, getrunken, gesehen\nAjraluvchi: prefiks + ge- + asos → aufgestanden, eingekauft\n-ieren bilan: phrasiert (ge- yo\'q) → studiert, telefoniert',
                examples: [
                  'machen → gemacht',
                  'essen → gegessen',
                  'schreiben → geschrieben',
                  'aufstehen → aufgestanden',
                  'studieren → studiert',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_prateritum',
            title: 'O\'tgan zamon — Präteritum',
            description: 'Yozma til va hikoya qilish uchun',
            rules: [
              GrammarRule(
                id: 'a2_prateritum_1',
                title: 'Präteritum: sein, haben va modal fe\'llar',
                explanation: 'Gündalik nutqda Perfekt ishlatiladi. Präteritum — yozma til va rasmiylarda.\nsein: war, warst, war, waren\nhaben: hatte, hattest, hatte, hatten\nModal: konnte, musste, wollte, durfte, sollte',
                examples: [
                  'Ich war gestern krank.',
                  'Er hatte keine Zeit.',
                  'Ich konnte nicht kommen.',
                  'Sie musste früh aufstehen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_futur1',
            title: 'Kelasi zamon — Futur I',
            description: 'werden + Infinitiv',
            rules: [
              GrammarRule(
                id: 'a2_futur1_1',
                title: 'Futur I tuzilishi',
                explanation: 'werden + Infinitiv gap oxirida.\nwerden: ich werde, du wirst, er wird, wir werden, ihr werdet, sie werden.\nEslatma: ko\'pincha hozirgi zamon + vaqt ifodasi bilan ham kelasi zamon ifodalanadi.',
                examples: [
                  'Ich werde morgen lernen.',
                  'Er wird bald kommen.',
                  'Wir werden Deutsch sprechen.',
                  'Morgen fahre ich nach Berlin. (Präsens bilan ham bo\'ladi)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_reflexive',
            title: 'O\'zlik (Reflexiv) fe\'llar',
            description: 'sich freuen, sich waschen...',
            rules: [
              GrammarRule(
                id: 'a2_reflexive_1',
                title: 'Refleksiv fe\'llar va sich',
                explanation: 'O\'zlik olmoshlari Akkusativ: mich, dich, sich, uns, euch, sich.\nDativ: mir, dir, sich, uns, euch, sich.\nKo\'p ishlatiladiganlar: sich freuen (quvonmoq), sich setzen (o\'tirmoq), sich waschen (yuvinmoq), sich erinnern (eslamoq), sich interessieren für (qiziqmoq)',
                examples: [
                  'Ich freue mich sehr! (quvondim)',
                  'Er wäscht sich die Hände.',
                  'Wir setzen uns hin.',
                  'Sie interessiert sich für Musik.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_konjunktiv2',
            title: 'Konjunktiv II — Xushmuomala',
            description: 'würde, könnte, hätte, wäre',
            rules: [
              GrammarRule(
                id: 'a2_konjunktiv2_1',
                title: 'Xushmuomala iltimos va istak',
                explanation: 'könnte (could), würde (would), hätte (would have), wäre (would be) — iltimos va taxmin ifodalash uchun.',
                examples: [
                  'Könnten Sie mir helfen, bitte?',
                  'Ich würde gerne mitkommen.',
                  'Hätten Sie einen Moment Zeit?',
                  'Das wäre sehr nett.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 2. HOLATLAR ───────────────────────────────────────
      GrammarCategory(
        id: 'a2_cases',
        name: 'Holatlar (Fälle)',
        icon: '📋',
        topics: [
          GrammarTopic(
            id: 'a2_dativ',
            title: 'Dativ — Kimga? (Wem?)',
            description: 'Bilvosita to\'ldiruvchi',
            rules: [
              GrammarRule(
                id: 'a2_dativ_1',
                title: 'Dativ artikl o\'zgarishlari',
                explanation: 'der (erkak) → dem\ndie (ayol) → der\ndas (neytral) → dem\ndie (ko\'plik) → den (+n ko\'plik oxiriga)\nein → einem, eine → einer, ein → einem',
                examples: [
                  'Ich helfe dem Mann. (der → dem)',
                  'Er gibt der Frau das Buch.',
                  'Wir spielen mit dem Kind.',
                  'Mit den Kindern spiele ich.',
                ],
              ),
              GrammarRule(
                id: 'a2_dativ_2',
                title: 'Dativ predloglari',
                explanation: 'HAMISHA Dativ: aus, bei, mit, nach, seit, von, zu, gegenüber, ab',
                examples: [
                  'Ich komme aus Deutschland.',
                  'Er ist bei mir zu Hause.',
                  'Wir fahren mit dem Bus.',
                  'Ich lerne seit einem Jahr.',
                  'Sie wohnt gegenüber dem Bahnhof.',
                ],
              ),
              GrammarRule(
                id: 'a2_dativ_3',
                title: 'Dativ talab qiluvchi fe\'llar',
                explanation: 'helfen (yordam bermoq), gefallen (yoqmoq), gehören (tegishli), danken (minnatdor), antworten (javob bermoq), folgen (ergashmoq)',
                examples: [
                  'Ich helfe dir. (Dativ)',
                  'Das Buch gehört mir.',
                  'Das Wetter gefällt mir nicht.',
                  'Ich danke Ihnen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_wechsel',
            title: 'Ikki holatli predloglar (Wechselpräpositionen)',
            description: 'Harakat = Akkusativ, Joy = Dativ',
            rules: [
              GrammarRule(
                id: 'a2_wechsel_1',
                title: 'an, auf, in, neben, unter, vor, hinter, über, zwischen',
                explanation: 'Harakat (qayerga? wohin?) → Akkusativ\nJoy (qayerda? wo?) → Dativ\nYodlash uchun: HARAKAT = AKKUSATIV (H=A)',
                examples: [
                  'Ich gehe in die Schule. (harakat, Akkusativ)',
                  'Ich bin in der Schule. (joy, Dativ)',
                  'Er stellt das Buch auf den Tisch. (Akkusativ)',
                  'Das Buch liegt auf dem Tisch. (Dativ)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_genitiv_intro',
            title: 'Genitiv — Kimning? (Wessen?)',
            description: 'Egali konstruksiya',
            rules: [
              GrammarRule(
                id: 'a2_genitiv_1',
                title: 'Genitiv asoslari',
                explanation: 'der (erkak) → des (+s otga)\ndie (ayol) → der\ndas (neytral) → des (+s otga)\ndie (ko\'plik) → der\nein → eines, eine → einer',
                examples: [
                  'Das ist das Auto des Mannes.',
                  'Die Tasche der Frau ist groß.',
                  'Das Zimmer des Kindes ist klein.',
                  'Das Ende des Films war gut.',
                ],
              ),
              GrammarRule(
                id: 'a2_genitiv_2',
                title: 'von + Dativ (alternativ)',
                explanation: 'Kundalik nutqda von + Dativ ko\'proq ishlatiladi (ayniqsa nom bilan).',
                examples: [
                  'Das Auto von meinem Vater.',
                  'Die Wohnung von meiner Freundin.',
                  'Ein Freund von mir.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 3. SIFATLAR ───────────────────────────────────────
      GrammarCategory(
        id: 'a2_adjectives',
        name: 'Sifatlar (Adjektive)',
        icon: '🎨',
        topics: [
          GrammarTopic(
            id: 'a2_declension',
            title: 'Sifat tuslanishi (Adjektivdeklination)',
            description: 'Aniq, noaniq va artikelsiz',
            rules: [
              GrammarRule(
                id: 'a2_declension_1',
                title: 'Aniq artikl bilan (starke = kuchsiz)',
                explanation: 'Nominativ: -e (barcha jins)\nAkkusativ: erkak -en, boshqalar -e\nDativ: barcha -en\nGenitiv: barcha -en',
                examples: [
                  'der alte Mann (Nom.)',
                  'den alten Mann (Akk.)',
                  'dem alten Mann (Dat.)',
                  'die schöne Frau / das kleine Kind',
                ],
              ),
              GrammarRule(
                id: 'a2_declension_2',
                title: 'Noaniq artikl bilan',
                explanation: 'Artikl jins ko\'rsatmagan joyda sifat ko\'rsatadi:\nNom.mask: -er, Nom.neut: -es, Nom.fem: -e\nAkk.mask: -en, boshqalar nom. kabi\nDat: -en (barcha)',
                examples: [
                  'ein großer Mann (Nom. mask.)',
                  'ein kleines Kind (Nom. neut.)',
                  'eine schöne Frau (Nom. fem.)',
                  'einen großen Mann (Akk. mask.)',
                ],
              ),
              GrammarRule(
                id: 'a2_declension_3',
                title: 'Artikelsiz (kuchli tuslash)',
                explanation: 'Artikel yo\'q bo\'lsa sifat o\'zi jins va holatni ko\'rsatadi (kuchli oxirlari).',
                examples: [
                  'Kalter Kaffee schmeckt nicht.',
                  'Mit frischer Milch.',
                  'Gutes Wetter macht glücklich.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_comparison',
            title: 'Qiyosiy daraja (Komparativ/Superlativ)',
            description: 'schnell → schneller → am schnellsten',
            rules: [
              GrammarRule(
                id: 'a2_comparison_1',
                title: 'Komparativ (-er)',
                explanation: 'Sifat + -er. Ba\'zida umlaut (a→ä, o→ö, u→ü).\nals bilan qiyoslash.',
                examples: [
                  'schnell → schneller als',
                  'groß → größer als',
                  'jung → jünger als',
                  'Er ist größer als ich.',
                ],
              ),
              GrammarRule(
                id: 'a2_comparison_2',
                title: 'Superlativ (am ...-sten)',
                explanation: 'am + sifat + -sten. Ba\'zida -esten.\nNotizlar: gut→besser→am besten, viel→mehr→am meisten, gern→lieber→am liebsten',
                examples: [
                  'am schnellsten, am größten, am jüngsten',
                  'Er ist am schnellsten.',
                  'Das ist das beste Restaurant.',
                  'Ich lese am liebsten.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 4. BOG'LOVCHILAR ──────────────────────────────────
      GrammarCategory(
        id: 'a2_connectors',
        name: 'Bog\'lovchilar (Konnektoren)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'a2_subordinate',
            title: 'Ergashgan gaplar (Nebensätze)',
            description: 'weil, wenn, dass, ob, als',
            rules: [
              GrammarRule(
                id: 'a2_subordinate_1',
                title: 'weil / da (chunki)',
                explanation: 'Ergashgan gapda fe\'l OXIRGA chiqadi.',
                examples: [
                  'Ich bleibe zu Hause, weil ich krank bin.',
                  'Er lernt, weil er die Prüfung bestehen will.',
                  'Da es regnet, nehme ich den Regenschirm.',
                ],
              ),
              GrammarRule(
                id: 'a2_subordinate_2',
                title: 'wenn (agar/qachon)',
                explanation: 'Shart yoki takrorlanuvchi holat. Ergashgan gapda fe\'l oxirida.',
                examples: [
                  'Wenn ich Zeit habe, komme ich.',
                  'Wenn es kalt ist, trage ich einen Mantel.',
                ],
              ),
              GrammarRule(
                id: 'a2_subordinate_3',
                title: 'dass (ki) va ob (yoki/mi)',
                explanation: 'dass — aniq holat bildiradi.\nob — noaniq savol (yes/no bilvosita so\'roq)',
                examples: [
                  'Ich denke, dass er kommt.',
                  'Er sagt, dass er Deutsch lernt.',
                  'Ich weiß nicht, ob er kommt.',
                  'Frag ihn, ob er Zeit hat.',
                ],
              ),
              GrammarRule(
                id: 'a2_subordinate_4',
                title: 'als (bir marotaba bo\'lgan o\'tmish)',
                explanation: 'als — o\'tmishda bir marta bo\'lgan holat. wenn — hozir yoki takrorlanuvchi.',
                examples: [
                  'Als ich jung war, lebte ich in München.',
                  'Als er ankam, war ich schon dort.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_adverbs',
            title: 'Bog\'lovchi ravishlar (Satzadverbien)',
            description: 'deshalb, trotzdem, dann, außerdem',
            rules: [
              GrammarRule(
                id: 'a2_adverbs_1',
                title: 'Asosiy bog\'lovchi ravishlar',
                explanation: 'Bu bog\'lovchilar gap boshi (1-o\'rin) yoki so\'ng turadi. Fe\'l 2-o\'rinda qoladi!\ndeshalb (shuning uchun), trotzdem (shunga qaramay), dann (keyin), außerdem (bundan tashqari), danach (undan keyin), zuerst (avval)',
                examples: [
                  'Es regnet. Deshalb bleibe ich zu Hause.',
                  'Er war krank. Trotzdem kam er.',
                  'Zuerst esse ich, dann gehe ich.',
                  'Er ist nett. Außerdem ist er klug.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 5. OLMOSHLAR ──────────────────────────────────────
      GrammarCategory(
        id: 'a2_pronouns',
        name: 'Olmoshlar (Pronomen)',
        icon: '👤',
        topics: [
          GrammarTopic(
            id: 'a2_dativ_pronouns',
            title: 'Kishilik olmoshlari — Dativ',
            description: 'mir, dir, ihm, ihr, ihm, uns, euch, ihnen',
            rules: [
              GrammarRule(
                id: 'a2_dativ_pronouns_1',
                title: 'Barcha holatlar jadvali',
                explanation: 'Nominativ | Akkusativ | Dativ\nych | mich | mir\ndu | dich | dir\ner | ihn | ihm\nsie | sie | ihr\nes | es | ihm\nwir | uns | uns\nihr | euch | euch\nsie/Sie | sie/Sie | ihnen/Ihnen',
                examples: [
                  'Ich helfe dir. (dir = Dativ)',
                  'Er gibt mir das Buch.',
                  'Wir danken Ihnen.',
                  'Das gehört ihm.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'a2_relative_intro',
            title: 'Nisbiy gaplar kirish (Relativsätze)',
            description: 'der, die, das — Nominativ',
            rules: [
              GrammarRule(
                id: 'a2_relative_1',
                title: 'Nisbiy olmosh — Nominativ',
                explanation: 'Nisbiy gap asosiy gapdan vergul bilan ajratiladi. Fe\'l oxirga chiqadi.\nNisbiy olmosh (der/die/das) = aniq artikl kabi, lekin tuslanishi biroz farqli.',
                examples: [
                  'Der Mann, der kommt, ist mein Freund.',
                  'Die Frau, die hier wohnt, ist Ärztin.',
                  'Das Buch, das ich lese, ist interessant.',
                  'Die Kinder, die spielen, sind laut.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 6. TEMPORAL PREDLOGLAR ────────────────────────────
      GrammarCategory(
        id: 'a2_temporal',
        name: 'Vaqt Predloglari (Temporale Präpositionen)',
        icon: '⏰',
        topics: [
          GrammarTopic(
            id: 'a2_temporal_prep',
            title: 'Vaqt predloglari to\'liq',
            description: 'vor, nach, seit, bis, während, ab',
            rules: [
              GrammarRule(
                id: 'a2_temporal_1',
                title: 'Dativ bilan: vor, nach, seit, ab',
                explanation: 'vor + Dativ — ...oldin\nnach + Dativ — ...keyin\nseit + Dativ — ...dan beri (hali ham davom etayapti!)\nab + Dativ — ...dan boshlab (kelajak)',
                examples: [
                  'vor dem Essen (ovqatdan oldin)',
                  'nach der Schule (maktabdan keyin)',
                  'seit einem Jahr (bir yildan beri)',
                  'ab nächster Woche (kelgusi haftadan boshlab)',
                ],
              ),
              GrammarRule(
                id: 'a2_temporal_2',
                title: 'Akkusativ bilan: bis, durch',
                explanation: 'bis + Akkusativ — ...gacha\ndurch + Akkusativ — ...davomida (orqali vaqt)',
                examples: [
                  'bis nächsten Montag (kelgusi dushanbagacha)',
                  'bis um drei Uhr',
                  'den ganzen Tag durch (kun bo\'yi)',
                ],
              ),
              GrammarRule(
                id: 'a2_temporal_3',
                title: 'Genitiv bilan: während',
                explanation: 'während + Genitiv — ...vaqtida, ...paytida',
                examples: [
                  'während des Unterrichts (dars paytida)',
                  'während der Pause',
                  'während des Sommers',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // ─────────────────────────────────────────────────────────
  // B1 Daraja
  // ─────────────────────────────────────────────────────────
  static final GrammarLevel _b1Level = GrammarLevel(
    id: 'b1',
    level: 'B1',
    title: 'O\'rta',
    description: 'O\'z fikrini izchil ifodalash, tajribalar haqida hikoya qilish va asosli mulohazalar yuritish uchun grammatik vositalar boyitiladi.',
    emoji: '📙',
    categories: [

      // ── 1. FE'LLAR ─────────────────────────────────────────
      GrammarCategory(
        id: 'b1_verbs',
        name: 'Fe\'llar (Verben)',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'b1_plusquamperfekt',
            title: 'Plusquamperfekt',
            description: 'O\'tmishdagi o\'tmish harakati',
            rules: [
              GrammarRule(
                id: 'b1_plusquamperfekt_1',
                title: 'Plusquamperfekt: hatte/war + Partizip II',
                explanation: 'O\'tmishdagi ikki harakatdan BIRINCHI bo\'lgani Plusquamperfektda, IKKINCHI bo\'lgani Präteritumda tuради.',
                examples: [
                  'Als er kam, hatte ich schon gegessen.',
                  'Nachdem sie aufgestanden war, frühstückte sie.',
                  'Ich hatte das Buch gelesen, bevor der Film anfing.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_passiv',
            title: 'Majhul nisbat (Vorgangspassiv)',
            description: 'werden + Partizip II',
            rules: [
              GrammarRule(
                id: 'b1_passiv_1',
                title: 'Präsens va Präteritum Passiv',
                explanation: 'Präsens: wird + Partizip II\nPräteritum: wurde + Partizip II\nAgent (kim tomonidan): von + Dativ',
                examples: [
                  'Das Buch wird gelesen.',
                  'Das Haus wurde gebaut.',
                  'Der Brief wird von Maria geschrieben.',
                  'Das Auto wurde von dem Mechaniker repariert.',
                ],
              ),
              GrammarRule(
                id: 'b1_passiv_2',
                title: 'Passiv bilan modal fe\'llar',
                explanation: 'Modal fe\'l + werden (Infinitiv) + Partizip II gap oxirida.',
                examples: [
                  'Das muss gemacht werden.',
                  'Die Tür soll geschlossen werden.',
                  'Der Text kann gelesen werden.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_konjunktiv2',
            title: 'Konjunktiv II — Irreal',
            description: 'Irreal istak, taxmin, tavsiya',
            rules: [
              GrammarRule(
                id: 'b1_konjunktiv2_1',
                title: 'Hozirgi zamon Konjunktiv II',
                explanation: 'würde + Infinitiv — umumiy foydalanish.\nwäre (sein), hätte (haben), könnte, müsste, sollte, dürfte — bevosita shakllar.',
                examples: [
                  'Wenn ich Zeit hätte, würde ich kommen.',
                  'An deiner Stelle würde ich das nicht machen.',
                  'Das wäre super!',
                  'Könnte ich bitte die Rechnung haben?',
                ],
              ),
              GrammarRule(
                id: 'b1_konjunktiv2_2',
                title: 'O\'tmish Konjunktiv II',
                explanation: 'hätte/wäre + Partizip II — o\'tmishda bo\'lmagan narsa haqida.',
                examples: [
                  'Wenn ich gelernt hätte, hätte ich die Prüfung bestanden.',
                  'Das hätte ich nicht gesagt.',
                  'Wären Sie früher gekommen!',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_lassen',
            title: 'lassen — maxsus ishlatilishi',
            description: 'Qildirishni buyurmoq yoki ruxsat bermoq',
            rules: [
              GrammarRule(
                id: 'b1_lassen_1',
                title: 'lassen + Infinitiv',
                explanation: '1. Buyruq: Ich lasse jemanden etwas tun (qilishni buyurmoq)\n2. Ruxsat: jemanden etwas tun lassen (qilishga ruxsat bermoq)\n3. sich lassen = passiv muqobili',
                examples: [
                  'Ich lasse das Auto reparieren. (ta\'mirlattiraman)',
                  'Er lässt die Kinder spielen. (ruxsat beradi)',
                  'Das lässt sich machen. (qilish mumkin)',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 2. INFINITIV KONSTRUKSIYALAR ──────────────────────
      GrammarCategory(
        id: 'b1_infinitiv',
        name: 'Infinitiv Konstruksiyalar',
        icon: '🔧',
        topics: [
          GrammarTopic(
            id: 'b1_um_zu',
            title: 'um...zu + Infinitiv',
            description: 'Maqsad bildiruvchi konstruksiya',
            rules: [
              GrammarRule(
                id: 'b1_um_zu_1',
                title: 'um...zu (uchun, maqsad)',
                explanation: 'Maqsad bildiradi. FAQAT asosiy va ergashgan gapdagi ega bir xil bo\'lganda ishlatiladi.\nQurilish: ..., um + [qolgan qism] + zu + Infinitiv.',
                examples: [
                  'Ich lerne, um die Prüfung zu bestehen.',
                  'Er arbeitet viel, um Geld zu verdienen.',
                  'Sie geht ins Fitnessstudio, um fit zu bleiben.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_ohne_zu',
            title: 'ohne...zu + Infinitiv',
            description: '...siz qilmoq',
            rules: [
              GrammarRule(
                id: 'b1_ohne_zu_1',
                title: 'ohne...zu (siz qilmoq)',
                explanation: 'Kutilgan amalni bajarmay qilish. Ega bir xil bo\'lishi kerak.',
                examples: [
                  'Er ging, ohne sich zu verabschieden.',
                  'Sie antwortete, ohne zu zögern.',
                  'Ich habe gegessen, ohne zu bezahlen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_anstatt_zu',
            title: 'anstatt...zu + Infinitiv',
            description: '...o\'rniga qilmoq',
            rules: [
              GrammarRule(
                id: 'b1_anstatt_zu_1',
                title: 'anstatt...zu (o\'rniga)',
                explanation: 'Biror narsa o\'rniga boshqa narsani qilish. (= statt...zu)',
                examples: [
                  'Er schläft, anstatt zu lernen.',
                  'Sie kauft Schuhe, anstatt zu sparen.',
                  'Statt zu fahren, ging er zu Fuß.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_zu_inf_general',
            title: 'zu + Infinitiv — umumiy',
            description: 'Fe\'l + zu + Infinitiv',
            rules: [
              GrammarRule(
                id: 'b1_zu_inf_1',
                title: 'Ko\'p ishlatiladigan fe\'llar + zu + Infinitiv',
                explanation: 'Quyidagi fe\'llar zu + Infinitiv talab qiladi:\nversuchen (urinmoq), anfangen (boshlash), aufhören (to\'xtatish), hoffen (umid qilish), vergessen (unutmoq), vorhaben (niyat qilmoq), empfehlen (tavsiya qilish).',
                examples: [
                  'Ich versuche, früh aufzustehen.',
                  'Er fängt an, Deutsch zu lernen.',
                  'Hör auf zu rauchen!',
                  'Ich hoffe, dich bald zu sehen.',
                  'Ich habe vergessen, ihn anzurufen.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 3. BOG'LOVCHILAR ──────────────────────────────────
      GrammarCategory(
        id: 'b1_connectors',
        name: 'Bog\'lovchilar (Konnektoren)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'b1_two_part',
            title: 'Ikki qismli bog\'lovchilar',
            description: 'entweder...oder, weder...noch, sowohl...als auch, nicht nur...sondern auch, zwar...aber',
            rules: [
              GrammarRule(
                id: 'b1_two_part_1',
                title: 'Barcha ikki qismli bog\'lovchilar',
                explanation: 'entweder...oder — yoki...yoki\nweder...noch — na...na (inkor)\nsowohl...als auch — ham...ham\nnicht nur...sondern auch — nafaqat...balki\nzwar...aber — garchi...lekin',
                examples: [
                  'Entweder du kommst, oder ich gehe allein.',
                  'Er trinkt weder Alkohol noch Kaffee.',
                  'Sie spricht sowohl Deutsch als auch Englisch.',
                  'Er ist nicht nur klug, sondern auch fleißig.',
                  'Er ist zwar müde, aber er arbeitet weiter.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_complex_connectors',
            title: 'Murakkab bog\'lovchilar',
            description: 'obwohl, während, nachdem, bevor, falls, seitdem, sobald, solange',
            rules: [
              GrammarRule(
                id: 'b1_complex_1',
                title: 'Vaxtni bildiruvchi bog\'lovchilar',
                explanation: 'nachdem (keyin) — Plusquamperfekt + Präteritum\nbevor/ehe (oldin) — bir zamon\nwährend (paytida) — bir zamon\nseitdem (o\'shandan beri)\nsobald (zamon)\nsolange (davomida)',
                examples: [
                  'Nachdem er gegessen hatte, machte er Sport.',
                  'Bevor sie schlafen geht, liest sie.',
                  'Während ich koche, hört er Musik.',
                  'Seitdem er umgezogen ist, sehen wir uns selten.',
                ],
              ),
              GrammarRule(
                id: 'b1_complex_2',
                title: 'Maqsad va sabab bildiruvchi bog\'lovchilar',
                explanation: 'obwohl (garchi) — qarama-qarshi\ndamit (uchun) — maqsad (ega turli bo\'lishi mumkin)\nfalls (agar) — shart\njedoch/allerdings (lekin) — qarama-qarshi',
                examples: [
                  'Obwohl es regnet, gehe ich spazieren.',
                  'Ich helfe dir, damit du es schaffst.',
                  'Falls du kommst, ruf mich an.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_modal_adverbs',
            title: 'Modallikni ifodalovchi ravishlar',
            description: 'deshalb, deswegen, daher, trotzdem, dennoch, sonst',
            rules: [
              GrammarRule(
                id: 'b1_modal_adv_1',
                title: 'Sabab va natija',
                explanation: 'deshalb / deswegen / daher — shuning uchun (sabab → natija)\nalso — demak\nfolglich — natijada\ntrotzdem / dennoch / jedoch — shunga qaramay\nsonst — aks holda',
                examples: [
                  'Es regnete, deshalb blieb ich zu Hause.',
                  'Sie ist krank, trotzdem kommt sie.',
                  'Lern mehr, sonst bestehtst du nicht.',
                  'Er hat studiert, also hat er Erfolg.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 4. NISBIY GAPLAR ──────────────────────────────────
      GrammarCategory(
        id: 'b1_relative',
        name: 'Nisbiy Gaplar (Relativsätze)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'b1_relative_all',
            title: 'Barcha holatlarda nisbiy olmoshlar',
            description: 'Nominativ, Akkusativ, Dativ, Genitiv',
            rules: [
              GrammarRule(
                id: 'b1_relative_1',
                title: 'Nisbiy olmosh jadvali',
                explanation: 'Nisbiy olmosh aniq artikl kabi, LEKIN:\nGenitiv: dessen (mask/neut), deren (fem/pl)\nDativ ko\'plik: denen\n\nNom: der / die / das / die\nAkk: den / die / das / die\nDat: dem / der / dem / denen\nGen: dessen / deren / dessen / deren',
                examples: [
                  'Der Mann, den ich kenne, ist Arzt. (Akkusativ)',
                  'Das Buch, das ich lese, ist gut. (Akkusativ)',
                  'Die Frau, der ich helfe, ist nett. (Dativ)',
                  'Der Mann, dessen Auto rot ist, kommt. (Genitiv)',
                ],
              ),
              GrammarRule(
                id: 'b1_relative_2',
                title: 'wo, wohin, worüber kabi nisbiy ravishlar',
                explanation: 'Joy bildiruvchi otlar uchun wo/wohin/woher\nPredlogli iboralar uchun wo(r)- + predlog',
                examples: [
                  'Das ist die Stadt, wo ich geboren wurde.',
                  'Das Thema, worüber wir sprachen, ist wichtig.',
                  'Die Firma, für die er arbeitet, ist groß.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 5. KELISHIKLAR VA PREDLOGLAR ──────────────────────
      GrammarCategory(
        id: 'b1_cases_advanced',
        name: 'Kelishiklar — Ilg\'or',
        icon: '📋',
        topics: [
          GrammarTopic(
            id: 'b1_genitiv_prep',
            title: 'Genitiv predloglari',
            description: 'wegen, trotz, während, statt, innerhalb, außerhalb, aufgrund',
            rules: [
              GrammarRule(
                id: 'b1_genitiv_prep_1',
                title: 'Keng ishlatiladigan Genitiv predloglari',
                explanation: 'wegen (sababli), trotz (qaramasdan), während (paytida), statt/anstatt (o\'rniga), innerhalb (ichida), außerhalb (tashqarisida), aufgrund (sababi bilan), mithilfe (yordamida), laut (ga ko\'ra)',
                examples: [
                  'Wegen des schlechten Wetters blieb er zu Hause.',
                  'Trotz der Müdigkeit arbeitete er weiter.',
                  'Statt des Kaffees trank er Tee.',
                  'Innerhalb der Stadt gibt es viele Parks.',
                  'Aufgrund des Staus kam er zu spät.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_praep_adjektive',
            title: 'Predlogli sifatlar (Präpositionaladjektive)',
            description: 'froh über, interessiert an, stolz auf...',
            rules: [
              GrammarRule(
                id: 'b1_praep_adj_1',
                title: 'Sifat + predlog + holat',
                explanation: 'Ko\'p ishlatiladigan birikishlar:\ninteressiert an + Dat — qiziqmoq\nfroh über + Akk — xursand bo\'lmoq\nstolz auf + Akk — faxrlanmoq\nangst vor + Dat — qo\'rqmoq\nbegeistert von + Dat — maftun bo\'lmoq\nzufrieden mit + Dat — mamnun bo\'lmoq\nfertig mit + Dat — tayyor bo\'lmoq',
                examples: [
                  'Ich bin interessiert an Musik.',
                  'Er ist froh über seinen Erfolg.',
                  'Sie ist stolz auf ihr Kind.',
                  'Ich bin fertig mit der Arbeit.',
                  'Wir sind zufrieden mit dem Ergebnis.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 6. OT VA SIFATLAR ─────────────────────────────────
      GrammarCategory(
        id: 'b1_nouns_advanced',
        name: 'Otlar va Sifatlar — Ilg\'or',
        icon: '📝',
        topics: [
          GrammarTopic(
            id: 'b1_n_deklination',
            title: 'N-Deklination (Zaif otlar)',
            description: 'Student, Name, Herr — barcha hollarda -(e)n',
            rules: [
              GrammarRule(
                id: 'b1_n_dekl_1',
                title: 'N-Deklination qoidasi',
                explanation: 'Ba\'zi erkak otlar Nominativdan boshqa barcha holatlarda -(e)n qo\'shimchasini oladi.\nKim? der Student — Kimni? den Studenten — Kimga? dem Studenten\nMashhur: der Student, der Mensch, der Kollege, der Herr (→ Herrn), der Name, der Gedanke.',
                examples: [
                  'Ich sehe den Studenten.',
                  'Ich helfe dem Herrn.',
                  'Das Auto des Studenten.',
                  'Er heißt Herrn Müller. (xat yozishda)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_nominalization',
            title: 'Sifatlarning otlashuvi',
            description: 'der/die Angestellte, das Gute, das Neue',
            rules: [
              GrammarRule(
                id: 'b1_nomin_1',
                title: 'Sifatdosh otlar (Substantivierte Adjektive)',
                explanation: 'Sifat katta harf bilan yoziladi va aniq artikl oladi. Lekin sifat kabi tuslanishda davom etadi!',
                examples: [
                  'der Angestellte / die Angestellte (xodim)',
                  'der Bekannte / die Bekannte (tanish)',
                  'das Neue (yangilik)',
                  'das Beste (eng yaxshi narsa)',
                  'Ich sehe einen Bekannten.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b1_da_wo_compound',
            title: 'Da- va Wo- qo\'shimchali olmoshlar',
            description: 'damit, davon, worüber, womit...',
            rules: [
              GrammarRule(
                id: 'b1_da_wo_1',
                title: 'Da(r)- va Wo(r)- qo\'shimchalari',
                explanation: 'Narsalar haqida gapirish uchun:\nda + predlog = damit, davon, daran, darüber...\nwo + predlog = womit, wovon, woran, worüber...\nPredlog unli bilan boshlanishsa r qo\'shiladi.',
                examples: [
                  'Womit schreibst du? — Damit schreibe ich.',
                  'Worüber sprecht ihr? — Darüber sprechen wir nicht.',
                  'Wofür interessiert er sich? — Dafür.',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // ─────────────────────────────────────────────────────────
  // B2 Daraja
  // ─────────────────────────────────────────────────────────
  static final GrammarLevel _b2Level = GrammarLevel(
    id: 'b2',
    level: 'B2',
    title: 'Yuqori O\'rta',
    description: 'Grammatikani noziklashtirish, murakkab matnlarni tushunish va ravon, puxta mulohaza yuritish ko\'nikmalarini rivojlantirish.',
    emoji: '📕',
    categories: [

      // ── 1. FE'LLAR ─────────────────────────────────────────
      GrammarCategory(
        id: 'b2_verbs',
        name: 'Fe\'llar — Ilg\'or',
        icon: '🔤',
        topics: [
          GrammarTopic(
            id: 'b2_passiv_all',
            title: 'Passiv — barcha zamon shakllari',
            description: 'Vorgangspassiv va Zustandspassiv',
            rules: [
              GrammarRule(
                id: 'b2_passiv_all_1',
                title: 'Vorgangspassiv (harakat passivi)',
                explanation: 'werden + Partizip II\nPräsens: wird gebaut\nPräteritum: wurde gebaut\nPerfekt: ist gebaut worden (worden!\nPlusquamperfekt: war gebaut worden\nFutur I: wird gebaut werden',
                examples: [
                  'Das Haus wird gebaut. (Präsens)',
                  'Das Haus wurde gebaut. (Präteritum)',
                  'Das Haus ist gebaut worden. (Perfekt)',
                  'Das Haus war gebaut worden. (Plusquamperfekt)',
                ],
              ),
              GrammarRule(
                id: 'b2_passiv_all_2',
                title: 'Zustandspassiv (holat passivi)',
                explanation: 'sein + Partizip II — tugallangan holat.\nVorgangspassiv = jarayon, Zustandspassiv = natija.',
                examples: [
                  'Die Tür ist geschlossen. (holat — yopiq)',
                  'Die Tür wird geschlossen. (jarayon — yopilmoqda)',
                  'Das Buch ist verkauft. (sotilgan)',
                ],
              ),
              GrammarRule(
                id: 'b2_passiv_all_3',
                title: 'Passiv muqobillari (Passiversatzformen)',
                explanation: '1. sein + zu + Infinitiv (mumkin yoki kerak)\n2. sich lassen + Infinitiv (qilish mumkin)\n3. man + aktiv fe\'l',
                examples: [
                  'Das ist zu machen. (= kann/muss gemacht werden)',
                  'Das lässt sich nicht ändern.',
                  'Man sagt, dass... (aytishlaricha)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_konjunktiv1',
            title: 'Konjunktiv I — Ko\'chirma gap',
            description: 'Bilvosita nutq (Indirekte Rede)',
            rules: [
              GrammarRule(
                id: 'b2_konjunktiv1_1',
                title: 'Konjunktiv I shakllari',
                explanation: 'Infinitivdan hosil qilinadi (Präsens Stamm + -e):\nsein: sei (alohida)\nhaben: habe, habest, habe, haben\nkommen: komme, kommest, komme, kommen\nIshlatilish: Er sagt, er komme. / Er sagte, er komme.',
                examples: [
                  'Er sagt, er komme morgen.',
                  'Sie berichtet, sie habe keine Zeit.',
                  'Er sagt, das Wetter sei schön.',
                  'Laut Bericht sei die Lage ruhig.',
                ],
              ),
              GrammarRule(
                id: 'b2_konjunktiv1_2',
                title: 'Bilvosita nutq tuzilishi',
                explanation: 'Agar Konjunktiv I = Indikativ bo\'lsa, Konjunktiv II ishlatiladi.\nZamon o\'zgarishi: Präsens → Kj I Präsens; Perfekt → Kj I Perfekt',
                examples: [
                  '"Ich bin krank." → Er sagt, er sei krank.',
                  '"Ich habe gegessen." → Er sagt, er habe gegessen.',
                  '"Ich werde kommen." → Er sagt, er werde kommen.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_modal_subjective',
            title: 'Modal fe\'llarning subyektiv ma\'nosi',
            description: 'Taxmin, ehtimollik ifodalash',
            rules: [
              GrammarRule(
                id: 'b2_modal_subj_1',
                title: 'Subyektiv modal fe\'llar — hozir',
                explanation: 'müssen — aniq taxmin (=sicher): Er muss krank sein.\nkönnen — ehtimollik: Das kann wahr sein.\ndürfen — ehtimollik (qonun/qoida): Das dürfte stimmen.\nsollen — boshqalarning da\'vosi: Er soll reich sein.\nwollen — o\'zining da\'vosi: Er will das gesehen haben.\nmögen — yo\'ldosh taxmin: Er mag Recht haben.',
                examples: [
                  'Er muss zu Hause sein. (sicher krank)',
                  'Das kann ein Fehler sein.',
                  'Er soll Millionär sein. (aytishlaricha)',
                  'Sie will das nicht gewusst haben.',
                ],
              ),
              GrammarRule(
                id: 'b2_modal_subj_2',
                title: 'Subyektiv modal fe\'llar — o\'tmish',
                explanation: 'Modal + haben/sein + Partizip II\nO\'tmishda bo\'lgan narsa haqida taxmin.',
                examples: [
                  'Er muss krank gewesen sein.',
                  'Sie kann das vergessen haben.',
                  'Er soll gewonnen haben.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 2. PARTIZIP KONSTRUKSIYALAR ───────────────────────
      GrammarCategory(
        id: 'b2_participles',
        name: 'Partizip Konstruksiyalar',
        icon: '🏗️',
        topics: [
          GrammarTopic(
            id: 'b2_partizip_adj',
            title: 'Partizip I va II — sifat sifatida',
            description: 'Qo\'shimcha sifat o\'rnida',
            rules: [
              GrammarRule(
                id: 'b2_partizip_1',
                title: 'Partizip I (faol, davom etayotgan)',
                explanation: 'Infinitiv + d → lesend, lachend, laufend.\nSifat kabi tuslanadi. Harakat davom etayotganda ishlatiladi.',
                examples: [
                  'das lachende Kind (kulayotgan bola)',
                  'die fließenden Gewässer (oqayotgan suvlar)',
                  'ein schlafendes Baby (uxlayotgan chaqaloq)',
                ],
              ),
              GrammarRule(
                id: 'b2_partizip_2',
                title: 'Partizip II (passiv, tugallangan)',
                explanation: 'Tugallangan yoki passiv ma\'no.\nTransitiv fe\'llar: passiv ma\'no → das gelesene Buch\nIntransitiv fe\'llar: tugallangan → ein eingeschlafenes Kind',
                examples: [
                  'das gelesene Buch (o\'qilgan kitob)',
                  'die geschlossene Tür (yopiq eshik)',
                  'ein eingeschlafenes Kind (uxlab qolgan bola)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_extended_attr',
            title: 'Kengaytirilgan sifat qo\'shimchasi (Erweitertes Attribut)',
            description: 'Rasmiy va yozma til uchun',
            rules: [
              GrammarRule(
                id: 'b2_ext_attr_1',
                title: 'Kengaytirilgan sifat attributi',
                explanation: 'Artikl va ot o\'rtasida to\'liq gap qo\'shish mumkin. Bu yozma va rasmiy tilda juda keng tarqalgan.',
                examples: [
                  'der schnell laufende Hund (tez yugurayotgan it)',
                  'das von mir geschriebene Buch (men yozgan kitob)',
                  'die im 19. Jahrhundert erbaute Brücke',
                  'der trotz des Regens spazieren gehende Mann',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 3. NOMINALIZATSIYA ────────────────────────────────
      GrammarCategory(
        id: 'b2_nominalization',
        name: 'Nominalizatsiya (Nominalstil)',
        icon: '📝',
        topics: [
          GrammarTopic(
            id: 'b2_nomin_verbs',
            title: 'Fe\'llarning otlashuvi',
            description: 'Rasmiy va akademik til',
            rules: [
              GrammarRule(
                id: 'b2_nomin_1',
                title: 'Fe\'ldan ot yasash',
                explanation: 'Nemis tilida ko\'pgina fe\'llar to\'g\'ridan-to\'g\'ri katta harf bilan ot bo\'ladi.\nYoki maxsus qo\'shimchalar: -ung, -heit, -keit, -ion, -nis',
                examples: [
                  'lesen → das Lesen (o\'qish jarayoni)',
                  'entwickeln → die Entwicklung (rivojlanish)',
                  'analysieren → die Analyse',
                  'frei sein → die Freiheit',
                  'möglich sein → die Möglichkeit',
                ],
              ),
              GrammarRule(
                id: 'b2_nomin_2',
                title: 'Verbal uslub vs Nominal uslub',
                explanation: 'Kundalik nutq — verbal uslub (fe\'l bilan)\nRasmiy/akademik — nominal uslub (ot bilan)',
                examples: [
                  'Kundalik: Er hat analysiert, wie... (verbal)',
                  'Rasmiy: Die Analyse zeigt, dass... (nominal)',
                  'K: Man muss helfen. → Rasmiy: Hilfe ist notwendig.',
                  'K: Er entschied sich. → R: Seine Entscheidung war...',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_funktionsverb',
            title: 'Funktsional fe\'l birikmalari (Funktionsverbgefüge)',
            description: 'in Betrieb nehmen, zur Verfügung stellen...',
            rules: [
              GrammarRule(
                id: 'b2_fvg_1',
                title: 'Ko\'p ishlatiladigan FVG',
                explanation: 'Ot + fe\'l birikmasidan iborat rasmiy iboralar.\nKundalik muqobili qavs ichida.',
                examples: [
                  'in Betrieb nehmen (ishga tushirmoq)',
                  'zur Verfügung stellen (taqdim etmoq)',
                  'in Frage kommen (e\'tiborga olinmoq)',
                  'Einfluss nehmen auf (ta\'sir qilmoq)',
                  'in Kauf nehmen (qabul qilmoq, toqat qilmoq)',
                  'eine Entscheidung treffen (qaror qabul qilmoq)',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 4. MATN BOG'LOVCHILARI ────────────────────────────
      GrammarCategory(
        id: 'b2_text_connectors',
        name: 'Matn Bog\'lovchilari (Textverbindung)',
        icon: '🔗',
        topics: [
          GrammarTopic(
            id: 'b2_complex_connectors',
            title: 'Murakkab bog\'lovchilar',
            description: 'indem, je...desto, ohne dass, solange, sobald',
            rules: [
              GrammarRule(
                id: 'b2_complex_1',
                title: 'Murakkab bog\'lovchilar — yangi',
                explanation: 'indem — qilish orqali (usul)\nje...desto — qancha...shuncha\nohne dass — ...siz bo\'lishiga qaramay (boshqa subyekt)\nsolange — ...davomida\nsobald — ...zahotiyoq\nnachdem — ...dan keyin (Plusquamperfekt bilan)',
                examples: [
                  'Er lernt, indem er laut liest. (o\'qish orqali)',
                  'Je mehr er lernt, desto besser wird er.',
                  'Er ging, ohne dass jemand es merkte.',
                  'Solange ich hier bin, bin ich für euch da.',
                  'Sobald er ankommt, beginnen wir.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_textstruktur',
            title: 'Matn tuzuvchi vositalar',
            description: 'erstens, einerseits, zusammenfassend...',
            rules: [
              GrammarRule(
                id: 'b2_text_1',
                title: 'Ro\'yxat va ketma-ketlik',
                explanation: 'erstens/zweitens/drittens (birinchidan/ikkinchidan)\neinerseits...andererseits (bir tomondan...boshqa tomondan)\nzunächst (avvaliga), dann (keyin), schließlich (nihoyat), zuletzt (oxirida)',
                examples: [
                  'Erstens ist es teuer, zweitens ist es weit.',
                  'Einerseits mag ich Sport, andererseits bin ich faul.',
                  'Zunächst lese ich, dann schreibe ich.',
                ],
              ),
              GrammarRule(
                id: 'b2_text_2',
                title: 'Xulosa va qarama-qarshilik',
                explanation: 'zusammenfassend (xulosa qilsak)\nallerdings (biroq, lekin)\nim Gegensatz dazu (buning aksiga)\nstattdessen (buning o\'rniga)\ndennoch (shunday bo\'lsa ham)\ndagegen (bunga qarshi)',
                examples: [
                  'Zusammenfassend lässt sich sagen, dass...',
                  'Er ist klug. Allerdings ist er faul.',
                  'Im Gegensatz dazu steht die andere Meinung.',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 5. GAP TUZILISHI ──────────────────────────────────
      GrammarCategory(
        id: 'b2_sentence',
        name: 'Gap Tuzilishi — Ilg\'or',
        icon: '💬',
        topics: [
          GrammarTopic(
            id: 'b2_modalpartikeln',
            title: 'Modal zarralar (Modalpartikeln/Abtönungspartikeln)',
            description: 'doch, ja, mal, eben, halt, eigentlich, wohl, schon',
            rules: [
              GrammarRule(
                id: 'b2_modal_1',
                title: 'Asosiy modal zarralar',
                explanation: 'ja — kutilgan narsa, ta\'kid: Das ist ja toll!\ndoch — inkorni inkor qilmoq: Doch, ich komme!\nmal — yumshoq buyruq: Komm mal her!\neben/halt — qilib bo\'lmaydi, shunday: Das ist eben so.\nschon — ishonch berish: Das wird schon klappen.\nwohl — taxmin: Er ist wohl krank.',
                examples: [
                  'Das ist ja interessant! (taajjub)',
                  'Komm doch mal vorbei. (iltimos)',
                  'Das ist halt so. (qilib bo\'lmaydi)',
                  'Das schaffst du schon. (ishontirish)',
                  'Er ist wohl noch nicht da. (taxmin)',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_word_order_adv',
            title: 'So\'z tartibi — Ilg\'or (Satzklammer)',
            description: 'Murakkab gap ichida so\'z tartibi',
            rules: [
              GrammarRule(
                id: 'b2_word_order_1',
                title: 'Satzklammer (ramka qurilishi)',
                explanation: 'Asosiy gap: Fe\'l 2-o\'rinda, qo\'shimcha qism oxirida.\nErgashgan gap: Barcha fe\'llar oxirida (modal → Infinitiv → oldin).',
                examples: [
                  'Ich habe das Buch gelesen. (habe...gelesen)',
                  'Er kann nicht kommen. (kann...kommen)',
                  '...weil er das Buch nicht gelesen hat.',
                  '...obwohl er kommen wollte.',
                ],
              ),
              GrammarRule(
                id: 'b2_word_order_2',
                title: 'Ergashgan gapdagi fe\'llar tartibi',
                explanation: 'Modal bilan Perfekt: ...dass er es nicht hat tun können.\nPassiv bilan modal: ...weil es gemacht werden muss.',
                examples: [
                  '...weil er gekommen ist.',
                  '...weil er kommen will.',
                  '...weil er hat kommen wollen. (ikki fe\'l)',
                  '...weil es nicht gemacht werden kann.',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_vorfeld',
            title: 'Birinchi o\'rin (Vorfeld) variatsiyasi',
            description: 'Ta\'kidlash va uslub',
            rules: [
              GrammarRule(
                id: 'b2_vorfeld_1',
                title: 'Birinchi o\'rinda turlicha elementlar',
                explanation: 'Nemischa gapda 1-o\'rinda nafaqat ega, balki vaqt, joy, ob\'ekt, ergashgan gap ham turishi mumkin — ta\'kidlash uchun.',
                examples: [
                  'Gestern habe ich ihn gesehen. (vaqt 1-o\'rinda)',
                  'Das Buch hat er nicht gelesen. (ob\'ekt 1-o\'rinda)',
                  'Weil es regnete, blieb er zu Hause. (ergashgan gap 1-o\'rinda)',
                  'Langsam wurde es dunkel. (ravish 1-o\'rinda)',
                ],
              ),
            ],
          ),
        ],
      ),

      // ── 6. USLUB VA NOZIKLIKLAR ───────────────────────────
      GrammarCategory(
        id: 'b2_style',
        name: 'Uslub va Nozikliklar (Stilmittel)',
        icon: '✍️',
        topics: [
          GrammarTopic(
            id: 'b2_register',
            title: 'Rasmiy va norasmiy uslub',
            description: 'Kundalik nutq vs rasmiy yozuv',
            rules: [
              GrammarRule(
                id: 'b2_register_1',
                title: 'Uslub farqlari',
                explanation: 'Norasmiy (Umgangssprache): qisqartmalar, to\'liqsiz gaplar, Perfekt\nRasmiy (Formalstil): Präteritum, Nominalstil, passiv, uzoq gaplar',
                examples: [
                  'Norasmiy: Ich hab\'s gemacht. Kein Problem.',
                  'Rasmiy: Die Aufgabe wurde erfolgreich abgeschlossen.',
                  'N: Warum bist du nicht da? R: Aus welchem Grund...',
                ],
              ),
              GrammarRule(
                id: 'b2_register_2',
                title: 'Wissenschaftlicher Schreibstil (Ilmiy uslub)',
                explanation: 'Passiv ko\'p ishlatish, shaxssiz qurilmalar (man, es gibt), aniq izohlar, bog\'lovchilar.',
                examples: [
                  'Es wurde festgestellt, dass...',
                  'Man kann beobachten, dass...',
                  'Im Folgenden wird untersucht...',
                  'Zusammenfassend lässt sich sagen...',
                ],
              ),
            ],
          ),
          GrammarTopic(
            id: 'b2_idiomatic',
            title: 'Iboralar va frazeologizmlar (Redewendungen)',
            description: 'Ko\'p ishlatiladigan iboralar',
            rules: [
              GrammarRule(
                id: 'b2_idiom_1',
                title: 'Asosiy iboralar',
                explanation: 'Ko\'p ishlatiladigan nemis iboralari:',
                examples: [
                  'Das ist nicht mein Ding. (bu menga emas)',
                  'Das geht auf keine Kuhhaut. (bu juda ko\'p)',
                  'Daumen drücken! (omad tilash — barmoqni ushlamoq)',
                  'jemanden auf dem Laufenden halten (xabardor qilmoq)',
                  'das Handtuch werfen (taslim bo\'lmoq)',
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
