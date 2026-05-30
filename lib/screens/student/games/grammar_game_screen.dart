import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/grammar_game_round.dart';
import '../../../services/ai_service.dart';
import '../../../services/game_stars_service.dart';
import '../../../services/tts_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import '../../../l10n/app_localizations.dart';

class GrammarGameScreen extends StatefulWidget {
  const GrammarGameScreen({super.key});

  @override
  State<GrammarGameScreen> createState() => _GrammarGameScreenState();
}

class _GrammarGameScreenState extends State<GrammarGameScreen> {
  final TTSService _ttsService = TTSService();
  
  List<GrammarGameRound> _rounds = [];
  int _currentRoundIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String? _selectedAnswer;
  int _timeLeft = 15;

  @override
  void initState() {
    super.initState();
    _loadRounds();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _loadRounds() async {
    try {
      final rounds = await AIService.generateGrammarRounds(count: 8);
      if (mounted) {
        setState(() {
          _rounds = rounds;
          _isLoading = false;
          _startTimer();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    setState(() {
      _timeLeft = 15;
    });
  }

  void _stopTimer() {
    // Timer to'xtatish logikasi
  }

  void _handleAnswer(String answer) {
    if (_showFeedback) return;

    _stopTimer();
    final currentRound = _rounds[_currentRoundIndex];
    final correct = answer == currentRound.correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) {
        _score += 10;
      }
    });

    // TTS bilan to'g'ri javobni o'qish
    if (correct) {
      // TTS o'chirildi, chunki hozircha kerak emas
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      if (_currentRoundIndex < _rounds.length - 1) {
        setState(() {
          _currentRoundIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
          _startTimer();
        });
      } else {
        _finishGame();
      }
    });
  }

  Future<void> _finishGame() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await GameStarsService.addGrammarGameStars(userProvider.uid, _score);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildResultDialog(),
    );
  }

  Widget _buildResultDialog() {
    final isDark = ThemeManager.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
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
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'O\'yin tugadi!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.duoGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GamifiedCard(
              color: AppColors.duoGreen,
              shadowColor: AppColors.duoGreenShadow,
              shadowDepth: 4,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Center(
                child: Text(
                  'DAVOM ETISH',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.duoBlue),
        ),
      );
    }

    if (_rounds.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
        body: Center(
          child: Text(
            'Xatolik yuz berdi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        ),
      );
    }

    final currentRound = _rounds[_currentRoundIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.grammarQuiz.toUpperCase(),
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
                  '$_score',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : AppColors.duoCardGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  widthFactor: (_currentRoundIndex + 1) / _rounds.length,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.duoBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentRoundIndex + 1}/${_rounds.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.duoOrange),
                      const SizedBox(width: 4),
                      Text(
                        '$_timeLeft',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _timeLeft <= 5 ? AppColors.duoRed : AppColors.duoOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Question
              GamifiedCard(
                padding: const EdgeInsets.all(24),
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                child: Column(
                  children: [
                    Text(
                      currentRound.question,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentRound.questionUz,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: currentRound.options.length,
                  itemBuilder: (context, index) {
                    final option = currentRound.options[index];
                    final isSelected = _selectedAnswer == option;
                    final isCorrectOption = option == currentRound.correctAnswer;
                    final isCorrectResult = _showFeedback && isCorrectOption;
                    final isWrongResult = _showFeedback && isSelected && !isCorrectOption;

                    Color cardColor;
                    Color borderColor;
                    Color labelBg;
                    Color labelText;
                    Color optionText;

                    if (isCorrectResult) {
                      cardColor = AppColors.duoGreen.withValues(alpha: isDark ? 0.15 : 0.08);
                      borderColor = AppColors.duoGreen;
                      labelBg = AppColors.duoGreen;
                      labelText = Colors.white;
                      optionText = AppColors.duoGreen;
                    } else if (isWrongResult) {
                      cardColor = AppColors.duoRed.withValues(alpha: isDark ? 0.15 : 0.08);
                      borderColor = AppColors.duoRed;
                      labelBg = AppColors.duoRed;
                      labelText = Colors.white;
                      optionText = AppColors.duoRed;
                    } else if (isSelected) {
                      cardColor = AppColors.duoBlue.withValues(alpha: isDark ? 0.15 : 0.08);
                      borderColor = AppColors.duoBlue;
                      labelBg = AppColors.duoBlue;
                      labelText = Colors.white;
                      optionText = isDark ? Colors.white : AppColors.duoTextDark;
                    } else {
                      cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
                      borderColor = isDark ? Colors.white12 : AppColors.duoBlue.withValues(alpha: 0.25);
                      labelBg = AppColors.duoBlue.withValues(alpha: 0.15);
                      labelText = AppColors.duoBlue;
                      optionText = isDark ? Colors.white : AppColors.duoTextDark;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: _showFeedback ? null : () => _handleAnswer(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: labelBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: labelText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: optionText,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (isCorrectResult)
                                const Icon(Icons.check_circle_rounded, color: AppColors.duoGreen, size: 20)
                              else if (isWrongResult)
                                const Icon(Icons.cancel_rounded, color: AppColors.duoRed, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Feedback
              if (_showFeedback)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? AppColors.duoGreen.withValues(alpha: 0.2)
                        : AppColors.duoRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCorrect ? AppColors.duoGreen : AppColors.duoRed,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.info,
                        color: _isCorrect ? AppColors.duoGreen : AppColors.duoRed,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentRound.explanationUz,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.duoTextDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
