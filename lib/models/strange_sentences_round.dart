enum StrangeRoundType { pick, order }

enum StrangeDifficulty { easy, medium, hard }

class StrangeSentencesRound {
  final StrangeRoundType type;
  final StrangeDifficulty difficulty;
  final String correctSentence;
  final List<String> pickOptions;
  final List<String> shuffledWords;
  final String explanationUz;

  const StrangeSentencesRound({
    required this.type,
    required this.difficulty,
    required this.correctSentence,
    this.pickOptions = const [],
    this.shuffledWords = const [],
    this.explanationUz = '',
  });

  List<String> get orderTokens =>
      correctSentence.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  factory StrangeSentencesRound.fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] ?? 'pick').toString().toLowerCase();
    final type = typeRaw == 'order' ? StrangeRoundType.order : StrangeRoundType.pick;
    final correct = (json['correctSentence'] ?? '').toString().trim();
    final difficultyRaw = (json['difficulty'] ?? 'medium').toString().toLowerCase();
    final difficulty = difficultyRaw == 'easy'
        ? StrangeDifficulty.easy
        : difficultyRaw == 'hard'
            ? StrangeDifficulty.hard
            : StrangeDifficulty.medium;

    List<String> options = [];
    if (json['options'] is List) {
      options = (json['options'] as List).map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }

    List<String> shuffled = [];
    if (json['shuffledWords'] is List) {
      shuffled = (json['shuffledWords'] as List).map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    } else if (type == StrangeRoundType.order && correct.isNotEmpty) {
      shuffled = List<String>.from(correct.split(RegExp(r'\s+')).where((w) => w.isNotEmpty));
      shuffled.shuffle();
    }

    if (type == StrangeRoundType.pick && options.length >= 3) {
      options = options.take(3).toList();
      if (!options.contains(correct)) {
        options[0] = correct;
      }
      options.shuffle();
    }

    return StrangeSentencesRound(
      type: type,
      difficulty: difficulty,
      correctSentence: correct,
      pickOptions: options,
      shuffledWords: shuffled,
      explanationUz: (json['explanationUz'] ?? '').toString(),
    );
  }

  bool get isValid {
    if (correctSentence.isEmpty) return false;
    if (type == StrangeRoundType.pick) {
      return pickOptions.length == 3 && pickOptions.contains(correctSentence);
    }
    final tokens = orderTokens;
    if (tokens.isEmpty || shuffledWords.length != tokens.length) return false;
    final a = List<String>.from(shuffledWords)..sort();
    final b = List<String>.from(tokens)..sort();
    return _listEquals(a, b);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
