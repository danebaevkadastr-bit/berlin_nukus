// B1 Mock Test — runner host screen.
//
// Hosts a non-shuffling navigator over the frozen `attempt.teile` held by a
// [MockTestController]. It renders the current Teil with the redesigned chrome:
// an animated burger leading control that opens an overlay [MockOverviewDrawer],
// a countdown [SectionTimer] banner, a progress bar, a horizontal
// [MockQuestionStrip] for the active Teil's questions, the matching Section
// view, and a [MockNavBar] (Previous / Next / separate Finish). A single
// [AnimationController] drives BOTH the burger → X icon morph and the drawer
// slide/scrim in sync. Navigating between Teile only moves the controller's
// position; it never alters the assembled content (Requirement 2.5).
//
// App-authored interface text is localized through [AppLocalizations]; the
// German exam terms (Section names, "Teil") stay in German via
// [mockSectionGermanName] per the exam-content localization rule
// (Requirement 11.2).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_manager.dart';
import '../../../services/ai_service.dart';
import '../../../services/mock_test_history_service.dart';
import '../../../services/sprechen_evaluation_service.dart';
import '../../../services/student_results_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import 'mock_test_controller.dart';
import 'mock_test_result_screen.dart';
import 'mock_test_review_controller.dart';
import 'model/mock_test_attempt.dart';
import 'model/mock_test_labels.dart';
import 'model/mock_test_timing.dart';
import 'views/horen_mock_view.dart';
import 'views/lesen_mock_view.dart';
import 'views/schreiben_mock_view.dart';
import 'views/sprechen_mock_view.dart';
import 'widgets/animated_burger_icon.dart';
import 'widgets/mock_nav_bar.dart';
import 'widgets/mock_overview_drawer.dart';
import 'widgets/mock_question_strip.dart';
import 'widgets/section_timer.dart';

class MockTestRunnerScreen extends StatefulWidget {
  final MockTestController controller;

  const MockTestRunnerScreen({super.key, required this.controller});

  @override
  State<MockTestRunnerScreen> createState() => _MockTestRunnerScreenState();
}

