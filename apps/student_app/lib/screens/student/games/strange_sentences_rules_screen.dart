import 'package:flutter/material.dart';

import 'package:core/l10n/app_localizations.dart';
import 'package:core/models/strange_sentences_round.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/strange_sentences_rules.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import 'strange_sentences_game_screen.dart';

class StrangeSentencesRulesScreen extends StatefulWidget {
  const StrangeSentencesRulesScreen({super.key});

  @override
  State<StrangeSentencesRulesScreen> createState() =>
      _StrangeSentencesRulesScreenState();
}

class _StrangeSentencesRulesScreenState
    extends State<StrangeSentencesRulesScreen> {
  StrangeDifficulty _selectedDifficulty = StrangeDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
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
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : AppColors.duoTextDark),
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
                  const Icon(Icons.theater_comedy_rounded,
                      size: 40, color: Colors.white),
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
              color: isDark
                  ? AppColors.duoCardGray.withValues(alpha: 0.1)
                  : Colors.white,
              shadowColor:
                  isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
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
            _modeCard(isDark, '🎯', l.strangeSentencesPickHint,
                '3 ta gapdan grammatik to\'g\'ri g\'alati gapni tanlang.'),
            const SizedBox(height: 12),
            _modeCard(isDark, '🔀', l.strangeSentencesOrderHint,
                'Aralashtirilgan so\'zlarni bosib to\'g\'ri tartibda gap tuzing.'),
            const SizedBox(height: 24),
            // ── Daraja tanlash ──
            Text(
              l.grammarGameSelectLevel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildDifficultySelector(isDark, l),
            const SizedBox(height: 28),
            // ── Boshlash tugmasi ──
            GamifiedCard(
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              shadowDepth: 5,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => StrangeSentencesGameScreen(
                    difficulty: _selectedDifficulty,
                  ),
                ),
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

  Widget _buildDifficultySelector(bool isDark, AppLocalizations l) {
    final items = [
      (StrangeDifficulty.easy, l.easy, '10⭐', AppColors.duoGreen),
      (StrangeDifficulty.medium, l.medium, '15⭐', AppColors.duoOrange),
      (StrangeDifficulty.hard, l.hard, '20⭐', AppColors.duoRed),
    ];

    return Row(
      children: items.map((item) {
        final (diff, label, stars, color) = item;
        final selected = _selectedDifficulty == diff;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: diff != StrangeDifficulty.hard ? 10 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = diff),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? color
                        : (isDark ? Colors.white12 : AppColors.duoCardGrayShadow),
                    width: selected ? 2.5 : 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: selected
                            ? color
                            : (isDark ? Colors.white : AppColors.duoTextDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stars,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _modeCard(bool isDark, String emoji, String title, String body) {
    return GamifiedCard(
      color: isDark
          ? AppColors.duoCardGray.withValues(alpha: 0.08)
          : Colors.white,
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
