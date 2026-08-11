enum GrammarRoundType {
  article, // Der/Die/Das tanlash
  verb, // Fe'l shaklini tanlash
  preposition, // Präposition tanlash
  fillBlank, // Gapni to'ldirish
}

class GrammarGameRound {
  final GrammarRoundType type;
  final String question; // Savol (nemischa)
  final String questionUz; // Savol (o'zbekcha)
  final List<String> options; // Variantlar (3-4 ta)
  final String correctAnswer; // To'g'ri javob
  final String explanationUz; // O'zbekcha izoh

  GrammarGameRound({
    required this.type,
    required this.question,
    required this.questionUz,
    required this.options,
    required this.correctAnswer,
    required this.explanationUz,
  });

  factory GrammarGameRound.fromJson(Map<String, dynamic> json) {
    return GrammarGameRound(
      type: GrammarRoundType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GrammarRoundType.article,
      ),
      question: json['question'] as String? ?? '',
      questionUz: json['questionUz'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanationUz: json['explanationUz'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'question': question,
      'questionUz': questionUz,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanationUz': explanationUz,
    };
  }

  bool get isValid {
    return question.isNotEmpty &&
        questionUz.isNotEmpty &&
        options.length >= 3 &&
        correctAnswer.isNotEmpty &&
        explanationUz.isNotEmpty &&
        options.contains(correctAnswer);
  }
}
