import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';

/// Nazariy qismni formatlangan matn sifatida ko'rsatuvchi widget
/// 
/// Qo'llab-quvvatlanadigan formatlar:
/// - Paragraflar (\n\n bilan ajratilgan)
/// - Ro'yxatlar (• yoki - bilan boshlanuvchi qatorlar)
/// - Ta'kidlangan matn (**bold** yoki *italic*)
class TheoryWidget extends StatelessWidget {
  /// Nazariy tushuntirish matni
  final String theoryText;

  const TheoryWidget({
    super.key,
    required this.theoryText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    
    if (theoryText.trim().isEmpty) {
      return _buildEmptyState(isDark);
    }

    final paragraphs = _parseParagraphs(theoryText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildParagraph(paragraph, isDark),
        );
      }).toList(),
    );
  }

  /// Bo'sh holat uchun widget
  Widget _buildEmptyState(bool isDark) {
    return Text(
      'Nazariy qism mavjud emas',
      style: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: isDark ? AppColors.duoTextLight : AppColors.duoTextDark,
      ),
    );
  }

  /// Matnni paragraflarga ajratish
  List<String> _parseParagraphs(String text) {
    return text
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// Paragrafni build qilish
  Widget _buildParagraph(String paragraph, bool isDark) {
    // Ro'yxat elementlarini tekshirish
    final lines = paragraph.split('\n');
    
    // Agar barcha qatorlar ro'yxat elementi bo'lsa
    if (_isListParagraph(lines)) {
      return _buildList(lines, isDark);
    }

    // Oddiy paragraf - formatlangan matn bilan
    return _buildFormattedText(paragraph, isDark);
  }

  /// Paragraf ro'yxatmi yoki yo'qligini tekshirish
  bool _isListParagraph(List<String> lines) {
    if (lines.isEmpty) return false;
    
    // Kamida bitta ro'yxat elementi bo'lishi kerak
    return lines.any((line) => _isListItem(line.trim()));
  }

  /// Qator ro'yxat elementimi
  bool _isListItem(String line) {
    return line.startsWith('• ') || line.startsWith('- ');
  }

  /// Ro'yxatni build qilish
  Widget _buildList(List<String> lines, bool isDark) {
    final widgets = <Widget>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      if (_isListItem(trimmedLine)) {
        // Ro'yxat elementi
        final content = trimmedLine.substring(2); // "• " yoki "- " ni olib tashlash
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                    color: ThemeManager.accent,
                  ),
                ),
                Expanded(
                  child: _buildFormattedText(content, isDark),
                ),
              ],
            ),
          ),
        );
      } else {
        // Oddiy matn (ro'yxat ichida)
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildFormattedText(trimmedLine, isDark),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Formatlangan matnni build qilish (**bold** va *italic* qo'llab-quvvatlash)
  Widget _buildFormattedText(String text, bool isDark) {
    final spans = _parseFormattedText(text, isDark);
    
    return RichText(
      text: TextSpan(
        style: _baseTextStyle(isDark),
        children: spans,
      ),
    );
  }

  /// Asosiy matn uslubi
  TextStyle _baseTextStyle(bool isDark) {
    return TextStyle(
      fontSize: 16,
      height: 1.6, // O'qish uchun qulay qator oralig'i
      color: isDark ? Colors.white : AppColors.duoTextDark,
    );
  }

  /// Formatlangan matnni parse qilish
  List<TextSpan> _parseFormattedText(String text, bool isDark) {
    final spans = <TextSpan>[];
    
    // Regex pattern: **bold** yoki *italic*
    // Bold: **...**
    // Italic: *...* (lekin ** emas)
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*([^*]+?)\*');
    
    int lastEnd = 0;
    
    for (final match in pattern.allMatches(text)) {
      // Match dan oldingi oddiy matn
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
        ));
      }
      
      // Bold matn (**...**)
      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ));
      }
      // Italic matn (*...*)
      else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: isDark 
                ? const Color(0xFFB0BEC5) 
                : AppColors.duoTextDark.withValues(alpha: 0.85),
          ),
        ));
      }
      
      lastEnd = match.end;
    }
    
    // Qolgan matn
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
      ));
    }
    
    // Agar hech qanday formatlash topilmasa
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }
    
    return spans;
  }
}
