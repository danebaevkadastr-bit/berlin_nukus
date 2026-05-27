import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../utils/group_check_helper.dart';
import '../../l10n/app_localizations.dart';
import 'conversations_screen.dart';
import 'schreiben_screen.dart';
import 'translation_screen.dart';
import 'games/der_die_das_rules_screen.dart';
import 'grammar_levels_screen.dart';
import 'mock_test_screen.dart';

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
              icon: '🤖',
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
              icon: '📘',
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
              icon: '✍️',
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
              icon: '👂',
              title: 'Hören',
              subtitle: l.listeningExercises,
            ),
            const SizedBox(height: 14),

            _buildLearningCard(
              context,
              icon: '📖',
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
              icon: '📚',
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
              icon: '📝',
              title: 'Mock Test',
              subtitle: 'A1–B2 darajalarida bilimni sinash',
              badge: '🆕',
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
    required String icon,
    required String title,
    required String subtitle,
    String? badge,
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
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.duoGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(fontSize: 12),
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
          Text(icon, style: const TextStyle(fontSize: 40)),
        ],
      ),
    );
  }
}