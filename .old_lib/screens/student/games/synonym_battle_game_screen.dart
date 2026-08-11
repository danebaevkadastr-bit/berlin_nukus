import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/synonym_word.dart';
import '../../../services/game_stars_service.dart';
import '../../../services/haptic_service.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/synonym_data.dart';
import '../../../utils/synonym_rules.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/bn_tiyin.dart';
import '../../../widgets/decorative_pattern_background.dart';
import '../../../widgets/fun_loading.dart';
import '../../../widgets/gamified_card.dart';
import 'synonym_battle_rules_screen.dart';

/// Sinonimlar Jangi o'yini asosiy ekrani.
///
/// Bu ekran o'yin jarayonini boshqaradi: savollar, taymer,
/// javoblarni tekshirish va natijalarni ko'rsatish.
/// DerDieDasGameScreen patterniga mos ravishda yaratilgan.
class SynonymBattleGameScreen extends StatefulWidget {
  const SynonymBattleGameScreen({super.key});

  @override
  State<SynonymBattleGameScreen> createState() =>
      _SynonymBattleGameScreenState();
}

class _SynonymBattleGameScreenState extends State<SynonymBattleGameScreen> {
  // ===== State Variables =====
  
  /// Joriy raund uchun so'zlar to'plami
  late List<SynonymWord> _deck;
  
  /// Joriy savol uchun javob variantlari (4 ta)
  late List<String> _currentOptions;
  
  /// Joriy savol indeksi (0 dan boshlanadi)
  int _index = 0;
  
  /// Joriy raund balli
  int _score = 0;
  
  /// To'g'ri javoblar soni
  int _correct = 0;
  
  /// Noto'g'ri javoblar soni
  int _wrong = 0;
  
  /// Ketma-ket to'g'ri javoblar soni (streak)
  int _streak = 0;
  
  /// Joriy savol uchun qolgan vaqt (soniyalarda)
  int _timeLeft = SynonymRules.secondsPerQuestion;
  
  /// Taymer
  Timer? _timer;
  
  /// Joriy savolga javob berilganmi
  bool _answered = false;
  
  /// Raund yakunlanganmi
  bool _finished = false;
  
  /// Feedback xabari (to'g'ri/noto'g'ri)
  String? _feedbackMessage;
  
  /// Oxirgi javob to'g'ri bo'ldimi
  bool? _lastWasCorrect;
  
  /// Jami saqlangan yulduzlar soni
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

  /// Yangi raund boshlash
  /// 
  /// Deck ni 10 ta tasodifiy so'z bilan to'ldiradi va
  /// barcha state o'zgaruvchilarini boshlang'ich holatga qaytaradi.
  void _startNewRound() {
    _timer?.cancel();
    setState(() {
      _deck = SynonymData.shuffledWords(limit: SynonymRules.questionsPerRound);
      _index = 0;
      _score = 0;
      _correct = 0;
      _wrong = 0;
      _streak = 0;
      _finished = false;
      _answered = false;
      _feedbackMessage = null;
      _lastWasCorrect = null;
      _timeLeft = SynonymRules.secondsPerQuestion;
      // Birinchi savol uchun variantlarni generatsiya qilish
      if (_deck.isNotEmpty) {
        _currentOptions = SynonymData.generateOptions(_deck[0]);
      }
    });
    _startTimer();
  }

  /// Joriy so'zni olish
  /// 
  /// Agar deck tugagan bo'lsa null qaytaradi.
  SynonymWord? get _current => _index < _deck.length ? _deck[_index] : null;

  /// Taymerni boshlash
  /// 
  /// Har soniyada _timeLeft ni kamaytiradi.
  /// Vaqt tugaganda javobni noto'g'ri deb hisoblaydi.
  void _startTimer() {
    _timer?.cancel();
    _timeLeft = SynonymRules.secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _answered || _finished) return;
      if (_timeLeft <= 1) {
        t.cancel();
        _onAnswer(null); // Vaqt tugadi - noto'g'ri javob
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  /// Javobni tekshirish
  /// 
  /// [chosenSynonym] - foydalanuvchi tanlagan sinonim (null = vaqt tugadi)
  void _onAnswer(String? chosenSynonym) {
    if (_answered || _finished || _current == null) return;

    _timer?.cancel();
    final word = _current!;
    final isCorrect = chosenSynonym != null && word.synonyms.contains(chosenSynonym);
    final correctSynonym = word.randomSynonym;

    setState(() {
      _answered = true;
      _lastWasCorrect = isCorrect;
      if (isCorrect) {
        _correct++;
        _streak++;
        var points = SynonymRules.pointsPerCorrect;
        // Streak bonus tekshirish
        if (_streak > 0 && _streak % SynonymRules.streakBonusEvery == 0) {
          points += SynonymRules.streakBonusPoints;
        }
        _score += points;
        _feedbackMessage = '${SynonymRules.correctAnswerMessage} +$points ⭐';
        SoundService.playCorrect();
        HapticService.mediumImpact();
      } else {
        _wrong++;
        _streak = 0;
        if (chosenSynonym == null) {
          _feedbackMessage = '${SynonymRules.timeoutMessage} To\'g\'ri: $correctSynonym';
        } else {
          _feedbackMessage = '${SynonymRules.wrongAnswerPrefix} $correctSynonym';
        }
        SoundService.playIncorrect();
        HapticService.lightImpact();
      }
    });

    // 1.4 soniyadan keyin keyingi savolga o'tish
    Future.delayed(const Duration(milliseconds: 1400), _nextQuestion);
  }

  /// Raundni yakunlash va yulduzlarni saqlash
  Future<void> _finishRound() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final total = await GameStarsService.addSynonymBattleStars(uid, _score);
    if (!mounted) return;
    setState(() {
      _finished = true;
      _totalSavedStars = total;
    });
  }

