import 'package:flutter/material.dart';
import 'package:core/models/grammar_level.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import 'grammar_rules_screen.dart';

class GrammarTopicsScreen extends StatelessWidget {
  final GrammarLevel level;

  const GrammarTopicsScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

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
          '${level.level} - ${level.title}',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getLevelColor(level.level).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        level.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Categories
              ...level.categories.map((category) => _buildCategoryCard(
                    context,
                    category,
                    level,
                    isDark,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    GrammarCategory category,
    GrammarLevel level,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamifiedCard(
        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
        padding: const EdgeInsets.all(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GrammarRulesScreen(
                level: level,
                category: category,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getLevelColor(level.level).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.topics.length} mavzu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.duoTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Topics preview
            ...category.topics.take(3).map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getLevelColor(level.level),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          topic.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
            if (category.topics.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${category.topics.length - 3} ko\'proq',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getLevelColor(level.level),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.duoGreen;
      case 'A2':
        return AppColors.duoBlue;
      case 'B1':
        return AppColors.duoOrange;
      case 'B2':
        return AppColors.duoRed;
      default:
        return AppColors.duoGreen;
    }
  }
}
