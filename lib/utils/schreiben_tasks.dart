import '../models/schreiben_task.dart';

const String schreibenGeneralHint =
    'Schreiben Sie zu jedem Punkt ein bis zwei Sätze. '
    'Schreiben Sie auch eine Anrede und einen Gruß.';

final List<SchreibenTask> schreibenTasks = [
  const SchreibenTask(
    id: 1,
    task:
        'Ihre guten Freunde Martina und Klaus wollen heiraten und haben Ihnen eine Einladung zur Hochzeit geschrieben. Antworten Sie den beiden auf die Einladung.',
    points: ['Grund für Ihr Schreiben', 'ob Sie kommen können', 'Geschenk'],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 2,
    task:
        'Ihre frühere Deutschlehrerin Frau Berg hat bald Geburtstag. Sie möchte eine Geburtstagparty feiern und hat Ihnen eine Einladung geschickt. Antworten Sie auf diese Einladung.',
    points: ['Grund für Ihr Schreiben', 'Was Sie im Moment tun', 'Kommen Sie?'],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 3,
    task:
        'Sie finden am Schwarzen Brett im Supermarkt ein Angebot für einen Schrank. Schreiben Sie eine Nachricht.',
    points: [
      'Grund Ihres Schreibens',
      'Wann können Sie den Schrank abholen',
      'Wie man Sie erreichen kann',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 4,
    task:
        'Sie möchten einen Führerschein machen. Aber vorher brauchen Sie noch einige Information. Schreiben Sie etwas zu folgenden Punkten.',
    points: [
      'Grund für Ihr Schreiben',
      'Bitten Sie um Informationen',
      'Warum brauchen Sie den Führerschein',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 5,
    task:
        'Sie besuchen einen Deutschkurs. Sie können diese Woche nicht mehr in den Kurs kommen. Deshalb schreiben Sie an Ihre Lehrerin Frau Meinert.',
    points: ['Entschuldigung', 'Hausaufgaben', 'Rückkehr in den Kurs'],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 6,
    task:
        'Sie haben ein interessantes Wohnungsangebot gelesen. Sie schreiben einen Brief an den Vermieter, Herrn Schmitz, weil Sie sich für die Wohnung interessieren.',
    points: [
      'Angaben zur Person',
      'Termin für die Besichtigung',
      'Stellen Sie Fragen zur Wohnung',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 7,
    task:
        'Ihr Kind konnte gestern nicht in die Schule, weil Sie mit ihm dringend zum Zahnarzt mussten. Schreiben Sie eine Entschuldigung an den Lehrer, Herrn Baumann.',
    points: [
      'Warum konnte Ihr Kind nicht in die Schule kommen?',
      'Hausaufgaben?',
      'Eigene Idee?',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 8,
    task:
        'Sie haben eine Wohnungsanzeige gesehen und möchten mehr Informationen. Schreiben Sie eine E-Mail.',
    points: [
      'Wer sind Sie?',
      'Was möchten Sie über die Wohnung wissen?',
      'Bedanken Sie sich schon einmal für die Antwort',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 9,
    task:
        'Ein Bekannter hat eine starke Erkältung. Sie wollen ihm helfen. Schreiben Sie eine E-Mail.',
    points: [
      'Drücken Sie Ihr Mitleid aus',
      'Geben Sie ihm Tipps',
      'Wünschen Sie eine gute Besserung',
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 10,
    task:
        'In der Zeitung haben Sie eine Anzeige gelesen: jemand sucht eine Hilfe für den Haushalt. Sie interessieren sich für den Job und schreiben einen Brief.',
    points: [
      'Grund für Ihr Schreiben',
      'Welche Aufgaben?',
      'Arbeitszeiten und Bezahlung',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 11,
    task:
        'Sie möchten einen Feriensprachkurs in Berlin besuchen. Sie suchen ein Zimmer für diese Zeit. Deshalb schreiben Sie einem Freund, der in diesem Jahr einen Feriensprachkurs in Berlin gemacht hat.',
    points: [
      'Grund für Ihr Schreiben',
      'Hotel oder Familie?',
      'Kosten für die Unterkunft?',
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 12,
    task:
        'Sie haben online Deutsch gelernt und berichten Ihrer Freundin/Ihrem Freund darüber.',
    points: [
      'Beschreiben Sie: Wie haben Sie gelernt?',
      'Begründen Sie: Welche Vorteile hat das Lernen mit dem Computer?',
      'Machen Sie einen Vorschlag für ein Treffen',
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 13,
    task:
        'Sie gehen zusammen mit Ihrer Freundin Susanne zu einer Geburtstagsparty bei Ihrer Schulfreundin Anna (sie wird 30 Jahre alt, ledig, Ärztin von Beruf, sie kocht gerne). Sie haben noch kein Geschenk. Schreiben Sie eine Nachricht an Susanne.',
    points: [
      'Grund für Ihr Schreiben',
      'Fragen Sie nach einer Geschenkidee',
      'Machen Sie einen Geschenkvorschlag',
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 14,
    task:
        'Ihre Freundin Maria hat ein Mädchen geboren und in einem Monat wird die Taufe des Mädchens stattfinden. Maria lädt Sie zur Taufe ein. Kommen viele Freunde und Bekannte. Schreiben Sie einen Brief.',
    points: [
      'Danke für die Einladung',
      'Fragen Sie über das Kind',
      'Wann kommen Sie?',
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 15,
    task:
        'Sie haben für den Urlaub ein Zimmer in einem Hotel reserviert. Sie können aber leider nicht auf Urlaub fahren und möchten das Zimmer stornieren. Schreiben Sie dem Hotel einen Brief/ein E-Mail.',
    points: [
      'Datum für den Urlaub',
      'Grund für die Stornierung',
      'Was Sie möchten',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 16,
    task:
        'Ihre Kollegin Frau Meyer ist krank und liegt seit einer Woche im Krankenhaus. Ihr Chef Herr Jansen hat Ihnen eine E-Mail geschickt. Er möchte mit Ihnen Frau Meyer im Krankenhaus besuchen. Schreiben Sie eine E-Mail zurück.',
    points: [
      'Was bringen Sie mit?',
      'Fragen Sie: Wann und wo ist der Treffpunkt?',
      'Schlagen Sie einen Termin vor',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 17,
    task:
        'Ihre Cousine Frieda lädt Sie zu ihrer Silberhochzeit ein. Sie möchten kommen und antworten auf die Einladung mit einem Brief.',
    points: ['Zusage', 'Gratulation', 'Übernachtung'],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 18,
    task:
        'Ihr Sohn hatte einen Unfall und ist im Krankenhaus. Er kann nicht zur Schule gehen. Schreiben Sie einen Brief an den Lehrer, Herr Koch.',
    points: [
      'Was ist passiert?',
      'Notizen: Welche Aufgaben?',
      'Wie lange im Krankenhaus?',
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 19,
    task:
        'Ein Freund feiert eine Abschiedsfeier, weil er für ein Semester nach Amerika geht. Er feiert am nächsten Wochenende und lädt Sie ein.',
    points: ['Zusage', 'etwas mitbringen', 'Pläne in Amerika'],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 20,
    task:
        'Sie möchten Ihr Kind in den Sommerferien in ein Feriencamp schicken. Sie brauchen aber noch mehr Informationen.',
    points: ['Kosten', 'Freizeitaktivitäten', 'Wegbeschreibung'],
    style: 'formell',
    minWords: 40,
  ),
];

int get schreibenTaskCount => schreibenTasks.length;

SchreibenTask schreibenTaskByIndex(int index) => schreibenTasks[index];
