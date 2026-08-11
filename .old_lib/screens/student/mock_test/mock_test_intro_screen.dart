// B1 Mock Test — intro screen.
//
// Presents the official TELC Deutsch B1 overview before an attempt: the total
// duration, the per-Section breakdown (questions + time), and a short list of
// important notes, then a Cancel / Start Test action bar. Pressing "Start Test"
// assembles a fresh attempt via [MockTestAssembler.assemble] and hands the
// frozen attempt to a [MockTestController] that drives the
// [MockTestRunnerScreen]. If the source content is insufficient, assembly
// throws [MockAssemblyException] and the screen shows a localized message
// instead of starting.
//
// All app-authored text is routed through [AppLocalizations]. The German exam
// section names (Lesen & Sprachbausteine, Hören, Schreiben, Sprechen) stay
// German regardless of the active locale, per the localization requirements.

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import 'mock_test_controller.dart';
import 'mock_test_history_screen.dart';
import 'mock_test_runner_screen.dart';
import 'model/mock_test_assembler.dart';
import 'model/mock_test_exceptions.dart';
import 'model/mock_test_structure.dart';
import 'model/mock_test_timing.dart';

/// One row of the Section breakdown list. [name] is German exam content.
class _SectionRow {
  final String name;
  final int questions;
  final Duration duration;
  const _SectionRow(this.name, this.questions, this.duration);
}

/// Intro/overview screen for the B1 Mock Test.
class MockTestIntroScreen extends StatelessWidget {
  const MockTestIntroScreen({super.key});

  /// The Section breakdown shown on the overview. Leseverstehen and
  /// Sprachbausteine are merged into one row (they share a 90-minute block).
  static List<_SectionRow> get _sections {
    final leseSprach =
        MockTestStructure.questionCountForSection(MockSection.leseverstehen) +
            MockTestStructure
                .questionCountForSection(MockSection.sprachbausteine);
    return [
      _SectionRow('Lesen & Sprachbausteine', leseSprach,
          MockTestTiming.leseSprachbausteine),
      _SectionRow(
          'Hören',
          MockTestStructure
              .questionCountForSection(MockSection.hoerverstehen),
          MockTestTiming.hoeren),
      _SectionRow(
          'Schreiben',
          MockTestStructure
              .questionCountForSection(MockSection.schriftlicherAusdruck),
          MockTestTiming.schreiben),
      _SectionRow(
          'Sprechen',
          MockTestStructure
              .questionCountForSection(MockSection.muendlicherAusdruck),
          MockTestTiming.sprechen),
    ];
  }

  /// Assembles a fresh attempt and navigates into the runner. On
  /// [MockAssemblyException] shows a localized message and does not start.
  void _start(BuildContext context) {
    final l = AppLocalizations.of(context);
    try {
      final attempt = MockTestAssembler.assemble(rng: Random());
      final controller = MockTestController(attempt: attempt);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MockTestRunnerScreen(controller: controller),
        ),
      );
    } on MockAssemblyException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.mockTestCannotAssemble),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, accent, _) {
        final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
        final textSecondary =
            isDark ? Colors.white70 : AppColors.duoTextLight;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: AppBar(
            title: Text(
              l.mockTestIntroTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textPrimary),
            actions: [
              IconButton(
                icon: Icon(Icons.history_rounded, color: textPrimary),
                tooltip: 'Tarix',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MockTestHistoryScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.mockTestIntroSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Duration ──────────────────────────────────────────
                      _sectionHeader(
                        icon: Icons.schedule_rounded,
                        iconColor: AppColors.duoOrange,
                        label: l.mockTestDurationTitle,
                        textColor: textPrimary,
                      ),
                      const SizedBox(height: 10),
                      _durationCard(isDark, l),
                      const SizedBox(height: 24),

                      // ── Sections ──────────────────────────────────────────
                      _sectionHeader(
                        icon: Icons.layers_rounded,
                        iconColor: AppColors.duoGreen,
                        label: l.mockTestSectionsHeader,
                        textColor: textPrimary,
                      ),
                      const SizedBox(height: 10),
                      for (final row in _sections) ...[
                        _sectionCard(isDark, l, row, textPrimary, textSecondary),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 14),

                      // ── Important Notes ───────────────────────────────────
                      _sectionHeader(
                        icon: Icons.error_rounded,
                        iconColor: AppColors.duoRed,
                        label: l.mockTestImportantNotes,
                        textColor: textPrimary,
                      ),
                      const SizedBox(height: 12),
                      _note(Icons.timer_outlined, l.mockTestNoteTimer,
                          textSecondary),
                      _note(Icons.swap_horiz_rounded, l.mockTestNoteNavigate,
                          textSecondary),
                      _note(Icons.done_all_rounded,
                          l.mockTestNoteAutoSubmit, textSecondary),
                      _note(Icons.wifi_rounded, l.mockTestNoteInternet,
                          textSecondary),
                      _note(Icons.volume_off_rounded, l.mockTestNoteQuiet,
                          textSecondary),
                    ],
                  ),
                ),
              ),
              _actionBar(context, isDark, l, accent, textPrimary),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _durationCard(bool isDark, AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.duoOrange.withValues(alpha: isDark ? 0.14 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.duoOrange.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom_rounded,
              size: 26, color: AppColors.duoOrange),
          const SizedBox(width: 14),
          Text(
            l.minutesShort(MockTestTiming.totalDuration.inMinutes),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.duoOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    bool isDark,
    AppLocalizations l,
    _SectionRow row,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.duoCardGray.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.duoCardGrayShadow.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${l.mockTestQuestionsCount(row.questions)}  •  '
            '${l.minutesShort(row.duration.inMinutes)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(IconData icon, String text, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l,
    AccentPreset accent,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2730) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(
                  color: isDark ? Colors.white24 : AppColors.duoCardGrayShadow,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l.mockTestCancel,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _start(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l.mockTestStartTest,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
