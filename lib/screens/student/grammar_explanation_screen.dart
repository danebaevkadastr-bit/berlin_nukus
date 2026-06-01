import 'package:flutter/material.dart';
import '../../models/grammar_level.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/grammar/theory_widget.dart';
import '../../widgets/grammar/grammar_table_widget.dart';
import '../../widgets/grammar/grammar_example_widget.dart';

/// Batafsil grammatika tushuntirishini ko'rsatuvchi ekran
///
/// Bu ekran grammatika qoidasi uchun nazariy qism, jadvallar va
/// formatlangan misollarni ko'rsatadi.
///
/// **Validates: Requirements 2.2, 2.3, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4**
class GrammarExplanationScreen extends StatelessWidget {
  /// Ko'rsatiladigan grammatika qoidasi
  final GrammarRule rule;

  /// Grammatika darajasi (rang uchun)
  final GrammarLevel level;

  const GrammarExplanationScreen({
    super.key,
    required this.rule,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final levelColor = _getLevelColor(level.level);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          rule.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              // Responsive: katta ekranlarda maksimal kenglikni cheklash (600px)
              constraints: BoxConstraints(
                maxWidth: screenWidth > 600 ? 600 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(isDark, levelColor),
                  const SizedBox(height: 24),
                  // Content - batafsil yoki oddiy ko'rinish
                  if (rule.detailedExplanation != null)
                    _buildDetailedView(isDark, levelColor, screenWidth)
                  else
                    _buildSimpleView(isDark, levelColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header qismini yaratish
  Widget _buildHeader(bool isDark, Color levelColor) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: levelColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 28,
              color: levelColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${level.level} - ${level.title}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: levelColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Grammatika qoidasi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Batafsil ko'rinishni yaratish (detailedExplanation mavjud bo'lganda)
  Widget _buildDetailedView(bool isDark, Color levelColor, double screenWidth) {
    final explanation = rule.detailedExplanation!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nazariy qism
        if (explanation.theoryText.isNotEmpty) ...[
          _buildSectionTitle('Nazariy qism', Icons.menu_book_rounded, isDark, levelColor),
          const SizedBox(height: 12),
          GamifiedCard(
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            padding: const EdgeInsets.all(20),
            child: TheoryWidget(theoryText: explanation.theoryText),
          ),
          const SizedBox(height: 24),
        ],

        // Jadvallar
        if (explanation.tables.isNotEmpty) ...[
          _buildSectionTitle('Jadvallar', Icons.table_chart_outlined, isDark, levelColor),
          const SizedBox(height: 12),
          ...explanation.tables.map((table) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GamifiedCard(
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  padding: const EdgeInsets.all(16),
                  child: GrammarTableWidget(
                    table: table,
                    accentColor: levelColor,
                    isDark: isDark,
                  ),
                ),
              )),
          const SizedBox(height: 8),
        ],

        // Misollar
        if (explanation.examples.isNotEmpty) ...[
          _buildSectionTitle('Misollar', Icons.format_quote_rounded, isDark, levelColor),
          const SizedBox(height: 12),
          GamifiedCard(
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            padding: const EdgeInsets.all(20),
            // Responsive: kichik ekranlarda vertikal joylashish
            child: _buildExamplesSection(explanation, levelColor, isDark, screenWidth),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  /// Misollar bo'limini yaratish (responsive)
  Widget _buildExamplesSection(
    dynamic explanation,
    Color levelColor,
    bool isDark,
    double screenWidth,
  ) {
    // Requirement 8.4: kichik ekranlarda vertikal joylashish
    // GrammarExampleWidget allaqachon vertikal joylashtirilgan
    return GrammarExampleWidget(
      examples: explanation.examples,
      accentColor: levelColor,
      isDark: isDark,
    );
  }

  /// Oddiy ko'rinishni yaratish (detailedExplanation mavjud bo'lmaganda)
  Widget _buildSimpleView(bool isDark, Color levelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tushuntirish
        _buildSectionTitle('Tushuntirish', Icons.info_outline_rounded, isDark, levelColor),
        const SizedBox(height: 12),
        GamifiedCard(
          color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
          padding: const EdgeInsets.all(20),
          child: Text(
            rule.explanation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.duoTextDark,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Misollar (oddiy ro'yxat)
        if (rule.examples.isNotEmpty) ...[
          _buildSectionTitle('Misollar', Icons.format_quote_rounded, isDark, levelColor),
          const SizedBox(height: 12),
          GamifiedCard(
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rule.examples.asMap().entries.map((entry) {
                final index = entry.key;
                final example = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: levelColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          example,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Istisnolar
        if (rule.exceptions != null && rule.exceptions!.isNotEmpty) ...[
          _buildSectionTitle('Istisnolar', Icons.warning_amber_rounded, isDark, AppColors.duoOrange),
          const SizedBox(height: 12),
          GamifiedCard(
            color: isDark 
                ? AppColors.duoOrange.withValues(alpha: 0.1) 
                : AppColors.duoOrange.withValues(alpha: 0.05),
            shadowColor: isDark 
                ? AppColors.duoOrange.withValues(alpha: 0.3) 
                : AppColors.duoOrange.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rule.exceptions!.map((exception) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.duoOrange,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            exception,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.duoTextLight,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  /// Bo'lim sarlavhasini yaratish
  Widget _buildSectionTitle(String title, IconData icon, bool isDark, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
      ],
    );
  }

  /// Daraja rangini aniqlash
  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.duoBlue;
      case 'A2':
        return AppColors.duoGreen;
      case 'B1':
        return AppColors.duoOrange;
      case 'B2':
        return AppColors.duoRed;
      default:
        return AppColors.duoBlue;
    }
  }
}
