// Data models and mock questions for Hören (A1)

const _base =
    'https://res.cloudinary.com/dmk6ir51m/video/upload/v1779954896';

// Cloudinary public IDs (fayl nomi + random suffix)
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
    // Teil 1 – Audio-Picture Matching (10 savol)
    HorenTeil(
      teilNumber: 1,
      questions: [
        HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _t1q1,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _t1q2,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _t1q3,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _t1q4,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _t1q5,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _t1q6,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _t1q7,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _t1q8,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _t1q9,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _t1q10,
          question: 'Was hört man?',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
      ],
    ),

    // Teil 2 – Phone Conversations (placeholder)
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

    // Teil 3 – Short Announcements (placeholder)
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
