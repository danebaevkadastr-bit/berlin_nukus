// B1 Mock Test — Hörverstehen section view.
//
// Mirrors `horen_question_screen`'s listening UX (per-question `audioplayers`
// playback, a seekable progress bar, and an audio-error retry affordance) but
// adapts it to the mock-test flow:
//   * It renders the [SelectedHorenTest] frozen onto one Teil of the assembled
//     attempt and records the student's selections through
//     [MockTestController.selectAnswer], keyed by `(teilIndex, questionIndex)`.
//   * It does **not** reveal correctness during the attempt — auto-grading is
//     deferred to the scorer at completion (Requirement 7.1) — so a selected
//     option is only highlighted, never marked right or wrong.
//   * Teil-level navigation is owned by the runner; this view only navigates
//     between the Questions inside its Teil. When the runner drives an active
//     question index (via [MockQuestionStrip]) the view follows it and hides its
//     own inline picker; when no index is supplied it falls back to its own
//     inline picker. The shared audio player stays at the top so the German
//     exam content is never truncated (Requirement 4.5).
//
// App-authored interface text is localized through [AppLocalizations]; the
// German exam content (questions, options) stays in German per the
// exam-content localization rule (Requirement 11.2).

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import '../../horen/horen_data.dart';
import '../mock_test_controller.dart';
import '../model/mock_test_attempt.dart';

/// Renders the Hörverstehen Teil at [teilIndex] of the attempt held by
/// [controller]: per-question audio playback plus the answer options, recording
/// each selection on the controller.
class HorenMockView extends StatefulWidget {
  final MockTestController controller;
  final int teilIndex;

  /// The question to display, selected by the runner's [MockQuestionStrip]. When
  /// `null` the view shows its own inline question picker and owns the active
  /// question itself. When supplied, the view follows this index and hides the
  /// inline picker (the runner's strip is the single source of truth).
  final int? activeQuestionIndex;

  const HorenMockView({
    super.key,
    required this.controller,
    required this.teilIndex,
    this.activeQuestionIndex,
  });

  @override
  State<HorenMockView> createState() => _HorenMockViewState();
}

class _HorenMockViewState extends State<HorenMockView> {
  // Audio playback state (mirrors horen_question_screen).
  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  bool _audioError = false;
  final List<StreamSubscription> _subscriptions = [];

  /// Index of the Question within this Teil currently being shown.
  int _currentIndex = 0;

  MockTestController get _controller => widget.controller;

  SelectedHorenTest get _selected =>
      _controller.attempt.teile[widget.teilIndex].test as SelectedHorenTest;

  List<HorenQuestion> get _questions => _selected.questions;

  HorenQuestion get _current => _questions[_currentIndex];

  Color get _accentColor => ThemeManager.accent;
  Color get _accentShadow => ThemeManager.accentShadow;

  bool get _isPlaying => _playerState == PlayerState.playing;

  AnswerKey _keyFor(int questionIndex) =>
      AnswerKey(widget.teilIndex, questionIndex);

  String? get _selectedAnswer => _controller.answerFor(_keyFor(_currentIndex));

  @override
  void initState() {
    super.initState();
    // Follow the runner-driven active question when one is supplied.
    final initial = widget.activeQuestionIndex ?? 0;
    if (initial >= 0 && initial < _questions.length) {
      _currentIndex = initial;
    }
    _setupAudioListeners();
    _loadAudio();
  }

  @override
  void didUpdateWidget(covariant HorenMockView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the runner changes the active question (or the Teil), follow it and
    // reload the audio source if necessary.
    final target = widget.activeQuestionIndex;
    if (target != null &&
        target != _currentIndex &&
        target >= 0 &&
        target < _questions.length) {
      _goToQuestion(target);
    }
  }

