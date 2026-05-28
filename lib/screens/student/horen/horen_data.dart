// Data models and questions for Hören A1 (Goethe Institut)

const _base =
    'https://res.cloudinary.com/dmk6ir51m/video/upload/v1779954896';

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
          correctAnswer: 'Im Restaurant',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _t1q2,
          question: 'Wann kommt der Zug?',
          options: ['Um 14:15 Uhr', 'Um 15:15 Uhr', 'Um 14:45 Uhr'],
          correctAnswer: 'Um 14:15 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _t1q3,
          question: 'Was trinkt die Frau?',
          options: ['Tee', 'Kaffee', 'Wasser'],
          correctAnswer: 'Kaffee',
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
          correctAnswer: 'Am Donnerstag',
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
          correctAnswer: 'Schnitzel',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _t1q10,
          question: 'Woher kommt Ana?',
          options: ['Aus Spanien', 'Aus Portugal', 'Aus Italien'],
          correctAnswer: 'Aus Spanien',
        ),
      ],
    ),

    // ── Teil 2 – placeholder ──────────────────────────────────────────────────
    HorenTeil(
      teilNumber: 2,
      questions: [
        HorenQuestion(
          audioTitle: 'Telefongespräch 1',
          audioUrl: '',
          question: 'Wann ist der Termin?',
          options: ['Am Montag um 9 Uhr', 'Am Dienstag um 10 Uhr', 'Am Mittwoch um 11 Uhr'],
          correctAnswer: 'Am Montag um 9 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 2',
          audioUrl: '',
          question: 'Wo wohnt die Person?',
          options: ['In der Hauptstraße 5', 'In der Bahnhofstraße 12', 'In der Schulstraße 3'],
          correctAnswer: 'In der Bahnhofstraße 12',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 3',
          audioUrl: '',
          question: 'Was bestellt die Person?',
          options: ['Eine Pizza', 'Einen Salat', 'Eine Suppe'],
          correctAnswer: 'Eine Pizza',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 4',
          audioUrl: '',
          question: 'Wann ist das Geschäft geöffnet?',
          options: ['Von 8 bis 18 Uhr', 'Von 9 bis 20 Uhr', 'Von 10 bis 19 Uhr'],
          correctAnswer: 'Von 9 bis 20 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 5',
          audioUrl: '',
          question: 'Wie viel kostet das Ticket?',
          options: ['5 Euro', '8 Euro', '12 Euro'],
          correctAnswer: '8 Euro',
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
