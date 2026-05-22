import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/schreiben_task.dart';
import '../../services/ai_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/schreiben_tasks.dart';
import '../../utils/theme_manager.dart';

class SchreibenScreen extends StatefulWidget {
  const SchreibenScreen({super.key});

  @override
  State<SchreibenScreen> createState() => _SchreibenScreenState();
}

class _SchreibenScreenState extends State<SchreibenScreen> {
  static const _bgDark = Color(0xFF121826);
  static const _cardDark = Color(0xFF1E293B);
  static const _accentBlue = Color(0xFF3B82F6);
  static const _inactiveCircle = Color(0xFF334155);

  final _answerController = TextEditingController();
  final _taskScrollController = ScrollController();
  final _mainScrollController = ScrollController();

  int _currentIndex = 0;
  bool _isEvaluating = false;
  String? _evaluation;
  bool _showSampleHint = false;

  @override
  void dispose() {
    _answerController.dispose();
    _taskScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  SchreibenTask get _task => schreibenTaskByIndex(_currentIndex);

  int _wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  void _goToTask(int index) {
    if (index < 0 || index >= schreibenTaskCount || index == _currentIndex) return;
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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final bg = isDark ? _bgDark : AppColors.duoBackground;
    final card = isDark ? _cardDark : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final words = _wordCount(_answerController.text);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(textPrimary),
            Expanded(
              child: SingleChildScrollView(
                controller: _mainScrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTaskCard(card, textPrimary, textSecondary),
                    const SizedBox(height: 16),
                    _buildWritingCard(card, textPrimary, textSecondary, words),
                    if (_evaluation != null) ...[
                      const SizedBox(height: 16),
                      _buildEvaluationCard(card, textPrimary),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _accentBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentIndex + 1} / $schreibenTaskCount',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: _taskScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: schreibenTaskCount,
                itemBuilder: (context, i) {
                  final selected = i == _currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _goToTask(i),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? _accentBlue : _inactiveCircle,
                          border: Border.all(
                            color: selected
                                ? _accentBlue
                                : Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : Colors.white60,
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

  Widget _buildTaskCard(Color card, Color textPrimary, Color textSecondary) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUESTION : ${_task.id}',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentBlue.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: _accentBlue.withValues(alpha: 0.9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    schreibenGeneralHint,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _task.task,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.duoOrange,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.nunito(
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
                            style: GoogleFonts.nunito(
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.style_outlined,
                        size: 14, color: textSecondary.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'Stil: ${_task.style}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _showSampleHint = !_showSampleHint),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 18, color: textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Show sample answer',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
          ),
          if (_showSampleHint)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Beispielantwort tez orada qo\'shiladi.',
                style: GoogleFonts.nunito(
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

  Widget _buildWritingCard(
    Color card,
    Color textPrimary,
    Color textSecondary,
    int words,
  ) {
    final canSend = _answerController.text.trim().isNotEmpty && !_isEvaluating;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'AI-Powered Evaluation',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Your Answer',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$words Wörter / ~${_task.minWords}',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: textPrimary,
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ihr Brief:',
                    hintStyle: GoogleFonts.nunito(
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: canSend ? _submitAnswer : null,
                    icon: _isEvaluating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(
                      _isEvaluating ? 'Tekshirilmoqda...' : 'Yuborish',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _accentBlue.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Write your answer to enable AI evaluation.',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: textSecondary.withValues(alpha: 0.7),
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

  Widget _buildEvaluationCard(Color card, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.duoGreen.withValues(alpha: 0.3)),
      ),
      child: SelectableText(
        _evaluation!,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final canGoBack = _currentIndex > 0;
    final canGoNext = _currentIndex < schreibenTaskCount - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: ThemeManager.isDark ? _cardDark : Colors.white,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: canGoBack ? () => _goToTask(_currentIndex - 1) : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                disabledForegroundColor: Colors.white24,
                side: BorderSide(
                  color: canGoBack
                      ? Colors.white30
                      : Colors.white.withValues(alpha: 0.1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: canGoNext ? () => _goToTask(_currentIndex + 1) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _accentBlue.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Next',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