class _MockTestRunnerScreenState extends State<MockTestRunnerScreen>
    with SingleTickerProviderStateMixin {
  MockTestController get _controller => widget.controller;

  /// One controller drives BOTH the burger → X icon morph (Requirement 3) and
  /// the overview drawer slide/scrim (Requirement 2): `0` = three lines + drawer
  /// closed, `1` = "X" + drawer open. The 300 ms duration satisfies the ≤400 ms
  /// bound (Requirement 3.4).
  late final AnimationController _drawerController;

  /// The eased `0..1` progress consumed by [AnimatedBurgerIcon] and
  /// [MockOverviewDrawer].
  late final Animation<double> _drawerAnimation;

  /// The active question within the current Teil, driven by [MockQuestionStrip].
  /// Reset to `0` whenever the controller moves to a different Teil.
  int _activeQuestion = 0;

  /// Tracks the controller's Teil index so we can detect Teil changes (from
  /// next/previous or a drawer jump) and reset [_activeQuestion].
  int _lastTeilIndex = 0;

  /// Set once the attempt has been submitted (manual finish or auto-submit) so
  /// the result screen is never pushed twice.
  bool _completed = false;

  /// Schreiben baholanmoqda — loading ko'rsatish uchun.
  bool _schreibenEvaluating = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOut,
    );
    _lastTeilIndex = _controller.currentTeilIndex;
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _drawerController.dispose();
    super.dispose();
  }

  /// Resets the active-question index to `0` when the controller changes Teil
  /// (next/previous or a drawer-driven `goToTeil`).
  void _onControllerChanged() {
    final index = _controller.currentTeilIndex;
    if (index != _lastTeilIndex) {
      _lastTeilIndex = index;
      if (_activeQuestion != 0 && mounted) {
        setState(() => _activeQuestion = 0);
      }
    }
  }

  // ── Drawer open/close (synchronized with the burger icon) ──────────────────

  void _toggleDrawer() {
    if (_drawerController.isDismissed) {
      _drawerController.forward();
    } else {
      _drawerController.reverse();
    }
  }

  void _closeDrawer() => _drawerController.reverse();

  /// Jumps to [index] (Requirement 2.3). The drawer also calls [_closeDrawer]
  /// afterwards; the active question reset is handled by [_onControllerChanged].
  void _onSelectTeil(int index) => _controller.goToTeil(index);

  // ── Question-level navigation (Next / Previous) ─────────────────────────────

  /// Advances within the current Teil one question at a time; only when the
  /// active question is the last one does it move to the next Teil. Whole-unit
  /// Teile (Schreiben/Sprechen) have no questions, so Next moves Teil directly.
  void _handleNext() {
    final count = _questionCountFor(_controller.currentTeil);
    if (count != null && _activeQuestion < count - 1) {
      setState(() => _activeQuestion++);
    } else if (!_controller.isOnFinalTeil) {
      // _onControllerChanged resets _activeQuestion to 0 for the new Teil.
      _controller.next();
    }
  }

  /// Steps back one question at a time; from the first question it moves to the
  /// previous Teil and lands on that Teil's last question.
  void _handlePrevious() {
    if (_activeQuestion > 0) {
      setState(() => _activeQuestion--);
    } else if (!_controller.isOnFirstTeil) {
      _controller.previous();
      final count = _questionCountFor(_controller.currentTeil);
      setState(() {
        _activeQuestion = (count != null && count > 0) ? count - 1 : 0;
      });
    }
  }

  // ── Exit confirmation (preserved — Requirement 6) ──────────────────────────

  /// Shows the localized leave-confirmation dialog. Returns `true` when the
  /// student confirms they want to discard the in-progress attempt.
  Future<bool> _confirmExit() async {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final bgColor = isDark ? const Color(0xFF1E2A32) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.duoTextDark;
    final secondaryColor = isDark ? Colors.white70 : AppColors.duoTextLight;
    final borderColor =
        isDark ? Colors.white12 : AppColors.duoCardGrayShadow;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor, width: 2),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        // Warning badge (Duolingo-style circular icon chip).
        icon: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.duoRed.withValues(alpha: isDark ? 0.18 : 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: AppColors.duoRed,
            size: 34,
          ),
        ),
        title: Text(
          l.mockExitTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        content: Text(
          l.mockExitMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: secondaryColor,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary destructive action — leave the attempt.
                _exitDialogButton(
                  label: l.mockExitLeave,
                  color: AppColors.duoRed,
                  shadowColor: AppColors.duoRedShadow,
                  textColor: Colors.white,
                  onTap: () => Navigator.of(ctx).pop(true),
                ),
                const SizedBox(height: 12),
                // Safe action — stay in the test.
                _exitDialogButton(
                  label: l.mockExitStay,
                  color: isDark
                      ? const Color(0xFF2A3942)
                      : AppColors.duoCardGray,
                  shadowColor: isDark
                      ? Colors.black38
                      : AppColors.duoCardGrayShadow,
                  textColor: textColor,
                  onTap: () => Navigator.of(ctx).pop(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// A full-width gamified push-button used by the exit dialog. Keeps the
  /// label text verbatim (no uppercasing) so localized strings render as
  /// authored.
  Widget _exitDialogButton({
    required String label,
    required Color color,
    required Color shadowColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(color: shadowColor, width: 3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePopInvoked(bool didPop) async {
    if (didPop) return;
    // An open drawer should close first rather than prompting to exit.
    if (!_drawerController.isDismissed) {
      _closeDrawer();
      return;
    }
    final shouldLeave = await _confirmExit();
    if (shouldLeave && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Builds the result + review and routes to the result screen
  /// (Requirement 8.5). Guarded so an auto-submit and a manual finish can never
  /// both push the result screen.
  void _completeAttempt() {
    if (_completed) return;
    _completed = true;

    // Schreiben javobini oldindan baholash (natija ko'rsatilishidan oldin)
    _evaluateAndShowResult();
  }

  Future<void> _evaluateAndShowResult() async {
    // Firebase ishga tushmagan bo'lsa (masalan testlarda) yiqilmaslik uchun.
    String? uid;
    try {
      uid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      uid = null;
    }

    // Sprechen/Schreiben AI baholari — hammasi test YAKUNIDA bajariladi
    // (test davomida o'quvchi kutmasin). Umumiy loading overlay ko'rsatamiz.
    final hasAiWork = _controller.pendingSprechenAudios.isNotEmpty ||
        _controller.sprechenFinalizer != null ||
        (_controller.schreibenAnswer?.trim().isNotEmpty ?? false);
    if (hasAiWork && mounted) {
      setState(() => _schreibenEvaluating = true);
    }

    // Teil 3 chat suhbatini yakunda baholash (agar ochiq va hali baholanmagan
    // bo'lsa).
    try {
      await _controller.sprechenFinalizer?.call();
    } catch (_) {}

    // Teil 1/2 audio javoblarini endi baholaymiz (Schreiben kabi).
    if (_controller.pendingSprechenAudios.isNotEmpty) {
      final lang = LocaleManager.code;
      for (final entry in _controller.pendingSprechenAudios.entries) {
        final audio = entry.value;
        try {
          final eval = await SprechenEvaluationService.evaluate(
            audioBytes: audio.bytes,
            mimeType: audio.mimeType,
            aufgabe: audio.aufgabe,
            level: audio.level,
            uiLangCode: lang,
          );
          if (mounted) _controller.recordSprechenEvaluation(entry.key, eval);
        } catch (_) {
          // Baholab bo'lmasa — o'sha Teil "baholanmadi" bo'lib qoladi.
        }
      }
    }
    if (!mounted) return;

    // Schreiben javobini tekshirishga yuborish
    final schreibenAnswer = _controller.schreibenAnswer;
    final schreibenTeilIndex = _findSchreibenTeilIndex();

    if (schreibenAnswer != null && schreibenAnswer.trim().isNotEmpty
        && schreibenTeilIndex >= 0) {
      // Loading ko'rsatish
      if (mounted) {
        setState(() => _schreibenEvaluating = true);
      }
      try {
        final teil = _controller.attempt.teile[schreibenTeilIndex];
        final task = (teil.test as SelectedSchreibenTest).task;
        final wordCount = schreibenAnswer.trim().isEmpty ? 0
            : schreibenAnswer.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

        final feedback = await AIService.evaluateSchreiben(
          taskText: task.task,
          points: task.points,
          style: task.style,
          minWords: task.minWords,
          answer: schreibenAnswer,
          wordCount: wordCount,
          level: 'B1',
          letter: task.letter,
        ).timeout(const Duration(seconds: 90));

        if (mounted) _controller.recordSchreibenFeedback(feedback);
      } catch (_) {
        if (mounted) _controller.recordSchreibenFeedback(null);
      }
    }

    // Barcha AI baholash tugadi — loading overlay'ni yopamiz.
    if (mounted) setState(() => _schreibenEvaluating = false);

    if (!mounted) return;

    final result = _controller.buildResult();
    final review = _controller.buildReview();

    // Firebase'ga natijani saqlash
    if (uid != null) {
      final totalScore = result.writtenPoints + result.oralPoints;
      final maxScore = result.writtenMax + result.oralMax;
      try {
        await StudentResultsService.saveResult(
          uid: uid,
          type: 'mock_test',
          title: 'Mock Test B1',
          level: 'B1',
          score: totalScore,
          total: maxScore,
          details: {
            'writtenPoints': result.writtenPoints,
            'writtenMax': result.writtenMax,
            'oralPoints': result.oralPoints,
            'oralMax': result.oralMax,
            'writtenPassed': result.writtenPassed,
            'oralPassed': result.oralPassed,
          },
        );
      } catch (e) {
        debugPrint('Mock test result save error: $e');
      }
    }

    // Mock test tarix'iga saqlash
    try {
      await MockTestHistoryService.save(result);
    } catch (e) {
      debugPrint('Mock test history save error: $e');
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MockTestResultScreen(
          result: result,
          review: review,
          schreibenAnswer: _controller.schreibenAnswer,
        ),
      ),
    );
  }

  int _findSchreibenTeilIndex() {
    for (int i = 0; i < _controller.attempt.teile.length; i++) {
      if (_controller.attempt.teile[i].test is SelectedSchreibenTest) return i;
    }
    return -1;
  }

  /// Fired when the active block's countdown reaches zero. Time-boxed sections:
  /// when a non-final block's time expires the runner auto-advances to the first
  /// Teil of the next block; when the final block's time expires the attempt is
  /// auto-submitted (Requirement: auto-submit on time-up).
  void _handleTimeUp() {
    if (_completed || !mounted) return;
    final teile = _controller.attempt.teile;
    final currentBlock =
        MockTestTiming.blockKeyOf(_controller.currentTeil.section);
    // Find the first later Teil that belongs to a different timed block.
    int nextBlockStart = -1;
    for (var i = _controller.currentTeilIndex + 1; i < teile.length; i++) {
      if (MockTestTiming.blockKeyOf(teile[i].section) != currentBlock) {
        nextBlockStart = i;
        break;
      }
    }
    if (nextBlockStart >= 0) {
      // More sections remain — move on to the next timed block.
      if (!_drawerController.isDismissed) _closeDrawer();
      _controller.goToTeil(nextBlockStart);
    } else {
      // The final block's time is up — submit the whole attempt.
      _completeAttempt();
    }
  }


  // ── Active-Teil question metadata ──────────────────────────────────────────

  /// The number of auto-graded questions in the current Teil, or `null` for a
  /// whole-unit Teil (Schreiben / Sprechen) that has no question strip.
  int? _questionCountFor(MockTeil teil) {
    return switch (teil.test) {
      SelectedLesenTest(:final questions) => questions.length,
      SelectedHorenTest(:final questions) => questions.length,
      SelectedSchreibenTest() => null,
      SelectedSprechenTest() => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handlePopInvoked(didPop),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final teil = _controller.currentTeil;
          final position = '${mockSectionGermanName(teil.section)} · '
              'Teil ${teil.teilNumber}';

          final questionCount = _questionCountFor(teil);
          // Only auto-graded Teile with more than one question get a strip;
          // whole-unit (Schreiben/Sprechen) Teile hide it gracefully.
          final showStrip = questionCount != null && questionCount > 1;
          final activeQuestion = (questionCount != null && questionCount > 0)
              ? _activeQuestion.clamp(0, questionCount - 1)
              : 0;
          // The active question index handed to the question-based views; null
          // for whole-unit Teile.
          final int? viewActiveQuestion =
              questionCount != null ? activeQuestion : null;

          final scaffold = Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Burger ↔ X morph, synced with the drawer (Requirements 2.1, 3).
              leading: AnimatedBurgerIcon(
                progress: _drawerAnimation,
                onTap: _toggleDrawer,
                tooltip: l.mockOverviewTitle,
              ),
              title: Text(
                position,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              centerTitle: true,
              actions: [
                // Separate exit control, distinct from the burger morph
                // (Requirement 6, design §Exit confirmation).
                IconButton(
                  icon: Icon(
                    Icons.logout_rounded,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                  tooltip: l.mockExitTooltip,
                  onPressed: () => _handlePopInvoked(false),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Countdown timer for the current Section's timed block.
                  SectionTimer(
                    controller: _controller,
                    onTimeUp: _handleTimeUp,
                  ),
                  // Progress through the attempt.
                  LinearProgressIndicator(
                    value: _controller.teilCount == 0
                        ? 0
                        : (_controller.currentTeilIndex + 1) /
                            _controller.teilCount,
                    backgroundColor:
                        isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                    color: AppColors.duoGreen,
                    minHeight: 4,
                  ),
                  // Horizontal question navigation for the active Teil.
                  if (showStrip)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: MockQuestionStrip(
                        count: questionCount,
                        activeIndex: activeQuestion,
                        isAnswered: (i) =>
                            _controller.answerFor(AnswerKey(
                              _controller.currentTeilIndex,
                              i,
                            )) !=
                            null,
                        onSelect: (i) => setState(() => _activeQuestion = i),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: _TeilBody(
                        controller: _controller,
                        activeQuestionIndex: viewActiveQuestion,
                      ),
                    ),
                  ),
                  MockNavBar(
                    canGoBack:
                        !_controller.isOnFirstTeil || activeQuestion > 0,
                    canGoNext: (questionCount != null &&
                            activeQuestion < questionCount - 1) ||
                        !_controller.isOnFinalTeil,
                    isFinalTeil: _controller.isOnFinalTeil,
                    onPrevious: _handlePrevious,
                    onNext: _handleNext,
                    onFinish: _completeAttempt,
                  ),
                ],
              ),
            ),
          );

          // The drawer overlays the whole screen (scrim + sliding panel) and is
          // driven by the same animation as the burger icon.
          return Stack(
            children: [
              scaffold,
              MockOverviewDrawer(
                controller: _controller,
                animation: _drawerAnimation,
                onSelectTeil: _onSelectTeil,
                onClose: _closeDrawer,
              ),
              // Schreiben baholanayotganda loading overlay
              if (_schreibenEvaluating)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.duoOrange,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Javoblaringiz baholanmoqda...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Natijalar tayyorlanmoqda. Iltimos kuting.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Resolves the section view that matches the selected-test subtype of the Teil
/// at [teilIndex] in the [controller]'s assembled attempt.
///
/// This is the single source of truth for the runner's Teil → view mapping. The
/// `switch` is exhaustive over the sealed [SelectedTest] hierarchy, so every
/// Teil resolves to exactly one interactive section view
/// (`SelectedLesenTest` → [LesenMockView], `SelectedHorenTest` → [HorenMockView],
/// `SelectedSchreibenTest` → [SchreibenMockView], `SelectedSprechenTest` →
/// [SprechenMockView]) with no unhandled case and no blank body
/// (Requirements 9.1, 9.2, 9.3).
///
/// The [activeQuestionIndex] (driven by [MockQuestionStrip]) is forwarded to the
/// question-based Lesen/Hören views; Schreiben/Sprechen are whole-unit views and
/// ignore it. Hören and Sprechen views own audio/recording lifecycles, so a
/// `ValueKey(teilIndex)` forces Flutter to rebuild (and tear down the old state)
/// when the Teil changes.
Widget mockTeilViewFor(
  MockTestController controller,
  int teilIndex, {
  int? activeQuestionIndex,
}) {
  final key = ValueKey(teilIndex);
  return switch (controller.attempt.teile[teilIndex].test) {
    SelectedLesenTest() => LesenMockView(
        key: key,
        controller: controller,
        teilIndex: teilIndex,
        activeQuestionIndex: activeQuestionIndex,
      ),
    SelectedHorenTest() => HorenMockView(
        key: key,
        controller: controller,
        teilIndex: teilIndex,
        activeQuestionIndex: activeQuestionIndex,
      ),
    SelectedSchreibenTest() => SchreibenMockView(
        key: key,
        controller: controller,
        teilIndex: teilIndex,
      ),
    SelectedSprechenTest() => SprechenMockView(
        key: key,
        controller: controller,
        teilIndex: teilIndex,
      ),
  };
}

/// Per-Teil body. Delegates to [mockTeilViewFor] to render the interactive
/// section view that matches the current Teil's selected test type, passing the
/// controller and the current Teil index so selections are recorded on the
/// frozen attempt. The [activeQuestionIndex] (driven by [MockQuestionStrip]) is
/// forwarded to the question-based Lesen/Hören views; Schreiben/Sprechen are
/// whole-unit views.
class _TeilBody extends StatelessWidget {
  final MockTestController controller;
  final int? activeQuestionIndex;

  const _TeilBody({required this.controller, this.activeQuestionIndex});

  @override
  Widget build(BuildContext context) {
    return mockTeilViewFor(
      controller,
      controller.currentTeilIndex,
      activeQuestionIndex: activeQuestionIndex,
    );
  }
}
