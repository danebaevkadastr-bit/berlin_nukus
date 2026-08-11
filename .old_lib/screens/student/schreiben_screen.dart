import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/schreiben_task.dart';
import '../../services/ai_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/schreiben_tasks.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/level_picker_sheet.dart';

class SchreibenScreen extends StatefulWidget {
  const SchreibenScreen({super.key});

  @override
  State<SchreibenScreen> createState() => _SchreibenScreenState();
}

class _SchreibenScreenState extends State<SchreibenScreen> {
  static Color get _accent => ThemeManager.accent;
  static Color get _accentShadow => ThemeManager.accentShadow;

  final _answerController = TextEditingController();
  final _taskScrollController = ScrollController();
  final _mainScrollController = ScrollController();

  int _currentIndex = 0;
  String _level = 'B1';
  bool _isEvaluating = false;
  String? _evaluation;
  bool _showSampleHint = false;

  List<SchreibenTask> get _tasks => schreibenTasksForLevel(_level);
  int get _taskCount => _tasks.length;

  @override
  void dispose() {
    _answerController.dispose();
    _taskScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  SchreibenTask get _task => _tasks[_currentIndex];

  Color _levelColor(String level) {
    switch (level) {
      case 'A2':
        return AppColors.duoBlue;
      case 'B1':
        return AppColors.duoOrange;
      default:
        return AppColors.duoBlue;
    }
  }

  Color _levelShadow(String level) {
    switch (level) {
      case 'A2':
        return AppColors.duoBlueShadow;
      case 'B1':
        return AppColors.duoOrangeShadow;
      default:
        return AppColors.duoBlueShadow;
    }
  }

  String _levelName(AppLocalizations l, String level) {
    switch (level) {
      case 'A2':
        return l.horenA2LevelName;
      case 'B1':
        return l.horenB1LevelName;
      default:
        return level;
    }
  }

  void _showLevelPicker(AppLocalizations l, bool isDark) async {
    final selected = await LevelPickerSheet.show(
      context: context,
      isDark: isDark,
      title: l.horenSelectLevel,
      levels: schreibenLevels,
      selectedLevel: _level,
      levelName: (lvl) => _levelName(l, lvl),
      comingSoonLabel: l.horenComingSoon,
    );
    if (selected != null) {
      _changeLevel(selected);
    }
  }

  void _changeLevel(String level) {
    if (level == _level) return;
    setState(() {
      _level = level;
      _currentIndex = 0;
      _answerController.clear();
      _evaluation = null;
      _showSampleHint = false;
    });
    _scrollTaskPickerTo(0);
  }

  int _wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  void _goToTask(int index) {
    if (index < 0 || index >= _taskCount || index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _answerController.clear();
      _evaluation = null;
      _showSampleHint = false;
    });
    _scrollTaskPickerTo(index);
  }

