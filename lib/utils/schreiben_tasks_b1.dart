import '../models/schreiben_task.dart';

/// TELC B1 — Schriftlicher Ausdruck. Har bir vazifada javob beriladigan
/// kirish xati (letter) va to'rtta majburiy punkt bor. Min 100 so'z.
final List<SchreibenTask> schreibenTasksB1 = [
  const SchreibenTask(
    id: 1,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Ich habe eine tolle Überraschung. Stell dir vor, was mir mein Onkel angeboten hat. '
        'Er rief mich am Samstag an. Er hat ein großes Ferienhaus im Schwarzwald. Das Haus kann ich '
        'für die Ferien kostenlos haben. Ich kann auch Freunde mitbringen! Wäre das nichts für uns? '
        'Wir könnten uns alle dort treffen. Du, deine Eltern und Freunde, und ich mit meiner Familie '
        'und meinen Freunden. Ich würde mich wahnsinnig freuen, wenn das klappen würde. Bitte schreibe '
        'mir so schnell du kannst, damit wir alles planen können. Urlaub im Schwarzwald - das wird '
        'traumhaft schön!\n\nHerzliche Grüße\nPetra',
    task:
        'Antworten Sie auf den Brief von Petra über den Urlaub im Schwarzwald.',
    points: [
      'Warum Sie gern nach Deutschland kommen möchten',
      'Wie Sie anreisen wollen',
      'Was Sie gemeinsam machen könnten',
      'Wen Sie mitbringen möchten',
    ],
  ),
  const SchreibenTask(
    id: 2,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Wie geht es denn so mit dem Deutsch lernen? Kommst du gut voran, und was machst du im '
        'Moment so? Stell dir vor, ich habe die neue Stelle bei der Zeitschrift VIA bekommen! Ich '
        'arbeite jetzt als Journalistin, und das war ja immer mein Traumberuf!\n\n'
        'VIA wird vor allem von jüngeren Leuten gelesen. Deshalb schreiben wir viel über Berufe und '
        'Ausbildungen und auch über Freizeit und Sport. Für die nächsten Hefte von VIA planen wir '
        'jetzt eine neue Serie über Berufswünsche. Was ist eigentlich dein Traumberuf? Wenn du '
        'möchtest, schicke ich dir gerne einmal ein Heft von VIA, damit du siehst, was ich so mache.\n\n'
        'Ich freue mich schon auf deine Antwort.\n\nHerzliche Grüße\nEva',
    task:
        'Schreiben Sie Ihrer Bekannten Eva einen Antwortbrief.',
    points: [
      'Fortschritte beim Deutsch Lernen',
      'Auf Evas neue Stelle reagieren',
      'Was es Neues bei Ihnen gibt',
      'Ihr Traumberuf',
    ],
  ),
  const SchreibenTask(
    id: 3,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Wir haben lange nichts mehr voneinander gehört. Ich hoffe, es geht dir gut. Gibt es bei dir '
        'Neuigkeiten? Ich bin nun schon seit zwei Monaten in Würzburg, und mein neuer Job gefällt mir '
        'sehr gut. In der Firma fühle ich mich wohl, mit meinen Kollegen verstehe ich mich prima und '
        'die Arbeit macht mir großen Spaß.\n\n'
        'Allerdings habe ich ein Problem: Außer meinen Kollegen kenne ich hier in der Stadt noch '
        'niemanden. In meiner Freizeit bin ich oft allein und weiß nicht, was ich machen soll. Wie '
        'könnte ich neue Leute kennenlernen? Hast du vielleicht einen Tipp für mich?\n\n'
        'Würzburg ist wirklich eine schöne Stadt mit vielen Sehenswürdigkeiten. Hast du Lust, mich '
        'mal an einem Wochenende zu besuchen? Ich würde mich sehr freuen.\n\nViele Grüße\nSophie',
    task:
        'Antworten Sie Sophie auf ihren Brief aus Würzburg.',
    points: [
      'Was es Neues bei Ihnen gibt',
      'Was Sie selbst gerne in Ihrer Freizeit machen',
      'Tipps für Sophie',
      'Reaktion auf den Vorschlag',
    ],
  ),
  const SchreibenTask(
    id: 4,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Ich hoffe, dir geht\'s gut. Stell dir vor, bei mir gibt es Neuigkeiten! Du weißt doch, dass '
        'wir schon lange von einem Garten geträumt haben. Jetzt haben wir endlich einen am Stadtrand '
        'gefunden. Da er sehr groß ist, wollte ich dich fragen, ob du nicht Lust hast, den Garten mit '
        'uns zu teilen.\n\n'
        'Die Miete ist gar nicht so hoch. Du könntest dort Salat und Gemüse anpflanzen, natürlich '
        'auch Blumen – ganz wie du willst. Es gibt auch Obstbäume und eine große Wiese, auf der man '
        'sich einfach hinlegen kann, und wir könnten im Garten auch grillen. Was denkst du? Wäre das '
        'nicht toll?\n\nAntworte mir bald.\n\nAlles Liebe\nDeine Nadja',
    task:
        'Antworten Sie auf den Brief von Nadja über den Garten.',
    points: [
      'Reaktion auf den Vorschlag',
      'Fragen zum Garten',
      'Weg zum Garten',
      'Was es bei Ihnen Neues gibt',
    ],
  ),
  const SchreibenTask(
    id: 5,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Entschuldige, dass ich dir so lange nicht mehr geschrieben habe. Aber weißt du – mein älterer '
        'Bruder, der schon lange im Ausland lebt, ist jetzt für zwei Monate bei uns. Wir unternehmen '
        'einiges zusammen, z.B. gehen wir nachmittags ins Schwimmbad oder abends ins Kino.\n\n'
        'Wir verstehen uns eigentlich ganz gut, aber dennoch habe ich ein Problem mit ihm: Wenn es '
        'im Fernsehen Sportsendungen gibt, dann bekomme ich ihn nicht mehr weg vom Fernseher! Er '
        'sitzt dann stundenlang nur da und sieht fern, ganz egal wie schön das Wetter draußen ist! '
        'Was soll ich bloß tun? Überhaupt nichts sagen oder soll ich mit ihm deswegen streiten? Er '
        'fährt bald wieder weg und ich möchte doch mit ihm zusammen sein. Was würdest du machen? '
        'Hast du vielleicht ein paar Tipps oder Ratschläge für mich?\n\nHerzliche Grüße\nNicole',
    task:
        'Schreiben Sie Ihrer Bekannten Nicole einen Antwortbrief.',
    points: [
      'Eigene Erfahrungen mit Geschwistern, Freunden, ...',
      'Tipps für Nicole',
      'Was Sie über den Bruder denken',
      'Was Sie selbst gern gemeinsam mit anderen machen',
    ],
  ),
  const SchreibenTask(
    id: 6,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Heute habe ich Zeit, dir ein paar Zeilen zu schreiben. Der Urlaub war so schön, aber seit ich '
        'zurück bin, habe ich im Büro sehr viel Arbeit. Bestimmt brauche ich schon bald wieder Urlaub!\n\n'
        'Während ich weg war, hat sich hier übrigens einiges geändert: Es gibt einen neuen Kollegen, '
        'er heißt Roberto. Er arbeitet mit mir in meinem Büro, das heißt, ich habe endlich jemanden, '
        'mit dem ich mich zwischendurch auch ein bisschen unterhalten kann! Roberto ist aus Spanien '
        'hierher gezogen. Er kennt noch niemanden hier, außer mir natürlich, und ist meistens allein. '
        'Denkst du, dass ich ihn und ein paar andere Arbeitskollegen einmal einladen sollte? Was '
        'würdest du tun? Na gut, für heute muss ich Schluss machen. Melde dich doch bald einmal '
        'bei mir!\n\nViele Grüße\nAndreas',
    task:
        'Antworten Sie Andreas auf seinen Brief über den neuen Kollegen.',
    points: [
      'Vorschlag wie Andreas seinem Arbeitskollegen helfen kann',
      'Wie Sie am liebsten arbeiten (alleine oder mit Kollegen)',
      'Was Sie nach dem Urlaub gemacht haben',
      'Was es bei Ihnen Neues gibt',
    ],
  ),
  const SchreibenTask(
    id: 7,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Wie geht\'s dir? Hattest du ein schönes Wochenende? Hier hat es die ganze Zeit geregnet, '
        'deshalb bin ich zuhause geblieben.\n\n'
        'Du hattest vorgeschlagen, dass wir im Sommer zusammen verreisen könnten. Die Idee finde '
        'ich super! An welches Reiseziel denkst du? Ich bin gerne am Meer, mag aber auch '
        'Städtereisen. Wichtig ist für mich nur, dass ich auch ein bisschen Sport machen kann. Die '
        'Reise sollte aber nicht zu viel kosten, denn ich habe vor Kurzem schon viel für eine '
        'Autoreparatur bezahlen müssen. Was meinst du: wie können wir günstig Urlaub machen? Es '
        'muss ja kein Luxushotel sein.\n\nSchreib mir bald, dann können wir anfangen zu planen.\n\n'
        'Viele Grüße\nAnnika',
    task:
        'Antworten Sie Annika auf ihren Brief über die Urlaubsplanung.',
    points: [
      'Was Sie am Wochenende unternommen haben',
      'Wohin Sie gerne reisen würden',
      'Was Sie im Urlaub gerne machen',
      'Wie man beim Reisen Geld sparen kann',
    ],
  ),
  const SchreibenTask(
    id: 8,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Endlich habe ich die Deutschprüfung hinter mir. Ich glaube, es ist gut gelaufen. Jetzt soll '
        'für unseren Kurs eine Party organisiert werden. Du hast doch kürzlich erzählt, dass du für '
        'euren Kurs auch ein Abschlussfest organisiert hast. Sicher kannst du mir ein paar Tipps '
        'geben. Ich habe mir gedacht, wir könnten vielleicht in einem Restaurant feiern. Da kann jeder '
        'essen und trinken, was er will. Was meinst du? Essen zu kochen ist doch ziemlich viel Arbeit. '
        'Und natürlich brauchen wir Musik. Welche Musik ist am besten geeignet? Was schlägst du vor?\n\n'
        'Melde dich bald. Ich freue mich schon auf deine Antwort.\n\nLiebe Grüße\nIris',
    task:
        'Antworten Sie Ihrer Bekannten Iris über die Kursparty.',
    points: [
      'Reaktion auf die Prüfung',
      'Wo feiern? Restaurant – Ihre Meinung',
      'Welche Musik',
      'Urlaubspläne',
    ],
  ),
  const SchreibenTask(
    id: 9,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Die Sommerferien kommen rasch näher und ich freue mich sehr, dass du mich besuchen kommst. '
        'Ich habe eine tolle Idee: Ich möchte dich gerne zu einem Musikfestival einladen, und zwar '
        'nach Rüdesheim (ca. 50 km von Mainz). Dort spielen in diesem Sommer die besten '
        'internationalen Musikgruppen.\n\n'
        'Ich finde Open-Air-Konzerte einfach toll: die friedliche Stimmung unter den Besuchern, die '
        'gute Musik und einfach viele schöne Momente, die man nie mehr vergisst. Vor allem, wenn das '
        'Wetter gut ist, kann man das so richtig genießen.\n\n'
        'Wir könnten mit dem Zug nach Rüdesheim fahren oder auch mein Auto nehmen. Was wäre dir '
        'lieber? Übernachten würde ich gern auf dem Festplatz. Was meinst du? Und willst du '
        'vielleicht noch jemanden mitbringen?\n\nIch freue mich schon auf deine Antwort.\n\n'
        'Herzliche Grüße\nSonja',
    task:
        'Antworten Sie Sonja auf ihre Einladung zum Musikfestival.',
    points: [
      'Was sonst noch machen?',
      'Wie zum Festival reisen?',
      'Jemanden mitbringen?',
      'Übernachten: Reaktion auf Sonjas Vorschlag',
    ],
  ),
  const SchreibenTask(
    id: 10,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Du hast schon so lange nicht mehr geschrieben. Wie geht es dir? Heute habe ich eine Bitte. '
        'Vielleicht kannst du uns helfen?\n\n'
        'Eine 16-jährige Schülerin aus deinem Land wird uns besuchen und zwei Wochen bei uns in '
        'Goldbach bleiben. Natürlich möchten wir, dass sie sich wohl fühlt. Dein Land kennen wir nur '
        'von deinen Erzählungen, denn wir waren selbst noch nicht da. Bitte gib uns ein paar '
        'Informationen z.B. über typische Gewohnheiten oder typisches Essen. Was können wir tun und '
        'wie können wir uns vorbereiten?\n\nWir freuen uns schon auf deine Antwort.\n\n'
        'Schon einmal vielen Dank und liebe Grüße\nCaroline',
    task:
        'Antworten Sie Caroline auf ihre Bitte über den Besuch der Schülerin.',
    points: [
      'Reaktion auf den Besuch der Schülerin',
      'Vorschlag zu Essen und Trinken',
      'Warum Sie so lange nicht geschrieben haben',
      'Unternehmungen/Programm mit der Schülerin',
    ],
  ),
  const SchreibenTask(
    id: 11,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Wie geht es dir und deiner Familie? Bei mir läuft alles prima. Endlich habe ich eine neue '
        'Arbeitsstelle. Ich habe nur ein kleines Problem: Es ist ein bisschen zu weit, um zu Fuß zu '
        'gehen. Und der Bus fährt nur alle 30 Minuten. Früher bin ich meist mit dem Fahrrad gefahren, '
        'aber hier gibt es keine Fahrradwege. Und da ist ja auch noch mein Daniel, den ich morgens in '
        'den Kindergarten bringen muss. Der liegt zum Glück gleich neben meiner neuen Firma. – Wie '
        'kommst du denn zur Arbeit oder zum Deutschkurs?\n\n'
        'Wollen wir uns nicht mal wieder treffen und alle zusammen was unternehmen? Ich würde mich '
        'freuen.\n\nLiebe Grüße\nVera',
    task:
        'Antworten Sie Vera auf ihren Brief über die neue Arbeitsstelle.',
    points: [
      'Was es bei Ihnen Neues gibt',
      'Wie Sie zur Arbeit kommen',
      'Was Sie über Veras neue Stelle wissen wollen',
      'Vorschlag für gemeinsame Unternehmung',
    ],
  ),
  const SchreibenTask(
    id: 12,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Entschuldige, dass ich mich erst jetzt wieder melde. Ich weiß, wir hatten ausgemacht, uns '
        'öfter mal zu schreiben. Aber es war so viel los in letzter Zeit. Ich habe eine Neuigkeit für '
        'dich: Meine kleine Schwester Janine heiratet im Oktober, und ich habe ihr versprochen, schon '
        'mal allen Freunden zu schreiben und Bescheid zu sagen. Die offizielle Einladung bekommst du '
        'natürlich noch von ihr direkt. Eddi, ihr zukünftiger Mann, ist echt nett, und wir mögen ihn '
        'alle sehr. Er ist Koch und arbeitet hier in einem Hotel.\n\n'
        'Wir planen jetzt alles. Gib mir deshalb möglichst bald Bescheid, ob du kommst und mit wem.\n\n'
        'Herzliche Grüße\nJennifer',
    task:
        'Antworten Sie auf den Brief von Jennifer über die Hochzeit.',
    points: [
      'Reaktion auf Neuigkeit',
      'Übernachtungsmöglichkeit',
      'Sie möchten zur Hochzeit kommen',
      'Hochzeitsgeschenk',
    ],
  ),
  const SchreibenTask(
    id: 13,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Es tut mir wirklich leid, dass ich dir schon so lange nicht geschrieben habe. Bei mir ist im '
        'letzten Monat ziemlich viel los gewesen.\n\n'
        'Vor drei Wochen bin ich nämlich in eine neue Wohnung gezogen, weil die alte für mich zu '
        'klein war. Mittlerweile habe ich mich schon sehr schön eingerichtet, mit ein paar neuen '
        'Möbeln usw. Ich fühle mich wirklich wohl! Hast du nicht Lust, im Sommer zu mir zu Besuch '
        'zu kommen?\n\n'
        'In meiner neuen Wohnung habe ich jetzt auch ein kleines Arbeitszimmer für meine ganzen '
        'Bücher und den Schreibtisch mit dem Computer. Wie ist das bei dir? Machst du eigentlich viel '
        'am Computer?\n\nLass doch mal wieder was von dir hören!\n\nLiebe Grüße und bis bald\nAndreas',
    task:
        'Antworten Sie auf den Brief von Andreas über seine neue Wohnung.',
    points: [
      'Ihre Erfahrungen mit dem Computer',
      'Etwas über Ihre Wohnung',
      'Ob Sie Andreas besuchen möchten',
      'Was es bei Ihnen Neues gibt',
    ],
  ),
  const SchreibenTask(
    id: 14,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Nach unserm schönen, gemeinsamen Erlebnis letztes Jahr möchte ich auch dieses Jahr wieder '
        'einen Ausflug für uns alle organisieren. Ich hoffe sehr, dass ihr Zeit habt und mitkommen '
        'könnt – ich freue mich schon jetzt, euch alle bald wieder zu sehen! Das Dumme ist nur, dass '
        'ich mir vor drei Wochen beim Basketball das Bein gebrochen habe und noch nicht so gut zu '
        'Fuß bin. Deshalb habe ich einen gemütlichen Ausflug mit Bus und Schiff geplant – hoffentlich '
        'ist dann auch das Wetter gut für die Schiffsfahrt! Wohin es geht, möchte ich euch aber noch '
        'nicht verraten – das soll eine Überraschung werden.\n\n'
        'Termin: übernächster Samstag. Zeit und Treffpunkt: 9:30 Uhr bei mir.\n\n'
        'Bitte schreibt mir doch, ob ihr beim Ausflug dabei sein könnt!\n\nHoffentlich bis bald.\nThomas',
    task:
        'Antworten Sie Thomas auf seinen Brief über den Ausflug.',
    points: [
      'Alternativvorschlag für schlechtes Wetter',
      'Einladung annehmen',
      'Was Sie noch über den Ausflug wissen wollen',
      'Auf Sportunfall reagieren',
    ],
  ),
  const SchreibenTask(
    id: 15,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Wie geht es Dir? Du hast mir schon so lange nicht mehr geschrieben, dass ich mir Sorgen '
        'mache. Hoffentlich ist bei Euch alles in Ordnung. Es wird wirklich Zeit, dass wir uns '
        'wiedersehen.\n\n'
        'Anfang des Jahres habe ich meinen Arbeitsplatz gewechselt. Meine neue Stelle ist sehr '
        'interessant, aber auch anstrengend. Ich bin nun beruflich sehr viel unterwegs. Demnächst '
        'muss ich auch in Eure Gegend reisen. Dann könnten wir uns doch einmal am Abend treffen und '
        'gemeinsam etwas unternehmen. Wie findest Du meine Idee? Ich würde auch sehr gerne Deine '
        'Familie kennenlernen.\n\nBitte antworte mir bald!\n\nHerzliche Grüße\nDeine Tamara',
    task:
        'Antworten Sie Tamara auf ihren Brief über das Treffen.',
    points: [
      'Vorschlag zum Treffen',
      'Jemanden mitbringen',
      'Frage zur neuen Arbeitsstelle',
      'Warum Sie nicht geschrieben haben',
    ],
  ),
  const SchreibenTask(
    id: 16,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Ich sende Dir ganz viele Grüße aus Rom! Du weißt ja, wie sehr mir diese Stadt gefällt. Ich '
        'bin hier von morgens bis abends nur unterwegs. Diese Museen, Parks, Plätze und natürlich '
        'das Essen – wunderbar! Gestern Abend war ich übrigens in einem Rockkonzert. Ich fand die '
        'Musik ganz toll und die Stimmung war super.\n\n'
        'Doch leider ist mein Urlaub schon fast vorbei und in drei Tagen muss ich wieder zurück nach '
        'Deutschland. Welche Stadt ist eigentlich Deine Lieblingsstadt? Hast du schon Pläne für Deinen '
        'nächsten Urlaub? Vielleicht können wir uns ja mal wieder treffen.\n\nHerzliche Grüße\nJan',
    task:
        'Antworten Sie Jan auf seinen Brief aus Rom.',
    points: [
      'Ihre Lieblingsstadt',
      'Welche Musik Sie mögen',
      'Ihre Pläne für den nächsten Urlaub',
      'Treffen mit Jan?',
    ],
  ),
  const SchreibenTask(
    id: 17,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Ich sende dir sonnige Grüße von der wunderschönen Insel Malta! Katja, die Kinder und ich '
        'sind ganz glücklich! Strand, Kultur, Sport – all das ist hier möglich! Gestern haben wir uns '
        'sogar ein Auto gemietet und einen Ausflug gemacht. Und auch für mein Hobby, das '
        'Fotografieren, habe ich sehr viel Zeit – ich habe schon ganz viele Fotos gemacht. Ich schicke '
        'dir mit diesem Brief auch ein Buch über Malta, damit du siehst, wie interessant dieses Land '
        'ist. Hoffentlich gefällt dir das Buch.\n\n'
        'Leider ist unser Urlaub auch schon in wenigen Tagen vorbei. Wie wäre das – vielleicht können '
        'wir uns ja wieder einmal treffen?\n\nBis hoffentlich bald\nViktor',
    task:
        'Antworten Sie auf den Brief von Viktor aus Malta.',
    points: [
      'Ihre Hobbys',
      'Reaktion auf das Buch',
      'Ihre Pläne für den nächsten Urlaub',
      'Treffen mit Viktor',
    ],
  ),
  const SchreibenTask(
    id: 18,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Endlich habe ich Zeit, dir wieder mal zu schreiben. Schade, dass du bei unserer Hochzeit nicht '
        'dabei sein konntest! Wir waren mit Freunden und Verwandten über 50 Personen. Ich habe ein '
        'langes, weißes Kleid getragen, und Karl hat sich für diesen Tag einen teuren, schwarzen Anzug '
        'gekauft, obwohl er sonst immer nur Jeans trägt. Natürlich gab es ein wunderbares Festessen '
        'und danach wurde getanzt. Karl und ich haben viele Geschenke bekommen, vor allem auch '
        'Geld für unsere Hochzeitsreise. Wir wissen aber noch gar nicht, wohin wir fahren wollen.\n\n'
        'Wie läuft\'s eigentlich bei dir, du hast doch eine neue Stelle? Wie gefällt dir die Arbeit? Karl '
        'und ich würden uns sehr freuen, wenn du uns wieder mal besuchen würdest!\n\nLiebe Grüße\nRita',
    task:
        'Antworten Sie Ihrer Bekannten Rita über ihre Hochzeit.',
    points: [
      'Ihre neue Arbeitsstelle',
      'Wie man in Ihrem Land heiratet',
      'Vorschlag für Ritas Hochzeitsreise',
      'Rita und Karl besuchen?',
    ],
  ),
  const SchreibenTask(
    id: 19,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ...,\n\n'
        'wie geht\'s? Wir haben lange nichts von dir gehört. Wir leben nun fast ein Jahr in Frankreich – '
        'und Marseille ist einfach eine tolle Stadt!\n\n'
        'Gestern haben wir lange überlegt, was wir im Sommer machen möchten. Wir dachten, es wäre '
        'schön, einige Freunde wiederzusehen. Und wir könnten auch dich besuchen. Wie findest du '
        'diese Idee? Würde dir Ende Juni passen? Oder bist du in dieser Zeit selbst weg? Falls ja, '
        'könnten wir auch erst Ende August kommen. Wir möchten nicht so lange bei dir bleiben, '
        'höchstens drei Tage. Wäre das in Ordnung?\n\n'
        'Bitte melde dich bald, damit wir unsere Reise planen können. Da wir zurzeit kein Auto haben, '
        'schreibe uns ein paar Tipps, wie wir am besten zu dir kommen.\n\nBis bald\nCora und Alex',
    task:
        'Antworten Sie Cora und Alex auf ihren Brief aus Marseille.',
    points: [
      'Beste Zeit für den Besuch, warum?',
      'Wie Ihre Freunde am besten anreisen',
      'Was Sie gerne zusammen mit Ihren Freunden machen möchten',
      'Fragen zu Marseille',
    ],
  ),
  const SchreibenTask(
    id: 20,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ........\n\n'
        'Ich hoffe, es geht dir gut. Du hast dich schon lange nicht gemeldet. Ist alles in Ordnung bei '
        'dir? Ich bin so froh, dass es nun Sommer ist und ich oft draußen sein kann. Hast du bereits '
        'Pläne?\n\n'
        'Ich schreibe dir auch, weil ich eine Bitte habe. Im Juli muss ich für eine Woche nach '
        'Dänemark reisen. In dieser Zeit brauche ich jemanden, der sich um meine Katze und meine '
        'Blumen kümmert. Könntest du bitte das machen oder möchtest du im Juli selbst verreisen?\n\n'
        'Du bist ja auch zu Laras 30. Geburtstag eingeladen. Wollen wir zusammen dort hinfahren? '
        'Würdest du lieber mit dem Zug oder dem Auto fahren? Lara lebt jetzt in Garmisch-Partenkirchen '
        'und das ist von uns aus ziemlich weit weg. Und was könnten wir Lara schenken? Zum 30. '
        'sollte es schon etwas Besonderes sein.\n\nLiebe Grüße\nAnne',
    task:
        'Antworten Sie Anne auf ihren Brief über Laras Geburtstag.',
    points: [
      'Geschenk für Lara',
      'Gemeinsam länger bleiben?',
      'Zug oder Auto?',
      'Was Sie in letzter Zeit erlebt haben',
    ],
  ),
  const SchreibenTask(
    id: 21,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe/r ....,\n\n'
        'ich freue mich sehr über dein Interesse an einem gemeinsamen Ausflug in die Berge. Auch mir '
        'würde es gefallen, mehrere Tage zu wandern.\n\n'
        'Ich möchte dir vorschlagen, dass wir nach Südtirol fahren, denn die Berge dort sollen wirklich '
        'wunderschön sein! Was hältst du davon? Mir wäre Anfang Juni am liebsten, weil es da noch '
        'nicht so heiß ist! Vielleicht möchtest du noch jemanden mitbringen?\n\n'
        'Bitte schreibe mir bald, was du von meinem Vorschlag hältst.\n\nViele liebe Grüße\nPaul',
    task:
        'Antworten Sie Paul auf seinen Vorschlag für den Ausflug nach Südtirol.',
    points: [
      'Termin in Ordnung?',
      'Reaktion auf Pauls Vorschlag',
      'Jemanden mitbringen?',
      'Was Sie noch von Paul wissen wollen',
    ],
  ),
  const SchreibenTask(
    id: 22,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe() ...\n\n'
        'Wie geht es dir? Ich wollte dir schon lange schreiben, aber ich hatte nach meinem Urlaub noch '
        'so viel zu tun.\n\n'
        'Im Moment habe ich leider ein Problem mit meinem Nachbarn. Er hört oft sehr laut Musik, '
        'auch abends. Das stört mich sehr. Ich weiß nicht, was ich machen soll – hast du einen Tipp? '
        'Hattest du auch schon mal solche Schwierigkeiten? Wie sind denn deine Nachbarn? Ich habe '
        'dich übrigens noch nie in deiner Wohnung besucht. Wie ist sie? Erzähl doch mal ein bisschen.\n\n'
        'Hast du bald mal Zeit? Dann könnten wir was unternehmen. Worauf hast du Lust?\n\n'
        'Meld dich doch mal.\n\nViele Grüße\nJakob',
    task:
        'Antworten Sie Jakob auf seinen Brief über das Problem mit dem Nachbarn.',
    points: [
      'Problem mit dem Nachbarn – Tipp',
      'Ihre Wohnung',
      'Vorschlag für Treffen',
      'Wie Ihre Nachbarn sind',
    ],
  ),
  const SchreibenTask(
    id: 23,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe/r .\n\n'
        'Wie geht es dir? Ich schreibe dir erst jetzt, weil ich in den letzten Wochen viel zu tun hatte. '
        'Wie du weißt, bin ich umgezogen.\n\n'
        'In meiner neuen Wohnung fühle ich mich wohl: Sie ist groß und hell, und ich habe sogar '
        'einen kleinen Garten. Meine Nachbarn sind sehr nett. Leider habe ich hier noch keine neuen '
        'Leute gefunden. Ich weiß nicht, wo ich neue Leute kennenlernen könnte. Hast du vielleicht '
        'ein paar Tipps für mich? Hoffentlich ist bei dir alles in Ordnung.\n\n'
        'Wir sollten uns bald wiedersehen. Schreib mir doch mal, ich freue mich!\n\nNora',
    task:
        'Antworten Sie Nora auf ihren Brief über die neue Wohnung.',
    points: [
      'Fragen über ihre Wohnung',
      'Tipps für Nachbarn / Leute kennenlernen',
      'Vorschlag Treffen',
      'Was es Neues gibt',
    ],
  ),
  const SchreibenTask(
    id: 24,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe ...\n\n'
        'Ich hoffe, es geht dir gut. Du hast dich schon lange nicht gemeldet. Ist alles in Ordnung bei '
        'dir? Ich bin so froh, dass es nun Sommer ist und ich oft draußen sein kann. Hast du bereits '
        'Pläne?\n\n'
        'Ich schreibe dir auch, weil ich eine Bitte habe. Im Juli muss ich für eine Woche nach '
        'Dänemark reisen. In dieser Zeit brauche ich jemanden, der sich um meine Katze und meine '
        'Blumen kümmert. Könntest du bitte das machen oder möchtest du im Juli selbst verreisen? '
        'Sag mir doch kurz Bescheid, ob das klappt. Ich lade dich danach auch zum Abendessen bei '
        'unserem Lieblingsitaliener ein.\n\nAnna',
    task:
        'Antworten Sie Anna auf ihre Bitte (Katze und Blumen).',
    points: [
      'Reaktion auf Annas Bitte',
      'Ihre Pläne für den Sommer',
      'Warum Sie sich nicht gemeldet haben',
      'Frage zur Katze',
    ],
  ),
  const SchreibenTask(
    id: 25,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe ...\n\n'
        'Leider haben wir uns schon länger nicht mehr geschrieben. Gibt es etwas Neues bei dir?\n\n'
        'Stell dir vor, mein Sohn Jonas wird nächste Woche schon fünf Jahre alt! Die Zeit vergeht so '
        'schnell. An seinem Geburtstag wollen wir mit vier seiner Freunde in den Zoo gehen. Mein '
        'Sohn liebt Tiere, besonders die Affen. Er kann ihnen stundenlang zugucken und über sie '
        'lachen.\n\n'
        'Gehst du auch gerne in den Zoo und welche Tiere magst du gerne? Gibt es in deinem '
        'Heimatland eigentlich auch Zoos wie hier in Deutschland? Vielleicht können wir uns bald mal '
        'wieder treffen. Wenn du Lust hast, könnten wir ja auch einmal einen Zoo zusammen besuchen.\n\n'
        'Ganz liebe Grüße\nClaudia',
    task:
        'Antworten Sie Claudia auf ihren Brief über den Zoobesuch.',
    points: [
      'Reaktion auf den Vorschlag',
      'Zoos im Heimatland',
      'Lieblingstier im Zoo',
      'Was es Neues bei Ihnen gibt',
    ],
  ),
  const SchreibenTask(
    id: 26,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ...\n\n'
        'Wie geht es dir? In der Zwischenzeit habe ich mich schon gut in Bamberg eingelebt. Ich '
        'wohne in der Altstadt und fühle mich sehr wohl. Hier brauche ich kein Auto und kann alles '
        'zu Fuß oder mit dem Fahrrad erreichen, sogar meinen Arbeitsplatz.\n\n'
        'Ich arbeite jetzt als Rezeptionistin im Hotel "Zur Residenz". Ich habe sehr viel zu tun und '
        'jeden Tag gibt es neue Überraschungen. Aber gerade das liebe ich ja an meinem Job. Komm '
        'mich doch besuchen! Dann zeige ich dir meine neue Wohnung und wir können endlich mal '
        'wieder lange reden.\n\nViele Grüße\nKarla',
    task:
        'Antworten Sie Karla auf ihren Brief aus Bamberg.',
    points: [
      'Etwas über Ihren Wohnort',
      'Etwas über Ihre Wohnung',
      'Karla besuchen?',
      'Frage zu Karlas Arbeit',
    ],
  ),
  const SchreibenTask(
    id: 27,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ...\n\n'
        'Wie geht es Dir? Warum hast Du in den letzten Wochen nicht mehr geschrieben? Leider haben '
        'wir uns ja auch schon sehr lange nicht mehr gesehen. Doch das kann sich bald ändern.\n\n'
        'Mein neuer Freund und ich haben in zwei Wochen Urlaub und möchten eine Reise mit dem '
        'Auto machen. Dabei möchten wir Dich auch gerne treffen. Schließlich möchte ich Dir ja auch '
        'meinen Freund vorstellen. Vielleicht hast Du eine Idee, wo wir uns treffen könnten. Kannst Du '
        'uns auch ein schönes Hotel bei Euch in der Nähe empfehlen? Antworte mir bald!\n\n'
        'Herzliche Grüße\nMara',
    task:
        'Antworten Sie auf den Brief von Mara über ihren Urlaub und neuen Freund.',
    points: [
      'Hotel / Übernachtungsmöglichkeit',
      'Vorschlag zum Treffen',
      'Reaktion auf Maras neuen Freund',
      'Warum Sie lange nicht geschrieben haben',
    ],
  ),
  const SchreibenTask(
    id: 28,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ...\n\n'
        'Ich habe lange nichts von dir gehört. Nun habe ich von Sina erfahren, dass du bald eine '
        'Prüfung machst. Das ist ja ganz toll! Sina hat mir auch gesagt, dass du jeden Tag fleißig '
        'Deutsch lernst und wenig Zeit hast, andere Dinge zu machen. Daher schreibe ich dir lieber '
        'eine E-Mail, denn ich wollte dich fragen, ob wir nach deiner Prüfung etwas zusammen machen '
        'sollen? Wie wäre es mit einer Tour an die Nordsee, nach Prag oder Amsterdam, oder in den '
        'Schwarzwald? Was denkst du? Wenn du Zeit hast, schreibe mir bitte bald. Und für deine '
        'Prüfung wünsche ich dir viel Erfolg.\n\nBis bald\nCorinna',
    task:
        'Antworten Sie Corinna auf ihre E-Mail über eine gemeinsame Reise.',
    points: [
      'Wohin Sie mit Corinna fahren möchten',
      'Wie Sie Deutsch lernen',
      'Was es bei Ihnen Neues gibt',
      'Was Sie von Corinna wissen wollen',
    ],
  ),
  const SchreibenTask(
    id: 29,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ...\n\n'
        'Ich hoffe, es geht dir gut.\n\n'
        'Ich habe eine Idee: Ich möchte die Leute aus unserem Englischkurs gerne einladen. Bei gutem '
        'Wetter feiern wir in meinem Garten. Aber was machen wir bei Regen?\n\n'
        'Kannst du mir vielleicht bei den Vorbereitungen helfen? Ich weiß noch nicht, was ich den '
        'Gästen zu essen anbieten kann. Hast du einen Vorschlag? Du weißt ja, dass ich nicht die beste '
        'Köchin bin. Den genauen Termin habe ich mir noch nicht überlegt. Meinst du, ich soll lieber '
        'an einem Freitag oder an einem Samstag feiern?\n\n'
        'Schreib mir doch mal, was du über meine Pläne denkst.\n\nLiebe Grüße\nAlicia',
    task:
        'Antworten Sie Alicia auf ihre E-Mail über die Party.',
    points: [
      'Party – welcher Tag?',
      'Wie Sie helfen können',
      'Bei Regen – wo?',
      'Essen',
    ],
  ),
  const SchreibenTask(
    id: 30,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe(r) ...\n\n'
        'Es tut mir leid, dass ich mich so lange nicht gemeldet habe, aber ich hatte in den vergangenen '
        'Wochen sehr viel zu tun. Ich habe eine kleine Firma gegründet.\n\n'
        'Nachdem ich einen Lieferwagen und Werkzeug gekauft habe, biete ich nun Gartenarbeiten und '
        'Reparaturen rund ums Haus an. Ich pflanze und pflege Blumen, schneide Gras und Bäume. '
        'Manchmal putze ich auch Gartenhäuschen und Garagen.\n\n'
        'Schon nach kurzer Zeit habe ich viele Kunden gewonnen, die mich immer wieder anrufen, '
        'wenn sie mich brauchen. Endlich bin ich mein eigener Chef.\n\n'
        'Was gibt es bei dir Neues? Schreib mir bald!\n\nBeste Grüße\nMiroslav',
    task:
        'Antworten Sie Miroslav auf seinen Brief über seine neue Firma.',
    points: [
      'Welche Arbeit Sie machen/suchen',
      'Was Sie von Miroslavs Tätigkeit halten',
      'Was es bei Ihnen Neues gibt',
      'Frage zu Miroslavs Kunden',
    ],
  ),
  const SchreibenTask(
    id: 31,
    level: 'B1',
    style: 'informell',
    minWords: 100,
    letter:
        'Liebe/r ______________,\n\n'
        'du weißt ja, dass ich schon lange nach einem Job suche, der mit meinem Hobby Musik zu tun '
        'hat. Stell dir vor, nun habe ich den perfekten Job gefunden. Ich gehe für sechs Monate mit der '
        'berühmten deutschen Musikgruppe "Wohnraumhelden" auf Tournee durch verschiedene Länder '
        '– als Assistentin des Managers. Dabei kommen wir auch ganz in die Nähe deiner Stadt. Leider '
        'war ich ja noch nie da. Kannst du mir ein paar Tipps geben, was ich dort so machen kann?\n\n'
        'Im Moment sind wir noch mit der Planung beschäftigt. Deshalb weiß ich noch nicht genau, '
        'wann es losgeht. Wenn ich den genauen Termin kenne, melde ich mich sofort bei dir. Ich '
        'hoffe, dass wir uns dann einmal treffen können, und natürlich organisiere ich auch Freikarten '
        'für dich und deine Freunde. Ich freue mich schon!\n\nLiebe Grüße\nLaura',
    task:
        'Antworten Sie auf die E-Mail von Laura über ihre Tournee.',
    points: [
      'Ihre Lieblingsmusik',
      'Wichtige Tipps (über Ihre Stadt)',
      'Reaktion auf Freikarten',
      'Treffen?',
    ],
  ),
];
