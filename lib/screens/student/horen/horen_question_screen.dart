import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import 'horen_data.dart';

class HorenQuestionScreen extends StatefulWidget {
  final HorenTeil teil;
  final String level;

  const HorenQuestionScreen({
    super.key,
    required this.teil,
    required this.level,
  });

  @override
  State<HorenQuestionScreen> createState() => _HorenQuestionScreenState();
}

class _HorenQuestionScreenState extends State<HorenQuestionScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isPlaying = false;
  // Fake elapsed seconds for UI demo
  int _elapsedSeconds = 0;
  static const int _totalSeconds = 23; // mock audio duration
  String? _selectedAnswer;
  bool _answered = false;
  // null = unanswered, true = correct, false = wrong
  final List<bool?> _results = [];
  final _scrollController = ScrollController();
  final _questionScrollController = ScrollController();

  List<HorenQuestion> get _questions => widget.teil.questions;
  HorenQuestion get _current => _questions[_currentIndex];

  Color get _accentColor => ThemeManager.accent;
  Color get _accentShadow => ThemeManager.accentShadow;

  @override
  void initState() {
    super.initState();
    _results.addAll(List.filled(_questions.length, null));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _questionScrollController.dispose();
    super.dispose();
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _selectedAnswer = _results[index] != null
          ? (_results[index]! ? _questions[index].correctAnswer : '__wrong__')
          : null;
      _answered = _results[index] != null;
      _isPlaying = false;
      _elapsedSeconds = 0;
    });
    _scrollQuestionPickerTo(index);
  }

  void _scrollQuestionPickerTo(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_questionScrollController.hasClients) return;
      const itemWidth = 44.0;
      final offset = (index * itemWidth).clamp(
        0.0,
        _questionScrollController.position.maxScrollExtent,
      );
      _questionScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _runFakeProgress();
    }
  }

  void _runFakeProgress() async {
    while (_isPlaying && _elapsedSeconds < _totalSeconds && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isPlaying) break;
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _totalSeconds) {
          _isPlaying = false;
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final isCorrect = answer == _current.correctAnswer;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _results[_currentIndex] = isCorrect;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      _goToQuestion(_currentIndex + 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final isLast = _currentIndex == _questions.length - 1;

    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Teil ${widget.teil.teilNumber}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 1.0,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildQuestionPicker(isDark),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAudioCard(isDark),
                      const SizedBox(height: 16),
                      _buildQuestionCard(isDark, l),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(isDark, l, isLast),
            ],
          ),
        );
      },
    );
  }

  // ── Question picker ────────────────────────────────────────────────────────
  Widget _buildQuestionPicker(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          GamifiedCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: _accentColor,
            shadowColor: _accentShadow,
            shadowDepth: 4,
            borderRadius: 20,
            child: Text(
              '${_currentIndex + 1} / ${_questions.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                controller: _questionScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _questions.length,
                itemBuilder: (context, i) {
                  final selected = i == _currentIndex;
                  final result = _results[i];

                  Color bgColor;
                  Color borderColor;
                  Color textColor;

                  if (selected) {
                    bgColor = _accentColor;
                    borderColor = _accentShadow;
                    textColor = Colors.white;
                  } else if (result == true) {
                    bgColor = AppColors.duoGreen.withValues(alpha: 0.2);
                    borderColor = AppColors.duoGreen;
                    textColor = AppColors.duoGreen;
                  } else if (result == false) {
                    bgColor = AppColors.duoRed.withValues(alpha: 0.2);
                    borderColor = AppColors.duoRed;
                    textColor = AppColors.duoRed;
                  } else {
                    bgColor = isDark
                        ? AppColors.duoCardGray.withValues(alpha: 0.2)
                        : Colors.white;
                    borderColor =
                        isDark ? Colors.white24 : AppColors.duoCardGrayShadow;
                    textColor =
                        isDark ? Colors.white70 : AppColors.duoTextDark;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _goToQuestion(i),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor,
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: _accentShadow,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Audio player ───────────────────────────────────────────────────────────
  Widget _buildAudioCard(bool isDark) {
    final progress =
        _totalSeconds > 0 ? _elapsedSeconds / _totalSeconds : 0.0;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teil badge + audio title
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Teil ${widget.teil.teilNumber}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _current.audioTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Player row: [play/pause]  0:00 ─────────── 0:23 ──
          Row(
            children: [
              // Play / Pause button
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accentShadow,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Elapsed time
              Text(
                _formatTime(_elapsedSeconds),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(width: 8),

              // Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white12
                        : AppColors.duoCardGrayShadow,
                    color: _accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Total time
              Text(
                _formatTime(_totalSeconds),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white38 : AppColors.duoTextLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Question + answers ─────────────────────────────────────────────────────
  Widget _buildQuestionCard(bool isDark, AppLocalizations l) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    // Per-question feedback banner
    Widget? feedbackBanner;
    if (_answered) {
      final isCorrect = _results[_currentIndex] == true;
      feedbackBanner = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: (isCorrect ? AppColors.duoGreen : AppColors.duoRed)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCorrect ? AppColors.duoGreen : AppColors.duoRed,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: isCorrect ? AppColors.duoGreen : AppColors.duoRed,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isCorrect ? l.horenCorrect : l.horenWrong,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isCorrect ? AppColors.duoGreen : AppColors.duoRed,
              ),
            ),
          ],
        ),
      );
    }

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question label
          Text(
            '${l.horenQuestion} ${_currentIndex + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          // Question text
          Text(
            _current.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Answer options
          ...List.generate(_current.options.length, (i) {
            final option = _current.options[i];
            final label = String.fromCharCode(65 + i); // A, B, C
            final isSelected = _selectedAnswer == option;
            final isCorrectOption = option == _current.correctAnswer;
            final isCorrectResult = _answered && isCorrectOption;
            final isWrongResult =
                _answered && isSelected && !isCorrectOption;

            // Colors
            Color cardColor;
            Color borderColor;
            Color labelBg;
            Color labelText;
            Color optionText;

            if (isCorrectResult) {
              cardColor =
                  AppColors.duoGreen.withValues(alpha: isDark ? 0.15 : 0.08);
              borderColor = AppColors.duoGreen;
              labelBg = AppColors.duoGreen;
              labelText = Colors.white;
              optionText = AppColors.duoGreen;
            } else if (isWrongResult) {
              cardColor =
                  AppColors.duoRed.withValues(alpha: isDark ? 0.15 : 0.08);
              borderColor = AppColors.duoRed;
              labelBg = AppColors.duoRed;
              labelText = Colors.white;
              optionText = AppColors.duoRed;
            } else if (isSelected) {
              cardColor =
                  _accentColor.withValues(alpha: isDark ? 0.15 : 0.08);
              borderColor = _accentColor;
              labelBg = _accentColor;
              labelText = Colors.white;
              optionText = textPrimary;
            } else {
              // Default unselected
              cardColor = isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppColors.duoBackground;
              borderColor =
                  isDark ? Colors.white12 : AppColors.duoCardGrayShadow;
              // Label badge: always visible with accent-tinted bg
              labelBg = _accentColor.withValues(alpha: 0.15);
              labelText = _accentColor;
              optionText = textPrimary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: _answered ? null : () => _selectAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      // A / B / C badge
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: labelBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
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
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.duoGreen, size: 20)
                      else if (isWrongResult)
                        const Icon(Icons.cancel_rounded,
                            color: AppColors.duoRed, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Per-question feedback banner
          if (feedbackBanner != null) ...[
            const SizedBox(height: 4),
            feedbackBanner,
          ],
        ],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool isDark, AppLocalizations l, bool isLast) {
    final canGoBack = _currentIndex > 0;
    final canGoNext = _answered;
    final textColor = isDark ? Colors.white : AppColors.duoTextDark;
    final disabledText = isDark ? Colors.white38 : AppColors.duoTextLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white12
                : AppColors.duoCardGrayShadow.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: isDark
                  ? AppColors.duoCardGray.withValues(alpha: 0.15)
                  : Colors.white,
              shadowColor:
                  isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              shadowDepth: canGoBack ? 4 : 2,
              borderRadius: 16,
              onTap: canGoBack
                  ? () => _goToQuestion(_currentIndex - 1)
                  : null,
              child: Center(
                child: Text(
                  '← Orqaga',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: canGoBack ? textColor : disabledText,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: canGoNext
                  ? _accentColor
                  : _accentColor.withValues(alpha: 0.35),
              shadowColor: _accentShadow,
              shadowDepth: canGoNext ? 5 : 2,
              borderRadius: 16,
              onTap: canGoNext ? _next : null,
              child: Center(
                child: Text(
                  isLast ? l.horenFinish : l.horenNextQuestion,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: canGoNext ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
