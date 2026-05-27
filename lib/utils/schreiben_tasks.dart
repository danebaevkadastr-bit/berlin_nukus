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
  const SchreibenTask(
    id: 21,
    task:
        'Ihr Führerschein ist weg. Sie möchten wissen, wie Sie einen neuen Führerschein bekommen können. Sie schreiben eine E-Mail an die Stadtverwaltung.',
    points: [
      'Wie es passiert ist / Grund',
      'Warum Sie dringend einen neuen Führerschein brauchen',
      'Foto?',
      'Wann geöffnet und Frage nach Kosten'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 22,
    task:
        'Sie haben in der Zeitung eine Anzeige gelesen: Das Kaufhaus „Fröhlich" sucht Aushilfen für den Verkauf von Spielzeug. Sie möchten sich bewerben und brauchen noch mehr Informationen. Schreiben Sie an das Kaufhaus.',
    points: [
      'Grund für Ihr Schreiben',
      'Ihre Ausbildung/Erfahrung',
      'Arbeitszeit?',
      'Andere Fragen zu der Stelle'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 23,
    task:
        'Sie möchten einen Ausbildungsplatz finden. In der Zeitung haben Sie gelesen, dass eine Firma in einem für Sie interessanten Beruf Auszubildende sucht. Sie schreiben eine Bewerbung an Herrn Schmitz.',
    points: [
      'Grund für Ihr Schreiben',
      'Wer Sie sind und Schulbildung',
      'Interessen/Hobbys',
      'Sprachkenntnisse'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 24,
    task:
        'Sie haben in Ihrer Tageszeitung eine Wohnungsanzeige gesehen. Schreiben Sie an Frau Busch von der Hausverwaltung.',
    points: [
      'Grund für Ihr Schreiben',
      'Angaben zu Ihrer Person',
      'Fragen zur Wohnung',
      'Besichtigungstermin?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 25,
    task:
        'Ihr Herd ist kaputt. Der Reparaturservice kommt morgen. Morgen sind Sie aber nicht zu Hause. Bitten Sie Ihre Nachbarin Johanna Müller um Hilfe.',
    points: [
      'Warum Sie nicht da sind',
      'Was Ihre Nachbarin tun soll',
      'Schlüssel',
      'Wie Sie bei Fragen erreichbar sind'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 26,
    task:
        'Sie besuchen einen Deutschkurs. Sie können diese Woche nicht mehr in den Kurs kommen. Schreiben Sie an Ihre Lehrerin Frau Meinert.',
    points: [
      'Grund für Ihr Schreiben',
      'Entschuldigung',
      'Hausaufgaben',
      'Rückkehr in den Kurs'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 27,
    task:
        'Ihre frühere Deutschlehrerin Frau Berg hat bald Geburtstag. Sie hat Sie eingeladen. Antworten Sie.',
    points: [
      'Grund für Ihr Schreiben',
      'Was Sie im Moment tun',
      'Kommen Sie?',
      'Bitte um Wegbeschreibung'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 28,
    task:
        'Ihre früheren Nachbarn sind umgezogen und feiern ein Fest. Sie haben eine Einladung bekommen. Antworten Sie.',
    points: [
      'Grund des Schreibens',
      'Geschenk',
      'Wer kommt noch?',
      'Bitte um Wegbeschreibung'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 29,
    task:
        'Sie sind zu einer Elternversammlung eingeladen. Sie haben aber einen Zahnarzttermin. Schreiben Sie an den Klassenlehrer Herrn Berberich.',
    points: [
      'Grund für das Schreiben',
      'Warum Sie nicht kommen können',
      'Sie fragen nach den Themen des Elternabends',
      'Sie bitten um einen Gesprächstermin'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 30,
    task:
        'Ihr Kind hat Probleme in der Schule. Sie suchen einen Nachhilfelehrer. Sie lesen eine Anzeige.',
    points: [
      'Grund für Ihr Schreiben',
      'Welche Probleme',
      'Wann und wo Nachhilfe',
      'Bezahlung'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 31,
    task:
        'Ihr Sohn hat sich den Fuß verletzt und kann nicht laufen. Entschuldigung an seine Klassenlehrerin.',
    points: [
      'Grund Ihres Schreibens',
      'Wann er wieder in die Schule kommt',
      'Bescheinigung vom Arzt',
      'Hausaufgaben'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 32,
    task:
        'Ihr Sohn ist krank und kann diese Woche nicht in die Schule. Nächste Woche gibt es einen Test.',
    points: [
      'Grund für Ihr Schreiben',
      'Was Ihrem Sohn fehlt',
      'Zu Hause üben',
      'Test zur Not nachschreiben'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 33,
    task:
        'Ihr Sohn kann morgen nicht an einem Ausflug teilnehmen (krank). Mitteilung an Frau Krüger.',
    points: [
      'Grund für Ihr Schreiben',
      'Was fehlt Ihrem Sohn?',
      'Was hat der Arzt gesagt?',
      'Wann wieder in der Schule?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 34,
    task:
        'Ihre Tochter ist krank und kann nicht zum Musikkurs. Schreiben Sie an Frau Olms.',
    points: [
      'Grund für Ihr Schreiben',
      'Welche Krankheit',
      'Wie lange krank',
      'Zu Hause üben (was/wie lange)?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 35,
    task:
        'Im Kindergarten findet ein Elternabend statt. Sie können Ihre Tochter nicht allein lassen. Bitten Sie Nachbarin Frau Löhr um Hilfe.',
    points: [
      'Wann Elternabend?',
      'Wie lange dauert er?',
      'Was Frau Löhr tun soll?',
      'Bitte um Antwort'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 36,
    task:
        'Eine Bekannte hat eine Erkältung und weiß nicht, zu welchem Arzt sie soll. Empfehlen Sie einen Arzt.',
    points: [
      'Grund für Ihr Schreiben',
      'Welcher Arzt und warum?',
      'Wo ist die Praxis?',
      'Wie kommt man dahin?'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 37,
    task:
        'Sie bekommen Strom von BilligStrom365. Rechnung über 1500 Euro. Beschwerdebrief.',
    points: [
      'Grund für Ihr Schreiben',
      'Was Sie dachten, als die Rechnung kam',
      'Was die Firma machen soll',
      'Was Sie tun, wenn nichts passiert'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 38,
    task:
        'Sie möchten einen Kurs machen, um im Altenheim zu arbeiten. E-Mail an Herrn Fischer.',
    points: [
      'Grund und warum Sie im Altenheim arbeiten möchten',
      'Berufserfahrung',
      'Dauer des Kurses',
      'Kosten'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 39,
    task:
        'Ihr Kollege Herr Sanchez bekommt Besuch von seinem Sohn. Er fragt, ob Sie vertreten können. Sie sagen zu.',
    points: [
      'Grund für Ihr Schreiben',
      'Welche Aufgaben?',
      'Genaue Uhrzeit?',
      'Frage nach dem Sohn'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 40,
    task:
        'Sie nehmen an einem Computerkurs teil und können nicht zur Arbeit. Ihr Kollege Herr Gildemeister soll vertreten.',
    points: [
      'Grund für Ihr Schreiben',
      'Dauer Ihrer Abwesenheit',
      'Aufgaben am Arbeitsplatz',
      'Büroschlüssel'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 41,
    task:
        'Sie sollen an einer Besprechung teilnehmen, müssen aber den Chef auf Dienstreise begleiten. Mitteilung an Kollegen.',
    points: [
      'Grund des Schreibens',
      'Dauer der Dienstreise',
      'Nächster Termin?',
      'Wer kann einen Bericht schreiben?'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 42,
    task:
        'Ihre Kollegin Frau Kaminski braucht Hilfe (auf Tochter aufpassen). Sie haben Zeit.',
    points: [
      'Hilfe anbieten',
      'Frage zur Tochter',
      'Spielzeug',
      'Dauer des Kurses'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 43,
    task:
        'Anzeige für gebrauchte Möbel von Frau Müller-Seipp. Sie sind interessiert.',
    points: [
      'Grund für das Schreiben',
      'An welchen Möbeln Sie interessiert sind',
      'Wie viel Sie ausgeben möchten',
      'Wie Sie die Möbel abholen können'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 44,
    task:
        'Jugendreise an den Bodensee (kostenlos auf Bauernhof gegen Hilfe). Fragen an Herrn Heizler.',
    points: [
      'Grund des Schreibens',
      'Ort des Bauernhofs?',
      'Arbeitsaufgaben?',
      'Freizeitmöglichkeiten?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 45,
    task:
        'Sie möchten über Berufsmöglichkeiten nach der Schule informiert werden. Termin im Jobcenter. An Frau Heberlein.',
    points: [
      'Grund des Schreibens',
      'Wer Sie sind',
      'Schule und Lieblingsfächer',
      'Ihre Interessen und Hobbys'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 46,
    task:
        'Jacke online bestellt (Versandhaus 24), sieht anders aus als auf dem Foto.',
    points: [
      'Grund für Ihr Schreiben',
      'Bestellung wann?',
      'Was ist falsch (Farbe/Größe)?',
      'Was Sie von der Firma möchten'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 47,
    task:
        'Fenster schließen nicht richtig (kalte Luft). Vermieter Herr Schmitz.',
    points: [
      'Grund für Ihr Schreiben',
      'Temperatur und Gesundheit',
      'Heizkosten',
      'Konsequenzen für den Vermieter'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 48,
    task:
        'Probleme mit der Heizung. Vermieter nicht erreichbar. Brief.',
    points: [
      'Grund des Schreibens',
      'Problem: wie lange schon?',
      'Termin für Reparatur',
      'Wie Sie erreichbar sind'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 49,
    task:
        'Umzug in neue Stadt. Transporter mieten. E-Mail an Autovermietung.',
    points: [
      'Grund für Ihr Schreiben',
      'Ab wann und wie lange?',
      'Welche Größe?',
      'Wie bezahlen?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 50,
    task:
        'Kursteilnehmer hatte Unfall, liegt im Krankenhaus. Mitteilung an die Klasse.',
    points: [
      'Grund für Ihr Schreiben',
      'Wann besuchen?',
      'Was mitbringen?',
      'Wie helfen?'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 51,
    task:
        'Fernseher funktioniert nicht (Antenne). Hausverwalter Herr Wiedemann.',
    points: [
      'Grund für Ihr Schreiben',
      'Was soll passieren?',
      'Wann soll das passieren?',
      'Was tun bei keiner Antwort?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 52,
    task:
        'Wohnungsanzeige: niedrige Miete, aber Gartenarbeit für Frau Peters (83).',
    points: [
      'Grund für Ihr Schreiben',
      'Zu Ihrer Person',
      'Fragen zur Wohnung?',
      'Gartenarbeit'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 53,
    task:
        'Nachbarin Frau Meier braucht Hilfe beim Schrankaufbau. Sie sind bis Freitag nicht da.',
    points: [
      'Grund des Schreibens',
      'Wann wieder da',
      'Werkzeug',
      'Weitere Hilfe anbieten'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 54,
    task:
        'Freunde Martina und Klaus heiraten. Einladung. Antwort.',
    points: [
      'Grund des Schreibens',
      'Ob Sie kommen können',
      'Geschenk?',
      'Wegbeschreibung'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 55,
    task:
        'Internationaler Schülertag an der Lessingschule. Einladung an Lehrer und Eltern.',
    points: [
      'Grund des Schreibens',
      'Zeit und Ort',
      'Programm',
      'Essen und Trinken'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 56,
    task:
        'Waschmaschine vor einem halben Jahr gekauft (Firma Neumann), jetzt kaputt. Garantie.',
    points: [
      'Grund des Schreibens',
      'Garantie',
      'Reparatur oder neue Waschmaschine',
      'Wie Sie erreichbar sind'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 57,
    task:
        'Angebot für Hausmeisterstelle am Schwarzen Brett. Bewerbung.',
    points: [
      'Grund Ihres Schreibens',
      'Wer Sie sind',
      'Was Sie können',
      'Wie man Sie erreicht'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 58,
    task:
        'Ihr Freund hat auf Ihre Einladung geantwortet. Jetzt schreiben Sie über:',
    points: [
      'Ausflugsweg und -ziel',
      'Kleidung',
      'Essen/Getränke',
      'Wer alles mitkommt'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 59,
    task:
        'Tasche im Bus liegen lassen. Brief an Fundbüro.',
    points: [
      'Grund für Ihr Schreiben',
      'Beschreibung der Tasche',
      'Wann/welcher Bus?',
      'Bitte um Zusendung (Adresse)'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 60,
    task:
        'Weißen Kleiderschrank bestellt, falscher Schrank geliefert.',
    points: [
      'Grund für Ihr Schreiben',
      'Anderen Schrank',
      'Neuer Termin',
      'Kosten/Rabatt?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 61,
    task:
        'Abflussrohr in der Küche verstopft. Nachbar empfiehlt Herrn Klein.',
    points: [
      'Problem mit dem Abfluss',
      'Termin',
      'Kosten der Reparatur',
      'Bitte um Rückmeldung'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 62,
    task:
        'Termin bei Ausländerbehörde, aber Operation im Krankenhaus. E-Mail.',
    points: [
      'Grund des Schreibens',
      'Bitte um anderen Termin',
      'Bescheinigung vom Krankenhaus',
      'Bitte um Antwort'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 63,
    task:
        'Sie wollen am Freitag ins Theater. Karten bestellen.',
    points: [
      'Grund des Schreibens',
      'Bitte um Eintrittskarten',
      'Wo abholen?',
      'Bitte um Antwort'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 64,
    task:
        'Im Mehrfamilienhaus vergessen viele, die Haustür abzuschließen. Nachricht fürs Schwarze Brett.',
    points: [
      'Grund des Schreibens',
      'Warum die Haustür abgeschlossen sein soll',
      'Andere Probleme im Haus',
      'Rückmeldungen oder Vorschläge?'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 65,
    task:
        'Ausländischen Führerschein in deutschen umschreiben. E-Mail an Führerscheinstelle.',
    points: [
      'Grund des Schreibens',
      'Wie umschreiben?',
      'Wie hoch sind die Gebühren?',
      'Bitte um Termin'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 66,
    task:
        'Sie müssen nach Köln (Mutter krank). Zettel an Nachbarin Frau Weber (Blumen gießen).',
    points: [
      'Grund des Schreibens',
      'Bitte an Frau Weber',
      'Bedanken Sie sich',
      'Wie lange?'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 67,
    task:
        'Am Donnerstag Termin mit Handwerker Thomas Schwarz (16 Uhr). Sie sind nicht zu Hause.',
    points: [
      'Warum Sie nicht da sind',
      'Neuen Termin vorschlagen',
      'Wie Sie bezahlen können'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 68,
    task:
        'Firma Schmidt will Montagvormittag Heizung reparieren. Sie sind nicht da.',
    points: [
      'Informieren, dass Sie nicht da sind',
      'Neuen Termin vorschlagen',
      'Um Antwort bitten'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 69,
    task:
        'Montag 14 Uhr Termin mit Kunden, müssen um 2 Stunden verschieben. An Herrn Groß.',
    points: [
      'Warum verschieben',
      'Neuen Termin vorschlagen',
      'Um Antwort bitten'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 70,
    task:
        'Donnerstag nicht im Deutschkurs (wichtiger Termin). An Frau Lippmann.',
    points: [
      'Entschuldigen',
      'Warum',
      'Hausaufgaben für Freitag'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 71,
    task:
        'Morgen nicht in der Schule. An Herrn Stark.',
    points: [
      'Entschuldigen',
      'Warum',
      'Hausaufgaben'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 72,
    task:
        'Heute nicht bei der Arbeit. An Chefin.',
    points: [
      'Entschuldigen',
      'Warum und wann zurück',
      'Kollegen dürfen anrufen'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 73,
    task:
        'Mittwoch Tennistraining, können nicht. An Frau Becker.',
    points: [
      'Entschuldigen',
      'Warum',
      'Anderen Termin (Tag/Uhrzeit) fragen'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 74,
    task:
        'Neue Wohnung, wollen Lehrerin Frau Schmidt zum Essen einladen.',
    points: [
      'Erklären, warum',
      'Neue Adresse zeigen',
      'Wann'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 75,
    task:
        'Nächsten Freitag Geburtstag, in der Klasse feiern. An Herrn Stein.',
    points: [
      'Wann und wie lange',
      'Essen und Getränke',
      'Um Erlaubnis bitten'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 76,
    task:
        'Neue Freundin + Eltern zum Kaffeetrinken einladen (Sonntag).',
    points: [
      'Einladen',
      'Wann und wo',
      'Weg beschreiben'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 77,
    task:
        'Kollegin Frau Gabler (neu in Stadt) Stadt zeigen.',
    points: [
      'Vorschlagen, was machen',
      'Wann und wo treffen',
      'Um Antwort bitten'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 78,
    task:
        'Kursleiterin Frau Schneider lädt zum Fest ein. Sie können nicht.',
    points: [
      'Bedanken',
      'Entschuldigen (warum)',
      'Andere Teilnehmer grüßen'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 79,
    task:
        'Nachbar Herr Müller lädt zum Geburtstag (Samstag) ein. Sie sagen zu.',
    points: [
      'Bedanken und zusagen',
      'Nach Uhrzeit fragen',
      'Was mitbringen?'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 80,
    task:
        'Herr Stark (Vater des Freundes) hat Karte für Rockkonzert (Rammstein). Antwort.',
    points: [
      'Bedanken und zusagen',
      'Informieren, dass Sie nicht bis ganz spät bleiben können',
      'Nach Treffzeit fragen'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 81,
    task:
        'Klassenlehrerin Frau Sturm will Abschlussparty organisieren.',
    points: [
      'Wie finden Sie die Idee?',
      'Wie Sie helfen können',
      'Dürfen Sie Schwester mitbringen?'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 82,
    task:
        'Musiklehrer Herr Fichte lädt zu Treffen (Gitarrengruppe) ein. Sie können nicht.',
    points: [
      'Bedanken und entschuldigen (warum)',
      'Sagen, dass Sie interessiert sind'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 83,
    task:
        'Schuljahr zu Ende. Herr Henning organisiert Gartenfest. Einladung. Antwort.',
    points: [
      'Bedanken und zusagen',
      'Was mitbringen?',
      'Nach Weg fragen'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 84,
    task:
        'Freundin Elisabeth zieht nach Leipzig um. Sie soll besuchen kommen. Antwort.',
    points: [
      'Dezember besuchen können',
      'Nach neuer Arbeit/Wohnung fragen',
      'Übernachtung in Leipzig'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 85,
    task:
        'Sie sind im Urlaub. Postkarte an Kollegen.',
    points: [
      'Wo Sie sind',
      'Was Sie gemacht haben',
      'Was Sie noch machen wollen'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 86,
    task:
        'Hotelzimmer gebucht, jemand aus Familie möchte mitkommen.',
    points: [
      'Warum',
      'Neuen Vorschlag',
      'Nach Preis fragen'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 87,
    task:
        'Chef (Herr Weickmann) will, dass Sie Samstag arbeiten.',
    points: [
      'Einverstanden',
      'Wie lange?',
      'Nächste Woche einen Tag frei'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 88,
    task:
        'Klassenlehrer Herr Häfner (Bein gebrochen) im Krankenhaus. Besuch.',
    points: [
      'Wie geht\'s? Gute Besserung',
      'Geplanten Besuch informieren',
      'Nach passendem Termin fragen'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 89,
    task:
        'Herr Schwarz will Weihnachtsbasar organisieren.',
    points: [
      'Wann Basar?',
      'Was Schüler anbieten können?',
      'Was es zu essen/trinken geben sollte'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 90,
    task:
        'Chefin Frau Hansen will Freitagabend länger arbeiten.',
    points: [
      'Einverstanden',
      'Nach der Arbeit fragen',
      'Nächste Woche früher gehen'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 91,
    task:
        'Sie ziehen bei Frau Wiegand ein. Fragen.',
    points: [
      'Heizung',
      'Kleine Party mit Freunden?',
      'Nächster Besuch'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 92,
    task:
        'Nachbarin Frau Schmidt (großer Garten) bittet um Hilfe.',
    points: [
      'Gern helfen',
      'Wann Sie Zeit haben',
      'Wer auch helfen könnte'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 93,
    task:
        'Freund Orhan zieht um (16. Juli). Antwort.',
    points: [
      'Können helfen',
      'Wo neue Wohnung? Wann kommen?',
      'Schlafplatz'
    ],
    style: 'informell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 94,
    task:
        'Ihr Teamleiter, Herr Brandt, lädt Sie zu einem Sommerfest der Firma ein. Schreiben Sie Herrn Brandt eine E-Mail.',
    points: [
      'Bedanken Sie sich für die Einladung',
      'Sagen Sie, ob Sie kommen und wen Sie mitbringen',
      'Fragen Sie, ob Sie etwas zum Buffet mitbringen sollen'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 95,
    task:
        'Ihre Deutschlehrerin, Frau Keller, organisiert am Freitag einen Besuch im Museum. Schreiben Sie ihr eine E-Mail.',
    points: [
      'Bedanken Sie sich für die Information',
      'Sagen Sie, dass Sie mitkommen möchten',
      'Fragen Sie nach Treffpunkt und Eintrittspreis'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 96,
    task:
        'Sie haben morgen einen Termin bei Ihrer Hausärztin, Frau Dr. Neumann, aber Sie können nicht kommen. Schreiben Sie der Praxis eine E-Mail.',
    points: [
      'Entschuldigen Sie sich',
      'Erklären Sie kurz den Grund',
      'Bitten Sie um einen neuen Termin am Nachmittag'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 97,
    task:
        'Sie möchten in einem Café am Wochenende arbeiten. Schreiben Sie der Besitzerin, Frau Berger, eine E-Mail.',
    points: [
      'Sagen Sie, dass Sie einen Nebenjob suchen',
      'Informieren Sie, wann Sie arbeiten können',
      'Fragen Sie nach einem kurzen Gespräch'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 98,
    task:
        'Ihr Vermieter, Herr Seidel, möchte am Montag den Wasserzähler ablesen. Schreiben Sie ihm eine E-Mail.',
    points: [
      'Bedanken Sie sich für die Nachricht',
      'Informieren Sie, wann Sie zu Hause sind',
      'Fragen Sie, wie lange der Besuch dauert'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 99,
    task:
        'Sie haben online Schuhe bestellt, aber die Größe ist falsch. Schreiben Sie dem Kundenservice eine E-Mail.',
    points: [
      'Erklären Sie das Problem',
      'Geben Sie die Bestellnummer an',
      'Fragen Sie, wie Sie die Schuhe umtauschen können'
    ],
    style: 'formell',
    minWords: 40,
  ),
  const SchreibenTask(
    id: 100,
    task:
        'Sie möchten einen Computerkurs in der Volkshochschule besuchen. Schreiben Sie Frau Arnold vom Sekretariat eine E-Mail.',
    points: [
      'Fragen Sie nach Kursen für Anfänger',
      'Informieren Sie, wann Sie Zeit haben',
      'Fragen Sie nach den Kosten'
    ],
    style: 'formell',
    minWords: 40,
  ),
];

int get schreibenTaskCount => schreibenTasks.length;

SchreibenTask schreibenTaskByIndex(int index) => schreibenTasks[index];
