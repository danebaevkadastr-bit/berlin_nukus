// B1 Mock Test — countdown Section timer banner.
//
// Sits at the top of the runner and counts down the remaining time of the
// timed block the current Section belongs to (Requirements 5.1, 5.2). The
// official TELC B1 allowances and the Section → block mapping come from
// [MockTestTiming]; Leseverstehen and Sprachbausteine share one 90-minute
// block, so navigating between them continues the same countdown.
//
// Per-block remaining time is preserved: a block only counts down while it is
// the active block, and when the student returns to a previously visited block
// the timer resumes from where it left off (Requirement 5.3) — this mirrors
// real exam time management rather than resetting on each visit.
//
// The visual phase is derived purely via [computeTimerState]:
//   * normal  — accent color;
//   * warning — `0 < remaining <= warningThreshold` → `duoOrange` (Req 5.4);
//   * timeUp  — `remaining == 0` → the warning state stops and a distinct
//     "time up" message (`l.mockTimerExpired`) is shown instead of "00:00"
//     (Requirements 5.5, 5.6).
//
// When a block's countdown reaches zero the timer fires its optional
// [SectionTimer.onTimeUp] callback (once, on the transition). The runner wires
// this to auto-advance to the next timed block, or to auto-submit the attempt
// when the final block's time expires. The timer itself never mutates the
// domain core. Time digits are rendered as numerals while the surrounding label
// text is localized through [AppLocalizations]
// (Requirements 5.8, 11.1).

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import '../mock_test_controller.dart';
import '../model/mock_test_timing.dart';

/// Top-of-runner countdown timer for the current Section's timed block.
///
/// Watches [controller] to follow the active Section and preserves a separate
/// remaining duration per timed block.
class SectionTimer extends StatefulWidget {
  final MockTestController controller;

  /// Called once when the active block's countdown reaches zero. The runner
  /// uses this to auto-advance to the next block, or to auto-submit the attempt
  /// when the final block's time expires.
  final VoidCallback? onTimeUp;

  const SectionTimer({super.key, required this.controller, this.onTimeUp});

  @override
  State<SectionTimer> createState() => _SectionTimerState();
}

class _SectionTimerState extends State<SectionTimer> {
  /// Per-block remaining time, keyed by [MockTestTiming.blockKeyOf]. A block is
  /// seeded with its official allowance the first time it becomes active and
  /// only counts down while it is the active block.
  final Map<Object, Duration> _remainingByBlock = {};

  /// The block key of the Section currently presented by the controller.
  late Object _activeBlockKey;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncActiveBlock();
    widget.controller.addListener(_onControllerChanged);
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Ensures the active block (derived from the controller's current Section)
  /// has a seeded remaining duration and updates [_activeBlockKey].
  void _syncActiveBlock() {
    final section = widget.controller.currentTeil.section;
    final key = MockTestTiming.blockKeyOf(section);
    _remainingByBlock.putIfAbsent(
      key,
      () => MockTestTiming.allowanceOf(section),
    );
    _activeBlockKey = key;
  }

  /// Rebuilds when the controller moves to a Teil in a different timed block so
  /// the banner shows that block's preserved remaining time (Requirement 5.3).
  void _onControllerChanged() {
    final previousKey = _activeBlockKey;
    _syncActiveBlock();
    if (previousKey != _activeBlockKey && mounted) {
      setState(() {});
    }
  }

  /// Decrements only the active block's remaining time, never below zero. When
  /// the active block reaches zero it fires [SectionTimer.onTimeUp] exactly once
  /// (on the transition) so the runner can auto-advance or auto-submit.
  void _tick(Timer timer) {
    final current = _remainingByBlock[_activeBlockKey] ?? Duration.zero;
    if (current <= Duration.zero) return;
    final next = current - const Duration(seconds: 1);
    final clamped = next < Duration.zero ? Duration.zero : next;
    setState(() {
      _remainingByBlock[_activeBlockKey] = clamped;
    });
    if (clamped <= Duration.zero) {
      widget.onTimeUp?.call();
    }
  }

  /// Formats a duration as `mm:ss` using digit numerals (Requirement 5.8).
  String _formatRemaining(Duration remaining) {
    final totalSeconds = remaining.inSeconds < 0 ? 0 : remaining.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final accent = ThemeManager.accent;

    final remaining = _remainingByBlock[_activeBlockKey] ?? Duration.zero;
    final state = computeTimerState(remaining, MockTestTiming.warningThreshold);

    // Phase color: accent (normal), duoOrange (warning), duoRed (timeUp).
    final Color phaseColor;
    switch (state.phase) {
      case TimerPhase.normal:
        phaseColor = accent;
        break;
      case TimerPhase.warning:
        phaseColor = AppColors.duoOrange;
        break;
      case TimerPhase.timeUp:
        phaseColor = AppColors.duoRed;
        break;
    }

    final bool expired = state.phase == TimerPhase.timeUp;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: phaseColor.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: phaseColor.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            expired ? Icons.timer_off_rounded : Icons.timer_rounded,
            size: 20,
            color: phaseColor,
          ),
          const SizedBox(width: 10),
          // App-authored label, localized (Requirements 5.8, 11.1).
          Flexible(
            child: Text(
              l.mockTimerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : AppColors.duoTextDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // On timeUp show the distinct expired message instead of "00:00"
          // (Requirements 5.5, 5.6); otherwise show the mm:ss numerals.
          Text(
            expired ? l.mockTimerExpired : _formatRemaining(state.remaining),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: expired ? 15 : 18,
              letterSpacing: expired ? 0 : 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: phaseColor,
            ),
          ),
        ],
      ),
    );
  }
}
