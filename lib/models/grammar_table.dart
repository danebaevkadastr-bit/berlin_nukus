/// Grammatik jadvalni ifodalovchi model
/// 
/// Bu model grammatika tushuntirishlarida ishlatiladigan jadvallarni
/// (artikl jadvali, tuslanish jadvali va h.k.) saqlash uchun ishlatiladi.
/// 
/// **Validates: Requirements 1.4, 1.5, 1.6, 2.4**
class GrammarTable {
  /// Jadval sarlavhasi
  final String title;

  /// Ustun nomlari
  final List<String> headers;

  /// Jadval qatorlari (har bir qator - ustunlar ro'yxati)
  final List<List<String>> rows;

  const GrammarTable({
    required this.title,
    required this.headers,
    required this.rows,
  });

  /// JSON dan GrammarTable obyektini yaratadi
  factory GrammarTable.fromJson(Map<String, dynamic> json) {
    return GrammarTable(
      title: json['title'] as String? ?? '',
      headers: (json['headers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rows: (json['rows'] as List<dynamic>?)
              ?.map((row) =>
                  (row as List<dynamic>).map((cell) => cell as String).toList())
              .toList() ??
          [],
    );
  }

  /// GrammarTable obyektini JSON ga aylantiradi
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'headers': headers,
      'rows': rows,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GrammarTable) return false;

    // Title tekshirish
    if (title != other.title) return false;

    // Headers tekshirish
    if (headers.length != other.headers.length) return false;
    for (int i = 0; i < headers.length; i++) {
      if (headers[i] != other.headers[i]) return false;
    }

    // Rows tekshirish
    if (rows.length != other.rows.length) return false;
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].length != other.rows[i].length) return false;
      for (int j = 0; j < rows[i].length; j++) {
        if (rows[i][j] != other.rows[i][j]) return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      Object.hashAll(headers),
      Object.hashAll(rows.map((row) => Object.hashAll(row))),
    );
  }

  @override
  String toString() {
    return 'GrammarTable(title: $title, headers: $headers, rows: $rows)';
  }
}
