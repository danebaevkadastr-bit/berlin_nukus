import 'package:flutter/material.dart';

import 'package:core/l10n/locale_manager.dart';
import 'package:core/services/sound_service.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/der_die_das_rules.dart';
import 'package:core/utils/game_words.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/decorative_pattern_background.dart';
import 'package:core/widgets/gamified_card.dart';

class DerDieDasLearningScreen extends StatefulWidget {
  const DerDieDasLearningScreen({super.key});

  @override
  State<DerDieDasLearningScreen> createState() => _DerDieDasLearningScreenState();
}

class _DerDieDasLearningScreenState extends State<DerDieDasLearningScreen> {
  late List<Map<String, String>> _deck;
  int _index = 0;
  int _correct = 0;
  int _wrong = 0;
  bool _answered = false;
  String? _feedbackMessage;
  bool? _lastWasCorrect;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      _deck = GameWords.shuffledWords(limit: DerDieDasRules.questionsPerRound);
      _index = 0;
      _correct = 0;
      _wrong = 0;
      _answered = false;
      _feedbackMessage = null;
      _lastWasCorrect = null;
    });
  }

  Map<String, String>? get _current =>
      _index < _deck.length ? _deck[_index] : null;

  void _onAnswer(String? chosenArticle) {
    if (_answered || _current == null) return;

    final correctArticle = _current!['article'] ?? '';
    final isCorrect = chosenArticle == correctArticle;
    final noun = GameWords.nounWithoutArticle(_current!);
    final fullWord = _current!['word'] ?? '';

    setState(() {
      _answered = true;
      _lastWasCorrect = isCorrect;
      if (isCorrect) {
        _correct++;
        _feedbackMessage = 'To\'g\'ri!';
        SoundService.playCorrect();
      } else {
        _wrong++;
        if (chosenArticle == null) {
          _feedbackMessage = 'To\'g\'ri: $correctArticle $noun';
        } else {
          _feedbackMessage = 'Noto\'g\'ri. To\'g\'ri: $fullWord';
        }
        SoundService.playIncorrect();
      }
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_index + 1 >= _deck.length) {
      _showRoundCompleteDialog();
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _feedbackMessage = null;
      _lastWasCorrect = null;
    });
  }

  void _showRoundCompleteDialog() {
    final accuracy = _deck.isEmpty ? 0 : ((_correct / _deck.length) * 100).round();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeManager.isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Raund yakunlandi!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: ThemeManager.isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aniqlik: $accuracy%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.duoBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'To\'g\'ri: $_correct | Xato: $_wrong',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeManager.isDark ? Colors.white70 : AppColors.duoTextLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewRound();
            },
            child: const Text(
              'Yana o\'rganish',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.duoGreen,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Chiqish',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.duoRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _articleColor(String article) {
    switch (article) {
      case 'der':
        return AppColors.duoBlue;
      case 'die':
        return AppColors.duoRed;
      default:
        return AppColors.duoGreen;
    }
  }

  Color _articleShadow(String article) {
    switch (article) {
      case 'der':
        return AppColors.duoBlueShadow;
      case 'die':
        return AppColors.duoRedShadow;
      default:
        return AppColors.duoGreenShadow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return ValueListenableBuilder<AppLocale>(
      valueListenable: LocaleManager.currentLocale,
      builder: (context, locale, _) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: AppBar(
            title: Text(
              'Der, Die, Das - O\'rganish',
              style: TextStyle(
                fontSize: 16,
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
          body: DecorativePatternBackground(
            isDark: isDark,
            variant: DecorativePatternVariant.derDieDas,
            child: _buildLearning(isDark, locale.code),
          ),
        );
      },
    );
  }

  Widget _buildLearning(bool isDark, String localeCode) {
    final current = _current;
    if (current == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.duoRed));
    }

    final noun = GameWords.nounWithoutArticle(current);
    final translation = GameWords.localizedTranslation(current, localeCode);
    final progress = (_index + 1) / _deck.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          Row(
            children: [
              _statChip(isDark, '✓ $_correct', AppColors.duoGreen),
              const SizedBox(width: 8),
              _statChip(isDark, '✗ $_wrong', AppColors.duoRed),
              const Spacer(),
              _statChip(isDark, '$_index/${_deck.length}', AppColors.duoBlue),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              color: AppColors.duoRed,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: GamifiedCard(
              color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
              shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              padding: const EdgeInsets.all(28),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Qaysi artikl?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 88,
                      width: double.infinity,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            noun,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.duoTextDark,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          translation,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : AppColors.duoTextLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 76,
                      width: double.infinity,
                      child: Center(
                        child: _feedbackMessage == null
                            ? const SizedBox.shrink()
                            : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: (_lastWasCorrect == true
                                          ? AppColors.duoGreen
                                          : AppColors.duoRed)
                                      .withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: _lastWasCorrect == true
                                        ? AppColors.duoGreen
                                        : AppColors.duoRed,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _feedbackMessage!,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _lastWasCorrect == true
                                          ? AppColors.duoGreen
                                          : AppColors.duoRed,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _articleButton('der', isDark),
              const SizedBox(width: 10),
              _articleButton('die', isDark),
              const SizedBox(width: 10),
              _articleButton('das', isDark),
            ],
          ),
          const SizedBox(height: 16),
          if (_answered)
            SizedBox(
              width: double.infinity,
              child: GamifiedCard(
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: AppColors.duoBlue,
                shadowColor: AppColors.duoBlueShadow,
                onTap: _nextQuestion,
                child: const Center(
                  child: Text(
                    'KEYINGI',
                    style: TextStyle(
                      fontSize: 16,
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
    );
  }

  Widget _statChip(bool isDark, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }

  Widget _articleButton(String article, bool isDark) {
    final color = _articleColor(article);
    final shadow = _articleShadow(article);
    final disabled = _answered;

    return Expanded(
      child: GamifiedCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: disabled ? (isDark ? Colors.white12 : AppColors.duoCardGrayShadow) : color,
        shadowColor: disabled ? Colors.transparent : shadow,
        shadowDepth: disabled ? 0 : 4,
        onTap: disabled ? null : () => _onAnswer(article),
        child: Center(
          child: Text(
            article.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: disabled ? (isDark ? Colors.white38 : AppColors.duoTextLight) : Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
