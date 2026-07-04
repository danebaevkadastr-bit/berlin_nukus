// B1 Mock Test — Leseverstehen / Sprachbausteine section view.
//
// Renders the [SelectedLesenTest] chosen for one Teil of an assembled attempt,
// mirroring the rendering of `lesen_question_screen` (shared/per-question
// passage, optional advertisement image, and answer options) but adapted to the
// mock-test flow:
//
//   * When the runner drives an active question index (via [MockQuestionStrip]),
//     it presents the shared Teil content (reading text / advertisement image)
//     at the top — kept intact so the German exam content is never truncated
//     (Requirement 4.5) — followed by the single active question. When no
//     active index is supplied it falls back to presenting *every* question of
//     the selected Test in a single scroll. Navigation between Teile (and the
//     active question) is owned by the runner, not here.
//   * Answers are recorded on the [MockTestController] via `selectAnswer` and
//     read back via `answerFor`, keyed by `AnswerKey(teilIndex, questionIndex)`,
//     so a selection is preserved across navigation.
//   * Correctness is intentionally **not** revealed during the attempt — Lesen
//     is auto-graded only when the attempt is completed (Requirement 7.1). The
//     view shows the selected option highlighted, never a right/wrong state.
//
// App-authored labels (e.g. "Text", "Anzeige", "Frage") are localized through
// [AppLocalizations]; the German exam content (passages, prompts, options) is
// presented verbatim in German regardless of the active locale
// (Requirements 11.1, 11.2).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/theme_manager.dart';
import '../../../../widgets/gamified_card.dart';
import '../../lesen/lesen_data.dart';
import '../mock_test_controller.dart';
import '../model/mock_test_attempt.dart';

/// Interactive view for a single Leseverstehen / Sprachbausteine Teil.
///
/// Reads the [SelectedLesenTest] at [teilIndex] from the controller's frozen
/// attempt and records the student's option selections back onto the
/// controller. Rebuilds whenever the controller notifies (e.g. after a
/// selection) so the highlighted option stays in sync.
class LesenMockView extends StatelessWidget {
  final MockTestController controller;
  final int teilIndex;

  /// The question to display, selected by the runner's [MockQuestionStrip]. When
  /// `null` (or out of range) the view falls back to rendering every question of
  /// the Teil in a single scroll. The shared Teil content (reading text /
  /// advertisement image) is always shown above the active question.
  final int? activeQuestionIndex;

  const LesenMockView({
    super.key,
    required this.controller,
    required this.teilIndex,
    this.activeQuestionIndex,
  });

  SelectedLesenTest get _test =>
      controller.attempt.teile[teilIndex].test as SelectedLesenTest;

