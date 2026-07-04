// TELC Sprechen (og'zaki nutq) — A1, A2, B1, B2 darajalari.
// Har daraja TELC imtihon strukturasiga mos Teil'lardan iborat.
// Bu bo'lim nutq mashqi uchun: har Teil topshiriq matnlari va misol
// iboralarni ko'rsatadi (avtomatik baholanmaydi).

/// Bitta nutq topshirig'i (vazifa) — sarlavha, ko'rsatma va yordamchi
/// kalit so'zlar / misol iboralar.
class SprechenAufgabe {
  /// Topshiriq sarlavhasi (masalan "Sich vorstellen").
  final String title;

  /// Topshiriq tavsifi / ko'rsatma (nima qilish kerakligi).
  final String instruction;

  /// Teil 2 (juftlik) uchun: qaysi nomzod ("A" yoki "B"). Bo'sh bo'lsa
  /// nomzod belgisi ko'rsatilmaydi.
  final String partner;

  /// Teil 2 uchun: o'qib, fikr bildiriladigan "Meinung" (fikr) kartasi matni.
  /// null bo'lsa ko'rsatilmaydi.
  final String? meinung;

  /// Teil 2 uchun: fikr muallifi (ism, yosh, kasb). null bo'lsa ko'rsatilmaydi.
  final String? author;

  /// Mavzu yoki kalit so'zlar (kartochkalar) — gapirishda yordam beradi.
  final List<String> keywords;

  /// Misol iboralar / foydali gaplar (Redemittel).
  final List<String> examples;

  /// To'liq namuna javob (Musterlösung) — foydalanuvchi bossa ochiladi.
  /// null bo'lsa ko'rsatilmaydi.
  final String? sampleAnswer;

  const SprechenAufgabe({
    required this.title,
    required this.instruction,
    this.partner = '',
    this.meinung,
    this.author,
    this.keywords = const [],
    this.examples = const [],
    this.sampleAnswer,
  });
}

/// Teil 2 uchun bitta test — bir mavzu (Thema) ostida ikki nomzod (A/B) uchun
/// turli fikrlar. Gorizontal scroll orqali testlar almashtiriladi.
class SprechenTest {
  /// Test mavzusi (masalan "TikTok"). Faqat ichki ko'rsatish uchun.
  final String thema;

  /// Shu testdagi topshiriqlar (odatda Teilnehmer A va B).
  final List<SprechenAufgabe> aufgaben;

  const SprechenTest({
    required this.thema,
    required this.aufgaben,
  });
}

/// Sprechen imtihonining bir qismi (Teil) — bir nechta topshiriqdan iborat.
class SprechenTeil {
  final int teilNumber;

  /// Teil nomi (masalan "Kontaktaufnahme").
  final String title;

  /// Qisqa tavsif.
  final String description;

  /// Oddiy Teil'lar uchun topshiriqlar (Teil 1, Teil 3).
  final List<SprechenAufgabe> aufgaben;

  /// Ko'p testli Teil'lar uchun (Teil 2): gorizontal scroll bilan tanlanadigan
  /// testlar. Bo'sh bo'lmasa, ekran [aufgaben] o'rniga shu testlarni ko'rsatadi.
  final List<SprechenTest> tests;

  const SprechenTeil({
    required this.teilNumber,
    required this.title,
    required this.description,
    this.aufgaben = const [],
    this.tests = const [],
  });
}

class SprechenLevel {
  final String level;
  final List<SprechenTeil> teile;

  const SprechenLevel({required this.level, required this.teile});
}

// ─────────────────────────────────────────────────────────────────────────────
// A1 — TELC Start Deutsch 1: 3 Teile
//   Teil 1: Sich vorstellen
//   Teil 2: Um Informationen bitten und geben
//   Teil 3: Bitten formulieren und darauf reagieren
// ─────────────────────────────────────────────────────────────────────────────
const sprechenA1 = SprechenLevel(
  level: 'A1',
  teile: [
    SprechenTeil(
      teilNumber: 1,
      title: 'Sich vorstellen',
      description: 'O\'zingiz haqingizda gapiring.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Sich vorstellen',
          instruction:
              'Stellen Sie sich vor. Sprechen Sie über die folgenden Punkte.',
          keywords: [
            'Name',
            'Alter',
            'Land',
            'Wohnort',
            'Sprachen',
            'Beruf',
            'Hobby',
          ],
          examples: [
            'Ich heiße … / Mein Name ist …',
            'Ich bin … Jahre alt.',
            'Ich komme aus … und wohne in …',
            'Ich spreche … und ein bisschen Deutsch.',
            'Von Beruf bin ich …',
            'In meiner Freizeit … ich gern.',
          ],
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 2,
      title: 'Um Informationen bitten und geben',
      description: 'Bir mavzu bo\'yicha savol bering va javob bering.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Thema: Einkaufen',
          instruction:
              'Bilden Sie eine Frage und eine Antwort mit dem Wort auf der Karte.',
          keywords: ['Brot', 'Obst', 'Markt', 'Preis', 'Getränke', 'Kasse'],
          examples: [
            'Wo kann man hier Brot kaufen?',
            'Was kostet das Obst?',
            'Gibt es hier einen Markt?',
          ],
        ),
        SprechenAufgabe(
          title: 'Thema: Freizeit',
          instruction:
              'Bilden Sie eine Frage und eine Antwort mit dem Wort auf der Karte.',
          keywords: ['Kino', 'Sport', 'Musik', 'Wochenende', 'Urlaub', 'Buch'],
          examples: [
            'Gehst du gern ins Kino?',
            'Was machst du am Wochenende?',
            'Welche Musik hörst du gern?',
          ],
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 3,
      title: 'Bitten formulieren und darauf reagieren',
      description: 'Iltimos bildiring va unga javob bering.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Bitten im Alltag',
          instruction:
              'Formulieren Sie eine höfliche Bitte und reagieren Sie darauf.',
          keywords: ['Fenster', 'Licht', 'Tür', 'Stift', 'Wasser', 'Handy'],
          examples: [
            'Kannst du bitte das Fenster öffnen?',
            'Könnten Sie bitte das Licht anmachen?',
            'Ja, gern. / Natürlich. / Einen Moment, bitte.',
          ],
        ),
      ],
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// A2 — TELC Deutsch A2: 3 Teile
//   Teil 1: Sich vorstellen (erweitert)
//   Teil 2: Über ein Thema sprechen
//   Teil 3: Gemeinsam etwas aushandeln / planen
// ─────────────────────────────────────────────────────────────────────────────
const sprechenA2 = SprechenLevel(
  level: 'A2',
  teile: [
    SprechenTeil(
      teilNumber: 1,
      title: 'Sich vorstellen',
      description: 'O\'zingiz va hayotingiz haqida batafsil gapiring.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Über sich erzählen',
          instruction:
              'Erzählen Sie etwas über sich und Ihr Leben.',
          keywords: [
            'Familie',
            'Arbeit / Schule',
            'Tagesablauf',
            'Sprachen lernen',
            'Wohnung',
            'Zukunftspläne',
          ],
          examples: [
            'Ich lebe seit … in …',
            'Ich arbeite als … / Ich lerne …',
            'Normalerweise stehe ich um … auf.',
            'In Zukunft möchte ich …',
          ],
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 2,
      title: 'Über ein Thema sprechen',
      description: 'Berilgan mavzu bo\'yicha o\'z fikringizni bildiring.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Thema: Essen und Trinken',
          instruction:
              'Sprechen Sie über das Thema. Beantworten Sie die Fragen.',
          keywords: [
            'Was essen Sie gern?',
            'Kochen Sie selbst?',
            'Essen gehen',
            'Gesunde Ernährung',
          ],
          examples: [
            'Am liebsten esse ich …',
            'Ich koche (nicht) gern, weil …',
            'Manchmal gehe ich mit … essen.',
          ],
        ),
        SprechenAufgabe(
          title: 'Thema: Reisen',
          instruction:
              'Sprechen Sie über das Thema. Beantworten Sie die Fragen.',
          keywords: [
            'Wohin reisen Sie gern?',
            'Mit wem?',
            'Lieblingsland',
            'Urlaub am Meer oder in den Bergen?',
          ],
          examples: [
            'Ich reise gern nach …',
            'Im letzten Urlaub war ich in …',
            'Ich mag lieber … als …',
          ],
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 3,
      title: 'Gemeinsam etwas planen',
      description: 'Hamkoringiz bilan birgalikda biror narsani rejalashtiring.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Eine Feier planen',
          instruction:
              'Planen Sie gemeinsam mit Ihrem Partner eine Geburtstagsfeier.',
          keywords: ['Wann?', 'Wo?', 'Wer kommt?', 'Essen', 'Musik', 'Geschenk'],
          examples: [
            'Wann sollen wir die Feier machen?',
            'Ich schlage vor, dass wir …',
            'Gute Idee! / Das finde ich nicht so gut.',
            'Sollen wir … oder …?',
          ],
        ),
      ],
    ),
  ],
);

// Teil 3 (Gemeinsam etwas planen) uchun umumiy foydali iboralar (Redemittel).
const _planungRedemittel = [
  'Ich schlage vor, dass wir …',
  'Wollen wir … oder …?',
  'Was hältst du davon, wenn wir …?',
  'Das ist eine gute Idee. / Das sehe ich anders.',
  'Gut, dann machen wir es so. Einverstanden?',
];

