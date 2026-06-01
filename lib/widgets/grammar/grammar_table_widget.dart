import 'package:flutter/material.dart';
import '../../models/grammar_table.dart';
import '../../utils/app_colors.dart';

/// Grammatik jadvalni ko'rsatuvchi widget
///
/// Bu widget grammatika tushuntirishlarida ishlatiladigan jadvallarni
/// (artikl jadvali, tuslanish jadvali va h.k.) ko'rsatish uchun ishlatiladi.
///
/// **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6**
class GrammarTableWidget extends StatelessWidget {
  /// Ko'rsatiladigan jadval ma'lumotlari
  final GrammarTable table;

  /// Daraja rangi (sarlavha va ustun sarlavhalari uchun)
  final Color accentColor;

  /// Qorong'i rejim yoqilganmi
  final bool isDark;

  const GrammarTableWidget({
    super.key,
    required this.table,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jadval sarlavhasi
        _buildTitle(),
        const SizedBox(height: 12),
        // Jadval kontenti (gorizontal scroll bilan)
        _buildTableContent(),
      ],
    );
  }

  /// Jadval sarlavhasini yaratadi
  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 18,
            color: accentColor,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              table.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Jadval kontentini gorizontal scroll bilan yaratadi
  Widget _buildTableContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildTable(),
        ),
      ),
    );
  }

  /// Asosiy jadvalni yaratadi
  Widget _buildTable() {
    // Ustunlar sonini aniqlash
    final headerCount = table.headers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ustun sarlavhalari
        _buildHeaderRow(headerCount),
        // Jadval qatorlari
        ...table.rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return _buildDataRow(row, headerCount, index);
        }),
      ],
    );
  }

  /// Ustun sarlavhalarini yaratadi
  Widget _buildHeaderRow(int headerCount) {
    return Container(
      color: accentColor.withValues(alpha: 0.2),
      child: Row(
        children: table.headers.map((header) {
          return _buildCell(
            text: header,
            isHeader: true,
            minWidth: _calculateCellWidth(headerCount),
          );
        }).toList(),
      ),
    );
  }

  /// Ma'lumot qatorini yaratadi (zebra uslubi bilan)
  Widget _buildDataRow(List<String> row, int headerCount, int rowIndex) {
    // Qator uzunligini headers ga moslash
    final normalizedRow = List<String>.generate(
      headerCount,
      (i) => i < row.length ? row[i] : '',
    );

    // Zebra uslubi: juft qatorlar boshqa rangda
    final isEvenRow = rowIndex % 2 == 0;
    final rowColor = _getRowColor(isEvenRow);

    return Container(
      color: rowColor,
      child: Row(
        children: normalizedRow.map((cell) {
          return _buildCell(
            text: cell,
            isHeader: false,
            minWidth: _calculateCellWidth(headerCount),
          );
        }).toList(),
      ),
    );
  }

  /// Qator rangini aniqlaydi (zebra uslubi)
  Color _getRowColor(bool isEvenRow) {
    if (isDark) {
      return isEvenRow
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.transparent;
    } else {
      return isEvenRow
          ? Colors.black.withValues(alpha: 0.03)
          : Colors.transparent;
    }
  }

  /// Jadval katakchasi yaratadi
  Widget _buildCell({
    required String text,
    required bool isHeader,
    required double minWidth,
  }) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 14 : 15,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader
              ? (isDark ? Colors.white : AppColors.textDark)
              : (isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.textDark),
        ),
      ),
    );
  }

  /// Katakcha kengligini hisoblaydi
  double _calculateCellWidth(int headerCount) {
    // Minimal kenglik - jadval o'qilishi uchun
    const minCellWidth = 100.0;
    // Agar ustunlar kam bo'lsa, kattaroq kenglik
    if (headerCount <= 2) return 150.0;
    if (headerCount <= 4) return 120.0;
    return minCellWidth;
  }
}
