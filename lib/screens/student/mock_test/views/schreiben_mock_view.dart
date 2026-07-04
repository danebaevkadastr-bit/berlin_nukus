// B1 Mock Test — Schriftlicher Ausdruck (Schreiben) section view.
//
// O'quvchi yozadi va ketadi. Tekshirish natija ekraniga o'tishdan
// OLDIN runner tomonidan chaqiriladi (background'da).
// Test davomida hech qanday kutish bo'lmaydi.

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/schreiben_task.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/theme_manager.dart';
import '../../../../widgets/gamified_card.dart';
import '../mock_test_controller.dart';
import '../model/mock_test_attempt.dart';

class SchreibenMockView extends StatefulWidget {
  final MockTestController controller;
  final int teilIndex;

  const SchreibenMockView({
    super.key,
    required this.controller,
    required this.teilIndex,
  });

  @override
  State<SchreibenMockView> createState() => _SchreibenMockViewState();
}

class _SchreibenMockViewState extends State<SchreibenMockView> {
  final _answerController = TextEditingController();

  MockTestController get _controller => widget.controller;

  SchreibenTask get _task {
    final test = _controller.attempt.teile[widget.teilIndex].test;
    return (test as SelectedSchreibenTest).task;
  }

  @override
  void initState() {
    super.initState();
    // Saqlangan javobni tiklash (agar bor bo'lsa)
    final saved = _controller.schreibenAnswer;
    if (saved != null && saved.isNotEmpty) {
      _answerController.text = saved;
    }
    _answerController.addListener(_saveAnswer);
  }

  void _saveAnswer() {
    _controller.recordSchreibenAnswer(_answerController.text);
  }

  @override
  void dispose() {
    _answerController.removeListener(_saveAnswer);
    _answerController.dispose();
    super.dispose();
  }

  int _wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final task = _task;
    final words = _wordCount(_answerController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTaskCard(context, isDark, l, task),
        const SizedBox(height: 16),
        _buildWritingCard(context, isDark, l, task, words),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, bool isDark, AppLocalizations l, SchreibenTask task) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final innerBg = isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : AppColors.duoBackground;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.duoCardGrayShadow.withValues(alpha: 0.35);

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l.aufgabe} ${task.id}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                  color: textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 14),
          if (task.letter != null && task.letter!.isNotEmpty) ...[
            _buildLetterCard(isDark, task),
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
                Text(task.task,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: textPrimary, height: 1.45)),
                const SizedBox(height: 14),
                ...List.generate(task.points.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: AppColors.duoOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.duoOrangeShadow, width: 2)),
                      alignment: Alignment.center,
                      child: Text('${i + 1}', style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(task.points[i],
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: textSecondary, height: 1.35))),
                  ]),
                )),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.style_outlined, size: 14, color: textSecondary),
                  const SizedBox(width: 6),
                  Text('${l.styleLabel} ${task.style}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textSecondary)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(bool isDark, SchreibenTask task) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.duoBlue.withValues(alpha: 0.12) : AppColors.duoBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.duoBlue.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.duoBlue),
          const SizedBox(width: 8),
          Text('Brief', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
              color: textSecondary, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        Text(task.letter!, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600,
            color: textPrimary, height: 1.5)),
      ]),
    );
  }

  Widget _buildWritingCard(BuildContext context, bool isDark, AppLocalizations l,
      SchreibenTask task, int words) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final inputBg = isDark ? const Color(0xFF1E293B) : AppColors.duoBackground;
    final accent = ThemeManager.accent;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.duoPurple,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            border: Border(bottom: BorderSide(color: AppColors.duoPurpleShadow, width: 3)),
          ),
          child: Row(children: [
            const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(l.yourAnswer, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3)),
            const Spacer(),
            Text('$words / ~${task.minWords} ${l.wordCountLabel}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                    color: words >= task.minWords ? Colors.greenAccent : Colors.white70)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _answerController,
            onChanged: (_) => setState(() {}),
            maxLines: 10,
            minLines: 6,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, height: 1.45),
            decoration: InputDecoration(
              hintText: 'Ihr Brief:',
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
              filled: true,
              fillColor: inputBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow.withValues(alpha: 0.5), width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow.withValues(alpha: 0.5), width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: accent, width: 2)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(l.writeAnswerHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
        ),
      ]),
    );
  }
}
