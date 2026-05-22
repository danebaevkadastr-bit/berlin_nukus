class SchreibenTask {
  final int id;
  final String task;
  final List<String> points;
  final String style;
  final int minWords;

  const SchreibenTask({
    required this.id,
    required this.task,
    required this.points,
    required this.style,
    required this.minWords,
  });
}
