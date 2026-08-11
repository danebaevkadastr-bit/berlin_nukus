import 'package:flutter/material.dart';

import 'package:core/utils/app_colors.dart';
import 'package:core/utils/der_die_das_rules.dart';
import 'package:core/utils/game_words.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import '../der_die_das_learning_screen.dart';
import 'der_die_das_game_screen.dart';

enum DerDieDasRulesMode { game, learning }

class DerDieDasRulesScreen extends StatefulWidget {
  final DerDieDasRulesMode mode;

  const DerDieDasRulesScreen({
    super.key,
    this.mode = DerDieDasRulesMode.game,
  });

  @override
  State<DerDieDasRulesScreen> createState() => _DerDieDasRulesScreenState();
}

class _DerDieDasRulesScreenState extends State<DerDieDasRulesScreen> {
  String _selectedLevel = 'A1';

  DerDieDasRulesMode get mode => widget.mode;

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
                  const Icon(Icons.article_rounded, size: 40, color: Colors.white),
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
            // Daraja tanlash (faqat game mode)
            if (mode == DerDieDasRulesMode.game) ...[
              _sectionTitle(isDark, 'DARAJA TANLANG'),
              const SizedBox(height: 10),
              Row(children: ['A1', 'A2', 'B1', 'B2'].map((lvl) {
                final selected = _selectedLevel == lvl;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: lvl != 'B2' ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLevel = lvl),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.duoBlue.withValues(alpha: 0.15)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.duoBlue : (isDark ? Colors.white12 : AppColors.duoCardGrayShadow),
                            width: selected ? 2.5 : 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          lvl,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: selected ? AppColors.duoBlue : (isDark ? Colors.white : AppColors.duoTextDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<AccentPreset>(
                valueListenable: ThemeManager.accentNotifier,
                builder: (context, accent, _) => GamifiedCard(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: accent.color,
                  shadowColor: accent.shadow,
                  shadowDepth: 5,
                  onTap: () {
                    if (mode == DerDieDasRulesMode.learning) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DerDieDasLearningScreen()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DerDieDasGameScreen(level: _selectedLevel)),
                      );
                    }
                  },
                  child: Center(
                    child: Text(
                      mode == DerDieDasRulesMode.learning
                          ? 'O\'RGANISHNI BOSHLASH'
                          : 'O\'YINNI BOSHLASH',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
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
