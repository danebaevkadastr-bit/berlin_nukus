/// Formatlangan misolni ifodalovchi model
/// 
/// Har bir misol nemischa jumla, o'zbekcha tarjima va ixtiyoriy
/// grammatik izohdan iborat.
class GrammarExample {
  /// Nemischa jumla
  final String german;

  /// O'zbekcha tarjima
  final String uzbek;

  /// Ixtiyoriy grammatik izoh
  final String? note;

  const GrammarExample({
    required this.german,
    required this.uzbek,
    this.note,
  });

  /// JSON dan GrammarExample obyektini yaratish
  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      german: json['german'] as String,
      uzbek: json['uzbek'] as String,
      note: json['note'] as String?,
    );
  }

  /// GrammarExample obyektini JSON ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'german': german,
      'uzbek': uzbek,
      if (note != null) 'note': note,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrammarExample &&
        other.german == german &&
        other.uzbek == uzbek &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hash(german, uzbek, note);

  @override
  String toString() {
    return 'GrammarExample(german: $german, uzbek: $uzbek, note: $note)';
  }
}
