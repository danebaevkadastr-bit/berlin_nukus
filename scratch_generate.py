import re

raw_data = """
Aufgabe 1 - Partner A
Gesundheit
Carsten Martens 23 Jahre, Angestellter
Naja, in meinem Alter muss ich doch noch nicht auf die Gesundheit aufpassen. Ich fühle mich sehr wohl und esse und trinke einfach, was mir schmeckt. Und zum Sport bin ich nach der Arbeit einfach zu müde. Zum Glück bin ich schlank und muss nicht auf mein Gewicht achten.

Aufgabe 1 - Partner B
Gesundheit
Silke Bauer, 21 Jahre Studentin
Ich versuche schon, auf meine Gesundheit zu achten. Ich rauche nicht und mache regelmäßig Sport. Ich bin Mitglied in einem Turnierverein und jogge auch sehr oft. Nur beim Essen kann ich mich manchmal nicht zurückhalten. Ich esse nämlich unheimlich gerne Süßigkeiten und Kuchen.

Aufgabe 2 - Partner A
Ausziehen und alleine wohnen
Carsten Daubner, 18 Jahre Auszubildender:
Pünktlich zu meinem Geburtstag bin ich ausgezogen. Meine Wohnung hat nur ein Zimmer, eine kleine Küche und ein Bad. Zum Glück ist sie nicht so teuer. Meine Eltern wollten eigentlich nicht, dass ich ausziehe und sie sagten ich solle erst meine Ausbildung beenden, aber ich habe sie überzeugt, dass ich meine Freiheit brauche. Ich möchte endlich auf eigenen Beinen stehen. Jetzt geben sie mir sogar ein bisschen Geld für die Miete.

Aufgabe 2 - Partner B
Ausziehen und alleine wohnen
Jenny Groh, 21 Jahre, Studentin:
Meine Eltern hätten nichts dagegen, dass ich ausziehe. Sie würden mir sogar das Geld für die Miete geben. Aber was soll ich alleine in einer kleinen Wohnung? Im Hause meiner Eltern habe ich doch viel mehr Platz. Hier habe ich nicht nur mein eigenes Zimmer, sondern auch den Garten und die anderen Räume. Das ist doch viel bequemer. Klar, bis zur Uni bin ich lange unterwegs. Aber meine Mutter leiht mir Ihr Auto.

Aufgabe 3 - Partner A
Reise
Klaus Schmidt 31 Jahre Kundenberater
In meinem Job muss ich viel reisen. Ich schätze, dass ich fast 100000 km jedes Jahr unterwegs bin. Das meiste mit dem Firmenwagen manchmal aber auch mit dem Flugzeug. Als ich diesen Job anfing, fand ich reisen ganz toll, aber inzwischen ist es langweilig, immer nur von einem Hotelzimmer zum nächsten unterwegs zu sein.

Aufgabe 3 - Partner B
Reise
Stefanie Berger, 24 Jahre, Studentin
Reisen macht mir wahnsinnig Spaß. Immer wenn ich frei habe fahre ich weg. Da ich einige Freunde im Ausland habe, komme ich sehr viel herum. Wir besuchen uns gegenseitig, d.h. ich kann bei ihnen wohnen und musst nur die Reise bezahlen. Und Zugfahrten ist für Studenten gar nicht so teuer.

Aufgabe 4 - Partner A
Familie
Nadja Beckmann 36 Jahre, Angestellte
Ich bin ein echter Familienmensch. Ich lebe mit meinem Mann und meinen Kindern in einem kleinen Dorf. Wir verbringen sehr viel Zeit mit meinen Eltern und der Familie meiner Schwester. Meine Schwester ist auch verheiratet und hat zwei Söhne. Ich selbst habe einen Sohn und eine Tochter möchte aber noch ein drittes Kind haben.

Aufgabe 4 - Partner B
Familie
Anton Meyer 34 Jahre, Manager
Ich lebe allein und genieße diese Freiheit. Im Moment denke ich nicht über eine eigene Familie. Naja, ich habe die ideale Partnerin auch noch nicht gefunden. Ich brauche einfach meine ganze Energie für meinen Beruf. Aber vielleicht wird sich das ja später einmal ändern, wenn ich etwas älter bin.

Aufgabe 5 - Partner A
Wohnen in der Großstadt
Anna Schudt 32 Jahre, Musikerin
Also ich liebe es in einer Großstadt zu leben. Deshalb bin ich nach Berlin gezogen. Viele Menschen unterschiedliche Kulturen rund um die Uhr Veranstaltungen. Hier ist was los, hier fühle ich mich wohl. Außerdem gibt es für mich nur in einer Großstadt wie Berlin Arbeit.

Aufgabe 5 - Partner B
Wohnen in der Großstadt
Uwe Meister 36 Jahre, Beamter
Ich wohne gern auf dem Land und verbringe viel Zeit im Garten und an der frischen Luft. Das Stadtleben ist mir ganz einfach zu laut und zu hektisch. Zum Ausgehen oder einkaufen fahre ich schon mal in die nächste Stadt. Danach bin ich aber meistens froh, wenn ich wieder zu Hause sein kann.

Aufgabe 6 - Partner A
Großeltern
Katja Jantos, 29 Jahre, Fotografin
Ich habe meine Großeltern leider nie kennen gelernt. Gern hätte ich mit ihnen über ihre Kindheit und unsere Familiengeschichte gesprochen. Ich hätte ihnen auch viele Fragen gestellt.

Aufgabe 6 - Partner B
Großeltern
Michael Schmidt, 32 Jahre, Manager
Ich sehe meine Großeltern nur selten. Sie sind schon älter und erzählen immer die gleichen Geschichten von früheren Zeiten. Das finde ich langweilig. Aber so ist das eben. Manche Menschen in diesem Alter leben einfach in einer anderen Welt.

Aufgabe 7 - Partner A
Verkehrsmittel
Carola Ahrenholz, 25 Jahre, Sekretärin
Im Sommer fahre ich immer mit dem Fahrrad zur Arbeit. Dann komme ich morgens schon munter ins Büro und abends kann ich mich beim Fahren wunderbar entspannen. Nur wenn es regnet, nehme ich den Bus. Im Winter fahre ich immer mit einer Kollegin im Auto. Dafür gebe ich ihr etwas Benzingeld, so sparen wir beide und tun außerdem noch etwas für den Umweltschutz.

Aufgabe 7 - Partner B
Verkehrsmittel
Bernd Kleinefeld, 45 Jahre, Elektrotechniker
Mein Auto brauche ich am meisten für meine Freizeitaktivitäten: Am Wochenende machen wir Ausflüge, unter der Woche fahre ich in die Stadt, ins Kino oder zum Sport. Um zur Arbeit zu kommen, benutze ich auch das Auto. Und weil wir auf dem Land wohnen, muss ich ziemlich oft auch die Kinder irgendwohin bringen.

Aufgabe 8 - Partner A
Wohnen
Rainer Jobke, 42 Jahre
Wir wohnen in einer 3-Zimmer-Wohnung in der Stadt. Zwar haben die Kinder nicht genug Platz zum Spielen, aber zentral zu wohnen, hat auch Vorteile: Wir brauchen nicht lange zur Arbeit und Geschäfte und Behörden liegen ganz in der Nähe.

Aufgabe 8 - Partner B
Wohnen
Volker Kühlheim, 36 Jahre
Im Moment sind wir auf Wohnungssuche. Ein kleines Haus mit Garten in einem Vorort wäre für uns ideal. Dann könnten wir für die Kinder endlich einen Hund kaufen. Wichtig ist natürlich ein S-Bahn-Anschluss in der Nähe, denn ich muss jeden Tag in die Stadt. Und natürlich darf die Miete nicht zu hoch sein.

Aufgabe 9 - Partner A
Einkäufe
Juliane Teubert, 18 Jahre
Ich bin noch in der Ausbildung und verdiene nicht viel. Das Geld reicht meistens nicht mal bis Monatsende. Gott sei Dank wohne ich noch bei meinen Eltern und muss nur für meine persönlichen Ausgaben aufkommen: Kleidung, Kosmetik, Zeitschriften, mein Fahrgeld und ab und zu Schmuck.

Aufgabe 9 - Partner B
Einkäufe
Paul Krügel, 27 Jahre
Ich fahre einmal in der Woche in einen Großmarkt einkaufen. Dann packe ich immer den ganzen Kofferraum voll mit den Sachen für die ganze Woche. Im Großmarkt sind die Preise besser. Was ich nicht vergessen darf, ist die Einkaufsliste von meiner Frau. Sonst gebe ich zu viel Geld aus, kaufe lauter unnötige Sachen und vergesse das Wichtigste.

Aufgabe 10 - Partner A
Mensch und Tier
Darnai Müller, 13 Jahre
Endlich habe ich den Hund bekommen, den ich mir schon so lange gewünscht habe. Seit Jahren bitte ich meine Eltern darum. Aber sie wollten die Verantwortung für ein Tier nicht übernehmen. Ich musste versprechen, dass ich mich allein um Rudi kümmere, sonst muss er zurück ins Tierheim.

Aufgabe 10 - Partner B
Mensch und Tier
Vanessa Dannewald, 24 Jahre
Ich habe zwar kein Haustier, aber trotzdem habe ich ein Herz für Tiere. Nur bin ich der Meinung, dass Tiere in ihre natürliche Umgebung gehören. Deshalb bin ich auch aktives Mitglied in einem Tierschutzverein. Unser Verein setzt sich für bedrohte Tiere ein, wie zum Beispiel die Braunbären.
"""

