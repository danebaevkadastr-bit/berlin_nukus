import 'grammar_table.dart';
import 'grammar_example.dart';

/// Batafsil grammatika tushuntirishini ifodalovchi model
///
/// Bu model har bir grammatika qoidasi uchun nazariy tushuntirish,
/// jadvallar va formatlangan misollarni saqlash uchun ishlatiladi.
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 2.4**
class GrammarExplanation {
  /// Nazariy tushuntirish matni (paragraflar, ro'yxatlar qo'llab-quvvatlanadi)
  final String theoryText;

  /// Grammatik jadvallar ro'yxati (artikl jadvali, tuslanish jadvali va h.k.)
  final List<GrammarTable> tables;

  /// Formatlangan misollar ro'yxati (nemischa-o'zbekcha)
  final List<GrammarExample> examples;

  const GrammarExplanation({
    required this.theoryText,
    this.tables = const [],
    this.examples = const [],
  });

  /// JSON dan GrammarExplanation obyektini yaratadi
  factory GrammarExplanation.fromJson(Map<String, dynamic> json) {
    return GrammarExplanation(
      theoryText: json['theoryText'] as String? ?? '',
      tables: (json['tables'] as List<dynamic>?)
              ?.map((e) => GrammarTable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// GrammarExplanation obyektini JSON ga aylantiradi
  Map<String, dynamic> toJson() {
    return {
      'theoryText': theoryText,
      'tables': tables.map((t) => t.toJson()).toList(),
      'examples': examples.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GrammarExplanation) return false;

    // theoryText tekshirish
    if (theoryText != other.theoryText) return false;

    // tables tekshirish
    if (tables.length != other.tables.length) return false;
    for (int i = 0; i < tables.length; i++) {
      if (tables[i] != other.tables[i]) return false;
    }

    // examples tekshirish
    if (examples.length != other.examples.length) return false;
    for (int i = 0; i < examples.length; i++) {
      if (examples[i] != other.examples[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      theoryText,
      Object.hashAll(tables),
      Object.hashAll(examples),
    );
  }

  @override
  String toString() {
    return 'GrammarExplanation(theoryText: $theoryText, tables: $tables, examples: $examples)';
  }
}
