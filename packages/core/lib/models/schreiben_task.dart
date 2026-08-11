class SchreibenTask {
  final int id;
  final String task;
  final List<String> points;
  final String style;
  final int minWords;

  /// Daraja: 'A2' yoki 'B1'
  final String level;

  /// B1 vazifalarida javob yoziladigan kirish xati (Brief). A2 da bo'sh.
  final String? letter;

  const SchreibenTask({
    required this.id,
    required this.task,
    required this.points,
    required this.style,
    required this.minWords,
    this.level = 'A2',
    this.letter,
  });
}
