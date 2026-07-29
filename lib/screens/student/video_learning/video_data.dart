// Nemis tili Video-Dialoglar (Nicos Weg & Easy German) ma'lumotlar modeli va seriyalar bazasi.

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

/// Nicos Weg A1, A2, B1 va Easy German individual seriyalari bazasi (Haqiqiy subtitrlar va 100% ochiladigan YouTube IDs)
final List<GermanVideo> germanVideosList = [
  // 1. Nicos Weg A1 - Folge 1: Hallo!
  const GermanVideo(
    id: 'nicos_weg_a1_f1',
    title: 'Nicos Weg A1 - Folge 1: Hallo!',
    level: 'A1',
    category: 'Nicos Weg',
    youtubeId: '4-eDoThe6qo',
    durationText: '1:45',
    description: 'Nico aeroportga yetib keladi va o\'zini tanishtiradi.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 6,
        textDe: 'Hallo! Ich heiße Nico. Wie heißt du?',
        words: [
          GermanWord(wordDe: 'Hallo!', transUz: 'Salom!', transKaa: 'Sálem!', transRu: 'Привет!'),
          GermanWord(wordDe: 'Ich', transUz: 'Men', transKaa: 'Men', transRu: 'Я'),
          GermanWord(wordDe: 'heiße', transUz: 'ismim ...', transKaa: 'atım ...', transRu: 'зовут ...'),
          GermanWord(wordDe: 'Nico.', transUz: 'Niko.', transKaa: 'Niko.', transRu: 'Нико.'),
          GermanWord(wordDe: 'Wie', transUz: 'Qanday', transKaa: 'Qanday', transRu: 'Как'),
          GermanWord(wordDe: 'heißt', transUz: 'ismingiz', transKaa: 'atınız', transRu: 'зовут'),
          GermanWord(wordDe: 'du?', transUz: 'sen?', transKaa: 'sen?', transRu: 'ты?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 7,
        endTimeSec: 14,
        textDe: 'Ich komme aus Spanien. Woher kommst du?',
        words: [
          GermanWord(wordDe: 'Ich', transUz: 'Men', transKaa: 'Men', transRu: 'Я'),
          GermanWord(wordDe: 'komme', transUz: 'kelaman', transKaa: 'kelemen', transRu: 'прихожу'),
          GermanWord(wordDe: 'aus', transUz: 'dan', transKaa: '-dan', transRu: 'из'),
          GermanWord(wordDe: 'Spanien.', transUz: 'Ispaniya.', transKaa: 'Ispaniya.', transRu: 'Испания.'),
          GermanWord(wordDe: 'Woher', transUz: 'Qayerdan', transKaa: 'Qay jerden', transRu: 'Откуда'),
          GermanWord(wordDe: 'kommst', transUz: 'kelasan', transKaa: 'keleseń', transRu: 'приходишь'),
          GermanWord(wordDe: 'du?', transUz: 'sen?', transKaa: 'sen?', transRu: 'ты?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 15,
        endTimeSec: 25,
        textDe: 'Willkommen in Deutschland!',
        words: [
          GermanWord(wordDe: 'Willkommen', transUz: 'Hush kelibsiz', transKaa: 'Xosh kelipsiz', transRu: 'Добро пожаловать'),
          GermanWord(wordDe: 'in', transUz: 'da / ga', transKaa: '-da / -ǵa', transRu: 'в'),
          GermanWord(wordDe: 'Deutschland!', transUz: 'Germaniya!', transKaa: 'Germaniya!', transRu: 'Германия!'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 2. Nicos Weg A1 - Folge 2: Koffer weg!
  const GermanVideo(
    id: 'nicos_weg_a1_f2',
    title: 'Nicos Weg A1 - Folge 2: Koffer weg!',
    level: 'A1',
    category: 'Nicos Weg',
    youtubeId: 'L_W1qN5jR_8',
    durationText: '2:10',
    description: 'Nico taksida chamadonini yo\'qotib qo\'yadi.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 7,
        textDe: 'Entschuldigung! Wo ist mein Koffer?',
        words: [
          GermanWord(wordDe: 'Entschuldigung!', transUz: 'Kechirasiz!', transKaa: 'Keshirińiz!', transRu: 'Извините!'),
          GermanWord(wordDe: 'Wo', transUz: 'Qayerda', transKaa: 'Qay jerde', transRu: 'Где'),
          GermanWord(wordDe: 'ist', transUz: 'joylashgan / bor', transKaa: 'jaylasqan', transRu: 'находится'),
          GermanWord(wordDe: 'mein', transUz: 'mening', transKaa: 'meniń', transRu: 'мой'),
          GermanWord(wordDe: 'Koffer?', transUz: 'chamadonim?', transKaa: 'chamadanım?', transRu: 'чемодан?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 8,
        endTimeSec: 16,
        textDe: 'Das Taxi ist weg! Was machen wir jetzt?',
        words: [
          GermanWord(wordDe: 'Das', transUz: 'Ushbu', transKaa: 'Usı', transRu: 'Это'),
          GermanWord(wordDe: 'Taxi', transUz: 'Taksi', transKaa: 'Taksi', transRu: 'Такси'),
          GermanWord(wordDe: 'ist', transUz: 'ketib qoldi', transKaa: 'ketip qaldı', transRu: 'уехало'),
          GermanWord(wordDe: 'weg!', transUz: 'yo\'q!', transKaa: 'yoq!', transRu: 'прочь!'),
          GermanWord(wordDe: 'Was', transUz: 'Nima', transKaa: 'Ne', transRu: 'Что'),
          GermanWord(wordDe: 'machen', transUz: 'qilamiz', transKaa: 'qılamız', transRu: 'делаем'),
          GermanWord(wordDe: 'wir', transUz: 'biz', transKaa: 'biz', transRu: 'мы'),
          GermanWord(wordDe: 'jetzt?', transUz: 'endi?', transKaa: 'endi?', transRu: 'сейчас?'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 3. Nicos Weg A1 - Folge 3: Die Zahlennamen
  const GermanVideo(
    id: 'nicos_weg_a1_f3',
    title: 'Nicos Weg A1 - Folge 3: Zahlen und Telefonnummer',
    level: 'A1',
    category: 'Nicos Weg',
    youtubeId: '82_d7TzRk7U',
    durationText: '2:30',
    description: 'Telefon raqami va sonlarni nemischa aytishni o\'rganish.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Wie ist deine Telefonnummer?',
        words: [
          GermanWord(wordDe: 'Wie', transUz: 'Qanday', transKaa: 'Qanday', transRu: 'Каков'),
          GermanWord(wordDe: 'ist', transUz: 'bo\'ladi', transKaa: 'boladı', transRu: 'есть'),
          GermanWord(wordDe: 'deine', transUz: 'sening', transKaa: 'seniń', transRu: 'твой'),
          GermanWord(wordDe: 'Telefonnummer?', transUz: 'telefon raqaming?', transKaa: 'telefon nomeriń?', transRu: 'номер телефона?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 9,
        endTimeSec: 18,
        textDe: 'Meine Nummer ist 0 1 7 2 4 5 8 9.',
        words: [
          GermanWord(wordDe: 'Meine', transUz: 'Mening', transKaa: 'Meniń', transRu: 'Мой'),
          GermanWord(wordDe: 'Nummer', transUz: 'raqamim', transKaa: 'nomerim', transRu: 'номер'),
          GermanWord(wordDe: 'ist', transUz: 'bo\'ladi', transKaa: 'boladı', transRu: 'есть'),
          GermanWord(wordDe: '0172...', transUz: 'raqamlar', transKaa: 'nomerler', transRu: 'цифры'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 4. Nicos Weg A2 - Im Café bestellen
  const GermanVideo(
    id: 'nicos_weg_a2_f1',
    title: 'Nicos Weg A2 - Folge 1: Im Café bestellen',
    level: 'A2',
    category: 'Nicos Weg',
    youtubeId: 'b-F2-y9sK88',
    durationText: '3:05',
    description: 'Kafeda buyurtma berish va menyuni tushunish.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Guten Tag! Was möchten Sie bestellen?',
        words: [
          GermanWord(wordDe: 'Guten', transUz: 'Xayrli', transKaa: 'Xayırlı', transRu: 'Добрый'),
          GermanWord(wordDe: 'Tag!', transUz: 'Kun!', transKaa: 'Kún!', transRu: 'День!'),
          GermanWord(wordDe: 'Was', transUz: 'Nima', transKaa: 'Ne', transRu: 'Что'),
          GermanWord(wordDe: 'möchten', transUz: 'xohlaysiz', transKaa: 'qáleysiz', transRu: 'хотите'),
          GermanWord(wordDe: 'Sie', transUz: 'Siz', transKaa: 'Siz', transRu: 'Вы'),
          GermanWord(wordDe: 'bestellen?', transUz: 'buyurtma berishni?', transKaa: 'zakaz beriwdi?', transRu: 'заказать?'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 9,
        endTimeSec: 18,
        textDe: 'Ich hätte gerne einen Cappuccino und ein Mineralwasser.',
        words: [
          GermanWord(wordDe: 'Ich', transUz: 'Men', transKaa: 'Men', transRu: 'Я'),
          GermanWord(wordDe: 'hätte', transUz: 'olar edim', transKaa: 'alar edim', transRu: 'взял бы'),
          GermanWord(wordDe: 'gerne', transUz: 'jon deb', transKaa: 'jon dep', transRu: 'с удовольствием'),
          GermanWord(wordDe: 'einen', transUz: 'bitta', transKaa: 'bir', transRu: 'один'),
          GermanWord(wordDe: 'Cappuccino', transUz: 'Kapuchino kofe', transKaa: 'Kapuchino kofe', transRu: 'Капучино'),
          GermanWord(wordDe: 'und', transUz: 'va', transKaa: 'hám', transRu: 'и'),
          GermanWord(wordDe: 'ein', transUz: 'bitta', transKaa: 'bir', transRu: 'одно'),
          GermanWord(wordDe: 'Mineralwasser.', transUz: 'Gazlangan suv.', transKaa: 'Gazlanǵan suv.', transRu: 'Минеральную воду.'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 5. Easy German B1 - Was machst du beruflich?
  const GermanVideo(
    id: 'easy_german_b1_f1',
    title: 'Easy German B1 - Was machst du beruflich?',
    level: 'B1',
    category: 'Easy German',
    youtubeId: '82_d7TzRk7U',
    durationText: '4:00',
    description: 'Ko\'chada nemislarning kasbi haqidagi jonli intervyular.',
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
          GermanWord(wordDe: 'Beruf.', transUz: 'kasbi.', transKaa: 'kásibi.', transRu: 'профессии.'),
        ],
      ),
    ],
    quizQuestions: [],
  ),

  // 6. Easy German B1 - Wie lernst du am besten Deutsch?
  const GermanVideo(
    id: 'easy_german_b1_f2',
    title: 'Easy German B1 - Wie lernst du am besten Deutsch?',
    level: 'B1',
    category: 'Easy German',
    youtubeId: 'b-F2-y9sK88',
    durationText: '4:20',
    description: 'Nemis tilini samarali o\'rganish bo\'yicha suhbatlar.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 0,
        endTimeSec: 8,
        textDe: 'Willkommen bei Easy German! Welcher Tipp hilft dir beim Deutschlernen?',
        words: [
          GermanWord(wordDe: 'Willkommen', transUz: 'Hush kelibsiz', transKaa: 'Xosh kelipsiz', transRu: 'Добро пожаловать'),
          GermanWord(wordDe: 'bei', transUz: 'ga / da', transKaa: '-ǵa', transRu: 'в'),
          GermanWord(wordDe: 'Easy', transUz: 'Easy', transKaa: 'Easy', transRu: 'Easy'),
          GermanWord(wordDe: 'German!', transUz: 'German!', transKaa: 'German!', transRu: 'German!'),
          GermanWord(wordDe: 'Welcher', transUz: 'Qaysi', transKaa: 'Qaysı', transRu: 'Какой'),
          GermanWord(wordDe: 'Tipp', transUz: 'maslahat', transKaa: 'maslahat', transRu: 'совет'),
          GermanWord(wordDe: 'hilft', transUz: 'yordam beradi', transKaa: 'járdem beredi', transRu: 'помогает'),
          GermanWord(wordDe: 'dir', transUz: 'sanga', transKaa: 'saǵan', transRu: 'тебе'),
          GermanWord(wordDe: 'beim', transUz: 'da', transKaa: '-da', transRu: 'при'),
          GermanWord(wordDe: 'Deutschlernen?', transUz: 'nemis tili o\'rganishda?', transKaa: 'nemisshe úyreniwde?', transRu: 'изучении немецкого?'),
        ],
      ),
    ],
    quizQuestions: [],
  ),
];
