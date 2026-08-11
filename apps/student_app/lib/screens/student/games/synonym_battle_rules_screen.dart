import 'package:flutter/material.dart';

import 'package:core/utils/app_colors.dart';
import 'package:core/utils/synonym_data.dart';
import 'package:core/utils/synonym_rules.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import 'synonym_battle_game_screen.dart';

/// Sinonimlar Jangi o'yini qoidalari ekrani.
///
/// Bu ekran o'yin qoidalarini o'zbek tilida ko'rsatadi va
/// foydalanuvchiga o'yinni boshlash imkonini beradi.
/// DerDieDasRulesScreen patterniga mos ravishda yaratilgan.
class SynonymBattleRulesScreen extends StatelessWidget {
  const SynonymBattleRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          SynonymRules.gameTitle.toUpperCase(),
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
        iconTheme:
            IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with emoji and word count
            GamifiedCard(
              color: AppColors.duoPurple,
              shadowColor: AppColors.duoPurpleShadow,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.sync_alt_rounded, size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${SynonymData.totalWords} TA SO\'Z',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sinonimlarni tez topish',
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

            // How to play section
            _sectionTitle(isDark, SynonymRules.howToPlayTitle),
            const SizedBox(height: 10),
            _textCard(isDark, SynonymRules.howToPlayText.trim()),
            const SizedBox(height: 24),

            // Scoring system section
            _sectionTitle(isDark, SynonymRules.scoringTitle),
            const SizedBox(height: 10),
            _textCard(isDark, SynonymRules.scoringText.trim()),
            const SizedBox(height: 24),

            // Time limit info
            _sectionTitle(isDark, 'VAQT CHEGARASI'),
            const SizedBox(height: 10),
            _textCard(
              isDark,
              'Har bir savol uchun ${SynonymRules.secondsPerQuestion} soniya vaqtingiz bor.\n'
                  'Vaqt ${SynonymRules.timerWarningThreshold} soniyadan kam qolsa, taymer qizil rangga o\'zgaradi.',
              icon: '⏱️',
            ),
            const SizedBox(height: 24),

            // Start game button
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<AccentPreset>(
                valueListenable: ThemeManager.accentNotifier,
                builder: (context, accent, _) => GamifiedCard(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: accent.color,
                  shadowColor: accent.shadow,
                  shadowDepth: 5,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SynonymBattleGameScreen(),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      SynonymRules.startButtonText,
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
      color: isDark
          ? AppColors.duoCardGray.withValues(alpha: 0.1)
          : Colors.white,
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
