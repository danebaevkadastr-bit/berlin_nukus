// Nemis tili Video-Dialoglar (Nicos Weg & Easy German) ma'lumotlar modeli va namunalari.

class GermanWord {
  final String wordDe;
  final String transUz;
  final String transKaa;
  final String transRu;
  final String exampleDe;

  const GermanWord({
    required this.wordDe,
    required this.transUz,
    required this.transKaa,
    required this.transRu,
    this.exampleDe = '',
  });

  String translationFor(String langCode) {
    if (langCode == 'kaa') return transKaa;
    if (langCode == 'ru') return transRu;
    return transUz;
  }
}

class SubtitleSegment {
  final int startTimeSec;
  final int endTimeSec;
  final String textDe;
  final List<GermanWord> words;

  const SubtitleSegment({
    required this.startTimeSec,
    required this.endTimeSec,
    required this.textDe,
    required this.words,
  });
}

class VideoQuizQuestion {
  final Map<String, String> questionText;
  final Map<String, List<String>> options;
  final int correctAnswerIndex;
  final Map<String, String> explanation;

  const VideoQuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  String getQuestion(String langCode) {
    return questionText[langCode] ?? questionText['uz'] ?? '';
  }

  List<String> getOptions(String langCode) {
    return options[langCode] ?? options['uz'] ?? [];
  }

  String getExplanation(String langCode) {
    return explanation[langCode] ?? explanation['uz'] ?? '';
  }
}

class GermanVideo {
  final String id;
  final String title;
  final String level; // A1, A2, B1
  final String youtubeId;
  final String durationText;
  final String description;
  final String category; // Nicos Weg, Easy German
  final List<SubtitleSegment> subtitles;
  final List<VideoQuizQuestion> quizQuestions;

  const GermanVideo({
    required this.id,
    required this.title,
    required this.level,
    required this.youtubeId,
    required this.durationText,
    required this.description,
    required this.category,
    required this.subtitles,
    required this.quizQuestions,
  });
}