  void _scrollTaskPickerTo(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_taskScrollController.hasClients) return;
      const itemWidth = 44.0;
      final offset = (index * itemWidth).clamp(
        0.0,
        _taskScrollController.position.maxScrollExtent,
      );
      _taskScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submitAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || _isEvaluating) return;

    setState(() {
      _isEvaluating = true;
      _evaluation = null;
    });

    try {
      final result = await AIService.evaluateSchreiben(
        taskText: _task.task,
        points: _task.points,
        style: _task.style,
        minWords: _task.minWords,
        answer: answer,
        wordCount: _wordCount(answer),
        level: _level,
        letter: _task.letter,
      );
      if (!mounted) return;
      setState(() {
        _evaluation = result;
        _isEvaluating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isEvaluating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final words = _wordCount(_answerController.text);
    final levelColor = _levelColor(_level);
    final levelShadow = _levelShadow(_level);

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
            title: GestureDetector(
              onTap: () => _showLevelPicker(l, isDark),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l.schreibenTitle} – $_level',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                ],
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: GamifiedCard(
                  color: levelColor,
                  shadowColor: levelShadow,
                  shadowDepth: 6,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note_rounded,
                          color: Colors.white, size: 40),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l.schreibenTitle} – $_level',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _levelName(l, _level),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showLevelPicker(l, isDark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _level,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.swap_vert_rounded,
                                  color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildTaskPicker(isDark, levelColor, levelShadow),
              Expanded(
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTaskCard(context, isDark),
                      const SizedBox(height: 16),
                      _buildWritingCard(context, isDark, words),
                      if (_evaluation != null) ...[
                        const SizedBox(height: 16),
                        _buildEvaluationCard(context, isDark),
                      ],
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskPicker(bool isDark, Color levelColor, Color levelShadow) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GamifiedCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: levelColor,
            shadowColor: levelShadow,
            shadowDepth: 4,
            borderRadius: 20,
            child: Text(
              '${_currentIndex + 1} / $_taskCount',
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
                controller: _taskScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _taskCount,
                itemBuilder: (context, i) {
                  final selected = i == _currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _goToTask(i),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? levelColor
                              : (isDark
                                  ? AppColors.duoCardGray.withValues(alpha: 0.2)
                                  : Colors.white),
                          border: Border.all(
                            color: selected
                                ? levelShadow
                                : (isDark
                                    ? Colors.white24
                                    : AppColors.duoCardGrayShadow),
                            width: 2,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: levelShadow,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : (isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: AppColors.duoCardGrayShadow
                                            .withValues(alpha: 0.4),
                                        offset: const Offset(0, 2),
                                      ),
                                    ]),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: selected
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : AppColors.duoTextDark),
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

  Widget _buildTaskCard(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context);
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final innerBg = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.5)
        : AppColors.duoBackground;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.duoCardGrayShadow.withValues(alpha: 0.35);

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l.aufgabe} ${_task.id}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accent.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.duoGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    schreibenGeneralHint,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_task.letter != null && _task.letter!.isNotEmpty) ...[
            _buildLetterCard(context, isDark),
            const SizedBox(height: 14),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: innerBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _task.task,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(_task.points.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.duoOrange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.duoOrangeShadow,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _task.points[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.style_outlined,
                        size: 14, color: textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${l.styleLabel} ${_task.style}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _showSampleHint = !_showSampleHint),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 18, color: textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    l.showSampleAnswer,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showSampleHint
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_showSampleHint)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l.sampleAnswerComingSoon,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(BuildContext context, bool isDark) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final letterBg = isDark
        ? AppColors.duoBlue.withValues(alpha: 0.12)
        : AppColors.duoBlue.withValues(alpha: 0.06);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: letterBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.duoBlue.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline_rounded,
                  size: 18, color: AppColors.duoBlue),
              const SizedBox(width: 8),
              Text(
                'Brief',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _task.letter!,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingCard(BuildContext context, bool isDark, int words) {
    final l = AppLocalizations.of(context);
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final inputBg = isDark
        ? const Color(0xFF1E293B)
        : AppColors.duoBackground;
    final canSend = _answerController.text.trim().isNotEmpty && !_isEvaluating;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.duoPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                bottom: BorderSide(color: AppColors.duoPurpleShadow, width: 3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  l.aiPoweredEvaluation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      l.yourAnswer,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$words ${l.wordCountLabel} / ~${_task.minWords}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: words >= _task.minWords
                            ? AppColors.duoGreen
                            : textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _answerController,
                  onChanged: (_) => setState(() {}),
                  maxLines: 8,
                  minLines: 6,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ihr Brief:',
                    hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white12
                            : AppColors.duoCardGrayShadow.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white12
                            : AppColors.duoCardGrayShadow.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _accent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GamifiedCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: canSend ? _accent : _accent.withValues(alpha: 0.4),
                    shadowColor: _accentShadow,
                    shadowDepth: canSend ? 5 : 2,
                    borderRadius: 16,
                    onTap: canSend ? _submitAnswer : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isEvaluating)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(Icons.send_rounded,
                              color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          _isEvaluating ? l.evaluating : l.submit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    l.writeAnswerHint,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context);
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoGreenShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.duoGreen, size: 22),
              const SizedBox(width: 8),
              Text(
                l.evaluation,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.duoGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            _evaluation!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context);
    final canGoBack = _currentIndex > 0;
    final canGoNext = _currentIndex < _taskCount - 1;
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
              onTap: canGoBack ? () => _goToTask(_currentIndex - 1) : null,
              child: Center(
                child: Text(
                  l.backBtn,
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
              color: canGoNext ? _accent : _accent.withValues(alpha: 0.35),
              shadowColor: _accentShadow,
              shadowDepth: canGoNext ? 5 : 2,
              borderRadius: 16,
              onTap: canGoNext ? () => _goToTask(_currentIndex + 1) : null,
              child: Center(
                child: Text(
                  l.next,
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