  /// Whether the test-level text uses Sprachbausteine `___(N)___` blanks.
  static bool _hasBlanks(String? text) =>
      text != null && RegExp(r'___\((\d+)\)___').hasMatch(text);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, _, __) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final test = _test;
    final hasBlanks = _hasBlanks(test.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Test-level image (e.g. the advertisement sheet for Teil 3).
        if (test.imageUrl != null && test.imageUrl!.isNotEmpty)
          _ImageCard(url: test.imageUrl!, isDark: isDark, label: l.lesenAnzeige),
        // Test-level reading text. For Sprachbausteine it carries `___(N)___`
        // blanks that are filled inline as the student picks options.
        if (test.text != null && test.text!.isNotEmpty)
          _TextCard(
            text: test.text!,
            isDark: isDark,
            label: l.lesenText,
            blankBuilder: hasBlanks
                ? (blankNumber) => _buildBlankChip(blankNumber, isDark)
                : null,
          ),
        const SizedBox(height: 16),
        // The questions to render: a single active question when the runner
        // drives [activeQuestionIndex] (the shared text/image above stays
        // intact — Requirement 4.5), otherwise every question of the Teil.
        for (final i in _visibleQuestionIndices(test.questions.length))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildQuestionCard(
              context,
              question: test.questions[i],
              questionIndex: i,
              isDark: isDark,
              l: l,
              useBlankLabel: hasBlanks,
            ),
          ),
      ],
    );
  }

  /// Indices of the questions to render. When [activeQuestionIndex] is a valid
  /// index, only that question is shown (the runner owns question navigation via
  /// [MockQuestionStrip]); otherwise all questions are shown in source order.
  List<int> _visibleQuestionIndices(int questionCount) {
    final active = activeQuestionIndex;
    if (active != null && active >= 0 && active < questionCount) {
      return [active];
    }
    return [for (var i = 0; i < questionCount; i++) i];
  }

  /// An inline chip rendered inside a Sprachbausteine passage in place of a
  /// `___(N)___` blank. Shows the student's selected word once answered,
  /// otherwise the blank number.
  Widget _buildBlankChip(int blankNumber, bool isDark) {
    final accent = ThemeManager.accent;
    final questionIndex = blankNumber - 1;
    final answer = controller.answerFor(AnswerKey(teilIndex, questionIndex));
    final answered = answer != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: answered ? 0.18 : 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: answered ? accent : accent.withValues(alpha: 0.4),
          width: 1.6,
        ),
      ),
      child: Text(
        answered ? answer : '$blankNumber',
        style: TextStyle(
          fontSize: answered ? 14 : 13,
          fontWeight: FontWeight.w800,
          color: accent,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context, {
    required LesenQuestion question,
    required int questionIndex,
    required bool isDark,
    required AppLocalizations l,
    required bool useBlankLabel,
  }) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;
    final accent = ThemeManager.accent;
    final accentShadow = ThemeManager.accentShadow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Per-question passage (Teil 1 short texts, Teil 3 situations).
        if (question.passage != null && question.passage!.isNotEmpty)
          _TextCard(text: question.passage!, isDark: isDark, label: l.lesenText),
        // Per-question image, when the question carries its own.
        if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
          _ImageCard(
            url: question.imageUrl!,
            isDark: isDark,
            label: l.lesenAnzeige,
          ),
        GamifiedCard(
          color: isDark
              ? AppColors.duoCardGray.withValues(alpha: 0.1)
              : Colors.white,
          shadowColor: isDark ? Colors.black26 : accentShadow,
          shadowDepth: 5,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                useBlankLabel
                    ? '${questionIndex + 1}'
                    : '${l.lesenQuestion} ${questionIndex + 1}',
                style: TextStyle(
                  fontSize: useBlankLabel ? 15 : 12,
                  fontWeight: FontWeight.w900,
                  color: useBlankLabel ? accent : textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              if (question.prompt.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  question.prompt,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildOptions(question, questionIndex, isDark),
            ],
          ),
        ),
      ],
    );
  }

  /// Whether every option is a single character (Teil 3 letter choices a–l, x).
  bool _isLetterChoice(LesenQuestion q) =>
      q.options.isNotEmpty && q.options.every((o) => o.length == 1);

  Widget _buildOptions(LesenQuestion question, int questionIndex, bool isDark) {
    final key = AnswerKey(teilIndex, questionIndex);
    final selected = controller.answerFor(key);

    if (_isLetterChoice(question)) {
      return _buildLetterGrid(question, key, selected, isDark);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildOptionTile(
              option: question.options[i],
              label: String.fromCharCode(97 + i), // a, b, c ...
              isSelected: selected == question.options[i],
              isDark: isDark,
              onTap: () => controller.selectAnswer(key, question.options[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String option,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final accent = ThemeManager.accent;
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;

    final Color cardColor;
    final Color borderColor;
    final Color labelBg;
    final Color labelText;
    if (isSelected) {
      cardColor = accent.withValues(alpha: isDark ? 0.15 : 0.08);
      borderColor = accent;
      labelBg = accent;
      labelText = Colors.white;
    } else {
      cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
      borderColor = isDark ? Colors.white12 : accent.withValues(alpha: 0.25);
      labelBg = accent.withValues(alpha: 0.15);
      labelText = accent;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterGrid(
    LesenQuestion question,
    AnswerKey key,
    String? selected,
    bool isDark,
  ) {
    final accent = ThemeManager.accent;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: question.options.map((option) {
        final isSelected = selected == option;
        final isX = option == 'x';

        final Color bg;
        final Color border;
        final Color fg;
        if (isSelected) {
          bg = accent.withValues(alpha: isDark ? 0.2 : 0.1);
          border = accent;
          fg = accent;
        } else {
          bg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
          border = isDark ? Colors.white12 : accent.withValues(alpha: 0.25);
          fg = isDark ? Colors.white : AppColors.duoTextDark;
        }

        return GestureDetector(
          onTap: () => controller.selectAnswer(key, option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isX ? null : 48,
            height: 48,
            padding:
                isX ? const EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 2),
            ),
            child: Text(
              isX ? '✕' : option,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// A reading-text card. When [blankBuilder] is provided, `___(N)___` markers in
/// [text] are replaced by inline widgets (used for Sprachbausteine blanks);
/// otherwise the text is shown as selectable plain text.
class _TextCard extends StatelessWidget {
  final String text;
  final bool isDark;
  final String label;
  final Widget Function(int blankNumber)? blankBuilder;

  const _TextCard({
    required this.text,
    required this.isDark,
    required this.label,
    this.blankBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ThemeManager.accent;
    final accentShadow = ThemeManager.accentShadow;
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    final baseStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.7,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamifiedCard(
        color:
            isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
        shadowColor: isDark ? Colors.black26 : accentShadow,
        shadowDepth: 5,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (blankBuilder != null)
              Text.rich(
                TextSpan(children: _buildSpans(baseStyle)),
                style: baseStyle,
              )
            else
              SelectableText(text, style: baseStyle),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildSpans(TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'___\((\d+)\)___');
    var last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      final blankNumber = int.parse(match.group(1)!);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: blankBuilder!(blankNumber),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans;
  }
}

/// An advertisement / image card with a tap-to-zoom full-screen viewer.
class _ImageCard extends StatelessWidget {
  final String url;
  final bool isDark;
  final String label;

  const _ImageCard({
    required this.url,
    required this.isDark,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ThemeManager.accent;
    final accentShadow = ThemeManager.accentShadow;
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamifiedCard(
        color:
            isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
        shadowColor: isDark ? Colors.black26 : accentShadow,
        shadowDepth: 5,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_rounded, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Icon(Icons.zoom_in_rounded,
                    size: 18,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _openViewer(context),
              child: Hero(
                tag: url,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    placeholder: (context, _) => Container(
                      height: 220,
                      color: isDark ? Colors.white10 : AppColors.duoBackground,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: accent,
                      ),
                    ),
                    errorWidget: (context, _, __) => Container(
                      height: 160,
                      color: isDark ? Colors.white10 : AppColors.duoBackground,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image_rounded,
                              size: 36, color: AppColors.duoRed),
                          const SizedBox(height: 8),
                          Text(
                            l.lesenImageError,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.duoRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _ImageViewer(imageUrl: url),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

/// Full-screen, pinch-to-zoom image viewer.
class _ImageViewer extends StatelessWidget {
  final String imageUrl;

  const _ImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, _) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, _, __) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
