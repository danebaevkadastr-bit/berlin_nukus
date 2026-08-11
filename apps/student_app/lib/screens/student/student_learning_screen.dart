import 'package:flutter/material.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/utils/group_check_helper.dart';
import 'package:core/l10n/app_localizations.dart';
import 'conversations_screen.dart';
import 'schreiben_screen.dart';
import 'translation_screen.dart';
import 'vocabulary_screen.dart';
import 'games/der_die_das_rules_screen.dart';
import 'grammar_levels_screen.dart';
import 'mock_test_screen.dart';
import 'horen/horen_screen.dart';
import 'lesen/lesen_screen.dart';
import 'sprechen/sprechen_screen.dart';
import 'video_learning/video_catalog_screen.dart';

class StudentLearningScreen extends StatelessWidget {
  const StudentLearningScreen({super.key});

  Future<void> _openWithGroupCheck(
    BuildContext context,
    Widget Function() builder,
  ) async {
    final allowed = await GroupCheckHelper.checkAndWarn(context);
    if (!allowed) return;
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => builder()),
      );
    }
  }

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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
          physics: const AlwaysScrollableScrollPhysics(),
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
              icon: Icons.smart_toy_rounded,
              iconColor: AppColors.duoPurple,
              title: 'Sprechen AI',
              subtitle: l.speakWithAi,
              onTap: () => _openWithGroupCheck(
                context,
                () => const ConversationsScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.ondemand_video_rounded,
              iconColor: AppColors.duoRed,
              title: 'Video-Darslar',
              subtitle: 'Nicos Weg, Easy German & Subtitrli videolar',
              onTap: () => _openWithGroupCheck(
                context,
                () => const VideoCatalogScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.article_rounded,
              iconColor: AppColors.duoBlue,
              title: 'Der, Die, Das',
              subtitle: l.learnArticles,
              onTap: () => _openWithGroupCheck(
                context,
                () => const DerDieDasRulesScreen(
                  mode: DerDieDasRulesMode.learning,
                ),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.edit_rounded,
              iconColor: AppColors.duoOrange,
              title: 'Schreiben',
              subtitle: l.writingExercises,
              onTap: () => _openWithGroupCheck(
                context,
                () => const SchreibenScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.headphones_rounded,
              iconColor: AppColors.duoGreen,
              title: 'Hören',
              subtitle: l.listeningExercises,
              onTap: () => _openWithGroupCheck(
                context,
                () => const HorenScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.menu_book_rounded,
              iconColor: AppColors.duoRed,
              title: 'Lesen',
              subtitle: l.readingExercises,
              onTap: () => _openWithGroupCheck(
                context,
                () => const LesenScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.record_voice_over_rounded,
              iconColor: AppColors.duoBlue,
              title: 'Sprechen',
              subtitle: l.sprechenExercises,
              onTap: () => _openWithGroupCheck(
                context,
                () => const SprechenScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.translate_rounded,
              iconColor: AppColors.duoGreen,
              title: l.translation,
              subtitle: l.vocabAndTranslation,
              onTap: () => _openWithGroupCheck(
                context,
                () => const TranslationScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.style_rounded,
              iconColor: AppColors.duoPurple,
              title: l.vocabulary,
              subtitle: l.savedVocabulary,
              onTap: () => _openWithGroupCheck(
                context,
                () => const VocabularyScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.school_rounded,
              iconColor: AppColors.duoOrange,
              title: 'Grammatika',
              subtitle: 'A1, A2, B1, B2 darajalari',
              onTap: () => _openWithGroupCheck(
                context,
                () => const GrammarLevelsScreen(),
              ),
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: Icons.fact_check_rounded,
              iconColor: AppColors.duoRed,
              title: 'Mock Test',
              subtitle: 'A1–B2 darajalarida bilimni sinash',
              showNewBadge: true,
              onTap: () => _openWithGroupCheck(
                context,
                () => const MockTestScreen(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLearningCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool showNewBadge = false,
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          height: 1.15,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                    ),
                    if (showNewBadge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ThemeManager.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fiber_new_rounded,
                          size: 16,
                          color: ThemeManager.accent,
                        ),
                      ),
                    ],
                  ],
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
        ],
      ),
    );
  }
}