import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/strange_sentences_rules.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import 'strange_sentences_game_screen.dart';

class StrangeSentencesRulesScreen extends StatelessWidget {
  const StrangeSentencesRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          l.strangeSentencesGame.toUpperCase(),
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
              color: AppColors.candyPink,
              shadowColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('🎭', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI + ${StrangeSentencesRules.roundsPerSession} RAUND',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.strangeSentencesDesc,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.strangeSentencesRulesHowTo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
            const SizedBox(height: 10),
            GamifiedCard(
              color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
              shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              padding: const EdgeInsets.all(18),
              child: Text(
                StrangeSentencesRules.howToPlayText.trim(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _modeCard(
              isDark,
              '🎯',
              l.strangeSentencesPickHint,
              '3 ta gapdan grammatik to\'g\'ri g\'alati gapni tanlang.',
            ),
            const SizedBox(height: 12),
            _modeCard(
              isDark,
              '🔀',
              l.strangeSentencesOrderHint,
              'Aralashtirilgan so\'zlarni bosib to\'g\'ri tartibda gap tuzing.',
            ),
            const SizedBox(height: 28),
            GamifiedCard(
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              shadowDepth: 5,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StrangeSentencesGameScreen()),
              ),
              child: Center(
                child: Text(
                  l.strangeSentencesStart.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeCard(bool isDark, String emoji, String title, String body) {
    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.08) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: isDark ? Colors.white60 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
