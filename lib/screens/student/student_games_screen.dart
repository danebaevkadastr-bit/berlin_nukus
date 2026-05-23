import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/game_stars_service.dart';
import 'games/der_die_das_rules_screen.dart';
import 'games/strange_sentences_rules_screen.dart';
import 'games/story_game_screen.dart';

class StudentGamesScreen extends StatefulWidget {
  final bool isActive;

  const StudentGamesScreen({super.key, this.isActive = true});

  @override
  State<StudentGamesScreen> createState() => _StudentGamesScreenState();
}

class _StudentGamesScreenState extends State<StudentGamesScreen> {
  int _totalStars = 0;
  bool _loadingStars = true;

  @override
  void initState() {
    super.initState();
    _loadStars();
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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DerDieDasRulesScreen()),
    );
    await _loadStars();
  }

  Future<void> _openStrangeSentencesGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StrangeSentencesRulesScreen()),
    );
    await _loadStars();
  }

  Future<void> _openStoryGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StoryGameScreen()),
    );
    await _loadStars();
  }

  void _showComingSoonDialog() {
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
              const Text('🚧', style: TextStyle(fontSize: 48)),
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
                  onTap: () => Navigator.pop(ctx),
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
                const Text('⭐', style: TextStyle(fontSize: 20)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
        child: Column(
          children: [
            _buildGameCard(
              context,
              icon: '🔄',
              title: l.gameSynonymBattleTitle,
              subtitle: l.synonymBattle,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 14),

            _buildGameCard(
              context,
              icon: '📝',
              title: l.gameGrammarTitle,
              subtitle: l.grammarQuiz,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 14),

            _buildGameCard(
              context,
              icon: '📘',
              title: l.gameDerDieDasTitle,
              subtitle: l.articleSpeedGame,
              onTap: _openDerDieDasGame,
            ),
            const SizedBox(height: 14),

            _buildGameCard(
              context,
              icon: '🎤',
              title: l.gameVoiceTitle,
              subtitle: l.pronunciationAndListening,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 14),

            _buildGameCard(
              context,
              icon: '⚔️',
              title: l.gameTranslationBattleTitle,
              subtitle: l.translationBattle,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 14),

            _buildGameCard(
              context,
              icon: '🎭',
              title: l.strangeSentencesGame,
              subtitle: l.strangeSentencesDesc,
              onTap: _openStrangeSentencesGame,
            ),
            const SizedBox(height: 14),

            _buildGameCard(
              context,
              icon: '📖',
              title: l.germanStoryGame,
              subtitle: l.germanStoryDesc,
              onTap: _openStoryGame,
            ),
            const SizedBox(height: 14),

            _buildGameCard(
              context,
              icon: '🖼️',
              title: l.describePictureGame,
              subtitle: l.describePictureDesc,
              onTap: _showComingSoonDialog,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
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
