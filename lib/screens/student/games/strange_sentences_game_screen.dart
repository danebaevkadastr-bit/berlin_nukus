import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_manager.dart';
import '../../../models/strange_sentences_round.dart';
import '../../../services/ai_service.dart';
import '../../../services/game_stars_service.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/strange_sentences_rules.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/bn_tiyin.dart';
import '../../../widgets/decorative_pattern_background.dart';
import '../../../widgets/fun_loading.dart';
import '../../../widgets/gamified_card.dart';
import 'strange_sentences_rules_screen.dart';

class StrangeSentencesGameScreen extends StatefulWidget {
  final StrangeDifficulty difficulty;
  const StrangeSentencesGameScreen({
    super.key,
    this.difficulty = StrangeDifficulty.medium,
  });

  @override
  State<StrangeSentencesGameScreen> createState() =>
      _StrangeSentencesGameScreenState();
}

class _StrangeSentencesGameScreenState extends State<StrangeSentencesGameScreen> {
  List<StrangeSentencesRound> _deck = [];
  bool _loading = true;
  String? _loadError;
  late StrangeDifficulty _selectedDifficulty;

  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _timeLeft = StrangeSentencesRules.secondsPerRound;
  Timer? _timer;
  bool _answered = false;
  bool _finished = false;
  String? _feedbackMessage;
  bool? _lastWasCorrect;
  int _totalSavedStars = 0;

