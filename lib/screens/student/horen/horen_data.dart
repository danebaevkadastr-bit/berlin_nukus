// Data models and questions for Hören A1 (Goethe Institut)

const _base =
    'https://res.cloudinary.com/dmk6ir51m/video/upload/v1779954896';
const _base2 =
    'https://res.cloudinary.com/dmk6ir51m/video/upload/v1779962870';

const _t1q1  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q1_iyvyew.mp3';
const _t1q2  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q2_ncpyhi.mp3';
const _t1q3  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q3_fc46of.mp3';
const _t1q4  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q4_qbfhql.mp3';
const _t1q5  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q5_sh6laj.mp3';
const _t1q6  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q6_x3nti0.mp3';
const _t1q7  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q7_x8bzcs.mp3';
const _t1q8  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q8_yneizj.mp3';
const _t1q9  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q9_qinhqv.mp3';
const _t1q10 = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q10_y8p8h2.mp3';

const _t2q1  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q1_hcyzuv.mp3';
const _t2q2  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q2_hbo261.mp3';
const _t2q3  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q3_l9c1fo.mp3';
const _t2q4  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q4_iag768.mp3';
const _t2q5  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q5_kv6asj.mp3';
const _t2q6  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q6_smruiw.mp3';
const _t2q7  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q7_u25tcp.mp3';
const _t2q8  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q8_vtnxco.mp3';
const _t2q9  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q9_koqmsi.mp3';
const _t2q10 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q10_dn9oes.mp3';
const _t2q11 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q11_ufuvvz.mp3';
const _t2q12 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q12_aszxvv.mp3';
const _t2q13 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q13_cla3j6.mp3';
const _t2q14 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q14_p7mtk3.mp3';
const _t2q15 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q15_yvoebs.mp3';
const _t2q16 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q16_r0ldsv.mp3';
const _t2q17 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q17_yjfeww.mp3';
const _t2q18 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q18_jzrbnr.mp3';
const _t2q19 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q19_jku5ch.mp3';
const _t2q20 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q20_j9jlru.mp3';

class HorenQuestion {
  final String audioTitle;
  final String audioUrl;
  final String question;
  final List<String> options;
  final String correctAnswer;

