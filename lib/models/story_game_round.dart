class StoryWord {
  final String word;
  final String type; // 'verb' or 'noun'
  final String? article; // der/die/das for nouns

  StoryWord({
    required this.word,
    required this.type,
    this.article,
  });

  factory StoryWord.fromJson(Map<String, dynamic> json) {
    return StoryWord(
      word: json['word'] ?? '',
      type: json['type'] ?? 'noun',
      article: json['article'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'type': type,
      if (article != null) 'article': article,
    };
  }
}

class StoryGameRound {
  final List<StoryWord> words;
  final int minWords;
  final int maxWords;
  final String? theme;

  StoryGameRound({
    required this.words,
    this.minWords = 30,
    this.maxWords = 40,
    this.theme,
  });

  factory StoryGameRound.fromJson(Map<String, dynamic> json) {
    final wordsList = json['words'] as List<dynamic>?;
    final words = wordsList
            ?.map((e) => StoryWord.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return StoryGameRound(
      words: words,
      minWords: json['minWords'] ?? 30,
      maxWords: json['maxWords'] ?? 40,
      theme: json['theme'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'words': words.map((w) => w.toJson()).toList(),
      'minWords': minWords,
      'maxWords': maxWords,
      if (theme != null) 'theme': theme,
    };
  }
}

class StoryEvaluation {
  final bool passed;
  final int wordCount;
  final String feedbackUz;
  final int score;

  StoryEvaluation({
    required this.passed,
    required this.wordCount,
    required this.feedbackUz,
    required this.score,
  });

  factory StoryEvaluation.fromJson(Map<String, dynamic> json) {
    return StoryEvaluation(
      passed: json['passed'] ?? false,
      wordCount: json['wordCount'] ?? 0,
      feedbackUz: json['feedbackUz'] ?? '',
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passed': passed,
      'wordCount': wordCount,
      'feedbackUz': feedbackUz,
      'score': score,
    };
  }
}