  /// Keyingi savolga o'tish
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
      // Yangi savol uchun variantlarni generatsiya qilish
      _currentOptions = SynonymData.generateOptions(_deck[_index]);
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          SynonymRules.gameTitle.toUpperCase(),
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
              MaterialPageRoute(builder: (_) => const SynonymBattleRulesScreen()),
            ),
          ),
        ],
      ),
      body: DecorativePatternBackground(
        isDark: isDark,
        variant: DecorativePatternVariant.synonymBattle,
        child: _finished
            ? _buildResults(isDark)
            : _buildGame(isDark),
      ),
    );
  }

  /// O'yin UI ni qurish
  Widget _buildGame(bool isDark) {
    final current = _current;
    if (current == null) {
      return FunLoading(
        title: 'Sinonim jang',
        tips: FunLoading.gameTips,
        color: AppColors.duoPurple,
      );
    }

    final progress = (_index + 1) / _deck.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          // Stats row
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
              _statChip(isDark, '${_index + 1}/${_deck.length}', AppColors.duoPurple),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              color: AppColors.duoPurple,
            ),
          ),
          const SizedBox(height: 8),
          // Streak and timer row
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
                    color: _timeLeft <= SynonymRules.timerWarningThreshold
                        ? AppColors.duoRed
                        : AppColors.duoOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_timeLeft s',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _timeLeft <= SynonymRules.timerWarningThreshold
                          ? AppColors.duoRed
                          : AppColors.duoOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Question card - placeholder for Task 5.2
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
                      'Qaysi sinonim?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // German word
                    SizedBox(
                      height: 88,
                      width: double.infinity,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            current.word,
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
                    // Uzbek translation
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          current.translation,
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
                    // Feedback message
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
          // Answer options - 4 buttons in 2x2 grid
          Column(
            children: [
              Row(
                children: [
                  _optionButton(_currentOptions[0], isDark),
                  const SizedBox(width: 10),
                  _optionButton(_currentOptions[1], isDark),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _optionButton(_currentOptions[2], isDark),
                  const SizedBox(width: 10),
                  _optionButton(_currentOptions[3], isDark),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Statistika chip widgeti
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

  /// Javob varianti tugmasi
  Widget _optionButton(String option, bool isDark) {
    final disabled = _answered;
    const color = AppColors.duoPurple;
    const shadow = AppColors.duoPurpleShadow;

    return Expanded(
      child: GamifiedCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        color: disabled ? (isDark ? Colors.white12 : AppColors.duoCardGrayShadow) : color,
        shadowColor: disabled ? Colors.transparent : shadow,
        shadowDepth: disabled ? 0 : 4,
        onTap: disabled ? null : () => _onAnswer(option),
        child: Center(
          child: Text(
            option,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: disabled ? (isDark ? Colors.white38 : AppColors.duoTextLight) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Natijalar UI ni qurish
  Widget _buildResults(bool isDark) {
    final accuracy = _deck.isEmpty ? 0 : ((_correct / _deck.length) * 100).round();
    final emoji = SynonymRules.getResultEmoji(accuracy);
    final message = SynonymRules.getMotivationalMessage(accuracy);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // Results header card
          GamifiedCard(
            color: AppColors.duoPurple,
            shadowColor: AppColors.duoPurpleShadow,
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  message.split('!').first.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
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
          // Stats rows
          _resultRow(isDark, SynonymRules.roundScoreLabel, '+$_score', AppColors.duoOrange, coin: true),
          const SizedBox(height: 10),
          _resultRow(isDark, SynonymRules.totalStarsLabel, '$_totalSavedStars', AppColors.duoOrange, coin: true),
          const SizedBox(height: 10),
          _resultRow(isDark, SynonymRules.correctLabel, '$_correct / ${_deck.length}', AppColors.duoGreen),
          const SizedBox(height: 10),
          _resultRow(isDark, SynonymRules.wrongLabel, '$_wrong', AppColors.duoRed),
          const SizedBox(height: 10),
          _resultRow(isDark, SynonymRules.accuracyLabel, '$accuracy%', AppColors.duoPurple),
          const Spacer(),
          // Play again button
          SizedBox(
            width: double.infinity,
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              onTap: _startNewRound,
              child: const Center(
                child: Text(
                  SynonymRules.playAgainButtonText,
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
          // Back button
          SizedBox(
            width: double.infinity,
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.15) : Colors.white,
              shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              onTap: () => Navigator.pop(context),
              child: Center(
                child: Text(
                  SynonymRules.backButtonText,
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

  /// Natija qatori widgeti
  Widget _resultRow(bool isDark, String label, String value, Color color, {bool coin = false}) {
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (coin) ...[
                const BnTiyin(size: 16, spinning: true),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