tasks = raw_data.strip().split("\n\n")
out = ""

for i in range(0, len(tasks), 2):
    t_a = tasks[i].strip().split("\n")
    t_b = tasks[i+1].strip().split("\n")
    
    thema = t_a[1].strip()
    author_a = t_a[2].strip()
    text_a = t_a[3].strip()
    
    author_b = t_b[2].strip()
    text_b = t_b[3].strip()

    out += f"""        SprechenTest(
          thema: '{thema}',
          aufgaben: [
            SprechenAufgabe(
              partner: 'A',
              title: '{thema}',
              instruction:
                  'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
                  'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
                  'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
                  'Thema aus und sprechen Sie dabei über Ihre persönlichen '
                  'Meinungen und Erfahrungen.',
              meinung: '{text_a}',
              author: '{author_a}',
              examples: [
                'In meiner Meinung geht es um …',
                'Die Person findet ..., weil …',
                'Ich sehe das ähnlich / anders, weil …',
                'Ich persönlich habe die Erfahrung gemacht, dass …',
                'Wie ist das bei dir?',
              ],
            ),
            SprechenAufgabe(
              partner: 'B',
              title: '{thema}',
              instruction:
                  'Sie lesen eine Meinung zu einem Thema. Berichten Sie Ihrer '
                  'Gesprächspartnerin/Ihrem Gesprächspartner davon. Sie/Er hat eine '
                  'andere Meinung zum selben Thema gelesen. Tauschen Sie sich zum '
                  'Thema aus und sprechen Sie dabei über Ihre persönlichen '
                  'Meinungen und Erfahrungen.',
              meinung: '{text_b}',
              author: '{author_b}',
              examples: [
                'In meiner Meinung geht es um …',
                'Die Person sieht das so, dass …',
                'Ich sehe das ähnlich / anders, weil …',
                'Aus eigener Erfahrung kann ich sagen, dass …',
                'Und wie denkst du darüber?',
              ],
            ),
          ],
        ),
"""

with open('scratch_aufgaben.txt', 'w', encoding='utf-8') as f:
    f.write(out)
print('Done')
