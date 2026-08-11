import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory GermanWord.fromJson(Map<String, dynamic> json) {
    return GermanWord(
      wordDe: json['wordDe'] as String? ?? '',
      transUz: json['transUz'] as String? ?? '',
      transKaa: json['transKaa'] as String? ?? '',
      transRu: json['transRu'] as String? ?? '',
      exampleDe: json['exampleDe'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordDe': wordDe,
      'transUz': transUz,
      'transKaa': transKaa,
      'transRu': transRu,
      'exampleDe': exampleDe,
    };
  }

  String translationFor(String langCode) {
    if (langCode == 'kaa') return transKaa;
    if (langCode == 'ru') return transRu;
    return transUz;
  }
}

class SubtitleSegment {
  final double startTimeSec;
  final double endTimeSec;
  final String textDe;
  final List<GermanWord> words;

  const SubtitleSegment({
    required this.startTimeSec,
    required this.endTimeSec,
    required this.textDe,
    required this.words,
  });

  factory SubtitleSegment.fromJson(Map<String, dynamic> json) {
    return SubtitleSegment(
      startTimeSec: (json['startTimeSec'] as num?)?.toDouble() ?? 0.0,
      endTimeSec: (json['endTimeSec'] as num?)?.toDouble() ?? 0.0,
      textDe: json['textDe'] as String? ?? '',
      words: (json['words'] as List<dynamic>?)
              ?.map((e) => GermanWord.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTimeSec': startTimeSec,
      'endTimeSec': endTimeSec,
      'textDe': textDe,
      'words': words.map((e) => e.toJson()).toList(),
    };
  }
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

  factory VideoQuizQuestion.fromJson(Map<String, dynamic> json) {
    return VideoQuizQuestion(
      questionText: Map<String, String>.from(json['questionText'] as Map? ?? {}),
      options: (json['options'] as Map?)?.map(
            (key, value) => MapEntry(key as String, List<String>.from(value as List? ?? [])),
          ) ?? {},
      correctAnswerIndex: (json['correctAnswerIndex'] as num?)?.toInt() ?? 0,
      explanation: Map<String, String>.from(json['explanation'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

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

  factory GermanVideo.fromJson(Map<String, dynamic> json, [String? id]) {
    return GermanVideo(
      id: id ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      level: json['level'] as String? ?? '',
      youtubeId: json['youtubeId'] as String? ?? '',
      durationText: json['durationText'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subtitles: (json['subtitles'] as List<dynamic>?)
              ?.map((e) => SubtitleSegment.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      quizQuestions: (json['quizQuestions'] as List<dynamic>?)
              ?.map((e) => VideoQuizQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'level': level,
      'youtubeId': youtubeId,
      'durationText': durationText,
      'description': description,
      'category': category,
      'subtitles': subtitles.map((e) => e.toJson()).toList(),
      'quizQuestions': quizQuestions.map((e) => e.toJson()).toList(),
    };
  }
}
