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

/// Lesen Teil 1 – Test 3 uchun 10 ta sarlavha (a–j) banki.
const _t1Test3Headings = [
  'Zufriedenheit im Job schützt vor Stress',
  'Erfolgreiche Männer können auch gute Väter sein',
  'Keiner lacht so fröhlich wie der Weihnachtsmann',
  'Wie Männer und Frauen lachen',
  'Weniger Arbeit – weniger Stress',
  'Schlechte Nachrichten? Sagen Sie es mit einem Lächeln',
  'Der Beruf ist für Männer wichtiger als die Familie',
  'Auch ältere Menschen leiden unter Stress',
  'Frauen reagieren besser auf schlechte Nachrichten als Männer',
  'Mit 70 Jahren macht das Leben am meistens Spaß',
];

/// Lesen Teil 1 – Test 4 uchun 10 ta sarlavha (a–j) banki.
const _t1Test4Headings = [
  'Hinweis für Besucher der Bregenzer Festspiele',
  'Abendwanderungen ab 89 Euro',
  'Musikveranstaltungen am Nachmittag',
  'Ihre Zeitung folgt Ihnen in den Urlaub',
  'Schlechtes Wetter: Festspiele abgesagt',
  'Rekord: 70.000 Besucher im Bücherdorf',
  'Wandern ohne Gepäck',
  'Neues für Literaturinteressierte',
  'Neue Zeitung für Ihre Urlaubsplanung',
  'Laute Musik stört den Nachbarn',
];

/// Lesen Teil 1 – Test 5 uchun 10 ta sarlavha (a–j) banki.
const _t1Test5Headings = [
  'Angebot für Reisende: Für wenig Geld öffentliche Verkehrsmittel benutzen',
  'Bildband: Babys im Garten',
  'Ein Schüler mit vielen Ideen',
  'Früh übt sich: Hotels bieten Skikurse für Zweijährige an',
  'Handbuch für Hobby-Fotografen',
  'Neu: Mit dem Taxi gratis zur Disco',
  'Neu: Taxi-Tickets für Discobesucher',
  'Schulkinder schreiben spannende Geschichten',
  'Skikurs für Eltern und Kinder',
  'Straßenbahn und Bus im Flugticket enthalten',
];

/// Lesen Teil 1 – Test 6 uchun 10 ta sarlavha (a–j) banki.
const _t1Test6Headings = [
  'Bilder mit dem Computer bearbeiten',
  'Kirche bietet Backkurs für Kinder an',
  'Kirche eröffnet neuen Treffpunkt',
  'Neu: Kochbuch über Wiener Fleischgerichte',
  'Neue Computerprogramme werden getestet',
  'Preis für bestes Lernprogramm',
  'Rezepte für Kuchen und Torten',
  'Studie zeigt: Kaffeetrinker sind glücklicher',
  'Warum die Wiener ins Café gehen',
  'Zürcher Fotografen stellen aus',
];

/// Lesen Teil 1 – Test 7 uchun 10 ta sarlavha (a–j) banki.
const _t1Test7Headings = [
  'Märchen-Festspiele in Bremen',
  'Griechische Botschaft bietet Sprachkurse für Schüler',
  'Universitätsstadt wird 300 Jahre',
  'Wissenschaft: Von der Körpergröße hängt das Gehalt ab',
  'Durch Handel reich geworden',
  'Interessante Universitätsstadt mit hoher Lebensqualität',
  'Latein in deutschen Schulen wieder beliebter',
  'Wer wenig lacht, verdient auch weniger',
  'Fremdsprachen: Schüler lernen nur Englisch und Französisch',
  'Griechisch wird in deutschen Schulen kaum unterrichtet',
];

