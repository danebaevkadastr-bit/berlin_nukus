import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';
import '../../l10n/app_localizations.dart';
import 'mock_test/mock_test_intro_screen.dart';
import 'mock_test/model/mock_test_structure.dart';
import 'mock_test/model/mock_test_timing.dart';

class MockTestScreen extends StatelessWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, accent, _) {
        return _MockTestBody(isDark: isDark, accent: accent);
      },
    );
  }
}

class _MockTestBody extends StatelessWidget {
  final bool isDark;
  final AccentPreset accent;

  const _MockTestBody({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          'MOCK TEST',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner — accent rang
            GamifiedCard(
              color: accent.color,
              shadowColor: accent.shadow,
              shadowDepth: 6,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.fact_check_rounded,
                      size: 48, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MOCK TEST',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.mockLandingSubtitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _sectionTitle(l.selectLevel.toUpperCase()),
            const SizedBox(height: 14),

            _buildLevelCard(
              context,
              level: 'A1',
              title: l.levelBeginner,
              description: l.mockLevelDescA1,
              levelIcon: Icons.spa_rounded,
              color: AppColors.duoGreen,
              shadow: AppColors.duoGreenShadow,
              questionCount: 30,
              duration: l.minutesShort(20),
            ),
            const SizedBox(height: 14),

            _buildLevelCard(
              context,
              level: 'A2',
              title: l.levelElementary,
              description: l.mockLevelDescA2,
              levelIcon: Icons.grass_rounded,
              color: AppColors.duoBlue,
              shadow: AppColors.duoBlueShadow,
              questionCount: 40,
              duration: l.minutesShort(25),
            ),
            const SizedBox(height: 14),

            _buildLevelCard(
              context,
              level: 'B1',
              title: l.levelIntermediate,
              description: l.mockLevelDescB1,
              levelIcon: Icons.park_rounded,
              color: AppColors.duoOrange,
              shadow: AppColors.duoOrangeShadow,
              questionCount: MockTestStructure.totalQuestionCount,
              duration: l.minutesShort(MockTestTiming.totalDuration.inMinutes),
              isAvailable: true,
            ),
            const SizedBox(height: 14),

            _buildLevelCard(
              context,
              level: 'B2',
              title: l.levelUpperIntermediate,
              description: l.mockLevelDescB2,
              levelIcon: Icons.terrain_rounded,
              color: AppColors.duoRed,
              shadow: AppColors.duoRedShadow,
              questionCount: 60,
              duration: l.minutesShort(45),
            ),

            const SizedBox(height: 32),

            _sectionTitle(l.mockHowItWorks.toUpperCase()),
            const SizedBox(height: 14),

            _buildInfoCard(1, l.selectLevel, l.mockStep1Desc),
            const SizedBox(height: 10),
            _buildInfoCard(2, l.mockStep2Title, l.mockStep2Desc),
            const SizedBox(height: 10),
            _buildInfoCard(3, l.mockStep3Title, l.mockStep3Desc),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white : AppColors.duoTextDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required String level,
    required String title,
    required String description,
    required IconData levelIcon,
    required Color color,
    required Color shadow,
    required int questionCount,
    required String duration,
    bool isAvailable = false,
  }) {
    final l = AppLocalizations.of(context);
    return GamifiedCard(
      color: isDark
          ? AppColors.duoCardGray.withValues(alpha: 0.1)
          : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(18),
      onTap: () => isAvailable
          ? _openMockTest(context)
          : _showComingSoon(context),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: shadow, width: 2),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                level,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(levelIcon, size: 18, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppColors.duoTextLight,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildChip(
                      Icons.help_outline_rounded,
                      l.mockQuestionsLabel(questionCount),
                      color.withValues(alpha: 0.15),
                      color,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      Icons.schedule_rounded,
                      duration,
                      color.withValues(alpha: 0.15),
                      color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isAvailable ? Icons.arrow_forward_ios_rounded : Icons.lock_rounded,
            color: isAvailable
                ? color
                : (isDark ? Colors.white30 : AppColors.duoTextLight),
            size: isAvailable ? 18 : 20,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(int step, String title, String subtitle) {
    return GamifiedCard(
      color: isDark
          ? AppColors.duoCardGray.withValues(alpha: 0.1)
          : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: accent.color,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  void _openMockTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MockTestIntroScreen()),
    );
  }

  void _showComingSoon(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF1E2A32) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded,
                  size: 52, color: AppColors.duoOrange),
              const SizedBox(height: 16),
              Text(
                l.mockComingSoonTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l.mockComingSoonDialogMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GamifiedCard(
                  color: accent.color,
                  shadowColor: accent.shadow,
                  shadowDepth: 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: () => Navigator.pop(ctx),
                  child: Center(
                    child: Text(
                      l.understood,
                      style: const TextStyle(
                        fontSize: 15,
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
      ),
    );
  }
}