  const HorenQuestion({
    required this.audioTitle,
    required this.audioUrl,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class HorenTeil {
  final int teilNumber;
  final List<HorenQuestion> questions;

  const HorenTeil({
    required this.teilNumber,
    required this.questions,
  });
}

class HorenLevel {
  final String level;
  final List<HorenTeil> teile;

  const HorenLevel({required this.level, required this.teile});
}

// ── A1 Data ───────────────────────────────────────────────────────────────────

const horenA1 = HorenLevel(
  level: 'A1',
  teile: [
    // ── Teil 1 – 10 savollar ─────────────────────────────────────────────────
    HorenTeil(
      teilNumber: 1,
      questions: [
        HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _t1q1,
          question: 'Wo wollen die Freunde essen?',
          options: ['Im Park', 'Zu Hause', 'Im Restaurant'],
          correctAnswer: 'Zu Hause',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _t1q2,
          question: 'Wann kommt der Zug?',
          options: ['Um 14:15 Uhr', 'Um 15:15 Uhr', 'Um 14:45 Uhr'],
          correctAnswer: 'Um 14:45 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _t1q3,
          question: 'Was trinkt die Frau?',
          options: ['Tee', 'Kaffee', 'Wasser'],
          correctAnswer: 'Tee',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _t1q4,
          question: 'Wie viele Kinder hat Frau Meier?',
          options: ['Zwei', 'Eins', 'Drei'],
          correctAnswer: 'Zwei',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _t1q5,
          question: 'Wo ist die Post?',
          options: [
            'Links um die Ecke',
            'Neben dem Supermarkt',
            'Geradeaus und rechts',
          ],
          correctAnswer: 'Geradeaus und rechts',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _t1q6,
          question: 'Wann hat der Arzt wieder auf?',
          options: ['Am Donnerstag', 'Am Montag', 'Am Freitag'],
          correctAnswer: 'Am Montag',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _t1q7,
          question: 'Was kostet das T-Shirt?',
          options: ['Zwölf Euro', 'Zweiundzwanzig Euro', 'Zwanzig Euro'],
          correctAnswer: 'Zwölf Euro',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _t1q8,
          question: 'Wann beginnt der Film?',
          options: ['Um acht Uhr', 'Um neun Uhr', 'Um halb neun'],
          correctAnswer: 'Um halb neun',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _t1q9,
          question: 'Was bestellt der Mann?',
          options: ['Schnitzel', 'Pizza', 'Suppe'],
          correctAnswer: 'Suppe',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _t1q10,
          question: 'Woher kommt Ana?',
          options: ['Aus Spanien', 'Aus Portugal', 'Aus Italien'],
          correctAnswer: 'Aus Portugal',
        ),
      ],
    ),

    // ── Teil 2 – Richtig / Falsch (20 savollar) ──────────────────────────────
    HorenTeil(
      teilNumber: 2,
      questions: [
        HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _t2q1,
          question: 'Der Zug nach München fährt von Gleis 5.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _t2q2,
          question: 'Die Fahrgäste sollen beim Busfahrer ein Ticket kaufen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _t2q3,
          question: 'Herr Weber soll zum Ausgang kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _t2q4,
          question: 'Das Geschäft schließt um 19 Uhr.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _t2q5,
          question: 'Die Fahrgäste sollen nicht aussteigen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _t2q6,
          question: 'Die Kinder können im 2. Stock spielen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _t2q7,
          question: 'Der Flug nach Berlin hat Verspätung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _t2q8,
          question: 'Die Fahrgäste sollen um 11 Uhr am Bus sein.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _t2q9,
          question: 'Frau Klein soll zur Information im Erdgeschoss kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _t2q10,
          question: 'Der Zug fährt in 10 Minuten weiter.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 11',
          audioUrl: _t2q11,
          question: 'Die Kunden sollen zur Kasse 3 gehen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 12',
          audioUrl: _t2q12,
          question: 'Man kann heute bis 22 Uhr schwimmen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 13',
          audioUrl: _t2q13,
          question: 'Der kleine Jonas sucht seine Mutter.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 14',
          audioUrl: _t2q14,
          question: 'Die Fahrgäste sollen rechts aussteigen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 15',
          audioUrl: _t2q15,
          question: 'Der Flug nach Madrid ist zum Einsteigen bereit.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 16',
          audioUrl: _t2q16,
          question: 'Die Fahrgäste können ihr Gepäck mitnehmen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 17',
          audioUrl: _t2q17,
          question: 'Obst und Gemüse sind heute besonders günstig.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 18',
          audioUrl: _t2q18,
          question: 'Der Bus fährt zum Krankenhaus.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 19',
          audioUrl: _t2q19,
          question: 'Herr Berger soll zum Schalter 12 kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 20',
          audioUrl: _t2q20,
          question: 'Die Besucher sollen zum Ausgang gehen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
      ],
    ),

    // ── Teil 3 – placeholder ──────────────────────────────────────────────────
    HorenTeil(
      teilNumber: 3,
      questions: [
        HorenQuestion(
          audioTitle: 'Durchsage 1',
          audioUrl: '',
          question: 'Von welchem Gleis fährt der Zug ab?',
          options: ['Gleis 3', 'Gleis 5', 'Gleis 7'],
          correctAnswer: 'Gleis 5',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 2',
          audioUrl: '',
          question: 'Was ist im Angebot?',
          options: ['Brot', 'Milch', 'Äpfel'],
          correctAnswer: 'Milch',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 3',
          audioUrl: '',
          question: 'Wann beginnt die Veranstaltung?',
          options: ['Um 14 Uhr', 'Um 15 Uhr', 'Um 16 Uhr'],
          correctAnswer: 'Um 15 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 4',
          audioUrl: '',
          question: 'Welcher Flug wird aufgerufen?',
          options: ['Flug nach Berlin', 'Flug nach München', 'Flug nach Hamburg'],
          correctAnswer: 'Flug nach München',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 5',
          audioUrl: '',
          question: 'Wer wird aufgerufen?',
          options: ['Herr Müller', 'Frau Schmidt', 'Herr Weber'],
          correctAnswer: 'Frau Schmidt',
        ),
      ],
    ),
  ],
);