/// Lesen Teil 1 – Test 8 uchun 10 ta sarlavha (a–j) banki.
const _t1Test8Headings = [
  'Familienbildung: Schwerpunkt Beruf und Familie',
  'Demonstration gegen Fluglärm',
  'Flughafen Frankfurt wird 10 Jahre',
  'Flughafen Frankfurt beliebter Veranstaltungsort',
  'Experten gegen Vergrößerung des Flughafens',
  'Diskussion über Flughafen und Arbeitsplätze',
  'Neue Kurse: Spiele für Mütter und Kinder',
  'Umwelt und Flughafen: Ein Informationsabend der Bürger',
  'Neue Kurse für Kinder',
  'Neue Kurse: Museumsführung für junge Väter',
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
        // ── TEST 3 ──
        LesenQuestion(
          passage:
              'Frauen lachen auf viele Arten. Sie kichern, glucksen und manchmal '
              'singen sie fast. Bei Männern dagegen kommt das viel seltener vor. '
              'Aber gemeinsam ist Männern und Frauen, dass sie in Vokalen lachen, '
              'die im Mundzentrum gebildet werden. Und das ist entscheidend: Nur '
              'wenn die Vokale im Mundzentrum gebildet werden, ist das Lachen für '
              'uns fröhlich und positiv. Damit ist bewiesen, dass das Lachen vom '
              'Weihnachtsmann, dass wie eine tiefes Ho, ho, ho klingt, kaum als '
              'fröhlich empfunden wird. Denn dieser Laut wird im hinteren Teil '
              'des Mundraums gebildet.',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test3Headings,
          correctAnswer: 'Wie Männer und Frauen lachen',
        ),
        LesenQuestion(
          passage:
              'Viel Arbeit, viel Stress. Wer viel arbeitet muss nicht unbedingt '
              'gestresst sein. Frauen in medizinischen Berufen zum Beispiel '
              'klagen trotz teilweise hoher Belastung deutlich weniger über '
              'stressbedingte Krankheiten als Raumpflegerinnen, '
              'Kindergärtnerinnen oder Berufsschullehrerinnen. Dies zeigt eine '
              'Untersuchung des Hamburger IPO-Instituts, das für eine Studie 1000 '
              'Frauen und Männer befragt hat. Vor Stress schützen laut Studie ein '
              'angenehmes Betriebsklima, ein gutes Verhältnis zur Chefin oder zum '
              'Chef und die Möglichkeit, die eigene Arbeit selbstständig zu '
              'planen.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test3Headings,
          correctAnswer: 'Zufriedenheit im Job schützt vor Stress',
        ),
        LesenQuestion(
          passage:
              'Ein neues Buch zeigt, wie Männer Fähigkeiten aus dem Arbeitsleben '
              'auf die Erziehung übertragen können und so zu erfolgreichen Vätern '
              'werden. Da wird die gemeinsame Kindererziehung zur Partnerarbeit '
              '(oder sogar zum Joint Venture), geschicktes Verhandeln heißt, das '
              'Kind zu überzeugen, dass sie Zähne geputzt werden müssen, und der '
              'Familienurlaub hat alle Qualitäten einer Tagung oder eines '
              'Seminars: Man erhält die Gelegenheit, die Kinder intensiv zu '
              'studieren.',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test3Headings,
          correctAnswer:
              'Erfolgreiche Männer können auch gute Väter sein',
        ),
        LesenQuestion(
          passage:
              'Eine Studie der Universität Essex hat ergeben, dass wir mit '
              'siebzig Jahren am glücklichsten sind. Zwar haben die meisten '
              'Menschen in diesem Alter gesundheitliche Probleme, aber dafür '
              'genießen sie viel Freizeit und haben keinen Stress mehr. Deshalb '
              'macht ihnen das Leben so viel Spaß wie nie zuvor. Die Studie '
              'besagt auch, dass wir einen ersten Höhepunkt der Lebensfreude mit '
              'fünfzehn Jahren erreichen. Danach geht es bergab: zwischen dreißig '
              'und fünfzig Jahren tragen wir am meisten Verantwortung, das Leben '
              'ist geprägt von Sachzwängen.',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test3Headings,
          correctAnswer:
              'Mit 70 Jahren macht das Leben am meistens Spaß',
        ),
        LesenQuestion(
          passage:
              'Warum bleiben manche Managerinnen erfolgreich, obwohl sie '
              'Nachrichten mitteilen, die ihr Publikum lieber nicht hören möchte? '
              'Ganz einfach: Sie verkaufen die schlechte Nachricht mit Humor. Ein '
              'Londoner Soziologe hat während einer Studie beobachtet, dass gerade '
              'bei Reden unangenehmen Inhalts oft heiter gelacht wird. Das Lachen '
              'wird bewusst provoziert, etwa durch bestimmte Wörter oder durch '
              'ein eigenes breites Lächeln. Die fröhliche Stimmung soll dafür '
              'sorgen, dass die Zuhörenden das Gefühl haben, würden mehr wissen '
              'als alle anderen.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test3Headings,
          correctAnswer:
              'Schlechte Nachrichten? Sagen Sie es mit einem Lächeln',
        ),
        // ── TEST 4 ──
        LesenQuestion(
          passage:
              'Abonnenten-Service. Wenn Sie verreisen, wünschen wir Ihnen '
              'erholsame und angenehme Feiertage. Bitte denken Sie daran, sich '
              'Ihre Zeitung in den Urlaubsort nachsenden zu lassen. Denn mit den '
              'Neuigkeiten von zu Hause und aus aller Welt lässt sich die '
              'schönste Zeit des Jahres erst richtig genießen. Ganz Europa '
              'kostenlos. Die Höhe des Bezugsgeldes bleibt unverändert. '
              'Ausführliche Informationen und entsprechende Coupons finden Sie in '
              'unserem großen Reise-Service-Anzeigen oder rufen Sie uns einfach '
              'an: Telefon 01 30-18 58 50 zum Nulltarif. Hannoversche Allgemeine '
              'Neue Presse.',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test4Headings,
          correctAnswer: 'Ihre Zeitung folgt Ihnen in den Urlaub',
        ),
        LesenQuestion(
          passage:
              'Im Luftkurort Stadtkyll in der Mittelgebirgslandschaft des Oberen '
              'Kylltals werden dreitägige Wanderungen ohne Gepäck veranstaltet. '
              'Die Rundwanderung im deutsch-belgischen Naturpark führt abends zu '
              'reservierten Zimmern. Die Betriebe übernehmen den Gepäcktransport '
              'zum nächsten Tagesziel. Die Wanderungen werden ganzjährig '
              'angeboten. In dem Wanderprogramm sind drei Übernachtungen mit '
              'Frühstück, dreimal Gepäcktransport, eine Wanderkarte, eine '
              'Wegbeschreibung und ein Wanderpass enthalten. Der Pauschalbetrag '
              'beträgt pro Person 89 Euro. Auskünfte: Verkehrsverein '
              'Erholungsgebiet Oberes Kylltal, Kurallee, 54589 Stadtkyll, '
              'Telefon (06597) 28 78.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test4Headings,
          correctAnswer: 'Wandern ohne Gepäck',
        ),
        LesenQuestion(
          passage:
              'Für den einen ist es musikalischer Hochgenuss, für den anderen '
              'schlicht Lärm. Gemeint ist Musik, die aus Lautsprechern, Radios '
              'oder durch Musikinstrumente durch geöffnete Türen und Fenster bei '
              'sommerlichen Temperaturen ins Freie dringt. Die Gemeinde weist '
              'darauf hin, dass der Mittagsruhe von 13 bis 15 Uhr und nachts von '
              '22 bis 7 Uhr keine musikalische Ruhestörung erfolgen darf. '
              'Gartengeräte mit Motoren dürfen montags bis freitags nur von 8 bis '
              '13 und von 15 bis 19 Uhr benutzt werden, an Sonnabenden von 9 bis '
              '13 Uhr. An Sonn- und Feiertagen dürfen die Geräte nicht zum '
              'Einsatz kommen.',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test4Headings,
          correctAnswer: 'Laute Musik stört den Nachbarn',
        ),
        LesenQuestion(
          passage:
              'Das erste deutsche Bücherdorf hat in Mühlbeck/Friedersdorf '
              '(Sachsen-Anhalt) seit Ende September seine Tore geöffnet. In acht '
              'Antiquariaten warten über 70.000 Bücher aus allen Bereichen der '
              'Literatur auf Interessenten. Das in reizvoller landschaftlicher '
              'Umgebung liegende Bücherdorf nahe Bitterfeld – unweit der A19 und '
              'des Flughafens Leipzig – ist aus allen Teilen Deutschlands leicht '
              'zu erreichen. Geöffnet sind die Antiquariate auch am Samstag und '
              'Sonntag. In Europa gibt es bereits acht solcher Bücherdörfer in '
              'Belgien, Frankreich, Großbritannien, den Niederlanden, Norwegen '
              'und der Schweiz. Initiatorin des deutschen Bücherdorfes ist Heidi '
              'Dehne (Tel. 03493/4 30 43).',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test4Headings,
          correctAnswer: 'Neues für Literaturinteressierte',
        ),
        LesenQuestion(
          passage:
              'Die Bregenzer Festspiele sind bemüht, die Vorstellungen auch bei '
              'zweifelhafter Witterung bzw. leichtem Regen auf der Seebühne '
              'abzuhalten, weshalb es zu Verzögerungen des Beginns oder zu '
              'Unterbrechungen kommen kann. Sollte die Seeaufführung nicht '
              'stattfinden können, wird eine halbszenische Version von Porgy and '
              'Bess im Festspielhaus gegeben. Wir empfehlen unseren Gästen, bei '
              'unsicherer Wetterlage regenfester Kleidung den Vorzug zu geben und '
              'auf Schirme zu verzichten, da diese die Sicht beeinträchtigen. Das '
              'Spiel auf dem See wird ohne Pause gespielt. Die Spieldauer beträgt '
              'ca. 2 Std. 45 Min.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test4Headings,
          correctAnswer: 'Hinweis für Besucher der Bregenzer Festspiele',
        ),
        // ── TEST 5 ──
        LesenQuestion(
          passage:
              'Ich möchte, dass Menschen, die meine Fotos gesehen haben, von nun '
              'an die Welt mit anderen Augen betrachten. Das könnte der '
              'neuseeländischen Fotografin Anne Geddes gelingen. Denn die Bilder, '
              'die sie für das Buch „Drunten im Garten" von den kleinen '
              'Menschenkindern gemacht hat, sind ungewöhnlich und wunderschön: '
              'Babys auf Blumen, Blättern, Beeren, verkleidet als Morcheln, '
              'Melonen oder Marienkäfer, Babys in Tulpen und als Schmetterlinge. '
              'Ein Bildband, angereichert mit poetischen Texten und Ratschlägen.',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test5Headings,
          correctAnswer: 'Bildband: Babys im Garten',
        ),
        LesenQuestion(
          passage:
              'Die meisten Skikurse für Kinder beginnen im Alter von vier '
              'Jahren. Im Kärntner Baby-Dorf Trebesing ist das anders: Hier '
              'werden im Windel-Wedel-Camp bereits Kleinkinder ab zwei Jahren '
              'unterrichtet. Täglich zwei Stunden können die Skihaserln unter '
              'fachkundiger Anleitung auf einem flachen Hügel erste Geh- bzw. '
              'Fahrversuche auf zwei Brettern machen. Nach einigen Tagen Übung '
              'geht es dann mit dem Baby-Bus ins Skigebiet Innerkrems. Auch '
              'Ginas Baby- und Kinderhotel am Faaker See bietet seinen jüngsten '
              'Gästen Skikurse. Fast 1000 Knirpse haben in der Windelschule '
              'schon Skifahren gelernt.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test5Headings,
          correctAnswer:
              'Früh übt sich: Hotels bieten Skikurse für Zweijährige an',
        ),
        LesenQuestion(
          passage:
              'Berlins jüngster Schriftsteller hat deutlich mehr Texte verfasst '
              'als er Jahre zählt. Rund 50 Gedichte und Erzählungen tippte Daniel '
              'Story, 12, schon in seinen Computer. „Ich schreibe fast, seitdem '
              'es mich gibt", sagt der Sechstklässler. Bereits mit sieben '
              'dichtete er die ersten Verse, jetzt mit zwölf ist er stolz auf '
              'seine erste Autorenlesung. Wenn Freunde Fußball spielen, tobt '
              'Daniels Phantasie im Kinderzimmer. Warum er lieber schreibt? '
              'Daniel: „Ich schreibe, weil ich nicht alles erleben kann, was ich '
              'denke."',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test5Headings,
          correctAnswer: 'Ein Schüler mit vielen Ideen',
        ),
        LesenQuestion(
          passage:
              'Ob Sie privat oder geschäftlich unterwegs sind, mit dem '
              'Stadt-Ticket können Sie billig die öffentlichen Verkehrsmittel '
              'nutzen. Voraussetzung: Sie sind mit dem Flugzeug oder der '
              'Deutschen Bahn (über 100 km) angereist. Gegen einen Aufpreis von '
              'nur 2,50 Euro ermöglicht Ihnen das Stadt-Ticket auch nach der '
              'Ankunft am Zielort freie Fahrt mit U-, S- oder Straßenbahnen '
              'sowie Bussen. Bis zu 48 Stunden. Übrigens: Ihr Stadt-Ticket gilt '
              'an zwei aufeinanderfolgenden Tagen, die Sie beim Kauf Ihres '
              'Fahrscheines selbst bestimmen.',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test5Headings,
          correctAnswer:
              'Angebot für Reisende: Für wenig Geld öffentliche Verkehrsmittel benutzen',
        ),
        LesenQuestion(
          passage:
              'In Mecklenburg-Vorpommern können junge Leute jetzt für den halben '
              'Fahrpreis mit dem Taxi auf Discotour gehen. Tickets dafür sind bei '
              'allen Geschäftsstellen der Allgemeinen Ortskrankenkasse (AOK) '
              'sowie an Esso-Tankstellen zum halben Preis erhältlich. Junge '
              'Leute zwischen 16 und 25 Jahren können sie an Wochenenden und '
              'Feiertagen in der Zeit von 20 Uhr bis morgens 6 Uhr benutzen. Die '
              'Taxifahrer erhalten bei ihrer Zentrale dann den vollen Fahrpreis '
              'erstattet.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test5Headings,
          correctAnswer: 'Neu: Taxi-Tickets für Discobesucher',
        ),
        // ── TEST 6 ──
        LesenQuestion(
          passage:
              'Die Kunst- und Medienschule F+F Zürich bietet bereits zum dritten '
              'Mal den Computerkurs Digitale Bildbearbeitung an. Im neuen '
              'Semester steht für zehn Samstage Fotografie, also die digitale '
              'Bearbeitung von Bildern, im Mittelpunkt. Dabei kommen verschiedene '
              'Softwareprodukte zum Einsatz. Der Kurs befasst sich aber nicht nur '
              'mit dem Vermitteln, auch Themen- und Problembereiche rund um die '
              'digitale Foto- und Bildbearbeitung. Kurskosten 800 Franken. '
              'Nähere Informationen und Anmeldung zu diesem Kurs: www.f-f.ch.',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test6Headings,
          correctAnswer: 'Bilder mit dem Computer bearbeiten',
        ),
        LesenQuestion(
          passage:
              'Neuperlach-Süd – Nach dem Einkaufen eine Kaffee genießen, mit '
              'anderen ins Gespräch kommen, sich mit Bekannten treffen oder '
              'einfach entspannen – all das geht ab 11. Juli immer dienstags '
              'zwischen 14 und 18 Uhr im neuen Eiscafé der '
              'Dietrich-Bonhoeffer-Kirche. „Wir wollten damit einen Ort der '
              'Begegnung für Jung und Alt anbieten und zur Belebung des '
              'Stadtteils beitragen", erklärt Pfarrer Sebastian Kühnen. Neben '
              'kalten und heißen Getränken sowie Kuchen steht während der '
              'Öffnungszeiten auch eine Mitarbeiterin für Gespräche zur '
              'Verfügung.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test6Headings,
          correctAnswer: 'Kirche eröffnet neuen Treffpunkt',
        ),
        LesenQuestion(
          passage:
              'Geheimnisse der modernen Konditorkunst: Der Meister des Süßen, '
              'Herwig Gasser, sammelte in Jahren als Bäcker des berühmten Wiener '
              'Café Landmann Mehlspeisenrezepte. Von der Birnentorte über den '
              'Apfelstrudel bis hin zum Heidelbeerstollen. Verlag Kettel, 110 '
              'Fotos, 300 Seiten. ISBN 3-85134-014-0.',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test6Headings,
          correctAnswer: 'Rezepte für Kuchen und Torten',
        ),
        LesenQuestion(
          passage:
              'Am Montag wird in Stuttgart die BildungsDidacta eröffnet. Dort '
              'werden vor allem Lehrmaterialien vorgestellt. Bei vielen sich um '
              'Bildungssoftware. Für ein gelungenes Softwareprojekt wird am der '
              'Bildungssoftwarepreis „digita" vergeben. Dabei handelt es sich um '
              'die wichtige Auszeichnung für Lehr- und Lernprogramme im '
              'deutschsprachigen Raum. Die verzeichnen sich mit dem „digita" '
              'multimediale Gebote aus, die inhaltlich und formal als ragend und '
              'beispielgebend gelten können.',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test6Headings,
          correctAnswer: 'Preis für bestes Lernprogramm',
        ),
        LesenQuestion(
          passage:
              'Das Gallup-Institut hat sich mit dem Kaffeehausverhalten der '
              'Wiener beschäftigt. Ein Vorurteil hat sich dabei bestätigt: Der '
              'Wiener und sein Kaffeehaus sind unzertrennlich. Ergebnisse der '
              'Studie: 27 Prozent gehen an, zumindest einmal im Monat in der '
              'Nähe ihrer Wohnung ein Kaffeehaus zu besuchen. Durchschnittlich 54 '
              'Minuten verweilen die Befragten in ihrem Stammcafé. Der Grund: Ein '
              'Kaffeehaus ist wichtiger als das Plaudern mit Freunden. 77 Prozent '
              'der Befragten nannten dies als Grund für den Besuch im '
              'Kaffeehaus.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test6Headings,
          correctAnswer: 'Warum die Wiener ins Café gehen',
        ),
        // ── TEST 7 ──
        LesenQuestion(
          passage:
              'In Deutschland lernen nur ganz wenige Schüler Griechisch. Es sind '
              'insgesamt nur 0,14% aller Schüler. Vor 30 Jahren waren es noch '
              '0,48%. So berichtet die griechische Botschaft in Berlin in ihrem '
              'Europabericht. Griechisch wird meistens von Zwölftklässlern als '
              'dritte Fremdsprache neben Französisch und Englisch gewählt. Die '
              'wenigen Schüler, die Griechisch wählen, haben Verwandte in '
              'Griechenland.',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test7Headings,
          correctAnswer:
              'Griechisch wird in deutschen Schulen kaum unterrichtet',
        ),
        LesenQuestion(
          passage:
              'Dem Meer verdankt die Hansestadt Bremen ihre Bedeutung. Bremer '
              'Kaufleute und Seefahrer nutzten die günstige geografische Lage, um '
              'in aller Welt heimisch zu werden. Seit Generationen haben sie '
              'Handel getrieben, so dass Geld in die Stadt kam. Dies sieht man '
              'der Stadt heute noch an: das Alte Rathaus, das Kaufmannshaus, die '
              'historische Innenstadt. Außerdem war Bremen auch immer eine Heimat '
              'für Künstler – natürlich das Märchen der Bremer Stadtmusikanten.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test7Headings,
          correctAnswer: 'Durch Handel reich geworden',
        ),
        LesenQuestion(
          passage:
              'Freiburg, die Hauptstadt des Schwarzwaldes, liegt in einer der '
              'sonnigsten Gegenden Deutschlands. Wo es so viel Sonne gibt, da ist '
              'auch viel Lebensfreude, und nicht zuletzt gehören auch badische '
              'Küche und badischer Wein zum Besten, was in Deutschland geboten '
              'wird. Zum einmaligen Flair der gemütlichen Universitätsstadt trägt '
              'auch ihre Lage bei. Frankreich und die Schweiz sind nicht weit '
              'entfernt. Die Stadt selbst lockt mit vielen alten Straßen, mit '
              'zahlreichen Museen und Baudenkmälern. Über alles hinaus ragt die '
              'große Kirche, die nach 300-jähriger Bauzeit 1513 vollendet wurde.',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test7Headings,
          correctAnswer:
              'Interessante Universitätsstadt mit hoher Lebensqualität',
        ),
        LesenQuestion(
          passage:
              'In einer wissenschaftlichen Untersuchung hat man erforscht, warum '
              'bestimmte Menschen mehr Geld verdienen als andere. Britische '
              'Wissenschaftler behaupten, größeren Menschen zahlt der Chef mehr. '
              'Im Laufe des vergangenen Jahres haben zwei weitere Untersuchungen '
              'festgestellt: Wer wenig lacht oder häufig mit Kollegen trinken '
              'geht, verdient mehr. Nur: Nicht lachen und mit Kollegen trinken '
              'gehen – das kann man lernen. Aber wachsen?',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test7Headings,
          correctAnswer:
              'Wissenschaft: Von der Körpergröße hängt das Gehalt ab',
        ),
        LesenQuestion(
          passage:
              'Das Statistische Bundesamt berichtet, dass in deutschen Schulen '
              'allgemein wieder mehr Latein gelernt wird. Allein in Thüringen hat '
              'sich die Anzahl in den letzten beiden Jahren verdoppelt. Während '
              'der Tiefpunkt bei Latein im vorletzten Jahr erreicht war, wählen '
              'zurzeit wieder mehr Schüler Latein als erste Fremdsprache. Als '
              'vorteilhaft hat sich offenbar vor allem das wittenbergische Modell '
              'erwiesen, das Latein in der fünften Klasse mit einer modernen '
              'Fremdsprache (Französisch, Englisch usw.) kombiniert. Allerdings '
              'sind hier meist nur drei Stunden für beide Sprachen pro Woche '
              'vorgesehen. „Das sei bei Weitem zu wenig", kritisieren '
              'Lateinlehrer.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test7Headings,
          correctAnswer: 'Latein in deutschen Schulen wieder beliebter',
        ),
        // ── TEST 8 ──
        LesenQuestion(
          passage:
              'Der Frankfurter Flughafen wird weiter ausgebaut. Eine Gruppe von '
              'Frankfurter Bürgern aus den östlichen Stadtteilen, die sich seit '
              'Jahren aktiv für den Naturschutz und die Umwelt einsetzt, lädt für '
              'Donnerstag dieser Woche um 19.30 Uhr zu einem Informationsabend '
              'über den Ausbau des Frankfurter Flughafens ein. Im Bürgerhaus '
              'Ostend, Parkstraße 24, Clubraum 12, werden verschiedene Sprecher '
              'zu hören sein. Die Gruppe möchte Antworten auf folgende Fragen '
              'suchen: Wie viel Lärm durch Flugzeuge verträgt die Stadt? Oder: '
              'Welche Auswirkungen hat der Flugverkehr auf Umwelt und Natur?',
          prompt: 'Welche Überschrift passt zu Text 1?',
          options: _t1Test8Headings,
          correctAnswer:
              'Umwelt und Flughafen: Ein Informationsabend der Bürger',
        ),
        LesenQuestion(
          passage:
              'Der Frankfurter Flughafen erfreut sich bei vielen Firmen als '
              'beliebter Ort für Veranstaltungen und Tagungen. Dies zeigt ein '
              'Bericht des Frankfurter Flughafens, der beim zehnjährigen '
              'Jubiläum des Kongresszentrums vorgelegt wurde. Im Jubiläumsjahr '
              'haben am Frankfurter Flughafen 6800 Veranstaltungen mit insgesamt '
              '72.000 Teilnehmern stattgefunden. Im Kongresszentrum, das direkt '
              'gegenüber dem Hauptgebäude des Flughafens liegt, gibt es 28 '
              'Konferenzräume für bis zu 200 Teilnehmer. Modernste Technik wie '
              'Laptop-Anschlüsse und Internetzugänge in allen Konferenzräumen '
              'sind ebenso vorhanden wie ein Dolmetscherdienst und verschiedene '
              'Speisemöglichkeiten.',
          prompt: 'Welche Überschrift passt zu Text 2?',
          options: _t1Test8Headings,
          correctAnswer: 'Flughafen Frankfurt beliebter Veranstaltungsort',
        ),
        LesenQuestion(
          passage:
              'Eine Bürgergruppe mit dem Namen „Südliches Frankfurt" lädt für '
              'Montag kommender Woche um 19.30 Uhr ins Pfarrhaus St. Mauritius, '
              'Mauritiusstraße 14, zu einer öffentlichen Expertenbefragung zum '
              'Thema „Arbeitsplätze am Frankfurter Flughafen" ein. Der Gruppe '
              'liegen Berichte und Daten vor, die nach den Worten der Sprecher '
              'der Gruppe sehr fantastisch und zweifelhaft sind. Deshalb hat die '
              'Bürgergruppe den Personalleiter des Frankfurter Flughafens, einen '
              'Experten aus dem Wirtschaftsministerium, einen bekannten '
              'Stadtentwicklungsplaner und einen Soziologen eingeladen. Im '
              'Anschluss an die Vorträge der Experten haben die Gäste Zeit, '
              'Fragen zu stellen.',
          prompt: 'Welche Überschrift passt zu Text 3?',
          options: _t1Test8Headings,
          correctAnswer: 'Diskussion über Flughafen und Arbeitsplätze',
        ),
        LesenQuestion(
          passage:
              'Das neue Halbjahresprogramm der Evangelischen '
              'Familienbildungsstätte bringt eine Übersicht über viele '
              'Veranstaltungen. Neben Kursen wie Geburtsvorbereitung und '
              'Babypflege steht diesmal das Thema „Berufstätige Eltern" im '
              'Mittelpunkt. In Gruppen und Kursen vor allem für Frauen geht es '
              'darum, wie sich nach der Geburt eines Kindes Beruf und Familie '
              'miteinander vereinbaren lassen. Das Verhältnis zwischen Mann und '
              'Frau spielt eine große Rolle im Angebot der Familienbildung. Auch '
              'zum Verhältnis der Generationen gibt es wieder Angebote. Darüber '
              'hinaus wartet das Programm mit Kursen für Entspannung und '
              'Zeitmanagement auf.',
          prompt: 'Welche Überschrift passt zu Text 4?',
          options: _t1Test8Headings,
          correctAnswer:
              'Familienbildung: Schwerpunkt Beruf und Familie',
        ),
        LesenQuestion(
          passage:
              'Die Volkshochschule Dornbirn bietet in den kommenden Wochen neue '
              'Kurse an. Am Mittwoch nächster Woche beginnen zwei Malkurse für '
              'Kinder. Für Kinder im Alter zwischen eineinhalb und sechs Jahren '
              'und ihre Väter beginnt am Samstag um 10.00 Uhr eine feste '
              'Vater-Kind-Gruppe. Etwas anderes ist die Kultur- und '
              'Kreativwerkstatt am Montag nächster Woche. Aus Ton und Erde sollen '
              'Figuren nach afrikanischen Beispielen gebastelt werden. Zur '
              'Vorbereitung treffen sich die Teilnehmer am kommenden Montag '
              'zuerst im Museum. Anmeldung spätestens morgen bis 15.00 Uhr.',
          prompt: 'Welche Überschrift passt zu Text 5?',
          options: _t1Test8Headings,
          correctAnswer: 'Neue Kurse: Museumsführung für junge Väter',
        ),
      ],
    ),

    // ── Teil 2 – Detailverstehen (ko'p testli): har TEST 1 matn + 5 savol ────
    LesenTeil(
      teilNumber: 2,
      questionsPerTest: 5,
      testTexts: [
        // ── TEST 1 ──
        'Leipzigerin geht in den USA auf Sendung\n'
            'Drei Monate Praktikum für junge Sachsen im Land der unbegrenzten '
            'Möglichkeiten\n\n'
            '„Manchmal fühle ich mich wie ein Missionar", scherzt Ulrike Rudelt. '
            'Das Bild vom Deutschen, der Lederhosen trägt, Bier trinkt und '
            'Sauerkraut isst, hält sich ihrer Meinung nach in der Öffentlichkeit '
            'Amerikas ganz stark und wird vor allem in der Fernsehwerbung ständig '
            'wiederholt. „Dagegen kämpfe ich", sagt die 25-Jährige '
            'selbstbewusst, die derzeit ein dreimonatiges Praktikum am Institute '
            'of International Studies in Kalifornien absolviert und so oft es '
            'geht über die Heimat erzählt.\n\n'
            'An der Uni in Monterey darf die Leipziger Studentin neben dem '
            'Hospitieren auch selbst unterrichten. Das Interesse der Studenten '
            'und Dozenten an der deutschen Sprache, an Geschichte und Gegenwart '
            'Deutschlands ist groß. Richtig in Fahrt kommt Ulrike, wenn es um den '
            'Mauerfall geht und darum, wie sich der Osten nach der Wende '
            'entwickelt hat. „Die Chancen, die ich jetzt habe, hatten meine '
            'Eltern nicht", sagt sie. So ging sie nach dem Studium als '
            'Au-Pair-Mädchen nach England und machte im Rahmen studentischer '
            'Austauschprogramme bereits Praktika in den USA und den '
            'Niederlanden.\n\n'
            '„Einen Vorgeschmack vom American Way of Life gab es bereits während '
            'des einwöchigen Einführungsseminars in New York", schwärmt Cornelia '
            'Schiemenz. „Die Stadt pulsiert, und wir hatten jede Menge Spaß." Auf '
            'dem Programm standen Ausflüge, und dazu hörten sie jede Menge '
            'Vorträge zum Welthandel, Kampf gegen Arbeitslosigkeit, zur '
            'wirtschaftlichen Entwicklung der USA und Kriminalitätsbekämpfung. In '
            'Denver, wo die Studentin für Kommunikations- und Medienwissenschaft '
            'die Arbeit eines TV-Senders kennen lernt, steht sie nach einigen '
            'Tagen selbst vor der Kamera und darf Beiträge für den Sender '
            'produzieren. „Ich bin absolut glücklich", sagt die 23-Jährige.\n\n'
            'Antje Kutzer, die dritte Leipzigerin in der Gruppe, hat es nach Los '
            'Angeles verschlagen. Nach dem Abitur hat sie Reiseverkehrskauffrau '
            'gelernt. In der Reisekette New World Travel sammelt sie erste '
            'Erfahrungen. „Anfangs", erzählt die 23-Jährige, „hatte ich großes '
            'Heimweh, es sind doch einige Kilometer weg von Leipzig. Doch dann '
            'stellte ich mich der Chefin im besten Englisch vor, worauf sie auf '
            'Deutsch antwortete, dass es sie wahnsinnig freut, dass ich ihr über '
            'die Schulter sehen will."\n\n'
            'Die drei Frauen zählen zu den 20 jungen Berufsanfängern aus '
            'Ostdeutschland, die unter 2100 Bewerbern der Pall-Mall-Initiative '
            'ausgewählt wurden und ein dreimonatiges Praktikum in den Staaten '
            'absolvieren. Bei der Auswahl der Praktikanten legt man auch auf '
            'Auslandserfahrung Wert. Schließlich geht es nicht darum, dass die '
            'Teilnehmer ein paar schöne Wochen im Land der unbegrenzten '
            'Möglichkeiten erleben. Die Unternehmen stellen zumeist hohe '
            'Anforderungen.',
        // ── TEST 2 ──
        'Das machen wir mit links\n'
            'Über eine Million Österreicher sind Linkshänder – und langsam '
            'setzen sie sich durch in der Rechtshänder-Welt\n\n'
            '„Schau, der macht das mit der linken Hand." Solche und ähnliche '
            'Kommentare hörte der gelernte Porzellanformer Gerhard Spur (51) von '
            'Besuchern, die die Porzellanmanufaktur im Wiener Augarten '
            'besichtigten und dem Künstler beim Herstellen eines Kunstwerkes '
            'zusahen – allerdings nur früher, als nur die rechte Hand die so '
            'genannte „schöne Hand" war, die man zum Arbeiten, Schreiben usw. '
            'verwenden durfte. Heute ist es offensichtlich normal, dass jemand '
            'mit der linken Hand Vasen aus Porzellan bearbeitet. Gerhard Spur '
            'wird jedenfalls nicht mehr bestaunt.\n\n'
            'Gut 15 Prozent der Menschheit sind Linkshänder. Über die Gründe für '
            'Linkshändigkeit ist sich die Wissenschaft nicht einig. Fest steht '
            'nur: Wenn Kinder gezwungen werden, statt mit der linken Hand mit der '
            'rechten Hand zu schreiben, hat dies schwerwiegende Folgen. „Dies '
            'führt zu Knoten im Kopf", so die Linkshänder-Expertin Johanna '
            'Barbara Sattler. Spätestens wenn umgeschulte Kinder mit dem Lesen '
            'und Schreiben beginnen, macht sich das Chaos im Kopf bemerkbar. In '
            'der Schule ist es mittlerweile verboten, Linkshänder auf rechts '
            'umzuschulen. „Probleme machen allerdings noch Arbeitsplätze, die '
            'nicht für Linkshänder geeignet sind", erklärt Erich Pospischill, '
            'Leiter des arbeitsmedizinischen Zentrums Mödling: „Schon die '
            'Computermaus auf der falschen Seite führt zu rascherer Ermüdung, '
            'weil das Gehirn durch das ständige Umdenken zusätzlich belastet '
            'wird."\n\n'
            'Die Maschine, an der Slata Tanasic tagtäglich arbeitet, funktioniert '
            'von links unten nach rechts oben. Genau verkehrt für die 41-Jährige, '
            'die seit 21 Jahren im Seibert-Elektronikwerk arbeitet. „Ich habe '
            'gesagt, dass ich mit der Maschine so nicht arbeiten kann. Und das '
            'wurde akzeptiert." Slata wurde in einen anderen Arbeitsbereich '
            'versetzt und macht jetzt Arbeiten, die auch mit der linken Hand '
            'möglich sind: Montieren und Vorbereiten der Bauteile.\n\n'
            '„Bei Kleinkindern lässt sich nicht sofort erkennen, ob sie links- '
            'oder rechtshändig sind", sagt die Expertin Sattler: „Viele Kinder '
            'ahmen zuerst die Tätigkeiten in unserer rechtshändigen Welt nach." '
            'Deshalb rät Sattler den Eltern, ihren Kindern beim Herausfinden '
            'ihrer Händigkeit zu helfen: Blumen gießen mit einer kleinen Kanne, '
            'einen Ball werfen – bei diesen Handlungen greifen Kinder automatisch '
            'mit der starken Hand zu.',
        // ── TEST 3 ──
        'Die neue Sir-Karl-Popper-Schule\n'
            'Ein Schulversuch für besonders kluge Schüler\n\n'
            'WIEN. Es ist eine ganz normale Schulstunde – Geschichte – in einer '
            'ganz normalen Klasse. Während der Lehrer einen Vortrag über das '
            'alte Rom hält, unterhalten sich die Schüler über den Schulball, '
            'kritisieren die Kleidung des Lehrers, reichen Zettel unter der '
            'Schulbank weiter.\n\n'
            '„Auch überdurchschnittlich intelligente Kinder sind ganz normale '
            'Kinder", betont Elfriede Wegricht, Psychologin in der '
            'Sir-Karl-Popper-Schule, die im vergangenen September ihren Betrieb '
            'aufgenommen hat. „Nur weil sie in der Schule gut sind, heißt das '
            'nicht, dass sie nicht genauso wie alle anderen Schüler Liebeskummer, '
            'Ärger mit den Eltern und andere Pubertätsprobleme haben." Der '
            'Unterschied zwischen normalen und hochbegabten Schülern: Letztere '
            'mussten sich in ihrer bisherigen Schulkarriere nicht besonders '
            'anstrengen und sind es nicht gewohnt, mit ihrer Zeit gut '
            'hauszuhalten.\n\n'
            'Um überdurchschnittlich intelligente Kinder nun entsprechend zu '
            'fördern, sieht das Konzept der Sir-Karl-Popper-Schule mehr '
            'Fremdsprachen, projektorientiertes Arbeiten in kleinen Klassen und '
            'vor allem mehr Eigenverantwortung für den Lernenden vor. Dazu kommt '
            'die Förderung der individuellen Fähigkeiten: Wer in einem Fach gut '
            'ist und sich besonders für ein Thema interessiert, bekommt '
            'Sonderaufgaben und tiefer gehende Unterlagen. Anfangs war der '
            'plötzliche Mehraufwand ein Schock für die Schüler, die eine '
            '40-Stunden-Woche zu bewältigen haben. „Aber es ist besser, sie '
            'erleben den Schock jetzt als zu Beginn des Studiums", meint Herr '
            'Peters, Lehrer und Schülerbetreuer an der Popper-Schule, „denn oft '
            'scheitern besonders kluge Menschen später, weil sie mit ihrer '
            'Intelligenz nichts anzufangen wissen." Denn zumeist erreichten sie '
            'mit wenig Aufwand und Mitarbeit relativ gute Ergebnisse.\n\n'
            'Zielgruppe der Sir-Karl-Popper-Schule sind Kinder, die in mindestens '
            'einem Fach hochbegabt sind und überdurchschnittlich gute Ergebnisse '
            'haben. Nach einer Aufnahmeprüfung wurden von 64 Bewerbern 28 '
            'aufgenommen, die von insgesamt 28 Lehrern betreut werden. „In diesen '
            'Klassen können die überdurchschnittlich intelligenten Schüler dann '
            'endlich so sein, wie sie sind, ohne bei jeder Wortmeldung von ihren '
            'Klassenkameraden beschimpft zu werden", meint die Schulpsychologin. '
            'Ziel des Schulversuchs sei es jedoch laut Peters nicht, besonders '
            'kluge Schüler von normalen Kindern zu trennen, sondern Erfahrung im '
            'Umgang mit der Begabtenförderung zu sammeln und diese in die '
            'Normalschule zu übernehmen.',
        // ── TEST 4 ──
        'Philipp Reis – der wahre Erfinder des Telefons?\n'
            'Erfinder, Lehrer, Familienvater – Auf den Spuren von Philipp Reis '
            'besuchte Susanne Müller seinen Geburtsort.\n\n'
            '„Weil sein Vater nie aufgeschrieben habe, was er machte, ist mancher '
            'gute Gedanke verloren gegangen", klagt später einmal Karl Reis. Auch '
            'gibt es wenige offizielle Berichte und Dokumente über Philipp Reis '
            'in Friedrichsdorf und in seiner Geburtsstadt Gelnhausen. Das gilt '
            'besonders für das private Leben der Familie Reis, die ab 1852 in '
            'unmittelbarer Nähe des berühmten Garnier-Instituts in Friedrichsdorf '
            'ein Haus gefunden hatte. Berichte des Sohnes Karl Reis erzählen ein '
            'wenig mehr über das Leben des Erfinders. Karl Reis, der beim Tod des '
            'Vaters erst elf Jahre alt war, berichtet von einem lieben und '
            'gerechten Vater, der sich sehr um seine Frau und seine Kinder '
            'gesorgt hat. Wenn der Vater aber seine Experimente machte, vergaß er '
            'alles um sich herum.\n\n'
            'Philipp Reis lernte bereits als Junge viele technische Maschinen '
            'kennen und machte eine Reihe von Experimenten, die er als Lehrer am '
            'Garnier-Institut fortsetzte. Er entwickelte eine große Anzahl von '
            'technischen Geräten, die im Institut gut verwendet werden konnten. '
            'Auf die Schüler machte Philipp Reis einen oft sehr merkwürdigen '
            'Eindruck. Verunsichert waren die Schüler besonders dann, wenn Reis '
            'Aufsicht hatte, aber selbst im Klassenraum gar nicht anwesend war. '
            'Trotzdem konnte Reis alles hören und wusste, was passiert war. '
            'Philipp Reis hatte eine besondere Kamera gebaut, mit der er von '
            'seinem Arbeitszimmer aus, in dem er gleichzeitig Experimente '
            'durchführte, in die Klassenräume schauen konnte. Ein Draht, der über '
            'den Schulhof in sein Arbeitszimmer führte, diente als Vorläufer des '
            'späteren Telefons. Bei den Schülern und Lehrern entstand so der Ruf, '
            'dass der Reis auf geheimnisvolle Weise alles sehen kann.\n\n'
            '1883 schrieb der englische Professor Silvanus Thompson einen Bericht '
            'über Reis und nannte ihn den wahren Erfinder des Telefons. Philipp '
            'Reis habe das Telefon entwickelt, und nicht Graham Bell oder Thomas '
            'Edison. Diese beiden amerikanischen Forscher hätten auch bei ihren '
            'Arbeiten zur Entwicklung des Telefons auf Philipp Reis\' Experimente '
            'in Deutschland hingewiesen. Seine offizielle Anerkennung als '
            'Erfinder des Telefons hat Philipp Reis allerdings nicht mehr erlebt. '
            'Im Jahre 1874 ist er in Friedrichsdorf an einer Lungenkrankheit '
            'gestorben.',
        // ── TEST 5 ──
        'Anne und Melanie (beide 6) stehen Erzieherinnen mit Vorschlägen '
            'hilfreich zur Seite\n'
            'Von Christiane Altenberger\n\n'
            'Sie sind die Problemlöser im Kindergarten an der Munckerstraße. Wenn '
            'das Malprogramm spinnt, plötzlich ein Spiel auftaucht, das keiner '
            'kennt, dann rufen die Erzieherinnen nach Anne und Melanie. Die sind '
            'zwar erst sechs Jahre alt, aber mit den Computerspielen kennen sie '
            'sich aus. „Die Kinder wissen manchmal mehr als wir", sagt Eva '
            'Schilling, Leiterin des Kindergartens. Gelernt haben die beiden ihr '
            'Know-how bei „Multimedia-Landschaften für Kinder", einem Projekt, '
            'das das Schulamt zusammen mit dem Studio im Netz gestartet hat.\n\n'
            'Im Rahmen dieses Projekts werden in städtischen Kindergärten zwei '
            'Wanderstationen mit je drei Multimedia-Computern und einem '
            'Farbdrucker installiert. Die Stationen wandern durch 14 '
            'Kindergärten, wo sie jeweils für vier Wochen installiert werden. '
            '„Vierjährige am Computer? In Pädagogenkreisen sind viele '
            'Berührungsängste da", weiß Edith Ilg, Fachberaterin für '
            'Kindergärten beim Schulamt, „aber wir können uns aus dieser '
            'Entwicklung nicht ausklinken. Die Kinder wollen sich mit ihrer '
            'Umwelt auseinandersetzen." 193 Kinder waren eingeladen, um erste '
            'Erfahrungen am Computer zu sammeln. „Die Kinder waren absolut '
            'begeistert, haben immer wieder gefragt, wann gehen wir da wieder '
            'hin", so Frau Ilg.\n\n'
            'Bevor jedoch die Computer in die Kindergärten kamen, waren die '
            'Eltern aufzuklären. Bei manchen Eltern löste das Stichwort Computer '
            'akute Ängste aus nach dem Motto: Mein fröhliches, gesundes Kind '
            'setzt sich vor den Computer und steht sechs Stunden später krank, '
            'sprachlos und einsam wieder auf. Diese Ängste haben sich inzwischen '
            'gelegt. Die Erzieherinnen achten auch darauf, dass die Kinder nie '
            'länger als 15 bis 20 Minuten vor den Computern sitzen, und holen vor '
            'allem kreative Software auf den Bildschirm.\n\n'
            'Das einsame Dämmern vor dem Computer ist wohl ohnehin eher Sache der '
            'Erwachsenen – die Kinder spielen immer zu zweit oder zu dritt an der '
            'Maschine. Eva Schilling hat beobachtet, dass die Kinder am Computer '
            'sehr friedlich miteinander umgehen, sie helfen sich gegenseitig, es '
            'gibt wenig Konflikte. Dabei entwickeln gerade Kinder, die sich sonst '
            'nur schwer auf etwas konzentrieren können, plötzlich ungeahnte '
            'Konzentrationszeiten. Eva Schilling kann sich deshalb die Computer '
            'als Dauereinrichtung im Kindergarten vorstellen.',
        // ── TEST 6 ──
        'Haustiere in Deutschland\n\n'
            'Egal ob Hund, Katze oder Maus: Haustiere sind in Deutschland sehr '
            'beliebt. Markus Kleinoth aus der Freizeitredaktion hat sich mit '
            'diesem Thema beschäftigt.\n\n'
            'In deutschen Haushalten gibt es rund 34 Millionen Haustiere. '
            'Besonders Katzen sind sehr beliebt, denn davon leben 14 Millionen in '
            'Deutschland. Und das, obwohl Deutschland als Land der Hundefans '
            'gilt. Insgesamt gibt es aber etwa 10 Millionen Hunde.\n\n'
            'Für den Hund ist manchen Menschen nichts zu teuer. Eine '
            'Hundebesitzerin, die überdurchschnittlich viel Geld für ihren '
            'Liebling ausgibt, ist Bettina Schröther: „Morgens vor der Arbeit '
            'bringe ich meinen Hund in eine sehr gute Tagesbetreuung, in der es '
            'auch eine Hundeschule gibt. Aber wenn ich frei habe, sind wir immer '
            'zusammen, auch im Urlaub. Ich war mit ihm sogar schon in einem '
            'Wellnesshotel für Hunde."\n\n'
            'Der Hundeexperte Marius Klotz kennt solche Fälle, sieht das aber '
            'kritisch: „Viele Besitzer meinen es gut und tun zu viel für ihre '
            'Hunde. Hier sollte man aufpassen. Für einen Hund ist es sehr '
            'wichtig, eine gute Erziehung zu bekommen. Wichtig sind klare Regeln, '
            'die er verstehen kann. Außerdem braucht er viel Bewegung und '
            'unbedingt passendes Futter. Frisches Futter ist nicht unbedingt das '
            'beste, da sollte man sich gut informieren, am besten Fachleute '
            'fragen." Viele Menschen sehen ihre Katzen und Hunde als Teil der '
            'Familie. So auch Ellie Herfried, Hundebesitzerin aus Erfurt: „Unsere '
            'Familie feiert jedes Jahr mit unserem kleinen Schatz Geburtstag. Er '
            'bekommt einen Geburtstagshundekuchen, natürlich mit Kerzen, und auch '
            'ein Geschenk. Dieses Jahr haben wir außerdem seine Hundefreunde '
            'eingeladen."\n\n'
            'Auch in einigen Seniorenheimen sind mittlerweile Tiere erlaubt. '
            'Sandra Bärenweger ist Altenpflegerin in Hamburg: „Bei uns im Haus '
            'haben einige Senioren einen Hund oder eine Katze. Dadurch haben sie '
            'eine Aufgabe, denn sie müssen sich ja um ihr Tier kümmern, es '
            'füttern oder mit ihm rausgehen, wenn es ein Hund ist. So haben sie '
            'jeden Tag eine sinnvolle Beschäftigung. Das tut den älteren Menschen '
            'gut; viele bleiben dadurch fit."\n\n'
            'Der tägliche Spaziergang mit dem Hund oder das Spielen mit der Katze '
            'bietet vielen Haustierbesitzern Ruhe und Entspannung, eine kleine '
            'Erholung vom Alltag. Das bestätigen auch Fachleute: „Haustiere '
            'können gerade bei Stress für viele Menschen ein guter Ausgleich '
            'sein. Die tägliche Beschäftigung mit seinem Haustier wie '
            'beispielsweise das Spazieren mit dem Hund und die Zuneigung, die man '
            'von ihm bekommt, spielen dabei eine wichtige Rolle." Das Haustier '
            'ist dabei auch viel mehr als ein Hobby, da es ein Lebewesen ist, das '
            'schnell zum Familienmitglied wird und das Leben bereichert.',
        // ── TEST 7 ──
        'Geheimnisse des Schlafes\n'
            'Schlafstörungen – die meisten Ursachen sind harmlos\n\n'
            'Lange Zeit hat man geglaubt, dass der Schlaf nur so etwas ist wie '
            'der kleine Bruder des Todes: ein Zustand, in dem der Körper Energie '
            'spart und alles langsamer läuft. Erst in den 50er Jahren des letzten '
            'Jahrhunderts fand man heraus, dass Schlafen etwas sehr Aktives ist '
            'und Nacht für Nacht in unterschiedlichen Abschnitten verläuft. Der '
            'Schweizer Schlafforscher Alexander Borbely hat diesen Vorgang mit '
            'einer Treppe verglichen, über die wir jede Nacht mehrmals gehen.\n\n'
            'Zunächst sind wir wach, dann schlafen wir ein und gehen bis tief '
            'hinab in den Keller in einen tiefen Schlaf. Danach geht es wieder '
            'hoch in einen leichten Schlaf, der von lebhaften, intensiven Träumen '
            'und schnellen Augenbewegungen begleitet wird. Daher wird diese Phase '
            'auch REM-Schlaf (rapid eye movements = schnelle Augenbewegung) '
            'genannt. Dieser Abschnitt ist im Gegensatz zu den anderen Phasen mit '
            'etwa 20 Minuten sehr kurz, soll aber äußerst wichtig für die '
            'physische Erholung sein.\n\n'
            'Damit hat die Wissenschaft aber noch lange nicht alle Probleme des '
            'Schlafes gelöst. Erwiesen ist nur: Wir brauchen ihn zur '
            'körperlichen Erholung, auch wenn wir ihn manchmal als '
            'Zeitverschwendung empfinden – immerhin verbringen wir ein Drittel '
            'unseres Lebens mit Schlafen.\n\n'
            'Warum können wir aber nicht immer sofort einschlafen, wenn wir müde '
            'sind? Tatsächlich klagen viele Menschen in den westlichen '
            'Industrienationen über gelegentliche oder dauernde Schlafstörungen.'
            '\n\n'
            'So muss unser Körper, insbesondere das Gehirn, die Eindrücke des '
            'Tages erst einmal verarbeiten, damit wir gesund schlafen. Dieses '
            'System reagiert so sensibel, dass schon kleine Ursachen – äußere und '
            'innere – störend wirken können. Äußere Ursachen können sein: Lärm, '
            'eine ungewohnte Umgebung, ein zu spätes, zu reichliches Essen, Kälte '
            'oder Wärme – alles wirkt sich auf unser Wohlbefinden und somit auch '
            'auf den Schlaf aus.\n\n'
            'Als innere Ursachen kommen Schmerzen, Angst oder Ärger über '
            'ungelöste Konflikte in Frage. Erkrankungen beeinflussen den Schlaf, '
            'auch Medikamente können eine störende Rolle spielen. Alles, was uns '
            'gedanklich stark beschäftigt, kann unseren Schlaf beeinträchtigen. '
            'Wer aber nur gelegentlich nachts aufwacht oder auch einmal einige '
            'Tage schlecht schläft, braucht sich keine Sorgen zu machen. Ein paar '
            'schlaflose Nächte lassen sich schnell wieder nachholen.\n\n'
            'Eine echte Schlafstörung liegt erst dann vor, wenn unsere '
            'Leistungsfähigkeit oder unsere Gesundheit auf Dauer stark '
            'beeinträchtigt werden. Dann sollte man auf jeden Fall ärztlichen Rat '
            'suchen.',
        // ── TEST 8 ──
        'Informationsveranstaltungen sind wichtige Grundlagen für die Berufswahl'
            '\n\n'
            'Die Entscheidung, welchen Beruf man erlernen will, ist nicht leicht. '
            'Große Firmen bieten spezielle Informationsveranstaltungen für '
            'Schülerinnen und Schüler an. Wir haben einen Info-Nachmittag der '
            'Bank Credit Suisse in Bern besucht und uns danach bei den '
            'Jugendlichen umgehört.\n\n'
            '20 Schülerinnen und Schüler kann Irene Leiser um Punkt 13 Uhr zu '
            'diesem Info-Nachmittag begrüßen. Die Jugendlichen kommen aus dem '
            'ganzen Kanton Bern und haben sich vorher bei der Bank angemeldet. '
            'Viermal im Frühling und zwei weitere Male im August werden diese '
            'Info-Veranstaltungen bei der Credit Suisse durchgeführt. Sie richten '
            'sich vor allem an Schülerinnen und Schüler aus der 8. Klasse. Irene '
            'Leiser hat gute Erfahrungen mit diesen Veranstaltungen gemacht: Die '
            'Jugendlichen können danach ihre Erwartungen an den Beruf und die '
            'Ausbildung an die Realität anpassen.\n\n'
            'Im ersten Teil des Nachmittags erklärt Frau Leiser die '
            'Hauptaufgaben einer Bank und stellt die Firma vor. Danach treten die '
            'Lehrlinge in Aktion: Daniel Sommer und Linda Schmidt sind im zweiten '
            'Lehrjahr und erzählen aus ihrem Berufsalltag. Dieser Teil gefällt '
            'den Schülerinnen und Schülern besonders gut.\n\n'
            'Die Jugendlichen identifizieren sich mit den Lehrlingen und sehen, '
            'wo sie selber in zwei Jahren beruflich stehen könnten. Das fasziniert '
            'sehr. Zum Schluss folgen Informationen darüber, welche '
            'Voraussetzungen man mitbringen muss und wie man sich bewirbt. Um '
            '16:30 Uhr schließt Frau Leiser die Veranstaltung. Sie ist zufrieden '
            'mit dem Nachmittag. Die Gruppe war sehr aufmerksam. Interessierten '
            'Schülerinnen und Schülern gibt sie folgenden Tipp: Gehen Sie auch '
            'noch zu anderen Firmen. Fragen Sie dort möglichst viele Lehrlinge '
            'und Mitarbeiter nach ihren Erfahrungen. Wir haben danach eine '
            'Schülerin und einen Schüler befragt, wie sie den Nachmittag erlebt '
            'haben:\n\n'
            'Tugba Kaptan aus Biel, 8. Klasse:\n'
            'Mich fasziniert das Umfeld einer Bank. Ich hätte mehr Leute bei der '
            'Arbeit sehen wollen, zum Beispiel am Schalter. Aber der Tag hat mir '
            'weitergeholfen. Ich habe viele Dinge erfahren, die ich bisher nicht '
            'gewusst habe. Solch ein Nachmittag ist ideal, weil da schulfrei ist.'
            '\n\n'
            'Alan Blank aus Mühleberg, 8. Klasse:\n'
            'Die Bank ist eigentlich mein Traumgebiet und bietet mir nach der '
            'Lehre viele Entscheidungsmöglichkeiten. Ich habe mich umgeschaut und '
            'mich über viele Berufe informiert. Jetzt weiß ich, dass ich eine '
            'Lehre in diesem Bereich machen will. Ich suche nach der optimalen '
            'Lehrstelle. Eine Großbank wäre toll für mich. Dieser Nachmittag hat '
            'mir gefallen. Alles war sehr gut organisiert. Ich kann solche '
            'Veranstaltungen nur empfehlen. Was mir persönlich gefehlt hat, ist '
            'eine Führung durch den Betrieb. Es ist wichtig zu sehen, wie das '
            'alles genau vor sich geht.',
        // ── TEST 9 ──
        'Beruf am Flughafen: Kinderbetreuerin\n'
            'Dem Kind zuliebe in Kloten warten\n\n'
            'Auf keinem anderen Flughafen sei der Aufenthalt familienfreundlicher '
            'als in Kloten, sagen viele Eltern. Weil die Wartezeit wie im Flug '
            'vergeht – dank der 18 Kinderbetreuerinnen.\n'
            'Von Gabriella Hofer\n\n'
            '24.000 Kinder aus der ganzen Welt wurden letztes Jahr auf dem '
            'Flughafen Zürich-Kloten betreut. Die 18 Mitarbeiterinnen, die sich '
            'im Schichtbetrieb ablösen, stehen den Eltern und ihren Kindern '
            'täglich von 6.30 bis 22 Uhr mit Rat und Tat zur Seite. Die '
            'vielsprachigen Betreuerinnen – viele von ihnen sind ausgebildete '
            'Krankenschwestern, Kleinkindererzieherinnen oder Flugbegleiterinnen '
            '– verfügen auch über Erste-Hilfe-Kenntnisse. Der Flughafen '
            'Zürich-Kloten ist der einzige in Europa, der seinen kleinsten Gästen '
            'in beiden Terminals einen eigenen Aufenthaltsraum bietet.\n\n'
            'Aufenthalt und Betreuung sind kostenlos. In beiden Räumen stehen '
            'vier Wickeltische mit Papierwindeln, eine Küche zum Aufwärmen der '
            'Kindermahlzeiten, sechs Bettchen, ein Laufgitter, Nachttöpfe und '
            'Toiletten für Kleinkinder zur Verfügung. Außerdem gibt es zahlreiche '
            'Stofftierchen, Schaukelpferdchen, Bauklötze, Puppenstuben, einen '
            'großen Stall, Bilderbücher, Spiele und vieles mehr.\n\n'
            'Es ist ein Erlebnis für die Kinder, mit Kindern zu spielen, die eine '
            'andere Muttersprache sprechen oder aus einem anderen Kulturkreis '
            'kommen, weiß Alice Martin (40). Die ehemalige Kinderschwester, '
            'selber Mutter eines sechsjährigen Sohnes, gehört seit 14 Jahren zum '
            'Team der Betreuerinnen. Zusammen mit 17 Kolleginnen ist sie '
            'abwechselnd in den beiden Kinderspielzimmern der Terminals A und B '
            'beschäftigt.\n\n'
            'Bevor Alice Martin 1994 von der Flughafendirektion angestellt wurde, '
            'war sie viele Jahre auf einer Geburtenabteilung und später noch in '
            'einem Behindertenheim beschäftigt. Die Kontakte zu den jetzt von ihr '
            'betreuten Kindern seien nicht mehr so intensiv wie früher im Spital '
            'oder im Heim, dafür biete ihr die heutige Tätigkeit mehr Abwechslung.'
            '\n\n'
            'Die kinderliebende Frau reist selber gern und viel. Auch ihre '
            'Fremdsprachenkenntnisse kommen ihr hier zugute. Alice Martin spricht '
            'neben ihrer Muttersprache Englisch, Französisch und Spanisch. Sehr '
            'bereichernd sei, dass sie in ihrer täglichen Arbeit andere Kulturen '
            'kennenlerne.',
        // ── TEST 10 ──
        'Mehr Platz und Schutz für Bienen\n\n'
            'Seit einiger Zeit hört man immer wieder, dass Bienen vom Aussterben '
            'bedroht sind. Welche Folgen hat dies für die Menschheit und was wird '
            'dagegen unternommen?\n\n'
            'Bienen spielen eine sehr wichtige Rolle für unsere Umwelt. Weltweit '
            'stirbt seit Jahren ein großer Teil der Bienenbevölkerung. Warum so '
            'viele Bienen sterben, lässt sich nicht so einfach sagen. Hier '
            'spielen mehrere Faktoren eine Rolle, wie zum Beispiel der Gebrauch '
            'von Pestiziden in der Landwirtschaft, fehlende Wiesen und '
            'Grünflächen, Luftverschmutzung und Klimawandel.\n\n'
            'In den letzten Jahren sind vor allem in den Städten verschiedene '
            'Aktionen ins Leben gerufen worden, um den Lebensraum von Bienen zu '
            'vergrößern. Schon heute finden Bienen in vielen Städten genug '
            'Nahrung, weil immer mehr Menschen dafür sorgen. „Bienen sind '
            'spannend", sagt Sebastian Werner. „Man sieht sie nicht immer, sie '
            'sind oft im Verborgenen und haben etwas Geheimnisvolles." „Die Biene '
            'ist für viele Menschen auch ein Symbol für Wildnis", sagt Thorsten '
            'Gottlieb. „Und es ist schön für uns Menschen, das zu erleben. '
            'Faszinierend, ihnen zuzuschauen, Bienen zu beobachten, stundenlang", '
            'sagt Manfred Kessel.\n\n'
            'Manche Wissenschaftler sind der Überzeugung, dass die Menschheit '
            'ohne die Arbeit der Bienen keine vier Jahre überleben könne. Denn '
            'ohne Bienen würde ein Großteil unserer Nahrung wegfallen. Diese drei '
            'sind mit dem Thema vertraut, da sie das jährliche Frankfurter '
            'Bienenfestival vorbereiten. Gottlieb und Werner sind Gründer der '
            'Initiative und Kessel ist der Gastgeber und Leiter des Botanischen '
            'Gartens, wo das Festival stattfindet.\n\n'
            'Die Beschäftigung mit Bienen wirkt entspannend im stressigen Tempo '
            'des Alltags. Außerdem ist die Welt, wie sie ist, ohne Bienen gar '
            'nicht vorstellbar. Sie sorgen für die Verbreitung hunderttausender '
            'Pflanzen, die Mensch und Tiere zur Ernährung brauchen.\n\n'
            'In Frankfurt besteht seit vielen hundert Jahren eine Tradition der '
            'Bienenhaltung. Für Einsteiger gibt es ein großes Angebot an Kursen.'
            '\n\n'
            '„Du brauchst Grundlagen und eine gute Ausbildung, sonst machst du '
            'einfach zu viele Fehler", warnt Thorsten Gottlieb. „Du hast eine '
            'riesengroße Verantwortung", fügt Sebastian Werner hinzu. „Du musst '
            'wissen, was du da tust – nicht nur, weil du für bis zu 60.000 Bienen '
            'in einem einzigen Volk zu sorgen hast. Alle Bienenvölker im Umkreis '
            'sind betroffen, wenn dein Volk krank ist."',
        // ── TEST 11 ──
        'Weltreise? Lieber ein Praktikum in Kuala Lumpur!\n'
            'Umfrage unter Abiturienten: Welche Pläne gibt es für die Zeit nach '
            'der Schule? Jura-Studium sehr beliebt\n\n'
            '„Nachdem ich das Abitur nun bestanden habe, fühle ich mich befreit. '
            'Jetzt gehe ich einen Monat nach San Francisco, um Freunde zu '
            'besuchen. Danach wartet ein Praktikum bei der Lufthansa in Kuala '
            'Lumpur auf mich, weil ich Luftverkehrsmanagement studieren möchte." '
            'Das sagt die 19-jährige Aynur Üstüner, die gerade erst ihr Abitur '
            'gemacht hat. Nicht nur für Aynur, sondern auch für 85 weitere '
            'Schüler der Heinrich-Mann-Schule (HMS) und der '
            'Rudolf-Steiner-Schule (RSS) fängt nun das Berufs- oder '
            'Universitätsleben an. Alle können sehr stolz auf sich sein: Zweimal '
            'gab es sogar die Bestnote 1,0. Insgesamt lag der Durchschnitt bei '
            '2,5 und war damit etwas besser als im Vorjahr. Durchgefallen ist '
            'keiner, nur ein Teilnehmer hat das Abitur abgebrochen. Für alle '
            'Grund genug, um den Erfolg richtig zu feiern. Während die '
            'Steiner-Schüler eine ganz ruhige Feier machten, drehten die '
            'Abiturienten der Heinrich-Mann-Schule im Bürgerhaus so richtig auf '
            'und präsentierten dem Publikum eine filmreife, fantastische Show. '
            'Bilder von den beiden Partys zeigen wir ab heute in unserer '
            'Bilder-Galerie im Internet. Nun haben also alle ihre Zeugnisse und '
            'endlich einmal richtig ausgeschlafen. Kein Wunder: In den letzten '
            'Wochen haben die Abiturienten nächtelang gelernt und gleichzeitig '
            'Abschied gefeiert – das war sehr anstrengend. Aber jetzt müssen '
            'wichtige Entscheidungen getroffen werden: Eine Ausbildung machen? '
            'Studieren? Oder vielleicht doch lieber eine Weltreise unternehmen? '
            'Wir haben außer Aynur Üstüner noch vier weitere Abiturienten nach '
            'ihren Plänen gefragt. Hier sind ihre Antworten:\n\n'
            'Christopher Hallgarten (20, RSS): „Ich bin froh, dass das Abitur '
            'vorbei ist. Nach einem kurzen Urlaub werde ich erstmal zwei Praktika '
            'in Krankenhäusern machen. Danach möchte ich Medizin studieren. Am '
            'liebsten in Bayreuth, da soll es schön gemütlich sein."\n\n'
            'Inka Schröder (18, RSS): „Jetzt werde ich erstmal die freien Wochen '
            'bis zum Studium genießen. Wahrscheinlich wird es Jura werden. '
            'Natürlich will ich später auch einige Zeit im Ausland studieren. '
            'Eine Pause nach dem Abitur brauche ich nicht unbedingt, schließlich '
            'freue ich mich auf mein Studium."\n\n'
            'Fabian Sänger (20, HMS): „Ich mache zunächst ein Freiwilliges '
            'Soziales Jahr. Auf diese Zeit freue ich mich schon sehr. Danach will '
            'ich unbedingt Sport studieren, weiß aber noch nicht, welche Uni mich '
            'aufnehmen wird. Ich lasse mich einfach überraschen, wohin die Reise '
            'geht."\n\n'
            'Alexander Michels (19, HMS): „Ich habe mich für das Fach Jura '
            'entschieden und werde dafür nach München ziehen. Zuerst brauche ich '
            'aber ein paar Wochen Urlaub, um mich von dem Abi-Stress zu erholen. '
            'Die Schule werde ich nicht vermissen!"',
        // ── TEST 12 ──
        'Verheiratet mit Handy und Computer\n\n'
            'Die Woche mit sechzig bis achtzig Arbeitsstunden war für Volkmar '
            'Bergmann ganz normal. Der Gründer und Chefingenieur einer '
            'Software-Firma hatte von montags bis freitags einen Zwölfstundentag '
            'und arbeitete auch an Samstagen und Sonntagen. Das Geschäft ging '
            'sehr gut. Die Firma wurde immer größer: 1.100 Mitarbeiterinnen und '
            'Mitarbeiter – darauf konnte Volkmar Bergmann wirklich stolz sein.\n\n'
            'Die Arbeit machte ihm Spaß, jedenfalls so lange, bis sein Sohn '
            'geboren wurde. Auf einmal fing er an, die Dinge in einem anderen '
            'Licht zu sehen, und versuchte, aus dem Stress mit Nacht- und '
            'Wochenendarbeit herauszukommen. Jahrelang gelang ihm das nicht. '
            'Erst als er sich entschlossen hatte, sein Leben vollkommen zu '
            'ändern, wurde es besser: Heute arbeitet Bergmann nur 20 Stunden die '
            'Woche, als Berater für die Firma, die ihm früher einmal gehörte. Er '
            'hat Zeit für die Kinder und sagt: „Ich bin zufriedener als jemals '
            'zuvor in meinem Leben."\n\n'
            'Glück gehabt. Anderen Vielarbeitern ist eine solche Änderung nicht '
            'möglich, sie bleiben mit ihrem Schreibtisch verheiratet. „Ein '
            '24-Stunden-Arbeitstag ist der Trend", sagt Bryan E. Robinson, '
            'Professor in den USA. Millionen von Arbeitnehmern geben ihre ganze '
            'Kraft für ihren Job. Wir leben in einer Welt, die vor allem den '
            'Menschen alle Chancen bietet, für die die Arbeit das Wichtigste im '
            'Leben ist, den so genannten Workaholics. Diese Menschen können '
            'Gutes nur noch in ihrer Arbeit tun. Sie haben längst die Fähigkeit '
            'verloren, ein Privatleben zu führen und sich um ihre Familie und '
            'die Freunde zu kümmern.\n\n'
            'Die Schwierigkeiten der Menschen, die an der Krankheit '
            'Workaholismus leiden, nehmen ständig zu. Immer mehr Menschen laufen '
            'Gefahr, von ihrer Arbeit regelrecht aufgefressen zu werden. Das '
            'Ende dieser Entwicklung lässt sich leicht absehen: Die Mitarbeiter '
            'werden häufiger krank, Arbeitsfreude und Motivation nehmen ab, es '
            'kommt zu Fehlern und Pannen. Das Familienleben leidet.\n\n'
            'Moderne Technik und Medien machen es möglich: Durch das Handy ist '
            'man überall und jederzeit erreichbar. Mit Laptops und '
            'Mini-Computern ist man unabhängig vom Arbeitsplatz und kann von '
            'jedem Ort der Welt aus im Internet surfen oder seine elektronische '
            'Post erledigen. Die räumliche Grenze zwischen dem Zuhause und dem '
            'Büro besteht für viele nicht mehr. Der Arbeitsplatz wird als '
            'Zuhause angesehen und das Zuhause wird zum Arbeitsplatz. Eigentlich '
            'waren die neuen Medien dazu gedacht, die Arbeit einfacher zu '
            'machen. In Wirklichkeit führen sie dazu, dass die Arbeit immer '
            'tiefer in den Bereich der Freizeit eindringt. Ein Privatleben, in '
            'dem man von der Arbeit einmal ganz abschalten kann, gibt es schon '
            'heute für viele nicht mehr.\n\n'
            'Inzwischen gibt es Seminare für Arbeitskranke, in denen die '
            'Teilnehmenden lernen sollen, wieder zu leben und nicht nur zu '
            'funktionieren. Der Psychologe Ulrich Beer gibt seinen Patienten in '
            'einer solchen Situation einen einfachen Rat: Im Kalender müssen '
            'genau so viele private wie berufliche Termine stehen. Familie und '
            'Beruf sind gleich wichtig.',
        // ── TEST 13 ──
        'Computerkurse sind schon für Kinder spannend\n'
            'Schreiben, Rechnen, Programme installieren\n\n'
            'Schaden oder nützen Computer unseren Kindern? Das fragen sich viele '
            'Eltern. Ein Computerkurs-Veranstalter ist sich ganz sicher: Wenn '
            'man den Kindern beibringt, den Computer richtig einzusetzen, ist er '
            'sogar eine Lernhilfe. Seit fünf Jahren bietet Franz Krapfenbauer '
            'Computerkurse für Kinder zwischen sieben und vierzehn Jahren an und '
            'ist von seinen Schülern begeistert. Am liebsten würden die Kinder '
            'drei Stunden ohne Pause durcharbeiten. Und das, obwohl in seinen '
            'Kursen nicht gespielt wird, sondern der Computer als Lernhilfe '
            'genutzt wird. Im ersten Kurs lernen die Kinder den Umgang mit dem '
            'Betriebssystem und erste Grundzüge der Textverarbeitung.\n\n'
            'Das Geheimnis von Krapfenbauer: „Ich erkläre die Programme in der '
            'Sprache der Kinder und langweile sie nicht mit technischen '
            'Details." Sein Talent entdeckte er, als sich seine eigenen Kinder '
            'für den PC zu interessieren begannen. Seine Tochter brachte immer '
            'mehr Mitschüler zum sonntäglichen PC-Training mit, bis eines Tages '
            'klar war: Das muss auf professionelle Beine gestellt werden.\n\n'
            'Das Schwierigste war, einen passenden und vor allem kostengünstigen '
            'Raum zu finden, denn Geld brachten die Kinderkurse am Anfang sehr '
            'wenig ein. Ein Bekannter, der Direktor eines Hotels ist, hatte '
            'schließlich die passende Lösung: Die Schulungsräume im Hotel stehen '
            'den Kindern nun an den Wochenenden zur Verfügung. Allgemein rät '
            'Krapfenbauer, Kinder so früh wie möglich an den Computer zu lassen, '
            'allerdings nur unter Aufsicht und mit den richtigen Programmen. '
            'Beim Computer ist es wie beim Fernseher: Wenn man ihn als '
            'Kindermädchen einsetzt, ohne sich darum zu kümmern, was die Kinder '
            'damit machen, kann das negative Folgen haben. Schon für drei- bis '
            'vierjährige Kinder gebe es sehr gute Spielprogramme, die mit '
            'Vorschulaufgaben vergleichbar wären.\n\n'
            'Gerade in der Zeit nach Weihnachten haben Krapfenbauers '
            'Kindercomputerkurse Hochsaison. Viele Eltern haben einen Computer '
            'unter den Christbaum gestellt und wollen jetzt, dass ihre Kinder '
            'frühzeitig damit umgehen lernen. Wobei der Seminarleiter für manche '
            'Eltern sogar zu viel Wissen weitergibt: Einige Eltern haben sich '
            'schon beschwert, weil ihre Kinder jetzt Hausaufgaben am Computer '
            'lösen. Die manchmal befürchtete Überforderung der Kinder hat '
            'Krapfenbauer noch nicht erlebt. Ganz im Gegenteil, die Kleinen sind '
            'oft gar nicht zu stoppen, wenn sie wieder etwas Neues erlernt '
            'haben. Viele Teilnehmer kommen dann auch gern zu den nächsten '
            'Kursen. Zeichenprogramme oder Spiele kommen in den Computerkursen '
            'höchstens als Belohnung am Rande vor.\n\n'
            'Das größte Hindernis auf dem Weg zum Computerexperten ist für die '
            'Kinder in manchen Fällen die negative Einstellung der Eltern. „Die '
            'Erwachsenen kennen oft nur die komplizierten Datenbankanwendungen '
            'und Programme aus dem Büro und können sich gar nicht vorstellen, '
            'was man mit dem Computer noch alles machen kann", bedauert '
            'Krapfenbauer. Natürlich wirkt sich diese negative Grundeinstellung '
            'auch auf die Kinder aus. Überraschenderweise sind es dann oft die '
            'Großeltern, die für Computerkurse das Geld geben, damit ihre '
            'Enkelkinder mit dem PC richtig umgehen lernen.',
        // ── TEST 14 ──
        'Mit dem Solarauto um die Welt\n\n'
            'CO2-Ausstoß: null. Geplante Strecke: einmal um die Welt. Endlich '
            'wird der Traum von Louis Palmer wahr: Der Schweizer startet mit '
            'seinem Auto, das mit Sonnenenergie fährt, zur Weltumrundung. Er '
            'will damit zeigen, dass Autofahren auch geht, ohne der Umwelt zu '
            'schaden.\n\n'
            '„Entwickelt für mich ein Fahrzeug für eine Weltreise, das mit '
            'Sonnenenergie fährt", forderte Louis Palmer Studenten an Schweizer '
            'Universitäten auf. Das war vor drei Jahren. Heute ist das Auto '
            'fertig: ein dreirädriges Fahrzeug mit zwei Sitzplätzen. Und die '
            'Weltreise? Am 3. Juli starten er und sein siebenköpfiges Team in '
            'Luzern: Das Auto soll als erstes Solarfahrzeug die Welt umrunden.\n\n'
            '„Die ganze Welt wartet auf revolutionäre Erfindungen für ein '
            'umweltbewusstes Auto", sagt der Schweizer, „ich will darauf '
            'aufmerksam machen, dass die technischen Lösungen schon jetzt '
            'vorhanden sind." Mit 14 Jahren hatte Louis den Entschluss gefasst: '
            'Gegen die Veränderung des Klimas muss etwas getan werden. Die '
            'Lösung hatte er auch schon: Mit kräftigen Strichen zeichnete er ein '
            'Rennauto, verziert mit lachenden Sonnen. Der Rest war nur eine '
            'Frage der Organisation und der konsequenten Lebensplanung. „Ich '
            'unterteile mein Leben in drei Phasen", sagt Palmer und lacht über '
            'sich selbst: „zwischen 20 und 30 die Welt kennen lernen, zwischen '
            '30 und 40 die Welt aufmerksam machen und zwischen 40 und 50 die '
            'Welt verändern."\n\n'
            'Phase eins begann mit 23 Jahren: Er zog aus, um 50 Länder auf allen '
            'Kontinenten zu bereisen. „Anstatt an die Uni zu gehen, habe ich die '
            'Welt studiert." Mit dem Fahrrad fuhr er von Kenia nach Kapstadt, '
            'mit einem Segelflugzeug überflog er Südamerika und als Fotograf '
            'reiste er mehrmals nach Afghanistan.\n\n'
            'Phase zwei startete vor drei Jahren: Palmer konnte Studenten von '
            'vier Universitäten gewinnen, die für ihn das Auto bauten. '
            '„Schwierig war es aber, Firmen und private Sponsoren für die '
            'finanzielle Unterstützung zu finden", meint Palmer. Doch auch das '
            'hat dann schließlich geklappt.\n\n'
            'Nun ist Palmer bereit für die Tour. „Ich habe keine Ahnung, was auf '
            'uns zukommt", sagt der erfahrene Globetrotter, der sechs Sprachen '
            'spricht. „Ich habe schon etwas Angst, z. B. vor dem Straßenverkehr '
            'in Millionenstädten oder unvorhersehbaren Zwischenfällen. Das '
            'Schlimmste ist aber, wenn jeder Tag wie der andere ist." In den '
            'nächsten 16 Monaten wird es dazu nicht kommen.',
        // ── TEST 15 ──
        'Die Angst vor Buchstaben abbauen\n'
            'Etwa 800.000 Menschen in der Schweiz haben zwar die Schule '
            'besucht, können aber dennoch nicht richtig lesen und schreiben. '
            'Einige holen das Versäumte später nach.\n'
            'Von Gabriela Baumgartner\n\n'
            '„Das Qualifikationsgespräch mit dem Chef sei sehr positiv '
            'gewesen", erzählt Kurt Hunziker seiner Gruppe. „Auch beim Sprechen '
            'fühle ich mich heute viel sicherer." Der 33-Jährige lächelt und '
            'blickt noch etwas unsicher in die Runde. „Es hat sich wirklich '
            'gelohnt."\n\n'
            'Neben ihm sitzt Sonja Kündig. Seit bald zwei Jahren sind die '
            'Teilnehmerinnen und Teilnehmer dieses Kurses damit beschäftigt '
            'nachzuholen, was sie alle im Laufe ihres Lebens irgendwann einmal '
            'aufgegeben hatten: Lesen und Schreiben. Einmal pro Woche besuchen '
            'sie den Kurs, tauschen Erfahrungen aus und motivieren sich '
            'gegenseitig.\n\n'
            'Fast zehn Jahre lang arbeitete Sonja Kündig bei einer Schweizer '
            'Großbank. „Ich verstand einfache Texte wie Witze in Zeitschriften." '
            'Schreiben aber konnte die heute 45-jährige Mutter zweier Söhne nur '
            'gerade mal ihre Adresse. Dafür hatte sie einen außergewöhnlichen '
            'Sinn für Genauigkeit und ein gutes Gedächtnis für Zahlen. '
            'Problematisch wurde es erst, als sie ihren Mann kennenlernte. „Ich '
            'hatte furchtbare Angst, ihm die Wahrheit zu sagen. Würde er mich '
            'für dumm halten?"\n\n'
            'Ihr Mitstreiter Michael Feller schwankt noch immer ständig zwischen '
            'Hoffnung und Verzweiflung. Weil seine Eltern häufig den Wohnort '
            'wechselten, hatte der 36-Jährige große Probleme in der Schule. „Als '
            'ich vor vier Jahren hierher kam, konnte ich gar nichts. Ich schämte '
            'mich, lebte sehr zurückgezogen und hatte kaum Bekannte." In der '
            'Zwischenzeit hat er aufgeholt und kann sich jetzt auch mündlich '
            'besser verständigen. Zum ersten Mal in seinem Leben traut er sich, '
            'mitzureden und seine Meinung zu sagen. Zufrieden ist Michael Feller '
            'aber noch nicht. Beim Lesen einer Zeitung oder eines Buches hat er '
            'noch immer Probleme. „Manchmal verstehe ich einzelne Wörter nicht." '
            'Verzweifelt wirft er in solchen Situationen den Text weg. „Manchmal '
            'kommt es mir vor, als würde ich einen Teufel in meinen Händen '
            'halten."\n\n'
            '„Lese- und Schreibschwächen drücken auf das Selbstwertgefühl", '
            'erklärt Silvia Herdeg, Kursleiterin am Verein Lesen und Schreiben '
            'für Erwachsene. In diesen Kursen wird deshalb nicht nur stur '
            'Grammatik gelernt. Trainiert wird ein neuer Kommunikationsstil. '
            '„Die Leute sind erleichtert, dass sie hier mit ihrem Problem nicht '
            'alleine sind. Mit jedem Fortschritt öffnen sie sich ein Stück '
            'weiter. Nach zwei Jahren sind viele wie verwandelt." Einige '
            'Teilnehmende haben überhaupt erst nach dem Kurs gewagt, eine '
            'anspruchsvollere Stelle zu suchen. Andere haben ihre Unabhängigkeit '
            'zurückgewonnen. „Früher habe ich nie mit Kollegen über einen '
            'Zeitungsartikel diskutieren können", erklärt Christian Koller. '
            '„Meine Angst war zu groß, ich könnte etwas falsch verstanden haben '
            'und mich dadurch lächerlich machen. Heute rede ich mit."',
        // ── TEST 16 ──
        'Die Sendung mit der Maus\n'
            'Eine Ausstellung über die berühmte Fernsehserie\n\n'
            'SPEYER. Mit dem Fragebogen in der Hand marschieren die '
            'Grundschüler durch das Historische Museum in Speyer. „Wie heißt '
            'doch noch mal der, der die Maus gezeichnet hat?", fragt Anna. Lisa '
            'entdeckt den Namen neben dem Zeichenpult. „Friedrich Streich", '
            'kritzelt sie auf ihr Blatt – allerdings erst, nachdem sie sich bei '
            'einem erwachsenen Ausstellungsbesucher vergewissert hat, dass diese '
            'Information auch richtig ist.\n\n'
            '„Maus Oleum" heißt die Ausstellung im Jungen Museum, die sich mit '
            'einem Stück Fernsehgeschichte beschäftigt. Sie zeigt über 30 Jahre '
            'Geschichte der „Sendung mit der Maus". In den farbenfrohen Räumen '
            'wird gezeigt, was und wer hinter den Lach- und Sachgeschichten '
            'steckt. Eine Weltkarte beweist, dass die Maus international bekannt '
            'ist. Kaum ein Land, in dem die beliebte Kindersendung nicht zu '
            'sehen ist.\n\n'
            'Die orangefarbene Maus erklärt die Welt, indem sie '
            'selbstverständlich gewordene Dinge hinterfragt. Mit welchen Mitteln '
            'dies geschieht, das zeigt die Ausstellung. Was steckt in einer '
            'Parkuhr? Wie funktioniert eine Luftpumpe? Woraus wird Creme '
            'gemacht? Wie kommen die Löcher in den Käse? Mit solchen und anderen '
            'Fragen verblüfft und fasziniert die Maus auch ihre großen '
            'Zuschauer, die sich schlagartig daran erinnern, dass sie einst '
            'entschieden neugieriger waren. Wie Detektive, die im Auftrag der '
            'Kinder ganz genau hingucken, gehen die Macher an jede Sendung '
            'heran. Sie wollen genauso viel wissen und verstehen wie die Kinder '
            'selbst. Deshalb wird zum Beispiel die Parkuhr einfach aufgeschraubt '
            'oder das Innere einer Fahrradpumpe gezeigt.\n\n'
            'An Vorschlägen, was die Maus erklären könnte, fehlt es nicht. Woche '
            'für Woche kommen Briefe aus aller Welt. Einige davon sind auch in '
            'der Ausstellung zu lesen. „Liebe Maus", heißt es da, „wir sind '
            'heute an einem Druckzentrum vorbeigefahren. Bitte sage uns doch, '
            'wie eine Zeitung gemacht wird." Seit 1971 ist die Maus aktiv: Sie '
            'reist in die Vergangenheit oder blickt in die Zukunft, sie '
            'beantwortet Fragen und lässt Kinder aus verschiedenen Ländern '
            'selbst erzählen. Auch schwierige Themen wie Politik sind dank der '
            'Maus kinderleicht zu verstehen.\n\n'
            'Überall da, wo man in der Ausstellung etwas anfassen und '
            'ausprobieren kann, wo kleine und große Geheimnisse gelüftet werden, '
            'dort staunen die kleinen Besucher. Bilder werden zum Laufen '
            'gebracht, Töne erzeugt und Kameras getestet.\n\n'
            'Die Maus ist inzwischen auch bei Künstlern beliebt. Sie ist auf '
            'Bildern, Postkarten und Plakaten auf der ganzen Welt zu sehen. '
            'Schöner aber sind die kleinen Kunstwerke aus Kinderhand, die die '
            'Fernsehmacher im Laufe der Jahre gesammelt haben: bunte Bilder aus '
            'Papier und sogar ein Puppentheater ganz aus Pappe – alles für die '
            'Maus.\n\n'
            'Öffnungszeiten: Die Ausstellung in Speyer ist noch bis zum 27. '
            'Oktober geöffnet. Dienstags bis sonntags von 10 bis 18 Uhr, '
            'mittwochs bis 20 Uhr.',
        // ── TEST 17 ──
        'Du oder Sie – das ist hier die Frage\n'
            'Sprachliche Regeln am Arbeitsplatz\n\n'
            'Häufig erscheint Ingvar Kamprad, Ikea-Gründer und -Besitzer, am '
            'Morgen unangemeldet am Hintereingang einer seiner Filialen: „Guten '
            'Morgen, ich bin der Ingvar." Das schwedische Möbelhaus ist das '
            'beste Beispiel für die Du-Kultur am Arbeitsplatz, denn alle '
            'Beschäftigten sprechen sich mit Du an. Die Gesellschaft für '
            'deutsche Sprache in Wiesbaden hat nun in einer Untersuchung '
            'festgestellt, dass mehr als 53 Prozent der befragten Personen alle '
            'Arbeitskollegen duzen. Wie zu erwarten, sind es vor allem die 16- '
            'bis 29-Jährigen (59 Prozent), die sich lieber schnell duzen. Bei '
            'den über 60-Jährigen sank die Zahl auf 14 Prozent.\n\n'
            'Warum eigentlich sagt man am Arbeitsplatz immer öfter Du? Zum '
            'Beispiel pflegen Ikea, Greenpeace und McDonald\'s alle das '
            'obligatorische Du. Damit wollen sie Vertrauen aufbauen und ein '
            'familiäres Umfeld schaffen. Gegenüber den Kunden ist man jedoch '
            'vorsichtiger geworden. So hat Ikea im Verkaufskatalog statt dem Du '
            'wieder das Sie eingeführt. Man hofft, mit Sie mehr Leute – nicht '
            'nur jüngere – anzusprechen.\n\n'
            'Bis heute üblich ist das Du zum Beispiel in Schweizer '
            'Gewerkschaften. Viele Mitglieder sind sogar beleidigt, wenn sie '
            'mit Sie angesprochen werden. Es gibt aber auch den umgekehrten '
            'Fall, und zwar bei der Polizei. Wer in Deutschland einen '
            'Polizisten duzt, riskiert eine Strafe. In der Schweiz hingegen '
            'findet man eine Anzeige wegen Duzens eines Beamten übertrieben. '
            '„Polizisten werden sowieso kaum mit Du angesprochen", meint '
            'Hanspeter Fäh von der Zürcher Stadtpolizei.\n\n'
            'Der Trend zum Du kann jedoch auch als sozialer Druck oder Zwang '
            'empfunden werden. Ein Du abzulehnen gilt nämlich als unfreundlich. '
            'Das hat Dieter S., Angestellter bei einem Textilgeschäft in '
            'Deutschland, erfahren. Ein Gericht entschied, dass er seine '
            'Kollegen weiterhin mit Du ansprechen musste.\n\n'
            'So sehr das Du in der Gesellschaft auch an Bedeutung gewinnt, das '
            'Sie hat immer noch eine feste soziale Basis und kann diese sogar '
            'ausbauen. Benimmkurse, wo man Höflichkeit und die richtigen '
            'Umgangsformen lernt, sind heute im Trend. Immer mehr Firmen '
            'schulen ihre Mitarbeiter in stilvollem Verhalten. Dazu gehören '
            'folgende Grundregeln: Die ältere Person bietet der jüngeren das Du '
            'an. Oft ist jedoch auch die Stellung entscheidend: Der ältere '
            'Mitarbeiter bietet seinem jüngeren Chef nie das Du an.',
        // ── TEST 18 ──
        'Neue Berufe\n'
            'Raumberater für harmonisches Wohnen\n\n'
            'Räume nach der chinesischen Lehre Feng-Shui zu gestalten, damit '
            'sich die Menschen wohl fühlen – das ist der Beruf von Iris '
            'Eigenmann.\n\n'
            '„Seit knapp einem Jahr bin ich nun selbstständig und bin voller '
            'Energie. So stehe ich jeden Tag mit einem Lächeln auf und gehe '
            'abends wieder mit einem Lächeln ins Bett." Die diplomierte '
            'Raumberaterin Iris Eigenmann ist von ihrem Beruf sichtlich '
            'begeistert. Da viele mit dem Wort Fengshui nichts anfangen können, '
            'bezeichnet sie sich selbst als Raumberaterin für harmonisches '
            'Wohnen. Ihre Aufgabe ist es, Wohnungen, aber auch Büros und andere '
            'Arbeitsplätze so einzurichten, dass sich Menschen in diesen Räumen '
            'wohl fühlen können.\n\n'
            'Ursprünglich ist Frau Eigenmann gelernte Hochbauzeichnerin und hat '
            'jahrelang Bauprojekte geleitet. Diese Erfahrungen mit Architektur '
            'und Wohnbau helfen ihr nun sehr bei ihrer Tätigkeit als '
            'Raumberaterin. Ihre Arbeit besteht darin, den optimalen '
            'Energiefluss eines Wohn- oder Arbeitsumfeldes zu finden. Sie macht '
            'individuelle Vorschläge für die Raumanordnung, die Farbwahl der '
            'Wände oder für die Verwendung von Baumaterialien. „Ich habe alle '
            'Ideen zuerst bei mir zu Hause ausprobiert und war selbst '
            'überrascht von der positiven Wirkung", erzählt sie begeistert.\n\n'
            'Eine Raumberaterin arbeitet in der Regel folgendermaßen: Zuerst '
            'besprechen die Leute mit Frau Eigenmann, warum sie sich in ihrer '
            'Wohnung nicht wohl fühlen und wie sie ihren Wohnraum verbessern '
            'möchten. Dann bittet die Beraterin ihre Kunden, ihr einen genauen '
            'Plan der Wohnung zu schicken, auf dem sie die Möbelaufstellung und '
            'die genaue Ausrichtung des Hauses sehen kann. Daraufhin macht Frau '
            'Eigenmann einen detaillierten Wohnungsplan mit ausführlichen '
            'Erklärungen, wie man die Räume optimal einrichtet, um sich darin '
            'zufrieden zu fühlen. Für die Erstellung eines solchen Planes '
            'benötigt sie nach eigener Aussage je nach Größe der Wohnung oder '
            'des Gebäudes zwischen einem halben und einem ganzen Tag.\n\n'
            'Anschließend geht Iris Eigenmann zu den Leuten nach Hause, um die '
            'Situation vor Ort zu analysieren und Verbesserungsmöglichkeiten '
            'aufzuzeigen.\n\n'
            'Auch immer mehr Firmen suchen Rat bei einer Raumberaterin, '
            'meistens dann, wenn das Unternehmen nicht mehr so erfolgreich '
            'arbeitet. Iris Eigenmann versucht dann, das Arbeitsumfeld so zu '
            'verändern, dass sich Kunden und Angestellte wohler fühlen. Das '
            'führt in den meisten Fällen dazu, dass auch die Geschäfte wieder '
            'besser gehen. Der Preis für die Raumberatung wird je nach Aufwand '
            'mit dem Kunden gemeinsam bestimmt. Das Geld aber ist für Frau '
            'Eigenmann weniger wichtig als die Möglichkeit, den Menschen zu '
            'helfen und ihre positiven Erfahrungen weiterzugeben.\n\n'
            'Das persönliche Ziel der Feng-Shui-Raumberaterin für die Zukunft '
            'ist es, vermehrt auch im sozialen Bereich zu wirken – zum Beispiel '
            'in Krankenhäusern oder Altersheimen. Sie meint, dass mit einfachen '
            'Maßnahmen dort die Lebensqualität der Menschen erheblich '
            'verbessert werden könnte.',
      ],
      questions: [
        // ── TEST 1: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Die Werbung in den Vereinigten Staaten',
          options: [
            'beschäftigt sich überhaupt nicht mit Deutschland.',
            'zeigt immer wieder dasselbe Bild von Deutschland.',
            'zeigt viele unterschiedliche Seiten von Deutschland.',
          ],
          correctAnswer: 'zeigt immer wieder dasselbe Bild von Deutschland.',
        ),
        LesenQuestion(
          prompt: 'Die Eltern von Ulrike Rudelt',
          options: [
            'arbeiteten und lebten lange Jahre in den Niederlanden.',
            'hatten nicht die Möglichkeiten wie ihre Tochter.',
            'wollen ihre Tochter nun in den USA besuchen.',
          ],
          correctAnswer: 'hatten nicht die Möglichkeiten wie ihre Tochter.',
        ),
        LesenQuestion(
          prompt: 'Während die Praktikantinnen in New York waren,',
          options: [
            'bekamen sie eine Stadtführung.',
            'besuchten sie einen Sprachkurs.',
            'wurden sie über wichtige Themen informiert.',
          ],
          correctAnswer: 'wurden sie über wichtige Themen informiert.',
        ),
        LesenQuestion(
          prompt: 'Die dritte Leipzigerin, die in die USA gereist ist,',
          options: [
            'kommt eigentlich aus Österreich.',
            'wollte dort ihr Abitur machen und dann studieren.',
            'wurde von ihrer neuen Chefin freundlich aufgenommen.',
          ],
          correctAnswer:
              'wurde von ihrer neuen Chefin freundlich aufgenommen.',
        ),
        LesenQuestion(
          prompt: 'Wer als Praktikantin ins Ausland geht,',
          options: [
            'braucht schon einige Berufserfahrungen.',
            'soll dabei vor allem das Land kennenlernen.',
            'soll schon einmal im Ausland gewesen sein.',
          ],
          correctAnswer: 'soll schon einmal im Ausland gewesen sein.',
        ),
        // ── TEST 2: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Gerhard Spur',
          options: [
            'arbeitet heute nur noch mit der rechten Hand.',
            'arbeitete früher mit Linkshändern zusammen.',
            'stellt seine Kunstwerke mit der linken Hand her.',
          ],
          correctAnswer: 'stellt seine Kunstwerke mit der linken Hand her.',
        ),
        LesenQuestion(
          prompt: 'Heute ist wissenschaftlich bewiesen, dass',
          options: [
            'es eine klare Ursache für Linkshändigkeit gibt.',
            'Linkshänder besser im Lesen und Schreiben sind.',
            'Linkshändern das Schreiben mit der rechten Hand schadet.',
          ],
          correctAnswer:
              'Linkshändern das Schreiben mit der rechten Hand schadet.',
        ),
        LesenQuestion(
          prompt: 'Erich Pospischill meint, dass',
          options: [
            'es für Linkshänder sehr oft keine geeigneten Arbeitsplätze gibt.',
            'Linkshänder vor allem im Computerbereich eingesetzt werden.',
            'Linkshänder wesentlich öfter krank sind.',
          ],
          correctAnswer:
              'es für Linkshänder sehr oft keine geeigneten Arbeitsplätze gibt.',
        ),
        LesenQuestion(
          prompt: 'Frau Slata Tanasic',
          options: [
            'arbeitet seit 41 Jahren in der gleichen Firma.',
            'erledigt alle Arbeiten mit der linken Hand.',
            'ist seit 21 Jahren in der gleichen Firma beschäftigt.',
          ],
          correctAnswer:
              'ist seit 21 Jahren in der gleichen Firma beschäftigt.',
        ),
        LesenQuestion(
          prompt: 'Laut der Linkshänder-Expertin Johanna Sattler',
          options: [
            'haben Linkshänder meistens auch linkshändige Eltern.',
            'kann man Linkshändigkeit bei kleinen Kindern nicht gleich entdecken.',
            'sind linkshändige Kinder besonders gut im Ballspielen.',
          ],
          correctAnswer:
              'kann man Linkshändigkeit bei kleinen Kindern nicht gleich entdecken.',
        ),
        // ── TEST 3: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Die Psychologin der Popper-Schule meint, dass',
          options: [
            'besonders intelligente Kinder sich stark von anderen Kindern unterscheiden.',
            'besonders intelligente Schüler dieselben Probleme haben wie andere Kinder.',
            'besonders intelligente Schüler weniger Probleme im alltäglichen Leben haben.',
          ],
          correctAnswer:
              'besonders intelligente Schüler dieselben Probleme haben wie andere Kinder.',
        ),
        LesenQuestion(
          prompt:
              'Für überdurchschnittlich intelligente Schüler ist typisch, dass sie',
          options: [
            'auch ohne viel Anstrengung gute Noten haben.',
            'nach der Schule immer großen Erfolg im Beruf haben.',
            'sich die Zeit zum Lernen besser als andere einteilen können.',
          ],
          correctAnswer: 'auch ohne viel Anstrengung gute Noten haben.',
        ),
        LesenQuestion(
          prompt: 'Im Unterricht der Popper-Schule sollen die Schüler',
          options: [
            'immer in einer Fremdsprache miteinander sprechen.',
            'in ihren besten Fächern eine spezielle Betreuung bekommen.',
            'in kleinen Gruppen schwächeren Schülern helfen.',
          ],
          correctAnswer:
              'in ihren besten Fächern eine spezielle Betreuung bekommen.',
        ),
        LesenQuestion(
          prompt: 'Die erste Zeit in der Popper-Schule war für die Schüler '
              'schwer, weil',
          options: [
            'sich ihre Noten plötzlich verschlechterten.',
            'sie auf einmal viel mehr Zeit mit Lernen verbringen mussten.',
            'sie noch nicht wussten, welche besonderen Talente sie hatten.',
          ],
          correctAnswer:
              'sie auf einmal viel mehr Zeit mit Lernen verbringen mussten.',
        ),
        LesenQuestion(
          prompt: 'In der Popper-Schule werden nur Schüler aufgenommen,',
          options: [
            'die in mindestens einem Fach sehr gut sind.',
            'die mindestens 20 bis 30 Prozent der Aufnahmeprüfung erreichen.',
            'die von den insgesamt 28 Lehrern als intelligent beschrieben werden.',
          ],
          correctAnswer: 'die in mindestens einem Fach sehr gut sind.',
        ),
        // ── TEST 4: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Über das private Leben von Philipp Reis',
          options: [
            'gibt es nur wenige Berichte aus seiner Familie.',
            'kann man im Garnier-Institut viele Berichte finden.',
            'kann man in Gelnhausen viel erfahren.',
          ],
          correctAnswer: 'gibt es nur wenige Berichte aus seiner Familie.',
        ),
        LesenQuestion(
          prompt: 'Heute weiß man, dass Philipp Reis',
          options: [
            'bei seinen Versuchen die Familie vergaß.',
            'seinen Kindern viel über seine Experimente erzählte.',
            'sogar mit seiner Familie Experimente machte.',
          ],
          correctAnswer: 'bei seinen Versuchen die Familie vergaß.',
        ),
        LesenQuestion(
          prompt: 'Philipp Reis',
          options: [
            'hat viele technische Geräte gebaut.',
            'leitete als junger Wissenschaftler das Garnier-Institut.',
            'studierte am Garnier-Institut.',
          ],
          correctAnswer: 'hat viele technische Geräte gebaut.',
        ),
        LesenQuestion(
          prompt: 'Die Schüler von Philipp Reis',
          options: [
            'konnten ihren Lehrer in seinem Arbeitszimmer sehen.',
            'machten in seinem Arbeitszimmer Experimente.',
            'wurden von ihrem Lehrer mit einer Kamera beobachtet.',
          ],
          correctAnswer:
              'wurden von ihrem Lehrer mit einer Kamera beobachtet.',
        ),
        LesenQuestion(
          prompt: 'Professor Thompson',
          options: [
            'hat bei der Entwicklung des Telefons mitgearbeitet.',
            'meinte, dass Reis das Telefon erfunden hat.',
            'war ein Studienkollege von Philipp Reis.',
          ],
          correctAnswer: 'meinte, dass Reis das Telefon erfunden hat.',
        ),
        // ── TEST 5: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Das Schulamt hat ein Projekt gestartet, bei dem',
          options: [
            'Computer in Kindergärten aufgestellt werden.',
            'Computerspiele für Vierjährige entwickelt werden sollen.',
            'Kinder neue Farbdrucker ausprobieren sollen.',
          ],
          correctAnswer: 'Computer in Kindergärten aufgestellt werden.',
        ),
        LesenQuestion(
          prompt: 'Die Kinder',
          options: [
            'hatten großen Spaß bei dem Projekt.',
            'wollten lieber draußen im Freien spielen.',
            'wussten nicht, wann sie ins Studio im Netz gehen sollten.',
          ],
          correctAnswer: 'hatten großen Spaß bei dem Projekt.',
        ),
        LesenQuestion(
          prompt: 'Eltern fürchten, dass',
          options: [
            'der Computer ihren Kindern schadet.',
            'ihre Kinder nicht so früh aufstehen können.',
            'ihre Kinder vor dem Computer Angst haben.',
          ],
          correctAnswer: 'der Computer ihren Kindern schadet.',
        ),
        LesenQuestion(
          prompt: 'Die Erzieherinnen',
          options: [
            'arbeiten jeden Tag 15 bis 20 Minuten am Computer.',
            'spielen immer mit zwei oder drei Kindern am Computer.',
            'wählen für die Kinder die Software aus.',
          ],
          correctAnswer: 'wählen für die Kinder die Software aus.',
        ),
        LesenQuestion(
          prompt: 'Wenn die Kinder am Computer sitzen, dann',
          options: [
            'gibt es häufig Streit.',
            'hilft ein Kind dem anderen.',
            'können sich die meisten nicht lange konzentrieren.',
          ],
          correctAnswer: 'hilft ein Kind dem anderen.',
        ),
        // ── TEST 6: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Bettina Schröther',
          options: [
            'lässt ihren Hund in einer Hundeschule erziehen.',
            'macht mit ihrem Hund regelmäßig Wellnessurlaube.',
            'verbringt die ganze Freizeit mit ihrem Hund.',
          ],
          correctAnswer: 'lässt ihren Hund in einer Hundeschule erziehen.',
        ),
        LesenQuestion(
          prompt: 'Nach Meinung von Hundeexperte Marius Klotz sollte man',
          options: [
            'die Regeln bei der Hundeerziehung beachten.',
            'seinen Hund immer gut behandeln.',
            'sich zur Ernährung des Tiers beraten lassen.',
          ],
          correctAnswer: 'sich zur Ernährung des Tiers beraten lassen.',
        ),
        LesenQuestion(
          prompt: 'Die Hundebesitzerin Ellie Herfried',
          options: [
            'backt ihrem Hund zum Geburtstag einen Kuchen.',
            'feiert ihren Geburtstag immer mit ihrem Hund.',
            'sieht ihren Hund als festes Familienmitglied.',
          ],
          correctAnswer: 'sieht ihren Hund als festes Familienmitglied.',
        ),
        LesenQuestion(
          prompt: 'In Seniorenheimen gibt es oft Tiere, damit',
          options: [
            'die Senioren etwas tun, was gut für sie ist.',
            'die Senioren mehr spazieren gehen.',
            'sie auf die älteren Menschen aufpassen.',
          ],
          correctAnswer: 'die Senioren etwas tun, was gut für sie ist.',
        ),
        LesenQuestion(
          prompt: 'Fachleute meinen, dass',
          options: [
            'ein Haustier ein sinnvolles Hobby ist.',
            'man mit seinem Hund täglich spazieren gehen sollte.',
            'man sich durch sein Haustier erholen kann.',
          ],
          correctAnswer: 'man sich durch sein Haustier erholen kann.',
        ),
        // ── TEST 7: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Der Schweizer Schlafforscher Alexander Borbely',
          options: [
            'behauptet, dass der gesunde Schlaf gleichmäßig ist.',
            'beschäftigt sich seit 50 Jahren mit dem Thema Schlaf.',
            'meint, dass es beim Schlaf verschiedene Stufen gibt.',
          ],
          correctAnswer: 'meint, dass es beim Schlaf verschiedene Stufen gibt.',
        ),
        LesenQuestion(
          prompt: 'Während der Leichtschlafphase',
          options: [
            'erholt man sich nicht gut.',
            'träumt man besonders viel.',
            'wacht man öfter auf.',
          ],
          correctAnswer: 'träumt man besonders viel.',
        ),
        LesenQuestion(
          prompt: 'Die Wissenschaft ist heute der Meinung, dass',
          options: [
            'alle Probleme des Schlafes gelöst sind.',
            'der Schlaf der körperlichen Erholung dient.',
            'man durch Schlafen viel Zeit verliert.',
          ],
          correctAnswer: 'der Schlaf der körperlichen Erholung dient.',
        ),
        LesenQuestion(
          prompt: 'Vor allem die Menschen in westlichen Ländern',
          options: [
            'klagen darüber, dass sie schlecht schlafen können.',
            'können ohne Sorgen und Probleme schlafen.',
            'werden beim Schlafen gelegentlich gestört.',
          ],
          correctAnswer: 'klagen darüber, dass sie schlecht schlafen können.',
        ),
        LesenQuestion(
          prompt: 'Zum Arzt sollen die Menschen gehen, die',
          options: [
            'längere Zeit sehr schlecht schlafen.',
            'manchmal nachts aufwachen.',
            'zu viel und zu lange schlafen.',
          ],
          correctAnswer: 'längere Zeit sehr schlecht schlafen.',
        ),
        // ── TEST 8: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Um Berufe kennenzulernen,',
          options: [
            'arbeiten Berner Schüler in den Ferien bei großen Firmen.',
            'nehmen Berner Schüler an Informationsveranstaltungen von großen '
                'Firmen teil.',
            'sollen Berner Schüler zweimal jährlich ein Praktikum machen.',
          ],
          correctAnswer:
              'nehmen Berner Schüler an Informationsveranstaltungen von großen '
              'Firmen teil.',
        ),
        LesenQuestion(
          prompt: 'Frau Leiser',
          options: [
            'erzählt aus ihrem Berufsalltag in der Bank.',
            'stellt die wichtigsten Aufgaben der Bank vor.',
            'zeigt den Jugendlichen die ganze Firma.',
          ],
          correctAnswer: 'stellt die wichtigsten Aufgaben der Bank vor.',
        ),
        LesenQuestion(
          prompt: 'An dem Informationsnachmittag',
          options: [
            'bekamen die Jugendlichen eine Liste mit Bewerbungstipps.',
            'war die Gruppe interessiert und hat gut zugehört.',
            'wurden viele Fragen gestellt.',
          ],
          correctAnswer: 'war die Gruppe interessiert und hat gut zugehört.',
        ),
        LesenQuestion(
          prompt: 'Tugba Kaptan',
          options: [
            'fand es gut, dass sie am Schalter arbeiten durfte.',
            'fand es schade, dass an diesem Nachmittag die Schule ausgefallen '
                'ist.',
            'hat viele Informationen bekommen.',
          ],
          correctAnswer: 'hat viele Informationen bekommen.',
        ),
        LesenQuestion(
          prompt: 'Alan Blank',
          options: [
            'möchte später gern bei einer Bank arbeiten.',
            'möchte viele Dinge besser nicht selbst entscheiden.',
            'weiß noch nicht, was er machen will.',
          ],
          correctAnswer: 'möchte später gern bei einer Bank arbeiten.',
        ),
        // ── TEST 9: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Die Kinderbetreuerinnen kümmern sich um',
          options: [
            'Kinder, die auf dem Flughafen warten müssen.',
            'Kinder, die im Flugzeug krank wurden.',
            'Kinder, die ohne Eltern fliegen müssen.',
          ],
          correctAnswer: 'Kinder, die auf dem Flughafen warten müssen.',
        ),
        LesenQuestion(
          prompt: 'Der Flughafen Zürich-Kloten ist besonders familienfreundlich,',
          options: [
            'seit Alice Martin dort arbeitet.',
            'weil die Wartezeit kürzer ist als auf anderen Flughäfen.',
            'weil es Räume gibt, in denen Kinder spielen können.',
          ],
          correctAnswer: 'weil es Räume gibt, in denen Kinder spielen können.',
        ),
        LesenQuestion(
          prompt: 'Frau Alice Martin hat eine Ausbildung als',
          options: [
            'Flugbegleiterin.',
            'Kinderschwester.',
            'Pilotin.',
          ],
          correctAnswer: 'Kinderschwester.',
        ),
        LesenQuestion(
          prompt: 'In den Aufenthaltsräumen spielen die Kinder',
          options: [
            'am liebsten mit 18 Betreuerinnen.',
            'am liebsten mit Alice Martin.',
            'auch mit Kindern anderer Kulturen und Sprachen.',
          ],
          correctAnswer: 'auch mit Kindern anderer Kulturen und Sprachen.',
        ),
        LesenQuestion(
          prompt: 'Frau Alice Martin findet',
          options: [
            'die Arbeit auf dem Flughafen interessant und abwechslungsreich.',
            'die Arbeit auf dem Flughafen nicht so vielseitig wie die Arbeit im '
                'Spital.',
            'die Kontakte zu den Kindern auf dem Flughafen sehr intensiv.',
          ],
          correctAnswer:
              'die Arbeit auf dem Flughafen interessant und abwechslungsreich.',
        ),
        // ── TEST 10: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Das Bienensterben',
          options: [
            'ist ein noch ungelöstes Problem.',
            'kann man nur in bestimmten Regionen beobachten.',
            'lässt sich auf eine einzige Ursache zurückführen.',
          ],
          correctAnswer: 'ist ein noch ungelöstes Problem.',
        ),
        LesenQuestion(
          prompt: 'In vielen Städten',
          options: [
            'finden Bienen wenig Futter.',
            'kann man keine Bienen mehr sehen.',
            'schafft man mehr Platz für Bienen.',
          ],
          correctAnswer: 'schafft man mehr Platz für Bienen.',
        ),
        LesenQuestion(
          prompt: 'Werner, Gottlieb und Kessel',
          options: [
            'arbeiten in einer Parkanlage in Frankfurt.',
            'forschen über Bienen und ihren Lebensraum.',
            'organisieren eine Veranstaltung über Bienen.',
          ],
          correctAnswer: 'organisieren eine Veranstaltung über Bienen.',
        ),
        LesenQuestion(
          prompt: 'Experten nehmen an, dass',
          options: [
            'es in vier Jahren keine Bienen mehr gibt.',
            'man viele Lebensmittel ohne Bienen herstellen kann.',
            'menschliches Leben ohne Bienen nicht möglich ist.',
          ],
          correctAnswer: 'menschliches Leben ohne Bienen nicht möglich ist.',
        ),
        LesenQuestion(
          prompt: 'In Frankfurt gibt es',
          options: [
            'schon lange Bienenhalter.',
            'viele kranke Bienenvölker.',
            'zurzeit 60.000 Bienen.',
          ],
          correctAnswer: 'schon lange Bienenhalter.',
        ),
        // ── TEST 11: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'An den beiden Schulen',
          options: [
            'haben alle teilnehmenden Schüler das Abitur bestanden.',
            'haben zwei Schüler die Note 2,5 erreicht.',
            'sind die Durchschnittsnoten gleich geblieben.',
          ],
          correctAnswer:
              'haben alle teilnehmenden Schüler das Abitur bestanden.',
        ),
        LesenQuestion(
          prompt:
              'Die Abiparty der Heinrich-Mann-Schule war fantastisch, weil',
          options: [
            'die Abiturienten einen Film über die Party gemacht haben.',
            'die ganze Party im Internet gezeigt wurde.',
            'es eine tolle Show gab.',
          ],
          correctAnswer: 'es eine tolle Show gab.',
        ),
        LesenQuestion(
          prompt: 'In den letzten Wochen haben die Schülerinnen und Schüler',
          options: [
            'immer nur nachts für das Abitur gelernt.',
            'lieber gefeiert als gelernt.',
            'viel zu wenig geschlafen.',
          ],
          correctAnswer: 'viel zu wenig geschlafen.',
        ),
        LesenQuestion(
          prompt: 'Inka und Alexander',
          options: [
            'finden es schade, dass die Schulzeit vorbei ist.',
            'haben vor, Jura zu studieren.',
            'machen erst einmal zusammen Urlaub im Ausland.',
          ],
          correctAnswer: 'haben vor, Jura zu studieren.',
        ),
        LesenQuestion(
          prompt: 'Einer der vier Abiturienten',
          options: [
            'möchte in Bayreuth studieren, weil die Stadt so schön groß ist.',
            'weiß noch nicht genau, wo er studieren wird.',
            'will nach dem Freiwilligen Sozialen Jahr zwei Praktika machen.',
          ],
          correctAnswer: 'weiß noch nicht genau, wo er studieren wird.',
        ),
        // ── TEST 12: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Volkmar Bergmann',
          options: [
            'wollte bei einer anderen Firma arbeiten.',
            'wollte mehr Zeit für sein Privatleben haben.',
            'wollte nur noch nachts und an Wochenenden arbeiten.',
          ],
          correctAnswer: 'wollte mehr Zeit für sein Privatleben haben.',
        ),
        LesenQuestion(
          prompt: 'Es gibt viele Menschen,',
          options: [
            'die gerne einen anderen Schreibtisch hätten.',
            'die heute bereits arbeitskrank sind.',
            'die pro Woche nur noch 24 Stunden arbeiten.',
          ],
          correctAnswer: 'die heute bereits arbeitskrank sind.',
        ),
        LesenQuestion(
          prompt: 'Durch die moderne Technik',
          options: [
            'haben die Menschen mehr Zeit für das Privatleben.',
            'kann die Arbeit fast überall erledigt werden.',
            'wird es in Zukunft immer weniger Arbeit geben.',
          ],
          correctAnswer: 'kann die Arbeit fast überall erledigt werden.',
        ),
        LesenQuestion(
          prompt: 'Laut Professor Robinson',
          options: [
            'wollen viele Menschen weniger arbeiten.',
            'kann viel Arbeit den Menschen gut tun.',
            'leben viele Menschen nur noch für ihren Beruf.',
          ],
          correctAnswer: 'leben viele Menschen nur noch für ihren Beruf.',
        ),
        LesenQuestion(
          prompt: 'In Seminaren sollen die Teilnehmer lernen,',
          options: [
            'kranken Mitarbeitern zu helfen.',
            'wie man die Arbeit im Büro besser organisieren kann.',
            'ein gesundes Verhältnis zur Arbeit zu finden.',
          ],
          correctAnswer: 'ein gesundes Verhältnis zur Arbeit zu finden.',
        ),
        // ── TEST 13: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'In den Computerkursen von Franz Krapfenbauer',
          options: [
            'lernen die Kinder vor allem neue Computerspiele kennen.',
            'lernen Kinder ab 14 Jahren das richtige Arbeiten mit dem Computer.',
            'werden die Computerprogramme so einfach wie möglich erklärt.',
          ],
          correctAnswer:
              'werden die Computerprogramme so einfach wie möglich erklärt.',
        ),
        LesenQuestion(
          prompt: 'Am Anfang war es für Franz Krapfenbauer schwierig,',
          options: [
            'einen geeigneten Raum für die Kurse zu finden.',
            'genug Kinder für den Computerkurs zu finden.',
            'seine Tochter für den Computer zu begeistern.',
          ],
          correctAnswer: 'einen geeigneten Raum für die Kurse zu finden.',
        ),
        LesenQuestion(
          prompt: 'Herr Krapfenbauer meint,',
          options: [
            'dass auch kleine Kinder mit dem Computer arbeiten sollen.',
            'dass Kinder unter vier Jahren zu jung für den Computer seien.',
            'dass sich Kinder alleine mit dem Computer beschäftigen sollen.',
          ],
          correctAnswer:
              'dass auch kleine Kinder mit dem Computer arbeiten sollen.',
        ),
        LesenQuestion(
          prompt: 'Viele Kinder',
          options: [
            'machen im Kurs ihre Hausaufgaben am Computer.',
            'machen nach dem ersten Kurs noch einen weiteren Kurs.',
            'probieren im Kurs neue Computerspiele aus.',
          ],
          correctAnswer:
              'machen nach dem ersten Kurs noch einen weiteren Kurs.',
        ),
        LesenQuestion(
          prompt: 'Franz Krapfenbauer erzählt,',
          options: [
            'dass die Computerkurse oft von den Großeltern bezahlt werden.',
            'dass einige Eltern selbst als Computerexperten arbeiten.',
            'dass er auch Computerkurse in Büros plant.',
          ],
          correctAnswer:
              'dass die Computerkurse oft von den Großeltern bezahlt werden.',
        ),
        // ── TEST 14: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Mit 23 Jahren wollte Louis Palmer',
          options: [
            'für Studenten Reisen nach Südamerika organisieren.',
            'mit dem Fahrrad durch 50 verschiedene Länder fahren.',
            'viele verschiedene Länder kennen lernen.',
          ],
          correctAnswer: 'viele verschiedene Länder kennen lernen.',
        ),
        LesenQuestion(
          prompt: 'Sein Projekt konnte Palmer realisieren,',
          options: [
            'weil er einen Preis von einer Universität gewonnen hat.',
            'weil er finanzielle Unterstützung von vier Universitäten erhalten '
                'hat.',
            'weil ihn Firmen und Universitäten unterstützt haben.',
          ],
          correctAnswer:
              'weil ihn Firmen und Universitäten unterstützt haben.',
        ),
        LesenQuestion(
          prompt: 'Schon als Jugendlicher',
          options: [
            'baute Louis an einem umweltfreundlichen Auto.',
            'wollte Louis etwas für die Umwelt tun.',
            'wusste Louis genau, wie er sein Leben einteilen will.',
          ],
          correctAnswer: 'wollte Louis etwas für die Umwelt tun.',
        ),
        LesenQuestion(
          prompt: 'Palmers Auto',
          options: [
            'fährt mit alternativer Energie.',
            'geht auf eine dreijährige Weltreise.',
            'hat genug Platz für sieben Personen.',
          ],
          correctAnswer: 'fährt mit alternativer Energie.',
        ),
        LesenQuestion(
          prompt: 'Louis Palmer',
          options: [
            'hat für die Weltreise sechs Sprachen gelernt.',
            'möchte mit seinem Auto nicht durch Großstädte fahren.',
            'wird sich in nächster Zeit nicht langweilen.',
          ],
          correctAnswer: 'wird sich in nächster Zeit nicht langweilen.',
        ),
        // ── TEST 15: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'In der Schweiz gibt es etwa 800.000 Menschen, die',
          options: [
            'als Kind Angst vor der Schule hatten.',
            'beim Lesen und Schreiben große Schwierigkeiten haben.',
            'erst als Erwachsene Lesen und Schreiben lernen.',
          ],
          correctAnswer:
              'beim Lesen und Schreiben große Schwierigkeiten haben.',
        ),
        LesenQuestion(
          prompt: 'Sonja Kündig',
          options: [
            'besitzt die Fähigkeit, sich Zahlen sehr gut zu merken.',
            'hat nach dem Kurs eine Stelle bei einer Bank gefunden.',
            'lernte ihren Mann im Kurs kennen.',
          ],
          correctAnswer:
              'besitzt die Fähigkeit, sich Zahlen sehr gut zu merken.',
        ),
        LesenQuestion(
          prompt: 'Michael Feller',
          options: [
            'ist heute mit seinen Lernfortschritten zufrieden.',
            'versucht jetzt, trotz Schwierigkeiten längere Texte zu lesen.',
            'wechselte den Wohnort, weil er Probleme in der Schule hatte.',
          ],
          correctAnswer:
              'versucht jetzt, trotz Schwierigkeiten längere Texte zu lesen.',
        ),
        LesenQuestion(
          prompt: 'Die Leiterin des Kurses stellt fest, dass',
          options: [
            'der Kurs die Teilnehmenden selbstsicherer macht.',
            'die Teilnehmenden keinen Grammatikunterricht brauchen.',
            'sie selbst einen neuen Kommunikationsstil lernen muss.',
          ],
          correctAnswer: 'der Kurs die Teilnehmenden selbstsicherer macht.',
        ),
        LesenQuestion(
          prompt: 'Christian Koller',
          options: [
            'diskutiert nun auch mit Kollegen über Themen aus der Zeitung.',
            'hat noch nie einen Zeitungsartikel gelesen.',
            'wurde früher von seinen Kollegen oft ausgelacht.',
          ],
          correctAnswer:
              'diskutiert nun auch mit Kollegen über Themen aus der Zeitung.',
        ),
        // ── TEST 16: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Die Maus',
          options: [
            'führt Kinder durch das Museum.',
            'wird in einer Werbefirma gezeichnet.',
            'wurde von Friedrich Streich erfunden.',
          ],
          correctAnswer: 'wurde von Friedrich Streich erfunden.',
        ),
        LesenQuestion(
          prompt: 'Das Thema der Ausstellung',
          options: [
            'ist die Geschichte der Sendung mit der Maus.',
            'ist 30 Jahre Junges Museum.',
            'sind Kinder aus aller Welt.',
          ],
          correctAnswer: 'ist die Geschichte der Sendung mit der Maus.',
        ),
        LesenQuestion(
          prompt: 'Die Sendung mit der Maus',
          options: [
            'erhält Post aus der ganzen Welt.',
            'hat es schwer, noch neue Themen zu finden.',
            'nimmt nur Vorschläge von Kindern an.',
          ],
          correctAnswer: 'erhält Post aus der ganzen Welt.',
        ),
        LesenQuestion(
          prompt: 'Die Ausstellung',
          options: [
            'erlaubt den Kindern, mit den Ausstellungsstücken zu spielen.',
            'erlaubt den Kindern nicht, die Ausstellungsstücke anzufassen.',
            'ist nur für Kinder geöffnet.',
          ],
          correctAnswer:
              'erlaubt den Kindern, mit den Ausstellungsstücken zu spielen.',
        ),
        LesenQuestion(
          prompt: 'Die Maus',
          options: [
            'erhält von den Kindern Geschenke aus verschiedenen Materialien.',
            'gibt es nur auf Postkarten und Plakaten zu kaufen.',
            'ist aus Wolle und Papier.',
          ],
          correctAnswer:
              'erhält von den Kindern Geschenke aus verschiedenen Materialien.',
        ),
        // ── TEST 17: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Die Firma Ikea benutzt heute das Du,',
          options: [
            'weil das ein Zeichen für eine familiäre Atmosphäre ist.',
            'weil sie mehr jüngere Kunden gewinnen will.',
            'weil so mehr Leute den Verkaufskatalog lesen.',
          ],
          correctAnswer:
              'weil das ein Zeichen für eine familiäre Atmosphäre ist.',
        ),
        LesenQuestion(
          prompt: 'In der Schweiz',
          options: [
            'gilt das Du in Gewerkschaften als Beleidigung.',
            'werden Polizisten nur selten mit Du angesprochen.',
            'wird man bestraft, wenn man zu Beamten Du sagt.',
          ],
          correctAnswer: 'werden Polizisten nur selten mit Du angesprochen.',
        ),
        LesenQuestion(
          prompt: 'Eine Untersuchung hat gezeigt,',
          options: [
            'dass 14 Prozent der jüngeren Mitarbeiter das Sie vorziehen.',
            'dass besonders jüngere Arbeitskollegen schneller das Du wählen.',
            'dass sich alle Arbeitskollegen gern mit Du anreden würden.',
          ],
          correctAnswer:
              'dass besonders jüngere Arbeitskollegen schneller das Du wählen.',
        ),
        LesenQuestion(
          prompt: 'Durch Kurse können Angestellte',
          options: [
            'höfliches Verhalten am Arbeitsplatz lernen.',
            'ihre Stellung im Arbeitsleben verbessern.',
            'neue Trends beim Einrichten des Arbeitsplatzes kennen lernen.',
          ],
          correctAnswer: 'höfliches Verhalten am Arbeitsplatz lernen.',
        ),
        LesenQuestion(
          prompt: 'Probleme am Arbeitsplatz kann es geben,',
          options: [
            'wenn man das Sie ablehnt.',
            'wenn man wegen eines Fehlers vor Gericht muss.',
            'wenn man zu den Mitarbeitern Sie sagen will.',
          ],
          correctAnswer: 'wenn man zu den Mitarbeitern Sie sagen will.',
        ),
        // ── TEST 18: Aufgabe 6–10 ──
        LesenQuestion(
          prompt: 'Iris Eigenmann',
          options: [
            'berät Kunden beim Aufstellen von Möbeln in Wohnungen und Büros.',
            'hilft Menschen bei der richtigen Berufswahl.',
            'zeichnet Pläne für eine große Baufirma.',
          ],
          correctAnswer:
              'berät Kunden beim Aufstellen von Möbeln in Wohnungen und Büros.',
        ),
        LesenQuestion(
          prompt: 'Als Raumberaterin kümmert sich Iris Eigenmann darum,',
          options: [
            'dass sich Menschen in Wohn- und Arbeitsräumen wohler fühlen.',
            'chinesische Möbel in Europa zu verkaufen.',
            'Materialien für neue Bauprojekte zu entwickeln.',
          ],
          correctAnswer:
              'dass sich Menschen in Wohn- und Arbeitsräumen wohler fühlen.',
        ),
        LesenQuestion(
          prompt: 'Die Leute, die sich beraten lassen wollen,',
          options: [
            'besprechen mit Frau Eigenmann zuerst ihre Wünsche.',
            'laden Frau Eigenmann zuerst in ihre Wohnung ein.',
            'schicken Frau Eigenmann zuerst einen Plan der Wohnung.',
          ],
          correctAnswer:
              'besprechen mit Frau Eigenmann zuerst ihre Wünsche.',
        ),
        LesenQuestion(
          prompt: 'Die Firmenkunden von Frau Eigenmann',
          options: [
            'bezahlen besonders wenig für die Beratung.',
            'sind meist erfolgreiche Unternehmen.',
            'wollen auch ihre wirtschaftliche Lage verbessern.',
          ],
          correctAnswer: 'wollen auch ihre wirtschaftliche Lage verbessern.',
        ),
        LesenQuestion(
          prompt: 'Frau Eigenmann möchte in Zukunft',
          options: [
            'als Krankenschwester arbeiten.',
            'mit ihrer Arbeit das Leben alter und kranker Menschen verbessern.',
            'viel Geld verdienen.',
          ],
          correctAnswer:
              'mit ihrer Arbeit das Leben alter und kranker Menschen verbessern.',
        ),
      ],
    ),
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
