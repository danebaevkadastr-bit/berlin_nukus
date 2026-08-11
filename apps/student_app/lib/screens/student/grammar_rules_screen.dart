import 'package:flutter/material.dart';
import 'package:core/models/grammar_level.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import 'grammar_explanation_screen.dart';

class GrammarRulesScreen extends StatelessWidget {
  final GrammarLevel level;
  final GrammarCategory category;

  const GrammarRulesScreen({
    super.key,
    required this.level,
    required this.category,
  });

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
          category.name,
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
                        category.icon,
                        style: const TextStyle(fontSize: 28),
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
                            color: _getLevelColor(level.level),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${category.topics.length} mavzu',
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
              ),
              const SizedBox(height: 24),
              // Topics
              ...category.topics.map((topic) => _buildTopicCard(
                    context,
                    topic,
                    level,
                    isDark,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, GrammarTopic topic, GrammarLevel level, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamifiedCard(
        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              topic.description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.duoTextLight,
              ),
            ),
            const SizedBox(height: 16),
            // Rules
            ...topic.rules.map((rule) => _buildRuleCard(context, rule, level, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, GrammarRule rule, GrammarLevel level, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarExplanationScreen(
              rule: rule,
              level: level,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getLevelColor(level.level).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getLevelColor(level.level).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 20,
                color: _getLevelColor(level.level),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rule.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rule.explanation,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.duoTextLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Examples
          if (rule.examples.isNotEmpty) ...[
            Text(
              'Misol:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _getLevelColor(level.level),
              ),
            ),
            const SizedBox(height: 8),
            ...rule.examples.map((example) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getLevelColor(level.level),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          example,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          // Exceptions
          if (rule.exceptions != null && rule.exceptions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.duoOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.duoOrange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.duoOrange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Istisnolar:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.duoOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...rule.exceptions!.map((exception) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.duoOrange,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                exception,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
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