  List<String> _selectedWords = [];
  List<String> _poolWords = [];

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.difficulty;
    _loadRounds();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRounds() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final rounds = await AIService.generateStrangeSentenceRounds(
        count: StrangeSentencesRules.roundsPerSession,
        difficulty: _selectedDifficulty,
      );
      if (!mounted) return;
      setState(() {
        _deck = rounds;
        _loading = false;
        if (rounds.isNotEmpty &&
            rounds.first.type == StrangeRoundType.order) {
          _resetOrderState(rounds.first);
        }
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  StrangeSentencesRound? get _current =>
      _index < _deck.length ? _deck[_index] : null;

  void _resetOrderState(StrangeSentencesRound round) {
    _selectedWords = [];
    _poolWords = List<String>.from(round.shuffledWords);
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = StrangeSentencesRules.secondsPerRound;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _answered || _finished || _loading) return;
      if (_timeLeft <= 1) {
        t.cancel();
        _onTimeout();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onTimeout() {
    if (_answered || _current == null) return;
    _submitAnswer(null);
  }

  String _normalizeToken(String w) =>
      w.trim().replaceAll(RegExp(r'[.,!?;:]+$'), '');

  bool _orderMatches(List<String> selected, StrangeSentencesRound round) {
    final expected = round.orderTokens;
    if (selected.length != expected.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (_normalizeToken(selected[i]) != _normalizeToken(expected[i])) {
        return false;
      }
    }
    return true;
  }

  void _submitAnswer(String? pickChoice) {
    if (_answered || _finished || _current == null) return;
    _timer?.cancel();

    final round = _current!;
    final bool isCorrect;
    if (round.type == StrangeRoundType.pick) {
      isCorrect = pickChoice != null &&
          _normalizeToken(pickChoice) ==
              _normalizeToken(round.correctSentence);
    } else {
      isCorrect = _orderMatches(_selectedWords, round);
    }

    setState(() {
      _answered = true;
      _lastWasCorrect = isCorrect;
      if (isCorrect) {
        _correct++;
        _streak++;
        var points = StrangeSentencesRules.pointsForDifficulty(round.difficulty);
        if (_streak > 0 &&
            _streak % StrangeSentencesRules.streakBonusEvery == 0) {
          points += StrangeSentencesRules.streakBonusPoints;
        }
        _score += points;
        _feedbackMessage = 'To\'g\'ri! +$points ⭐';
        SoundService.playCorrect();
      } else {
        _wrong++;
        _streak = 0;
        _feedbackMessage = round.explanationUz.isNotEmpty
            ? round.explanationUz
            : 'To\'g\'ri: ${round.correctSentence}';
        SoundService.playIncorrect();
      }
    });

    Future.delayed(const Duration(milliseconds: 1600), _nextRound);
  }

  Future<void> _finishSession() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final total = await GameStarsService.addStrangeSentencesStars(uid, _score);
    if (!mounted) return;
    setState(() {
      _finished = true;
      _totalSavedStars = total;
    });
  }

  void _nextRound() {
    if (!mounted) return;
    if (_index + 1 >= _deck.length) {
      _finishSession();
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _feedbackMessage = null;
      _lastWasCorrect = null;
      final next = _current;
      if (next != null && next.type == StrangeRoundType.order) {
        _resetOrderState(next);
      }
    });
    _startTimer();
  }

  void _onPoolWordTap(String word) {
    if (_answered || _current?.type != StrangeRoundType.order) return;
    setState(() {
      _selectedWords.add(word);
      _poolWords.remove(word);
    });
  }

  void _onSelectedWordTap(int index) {
    if (_answered) return;
    setState(() {
      final w = _selectedWords.removeAt(index);
      _poolWords.add(w);
    });
  }

  void _clearOrder() {
    if (_answered || _current == null) return;
    _resetOrderState(_current!);
    setState(() {});
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
            title: Text(
              l.strangeSentencesGame.toUpperCase(),
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
            iconTheme:
                IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu_book_rounded),
                tooltip: l.strangeSentencesRulesHowTo,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StrangeSentencesRulesScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: DecorativePatternBackground(
            isDark: isDark,
            variant: DecorativePatternVariant.derDieDas,
            child: _loading
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

  Widget _buildLoading(bool isDark, AppLocalizations l) {
    return FunLoading(
      title: l.strangeSentencesGame,
      tips: const [
        'Grammatik jihatdan to\'g\'ri g\'alati gaplarni topamiz!',
        'So\'z tartibini bilasizmi?',
        'Har raund uchun vaqt cheklangan!',
        'AI qiziqarli gaplar tayyorlayapti...',
        'Biroz sabr — zo\'r savollar keladi!',
      ],
      color: AppColors.candyPink,
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
              onTap: _loadRounds,
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
    final round = _current;
    if (round == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.candyPink),
      );
    }

    final progress = (_index + 1) / _deck.length;
    final modeLabel = round.type == StrangeRoundType.pick
        ? '🎯 ${l.strangeSentencesPickHint}'
        : '🔀 ${l.strangeSentencesOrderHint}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BnTiyin(size: 14),
                  const SizedBox(width: 4),
                  _statChip(isDark, ' $_score', AppColors.duoOrange),
                ],
              ),
              const SizedBox(width: 8),
              _statChip(isDark, '✓ $_correct', AppColors.duoGreen),
              const Spacer(),
              _statChip(isDark, '$_index/${_deck.length}', AppColors.candyPink),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor:
                  isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              color: AppColors.candyPink,
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
                    color: _timeLeft <= 8
                        ? AppColors.duoRed
                        : AppColors.duoOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_timeLeft s',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _timeLeft <= 8
                          ? AppColors.duoRed
                          : AppColors.duoOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            modeLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
          const SizedBox(height: 12),
          if (_feedbackMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: (_lastWasCorrect == true
                        ? AppColors.duoGreen
                        : AppColors.duoRed)
                    .withValues(alpha: 0.15),
                border: Border.all(
                  color: _lastWasCorrect == true
                      ? AppColors.duoGreen
                      : AppColors.duoRed,
                  width: 1.5,
                ),
              ),
              child: Text(
                _feedbackMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: round.type == StrangeRoundType.pick
                ? _buildPickRound(isDark, round, l)
                : _buildOrderRound(isDark, round, l),
          ),
        ],
      ),
    );
  }

  Widget _buildPickRound(
    bool isDark,
    StrangeSentencesRound round,
    AppLocalizations l,
  ) {
    return ListView.separated(
      itemCount: round.pickOptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final option = round.pickOptions[i];
        return GamifiedCard(
          color: isDark
              ? AppColors.duoCardGray.withValues(alpha: 0.1)
              : Colors.white,
          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
          shadowDepth: 4,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          onTap: _answered ? null : () => _submitAnswer(option),
          child: Text(
            option,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.35,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderRound(
    bool isDark,
    StrangeSentencesRound round,
    AppLocalizations l,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.strangeSentencesYourSentence,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
          const SizedBox(height: 8),
          GamifiedCard(
            color: isDark
                ? AppColors.duoCardGray.withValues(alpha: 0.12)
                : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            padding: const EdgeInsets.all(14),
            child: _selectedWords.isEmpty
                ? Text(
                    '—',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white30 : AppColors.duoTextLight,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_selectedWords.length, (i) {
                      return _wordChip(
                        isDark,
                        _selectedWords[i],
                        onTap: _answered ? null : () => _onSelectedWordTap(i),
                        selected: true,
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            l.strangeSentencesTapWords,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _poolWords.map((w) {
              return _wordChip(
                isDark,
                w,
                onTap: _answered ? null : () => _onPoolWordTap(w),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GamifiedCard(
                  color: AppColors.duoCardGray,
                  shadowColor: AppColors.duoCardGrayShadow,
                  shadowDepth: 3,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: _answered ? null : _clearOrder,
                  child: Center(
                    child: Text(
                      l.strangeSentencesReset,
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
                flex: 2,
                child: GamifiedCard(
                  color: AppColors.candyPink,
                  shadowColor: const Color(0xFFE91E63),
                  shadowDepth: 4,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: _answered || _selectedWords.length != round.orderTokens.length
                      ? null
                      : () => _submitAnswer(null),
                  child: Center(
                    child: Text(
                      l.strangeSentencesCheck.toUpperCase(),
                      style: const TextStyle(
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
    );
  }

  Widget _wordChip(
    bool isDark,
    String word, {
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? AppColors.candyPink.withValues(alpha: 0.2)
                : (isDark ? Colors.white10 : AppColors.duoBackground),
            border: Border.all(
              color: selected ? AppColors.candyPink : AppColors.duoCardGrayShadow,
              width: 1.5,
            ),
          ),
          child: Text(
            word,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(bool isDark, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.15),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    final l = AppLocalizations.of(context);
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
              const Icon(Icons.celebration_rounded,
                  size: 56, color: AppColors.duoOrange),
              const SizedBox(height: 16),
              Text(
                l.sessionFinished,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BnTiyin(size: 22, spinning: true),
                  const SizedBox(width: 4),
                  Text(
                    '$_score ${l.mockTestPointsSuffix}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.duoOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${l.horenCorrect}: $_correct  •  ${l.horenWrong}: $_wrong',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white60 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l.totalStars}: $_totalSavedStars',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  BnTiyin(size: 15, spinning: false),
                ],
              ),
              const SizedBox(height: 24),
              GamifiedCard(
                color: AppColors.duoGreen,
                shadowColor: AppColors.duoGreenShadow,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                onTap: () => Navigator.pop(context),
                child: Text(
                  l.close,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
