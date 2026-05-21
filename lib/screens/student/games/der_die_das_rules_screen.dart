import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/der_die_das_rules.dart';
import '../../../utils/game_words.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import 'der_die_das_game_screen.dart';

class DerDieDasRulesScreen extends StatelessWidget {
  const DerDieDasRulesScreen({super.key});

  Color _articleColor(String article) {
    switch (article) {
      case 'der':
        return AppColors.duoBlue;
      case 'die':
        return AppColors.duoRed;
      default:
        return AppColors.duoGreen;
    }
  }

  Color _articleShadow(String article) {
    switch (article) {
      case 'der':
        return AppColors.duoBlueShadow;
      case 'die':
        return AppColors.duoRedShadow;
      default:
        return AppColors.duoGreenShadow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          DerDieDasRules.gameTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GamifiedCard(
              color: AppColors.duoRed,
              shadowColor: AppColors.duoRedShadow,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('📘', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${GameWords.totalWords} TA SO\'Z',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Artiklarni tez tanish',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle(isDark, DerDieDasRules.howToPlayTitle),
            const SizedBox(height: 10),
            _textCard(isDark, DerDieDasRules.howToPlayText.trim()),
            const SizedBox(height: 24),
            _sectionTitle(isDark, 'ARTIKL QOIDALARI'),
            const SizedBox(height: 12),
            ...DerDieDasRules.articleSections.map((section) {
              final color = _articleColor(section.article);
              final shadow = _articleShadow(section.article);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GamifiedCard(
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: shadow, width: 2),
                            ),
                            child: Text(
                              section.article.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(section.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...section.tips.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            _sectionTitle(isDark, 'ESDA SAQLASH UCHUN'),
            const SizedBox(height: 10),
            ...DerDieDasRules.memoryTricks.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _textCard(isDark, tip, icon: '💡'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GamifiedCard(
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: AppColors.duoGreen,
                shadowColor: AppColors.duoGreenShadow,
                shadowDepth: 5,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DerDieDasGameScreen()),
                ),
                child: const Center(
                  child: Text(
                    'O\'YINNI BOSHLASH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(bool isDark, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white : AppColors.duoTextDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _textCard(bool isDark, String text, {String? icon}) {
    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.duoTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
