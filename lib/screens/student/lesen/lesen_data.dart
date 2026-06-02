// Data models and content for Lesen (Leseverstehen) — TELC B1
//
// Struktur (TELC B1):
//   Teil 1 – Globalverstehen:   5 ta qisqa matn → mos sarlavhani tanlash
//   Teil 2 – Detailverstehen:   1 ta uzun matn → 5 ta savol (a/b/c)
//   Teil 3 – Selektives Verstehen: 10 ta vaziyat → mos e'lonni tanlash
//
// Lesen + Sprachbausteine birgalikda 90 daqiqa (tanaffussiz).

class LesenQuestion {
  /// Shu savolga tegishli matn (Teil 1 — qisqa matn, Teil 3 — vaziyat).
  /// Teil 2 da bu null, chunki matn butun Teil uchun umumiy (sharedText).
  final String? passage;

  /// Savol yoki ko'rsatma.
  final String prompt;

  final List<String> options;
  final String correctAnswer;

  const LesenQuestion({
    this.passage,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
  });
}

class LesenTeil {
  final int teilNumber;

  /// Butun Teil uchun umumiy o'qish matni (Teil 2 uchun maqola).
  final String? sharedText;

  /// Ko'p testli Teil'lar uchun (Sprachbausteine): har bir TEST'ning matni.
  /// testTexts[i] — i-chi TEST guruhining matni. null bo'lsa ishlatilmaydi.
  final List<String>? testTexts;

  /// Agar > 0 bo'lsa, savollar har shuncha tadan TEST guruhlariga bo'linadi
  /// (Sprachbausteine: har testda 10 ta bo'sh joy). 0 — guruhlash yo'q.
  final int questionsPerTest;

  final List<LesenQuestion> questions;

  const LesenTeil({
    required this.teilNumber,
    this.sharedText,
    this.testTexts,
    this.questionsPerTest = 0,
    required this.questions,
  });
}

class LesenLevel {
  final String level;
  final List<LesenTeil> teile;

  const LesenLevel({required this.level, required this.teile});
}

// ── B1 (TELC) ────────────────────────────────────────────────────────────────

/// Lesen Teil 1 – Test 1 uchun 10 ta sarlavha (a–j) banki.
/// Har bir matn shu ro'yxatdan bittasiga mos keladi (5 mos + 5 chalg'ituvchi).
const _t1Test1Headings = [
  'Finanzielle Unterstützung für Kunstprojekte mit Schülern',
  'Winterveranstaltung auf dem Eis mit Musik',
  'Aktionsprogramm der EU: Finanzielle Unterstützung für italienische Künstler',
  'Kunstausstellung von italienischen Schülern',
  'Deutschlernen mit eurer Methode im Radio',
  'Geld für gemeinsame europäische Projekte',
  'Elternverein organisiert Kunstausstellung',
  'Mit der Eisenbahn ins winterliche Wien',
  'Mehr Geld für österreichische Musikschulen',
  'Wie Sprachaufenthalte auswählen?',
];

/// Lesen Teil 1 – Test 2 uchun 10 ta sarlavha (a–j) banki.
const _t1Test2Headings = [
  'Der öffentliche Verkehr auf einen Blick.',
  'Türen auf für fremde Kulturen.',
  'Ski fahren in der Schweiz.',
  'Schlank werden und trotzdem gut essen.',
  '"Herr Ober, es schmeckt mir nicht!", sagen nur wenige Gäste.',
  'Die schönsten Bahnstrecken in Deutschland.',
  'Die Deutschen beschweren sich sofort.',
  'Wanderungen im Schnee.',
  'Hauptsache es schmeckt - Gesundheit ist Nebensache.',
  'Immer beliebter: Studienreisen in die Schweiz.',
];

/// Sprachbausteine Teil 2 uchun umumiy so'z banki (15 ta so'z, a–o).
/// Har bir bo'sh joy uchun shu ro'yxatdan bittasi tanlanadi.
const _sb2Words = [
  'anmelden',
  'Antwort',
  'arbeiten',
  'Bescheinigung',
  'bezahlen',
  'Erfahrung',
  'geeignet',
  'gute',
  'interessiere',
  'leider',
  'mitteilen',
  'möglich',
  'Unterricht',
  'verbessern',
  'wissen',
];

