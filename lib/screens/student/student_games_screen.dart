import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/game_stars_service.dart';
import 'games/der_die_das_rules_screen.dart';

class StudentGamesScreen extends StatefulWidget {
  final bool isActive;

  const StudentGamesScreen({super.key, this.isActive = true});

  @override
  State<StudentGamesScreen> createState() => _StudentGamesScreenState();
}

class _StudentGamesScreenState extends State<StudentGamesScreen> {
  int _totalStars = 0;
  int _derDieDasStars = 0;
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
    final derDieDas = await GameStarsService.getDerDieDasStars(uid);
    if (!mounted) return;
    setState(() {
      _totalStars = total;
      _derDieDasStars = derDieDas;
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GamifiedCard(
              color: AppColors.duoOrange,
              shadowColor: AppColors.duoOrangeShadow,
              shadowDepth: 6,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.myStars,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        _loadingStars ? '...' : _formatStars(_totalStars),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Row(
                      children: [
                        const Text('📘', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          _loadingStars ? '...' : _formatStars(_derDieDasStars),
                          style: const TextStyle(
                            fontSize: 16,
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

            const SizedBox(height: 24),

            Text(
              l.allGames.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '🔄',
              title: 'Synonym Battle',
              subtitle: l.synonymBattle,
              stars: 3,
              maxStars: 3,
              score: '250',
              color: AppColors.duoBlue,
              shadowColor: AppColors.duoBlueShadow,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '📝',
              title: 'Grammatik O\'yin',
              subtitle: l.grammarQuiz,
              stars: 2,
              maxStars: 3,
              score: '180',
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '📘',
              title: 'Der, Die, Das',
              subtitle: l.articleSpeedGame,
              stars: 3,
              maxStars: 3,
              score: _loadingStars ? '...' : _formatStars(_derDieDasStars),
              color: AppColors.duoRed,
              shadowColor: AppColors.duoRedShadow,
              onTap: _openDerDieDasGame,
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '🎤',
              title: 'Ovozli O\'yin',
              subtitle: l.pronunciationAndListening,
              stars: 1,
              maxStars: 3,
              score: '150',
              color: AppColors.duoPurple,
              shadowColor: AppColors.duoPurpleShadow,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '⚔️',
              title: 'Tarjima Battle',
              subtitle: l.translationBattle,
              stars: 3,
              maxStars: 3,
              score: '350',
              color: AppColors.duoOrange,
              shadowColor: AppColors.duoOrangeShadow,
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '🎭',
              title: l.strangeSentencesGame,
              subtitle: l.strangeSentencesDesc,
              stars: 0,
              maxStars: 3,
              score: '0',
              color: AppColors.candyPink,
              shadowColor: const Color(0xFFE91E63),
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '📖',
              title: l.germanStoryGame,
              subtitle: l.germanStoryDesc,
              stars: 0,
              maxStars: 3,
              score: '0',
              color: AppColors.lavender,
              shadowColor: const Color(0xFF7E57C2),
              onTap: _showComingSoonDialog,
            ),
            const SizedBox(height: 16),

            _buildGameCard(
              context,
              icon: '🖼️',
              title: l.describePictureGame,
              subtitle: l.describePictureDesc,
              stars: 0,
              maxStars: 3,
              score: '0',
              color: AppColors.skyBlue,
              shadowColor: AppColors.duoBlueShadow,
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
    required int stars,
    required int maxStars,
    required String score,
    required Color color,
    required Color shadowColor,
    VoidCallback? onTap,
  }) {
    final isDark = ThemeManager.isDark;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: color,
              border: Border.all(color: shadowColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(maxStars, (index) {
                      return Text(
                        index < stars ? '⭐' : '☆',
                        style: TextStyle(
                          fontSize: 14,
                          color: index < stars
                              ? AppColors.duoOrange
                              : (isDark ? Colors.white30 : AppColors.duoTextLight),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      '$score ⭐',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