// ─────────────────────────────────────────────────────────────────────────────
// B1 — TELC Deutsch B1: 3 Teile
//   Teil 1: Kontaktaufnahme (tanishish)
//   Teil 2: Über ein Thema sprechen (fikr o'qish va muhokama)
//   Teil 3: Gemeinsam etwas planen (birgalikda rejalashtirish)
// ─────────────────────────────────────────────────────────────────────────────
const sprechenB1 = SprechenLevel(
  level: 'B1',
  teile: [
    SprechenTeil(
      teilNumber: 1,
      title: 'Kontaktaufnahme',
      description:
          'Hamkoringiz bilan tanishing: ism, kelib chiqishi, oila, til va kasb '
          'haqida bir-biringizga savol bering va javob bering.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Kontaktaufnahme',
          instruction:
              'Unterhalten Sie sich mit Ihrer Partnerin bzw. Ihrem Partner '
              'über folgende Themen. Die Prüfenden können außerdem noch weitere '
              'Fragen stellen.',
          keywords: [
            'Name',
            'Woher sie oder er kommt',
            'Wie sie oder er wohnt (Wohnung, Haus, Garten …)',
            'Familie',
            'Wo sie oder er Deutsch gelernt hat',
            'Was sie oder er macht (Schule, Studium, Beruf …)',
            'Sprachen (welche? wie lange? warum?)',
          ],
          examples: [
            'Darf ich dich etwas fragen? Wie heißt du?',
            'Woher kommst du?',
            'Wie wohnst du – in einer Wohnung oder in einem Haus?',
            'Erzähl mir etwas über deine Familie.',
            'Wo hast du Deutsch gelernt?',
            'Was machst du – gehst du zur Schule, studierst du oder arbeitest du?',
            'Welche Sprachen sprichst du und wie lange lernst du sie schon?',
          ],
          sampleAnswer:
              'A: Hallo! Mein Name ist Aziz. Und wie heißt du?\n'
              'B: Hallo Aziz, ich heiße Marta. Freut mich!\n'
              'A: Woher kommst du, Marta?\n'
              'B: Ich komme aus Polen, aus einer kleinen Stadt in der Nähe von '
              'Krakau. Und du?\n'
              'A: Ich komme aus Usbekistan, aus Nukus. Wie wohnst du hier – in '
              'einer Wohnung oder in einem Haus?\n'
              'B: Ich wohne in einer Wohnung im Stadtzentrum. Sie ist nicht '
              'groß, aber sehr gemütlich. Hast du eine große Familie?\n'
              'A: Ja, ich habe zwei Brüder und eine Schwester. Meine Eltern '
              'leben noch in Nukus. Und wo hast du Deutsch gelernt?\n'
              'B: Ich habe in einer Sprachschule in Krakau angefangen und lerne '
              'jetzt hier weiter. Was machst du beruflich?\n'
              'A: Ich studiere Informatik und arbeite nebenbei in einem Café. '
              'Welche Sprachen sprichst du?\n'
              'B: Ich spreche Polnisch, Englisch und seit zwei Jahren Deutsch. '
              'Deutsch lerne ich, weil ich gern in Deutschland arbeiten möchte.\n'
              'A: Das ist ein gutes Ziel. Ich lerne Deutsch aus demselben Grund!',
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 2,
      title: 'Über ein Thema sprechen',
      description:
          'Har testda bir mavzu beriladi. Ikkala nomzod (A/B) shu mavzu '
          'bo\'yicha turli fikrlarni o\'qiydi va birgalikda muhokama qiladi.',
      tests: [
        SprechenTest(
          thema: 'TikTok',
          aufgaben: [
        SprechenAufgabe(
          partner: 'A',
          title: 'TikTok',
          instruction:
              'Lesen Sie die folgende Meinung vor und sagen Sie, was Sie '
              'davon halten. Reagieren Sie dann auf die Meinung Ihres Partners '
              'und sprechen Sie gemeinsam über das Thema.',
          meinung:
              'Manche Menschen verbringen Stunden mit TikTok-Videos. Das ist '
              'doch reine Zeitverschwendung. Warum sollten einem die '
              'Darstellungen und Meinungen fremder Leute wichtig sein? Ich '
              'würde mir lieber ein schönes Hobby suchen. Es gibt so viele '
              'Möglichkeiten.',
          examples: [
            'In dieser Meinung geht es um …',
            'Ich kann diese Meinung gut verstehen, denn …',
            'Auf der einen Seite stimmt das, auf der anderen Seite …',
            'Wie siehst du das?',
            'Da bin ich (nicht) deiner Meinung, weil …',
          ],
          sampleAnswer:
              'In dieser Meinung geht es darum, dass viele Menschen zu viel '
              'Zeit mit TikTok-Videos verbringen und dass das Zeitverschwendung '
              'sei.\n\n'
              'Ich kann diese Meinung teilweise verstehen. Es stimmt, dass '
              'manche Leute stundenlang Videos anschauen, statt etwas Sinnvolles '
              'zu tun. Man könnte diese Zeit auch für ein Hobby, für Sport oder '
              'für Freunde nutzen.\n\n'
              'Auf der anderen Seite finde ich nicht, dass TikTok nur '
              'Zeitverschwendung ist. Man kann dort auch viel lernen, zum '
              'Beispiel Kochrezepte, Sprachen oder kleine Tricks. Es kommt also '
              'darauf an, wie man die App benutzt.\n\n'
              'Und wie ist deine Meinung dazu?',
        ),
        SprechenAufgabe(
          partner: 'B',
          title: 'TikTok',
          instruction:
              'Lesen Sie die folgende Meinung vor und sagen Sie, was Sie '
              'davon halten. Reagieren Sie dann auf die Meinung Ihres Partners '
              'und sprechen Sie gemeinsam über das Thema.',
          meinung:
              'Unsere Tochter postet regelmäßig Videos auf TikTok. Anfangs habe '
              'ich mir Sorgen gemacht. Aber nun sehe ich, wie gut es ihr tut. '
              'Sie hat wirklich Talent als Schauspielerin und Sängerin, und '
              'das kann sie so mit anderen teilen. Ihre Videos haben viel '
              'Erfolg.',
          examples: [
            'In dieser Meinung geht es um …',
            'Ich sehe das ähnlich / anders, weil …',
            'Das ist ein gutes Beispiel dafür, dass …',
            'Was meinst du dazu?',
            'Zusammenfassend kann man sagen, dass …',
          ],
          sampleAnswer:
              'In dieser Meinung erzählt ein Elternteil, dass die Tochter '
              'regelmäßig Videos auf TikTok postet und damit viel Erfolg hat.\n\n'
              'Ich sehe das sehr positiv. Früher hatten junge Menschen kaum '
              'eine Möglichkeit, ihr Talent zu zeigen. Heute kann man über '
              'TikTok ein großes Publikum erreichen, ohne berühmt zu sein.\n\n'
              'Natürlich gibt es auch Risiken: Man sollte vorsichtig sein, '
              'welche Informationen man teilt, und nicht zu viel Zeit damit '
              'verbringen. Aber wenn jemand wie diese Tochter Talent als '
              'Sängerin oder Schauspielerin hat, ist TikTok eine tolle Chance.\n\n'
              'Zusammenfassend würde ich sagen: Es kommt darauf an, wie man die '
              'App nutzt. Was denkst du?',
        ),
          ],
        ),
        SprechenTest(
          thema: 'Gemeinschaftsgarten',
          aufgaben: [
        SprechenAufgabe(
          partner: 'A',
          title: 'Gemeinschaftsgarten',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Wir nutzen seit einem Jahr ein Stück in einem '
              'Gemeinschaftsgarten. Wir bauen Gemüse und Kräuter an. So wissen '
              'wir, wo unser Essen herkommt. Wir können ganz sicher sein, dass '
              'es wirklich Bio ist. Außerdem macht uns die Arbeit im Freien '
              'viel Freude.',
          author: 'Lisa Feldmann (43), Kamerafrau',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person findet einen Gemeinschaftsgarten gut, weil …',
            'Ich sehe das ähnlich / anders, weil …',
            'Ich persönlich habe die Erfahrung gemacht, dass …',
            'Wie ist das bei dir?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es um Gemeinschaftsgärten. Lisa Feldmann '
              'nutzt seit einem Jahr ein Stück in so einem Garten und baut dort '
              'Gemüse und Kräuter an.\n\n'
              'Sie findet das gut, weil sie genau weiß, wo ihr Essen herkommt '
              'und dass es wirklich Bio ist. Außerdem macht ihr die Arbeit im '
              'Freien Freude.\n\n'
              'Ich kann das gut verstehen. Frische Lebensmittel selbst '
              'anzubauen ist gesund und macht Spaß. Bei uns auf dem Land hatten '
              'wir früher einen eigenen Garten, und das Gemüse hat viel besser '
              'geschmeckt als aus dem Supermarkt.\n\n'
              'Wie ist das bei dir? Hast du auch schon einmal etwas selbst '
              'angebaut?',
        ),
        SprechenAufgabe(
          partner: 'B',
          title: 'Gemeinschaftsgarten',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Meine Eltern sind Mieter in einem Gemeinschaftsgarten. Da gibt '
              'es oft Stress: zum Beispiel, wenn es lange nicht regnet, und die '
              'teuren Pflanzen vertrocknen. Wenn sie in Urlaub fahren wollen, '
              'muss jemand den Garten für sie gießen. Ich kaufe mein Gemüse '
              'lieber im Laden.',
          author: 'Harald Daubner (29), Kaufmann',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person sieht eher die Nachteile, zum Beispiel …',
            'Ich sehe das ähnlich / anders, weil …',
            'Aus eigener Erfahrung kann ich sagen, dass …',
            'Und wie denkst du darüber?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es auch um Gemeinschaftsgärten, aber '
              'Harald Daubner sieht eher die Nachteile.\n\n'
              'Seine Eltern mieten ein Stück in so einem Garten, und er '
              'berichtet, dass es oft Stress gibt: Wenn es lange nicht regnet, '
              'vertrocknen die teuren Pflanzen, und wenn man in Urlaub fährt, '
              'muss jemand gießen. Deshalb kauft er sein Gemüse lieber im '
              'Laden.\n\n'
              'Ich kann diese Sorgen verstehen. Ein Garten bedeutet viel Arbeit '
              'und Verantwortung, und nicht jeder hat dafür Zeit. Trotzdem '
              'finde ich, dass die Vorteile überwiegen, wenn man die Zeit hat.\n\n'
              'Und wie denkst du darüber – lohnt sich der Aufwand?',
        ),
          ],
        ),
        SprechenTest(
          thema: 'Im Internet bestellen',
          aufgaben: [
        SprechenAufgabe(
          partner: 'A',
          title: 'Im Internet bestellen',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Am liebsten bestelle ich meine Kleider im Internet. Die Auswahl '
              'ist viel größer als im Laden. Überfüllte Geschäfte mag ich '
              'nicht. Ich suche lieber zu Hause aus und probiere dann in aller '
              'Ruhe. Was mir nicht gefällt, kann ich problemlos '
              'zurückschicken.',
          author: 'Heike Bittner (36), Hausfrau',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person bestellt am liebsten online, weil …',
            'Ich sehe das ähnlich / anders, weil …',
            'Ich persönlich bestelle (nicht) gern im Internet, weil …',
            'Wie machst du das?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es um das Einkaufen im Internet. Heike '
              'Bittner bestellt ihre Kleidung am liebsten online.\n\n'
              'Sie findet das gut, weil die Auswahl viel größer ist als im '
              'Laden und sie überfüllte Geschäfte nicht mag. Sie sucht lieber '
              'in Ruhe zu Hause aus und kann alles problemlos zurückschicken.\n\n'
              'Ich kann das gut nachvollziehen. Online-Shopping ist bequem und '
              'man spart Zeit. Ich selbst bestelle auch oft im Internet, vor '
              'allem Bücher und Elektronik.\n\n'
              'Bei Kleidung bin ich aber vorsichtiger, weil die Größen oft nicht '
              'passen. Wie machst du das – kaufst du lieber online oder im '
              'Laden?',
        ),
        SprechenAufgabe(
          partner: 'B',
          title: 'Im Internet bestellen',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Ich kaufe nicht oft Kleidung. Aber wenn ich etwas brauche, nehme '
              'ich mir Zeit und gehe in die Stadt. Im Internet bestellen mag '
              'ich nicht. Die Farben sind oft ganz anders als auf den Fotos. '
              'Der Stoff sieht auf den Bildern auch meistens besser aus.',
          author: 'Carlo Marchese (33), Malermeister',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person kauft lieber im Laden, weil …',
            'Ich sehe das ähnlich / anders, weil …',
            'Aus eigener Erfahrung kann ich sagen, dass …',
            'Und wie ist deine Meinung dazu?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es auch um das Einkaufen im Internet, '
              'aber Carlo Marchese hat eine andere Meinung.\n\n'
              'Er kauft nicht oft Kleidung, und wenn er etwas braucht, geht er '
              'lieber in die Stadt. Online bestellen mag er nicht, weil die '
              'Farben oft anders sind als auf den Fotos und der Stoff auf den '
              'Bildern besser aussieht.\n\n'
              'Da hat er recht: Mir ist das auch schon passiert. Einmal habe '
              'ich eine Jacke bestellt, und die Farbe war ganz anders als '
              'erwartet.\n\n'
              'Trotzdem finde ich Online-Shopping praktisch, wenn man wenig '
              'Zeit hat. Und wie ist deine Meinung dazu?',
        ),
          ],
        ),
        SprechenTest(
          thema: 'Haustiere',
          aufgaben: [
        SprechenAufgabe(
          partner: 'A',
          title: 'Haustiere',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Haustiere sind wichtig für Kinder. Ein Hund zum Beispiel kann '
              'ein guter Freund sein. Vor allem für Kinder, die sich oft allein '
              'fühlen oder schüchtern sind, ist das eine große Hilfe. Und mit '
              'Tieren lernen Kinder, sich um jemanden zu kümmern.',
          author: 'Udo Franke (39), Betriebswirt',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person findet Haustiere für Kinder wichtig, weil …',
            'Ich sehe das ähnlich / anders, weil …',
            'Ich persönlich habe als Kind … gehabt.',
            'Wie ist das bei dir?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es um Haustiere. Udo Franke findet, dass '
              'Haustiere für Kinder wichtig sind.\n\n'
              'Er meint, ein Hund kann ein guter Freund sein, besonders für '
              'Kinder, die sich allein fühlen oder schüchtern sind. Außerdem '
              'lernen Kinder mit Tieren, Verantwortung zu übernehmen und sich '
              'um jemanden zu kümmern.\n\n'
              'Ich sehe das ähnlich. Als Kind hatte ich eine Katze, und ich '
              'habe gelernt, jeden Tag für sie zu sorgen. Das war eine gute '
              'Erfahrung.\n\n'
              'Tiere machen Kinder auch fröhlicher und aktiver. Wie ist das bei '
              'dir – hattest du als Kind ein Haustier?',
        ),
        SprechenAufgabe(
          partner: 'B',
          title: 'Haustiere',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Unser Sohn, Timo, wünscht sich einen Hund. Doch Timo ist erst '
              'sieben Jahre alt. Wir denken, dass er zu jung ist. Ein Hund '
              'macht viel Arbeit. Man muss ihn regelmäßig füttern und mit ihm '
              'spazieren gehen. Kindern fehlt aber die nötige Disziplin.',
          author: 'Saskia Vorbeck (35), Grafikerin',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person ist eher dagegen, weil …',
            'Ich sehe das ähnlich / anders, weil …',
            'Aus eigener Erfahrung kann ich sagen, dass …',
            'Und wie denkst du darüber?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es auch um Haustiere, aber Saskia '
              'Vorbeck ist eher dagegen.\n\n'
              'Ihr Sohn Timo wünscht sich einen Hund, aber er ist erst sieben '
              'Jahre alt. Sie findet, dass er noch zu jung ist, weil ein Hund '
              'viel Arbeit macht: Man muss ihn regelmäßig füttern und mit ihm '
              'spazieren gehen, und Kindern fehle dafür die Disziplin.\n\n'
              'Ich kann ihre Sorgen verstehen. Ein kleines Kind kann nicht '
              'allein die ganze Verantwortung tragen. Aber ich denke, die '
              'Eltern können dem Kind helfen und es so Schritt für Schritt '
              'lernen lassen.\n\n'
              'Und wie denkst du darüber – ab welchem Alter ist ein Haustier '
              'sinnvoll?',
        ),
          ],
        ),
        SprechenTest(
          thema: 'Brief oder E-Mail',
          aufgaben: [
        SprechenAufgabe(
          partner: 'A',
          title: 'Brief oder E-Mail',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Ich finde es schade, dass viele Menschen nicht mehr mit der Hand '
              'schreiben wollen. Also, ich freue mich immer über einen '
              'handgeschriebenen Brief oder eine Karte, zum Beispiel zum '
              'Geburtstag. Das ist viel persönlicher als eine E-Mail oder eine '
              'Nachricht am Telefon.',
          author: 'Max Bayer (30), Lehrer',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person mag handgeschriebene Briefe, weil …',
            'Ich sehe das ähnlich / anders, weil …',
            'Ich persönlich schreibe (nicht) gern Briefe, weil …',
            'Wie ist das bei dir?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es um Briefe und E-Mails. Max Bayer '
              'findet es schade, dass viele Menschen nicht mehr mit der Hand '
              'schreiben.\n\n'
              'Er freut sich immer über einen handgeschriebenen Brief oder eine '
              'Karte, zum Beispiel zum Geburtstag, weil das viel persönlicher '
              'ist als eine E-Mail oder eine Nachricht am Telefon.\n\n'
              'Ich sehe das ähnlich. Einen handgeschriebenen Brief zu bekommen '
              'ist etwas Besonderes. Man merkt, dass sich jemand Zeit genommen '
              'hat.\n\n'
              'Trotzdem schreibe ich im Alltag meistens Nachrichten, weil es '
              'schneller geht. Wie ist das bei dir – schreibst du noch Briefe?',
        ),
        SprechenAufgabe(
          partner: 'B',
          title: 'Brief oder E-Mail',
          instruction:
              'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
              'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
              'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
              'Thema aus und sprechen Sie dabei über Ihre persönlichen '
              'Meinungen und Erfahrungen.',
          meinung:
              'Briefe schreibe ich nie. Wozu auch? Es dauert viel zu lange, bis '
              'ein Brief endlich ankommt. Eine E-Mail oder eine Nachricht per '
              'Telefon ist sofort beim Empfänger. Da kann ich auch Emojis '
              'benutzen. Briefe finde ich altmodisch.',
          author: 'Tina Klein (35), Pflegerin',
          examples: [
            'In meiner Meinung geht es um …',
            'Die Person schreibt nie Briefe, weil …',
            'Ich sehe das ähnlich / anders, weil …',
            'Aus eigener Erfahrung kann ich sagen, dass …',
            'Und wie ist deine Meinung dazu?',
          ],
          sampleAnswer:
              'In meiner Meinung geht es auch um Briefe und E-Mails, aber Tina '
              'Klein hat eine andere Meinung.\n\n'
              'Sie schreibt nie Briefe. Sie findet, dass es viel zu lange '
              'dauert, bis ein Brief ankommt. Eine E-Mail oder eine Nachricht '
              'per Telefon ist sofort beim Empfänger, und sie kann dabei auch '
              'Emojis benutzen. Briefe findet sie altmodisch.\n\n'
              'Da hat sie in vielen Punkten recht: Digitale Nachrichten sind '
              'schnell und praktisch. Ich benutze sie auch jeden Tag.\n\n'
              'Aber ich finde, ein persönlicher Brief hat trotzdem seinen '
              'Wert. Und wie ist deine Meinung dazu?',
        ),
          ],
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 3,
      title: 'Gemeinsam etwas planen',
      description:
          'Har testda bitta situation beriladi. Gorizontal scroll bilan testni '
          'tanlang va hamkoringiz bilan birgalikda rejalashtiring.',
      tests: [
        SprechenTest(
          thema: 'Einen Ausflug planen',
          aufgaben: [
            SprechenAufgabe(
              title: 'Einen Ausflug planen',
              instruction:
                  'Planen Sie gemeinsam mit Ihrem Partner eine Aktivität (z. B. '
                  'einen Ausflug). Einigen Sie sich auf die Einzelheiten: Wohin? '
                  'Wann? Wie? Was nehmen Sie mit?',
              keywords: [
                'Reiseziel',
                'Datum / Uhrzeit',
                'Verkehrsmittel',
                'Kosten',
                'Essen / Getränke',
                'sich einigen',
              ],
              examples: [
                'Ich würde vorschlagen, dass wir nach … fahren.',
                'Wollen wir mit dem Zug oder mit dem Auto fahren?',
                'Was hältst du davon, wenn wir …?',
                'Das ist eine gute Idee, aber …',
                'Gut, dann einigen wir uns auf … Einverstanden?',
              ],
            ),
          ],
        ),
        ...sprechenB1Teil3Situationen,
      ],
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// B2 — TELC Deutsch B2: 3 Teile
//   Teil 1: Über Erfahrungen berichten / präsentieren
//   Teil 2: Über ein aktuelles Thema diskutieren
//   Teil 3: Gemeinsam eine Lösung / Entscheidung finden
// ─────────────────────────────────────────────────────────────────────────────
const sprechenB2 = SprechenLevel(
  level: 'B2',
  teile: [
    SprechenTeil(
      teilNumber: 1,
      title: 'Präsentation',
      description: 'Bir mavzuni mustaqil ravishda taqdim eting.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Thema: Digitalisierung im Alltag',
          instruction:
              'Halten Sie einen kurzen Vortrag. Beschreiben Sie die aktuelle '
              'Situation, nennen Sie Vor- und Nachteile und geben Sie Ihre '
              'eigene Einschätzung.',
          keywords: [
            'Einleitung',
            'aktuelle Situation',
            'Vorteile',
            'Nachteile',
            'eigene Meinung',
            'Schluss',
          ],
          examples: [
            'Ich möchte heute über … sprechen.',
            'Zunächst möchte ich auf … eingehen.',
            'Einerseits … andererseits …',
            'Ein wesentlicher Vorteil / Nachteil ist …',
            'Abschließend lässt sich sagen, dass …',
          ],
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 2,
      title: 'Diskussion',
      description: 'Dolzarb mavzu bo\'yicha bahslashing va dalil keltiring.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Thema: Umweltschutz im Alltag',
          instruction:
              'Diskutieren Sie mit Ihrem Partner. Vertreten Sie Ihren '
              'Standpunkt mit Argumenten und reagieren Sie auf Gegenargumente.',
          keywords: [
            'Standpunkt',
            'Argument',
            'Gegenargument',
            'Beispiel',
            'Kompromiss',
          ],
          examples: [
            'Ich bin der Ansicht, dass …',
            'Dafür spricht, dass … / Dagegen spricht …',
            'Das mag sein, aber bedenken Sie, dass …',
            'Ein gutes Beispiel dafür ist …',
            'Vielleicht können wir uns darauf einigen, dass …',
          ],
        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 3,
      title: 'Gemeinsam eine Lösung finden',
      description: 'Birgalikda qaror qabul qiling yoki muammoni hal qiling.',
      aufgaben: [
        SprechenAufgabe(
          title: 'Ein Problem lösen',
          instruction:
              'Ihre Firma möchte ein Sommerfest organisieren. Finden Sie '
              'gemeinsam eine Lösung und treffen Sie eine Entscheidung.',
          keywords: [
            'Vorschläge',
            'abwägen',
            'Vor- und Nachteile',
            'Entscheidung',
            'Aufgaben verteilen',
          ],
          examples: [
            'Wie wäre es, wenn wir …?',
            'Das hat den Vorteil, dass …',
            'Wenn wir das vergleichen, dann …',
            'Lassen Sie uns festhalten: …',
            'Gut, dann machen wir es so.',
          ],
        ),
      ],
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// B1 — Teil 3 "Gemeinsam etwas planen": 84 ta situation (test).
// Har test = bitta situation (ko'rsatma) + rejalashtirish nuqtalari (keywords).
// ─────────────────────────────────────────────────────────────────────────────
const List<SprechenTest> sprechenB1Teil3Situationen = [
  SprechenTest(
    thema: 'Geburtstagsfeier (50)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Geburtstagsfeier für Frau Schwarz',
        instruction:
            'Ihre Kollegin Rita Schwarz wird in drei Wochen 50 Jahre alt. Sie hat Sie und andere Kollegen zu der Feier eingeladen. Überlegen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Welches Verkehrsmittel?',
          'Welches Geschenk?',
          'Geld einsammeln?',
          'Überraschung für Frau Schwarz?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Gemeinsam Deutsch lernen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Bekannte zum Deutschlernen einladen',
        instruction:
            'Sie haben einige Bekannte aus Ihrem Deutschkurs am Wochenende zu sich nach Hause eingeladen, weil Sie gemeinsam Deutsch lernen möchten.',
        keywords: [
          'Wann genau?',
          'Welche Bücher?',
          'Welches Lernmaterial? (Computer?)',
          'Essen und Getränke?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Auf Philipp aufpassen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Auf den 6-jährigen Philipp aufpassen',
        instruction:
            'Eine Freundin von Ihnen ist für ein Wochenende in den Urlaub gefahren. Sie und Ihr Gesprächspartner sollen in dieser Zeit auf ihren 6-jährigen Sohn Philipp aufpassen.',
        keywords: [
          'Aktivitäten bei gutem Wetter?',
          'Aktivitäten bei schlechtem Wetter?',
          'Essen und Trinken?',
          'Was tun am Abend?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Überraschungsparty (Lehrerin)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Geburtstagsparty für die Lehrerin',
        instruction:
            'Ihre Deutschlehrerin wird am kommenden Samstag 50 Jahre alt. Ihr Kurs möchte sie mit einer Geburtstagsparty überraschen.',
        keywords: [
          'Wann?',
          'Wo?',
          'Geschenk?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Am letzten Kurstag kochen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Party am letzten Kurstag',
        instruction:
            'Sie wollen am letzten Kurstag in der Schule zusammen feiern. Gemeinsam mit Ihrer Prüfungspartnerin oder Ihrem Prüfungspartner wollen Sie für diese Party etwas kochen.',
        keywords: [
          'Was kochen?',
          'Wer kauft ein?',
          'Getränke?',
          'Weitere Ideen für die Party?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Ausflug am Samstag',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einen Ausflug mit einem Freund planen',
        instruction:
            'Sie wollen mit einem Freund am nächsten Samstag einen Ausflug machen. Planen Sie, was Sie tun möchten.',
        keywords: [
          'Wohin?',
          'Wie lange?',
          'Wie reisen?',
          'Was dort machen?',
          'Was mitnehmen?',
          'Wer kümmert sich um was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hoffest',
    aufgaben: [
      SprechenAufgabe(
        title: 'Am Hoffest teilnehmen',
        instruction:
            'Am nächsten Samstag ist in Ihrem Haus ein Hoffest. Jeder soll etwas dazu beitragen. Sie möchten mit Ihrer Gesprächspartnerin oder Ihrem Gesprächspartner an diesem Hoffest teilnehmen.',
        keywords: [
          'Essen und Trinken?',
          'Wer kauft ein?',
          'Wer bezahlt wie viel?',
          'Ideen für das Fest?',
          'Was machen, wenn es regnet?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Abschiedsfest (Rente)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Kleines Fest zum Renteneintritt',
        instruction:
            'Eine Mitarbeiterin in der Firma, in der Sie arbeiten, geht nächsten Monat in Rente. Ihr Kollege/Ihre Kollegin und Sie möchten sie mit einem kleinen Fest überraschen.',
        keywords: [
          'Wann?',
          'Wo?',
          'Geschenk?',
          'Eine andere Überraschung?',
          'Wer wird eingeladen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Geschenk für die Lehrerin',
    aufgaben: [
      SprechenAufgabe(
        title: 'Dankeschön-Geschenk organisieren',
        instruction:
            'Ihre Klasse möchte zum Abschluss Ihres Deutschkurses Ihrer Lehrerin/Ihrem Lehrer ein Geschenk als Dankeschön machen. Sie und Ihr Gesprächspartner sollen das Geschenk gemeinsam organisieren.',
        keywords: [
          'Was für ein Geschenk?',
          'Was gefällt der Lehrerin/dem Lehrer?',
          'Wann das Geschenk geben?',
          'Wer bezahlt was?',
          'Wer macht was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Einweihungsparty',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einweihungsparty feiern',
        instruction:
            'Sie sind in eine neue Wohnung gezogen und wollen eine Einweihungsparty feiern.',
        keywords: [
          'Wann?',
          'Wie viele Leute?',
          'Essen und Trinken?',
          'Nachbarn?',
          'Wer macht was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Heimatland vorstellen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Präsentation über das Heimatland',
        instruction:
            'Sie sollen in Ihrem Deutschkurs Ihr Heimatland vorstellen. Planen Sie gemeinsam die Präsentation.',
        keywords: [
          'Wo treffen Sie sich?',
          'Wann treffen Sie sich?',
          'Wo finden Sie Informationen?',
          'Wer besorgt welche Informationen?',
          'Brauchen Sie Fotos, Musik, Essen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Abschiedsparty (Kursende)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Abschiedsparty zum Kursende',
        instruction:
            'Sie möchten zum Ende Ihres Deutschkurses eine Abschiedsparty feiern. Planen Sie das Fest.',
        keywords: [
          'Wo soll das Fest stattfinden?',
          'Wann soll das Fest sein?',
          'Organisieren Sie Essen und Getränke?',
          'Brauchen Sie Musik?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Grillen am Wochenende',
    aufgaben: [
      SprechenAufgabe(
        title: 'Grillen mit Freunden',
        instruction:
            'Sie wollen am Wochenende mit Freunden grillen. Planen Sie gemeinsam mit Ihrer Gesprächspartnerin/Ihrem Gesprächspartner, was Sie tun müssen.',
        keywords: [
          'Wo?',
          'Wann?',
          'Was grillen?',
          'Wie viele Leute?',
          'Getränke?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Jubiläum der Sprachschule',
    aufgaben: [
      SprechenAufgabe(
        title: '10-jähriges Jubiläum feiern',
        instruction:
            'Sie machen zusammen einen Deutschkurs an einer kleinen Sprachschule. Die Sprachschule hat bald 10-jähriges Jubiläum. Deshalb soll es ein großes Fest geben. Sie organisieren zusammen, was Ihr Kurs für dieses Fest macht.',
        keywords: [
          'Essen?',
          'Getränke?',
          'Programm?',
          'Musik?',
          'Wer macht was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Beim Umzug helfen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Umzug einer Familie organisieren',
        instruction:
            'Eine befreundete Familie mit zwei kleinen Kindern zieht in eine neue Wohnung. Sie haben versprochen, beim Umzug zu helfen. Sie organisieren zusammen mit Ihrer Gesprächspartnerin oder Ihrem Gesprächspartner den Umzug.',
        keywords: [
          'Termin?',
          'Transportmittel: Auto/Lkw?',
          'Wer kann noch helfen?',
          'Essen/Getränke für die Helfer?',
          'Wer kümmert sich um die Kinder?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hausfest',
    aufgaben: [
      SprechenAufgabe(
        title: 'Ein Hausfest planen',
        instruction:
            'Sie möchten mit Ihrer Partnerin/Ihrem Partner an einem der nächsten Wochenenden ein Hausfest machen. Planen Sie, was Sie tun möchten.',
        keywords: [
          'Wo?',
          'Essen und Trinken?',
          'Wann?',
          'Einladungen schreiben',
          'Andere Ideen',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Geburtstag im Büro (30)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Kleines Fest am Feierabend',
        instruction:
            'Sie arbeiten zusammen mit Ihrer Gesprächspartnerin oder Ihrem Gesprächspartner in einer kleinen Firma. Nächste Woche hat eine Kollegin ihren dreißigsten Geburtstag. Sie möchten am Feierabend ein kleines Fest für sie organisieren.',
        keywords: [
          'Wo feiern?',
          'Geschenk?',
          'Essen und Getränke?',
          'Wen einladen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hochzeit in Neuburg',
    aufgaben: [
      SprechenAufgabe(
        title: 'Zur Hochzeit nach Neuburg fahren',
        instruction:
            'Sie sind beide am folgenden Wochenende zu einer Hochzeitsfeier eingeladen. Die Hochzeit findet in Neuburg statt, das etwa 100 km von Ihnen entfernt liegt. Sie waren noch nie in Neuburg und kennen sich nicht aus.',
        keywords: [
          'Verkehrsmittel?',
          'Stadtplan?',
          'Geschenk?',
          'Kleidung?',
          'Treffpunkt?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kursabschlussparty',
    aufgaben: [
      SprechenAufgabe(
        title: 'Kursabschlussparty organisieren',
        instruction:
            'Sie möchten in Ihrem Deutschkurs eine Kursabschlussparty feiern. Sie sollen diese Party organisieren.',
        keywords: [
          'Wo?',
          'Essen/Getränke?',
          'Was brauchen Sie noch (Musik, Spiele …)?',
          'Wer bezahlt dafür?',
          'Wer macht was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Abschiedsparty (Kollegin)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Abschiedsparty für eine Kollegin',
        instruction:
            'Eine Arbeitskollegin wird in einer anderen Firma arbeiten. Sie haben die Aufgabe, zusammen mit Ihrer Prüferin/Ihrem Prüfer eine Abschiedsparty für diese Kollegin zu organisieren. Überlegen Sie, was alles zu tun ist und wer welche Aufgaben übernimmt.',
        keywords: [
          'Wo?',
          'Wann?',
          'Essen und Getränke?',
          'Wer bezahlt dafür?',
          'Wer wird eingeladen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Klassenfahrt',
    aufgaben: [
      SprechenAufgabe(
        title: 'Eine Klassenfahrt planen',
        instruction:
            'Mit deiner Schulklasse und deinem Lehrer möchtet ihr eine Klassenfahrt machen. Es ist aber noch nicht klar, wohin die Fahrt gehen soll. Du sollst gemeinsam mit deinem Gesprächspartner Vorschläge für die Reise machen.',
        keywords: [
          'Wohin? (Stadt/Land …)',
          'Wann/Wie lange?',
          'Übernachten',
          'Kosten',
          'Abendprogramm',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kinder betreuen (6 und 10)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Ein Wochenende auf Kinder aufpassen',
        instruction:
            'Sie und Ihre Gesprächspartnerin/Ihr Gesprächspartner wollen die Kinder von Freunden (6 und 10 Jahre alt) ein Wochenende lang betreuen. Überlegen Sie zusammen, was Sie mit den Kindern unternehmen können und wer welche Aufgaben übernimmt.',
        keywords: [
          'Was am Samstag?',
          'Was am Sonntag?',
          'Wenn es regnet/wenn die Sonne scheint?',
          'Vorher einkaufen?',
          'Essen und Trinken?',
          'Was tun am Abend?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Neue Möbel kaufen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Gemeinsam neue Möbel kaufen',
        instruction:
            'Sie und Ihre Partnerin/Ihr Partner wollen neue Möbel kaufen. Sie haben sich schon Notizen gemacht. Besprechen Sie folgende Punkte.',
        keywords: [
          'Termin?',
          'Wohin?',
          'Was?',
          'Hilfe?',
          'Transport?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Gesünder leben',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einen Plan für ein gesünderes Leben machen',
        instruction:
            'Sie und Ihre Partnerin/Ihr Partner haben immer sehr viel Stress. Sie möchten gesünder leben. Machen Sie zusammen einen Plan. Machen Sie Vorschläge und reagieren Sie auf die Vorschläge Ihrer Partnerin/Ihres Partners.',
        keywords: [
          'Was wollen Sie genau machen?',
          'Sport? (Was? Wann?)',
          'Gesundes Essen (Was?)',
          'Entspannung? (Was? Wann?)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Gesünder leben (Plan)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Weniger Stress – gesünder leben',
        instruction:
            'Sie und Ihre Partnerin haben immer sehr viel Stress. Sie möchten gesünder leben. Machen Sie zusammen einen Plan.',
        keywords: [
          'Sport (Was? Wann?)',
          'Gesund essen (Was?)',
          'Entspannung (Was? Wann?)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hochzeit in Neuburg (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Hochzeit einer Kursteilnehmerin',
        instruction:
            'Sie sind mit Ihrem Gesprächspartner am Wochenende zu der Hochzeitsfeier einer Kursteilnehmerin eingeladen. Die Hochzeit findet in Neuburg statt, das etwa 100 km von Ihnen entfernt ist. Sie waren noch nie in Neuburg und kennen sich nicht aus.',
        keywords: [
          'Verkehrsmittel',
          'Stadtplan kaufen',
          'Geschenk',
          'Kleidung',
          'Treffpunkt',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Veranstaltung Umweltschutz',
    aufgaben: [
      SprechenAufgabe(
        title: 'Veranstaltung zum Umweltschutz',
        instruction:
            'Sie müssen in Ihrem Kurs eine Veranstaltung zum Thema "Umweltschutz" organisieren. Sprechen Sie mit Ihrem Partner/Ihrer Partnerin und planen Sie die Veranstaltung.',
        keywords: [
          'Wo?',
          'Wann?',
          'Themen',
          'Plakate',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Probleme in Mathematik',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einem Kind in Mathe helfen',
        instruction:
            'Der Sohn Ihrer Freundin hat Probleme in Mathematik. Besprechen Sie mit Ihrem/Ihrer Partner/in, wie Sie ihr helfen können.',
        keywords: [
          'Welches Problem?',
          'Nachhilfe',
          'Beratung',
          'Andere Lösung',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Wasserschaden im Haus',
    aufgaben: [
      SprechenAufgabe(
        title: 'Haus voller Wasser nach Regen',
        instruction:
            'Es hat geregnet und das Haus eines Freundes ist voller Wasser. Sie müssen etwas dagegen unternehmen und dem Freund ein paar Tipps geben, was man tun kann.',
        keywords: [
          'Versicherung',
          'Wer muss das Geld für den Schaden bezahlen?',
          'Putzen, aufräumen',
          'Neue Sachen kaufen',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Ausflug am Samstag (Kurs)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Ausflug mit dem Kurs planen',
        instruction:
            'Ihr Kurs möchte am Samstag einen Ausflug machen. Sie und Ihr Gesprächspartner/Ihre Gesprächspartnerin müssen den Ausflug planen.',
        keywords: [
          'Wohin?',
          'Womit?',
          'Essen/Getränke',
          'Was machen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Krankenhausbesuch',
    aufgaben: [
      SprechenAufgabe(
        title: 'Verunglückten Teilnehmer unterstützen',
        instruction:
            'Ein Teilnehmer aus dem Deutschkurs hatte einen Unfall und liegt im Krankenhaus. Diese Woche möchten Sie ihn besuchen und ein Geschenk von der ganzen Gruppe mitbringen. Nächste Woche kann er das Krankenhaus verlassen; da er allein lebt, wird er Hilfe brauchen. Überlegen Sie, wie Sie ihn unterstützen können.',
        keywords: [
          'Wann geht ihr ihn besuchen? (Tag, Uhrzeit?)',
          'Wie kommt ihr dort hin?',
          'Was werdet ihr mitbringen?',
          'Wie kann man helfen? (abholen, einkaufen)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Krankenhausbesuch (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Gemeinsam etwas planen – Krankenhaus',
        instruction:
            'Ein Teilnehmer aus dem Deutschkurs hatte einen Unfall und liegt im Krankenhaus. Diese Woche möchten Sie ihn besuchen und ein Geschenk von der ganzen Gruppe mitbringen. Nächste Woche kann er das Krankenhaus verlassen; da er allein lebt, wird er Hilfe brauchen. Überlegen Sie, wie Sie ihn unterstützen können.',
        keywords: [
          'Wann geht ihr ihn besuchen? (Tag, Uhrzeit?)',
          'Wie kommt ihr dort hin?',
          'Was werdet ihr mitbringen?',
          'Wie kann man helfen? (abholen, einkaufen)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hoffest (Notizen)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Beitrag zum Hoffest',
        instruction:
            'Am nächsten Samstag ist in Ihrem Haus ein Hoffest. Jeder soll etwas dazu beitragen. Sie möchten zusammen an diesem Hoffest teilnehmen. Planen Sie, was Sie tun möchten.',
        keywords: [
          'Essen/Getränke?',
          'Wer kauft ein?',
          'Wer bezahlt wie viel?',
          'Ideen für das Fest?',
          'Was machen Sie, wenn es regnet?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Grillen (Notizen)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Grillen am Wochenende planen',
        instruction:
            'Sie wollen am Wochenende mit Freunden grillen. Planen Sie gemeinsam, was Sie tun müssen.',
        keywords: [
          'Wo?',
          'Wann?',
          'Was?',
          'Was grillen?',
          'Wie viele Leute?',
          'Getränke?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Umzug helfen (Notizen)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Umzug einer Familie planen',
        instruction:
            'Eine befreundete Familie mit zwei kleinen Kindern zieht in eine neue Wohnung. Sie haben versprochen, beim Umzug zu helfen. Sie organisieren zusammen den Umzug. Planen Sie, was Sie tun müssen.',
        keywords: [
          'Termin?',
          'Transportmittel: Lkw/Pkw?',
          'Wer kann noch helfen?',
          'Essen/Getränke für die Helfer?',
          'Wer kümmert sich um die Kinder?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kinderbetreuung finden',
    aufgaben: [
      SprechenAufgabe(
        title: 'Betreuung für eine 2-jährige Tochter',
        instruction:
            'Ihre Freundin möchte arbeiten gehen. Sie hat eine 2-jährige Tochter. Sie wollen ihr helfen, eine Kinderbetreuung zu finden.',
        keywords: [
          'Von wann bis wann?',
          'Wo?',
          'Alter der Kinder?',
          'Wie viel bezahlen?',
          'Essen/Trinken?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Freunde zum Essen einladen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Am Samstagabend kochen',
        instruction:
            'Sie wollen am Samstagabend etwas zusammen kochen und haben zum Essen Freunde zu sich nach Hause eingeladen. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Was kochen?',
          'Wer kauft ein?',
          'Getränke?',
          'Wer bezahlt?',
          'Nach dem Essen: etwas gemeinsam unternehmen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Wiedersehen (VHS)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Ein Wiedersehen organisieren',
        instruction:
            'Sie wollen gemeinsam ein Wiedersehen mit anderen Kursteilnehmerinnen und Kursteilnehmern aus Ihrer VHS planen. Der Kurs ist schon vor einem Jahr beendet. Sie sollen ein Wiedersehen organisieren. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Wann? Wo?',
          'Wie finden Sie Adressen?',
          'Wie kommen Sie zum Treffpunkt?',
          'Wie viel darf alles kosten?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Austauschschüler aus Spanien',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einen Gastschüler aufnehmen',
        instruction:
            'Ihre Bekannte hat eine Tochter im Alter von 16 Jahren. Nächsten Monat kommt eine Schulklasse aus Spanien nach Deutschland und ein Schüler soll bei Ihrer Bekannten wohnen. Helfen Sie Ihrer Bekannten bei der Planung. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Wer? (Junge, Mädchen, Alter …)',
          'Wie lange bleibt er/sie?',
          'Tagesablauf? (Schule, Freizeit, …)',
          'Aktivitäten? (Sport, Kino, Ausflüge, …)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hilfe bei Krankenhausaufenthalt',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einer Teilnehmerin im Krankenhaus helfen',
        instruction:
            'Eine Teilnehmerin aus Ihrem Kurs muss nach einem Unfall eine Woche im Krankenhaus bleiben und braucht Ihre Hilfe. Planen Sie gemeinsam, was Sie tun.',
        keywords: [
          'Wohnungsschlüssel?',
          'Blumen und den Hund versorgen?',
          'Besuch im Krankenhaus (wie oft? Wer geht mit? Sachen bringen)?',
          'Post (Briefkasten leeren, Briefe bringen, Pakete annehmen)',
          'Eine Überraschung nach der Entlassung',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Deutsches Fernsehen schauen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Gemeinsam Fernsehen schauen',
        instruction:
            'Sie möchten zusammen deutsches Fernsehen schauen. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Wann? Wo?',
          'Was möchten Sie sehen (Nachrichten, Filme …)? Warum?',
          'Fernsehprogramm woher? (Fernsehzeitung, Internet …)',
          'Wie lange fernsehen?',
          'Was brauchen Sie noch? (Hi-Fi, Wörterbuch …)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Deutsch üben',
    aufgaben: [
      SprechenAufgabe(
        title: 'Gemeinsam Deutsch üben',
        instruction:
            'Sie beide möchten gemeinsam Deutsch üben. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Zeit(en)?',
          'Ort?',
          'Thema (schreiben, sprechen, Grammatik …)',
          'Eine Deutsche/Ein Deutscher: Gesprächspartner, Hilfe …?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Weiter Deutsch lernen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Nach dem Kurs weiterlernen',
        instruction:
            'Ihr Kurs ist zu Ende, aber Sie beide möchten weiter Deutsch lernen. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Wann (Tag/Uhrzeit)?',
          'Wie lange?',
          'Wo (zu Hause, Café …)?',
          'Was mitnehmen (Bücher, CDs …)?',
          'Wie lernen (Wörter erklären, Aufgaben üben)?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Besuch im Tierpark',
    aufgaben: [
      SprechenAufgabe(
        title: 'In den Tierpark gehen',
        instruction:
            'Sie möchten in einen Tierpark gehen. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Wann (Tag/Uhrzeit)?',
          'Anreise (Bus, Auto …)?',
          'Wen mitnehmen?',
          'Wo essen und trinken?',
          'Was noch mitnehmen (Fotoapparat …)?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kaputte Fenster reparieren',
    aufgaben: [
      SprechenAufgabe(
        title: 'Kaputte Fenster bei der Freundin',
        instruction:
            'In der Wohnung Ihrer Freundin sind Fenster kaputt. Sie hat zwei kleine Kinder. Sie bittet Sie, ihr zu helfen. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Welche Probleme? (Gesundheit, Lärm, niedrige Temperatur …)',
          'Wer soll reparieren (selbst, Vermieter, Handwerker …)?',
          'Wie Bescheid sagen (anrufen, per E-Mail …)?',
          'Wann Reparatur?',
          'Wer bezahlt?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Defekte Eingangstür',
    aufgaben: [
      SprechenAufgabe(
        title: 'Eingangstür schließt nicht',
        instruction:
            'Sie wohnen im Mietshaus in verschiedenen Stockwerken. Seit drei Wochen geht die Eingangstür nicht richtig zu. Sie möchten etwas dagegen unternehmen. Planen Sie gemeinsam, was Sie tun möchten.',
        keywords: [
          'Wem Bescheid sagen (Hausmeister, Vermieter …)?',
          'Anrufen, schreiben oder faxen?',
          'Was sagen/schreiben/faxen?',
          'Andere Nachbarn informieren?',
          'Was tun, wenn nichts passiert?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kinderbetreuung im Haus',
    aufgaben: [
      SprechenAufgabe(
        title: 'Betreuung für viele Kinder im Haus',
        instruction:
            'Sie wohnen in einem mehrstöckigen Haus. In Ihrem Haus wohnen viele Familien mit kleinen Kindern. Sie wollen für die Kinder eine Kinderbetreuung organisieren.',
        keywords: [
          'Von wann bis wann?',
          'Alter der Kinder?',
          'Wie viel bezahlen?',
          'Essen/Trinken?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Einweihungsparty (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einweihungsparty in der neuen Wohnung',
        instruction:
            'Sie sind in eine Wohnung gezogen und wollen eine Einweihungsparty feiern. Überlegen Sie gemeinsam.',
        keywords: [
          'Wann?',
          'Wie viele Leute?',
          'Essen und Trinken?',
          'Nachbarn?',
          'Wer macht was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Museumsbesuch',
    aufgaben: [
      SprechenAufgabe(
        title: 'Museumsbesuch vorbereiten',
        instruction:
            'Ihr Deutschkurs will ein Museum in der Stadt besuchen. Sie sollen zusammen den Besuch vorbereiten.',
        keywords: [
          'Passende Termine',
          'Treffpunkt und Uhrzeit',
          'Dauer des Besuchs',
          'Kosten für Eintritt und Führung',
          'Fotos machen',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Wochenendreise (Kurs)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Übers Wochenende wegfahren',
        instruction:
            'Ihr Kurs will gemeinsam über ein Wochenende wegfahren. Planen Sie die Reise!',
        keywords: [
          'Wann? (Tag der Abreise, Rückkehr?)',
          'Wohin?',
          'Womit reisen?',
          'Was machen?',
          'Wo schlafen und essen?',
          'Wie lange?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Stadtausflug',
    aufgaben: [
      SprechenAufgabe(
        title: 'Ausflug in eine Stadt in der Nähe',
        instruction:
            'Sie möchten mit Ihrem Partner/Ihrer Partnerin einen Ausflug in eine Stadt in Ihrer Nähe unternehmen.',
        keywords: [
          'Wann?',
          'Wie werden Sie fahren?',
          'Essen und Trinken?',
          'Was machen Sie dort?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kaputte Haustür',
    aufgaben: [
      SprechenAufgabe(
        title: 'Außentür schließt nicht',
        instruction:
            'Die Außentür des Hauses ist kaputt, deshalb schließt sie nicht. Was können Sie mit Ihren Nachbarn tun, um das Problem zu lösen?',
        keywords: [
          'Informieren Sie den Vermieter oder Hausmeister.',
          'Senden Sie eine E-Mail oder telefonieren Sie.',
          'Sollten Sie auch die Nachbarn informieren?',
          'Was machen Sie, wenn die Situation nicht gelöst ist?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Ausflug machen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Ausflug am nächsten Samstag',
        instruction:
            'Sie wollen mit einem Freund am nächsten Samstag einen Ausflug machen. Planen Sie, was Sie tun möchten.',
        keywords: [
          'Wohin? (Natur/See/Stadt)',
          'Wie lange? Wann zurück? Wann treffen?',
          'Wie reisen? (Fahrrad, Zug, Auto – Vorteile/Nachteile)',
          'Was dort machen? (besichtigen, Picknick, wandern, schwimmen)',
          'Was mitnehmen? Wer besorgt was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Urlaubsreise (Europa)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Urlaub in einem europäischen Land',
        instruction:
            'Sie haben bald Ferien und möchten gemeinsam mit Ihrem Gesprächspartner eine Urlaubsreise in ein europäisches Land machen. Planen Sie Ihren gemeinsamen Urlaub.',
        keywords: [
          'Welches Land? Warum?',
          'Verkehrsmittel? (Auto, Flugzeug, Bahn …)',
          'Urlaubsdauer?',
          'Übernachtungen? (Hotel reservieren?)',
          'Was mitnehmen? (Fotokamera, Kleidung …)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Heimatland erzählen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Über das Heimatland erzählen',
        instruction:
            'Ihr Kursleiter hat jeden Kursteilnehmer gebeten, etwas über sein/ihr Heimatland zu erzählen. Planen Sie mit Ihrem Gesprächspartner, was Sie über Ihr Heimatland sagen möchten.',
        keywords: [
          'Kultur und Musik? Sehenswürdigkeiten?',
          'Informationen über das Land (Größe, Lage, Einwohner …)?',
          'Etwas mitbringen (Fotos, Souvenirs, Essen …)',
          'Besonderheiten, z. B. Sprichwörter',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kranker Freund (Tipps)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Gesundheitstipps für einen Freund',
        instruction:
            'Ein anderer Teilnehmer aus Ihrem Deutschkurs ist oft erkältet. Deshalb fehlt er häufig im Unterricht. Sie möchten ihm helfen und ein paar Tipps geben. Besprechen Sie gute Gesundheitstipps für Ihren Freund.',
        keywords: [
          'Essen und Getränke?',
          'Ruhe oder Bewegung? (spazieren gehen, Sport …)',
          'Medikamente oder Hausmittel?',
          'Wann zum Arzt?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Stadtausflug für Neuen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einem neuen Teilnehmer die Stadt zeigen',
        instruction:
            'Sie haben im Kurs einen neuen Teilnehmer, der sich in Ihrer Stadt nicht auskennt. Sie möchten mit ihm einen Stadtausflug machen und ihm wichtige Orte zeigen. Planen Sie den gemeinsamen Stadtausflug.',
        keywords: [
          'Sehenswürdigkeiten / kulturelle Orte (Markt, Dom …)',
          'Verkehrsverbindungen (Busbahnhof, Bahnhof …)',
          'Ämter und Behörden (Jobcenter, Ausländeramt …)',
          'Bibliothek / Bücherei',
          'Lebensmittel (Supermarkt, Drogerie …)',
          'Freizeitmöglichkeiten (Park, Kino, Eiscafé …)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Einladen und kochen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Freunde einladen und kochen',
        instruction:
            'Sie und Ihr Gesprächspartner möchten Freunde am Samstag einladen und kochen.',
        keywords: [
          'Welches Essen und Getränke?',
          'Wer wird eingeladen?',
          'Wie viele Personen maximal?',
          'Wann treffen Sie sich?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kranker Freund (Tipps 2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Tipps gegen häufige Erkältung',
        instruction:
            'Ein anderer Teilnehmer aus Ihrem Deutschkurs ist oft erkältet. Deshalb fehlt er häufig im Unterricht. Sie möchten ihm helfen und ein paar Tipps geben. Besprechen Sie gute Gesundheitstipps für Ihren Freund.',
        keywords: [
          'Essen und Getränke?',
          'Ruhe oder Bewegung? (spazieren gehen, Sport …)',
          'Medikamente oder Hausmittel?',
          'Wann zum Arzt?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Renovieren helfen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einem Mitschüler beim Renovieren helfen',
        instruction:
            'Ein Mitschüler von Ihnen renoviert seine Wohnung. Sie möchten ihm helfen. Planen Sie zusammen mit Ihrer Partnerin/Ihrem Partner die Renovierung.',
        keywords: [
          'Wann?',
          'Wohin?',
          'Was renovieren?',
          'Was mitbringen?',
          'Treffpunkt?',
          'Wer hilft mit?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Renovieren helfen (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Renovierung der Wohnung planen',
        instruction:
            'Ein Mitschüler von Ihnen renoviert seine Wohnung. Sie möchten ihm helfen. Planen Sie zusammen mit Ihrer Partnerin/Ihrem Partner die Renovierung.',
        keywords: [
          'Wann?',
          'Wohin?',
          'Was renovieren?',
          'Was mitbringen?',
          'Treffpunkt?',
          'Wer hilft mit?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Freund im Krankenhaus besuchen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Besuch nach einer Operation',
        instruction:
            'Sie und Ihr Gesprächspartner haben einen Freund, der nach einer Operation im Krankenhaus liegt. Sie beide möchten ihn besuchen. Planen Sie den Besuch im Krankenhaus.',
        keywords: [
          'Wann haben Sie Zeit?',
          'Treffpunkt: Wann und wo?',
          'Welches Lieblingsessen mitbringen?',
          'Welches Getränk mitbringen?',
          'Blumen oder Geschenk kaufen?',
          'Wer könnte auch mitkommen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kindergeburtstag',
    aufgaben: [
      SprechenAufgabe(
        title: 'Kindergeburtstagsparty organisieren',
        instruction:
            'Ihre Kinder sind beide im Kindergarten und haben am selben Tag Geburtstag. Sie sollen bei der Organisation der Kindergeburtstagsparty helfen. Überlegen Sie, was man machen könnte und wer welche Aufgaben übernimmt.',
        keywords: [
          'Zeit / Ort? (zu Hause, Tierpark, Spielplatz …)',
          'Zahl der Gäste (nur Kinder oder auch Erwachsene?)',
          'Was für Spiele?',
          'Essen und Trinken?',
          'Worauf muss man achten?',
          'Wie kommen die Gäste nach Hause?',
          'Geschenk?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Freund im Krankenhaus besuchen (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Krankenbesuch nach einer Operation',
        instruction:
            'Sie und Ihr Gesprächspartner haben einen Freund, der nach einer Operation im Krankenhaus liegt. Sie beide möchten ihn besuchen. Planen Sie den Besuch im Krankenhaus.',
        keywords: [
          'Wann haben Sie Zeit?',
          'Treffpunkt: Wann und wo?',
          'Welches Lieblingsessen mitbringen?',
          'Welches Getränk mitbringen?',
          'Blumen oder Geschenk kaufen?',
          'Wer könnte auch mitkommen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Etwas unternehmen / wegfahren',
    aufgaben: [
      SprechenAufgabe(
        title: 'Übers Wochenende etwas unternehmen',
        instruction:
            'Sie möchten mit Ihrem Partner etwas unternehmen oder übers Wochenende wegfahren. Planen Sie zusammen, was Sie tun möchten bzw. wohin Sie fahren möchten.',
        keywords: [
          'Wann?',
          'Wohin?',
          'Wie fahren?',
          'Wie lange?',
          'Andere Leute?',
          'Was mitnehmen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Umzug helfen (Freund)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Einem Freund beim Umzug helfen',
        instruction:
            'Sie und Ihr Gesprächspartner haben einen Freund, der nächste Woche in eine neue Wohnung umzieht. Sie beide möchten ihm helfen, weil er darum gebeten hat. Planen Sie, wie Sie ihm beim Umzug helfen möchten.',
        keywords: [
          'Was tun: alte Wohnung?',
          'Was tun: neue Wohnung?',
          'Sperrmüll',
          'Neue Möbel',
          'Geschenk',
          'Wer kann noch helfen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Geburtstagsparty besuchen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Zur Geburtstagsparty eines Bekannten',
        instruction:
            'Ihr Bekannter lädt Sie zu seinem Geburtstag ein. Sie möchten ihn gemeinsam mit Ihrem Gesprächspartner besuchen. Planen Sie den Besuch der Geburtstagsparty.',
        keywords: [
          'Treffpunkt?',
          'Wie hinkommen?',
          'Welches Geschenk?',
          'Andere Personen mitbringen?',
          'Welche Kleidung?',
          'Hilfe?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Katzen versorgen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Sich um die Katzen kümmern',
        instruction:
            'Ihre Freundin muss für eine Woche nach Berlin fahren. Sie hat Sie gefragt, ob Sie sich in dieser Zeit um ihre Katzen kümmern können. Planen Sie mit Ihrem Gesprächspartner, was zu tun ist.',
        keywords: [
          'Futter? Wo kaufen? (Tiergeschäft, Supermarkt …)',
          'Wie oft hingehen?',
          'Spielzeug?',
          'Katzentoilette pflegen (sauber machen, neuer Sand …)',
          'Wie lange bei den Katzen bleiben?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Katzen versorgen (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Eine Woche auf die Katzen aufpassen',
        instruction:
            'Ihre Freundin muss für eine Woche nach Berlin fahren. Sie hat Sie gefragt, ob Sie sich in dieser Zeit um ihre Katzen kümmern können. Planen Sie mit Ihrem Gesprächspartner, was zu tun ist.',
        keywords: [
          'Futter? Wo kaufen? (Tiergeschäft, Supermarkt …)',
          'Wie oft hingehen?',
          'Spielzeug?',
          'Katzentoilette pflegen (sauber machen, neuer Sand …)',
          'Wie lange bei den Katzen bleiben?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Freund Samer abholen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Samer vom Flughafen abholen',
        instruction:
            'Ihr Freund Samer kommt in den nächsten Tagen nach Deutschland, um Sie für ein paar Tage zu besuchen. Sie sollen ihn vom Flughafen abholen und sich um ihn kümmern. Planen Sie gemeinsam, was Sie für Samer machen möchten.',
        keywords: [
          'Ankunftsdatum und -zeit',
          'Welcher Flughafen?',
          'Verkehrsmittel?',
          'Dauer des Besuchs',
          'Wo übernachten? (zu Hause, Hotel …)',
          'Was kann man mit Samer machen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Wasserschaden (Freund helfen)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Hilfe bei einem Wasserschaden',
        instruction:
            'Sie und Ihr Gesprächspartner haben einen Freund, der einen Wasserschaden in seiner Wohnung hatte. Sie beide möchten ihm helfen, weil er darum gebeten hat. Planen Sie, wie Sie Ihrem Freund helfen möchten.',
        keywords: [
          'Termin beim Hausmeister vereinbaren',
          'Versicherung informieren',
          'Sperrmüll',
          'Neue Möbel',
          'Renovierung',
          'Wer kann noch helfen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Nachhilfe in Mathematik',
    aufgaben: [
      SprechenAufgabe(
        title: 'Lösung für Mathe-Probleme finden',
        instruction:
            'Ihre Kinder haben Probleme im Fach Mathematik. Sie und Ihr Gesprächspartner möchten ihnen helfen und eine Lösung finden. Planen Sie, was Sie tun können.',
        keywords: [
          'Nachhilfeunterricht?',
          'Nachhilfelehrer (privat, in der Schule …)',
          'Wo suchen? (Internet, Zeitung …)',
          'Wen noch fragen? (Freunde, Klassenlehrer …)',
          'Weitere Lösungsideen? (Übungsbuch, YouTube …)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hoffest (Dekoration)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Beitrag und Dekoration für das Hoffest',
        instruction:
            'Am nächsten Samstag ist in Ihrem Haus ein Hoffest. Jeder soll etwas dazu beitragen. Sie möchten mit Ihrem Gesprächspartner an diesem Hoffest teilnehmen. Planen Sie, was Sie für das Hoffest tun möchten.',
        keywords: [
          'Essen und Trinken?',
          'Wer kauft ein?',
          'Wer bezahlt wie viel?',
          'Ideen für das Fest? (Dekoration, Lichter, Musik …)',
          'Was machen, wenn es regnet? (im Haus, Zelt mieten …)',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Gemeinsam Deutsch lernen (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Gemeinsames Lernen planen',
        instruction:
            'Sie haben einige Bekannte aus Ihrem Deutschkurs am Wochenende zu sich nach Hause eingeladen, weil Sie gemeinsam Deutsch lernen möchten. Planen Sie das gemeinsame Lernen.',
        keywords: [
          'Wann genau (Tag, Uhrzeit …)?',
          'Welche Bücher (Kursbuch, Grammatik …)?',
          'Welches Lernmaterial? (Computer, Übungen …)',
          'Essen und Getränke?',
          'Wen einladen?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Einweihungsparty (3)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Neue Wohnung feiern',
        instruction:
            'Sie sind in eine neue Wohnung gezogen und wollen eine Einweihungsparty feiern.',
        keywords: [
          'Wann?',
          'Wie viele Leute?',
          'Essen und Trinken?',
          'Nachbarn?',
          'Wer macht was?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Auf Philipp aufpassen (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Aufgaben für das Aufpassen verteilen',
        instruction:
            'Eine Freundin von Ihnen ist für ein Wochenende in den Urlaub gefahren. Sie und Ihr Gesprächspartner sollen in dieser Zeit auf ihren 6-jährigen Sohn Philipp aufpassen. Überlegen Sie gemeinsam, was zu tun ist und wer welche Aufgaben übernimmt.',
        keywords: [
          'Was tun? Aktivitäten?',
          'Aktivitäten bei gutem Wetter (Spielplatz, Park …)?',
          'Aktivitäten bei schlechtem Wetter (Film, Brettspiele …)?',
          'Essen und Trinken?',
          'Was tun am Abend?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Abschiedsparty (Kursende 2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Abschiedsparty zum Kursende',
        instruction:
            'Sie möchten zum Ende Ihres Deutschkurses eine Abschiedsparty feiern. Planen Sie das Fest.',
        keywords: [
          'Wo soll das Fest stattfinden?',
          'Wann soll das Fest sein?',
          'Organisieren Sie Essen und Getränke?',
          'Brauchen Sie Musik?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Grillparty',
    aufgaben: [
      SprechenAufgabe(
        title: 'Grillparty mit Freunden',
        instruction:
            'Sie wollen am Wochenende mit Freunden grillen. Planen Sie gemeinsam mit Ihrer Gesprächspartnerin/Ihrem Gesprächspartner, was Sie tun müssen.',
        keywords: [
          'Wo?',
          'Wann?',
          'Was grillen?',
          'Wie viele Leute?',
          'Getränke?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Grillparty (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Grillparty organisieren',
        instruction:
            'Sie wollen am Wochenende mit Freunden grillen. Planen Sie gemeinsam mit Ihrer Gesprächspartnerin/Ihrem Gesprächspartner, was Sie tun müssen.',
        keywords: [
          'Was kochen?',
          'Wer kauft ein?',
          'Essen und Getränke?',
          'Wer bezahlt?',
          'Musik?',
          'Weitere Ideen für die Party?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Hochzeit in Neuburg (3)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Hochzeitsfeier in Neuburg',
        instruction:
            'Sie sind beide am folgenden Wochenende zu der Hochzeitsfeier eingeladen. Die Hochzeit findet in Neuburg statt, das etwa 100 km von Ihnen entfernt liegt. Sie waren noch nie in Neuburg und kennen sich nicht aus.',
        keywords: [
          'Verkehrsmittel: Womit fahren wir?',
          'Stadtplan: Wo kaufen wir einen?',
          'Geschenk: Was kaufen wir?',
          'Kleidung: Was ziehen wir an?',
          'Treffpunkt: Wo und wann treffen wir uns?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Küche renovieren',
    aufgaben: [
      SprechenAufgabe(
        title: 'Beim Renovieren der Küche helfen',
        instruction:
            'Ein Bekannter aus Ihrem Integrationskurs will seine Küche renovieren und braucht Ihre Hilfe. Entscheiden Sie gemeinsam über folgende Punkte.',
        keywords: [
          'Was machen? (streichen, einkaufen, tragen)',
          'Wann/wie lange?',
          'Andere Leute fragen?',
          'Kleidung?',
          'Werkzeug?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Kaputte Haustür (2)',
    aufgaben: [
      SprechenAufgabe(
        title: 'Problem mit der Außentür lösen',
        instruction:
            'Die Außentür des Hauses ist kaputt, deshalb schließt sie nicht. Was können Sie mit Ihren Nachbarn tun, um das Problem zu lösen?',
        keywords: [
          'Informieren Sie den Vermieter oder Hausmeister.',
          'Senden Sie eine E-Mail oder telefonieren Sie.',
          'Sollten Sie auch die Nachbarn informieren?',
          'Was machen Sie, wenn die Situation nicht gelöst ist?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Schule neu gestalten',
    aufgaben: [
      SprechenAufgabe(
        title: 'Die Schule neu gestalten',
        instruction:
            'Der Direktor deiner Schule hat entschieden, dass es Zeit wird, die Schule neu zu gestalten. Er hat alle Klassen gefragt, was sie gern machen würden, damit die Schule wieder gut aussieht. Besprich mit deinem Partner, was alles gemacht werden soll.',
        keywords: [
          'Wer',
          'Wann',
          'Was',
          'Schüler',
          'Eltern',
          'Geld',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
  SprechenTest(
    thema: 'Wohnung putzen',
    aufgaben: [
      SprechenAufgabe(
        title: 'Putztag gemeinsam planen',
        instruction:
            'Sie und Ihr Partner/Ihre Partnerin wohnen gemeinsam in einer Wohnung. Am Samstag muss wieder einmal richtig geputzt und aufgeräumt werden. Planen Sie gemeinsam den Tag.',
        keywords: [
          'Was putzen/aufräumen?',
          'Materialien?',
          'Wer macht was?',
          'Uhrzeit?',
        ],
        examples: _planungRedemittel,
      ),
    ],
  ),
];