const lesenB1 = LesenLevel(
  level: 'B1',
  teile: [
    // ── Teil 1 – Globalverstehen: 5 ta matn, 10 sarlavhadan mosini topish ────
    // Har TEST: 5 ta matn + umumiy 10 ta sarlavha (a–j), 5 tasi chalg'ituvchi.
    LesenTeil(
      teilNumber: 1,
      questionsPerTest: 5,
      questions: [
        // ── TEST 1 ──
        LesenQuestion(
          passage:
              'Rund 150.000 Sprachreisen werden von Deutschen jährlich '
              'unternommen. Der Wunsch, eine andere Sprache zu lernen, kann '
              'verschiedene Gründe haben: private, schulische oder berufliche. '
              'Das Angebot an Sprachreisen wächst ständig, über die Qualität ist '
              'jedoch wenig oder nichts bekannt. Im Marktplatz geht es diesmal um '
              'Kriterien für das Lernen mit Erfolg. Welche Methoden sind zu '
              'empfehlen, welche Anbieter kosten? Ihre Fragen werden am '
              'Hörertelefon unter 0800-839601 von Fachleuten beantwortet.',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test1Headings,
          correctAnswer: 'Wie Sprachaufenthalte auswählen?',
        ),
        LesenQuestion(
          passage:
              'Die Metropole Wien lädt zum winterlichen Eisvergnügen vor dem '
              'Wiener Rathaus ein: vom 22. Januar bis 7. März kann man auf 1800 '
              'Quadratmetern übers Eis fahren. Die Musik dazu bestimmt den '
              'Fahrstil und reicht vom klassischen Walzer bis zur Diskomusik. '
              'Nachts werden auf der Eisbahn Partys veranstaltet, vom Samba-Fest '
              'bis zum Hip-Hop-Event. Speisen und Getränke gibt es an '
              'verschiedenen Ständen, Schlittschuhe und Stiefel kann man leihen. '
              'Informationen: Wiener Tourismusverband.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test1Headings,
          correctAnswer: 'Winterveranstaltung auf dem Eis mit Musik',
        ),
        LesenQuestion(
          passage:
              'Für das Aktionsprogramm der Europäischen Union (EU) zur '
              'beruflichen Weiterbildung, Leonardo da Vinci, können noch bis zum '
              '31. März Anträge gestellt werden. Ziel des Programms ist es, '
              'europäische Projekte zur beruflichen Weiterbildung zu '
              'unterstützen. Anträge auf finanzielle Unterstützung können die '
              'Institutionen stellen, die mit mindestens zwei weiteren '
              'europäischen Partnern an einem Projekt arbeiten wollen. '
              'Information: Nationale Koordinierungsstelle Leonardo da Vinci, '
              'Fehrbelliner Platz 3, D-10707 Berlin, Tel. 030/8643-0, Fax -2637.',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test1Headings,
          correctAnswer: 'Geld für gemeinsame europäische Projekte',
        ),
        LesenQuestion(
          passage:
              'Wien (SN.APA). Wie das Unterrichtsministerium mitteilte, sollen '
              'im kommenden Jahr monatlich 70.000 Euro für Kulturprojekte an '
              'Schulen zur Verfügung gestellt werden. Unterstützt würden damit '
              'Veranstaltungen und Projekte, die das Verständnis der Kinder und '
              'Jugendlichen für die Künste wecken, das Interesse am '
              'Musisch-Kreativen verstärken und zu Kontakten und einer '
              'Auseinandersetzung mit Künstlern führen. Dadurch soll in '
              'altersgemäßer Form die ganzheitliche Entwicklung der '
              'Persönlichkeit von Kindern und Jugendlichen gefördert werden.',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test1Headings,
          correctAnswer:
              'Finanzielle Unterstützung für Kunstprojekte mit Schülern',
        ),
        LesenQuestion(
          passage:
              'Zum sechsten Mal veranstaltet das Comitato Geniton '
              'Binningen/Bottmingen seine breit angelegte multikulturelle '
              'Kunstausstellung Arte. An der Veranstaltung nehmen 70 '
              'Künstlerinnen und Künstler aus der Region sowie Gäste aus Italien, '
              'Frankreich, Deutschland und weiteren Ländern teil. Bei dem vor 18 '
              'Jahren gegründeten Comitato handelt es sich um einen Elternverein, '
              'der damals italienischsprachigen Kindern bei ihren Schulproblemen '
              'hilfreich zur Seite stand. Da die jetzige dritte Kindergeneration '
              'nicht mehr diese Probleme hat, suchte das Comitato nach neuen '
              'Aufgaben und fand in der Organisation der alljährlichen '
              'Kunstausstellung ein neues, interessantes Betätigungsfeld.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test1Headings,
          correctAnswer: 'Elternverein organisiert Kunstausstellung',
        ),
        // ── TEST 2 ──
        LesenQuestion(
          passage:
              'Es stimmt: Wir essen einfach zu viel Fett, zu viel Fleisch und '
              'zu wenig Ballaststoffe. Doch die wenigsten scheint das zu kümmern. '
              'Die Hausmannskost mit Kohlrouladen, Schweinebraten und Currywurst '
              'sind nach wie vor die Lieblingsgerichte der Deutschen. Und nur '
              'jeder Fünfte will sich der Figur zuliebe beim Essen einschränken. '
              'Das ergab die neueste Umfrage der Gesellschaft für Konsumforschung '
              'über Trends in der Ernährung.',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test2Headings,
          correctAnswer:
              'Hauptsache es schmeckt - Gesundheit ist Nebensache.',
        ),
        LesenQuestion(
          passage:
              'Sämtliche Informationen zu den Bahnlinien und ausgesuchten '
              'Busverbindungen in der Bundesrepublik können Sie in gesammelter '
              'Form auf der Webseite des Verkehrsclubs Deutschland (www.vcd.net) '
              'finden. Unter dem Menüpunkt „Fahrpläne Bus und Bahn Deutschland" '
              'können Sie die wichtigsten Daten zum Fernverkehr, zu Regional- '
              'und S-Bahnen sowie zu Buslinien abrufen. Per Suchbefehl erhalten '
              'Sie außerdem Auskunft über Verkehrsverbunde und rund 8000 '
              'Bahnhöfe in Deutschland.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test2Headings,
          correctAnswer: 'Der öffentliche Verkehr auf einen Blick.',
        ),
        LesenQuestion(
          passage:
              'Immer mehr Gäste in den Wintersportorten wollen auch in der '
              'kalten Jahreszeit ihrem Hobby, dem Wandern, frönen und suchen '
              'Freude und Erholung abseits des Pistenrummels. Sie finden beides '
              'auf markierten und vom Schnee geräumten Winterwanderwegen in den '
              'Bergen. Der Autor Emanuel Balsinger stellt drei Dutzend Routen in '
              'der Schweiz vor und liefert sämtliche Informationen zu einfachen '
              'Spaziergängen im Schnee oder anspruchsvollen, längeren '
              'Wanderungen. Das Buch kostet CHF 34,80. Erhältlich im Buchhandel '
              'oder direkt bei: Werd Verlag, Postfach, 8021 Zürich.',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test2Headings,
          correctAnswer: 'Wanderungen im Schnee.',
        ),
        LesenQuestion(
          passage:
              'Der Service im Restaurant ist schlecht, das Essen lauwarm und '
              'mäßig. Beschweren Sie sich? Nein? Dann befinden Sie sich in großer '
              'Gesellschaft. Nach dem Ergebnis einer Studie der '
              'Bundesforschungsanstalt für Ernährung hat nur jeder Dritte beim '
              'Anblick des bestellten Menüs daran gedacht, sich zu beschweren. '
              'Wenige von ihnen machten ihrem Ärger auch tatsächlich Luft. Die '
              'übrigen zwei Drittel hielten lieber still, weil sie den Aufwand '
              'scheuten, keine Zeit hatten oder es peinlich fanden. Dabei hatten '
              'die Aufmüpfigen durchweg Erfolg. Die meisten erhielten eine '
              'Ersatzleistung. Seltener gab\'s eine Entschuldigung und noch '
              'seltener Preisnachlass.',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test2Headings,
          correctAnswer:
              '"Herr Ober, es schmeckt mir nicht!", sagen nur wenige Gäste.',
        ),
        LesenQuestion(
          passage:
              'Die Jugendaustausch-Organisation AFS Interkulturelle Programme '
              'Schweiz sucht Familien, die während eines Jahres Schüler und '
              'Schülerinnen aus dem Ausland beherbergen möchten. Die 16- bis '
              '19-jährigen Jungen und Mädchen kommen vorwiegend aus Neuseeland '
              'und Australien, aber auch aus Südafrika, Chile, Simbabwe, Costa '
              'Rica und Kolumbien. In ihrem Austauschjahr möchten sie unsere '
              'Kultur und Sprache kennen lernen. Die Gastfamilien bieten '
              'kostenlos Unterkunft und Verpflegung. Es braucht ein offenes Herz, '
              'etwas Mut und Humor. Wer sich gerne mit neuen Gedanken und '
              'Menschen aus fremden Kulturen auseinandersetzt, wendet sich an: '
              'AFS Interkulturelle Programme Schweiz, CH 8037 Zürich.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test2Headings,
          correctAnswer: 'Türen auf für fremde Kulturen.',
        ),
      ],
    ),

    // ── Teil 2 – Detailverstehen: 1 maqola, 5 ta savol (a/b/c) ───────────────
    LesenTeil(
      teilNumber: 2,
      sharedText:
          'Immer mehr Menschen arbeiten heute von zu Hause aus. Das sogenannte '
          'Homeoffice hat in den letzten Jahren stark zugenommen. Viele Firmen haben '
          'gemerkt, dass ihre Mitarbeiter auch zu Hause gute Arbeit leisten können.\n\n'
          'Für die Angestellten hat das Homeoffice viele Vorteile. Sie sparen Zeit, '
          'weil sie nicht mehr jeden Tag ins Büro fahren müssen. Außerdem können sie '
          'ihre Arbeit oft flexibler einteilen. Eltern mit kleinen Kindern finden das '
          'besonders praktisch.\n\n'
          'Es gibt aber auch Nachteile. Manche Menschen fühlen sich zu Hause allein und '
          'vermissen den Kontakt zu ihren Kollegen. Andere können sich in der Wohnung '
          'schlecht konzentrieren, weil es dort viele Ablenkungen gibt. Auch die Grenze '
          'zwischen Arbeit und Freizeit wird oft unklar.\n\n'
          'Experten raten deshalb, feste Arbeitszeiten zu haben und sich einen ruhigen '
          'Arbeitsplatz einzurichten. Wichtig ist auch, regelmäßig Pausen zu machen und '
          'sich mit den Kollegen online auszutauschen. Wer diese Regeln beachtet, kann '
          'im Homeoffice gesund und produktiv arbeiten.',
      questions: [
        LesenQuestion(
          prompt: 'Was sagt der Text über das Homeoffice?',
          options: [
            'Es wird immer seltener.',
            'Es ist in den letzten Jahren häufiger geworden.',
            'Nur kleine Firmen erlauben es.',
          ],
          correctAnswer: 'Es ist in den letzten Jahren häufiger geworden.',
        ),
        LesenQuestion(
          prompt: 'Ein Vorteil des Homeoffice ist, dass die Angestellten ...',
          options: [
            'mehr Geld verdienen.',
            'gar nicht arbeiten müssen.',
            'Zeit für den Weg ins Büro sparen.',
          ],
          correctAnswer: 'Zeit für den Weg ins Büro sparen.',
        ),
        LesenQuestion(
          prompt: 'Für wen ist das Homeoffice laut Text besonders praktisch?',
          options: [
            'Für Eltern mit kleinen Kindern.',
            'Für Studenten ohne Job.',
            'Für Rentner.',
          ],
          correctAnswer: 'Für Eltern mit kleinen Kindern.',
        ),
        LesenQuestion(
          prompt: 'Welches Problem nennt der Text?',
          options: [
            'Die Technik funktioniert oft nicht.',
            'Manche Menschen fühlen sich allein.',
            'Das Homeoffice ist zu teuer.',
          ],
          correctAnswer: 'Manche Menschen fühlen sich allein.',
        ),
        LesenQuestion(
          prompt: 'Was raten die Experten?',
          options: [
            'Man soll gar keine Pausen machen.',
            'Man soll feste Arbeitszeiten haben.',
            'Man soll nie mit Kollegen sprechen.',
          ],
          correctAnswer: 'Man soll feste Arbeitszeiten haben.',
        ),
      ],
    ),

    // ── Teil 3 – Selektives Verstehen: 10 ta vaziyat → mos e'lon ─────────────
    LesenTeil(
      teilNumber: 3,
      questions: [
        LesenQuestion(
          passage:
              'Sie möchten am Wochenende einen Computerkurs für Anfänger machen.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Computerschule Müller: Abendkurse von Montag bis Freitag, nur für Fortgeschrittene.',
            'PC-Treff: Computerkurse für Anfänger, jeden Samstag von 10 bis 13 Uhr.',
            'Online-Shop für gebrauchte Computer und Zubehör zu günstigen Preisen.',
          ],
          correctAnswer:
              'PC-Treff: Computerkurse für Anfänger, jeden Samstag von 10 bis 13 Uhr.',
        ),
        LesenQuestion(
          passage:
              'Sie suchen für sich und Ihre Familie eine Wohnung mit drei Zimmern.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Schöne 3-Zimmer-Wohnung mit Balkon, ruhige Lage, ab sofort frei.',
            'Kleines 1-Zimmer-Apartment für Studenten, möbliert, zentral.',
            'Helle Büroräume im Stadtzentrum zu vermieten.',
          ],
          correctAnswer:
              'Schöne 3-Zimmer-Wohnung mit Balkon, ruhige Lage, ab sofort frei.',
        ),
        LesenQuestion(
          passage:
              'Ihr Auto ist kaputt und Sie brauchen schnell eine Werkstatt.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Fahrschule Schnell: Führerschein in nur vier Wochen.',
            'Autowerkstatt Berg: Reparaturen aller Marken, auch samstags geöffnet.',
            'Autovermietung: günstige Mietwagen für das Wochenende.',
          ],
          correctAnswer:
              'Autowerkstatt Berg: Reparaturen aller Marken, auch samstags geöffnet.',
        ),
        LesenQuestion(
          passage:
              'Sie möchten schwimmen lernen und suchen einen Kurs für Erwachsene.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Schwimmkurs für Kinder ab 5 Jahren im Hallenbad.',
            'Schwimmschule Delfin: Kurse für erwachsene Anfänger, dienstags abends.',
            'Tauchclub sucht erfahrene Taucher für Ausflüge am Meer.',
          ],
          correctAnswer:
              'Schwimmschule Delfin: Kurse für erwachsene Anfänger, dienstags abends.',
        ),
        LesenQuestion(
          passage: 'Sie suchen für Ihre Tochter einen Klavierlehrer.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Musikschule Harmonie: Klavierunterricht für Kinder und Jugendliche.',
            'Gitarrenkurs für Anfänger, jeden Mittwoch im Jugendzentrum.',
            'Verkaufe altes Klavier, günstig abzugeben.',
          ],
          correctAnswer:
              'Musikschule Harmonie: Klavierunterricht für Kinder und Jugendliche.',
        ),
        LesenQuestion(
          passage:
              'Sie möchten Ihren Urlaub am Meer verbringen und suchen ein günstiges Hotel.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Gemütliche Berghütte in den Alpen, ideal zum Wandern.',
            'Strandhotel Sonne: günstige Zimmer direkt am Meer, Frühstück inklusive.',
            'Stadtrundfahrten mit dem Bus, jeden Tag um 9 Uhr.',
          ],
          correctAnswer:
              'Strandhotel Sonne: günstige Zimmer direkt am Meer, Frühstück inklusive.',
        ),
        LesenQuestion(
          passage: 'Sie suchen einen Babysitter für Samstagabend.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Erfahrene Studentin passt abends und am Wochenende auf Ihre Kinder auf.',
            'Hundepension nimmt Ihren Hund über das ganze Wochenende.',
            'Reinigungsfirma putzt Ihre Wohnung jede Woche zuverlässig.',
          ],
          correctAnswer:
              'Erfahrene Studentin passt abends und am Wochenende auf Ihre Kinder auf.',
        ),
        LesenQuestion(
          passage: 'Sie möchten Ihr Deutsch für den Beruf verbessern.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Deutschkurs B2 mit Schwerpunkt Beruf, abends, zweimal pro Woche.',
            'Englischkurs für komplette Anfänger, vormittags.',
            'Nachhilfe in Mathematik für Schüler der Klassen 5 bis 10.',
          ],
          correctAnswer:
              'Deutschkurs B2 mit Schwerpunkt Beruf, abends, zweimal pro Woche.',
        ),
        LesenQuestion(
          passage:
              'Sie suchen ein gebrauchtes Fahrrad für den Weg zur Arbeit.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Neue E-Bikes im Angebot, modern, aber ziemlich teuer.',
            'Verkaufe gut erhaltenes Damenfahrrad, ideal für die Stadt.',
            'Geführte Fahrradtouren durch die Berge am Wochenende.',
          ],
          correctAnswer:
              'Verkaufe gut erhaltenes Damenfahrrad, ideal für die Stadt.',
        ),
        LesenQuestion(
          passage:
              'Sie möchten in Ihrer Freizeit ehrenamtlich anderen Menschen helfen.',
          prompt: 'Welche Anzeige passt?',
          options: [
            'Stellenangebot: Vollzeitjob als Verkäufer mit gutem Gehalt gesucht.',
            'Die Tafel sucht freiwillige Helfer für die Essensausgabe.',
            'Putzhilfe für Privathaushalt gesucht, gegen Bezahlung.',
          ],
          correctAnswer:
              'Die Tafel sucht freiwillige Helfer für die Essensausgabe.',
        ),
      ],
    ),

    // ── Sprachbausteine Teil 1 – Grammatik (ko'p testli) ────────────────────
    // Har TEST: 1 ta matn + 10 ta bo'sh joy (a/b/c).
    LesenTeil(
      teilNumber: 4,
      questionsPerTest: 10,
      testTexts: [
        // ── TEST 1 ──
        'Sehr geehrter Herr Meyerhofer,\n\n'
            'Wie Sie wissen, miete ich nun schon seit drei Jahren eine Wohnung '
            'in ___(1)___ Haus. Ich ___(2)___ die ganze Zeit sehr zufrieden, '
            'denn im Haus war es immer ruhig, sauber und sicher. In der '
            'Zwischenzeit ___(3)___ sich die Wohnqualität durch die Eröffnung '
            'des Restaurants im Erdgeschoss aber deutlich verschlechtert. '
            '___(4)___ spät abends höre ich nun täglich ___(5)___ Lärm der '
            'Restaurantgäste im Garten, die Mülleimer im Hof sind immer '
            'überfüllt, die Parkplätze vor dem Haus, ___(6)___ eigentlich für '
            'die Mieter reserviert sind, sind immer besetzt, und das '
            'Treppenhaus ist ständig verschmutzt. Außerdem fühle ich mich '
            '___(7)___ Haus nicht mehr sicher, weil das Restaurant oft die '
            'ganze Nacht ___(8)___ hat.\n\n'
            'Ich möchte Sie dringend bitten, sich um diese ___(9)___ zu kümmern '
            'und mit den Restaurantbesitzern zu sprechen. Vielleicht könnte '
            '___(10)___ gemeinsam eine Lösung finden.\n\n'
            'Mit freundlichen Grüßen\n'
            'Ihre Anneliese Kühne',
        // ── TEST 2 ──
        'Liebe Jelena,\n\n'
            'ich hab dir doch schon vom Deutschkurs erzählt, ___(1)___ ich hier '
            'besuche. Der ist wirklich ganz gut. Wir haben jetzt eine neue '
            'Aufgabe bekommen. Wir müssen Informationen ___(2)___ Thema '
            'Gesundheit und Ernährung suchen und schauen, was es dazu '
            'Interessantes ___(3)___ Internet gibt. Die interessanteste '
            'Internetseite, die ich finden ___(4)___ , ist www.gesund.ch. Diese '
            'Seite ist für ___(5)___ Leute gemacht, die gern mehr über gesunde '
            'Ernährung erfahren möchten. Fachleute beschreiben hier genau, '
            '___(6)___ Lebensmittel für unseren Körper wichtig und gesund sind '
            'und wie oft und wie viel man pro Tag essen sollte. Außerdem kann '
            'man ___(7)___ seinen persönlichen Speiseplan selbst erstellen und '
            'dafür passende Rezepte ___(8)___ . Für Menschen, ___(9)___ ein paar '
            'Kilos zu viel haben, gibt es auch Tipps zum Abnehmen und Links zu '
            'verschiedenen Fitnesszentren in der Schweiz.\n\n'
            'Und was gibt es bei dir Neues? ___(10)___ mir doch möglichst bald '
            'zurück!\n\n'
            'Bis dann und viele Grüße\n'
            'Paola',
        // ── TEST 3 ──
        'Liebe Olivia,\n\n'
            'wie du ja weißt, mache ich gerade Urlaub auf Fehmarn. Und dass ich '
            'mein Fahrrad mitgenommen habe, war wirklich eine gute Idee. '
            'Radfahren macht hier nämlich viel Spaß trotz ___(1)___ Windes. Und '
            'es gibt auch Angebote für Radfahrer wie ___(2)___ , die sich vor '
            'allem erholen und nicht besonders anstrengen wollen.\n\n'
            'So kann man hier zum Beispiel ___(3)___ Fahrkarten kaufen, um mit '
            'dem Bus in einen anderen Ort zu fahren und mit dem Rad zurück. Oder '
            'es gibt Angebote mit Schiffen, die das Rad ___(4)___ wenig Geld '
            'transportieren.\n\n'
            'Besonders ___(5)___ hat mich aber die Stadt Burg auf Fehmarn. Schon '
            '___(6)___ Hafen sind mir die vielen Fahrräder aufgefallen. ___(7)___ '
            'gibt es Markierungen auf den Straßen, die den Radfahrern ___(8)___ , '
            'sich bei roten Ampeln vor die Autos zu stellen. ___(9)___ Ampeln '
            'schalten für Radfahrer sogar früher auf Grün als für Autos.\n\n'
            'Du siehst also: Es hat sich gelohnt, das Fahrrad ___(10)___ .\n\n'
            'Liebe Grüße\n'
            'Lutz',
        // ── TEST 4 ──
        'Liebe Frau Grenzacker,\n\n'
            'leider habe ich Sie vor den Feiertagen nicht mehr angetroffen. '
            '___(1)___ schreibe ich Ihnen nun aus dem Skiparadies Obergurgl, '
            '___(2)___ ich jetzt mit einigen Freunden die Winterferien '
            'verbringe. Nochmals vielen Dank für die selbst gebackenen Kekse, '
            'die Sie mir bei unserem letzten Treffen ___(3)___ die Reise '
            'mitgegeben haben. Sie schmecken köstlich zu unserem Glühwein, den '
            'wir abends in gemütlicher Runde trinken. Im Skikurs mache ich '
            'langsam Fortschritte, aber es ist gar nicht so einfach, ___(4)___ '
            'es aussieht.\n\n'
            'Ich möchte übrigens erst am Montag direkt zur Präsentation '
            '___(5)___ Projekts in Wien zurück sein. In ___(6)___ Fällen würde '
            'ich aber auch schon früher abreisen. Allerdings ___(7)___ ich '
            'telefonisch nur über Handy erreichbar. Im Notfall müssten Sie '
            '___(8)___ eine SMS oder eine E-Mail schicken. Meine Handy-Nummer '
            'und E-Mail-Adresse ___(9)___ Sie ja.\n\n'
            'Ich hoffe, dass auch Sie mit Ihrer Familie ___(10)___ erholsamen '
            'Urlaub verbracht haben!\n\n'
            'Mit lieben Grüßen\n'
            'Ihre Monika Riedel',
        // ── TEST 5 ──
        'An alle Kunden\n\n'
            'Sehr geehrter Herr Schröder,\n\n'
            'zum Start in das neue Geschäftsjahr ___(1)___ wir uns für Sie etwas '
            'ganz Besonderes ausgedacht: einen attraktiven Gewinn! ___(2)___ dem '
            'Beginn des neuen Geschäftsjahres feiern wir unsere erfolgreiche '
            'Buchidee. Machen Sie mit! Es warten auf Sie sehr ___(3)___ Gewinne '
            'im Wert von vielen Tausend Euro. Mit Ihrer Kundennummer können Sie '
            'an einem Preisausschreiben teilnehmen. Senden Sie uns ___(4)___ das '
            'beigefügte Antwortschreiben zurück und bestellen Sie damit – ohne '
            'Risiko – das Buch des Monats. Sie erhalten dieses Buch mit ___(5)___ '
            'Versprechen, es nach 10 Tagen zurückgeben zu können, sollte Ihnen '
            'das Buch nicht gefallen. Ohne irgendetwas zu zahlen! Behalten Sie '
            'das Buch, was wir ___(6)___ hoffen, zahlen Sie nur 50 Prozent des '
            'sonst üblichen Preises in einer Buchhandlung. Gleichzeitig nehmen '
            'Sie an einem Preisausschreiben ___(7)___ .\n\n'
            'Bitte bedenken Sie: Sollte Ihre Kundennummer ___(8)___ den richtigen '
            'Zahlen sein, haben Sie die Chance, ein Auto, eine Reise und viele '
            'weitere Preise zu erhalten. Antworten Sie ___(9)___ noch diese '
            'Woche! Dann haben Sie in jedem Fall die Chance auf den Hauptgewinn '
            '- einen Mercedes der S-Klasse. Wenn Sie innerhalb der kommenden '
            'vier Wochen antworten, nehmen Sie immer ___(10)___ an unserer '
            'Gewinnverteilung teil – vorausgesetzt, Sie haben die richtige '
            'Kundennummer.\n\n'
            'Mit freundlichen Grüßen\n'
            'Petra Obermoser\n'
            'Leiterin der Abteilung Marketing',
        // ── TEST 6 ──
        'Liebe Catherine,\n\n'
            'seit ich dir letztes Mal von meinem Sprachaufenthalt in der Schweiz '
            '___(1)___ habe, ist viel passiert. Ich kenne ___(2)___ Land jetzt '
            'schon recht gut.\n\n'
            'Die Schweiz ist ja wirklich nicht groß. ___(3)___ in jeder Gegend '
            'wird ein anderer Dialekt oder gar eine andere Sprache gesprochen. '
            'Das ist ___(4)___ mich fast unglaublich! Bei uns in Australien '
            'fährt man mit dem Auto 24 Stunden lang geradeaus, und ___(5)___ man '
            'ankommt, dann sprechen die Leute dort immer noch dieselbe '
            'Sprache.\n\n'
            'Am Anfang hat mich das Sprachgemisch ___(6)___ sehr verwirrt, aber '
            '___(7)___ verstehe ich fast alles, wenn jemand auf Schweizerdeutsch '
            'zu mir spricht. Ich kann aber nur auf Hochdeutsch antworten.\n\n'
            'Zwischen der Schule hier und unserem Schulsystem in Australien gibt '
            'es einige ___(8)___ : In der Schweiz sprechen die Lehrer viel und '
            'die Schüler ___(9)___ Vieles im Kopf behalten oder aufschreiben. In '
            'Australien arbeiten wir meistens im Rahmen von Projekten und machen '
            'eigentlich alle Aufgaben auf ___(10)___ Computer.\n\n'
            'Viele Grüße\n'
            'Jack',
        // ── TEST 7 ──
        'Hallo Isabelle,\n\n'
            'wie du ja weißt, ___(1)___ ich seit zwei Monaten in einem '
            'Altersheim ___(2)___ der Nähe von Schaffhausen. Die Arbeit in '
            '___(3)___ Haus gefällt mir gut, obwohl es manchmal auch sehr '
            'stressig ist. Besonders schön ist der enge ___(4)___ zu einigen der '
            'alten Menschen. Eine Frau, Anna Ringier, mag ich ___(5)___ gern. '
            'Sie ist schon 96 Jahre alt und sitzt im Rollstuhl, aber sie ist '
            'immer noch fröhlich. Gestern hat sie mir ___(6)___ ganzes Leben '
            'erzählt. Sie hat bis zum 84. Lebensjahr ___(7)___ gearbeitet. Schon '
            'als achtjähriges Mädchen musste sie bei einem Bauern arbeiten, '
            '___(8)___ ihre Eltern die neunköpfige Familie nicht ernähren '
            'konnten. Später arbeitete Anna als Schneiderin.\n\n'
            'Neben ihrer Arbeit hat Anna ___(9)___ auf eine Sache nie '
            'verzichtet: das Bergsteigen! Das war immer ihre große Leidenschaft. '
            'Diese Frau ist wirklich sehr beeindruckend!\n\n'
            'Aber du ___(10)___ bestimmt auch viel erlebt. Ich würde mich sehr '
            'freuen, wenn du mir bald wieder einmal schreibst!\n\n'
            'Herzliche Grüße\n'
            'deine Julie',
        // ── TEST 8 ──
        'Herrn Matthias Buschhaus\n'
            'Alte Gasse 19\n'
            'D-80344 München\n\n'
            'Ihre Kündigung vom 15. Mai\n\n'
            'Sehr geehrter Herr Buschhaus,\n\n'
            'schade, ___(1)___ Sie CHIP nicht weiter beziehen ___(2)___ . Die '
            'Belieferung beenden wir mit unserem ___(3)___ Heft. Sie erhalten '
            'daher die darauf folgende Ausgabe nicht ___(4)___ .\n\n'
            'Wir ___(5)___ Sie natürlich nur ungern als Abonnenten und würden '
            'uns freuen, wenn Sie CHIP ___(6)___ ab und zu am Kiosk kaufen. '
            'Vielleicht gelingt es uns, ___(7)___ wieder von der Qualität von '
            'CHIP zu überzeugen.\n\n'
            '___(8)___ Sie noch Fragen haben oder sich wieder für ein Abonnement '
            'entscheiden, stehen wir Ihnen gerne unter ___(9)___ Nummer '
            '0781/639 6259 von montags bis freitags von 8 bis 18 Uhr zur '
            'Verfügung.\n\n'
            'Mit ___(10)___ Grüßen\n'
            'Ihr CHIP-Aboservice',
        // ── TEST 9 ──
        'Liebe Maria,\n\n'
            'danke vielmals für die Einladung. Nächste Woche werde ich also '
            '___(1)___ dir in Berlin sein. Ich freue mich schon sehr ___(2)___ , '
            'denn schließlich haben wir uns fast ein ___(3)___ Jahr nicht '
            'gesehen. Wie du ja weißt, wohne ich jetzt auf dem Land hier in der '
            'Nähe von Hamburg und das finde ich ganz toll. ___(4)___ ich würde '
            'gern auch mal wieder in eine richtige Disko gehen. Mal wieder eine '
            'ganze Nacht tanzen, das ___(5)___ mein Traum! Und zu zweit macht es '
            'viel ___(6)___ Spaß!\n\n'
            'Weißt du eigentlich, ob die Disko am Wittenberger Platz ___(7)___ '
            'existiert?\n\n'
            'Leider habe ich noch keine Ahnung, ___(8)___ ich in Berlin ankommen '
            'werde. Jedenfalls ___(9)___ ich versuchen, eine Mitfahrgelegenheit '
            'zu finden. Es gibt ja im Internet die Mitfahrzentrale, ___(10)___ so '
            'etwas organisiert. Also mache dir keine Sorgen, wenn ich etwas '
            'später komme!\n\n'
            'Ich freue mich sehr auf dich!\n'
            'Alexandra',
        // ── TEST 10 ──
        'Hallo Kathrin,\n\n'
            'wir sind heute wieder mit unseren Enkeln unterwegs. Für diese '
            '___(1)___ Reise haben wir uns die Stadt Porto ausgesucht. Vor zehn '
            'Jahren waren wir auch schon mal ___(2)___ den Motorrädern hier. Nun '
            '___(3)___ wir einfach nur Porto genießen. Die Wettervorhersage hört '
            'sich gut an.\n\n'
            'Die Flüge von Hannover ___(4)___ Frankfurt waren verspätet, aber '
            'wir sind gut angekommen. Die Verspätung wurde durch Nebel und '
            'technische Probleme verursacht. ___(5)___ wir in Porto landeten, '
            'schien zum Glück wieder die Sonne.\n\n'
            'Wir sind sehr zufrieden mit ___(6)___ Unterkunft. Es gibt zwei '
            'Zimmer mit einer gut eingerichteten Küche, sogar eine Waschmaschine '
            '___(7)___ vorhanden.\n\n'
            'Morgen werden wir ___(8)___ Ruhe die Stadt erkunden. Wir haben uns '
            'ein kleines Programm ___(9)___ , das wir gerne in den nächsten Tagen '
            'machen wollen. Die Reihenfolge haben wir aber ___(10)___ nicht '
            'festgelegt. Da sind wir flexibel.\n\n'
            'Viele Grüße\n'
            'Anne',
        // ── TEST 11 ──
        'Hallo Nikolas,\n\n'
            'in knapp einer Woche ist es so weit: Unsere spanische Theatergruppe '
            '„Los Mutantes" geht auf große Tour ___(1)___ Deutschland und '
            'Spanien mit dem Stück „Niebla" (Nebel). Wir planen, mindestens 30 '
            'Vorstellungen zu geben und das mit so ___(2)___ bunt gemischten '
            'Gruppe aus zehn (!) Ländern. Am 7. April beginnen wir unsere '
            'Theaterreise an der Uni von Alicante/Spanien. Du kannst ___(3)___ '
            'denken, dass ich als Nichtmuttersprachlerin sehr ___(4)___ bin, dort '
            'vor spanischem Publikum zu spielen, ___(5)___ ich ja fließend und '
            'fast ohne Akzent Spanisch spreche.\n\n'
            '___(6)___ Herbst steht vielleicht auch meine alte '
            '„Wahlheimatstadt" Barcelona auf dem Programm, wie gerne ___(7)___ '
            'ich euch alle wiedersehen! Ohne eure Hilfe hätte ich die Sprache '
            'niemals so gut lernen ___(8)___ . Ich denke oft an unsere '
            'multikulturelle Wohngemeinschaft: das gemeinsame Kochen, die tollen '
            'Feste … Ein bisschen ___(9)___ habe ich jetzt in der Theatergruppe '
            '___(10)___ .\n\n'
            'Liebe Grüße auch an deine Mitbewohner\n'
            'schickt dir\n'
            'Sarah',
        // ── TEST 12 ──
        'Hallo Pat,\n\n'
            'ab sofort habe ich eine neue E-Mail-Adresse: Boris3@xmg.net. Die '
            'habe ich mir bei www.xmg.net gratis ___(1)___ . Das war ganz '
            'einfach. Vielen Dank für ___(2)___ Tipp! Ach ja, mein Bruder ist '
            'total sauer auf ___(3)___ . Am Wochenende fand ich ___(4)___ '
            'Internet ein Computerspiel, leider hatte es einen Virus: Der '
            'Computer stürzte ab und nichts ging mehr. Das ist ärgerlich, vor '
            'allem ___(5)___ meine MP3-Dateien weg sind. Mein Bruder ___(6)___ '
            'die ganze Nacht lang gebraucht, um den Computer wieder fit zu '
            'kriegen. Jetzt soll ich nichts mehr herunterladen, ___(7)___ ihn '
            'vorher zu fragen. Aber kein Problem, denn bei www.spiele.org gibt es '
            '___(8)___ Spiele, die man nicht herunterladen muss. ___(9)___ dir '
            'die Seite doch auch mal an und schreib mir, ___(10)___ du davon '
            'hältst.\n\n'
            'Bis dann,\n'
            'Boris',
        // ── TEST 13 ──
        'Liebe Karin,\n\n'
            'nach meinem Praktikum in Frankreich bin ich jetzt wieder zu Hause. '
            'Wie du ja weißt, wollte ich eigentlich nach Paris, ___(1)___ das '
            'hat dann leider nicht geklappt. Doch dann habe ich eine Stelle als '
            'Praktikant bei ___(2)___ Firma in Straßburg gefunden.\n\n'
            'Dort ___(3)___ ich drei Monate geblieben. Die Arbeit war sehr '
            '___(4)___ – ich musste schon um 8.00 Uhr im Büro sein –, hat mir '
            'aber ___(5)___ sehr gut gefallen. Ich habe ___(6)___ dieser Zeit in '
            'verschiedenen Abteilungen gearbeitet und so nicht nur etwas über '
            'die Herstellung von Fernsehgeräten ___(7)___ , sondern auch über '
            'den Verkauf. Und die Kollegen, mit ___(8)___ ich am meisten zu tun '
            'hatte, waren wirklich sehr nett.\n\n'
            'Nach dem Praktikum habe ich noch zwei Wochen Urlaub bei ___(9)___ '
            'Freunden gemacht. Darüber erzähle ich ___(10)___ bald mehr – für '
            'heute muss ich Schluss machen.\n\n'
            'Liebe Grüße\n'
            'Fritz',
        // ── TEST 14 ──
        'Genuss mit Kaffee Partner\n\n'
            'Sehr geehrte Frau Thoma,\n\n'
            'schade, ___(1)___ Sie bisher noch nicht Kunde bei Kaffee Partner '
            '___(2)___ . Vielleicht liegt das an uns, weil wir ___(3)___ nicht '
            'das richtige Angebot gemacht haben, seit wir uns vor einiger Zeit '
            'in Köln auf der ANUGA, der großen Messe für Nahrung und '
            'Genussmittel, ___(4)___ haben. Wir ___(5)___ das jetzt mit dem '
            'aktuellen Katalog nachholen, den Sie heute erhalten.\n\n'
            'Sie ___(6)___ darin viele nützliche und attraktive Dinge rund um '
            'das Thema Kaffee und Trinkwasser ___(7)___ Mitarbeiter und '
            'Besucher. Aber auch Tee, kleine Leckereien und nette Kalender für '
            'Büro und Zuhause ___(8)___ Ihnen unser Geschenkkatalog. Viel Spaß '
            'beim Blättern und Aussuchen. Wir freuen ___(9)___ auf Sie!\n\n'
            '___(10)___ Grüße aus Wallenhorst\n'
            'Ihr Kaffee Partner-Team\n'
            'Manfred Pflüger',
        // ── TEST 15 ──
        'Liebe Beatrice,\n\n'
            'wie du ja weißt, sind meine Eltern seit Anfang Mai in einem Haus '
            '___(1)___ Meer in Spanien. Zuerst wollten meine Eltern warten, bis '
            'ich mit dem Gymnasium fertig bin. Aber dann sind sie doch ___(2)___ '
            'früher gefahren.\n\n'
            'Als ich im Sommer 18 wurde, wollte ich mit ___(3)___ älteren Bruder '
            'zusammen eine kleine Wohnung mieten. Das hat aber nicht geklappt. '
            'Eine Freundin hat ___(4)___ dann ein Zimmer in ihrer '
            'Wohngemeinschaft angeboten. Ich wohne jetzt mit drei ___(5)___ '
            'zusammen in der Innenstadt. Ich bin sehr zufrieden, ___(6)___ mein '
            'Zimmer recht klein ist.\n\n'
            'In der Schule habe ich keine Probleme. Ich staune selbst über meine '
            'Noten, wenn ich ___(7)___ denke, wie ___(8)___ Zeit ich mir für '
            'Hausaufgaben nehme.\n\n'
            'Manchmal schicken mir meine Eltern eine E-Mail. ___(9)___ sie rufen '
            'an. ___(10)___ jetzt habe ich jede Woche von ihnen gehört.\n\n'
            'Das war\'s für heute, bis bald und liebe Grüße\n'
            'Saskia',
        // ── TEST 16 ──
        'Liebe Dominique,\n\n'
            'da ich dich telefonisch nicht erreiche, auch nicht per E-Mail, '
            'schreibe ich dir einen Brief. Es ist nämlich etwas ganz Besonderes '
            '___(1)___ : Stelle ___(2)___ vor, ich habe die Stelle bei der EU in '
            'Brüssel bekommen!\n\n'
            'Du weißt noch: Es gab ungefähr 300 Bewerber, und unter denen '
            '___(3)___ die besten ausgesucht. Ich hatte mich auf das '
            'Vorstellungsgespräch schon ___(4)___ Zeit vorher vorbereitet. '
            'Trotzdem – ohne meine Sprachkenntnisse und meine Auslandserfahrung '
            '___(5)___ ich die Stelle sicher nicht bekommen. Aber ein bisschen '
            'Glück braucht man auch, ___(6)___ so etwas gelingt.\n\n'
            'Nun bitte ich dich ___(7)___ ein paar gute Tipps. Vielleicht kennst '
            'du auch jemanden, von ___(8)___ ich Informationen über das Leben in '
            'Belgien bekommen kann? Ich würde dich am liebsten kurz ___(9)___ , '
            'um mit dir persönlich zu sprechen. Geht das vielleicht ___(10)___ '
            'zwei Wochen, z. B. am übernächsten Wochenende? Bitte gib mir '
            'Bescheid.\n\n'
            'Herzliche Grüße\n'
            'Katie',
        // ── TEST 17 ──
        'Liebe Vollzwinkler,\n\n'
            'wir wohnen jetzt schon ___(1)___ sechs Wochen in unserer neuen '
            'Wohnung. Zwar ist immer noch nicht alles so eingerichtet, wie wir '
            '___(2)___ das wünschen. Aber wir wussten ja, dass das einige Zeit '
            '___(3)___ würde, bis alles fertig ist. Natürlich haben wir uns '
            'zuerst um das Kinderzimmer gekümmert. Unsere beiden Kinder durften '
            'sich die Farben für die Wände selbst ___(4)___ . Sie haben sich für '
            'Blau und Gelb entschieden. Meinem Mann ___(5)___ das am Anfang gar '
            'nicht gefallen, aber jetzt hat er sich ___(6)___ gewöhnt. Jetzt '
            'fehlt eigentlich nur noch das Wohnzimmer.\n\n'
            'Wir warten auf die neuen Möbel, ___(7)___ wir gekauft haben. In der '
            '___(8)___ Woche kommen sie endlich. Dann können auch wieder Gäste '
            'zu uns kommen. Wir würden uns alle sehr freuen, wenn Sie und Ihr '
            'Mann uns sehr bald besuchen ___(9)___ . Wir waren schließlich fünf '
            'Jahre lang Nachbarn! Und trotz ___(10)___ schönen neuen Wohnung '
            'sind wir ein bisschen traurig, dass wir nicht mehr neben Ihnen '
            'wohnen.\n\n'
            'Viele liebe Grüße\n'
            'Ihre Edeltraut Augenthaler',
        // ── TEST 18 ──
        'Sehr geehrter Herr Schmidt,\n\n'
            'im Januar hatte ich bei ___(1)___ für mich und meine Familie einen '
            'Flug nach Indien gebucht. Leider entsprach unser Flug überhaupt '
            'nicht dem, ___(2)___ bei der Buchung am Telefon ausgemacht worden '
            'war.\n\n'
            '___(3)___ ich ausdrücklich einen Direktflug nach Mumbai bestellt '
            'hatte, haben Sie mir einen Flug ___(4)___ Zwischenstopp in Delhi '
            'ausgestellt. Wir mussten eine Nacht in Delhi verbringen und kamen '
            'so ___(5)___ einen Tag später als geplant in Mumbai an. Doch damit '
            'nicht genug. Der Flug war nicht nur anders als vereinbart, ___(6)___ '
            'auch noch viel teurer. Statt ___(7)___ erwarteten 640 Euro kostete '
            'der Flug 720 Euro.\n\n'
            'Ich darf Sie daher ___(8)___ Rückzahlung der zu viel verrechneten '
            'Kosten auf mein Konto ___(9)___ der Deutschen Bank in Mumbai '
            'bitten. Meine Bankdaten haben Sie bereits.\n\n'
            'Ich bitte Sie, die Angelegenheit bald zu klären und ___(10)___ dann '
            'zu antworten.\n\n'
            'Mit freundlichen Grüßen\n'
            'Harish Khurana',
      ],
      questions: [
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['Ihr', 'Ihrem', 'Ihren'],
          correctAnswer: 'Ihrem',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['war', 'wäre', 'würde'],
          correctAnswer: 'war',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['hat', 'ist', 'wurde'],
          correctAnswer: 'hat',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['Bis', 'Nach', 'Von'],
          correctAnswer: 'Bis',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['dem', 'den', 'der'],
          correctAnswer: 'den',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['denen', 'die', 'diese'],
          correctAnswer: 'die',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['im', 'in', 'ins'],
          correctAnswer: 'im',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['geöffnet', 'öffnen', 'öffnet'],
          correctAnswer: 'geöffnet',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['Problem', 'Probleme', 'Problemen'],
          correctAnswer: 'Probleme',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['er', 'man', 'wir'],
          correctAnswer: 'man',
        ),
        // ── TEST 2: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['das', 'den', 'der'],
          correctAnswer: 'den',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['zu', 'zum', 'zur'],
          correctAnswer: 'zum',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['am', 'im', 'mit'],
          correctAnswer: 'im',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['können', 'könnten', 'konnte'],
          correctAnswer: 'konnte',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['junge', 'jungen', 'junges'],
          correctAnswer: 'junge',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['welche', 'welchen', 'welcher'],
          correctAnswer: 'welche',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['mir', 'dir', 'sich'],
          correctAnswer: 'sich',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['fand', 'finden', 'gefunden'],
          correctAnswer: 'finden',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['denen', 'deren', 'die'],
          correctAnswer: 'die',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['Schreibe', 'Schreiben', 'Schreibt'],
          correctAnswer: 'Schreibe',
        ),
        // ── TEST 3: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['den', 'der', 'des'],
          correctAnswer: 'des',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['mein', 'mich', 'mir'],
          correctAnswer: 'mich',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['besondere', 'besonderem', 'besonderen'],
          correctAnswer: 'besondere',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['durch', 'für', 'mit'],
          correctAnswer: 'für',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['beeindrucken', 'beeindruckend', 'beeindruckt'],
          correctAnswer: 'beeindruckt',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['am', 'im', 'zum'],
          correctAnswer: 'am',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['Aber', 'Außer', 'Außerdem'],
          correctAnswer: 'Außerdem',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['erlauben', 'erlaubt', 'erlaubte'],
          correctAnswer: 'erlauben',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['Einige', 'Einigen', 'Einiges'],
          correctAnswer: 'Einige',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['mitgenommen', 'mitnehmen', 'mitzunehmen'],
          correctAnswer: 'mitzunehmen',
        ),
        // ── TEST 4: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['daher', 'denn', 'weil'],
          correctAnswer: 'daher',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['wo', 'woher', 'wohin'],
          correctAnswer: 'wo',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['an', 'für', 'in'],
          correctAnswer: 'für',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['als', 'wie', 'wo'],
          correctAnswer: 'wie',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['unser', 'unseren', 'unseres'],
          correctAnswer: 'unseres',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['dringende', 'dringenden', 'dringender'],
          correctAnswer: 'dringenden',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['bin', 'werde', 'würde'],
          correctAnswer: 'bin',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['meiner', 'mich', 'mir'],
          correctAnswer: 'mir',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['kenne', 'kennen', 'kennt'],
          correctAnswer: 'kennen',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['ein', 'einem', 'einen'],
          correctAnswer: 'einen',
        ),
        // ── TEST 5: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['sind', 'haben', 'hat'],
          correctAnswer: 'haben',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['Zwischen', 'Mit', 'Von'],
          correctAnswer: 'Mit',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['schönes', 'schöne', 'schönen'],
          correctAnswer: 'schöne',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['noch', 'einfach', 'immer'],
          correctAnswer: 'einfach',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['unseren', 'unsere', 'unserem'],
          correctAnswer: 'unserem',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['viele', 'natürlich', 'schön'],
          correctAnswer: 'natürlich',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['zu', 'mit', 'teil'],
          correctAnswer: 'teil',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['vor', 'unter', 'neben'],
          correctAnswer: 'neben',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['unbedingt', 'bald', 'bereits'],
          correctAnswer: 'unbedingt',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['schnell', 'noch', 'schon'],
          correctAnswer: 'noch',
        ),
        // ── TEST 6: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['erzähle', 'erzählen', 'erzählt'],
          correctAnswer: 'erzählt',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['diese', 'diesen', 'dieses'],
          correctAnswer: 'dieses',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['aber', 'obwohl', 'sondern'],
          correctAnswer: 'aber',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['an', 'für', 'vor'],
          correctAnswer: 'für',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['als', 'wann', 'wenn'],
          correctAnswer: 'wenn',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['denn', 'ganz', 'schon'],
          correctAnswer: 'schon',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['früher', 'jetzt', 'seit'],
          correctAnswer: 'jetzt',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['unterschied', 'unterschiede', 'unterschieden'],
          correctAnswer: 'unterschiede',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['brauchen', 'haben', 'müssen'],
          correctAnswer: 'müssen',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['dem', 'den', 'der'],
          correctAnswer: 'dem',
        ),
        // ── TEST 7: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['arbeite', 'arbeiten', 'arbeiteten'],
          correctAnswer: 'arbeite',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['auf', 'bei', 'in'],
          correctAnswer: 'bei',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['diesem', 'diesen', 'dieses'],
          correctAnswer: 'diesem',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['Kontakt', 'Kontakte', 'Kontakten'],
          correctAnswer: 'Kontakt',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['besondere', 'besonderes', 'besonders'],
          correctAnswer: 'besonders',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['ihr', 'ihre', 'ihres'],
          correctAnswer: 'ihr',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['hart', 'harte', 'härter'],
          correctAnswer: 'harte',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['daher', 'deshalb', 'weil'],
          correctAnswer: 'weil',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['aber', 'als', 'wei'],
          correctAnswer: 'aber',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['bist', 'hast', 'wirst'],
          correctAnswer: 'hast',
        ),
        // ── TEST 8: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['darum', 'dass', 'weil'],
          correctAnswer: 'dass',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['möchte', 'möchten', 'möchtest'],
          correctAnswer: 'möchten',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['nächste', 'nächsten', 'nächstes'],
          correctAnswer: 'nächsten',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['mehr', 'noch', 'nur'],
          correctAnswer: 'mehr',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['verlieren', 'verliert', 'verloren'],
          correctAnswer: 'verlieren',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['obwohl', 'trotz', 'trotzdem'],
          correctAnswer: 'trotz',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['Ihnen', 'sie', 'Sie'],
          correctAnswer: 'Sie',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['Aber', 'Falls', 'Wann'],
          correctAnswer: 'Falls',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['das', 'der', 'die'],
          correctAnswer: 'der',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['freundlich', 'freundlichem', 'freundlichen'],
          correctAnswer: 'freundlichen',
        ),
        // ── TEST 9: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['bei', 'nach', 'zu'],
          correctAnswer: 'bei',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['darauf', 'darum', 'dazu'],
          correctAnswer: 'darauf',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['halbe', 'halben', 'halbes'],
          correctAnswer: 'halbes',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['Aber', 'Sondern', 'Trotzdem'],
          correctAnswer: 'Aber',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['hätte', 'wäre', 'würde'],
          correctAnswer: 'wäre',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['am meisten', 'ganz', 'mehr'],
          correctAnswer: 'mehr',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['auch', 'noch', 'nur'],
          correctAnswer: 'noch',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['als', 'wann', 'wenn'],
          correctAnswer: 'wann',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['darf', 'soll', 'will'],
          correctAnswer: 'will',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['das', 'die', 'der'],
          correctAnswer: 'die',
        ),
        // ── TEST 10: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['kurze', 'kurzen', 'kurzes'],
          correctAnswer: 'kurze',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['bei', 'mit', 'ohne'],
          correctAnswer: 'mit',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['haben', 'müssen', 'wollen'],
          correctAnswer: 'wollen',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['aus', 'unter', 'über'],
          correctAnswer: 'über',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['Als', 'Wann', 'Wenn'],
          correctAnswer: 'Als',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['deiner', 'meiner', 'unserer'],
          correctAnswer: 'unserer',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['hat', 'ist', 'wird'],
          correctAnswer: 'hat',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['in', 'mit', 'zu'],
          correctAnswer: 'in',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['überlegen', 'überlegt', 'überlegte'],
          correctAnswer: 'überlegt',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['noch', 'nur', 'schon'],
          correctAnswer: 'noch',
        ),
        // ── TEST 11: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['aus', 'durch', 'von'],
          correctAnswer: 'durch',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['eine', 'einen', 'einer'],
          correctAnswer: 'einer',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['dich', 'dir', 'sich'],
          correctAnswer: 'dir',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['aufgeregt', 'aufregend', 'aufzuregen'],
          correctAnswer: 'aufgeregt',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['obwohl', 'weil', 'zwar'],
          correctAnswer: 'obwohl',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['Im', 'In', 'Während'],
          correctAnswer: 'Im',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['hätte', 'würde', 'wurde'],
          correctAnswer: 'würde',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['können', 'müssen', 'sollen'],
          correctAnswer: 'können',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['damit', 'davon', 'dazu'],
          correctAnswer: 'davon',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['wiederfinden', 'wiedergefunden', 'wiederzufinden'],
          correctAnswer: 'wiedergefunden',
        ),
        // ── TEST 12: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['eingerichtet', 'einrichten', 'einrichtet'],
          correctAnswer: 'eingerichtet',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['dein', 'deinem', 'deinen'],
          correctAnswer: 'deinen',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['mein', 'mich', 'mir'],
          correctAnswer: 'mich',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['am', 'im', 'um'],
          correctAnswer: 'im',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['damit', 'denn', 'weil'],
          correctAnswer: 'weil',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['hat', 'ist', 'wird'],
          correctAnswer: 'hat',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['außer', 'ohne', 'statt'],
          correctAnswer: 'ohne',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['viel', 'viele', 'vielen'],
          correctAnswer: 'viele',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['Schau', 'Schauen', 'Schaust'],
          correctAnswer: 'Schau',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['was', 'welches', 'wie'],
          correctAnswer: 'was',
        ),
        // ── TEST 13: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['aber', 'denn', 'sondern'],
          correctAnswer: 'aber',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['eine', 'einen', 'einer'],
          correctAnswer: 'einer',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['bin', 'habe', 'wurde'],
          correctAnswer: 'bin',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['anstrengend', 'anstrengende', 'anstrengendes'],
          correctAnswer: 'anstrengend',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['trotzdem', 'wegen', 'weshalb'],
          correctAnswer: 'trotzdem',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['bis', 'in', 'nach'],
          correctAnswer: 'in',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['gelernt', 'lernen', 'lernte'],
          correctAnswer: 'gelernt',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['den', 'denen', 'die'],
          correctAnswer: 'denen',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['meine', 'meinen', 'meiner'],
          correctAnswer: 'meinen',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['dir', 'Ihnen', 'uns'],
          correctAnswer: 'dir',
        ),
        // ── TEST 14: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['dass', 'darum', 'weil'],
          correctAnswer: 'dass',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['seid', 'sein', 'sind'],
          correctAnswer: 'sind',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['euch', 'Ihnen', 'Sie'],
          correctAnswer: 'Ihnen',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['kennengelernt', 'kennen lernen', 'kennen lernte'],
          correctAnswer: 'kennengelernt',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['mochten', 'möchten', 'mögen'],
          correctAnswer: 'möchten',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['fanden', 'finden', 'findet'],
          correctAnswer: 'finden',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['für', 'von', 'wegen'],
          correctAnswer: 'von',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['gezeigt', 'zeigen', 'zeigt'],
          correctAnswer: 'zeigt',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['mich', 'sich', 'uns'],
          correctAnswer: 'uns',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['Freundlich', 'Freundliche', 'Freundlichen'],
          correctAnswer: 'Freundliche',
        ),
        // ── TEST 15: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['am', 'in', 'zum'],
          correctAnswer: 'am',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['bloß', 'erst', 'schon'],
          correctAnswer: 'schon',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['mein', 'meinem', 'meinen'],
          correctAnswer: 'meinem',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['ihr', 'mich', 'mir'],
          correctAnswer: 'mir',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['Freund', 'Freundin', 'Freundinnen'],
          correctAnswer: 'Freundinnen',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['aber', 'obwohl', 'trotz'],
          correctAnswer: 'obwohl',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['daran', 'darauf', 'darüber'],
          correctAnswer: 'daran',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['wenig', 'wenigen', 'weniger'],
          correctAnswer: 'wenig',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['Damit', 'Oder', 'Sondern'],
          correctAnswer: 'Oder',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['Ab', 'Bis', 'Seit'],
          correctAnswer: 'Bis',
        ),
        // ── TEST 16: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['geschah', 'geschehen', 'geschieht'],
          correctAnswer: 'geschehen',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['dich', 'dir', 'Du'],
          correctAnswer: 'dir',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['halten', 'wären', 'wurden'],
          correctAnswer: 'wurden',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['lange', 'langem', 'langer'],
          correctAnswer: 'langer',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['habe', 'hätte', 'würde'],
          correctAnswer: 'hätte',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['als', 'damit', 'ob'],
          correctAnswer: 'damit',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['für', 'über', 'um'],
          correctAnswer: 'um',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['dem', 'den', 'denen'],
          correctAnswer: 'denen',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['getroffen', 'treffe', 'treffen'],
          correctAnswer: 'treffen',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['bis', 'in', 'an'],
          correctAnswer: 'in',
        ),
        // ── TEST 17: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['ab', 'seit', 'vor'],
          correctAnswer: 'seit',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['ihnen', 'sich', 'uns'],
          correctAnswer: 'uns',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['dauern', 'dauert', 'gedauert'],
          correctAnswer: 'dauern',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['ausgesucht', 'aussuchen', 'aussuchten'],
          correctAnswer: 'aussuchen',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['hat', 'ist', 'wird'],
          correctAnswer: 'hat',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['daran', 'darüber', 'davon'],
          correctAnswer: 'daran',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['das', 'den', 'die'],
          correctAnswer: 'die',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['nächsten', 'nächster', 'nächstes'],
          correctAnswer: 'nächsten',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['worden', 'wurden', 'würden'],
          correctAnswer: 'würden',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['unser', 'unserer', 'unseres'],
          correctAnswer: 'unserer',
        ),
        // ── TEST 18: Aufgabe 21–30 ──
        LesenQuestion(
          prompt: 'Lücke 1',
          options: ['ihnen', 'Ihnen', 'Sie'],
          correctAnswer: 'Ihnen',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: ['das', 'was', 'wie'],
          correctAnswer: 'was',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: ['Danach', 'Obwohl', 'Nämlich'],
          correctAnswer: 'Obwohl',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: ['für', 'mit', 'zu'],
          correctAnswer: 'mit',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: ['erst', 'nach', 'seit'],
          correctAnswer: 'erst',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: ['besonders', 'sondern', 'sonst'],
          correctAnswer: 'sondern',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: ['der', 'deren', 'die'],
          correctAnswer: 'der',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: ['für', 'um', 'zu'],
          correctAnswer: 'um',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: ['an', 'bei', 'vor'],
          correctAnswer: 'bei',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: ['mich', 'mir', 'sich'],
          correctAnswer: 'mir',
        ),
      ],
    ),

    // ── Sprachbausteine Teil 2 – Wortschatz: 1 matn, 10 bo'sh joy (a–o) ──────
    LesenTeil(
      teilNumber: 5,
      sharedText:
          'Sehr geehrte Damen und Herren,\n\n'
          'ich möchte mich für einen Deutschkurs ___(1)___ . Ich ___(2)___ mich '
          'besonders für den Abendkurs, weil ich tagsüber ___(3)___ muss.\n\n'
          'Ich habe schon ein bisschen ___(4)___ mit der deutschen Sprache, aber '
          'ich möchte vor allem mein Sprechen ___(5)___ . Bitte lassen Sie mich '
          '___(6)___ , wann der ___(7)___ beginnt und wie viel ich ___(8)___ '
          'muss.\n\n'
          '___(9)___ kann ich erst ab nächster Woche anfangen. Ich hoffe, das ist '
          'für Sie ___(10)___ .\n\n'
          'Mit freundlichen Grüßen\n'
          'Maria Ivanova',
      questions: [
        LesenQuestion(
          prompt: 'Lücke 1',
          options: _sb2Words,
          correctAnswer: 'anmelden',
        ),
        LesenQuestion(
          prompt: 'Lücke 2',
          options: _sb2Words,
          correctAnswer: 'interessiere',
        ),
        LesenQuestion(
          prompt: 'Lücke 3',
          options: _sb2Words,
          correctAnswer: 'arbeiten',
        ),
        LesenQuestion(
          prompt: 'Lücke 4',
          options: _sb2Words,
          correctAnswer: 'Erfahrung',
        ),
        LesenQuestion(
          prompt: 'Lücke 5',
          options: _sb2Words,
          correctAnswer: 'verbessern',
        ),
        LesenQuestion(
          prompt: 'Lücke 6',
          options: _sb2Words,
          correctAnswer: 'wissen',
        ),
        LesenQuestion(
          prompt: 'Lücke 7',
          options: _sb2Words,
          correctAnswer: 'Unterricht',
        ),
        LesenQuestion(
          prompt: 'Lücke 8',
          options: _sb2Words,
          correctAnswer: 'bezahlen',
        ),
        LesenQuestion(
          prompt: 'Lücke 9',
          options: _sb2Words,
          correctAnswer: 'leider',
        ),
        LesenQuestion(
          prompt: 'Lücke 10',
          options: _sb2Words,
          correctAnswer: 'möglich',
        ),
      ],
    ),
  ],
);