  void _setupAudioListeners() {
    _subscriptions.add(_player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    }));
    _subscriptions.add(_player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    }));
    _subscriptions.add(_player.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    }));
    _subscriptions.add(_player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = _duration);
    }));
  }

  Future<void> _loadAudio() async {
    final url = _current.audioUrl;
    if (url.isEmpty) return;
    setState(() {
      _isLoading = true;
      _audioError = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    try {
      await _player.stop();
      await _player.setSourceUrl(url);
      final dur = await _player.getDuration();
      if (mounted && dur != null) setState(() => _duration = dur);
    } catch (e) {
      debugPrint('[HorenMock] Audio yuklab bo\'lmadi: $e');
      if (mounted) setState(() => _audioError = true);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _togglePlay() async {
    if (_current.audioUrl.isEmpty) return;
    // Retry once if a previous load/playback failed.
    if (_audioError) {
      await _loadAudio();
      if (_audioError) return;
    }
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (_position >= _duration && _duration > Duration.zero) {
          await _player.seek(Duration.zero);
        }
        await _player.resume();
      }
    } catch (e) {
      debugPrint('[HorenMock] Audio ijro xatosi: $e');
      if (mounted) setState(() => _audioError = true);
    }
  }

  Future<void> _seekTo(double ratio) async {
    if (_duration == Duration.zero) return;
    final target = Duration(
      milliseconds: (ratio * _duration.inMilliseconds).round(),
    );
    await _player.seek(target);
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) {
      return;
    }
    final previousUrl = _current.audioUrl;
    setState(() => _currentIndex = index);

    // Only reload when the audio source actually changes.
    final newUrl = _questions[index].audioUrl;
    if (newUrl != previousUrl) {
      setState(() {
        _isLoading = false;
        _audioError = false;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      _loadAudio();
    }
  }

  void _selectAnswer(String option) {
    _controller.selectAnswer(_keyFor(_currentIndex), option);
    setState(() {}); // refresh the highlighted selection
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _player.dispose();
    super.dispose();
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

    // Hide the inline picker when the runner's MockQuestionStrip drives the
    // active question (it is then the single source of truth, R4.1/R4.2).
    final showInlinePicker =
        widget.activeQuestionIndex == null && _questions.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showInlinePicker) _buildQuestionPicker(isDark),
        if (showInlinePicker) const SizedBox(height: 12),
        _buildAudioCard(isDark, l),
        const SizedBox(height: 16),
        _buildQuestionCard(isDark, l),
      ],
    );
  }

  // ── Question picker (within the Teil) ──────────────────────────────────────
  Widget _buildQuestionPicker(bool isDark) {
    return Row(
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
              scrollDirection: Axis.horizontal,
              itemCount: _questions.length,
              itemBuilder: (context, i) => _buildQuestionButton(i, isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionButton(int i, bool isDark) {
    final selected = i == _currentIndex;
    final answered = _controller.answerFor(_keyFor(i)) != null;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (selected) {
      bgColor = _accentColor;
      borderColor = _accentShadow;
      textColor = Colors.white;
    } else if (answered) {
      bgColor = AppColors.duoGreen.withValues(alpha: 0.2);
      borderColor = AppColors.duoGreen;
      textColor = AppColors.duoGreen;
    } else {
      bgColor =
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.2) : Colors.white;
      borderColor = isDark ? Colors.white24 : AppColors.duoCardGrayShadow;
      textColor = isDark ? Colors.white70 : AppColors.duoTextDark;
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
                ? [BoxShadow(color: _accentShadow, offset: const Offset(0, 3))]
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
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
        ),
      ),
    );
  }

  // ── Audio player ───────────────────────────────────────────────────────────
  Widget _buildAudioCard(bool isDark, AppLocalizations l) {
    final hasAudio = _current.audioUrl.isNotEmpty;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : _accentShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Play / pause button.
              GestureDetector(
                onTap: hasAudio ? _togglePlay : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasAudio
                        ? _accentColor
                        : (isDark
                            ? Colors.white12
                            : AppColors.duoCardGrayShadow),
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
              Text(
                _formatDuration(_position),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
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

          // No-audio notice.
          if (!hasAudio) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.duoOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.horenAudioError,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Audio-error retry affordance.
          if (hasAudio && _audioError) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: AppColors.duoRed),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.horenAudioError,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.duoRed,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _loadAudio,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.duoRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded,
                            size: 14, color: AppColors.duoRed),
                        const SizedBox(width: 4),
                        Text(
                          l.horenAudioRetry,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.duoRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Question + options ───────────────────────────────────────────────────
  Widget _buildQuestionCard(bool isDark, AppLocalizations l) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final selectedAnswer = _selectedAnswer;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
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

          // Answer options — selection is recorded but never graded here.
          ...List.generate(_current.options.length, (i) {
            final option = _current.options[i];
            final label = String.fromCharCode(65 + i);
            final isSelected = selectedAnswer == option;

            final Color cardColor;
            final Color borderColor;
            final Color labelBg;
            final Color labelText;

            if (isSelected) {
              cardColor = _accentColor.withValues(alpha: isDark ? 0.15 : 0.08);
              borderColor = _accentColor;
              labelBg = _accentColor;
              labelText = Colors.white;
            } else {
              cardColor =
                  isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
              borderColor =
                  isDark ? Colors.white12 : _accentColor.withValues(alpha: 0.25);
              labelBg = _accentColor.withValues(alpha: 0.15);
              labelText = _accentColor;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _selectAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.radio_button_checked_rounded,
                            color: _accentColor, size: 20)
                      else
                        Icon(Icons.radio_button_unchecked_rounded,
                            color: isDark
                                ? Colors.white24
                                : AppColors.duoCardGrayShadow,
                            size: 20),
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
}
