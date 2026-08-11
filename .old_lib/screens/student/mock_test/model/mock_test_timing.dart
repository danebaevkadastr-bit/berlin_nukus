// Pure timer/timing models for the B1 Mock Test redesign (presentation layer).
//
// This file holds **no** scoring or assembly logic and never mutates the domain
// core. It exposes:
//   * [TimerPhase] / [SectionTimerState] — the immutable visual state a timer
//     widget renders.
//   * [computeTimerState] — a pure classifier from remaining time to phase.
//   * [MockTestTiming] — the official TELC B1 timed-block durations and the
//     mapping from a [MockSection] to its block and allowance.
//
// Pure Dart: the only Flutter dependency is `@immutable` from
// `package:flutter/foundation.dart`, which carries no runtime/I-O behaviour and
// keeps the models property-testable in isolation. The timer logic never
// auto-submits an attempt (Requirement 5.7).

import 'package:flutter/foundation.dart';

import 'mock_test_structure.dart';

/// The visual state of the [SectionTimer], derived purely from remaining time.
enum TimerPhase {
  /// Remaining time is above the warning threshold.
  normal,

  /// Remaining time is at or below the warning threshold but still positive.
  warning,

  /// Remaining time has reached zero. The attempt is **not** auto-submitted;
  /// the student may keep working (Requirement 5.7).
  timeUp,
}

/// Immutable snapshot of the timer's derived visual state.
///
/// [remaining] is `Duration.zero` whenever [phase] is [TimerPhase.timeUp].
@immutable
class SectionTimerState {
  final TimerPhase phase;
  final Duration remaining;

  const SectionTimerState({required this.phase, required this.remaining});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionTimerState &&
          runtimeType == other.runtimeType &&
          phase == other.phase &&
          remaining == other.remaining;

  @override
  int get hashCode => Object.hash(phase, remaining);

  @override
  String toString() => 'SectionTimerState(phase: $phase, remaining: $remaining)';
}

/// Pure classifier from a [remaining] duration and a [warningThreshold] to the
/// timer's visual state.
///
/// Classification (mutually exclusive):
///   * [TimerPhase.timeUp]  iff `remaining == Duration.zero`;
///   * [TimerPhase.warning] iff `Duration.zero < remaining <= warningThreshold`;
///   * [TimerPhase.normal]  iff `remaining > warningThreshold`.
///
/// This function has no side effects: it returns a state only and never
/// completes the attempt or triggers any auto-submit (Requirement 5.7).
SectionTimerState computeTimerState(
  Duration remaining,
  Duration warningThreshold,
) {
  if (remaining <= Duration.zero) {
    return const SectionTimerState(
      phase: TimerPhase.timeUp,
      remaining: Duration.zero,
    );
  }
  if (remaining <= warningThreshold) {
    return SectionTimerState(
      phase: TimerPhase.warning,
      remaining: remaining,
    );
  }
  return SectionTimerState(
    phase: TimerPhase.normal,
    remaining: remaining,
  );
}

/// Official TELC B1 timed-block durations and per-[MockSection] mapping.
///
/// Leseverstehen and Sprachbausteine share a single 90-minute block (they are
/// timed together in the official exam); the remaining sections each have their
/// own block.
class MockTestTiming {
  const MockTestTiming._();

  /// Combined Leseverstehen + Sprachbausteine block.
  static const Duration leseSprachbausteine = Duration(minutes: 90);

  /// Hörverstehen block.
  static const Duration hoeren = Duration(minutes: 30);

  /// Schriftlicher Ausdruck block.
  static const Duration schreiben = Duration(minutes: 30);

  /// Mündlicher Ausdruck block.
  static const Duration sprechen = Duration(minutes: 15);

  /// The official total exam duration shown on overview screens: the sum of
  /// every timed block plus the 20-minute oral preparation time
  /// (90 + 30 + 30 + 15 + 20 = 185 min). The per-block countdown timers still
  /// use the individual [allowanceOf] values.
  static const Duration totalDuration = Duration(minutes: 185);

  /// Low-time threshold below which the timer enters [TimerPhase.warning].
  static const Duration warningThreshold = Duration(minutes: 1);

  /// Identifies which timed block [section] belongs to. Leseverstehen and
  /// Sprachbausteine resolve to the **same** key so they share one countdown.
  static Object blockKeyOf(MockSection section) {
    switch (section) {
      case MockSection.leseverstehen:
      case MockSection.sprachbausteine:
        return 'lese_sprachbausteine';
      case MockSection.hoerverstehen:
        return 'hoeren';
      case MockSection.schriftlicherAusdruck:
        return 'schreiben';
      case MockSection.muendlicherAusdruck:
        return 'sprechen';
    }
  }

  /// The official total time allowance for [section]'s timed block.
  static Duration allowanceOf(MockSection section) {
    switch (section) {
      case MockSection.leseverstehen:
      case MockSection.sprachbausteine:
        return leseSprachbausteine;
      case MockSection.hoerverstehen:
        return hoeren;
      case MockSection.schriftlicherAusdruck:
        return schreiben;
      case MockSection.muendlicherAusdruck:
        return sprechen;
    }
  }
}
