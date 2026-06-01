import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _HorenQuestionScreenState extends State<HorenQuestionScreen> {
  int _currentIndex = 0;

  // Audio
  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;

  // Quiz
  String? _selectedAnswer;
  bool _answered = false;
  final List<bool?> _results = [];

  final _scrollController = ScrollController();
  final _questionScrollController = ScrollController();

  List<HorenQuestion> get _questions => widget.teil.questions;
  HorenQuestion get _current => _questions[_currentIndex];

  Color get _accentColor => ThemeManager.accent;
  Color get _accentShadow => ThemeManager.accentShadow;

  bool get _isPlaying => _playerState == PlayerState.playing;

  // ── SharedPreferences key ─────────────────────────────────────────────────
  String _prefKey(int index) =>
      'horen_${widget.level}_teil${widget.teil.teilNumber}_q$index';
  String _prefAnswerKey(int index) =>
      'horen_${widget.level}_teil${widget.teil.teilNumber}_q${index}_answer';

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _questions.length; i++) {
      final val = prefs.getString(_prefKey(i));
      if (val == 'true') {
        _results[i] = true;
      } else if (val == 'false') {
        _results[i] = false;
      }
    }
    // Joriy savol uchun tanlangan javobni ham yuklash
    if (_results[_currentIndex] != null) {
      final saved = prefs.getString(_prefAnswerKey(_currentIndex));
      if (mounted) {
        setState(() {
          _answered = true;
          _selectedAnswer = saved;
        });
      }
    } else if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveResult(int index, bool isCorrect, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey(index), isCorrect.toString());
    await prefs.setString(_prefAnswerKey(index), answer);
  }

  @override
  void initState() {
    super.initState();
    _results.addAll(List.filled(_questions.length, null));
    _setupAudioListeners();
    _loadAudio();
    _loadResults();
  }

  void _setupAudioListeners() {
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
    _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = _duration);
    });
  }

  Future<void> _loadAudio() async {
    final url = _current.audioUrl;
    if (url.isEmpty) return;
    setState(() {
      _isLoading = true;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    try {
      await _player.stop();
      await _player.setSourceUrl(url);
      // Get duration after setting source
      final dur = await _player.getDuration();
      if (mounted && dur != null) setState(() => _duration = dur);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _togglePlay() async {
    if (_current.audioUrl.isEmpty) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_position >= _duration && _duration > Duration.zero) {
        await _player.seek(Duration.zero);
      }
      await _player.resume();
    }
  }

  Future<void> _seekTo(double ratio) async {
    if (_duration == Duration.zero) return;
    final target = Duration(
      milliseconds: (ratio * _duration.inMilliseconds).round(),
    );
    await _player.seek(target);
  }

  @override
  void dispose() {
    _player.dispose();
    _scrollController.dispose();
    _questionScrollController.dispose();
    super.dispose();
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) {
      return;
    }
    
    final previousUrl = _current.audioUrl;
    
    setState(() {
      _currentIndex = index;
      _answered = _results[index] != null;
      _selectedAnswer = null;
    });
    
    // Saqlangan javobni yuklash
    if (_results[index] != null) {
      SharedPreferences.getInstance().then((prefs) {
        final saved = prefs.getString(_prefAnswerKey(index));
        if (mounted) setState(() => _selectedAnswer = saved);
      });
    }
    _scrollQuestionPickerTo(index);
    
    // Agar audio URL o'zgarmagan bo'lsa, qaytadan yuklamaslik
    final newUrl = _questions[index].audioUrl;
    if (newUrl != previousUrl) {
      setState(() {
        _isLoading = false;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      _loadAudio();
    }
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

  void _selectAnswer(String answer) {
    if (_answered) return;
    final isCorrect = answer == _current.correctAnswer;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _results[_currentIndex] = isCorrect;
    });
    _saveResult(_currentIndex, isCorrect, answer);
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      _goToQuestion(_currentIndex + 1);
    } else {
      Navigator.pop(context);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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

  // ── Question picker ──────────────────────────────────────────────────────
  Widget _buildQuestionPicker(bool isDark) {
    final isB1 = widget.level == 'B1';
    int questionsPerTest = 5; // default
    
    if (isB1 && widget.teil.teilNumber == 2) {
      questionsPerTest = 10; // Teil 2 da 10 ta savol
    }
    
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
                itemCount: _questions.length + (isB1 ? (_questions.length ~/ questionsPerTest) : 0),
                itemBuilder: (context, index) {
                  // B1 uchun test headerlarini qo'shish
                  if (isB1) {
                    // Har questionsPerTest ta savoldan keyin test header qo'shish
                    final testHeaderCount = index ~/ (questionsPerTest + 1);
                    final positionInGroup = index % (questionsPerTest + 1);
                    
                    if (positionInGroup == 0) {
                      // Bu test header
                      final testNum = testHeaderCount + 1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _accentColor.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'TEST $testNum',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Bu savol tugmasi
                    final questionIndex = testHeaderCount * questionsPerTest + (positionInGroup - 1);
                    if (questionIndex >= _questions.length) return const SizedBox.shrink();
                    
                    return _buildQuestionButton(questionIndex, isDark);
                  } else {
                    // A1 uchun oddiy ko'rinish
                    return _buildQuestionButton(index, isDark);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionButton(int i, bool isDark) {
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
  }

  // ── Audio player ─────────────────────────────────────────────────────────
  Widget _buildAudioCard(bool isDark) {
    final hasAudio = _current.audioUrl.isNotEmpty;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return GamifiedCard(
      color: isDark
          ? AppColors.duoCardGray.withValues(alpha: 0.1)
          : Colors.white,
      shadowColor: isDark ? Colors.black26 : _accentShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Player row ──
          Row(
            children: [
              // Play / Pause button
              GestureDetector(
                onTap: hasAudio ? _togglePlay : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasAudio
                        ? _accentColor
                        : (isDark ? Colors.white12 : AppColors.duoCardGrayShadow),
                    shape: BoxShape.circle,
                    boxShadow: hasAudio
                        ? [
                            BoxShadow(
                              color: _accentShadow,
                              offset: const Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Elapsed time
              Text(
                _formatDuration(_position),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(width: 8),

              // Seekable progress bar
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    // approximate width of the bar area
                    final barWidth = box.size.width - 44 - 12 - 40 - 16;
                    final ratio =
                        (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
                    _seekTo(ratio);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white12
                          : AppColors.duoCardGrayShadow,
                      color: hasAudio
                          ? _accentColor
                          : (isDark
                              ? Colors.white24
                              : AppColors.duoCardGrayShadow),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Total duration
              Text(
                _formatDuration(_duration),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white38 : AppColors.duoTextLight,
                ),
              ),
            ],
          ),

          // No audio warning
          if (!hasAudio) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.duoOrange),
                const SizedBox(width: 6),
                Text(
                  'Audio tez kunda qo\'shiladi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Question + answers ───────────────────────────────────────────────────
  Widget _buildQuestionCard(bool isDark, AppLocalizations l) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    return GamifiedCard(
      color: isDark
          ? AppColors.duoCardGray.withValues(alpha: 0.1)
          : Colors.white,
      shadowColor: isDark ? Colors.black26 : _accentShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            final label = String.fromCharCode(65 + i);
            final isCorrectOption = option == _current.correctAnswer;
            final isSelected = _selectedAnswer == option;
            final isCorrectResult = _answered && isCorrectOption;
            final isWrongResult =
                _answered && isSelected && !isCorrectOption;

            Color cardColor;
            Color borderColor;
            Color labelBg;
            Color labelText;
            Color optionText;

            if (isCorrectResult) {
              cardColor = AppColors.duoGreen
                  .withValues(alpha: isDark ? 0.15 : 0.08);
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
              cardColor = isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white;
              borderColor = isDark
                  ? Colors.white12
                  : _accentColor.withValues(alpha: 0.25);
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

        ],
      ),
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool isDark, AppLocalizations l, bool isLast) {
    final canGoBack = _currentIndex > 0;
    final canGoNext = true; // Allow skipping without answering
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
