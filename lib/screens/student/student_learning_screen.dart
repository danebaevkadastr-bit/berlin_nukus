import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import 'conversations_screen.dart';
import 'schreiben_screen.dart';
import 'translation_screen.dart';
import 'der_die_das_learning_screen.dart';

class StudentLearningScreen extends StatelessWidget {
  const StudentLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.navLearning.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Text(
              l.categories.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            _buildLearningCard(
              context,
              icon: '🤖',
              title: 'Sprechen AI',
              subtitle: l.speakWithAi,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConversationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: '📘',
              title: 'Der, Die, Das',
              subtitle: l.learnArticles,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DerDieDasLearningScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: '✍️',
              title: 'Schreiben',
              subtitle: l.writingExercises,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SchreibenScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: '👂',
              title: 'Hören',
              subtitle: l.listeningExercises,
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: '📖',
              title: 'Tarjima',
              subtitle: l.vocabAndTranslation,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TranslationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final isDark = ThemeManager.isDark;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    height: 1.15,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(icon, style: const TextStyle(fontSize: 40)),
        ],
      ),
    );
  }
}