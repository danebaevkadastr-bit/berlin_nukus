import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_manager.dart';
import '../../../models/story_game_round.dart';
import '../../../services/ai_service.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/decorative_pattern_background.dart';
import '../../../widgets/fun_loading.dart';
import '../../../widgets/gamified_card.dart';

class StoryGameScreen extends StatefulWidget {
  const StoryGameScreen({super.key});

  @override
  State<StoryGameScreen> createState() => _StoryGameScreenState();
}

class _StoryGameScreenState extends State<StoryGameScreen> {
  bool _loading = true;
  String? _loadError;
  StoryGameRound? _round;
  final TextEditingController _storyController = TextEditingController();
  bool _evaluating = false;
  StoryEvaluation? _evaluation;
  bool _finished = false;
  bool _showRules = true;
  String _selectedDifficulty = 'medium';

  @override
  void initState() {
    super.initState();
    _storyController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _storyController.removeListener(_updateWordCount);
    _storyController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    setState(() {});
  }


  Future<void> _loadRound() async {
    setState(() {
      _loading = true;
      _loadError = null;
      _evaluation = null;
      _finished = false;
      _storyController.clear();
    });

    try {
      final config = _getDifficultyConfig(_selectedDifficulty);
      final round = await AIService.generateStoryWords(
        wordCount: config['wordCount']!,
        minWords: config['minWords']!,
        maxWords: config['maxWords']!,
        difficulty: _selectedDifficulty,
      );
      if (!mounted) return;
      setState(() {
        _round = round;
        _loading = false;
        _showRules = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  Map<String, int> _getDifficultyConfig(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return {'wordCount': 6, 'minWords': 20, 'maxWords': 30};
      case 'medium':
        return {'wordCount': 10, 'minWords': 30, 'maxWords': 40};
      case 'hard':
        return {'wordCount': 15, 'minWords': 40, 'maxWords': 50};
      default:
        return {'wordCount': 10, 'minWords': 30, 'maxWords': 40};
    }
  }

  Future<void> _submitStory() async {
    final story = _storyController.text.trim();
    if (story.isEmpty || _round == null) return;

    setState(() {
      _evaluating = true;
    });

    try {
      final evaluation = await AIService.evaluateStory(
        story: story,
        requiredWords: _round!.words,
        minWords: _round!.minWords,
        maxWords: _round!.maxWords,
      );
      if (!mounted) return;
      setState(() {
        _evaluation = evaluation;
        _evaluating = false;
        _finished = true;
      });

      if (evaluation.passed) {
        SoundService.playCorrect();
      } else {
        SoundService.playIncorrect();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _evaluating = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return ValueListenableBuilder<AppLocale>(
      valueListenable: LocaleManager.currentLocale,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: AppBar(
            title: const Text(
              'Hikoya O\'YINI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme:
                IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
          ),
          body: DecorativePatternBackground(
            isDark: isDark,
            variant: DecorativePatternVariant.derDieDas,
            child: _showRules
                ? _buildRules(isDark)
                : _loading
                    ? _buildLoading(isDark, l)
                    : _loadError != null
                        ? _buildError(isDark)
                        : _finished
                            ? _buildResults(isDark)
                            : _buildGame(isDark, l),
          ),
        );
      },
    );
  }

  Widget _buildRules(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '📝 Hikoya O\'YINI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? AppColors.duoCardGray.withValues(alpha: 0.1)
                  : Colors.white,
              border: Border.all(
                color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QOIDALAR:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.candyPink,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRuleItem('1. Berilgan so\'zlardan foydalanib hikoya yozing', isDark),
                _buildRuleItem('2. Otlarning artiklini o\'zgartirishingiz mumkin (masalan: das Buch → ein Buch)', isDark),
                _buildRuleItem('3. Fe\'llarni turli shakllarda ishlatishingiz mumkin (masalan: lesen → ich lese)', isDark),
                _buildRuleItem('4. Hikoya uzunligi berilgan oraliqda bo\'lishi kerak', isDark),
                _buildRuleItem('5. Grammatik jihatdan to\'g\'ri bo\'lishi kerak', isDark),
                _buildRuleItem('6. Mantiqan bog\'liq hikoya yozing', isDark),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Darajani tanlang:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDifficultyButton('Oson', 'easy', isDark),
              const SizedBox(width: 8),
              _buildDifficultyButton('O\'rtacha', 'medium', isDark),
              const SizedBox(width: 8),
              _buildDifficultyButton('Qiyin', 'hard', isDark),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GamifiedCard(
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onTap: _loadRound,
              child: const Center(
                child: Text(
                  'Boshlash',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : AppColors.duoTextLight,
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String label, String value, bool isDark) {
    final isSelected = _selectedDifficulty == value;
    return Expanded(
      child: GamifiedCard(
        color: isSelected ? AppColors.candyPink : AppColors.duoCardGray,
        shadowColor: isSelected ? const Color(0xFFE91E63) : AppColors.duoCardGrayShadow,
        padding: const EdgeInsets.symmetric(vertical: 12),
        onTap: () {
          setState(() {
            _selectedDifficulty = value;
          });
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.duoTextDark),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark, AppLocalizations l) {
    return FunLoading(
      title: l.wordsLoading,
      tips: const [
        'AI qiziqarli so\'zlar tanlayapti...',
        'Hikoya yozishga tayyormisiz?',
        'Kreativlikni mashq qilish vaqti!',
        'So\'z boyligingizni oshiramiz!',
        'Biroz sabr — zo\'r savollar keladi!',
      ],
      color: AppColors.duoGreen,
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _loadError ?? 'Xato',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.duoTextLight,
              ),
            ),
            const SizedBox(height: 16),
            GamifiedCard(
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              onTap: _loadRound,
              child: const Text(
                'Qayta urinish',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(bool isDark, AppLocalizations l) {
    if (_round == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.candyPink),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quyidagi so\'zlardan foydalanib hikoya yozing:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? AppColors.duoCardGray.withValues(alpha: 0.1)
                  : Colors.white,
              border: Border.all(
                color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                width: 1.5,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _round!.words.map((word) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: word.type == 'verb'
                        ? AppColors.duoBlue.withValues(alpha: 0.15)
                        : AppColors.duoGreen.withValues(alpha: 0.15),
                    border: Border.all(
                      color: word.type == 'verb'
                          ? AppColors.duoBlue
                          : AppColors.duoGreen,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (word.article != null) ...[
                        Text(
                          word.article!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (_round!.theme != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.duoBlue.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.duoBlue,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.track_changes_rounded,
                      size: 16, color: AppColors.duoBlue),
                  const SizedBox(width: 6),
                  Text(
                    'Mavzu: ${_round!.theme}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.duoBlue,
                    ),
                  ),
                ],
              ),
            ),
          if (_round!.theme != null) const SizedBox(height: 12),
          Text(
            'Hikoya uzunligi: ${_round!.minWords}-${_round!.maxWords} so\'z',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : AppColors.duoTextLight,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _storyController,
            maxLines: 8,
            minLines: 6,
            decoration: InputDecoration(
              hintText: 'Hikoyani shu yerga yozing...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white30 : AppColors.duoTextLight.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.duoCardGray.withValues(alpha: 0.1)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.candyPink,
                  width: 2,
                ),
              ),
              suffixText: '${_storyController.text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length} so\'z',
              suffixStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : AppColors.duoTextLight,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GamifiedCard(
              color: AppColors.candyPink,
              shadowColor: const Color(0xFFE91E63),
              shadowDepth: 4,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onTap: _evaluating ? null : _submitStory,
              child: Center(
                child: _evaluating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Hikoyani Tekshirish',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    if (_evaluation == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.candyPink),
      );
    }

    final eval = _evaluation!;
    final passed = eval.passed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GamifiedCard(
          color: isDark
              ? AppColors.duoCardGray.withValues(alpha: 0.1)
              : Colors.white,
          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                passed ? '🎉' : '😔',
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 16),
              Text(
                passed ? 'Tabriklaymiz!' : 'Hikoya qabul qilinmadi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ball: ${eval.score}/100',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.duoOrange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'So\'zlar soni: ${eval.wordCount}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white60 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: passed
                      ? AppColors.duoGreen.withValues(alpha: 0.15)
                      : AppColors.duoRed.withValues(alpha: 0.15),
                  border: Border.all(
                    color: passed ? AppColors.duoGreen : AppColors.duoRed,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  eval.feedbackUz,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GamifiedCard(
                      color: AppColors.duoCardGray,
                      shadowColor: AppColors.duoCardGrayShadow,
                      shadowDepth: 3,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onTap: () {
                        setState(() {
                          _showRules = true;
                        });
                      },
                      child: Center(
                        child: Text(
                          'Yangi hikoya',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white70 : AppColors.duoTextDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GamifiedCard(
                      color: AppColors.duoGreen,
                      shadowColor: AppColors.duoGreenShadow,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onTap: () => Navigator.pop(context),
                      child: const Center(
                        child: Text(
                          'Yopish',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
