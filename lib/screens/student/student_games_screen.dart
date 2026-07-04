import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/page_transitions.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../utils/group_check_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../services/game_stars_service.dart';
import '../../services/haptic_service.dart';
import '../../widgets/bn_tiyin.dart';
import 'games/der_die_das_rules_screen.dart';
import 'games/strange_sentences_rules_screen.dart';
import 'games/story_game_screen.dart';
import 'games/grammar_game_screen.dart';
import 'games/synonym_battle_rules_screen.dart';

class StudentGamesScreen extends StatefulWidget {
  final bool isActive;

  const StudentGamesScreen({super.key, this.isActive = true});

  @override
  State<StudentGamesScreen> createState() => _StudentGamesScreenState();
}

class _StudentGamesScreenState extends State<StudentGamesScreen> {
  int _totalStars = 0;
  bool _loadingStars = true;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStars();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _initialLoading = false);
    });
  }

  @override
  void didUpdateWidget(StudentGamesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadStars();
    }
  }

  Future<void> _loadStars() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final total = await GameStarsService.getTotalStars(uid);
    if (!mounted) return;
    setState(() {
      _totalStars = total;
      _loadingStars = false;
    });
  }

  String _formatStars(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      if (i > 0 && posFromEnd % 3 == 0) buffer.write(' ');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  Future<void> _openDerDieDasGame() async {
    await HapticService.mediumImpact();
    if (!mounted) return;
    final allowed = await GroupCheckHelper.checkAndWarn(context);
    if (!allowed || !mounted) return;
    await Navigator.push(context, SlideTransitionPage(child: const DerDieDasRulesScreen()));
    if (mounted) await _loadStars();
  }

  Future<void> _openStrangeSentencesGame() async {
    await HapticService.mediumImpact();
    if (!mounted) return;
    final allowed = await GroupCheckHelper.checkAndWarn(context);
    if (!allowed || !mounted) return;
    await Navigator.push(context, SlideTransitionPage(child: const StrangeSentencesRulesScreen()));
    if (mounted) await _loadStars();
  }

  Future<void> _openStoryGame() async {
    await HapticService.mediumImpact();
    if (!mounted) return;
    final allowed = await GroupCheckHelper.checkAndWarn(context);
    if (!allowed || !mounted) return;
    await Navigator.push(context, SlideTransitionPage(child: const StoryGameScreen()));
    if (mounted) await _loadStars();
  }

  Future<void> _openGrammarGame() async {
    await HapticService.mediumImpact();
    if (!mounted) return;
    final allowed = await GroupCheckHelper.checkAndWarn(context);
    if (!allowed || !mounted) return;
    await Navigator.push(context, SlideTransitionPage(child: const GrammarGameScreen()));
    if (mounted) await _loadStars();
  }

  Future<void> _openSynonymBattleGame() async {
    await HapticService.mediumImpact();
    if (!mounted) return;
    final allowed = await GroupCheckHelper.checkAndWarn(context);
    if (!allowed || !mounted) return;
    await Navigator.push(context, SlideTransitionPage(child: const SynonymBattleRulesScreen()));
    if (mounted) await _loadStars();
  }

  void _showComingSoonDialog() {
    HapticService.lightImpact();
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.duoOrange.withValues(alpha: isDark ? 0.2 : 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 38,
                  color: AppColors.duoOrange,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.gameComingSoonTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.gameComingSoonMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GamifiedCard(
                  color: AppColors.duoGreen,
                  shadowColor: AppColors.duoGreenShadow,
                  shadowDepth: 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: () {
                    HapticService.lightImpact();
                    Navigator.pop(ctx);
                  },
                  child: Center(
                    child: Text(
                      l.gameComingSoonButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.navGames.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BnTiyin(size: 22),
                const SizedBox(width: 4),
                Text(
                  _loadingStars ? '...' : _formatStars(_totalStars),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _initialLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadStars,
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

                    _buildGameCard(
                      icon: Icons.quiz_rounded,
                      iconColor: AppColors.duoBlue,
                      title: l.gameGrammarTitle,
                      subtitle: l.grammarQuiz,
                      onTap: _openGrammarGame,
                    ),
                    const SizedBox(height: 14),

                    _buildGameCard(
                      icon: Icons.article_rounded,
                      iconColor: AppColors.duoPurple,
                      title: l.gameDerDieDasTitle,
                      subtitle: l.articleSpeedGame,
                      onTap: _openDerDieDasGame,
                    ),
                    const SizedBox(height: 14),

                    _buildGameCard(
                      icon: Icons.theater_comedy_rounded,
                      iconColor: AppColors.duoOrange,
                      title: l.strangeSentencesGame,
                      subtitle: l.strangeSentencesDesc,
                      onTap: _openStrangeSentencesGame,
                    ),
                    const SizedBox(height: 14),

                    _buildGameCard(
                      icon: Icons.auto_stories_rounded,
                      iconColor: AppColors.duoGreen,
                      title: l.germanStoryGame,
                      subtitle: l.germanStoryDesc,
                      onTap: _openStoryGame,
                    ),
                    const SizedBox(height: 14),

                    _buildGameCard(
                      icon: Icons.sync_alt_rounded,
                      iconColor: AppColors.duoRed,
                      title: l.gameSynonymBattleTitle,
                      subtitle: l.synonymBattle,
                      onTap: _openSynonymBattleGame,
                    ),
                    const SizedBox(height: 14),

                    _buildGameCard(
                      icon: Icons.mic_rounded,
                      iconColor: AppColors.duoBlue,
                      title: l.gameVoiceTitle,
                      subtitle: l.pronunciationAndListening,
                      onTap: _showComingSoonDialog,
                      isComingSoon: true,
                    ),
                    const SizedBox(height: 14),

                    _buildGameCard(
                      icon: Icons.sports_kabaddi_rounded,
                      iconColor: AppColors.duoOrange,
                      title: l.gameTranslationBattleTitle,
                      subtitle: l.translationBattle,
                      onTap: _showComingSoonDialog,
                      isComingSoon: true,
                    ),
                    const SizedBox(height: 14),



                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGameCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isComingSoon = false,
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
                    if (isComingSoon) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.duoOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.construction_rounded,
                          size: 16,
                          color: AppColors.duoOrange,
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

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
      child: Column(
        children: List.generate(
          6,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SkeletonLoader(
              width: double.infinity,
              height: 82,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
