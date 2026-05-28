// Data models and mock questions for Hören (A1)

class HorenQuestion {
  final String audioTitle;   // Audio fayl nomi / tavsifi
  final String audioUrl;     // TODO: real audio URL
  final String question;     // Savol matni
  final List<String> options; // A, B, C javoblar
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

// ── A1 Mock Data ─────────────────────────────────────────────────────────────

const horenA1 = HorenLevel(
  level: 'A1',
  teile: [
    // Teil 1 – Audio-Picture Matching (5 savol)
    HorenTeil(
      teilNumber: 1,
      questions: [
        HorenQuestion(
          audioTitle: 'Audio 1 – Im Supermarkt',
          audioUrl: '',
          question: 'Wo ist die Person?',
          options: ['Im Supermarkt', 'Im Restaurant', 'Im Bahnhof'],
          correctAnswer: 'Im Supermarkt',
        ),
        HorenQuestion(
          audioTitle: 'Audio 2 – Das Wetter',
          audioUrl: '',
          question: 'Wie ist das Wetter?',
          options: ['Es regnet', 'Es schneit', 'Die Sonne scheint'],
          correctAnswer: 'Die Sonne scheint',
        ),
        HorenQuestion(
          audioTitle: 'Audio 3 – Familie',
          audioUrl: '',
          question: 'Wer spricht?',
          options: ['Eine Mutter', 'Ein Kind', 'Ein Lehrer'],
          correctAnswer: 'Eine Mutter',
        ),
        HorenQuestion(
          audioTitle: 'Audio 4 – Uhrzeit',
          audioUrl: '',
          question: 'Wie spät ist es?',
          options: ['Es ist 8 Uhr', 'Es ist 10 Uhr', 'Es ist 12 Uhr'],
          correctAnswer: 'Es ist 10 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Audio 5 – Verkehr',
          audioUrl: '',
          question: 'Womit fährt die Person?',
          options: ['Mit dem Bus', 'Mit dem Auto', 'Mit dem Fahrrad'],
          correctAnswer: 'Mit dem Bus',
        ),
      ],
    ),

    // Teil 2 – Phone Conversations (5 savol)
    HorenTeil(
      teilNumber: 2,
      questions: [
        HorenQuestion(
          audioTitle: 'Telefongespräch 1 – Termin',
          audioUrl: '',
          question: 'Wann ist der Termin?',
          options: ['Am Montag um 9 Uhr', 'Am Dienstag um 10 Uhr', 'Am Mittwoch um 11 Uhr'],
          correctAnswer: 'Am Montag um 9 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 2 – Adresse',
          audioUrl: '',
          question: 'Wo wohnt die Person?',
          options: ['In der Hauptstraße 5', 'In der Bahnhofstraße 12', 'In der Schulstraße 3'],
          correctAnswer: 'In der Bahnhofstraße 12',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 3 – Bestellung',
          audioUrl: '',
          question: 'Was bestellt die Person?',
          options: ['Eine Pizza', 'Einen Salat', 'Eine Suppe'],
          correctAnswer: 'Eine Pizza',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 4 – Öffnungszeiten',
          audioUrl: '',
          question: 'Wann ist das Geschäft geöffnet?',
          options: ['Von 8 bis 18 Uhr', 'Von 9 bis 20 Uhr', 'Von 10 bis 19 Uhr'],
          correctAnswer: 'Von 9 bis 20 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Telefongespräch 5 – Preis',
          audioUrl: '',
          question: 'Wie viel kostet das Ticket?',
          options: ['5 Euro', '8 Euro', '12 Euro'],
          correctAnswer: '8 Euro',
        ),
      ],
    ),

    // Teil 3 – Short Announcements (5 savol)
    HorenTeil(
      teilNumber: 3,
      questions: [
        HorenQuestion(
          audioTitle: 'Durchsage 1 – Bahnhof',
          audioUrl: '',
          question: 'Von welchem Gleis fährt der Zug ab?',
          options: ['Gleis 3', 'Gleis 5', 'Gleis 7'],
          correctAnswer: 'Gleis 5',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 2 – Supermarkt',
          audioUrl: '',
          question: 'Was ist im Angebot?',
          options: ['Brot', 'Milch', 'Äpfel'],
          correctAnswer: 'Milch',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 3 – Schule',
          audioUrl: '',
          question: 'Wann beginnt die Veranstaltung?',
          options: ['Um 14 Uhr', 'Um 15 Uhr', 'Um 16 Uhr'],
          correctAnswer: 'Um 15 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 4 – Flughafen',
          audioUrl: '',
          question: 'Welcher Flug wird aufgerufen?',
          options: ['Flug nach Berlin', 'Flug nach München', 'Flug nach Hamburg'],
          correctAnswer: 'Flug nach München',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 5 – Arztpraxis',
          audioUrl: '',
          question: 'Wer wird aufgerufen?',
          options: ['Herr Müller', 'Frau Schmidt', 'Herr Weber'],
          correctAnswer: 'Frau Schmidt',
        ),
      ],
    ),
  ],
);