/// Nicos Weg A1, A2, B1 va Easy German rasmiy seriyalari (100% Embeddable YouTube IDs)
final List<GermanVideo> germanVideosList = [
  // 1. Nicos Weg A1 (Deutsche Welle)
  const GermanVideo(
    id: 'nicos_weg_a1_full',
    title: 'Nicos Weg A1 - Ankunft in Deutschland',
    level: 'A1',
    category: 'Nicos Weg',
    youtubeId: 'v8Jt_Z6HnMs',
    durationText: '1:42:00',
    description: 'Nico Germaniyaga aeroport orqali keladi va nemis tilida tanishishni o\'rganadi.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Hallo! Willkommen in Deutschland.',
        words: [
          GermanWord(wordDe: 'Hallo!', transUz: 'Salom!', transKaa: 'Sálem!', transRu: 'Привет!'),
          GermanWord(wordDe: 'Willkommen', transUz: 'Hush kelibsiz', transKaa: 'Xosh kelipsiz', transRu: 'Добро пожаловать'),
          GermanWord(wordDe: 'in', transUz: 'da / ga', transKaa: '-da / -ǵa', transRu: 'в'),
          GermanWord(wordDe: 'Deutschland.', transUz: 'Germaniya', transKaa: 'Germaniya', transRu: 'Германия'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 9,
        endTimeSec: 16,
        textDe: 'Ich heiße Nico. Wie heißt du?',
        words: [
          GermanWord(wordDe: 'Ich', transUz: 'Men', transKaa: 'Men', transRu: 'Я'),
          GermanWord(wordDe: 'heiße', transUz: 'ismim ...', transKaa: 'atım ...', transRu: 'зовут ...'),
          GermanWord(wordDe: 'Nico.', transUz: 'Niko', transKaa: 'Niko', transRu: 'Нико'),
          GermanWord(wordDe: 'Wie', transUz: 'Qanday', transKaa: 'Qanday', transRu: 'Как'),
          GermanWord(wordDe: 'heißt', transUz: 'ismingiz', transKaa: 'atınız', transRu: 'зовут'),
          GermanWord(wordDe: 'du?', transUz: 'sen?', transKaa: 'sen?', transRu: 'ты?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 17,
        endTimeSec: 25,
        textDe: 'Ich komme aus Spanien. Woher kommst du?',
        words: [
          GermanWord(wordDe: 'Ich', transUz: 'Men', transKaa: 'Men', transRu: 'Я'),
          GermanWord(wordDe: 'komme', transUz: 'kelaman', transKaa: 'kelemen', transRu: 'прихожу'),
          GermanWord(wordDe: 'aus', transUz: 'dan', transKaa: '-dan', transRu: 'из'),
          GermanWord(wordDe: 'Spanien.', transUz: 'Ispaniya', transKaa: 'Ispaniya', transRu: 'Испания'),
          GermanWord(wordDe: 'Woher', transUz: 'Qayerdan', transKaa: 'Qay jerden', transRu: 'Откуда'),
          GermanWord(wordDe: 'kommst', transUz: 'kelasan', transKaa: 'keleseń', transRu: 'приходишь'),
          GermanWord(wordDe: 'du?', transUz: 'sen?', transKaa: 'sen?', transRu: 'ты?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 26,
        endTimeSec: 35,
        textDe: 'Entschuldigung, wo ist der Flughafen?',
        words: [
          GermanWord(wordDe: 'Entschuldigung,', transUz: 'Kechirasiz,', transKaa: 'Keshirińiz,', transRu: 'Извините,'),
          GermanWord(wordDe: 'wo', transUz: 'qayerda', transKaa: 'qay jerde', transRu: 'где'),
          GermanWord(wordDe: 'ist', transUz: 'joylashgan', transKaa: 'jaylasqan', transRu: 'находится'),
          GermanWord(wordDe: 'der', transUz: 'artikl', transKaa: 'artikl', transRu: 'артикль'),
          GermanWord(wordDe: 'Flughafen?', transUz: 'Aeroport?', transKaa: 'Aeroport?', transRu: 'Аэропорт?'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 2. Nicos Weg A2 (Deutsche Welle)
  const GermanVideo(
    id: 'nicos_weg_a2_full',
    title: 'Nicos Weg A2 - Alltag in Deutschland',
    level: 'A2',
    category: 'Nicos Weg',
    youtubeId: '4-eDoThe6qo',
    durationText: '1:46:00',
    description: 'Niconing Germaniyadagi maishiy va kundalik hayoti suhbatlari.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Guten Tag! Was möchten Sie trinken?',
        words: [
          GermanWord(wordDe: 'Guten', transUz: 'Xayrli', transKaa: 'Xayırlı', transRu: 'Добрый'),
          GermanWord(wordDe: 'Tag!', transUz: 'Kun!', transKaa: 'Kún!', transRu: 'День!'),
          GermanWord(wordDe: 'Was', transUz: 'Nima', transKaa: 'Ne', transRu: 'Что'),
          GermanWord(wordDe: 'möchten', transUz: 'xohlaysiz', transKaa: 'qáleysiz', transRu: 'хотите'),
          GermanWord(wordDe: 'Sie', transUz: 'Siz', transKaa: 'Siz', transRu: 'Вы'),
          GermanWord(wordDe: 'trinken?', transUz: 'ichishni?', transKaa: 'ishiwdi?', transRu: 'пить?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 9,
        endTimeSec: 16,
        textDe: 'Ich hätte gerne einen Kaffee und ein Stück Kuchen.',
        words: [
          GermanWord(wordDe: 'Ich', transUz: 'Men', transKaa: 'Men', transRu: 'Я'),
          GermanWord(wordDe: 'hätte', transUz: 'olar edim', transKaa: 'alar edim', transRu: 'взял бы'),
          GermanWord(wordDe: 'gerne', transUz: 'mumnuniyat bilan', transKaa: 'quwanısh menen', transRu: 'с удовольствием'),
          GermanWord(wordDe: 'einen', transUz: 'bitta', transKaa: 'bir', transRu: 'один'),
          GermanWord(wordDe: 'Kaffee', transUz: 'Kofe', transKaa: 'Kofe', transRu: 'Кофе'),
          GermanWord(wordDe: 'und', transUz: 'va', transKaa: 'hám', transRu: 'и'),
          GermanWord(wordDe: 'ein', transUz: 'bir', transKaa: 'bir', transRu: 'один'),
          GermanWord(wordDe: 'Stück', transUz: 'bo\'lak / qism', transKaa: 'bólek', transRu: 'кусочек'),
          GermanWord(wordDe: 'Kuchen.', transUz: 'Pirog / Tort', transKaa: 'Pirog', transRu: 'Пирог'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 3. Nicos Weg B1 (Deutsche Welle)
  const GermanVideo(
    id: 'nicos_weg_b1_full',
    title: 'Nicos Weg B1 - Beruf und Zukunft',
    level: 'B1',
    category: 'Nicos Weg',
    youtubeId: 'qWn-rD_y62A',
    durationText: '1:54:00',
    description: 'Nico ish qidiradi, intervyulardan o\'tadi va kelajak rejalarini tuzadi.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Wir müssen zusammen die Zukunft planen.',
        words: [
          GermanWord(wordDe: 'Wir', transUz: 'Biz', transKaa: 'Biz', transRu: 'Мы'),
          GermanWord(wordDe: 'müssen', transUz: 'kerak', transKaa: 'kerek', transRu: 'должны'),
          GermanWord(wordDe: 'zusammen', transUz: 'birgalikda', transKaa: 'birgelikde', transRu: 'вместе'),
          GermanWord(wordDe: 'die', transUz: 'artikl', transKaa: 'artikl', transRu: 'артикль'),
          GermanWord(wordDe: 'Zukunft', transUz: 'kelajakni', transKaa: 'kelajaktı', transRu: 'будущее'),
          GermanWord(wordDe: 'planen.', transUz: 'rejalashtirish', transKaa: 'rejalashtırıw', transRu: 'планировать'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 4. Easy German B1 - Was machst du beruflich?
  const GermanVideo(
    id: 'easy_german_b1_ep1',
    title: 'Easy German B1 - Was machst du beruflich?',
    level: 'B1',
    category: 'Easy German',
    youtubeId: '82_d7TzRk7U',
    durationText: '4:05',
    description: 'Germaniya ko\'chalarida odamlarning kasbi va ishi haqidagi intervyular.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Heute fragen wir die Leute in Berlin nach ihrem Beruf.',
        words: [
          GermanWord(wordDe: 'Heute', transUz: 'Bugun', transKaa: 'Búgin', transRu: 'Сегодня'),
          GermanWord(wordDe: 'fragen', transUz: 'so\'raymiz', transKaa: 'soraymız', transRu: 'спрашиваем'),
          GermanWord(wordDe: 'wir', transUz: 'biz', transKaa: 'biz', transRu: 'мы'),
          GermanWord(wordDe: 'die', transUz: 'artikl', transKaa: 'artikl', transRu: 'артикль'),
          GermanWord(wordDe: 'Leute', transUz: 'odamlar', transKaa: 'adamlar', transRu: 'люди'),
          GermanWord(wordDe: 'in', transUz: 'da', transKaa: '-da', transRu: 'в'),
          GermanWord(wordDe: 'Berlin', transUz: 'Berlin', transKaa: 'Berlin', transRu: 'Берлин'),
          GermanWord(wordDe: 'nach', transUz: 'haqida', transKaa: 'haqqında', transRu: 'о'),
          GermanWord(wordDe: 'ihrem', transUz: 'ularning', transKaa: 'olardıń', transRu: 'их'),
          GermanWord(wordDe: 'Beruf.', transUz: 'kasbi / mutaxassisligi', transKaa: 'kásibi', transRu: 'профессия'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 5. Easy German A2 - Wie lernt man Deutsch?
  const GermanVideo(
    id: 'easy_german_a2_ep1',
    title: 'Easy German A2 - Wie lernt man Deutsch?',
    level: 'A2',
    category: 'Easy German',
    youtubeId: 'b-F2-y9sK88',
    durationText: '5:12',
    description: 'Ko\'chalardagi nemislardan til o\'rganish sirlari haqida intervyular.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Herzlich willkommen zu einer neuen Folge von Easy German!',
        words: [
          GermanWord(wordDe: 'Herzlich', transUz: 'Samimiy', transKaa: 'Samimiy', transRu: 'Сердечно'),
          GermanWord(wordDe: 'willkommen', transUz: 'hush kelibsiz', transKaa: 'xosh kelipsiz', transRu: 'добро пожаловать'),
          GermanWord(wordDe: 'zu', transUz: 'ga', transKaa: '-ǵa', transRu: 'к'),
          GermanWord(wordDe: 'einer', transUz: 'bir', transKaa: 'bir', transRu: 'одной'),
          GermanWord(wordDe: 'neuen', transUz: 'yangi', transKaa: 'jańa', transRu: 'новой'),
          GermanWord(wordDe: 'Folge', transUz: 'qismga / epizodga', transKaa: 'bólimge', transRu: 'серии'),
          GermanWord(wordDe: 'von', transUz: 'dan', transKaa: '-dan', transRu: 'от'),
          GermanWord(wordDe: 'Easy', transUz: 'Easy', transKaa: 'Easy', transRu: 'Easy'),
          GermanWord(wordDe: 'German!', transUz: 'German!', transKaa: 'German!', transRu: 'German!'),
        ],
      ),
    ],
    quizQuestions: [],
  ),
];
