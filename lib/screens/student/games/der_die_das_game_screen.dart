import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_manager.dart';
import '../../../services/game_stars_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/der_die_das_rules.dart';
import '../../../utils/game_words.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import 'der_die_das_rules_screen.dart';

class DerDieDasGameScreen extends StatefulWidget {
  const DerDieDasGameScreen({super.key});

  @override
  State<DerDieDasGameScreen> createState() => _DerDieDasGameScreenState();
}

class _DerDieDasGameScreenState extends State<DerDieDasGameScreen> {
  late List<Map<String, String>> _deck;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _timeLeft = DerDieDasRules.secondsPerQuestion;
  Timer? _timer;
  bool _answered = false;
  bool _finished = false;
  String? _feedbackMessage;
  bool? _lastWasCorrect;
  int _totalSavedStars = 0;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewRound() {
    _timer?.cancel();
    setState(() {
      _deck = GameWords.shuffledWords(limit: DerDieDasRules.questionsPerRound);
      _index = 0;
      _score = 0;
      _correct = 0;
      _wrong = 0;
      _streak = 0;
      _finished = false;
      _answered = false;
      _feedbackMessage = null;
      _lastWasCorrect = null;
      _timeLeft = DerDieDasRules.secondsPerQuestion;
    });
    _startTimer();
  }

  Map<String, String>? get _current =>
      _index < _deck.length ? _deck[_index] : null;

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = DerDieDasRules.secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _answered || _finished) return;
      if (_timeLeft <= 1) {
        t.cancel();
        _onAnswer(null);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onAnswer(String? chosenArticle) {
    if (_answered || _finished || _current == null) return;

    _timer?.cancel();
    final correctArticle = _current!['article'] ?? '';
    final isCorrect = chosenArticle == correctArticle;
    final noun = GameWords.nounWithoutArticle(_current!);
    final fullWord = _current!['word'] ?? '';

    setState(() {
      _answered = true;
      _lastWasCorrect = isCorrect;
      if (isCorrect) {
        _correct++;
        _streak++;
        var points = DerDieDasRules.pointsPerCorrect;
        if (_streak > 0 && _streak % DerDieDasRules.streakBonusEvery == 0) {
          points += DerDieDasRules.streakBonusPoints;
        }
        _score += points;
        _feedbackMessage = 'To\'g\'ri! +$points ⭐';
      } else {
        _wrong++;
        _streak = 0;
        if (chosenArticle == null) {
          _feedbackMessage = 'Vaqt tugadi! To\'g\'ri: $correctArticle $noun';
        } else {
          _feedbackMessage = 'Noto\'g\'ri. To\'g\'ri: $fullWord';
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), _nextQuestion);
  }

  Future<void> _finishRound() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final total = await GameStarsService.addDerDieDasStars(uid, _score);
    if (!mounted) return;
    setState(() {
      _finished = true;
      _totalSavedStars = total;
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_index + 1 >= _deck.length) {
      _finishRound();
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _feedbackMessage = null;
      _lastWasCorrect = null;
    });
    _startTimer();
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
              DerDieDasRules.gameTitle.toUpperCase(),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.menu_book_rounded),
                tooltip: 'Qoidalar',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DerDieDasRulesScreen()),
                ),
              ),
            ],
          ),
          body: _finished
              ? _buildResults(isDark)
              : _buildGame(isDark, locale.code),
        );
      },
    );
  }

  Widget _buildGame(bool isDark, String localeCode) {
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
              _statChip(isDark, '⭐ $_score', AppColors.duoOrange),
              const SizedBox(width: 8),
              _statChip(isDark, '✓ $_correct', AppColors.duoGreen),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ketma-ket: $_streak 🔥',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white60 : AppColors.duoTextLight,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: 18,
                    color: _timeLeft <= 4 ? AppColors.duoRed : AppColors.duoOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_timeLeft s',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _timeLeft <= 4 ? AppColors.duoRed : AppColors.duoOrange,
                    ),
                  ),
                ],
              ),
            ],
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

  Widget _buildResults(bool isDark) {
    final accuracy = _deck.isEmpty ? 0 : ((_correct / _deck.length) * 100).round();
    String emoji;
    String message;
    if (accuracy >= 90) {
      emoji = '🏆';
      message = 'Ajoyib natija!';
    } else if (accuracy >= 70) {
      emoji = '⭐';
      message = 'Yaxshi ish!';
    } else if (accuracy >= 50) {
      emoji = '💪';
      message = 'Yana mashq qiling!';
    } else {
      emoji = '📘';
      message = 'Qoidalarni qayta o\'qing';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          GamifiedCard(
            color: AppColors.duoRed,
            shadowColor: AppColors.duoRedShadow,
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  message.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'RAUND YAKUNLANDI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _resultRow(isDark, 'Bu raund', '+$_score ⭐', AppColors.duoOrange),
          const SizedBox(height: 10),
          _resultRow(isDark, 'Jami yulduz', '$_totalSavedStars ⭐', AppColors.duoOrange),
          const SizedBox(height: 10),
          _resultRow(isDark, 'To\'g\'ri', '$_correct / ${_deck.length}', AppColors.duoGreen),
          const SizedBox(height: 10),
          _resultRow(isDark, 'Xato', '$_wrong', AppColors.duoRed),
          const SizedBox(height: 10),
          _resultRow(isDark, 'Aniqlik', '$accuracy%', AppColors.duoBlue),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              onTap: _startNewRound,
              child: const Center(
                child: Text(
                  'YANA O\'YNASH',
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.15) : Colors.white,
              shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              onTap: () => Navigator.pop(context),
              child: Center(
                child: Text(
                  'ORQAGA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white70 : AppColors.duoTextDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(bool isDark, String label, String value, Color color) {
    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white70 : AppColors.duoTextLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
