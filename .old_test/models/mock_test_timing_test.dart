// Property test for the pure timer classifier `computeTimerState`.
//
// Feature: b1-mock-test-redesign, Property 4: Section_Timer holati
// klassifikatsiyasi — For any remaining duration r >= 0 and any
// warningThreshold t > 0, computeTimerState(r, t) returns exactly one phase
// such that: phase == timeUp iff r == 0; phase == warning iff 0 < r <= t;
// phase == normal iff r > t; the three phases are mutually exclusive; and the
// function is pure (returns a state only, with no side effect).
//
// Validates: Requirements 5.4, 5.5, 5.7
//
// Strategy: glados drives two integer dimensions (milliseconds) which are
// turned into Durations. `rMs` ranges over [0, ...) so the r == 0 edge case is
// generated directly; `tMs` ranges over [1, ...) so the threshold is always
// positive. To guarantee the r == t boundary is exercised (continuous random
// ranges hit exact equality only rarely), a second generator derives r as an
// offset relative to t, and explicit boundary unit tests pin r == 0, r == t,
// r == t - 1ms and r == t + 1ms. Runs at least 100 iterations (glados default).

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test;

import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_timing.dart';

/// Asserts the full Property 4 contract for one (remaining, threshold) pair.
void _assertClassification(Duration r, Duration t) {
  // Calling twice with the same inputs must yield equal results: the function
  // is a pure classifier with no observable side effect (Requirement 5.7).
  final state = computeTimerState(r, t);
  final again = computeTimerState(r, t);
  expect(again, state, reason: 'computeTimerState must be pure/deterministic');

  final isTimeUp = state.phase == TimerPhase.timeUp;
  final isWarning = state.phase == TimerPhase.warning;
  final isNormal = state.phase == TimerPhase.normal;

  // Mutual exclusivity: exactly one phase holds.
  final activeCount = [isTimeUp, isWarning, isNormal].where((b) => b).length;
  expect(activeCount, 1, reason: 'phases must be mutually exclusive');

  // Classification (domain: r >= 0, t > 0).
  expect(isTimeUp, r == Duration.zero, reason: 'timeUp iff r == 0');
  expect(isWarning, r > Duration.zero && r <= t, reason: 'warning iff 0 < r <= t');
  expect(isNormal, r > t, reason: 'normal iff r > t');

  // timeUp pins remaining to zero; otherwise remaining is preserved.
  if (isTimeUp) {
    expect(state.remaining, Duration.zero);
  } else {
    expect(state.remaining, r);
  }
}

void main() {
  // Feature: b1-mock-test-redesign, Property 4: Section_Timer holati
  // klassifikatsiyasi.
  //
  // Independent r and t over wide millisecond ranges (up to 2 hours), with
  // r == 0 reachable directly from the lower bound.
  Glados2<int, int>(
    any.intInRange(0, 7200001), // remaining: 0 .. 2h (inclusive of 0)
    any.intInRange(1, 7200001), // threshold: 1ms .. 2h (always > 0)
  ).test(
    'Property 4: phase is timeUp iff r==0, warning iff 0<r<=t, normal iff r>t',
    (rMs, tMs) {
      _assertClassification(
        Duration(milliseconds: rMs),
        Duration(milliseconds: tMs),
      );
    },
  );

  // Same property, but r is derived as an offset relative to t so the r == t
  // and near-boundary cases (r == t ± k) are exercised frequently, including
  // offsets that drive r down to (and below) zero — clamped to >= 0.
  Glados2<int, int>(
    any.intInRange(1, 7200001), // threshold: 1ms .. 2h
    any.intInRange(-5000, 5001), // offset around the threshold (covers 0)
  ).test(
    'Property 4: classification holds around the r == t boundary',
    (tMs, offsetMs) {
      final rMs = (tMs + offsetMs).clamp(0, 1 << 31);
      _assertClassification(
        Duration(milliseconds: rMs),
        Duration(milliseconds: tMs),
      );
    },
  );

  // Explicit edge cases required by the task: r == 0 and r == t (plus the two
  // adjacent millisecond boundaries) are deterministically covered.
  group('Property 4: explicit boundary edge cases', () {
    const t = Duration(minutes: 1); // MockTestTiming.warningThreshold

    test('r == 0 classifies as timeUp with remaining zero', () {
      final state = computeTimerState(Duration.zero, t);
      expect(state.phase, TimerPhase.timeUp);
      expect(state.remaining, Duration.zero);
    });

    test('r == t classifies as warning (inclusive upper bound)', () {
      final state = computeTimerState(t, t);
      expect(state.phase, TimerPhase.warning);
      expect(state.remaining, t);
    });

    test('r == t - 1ms classifies as warning', () {
      final r = t - const Duration(milliseconds: 1);
      expect(computeTimerState(r, t).phase, TimerPhase.warning);
    });

    test('r == t + 1ms classifies as normal', () {
      final r = t + const Duration(milliseconds: 1);
      expect(computeTimerState(r, t).phase, TimerPhase.normal);
    });

    test('uses the official default warning threshold of 1 minute', () {
      expect(MockTestTiming.warningThreshold, const Duration(minutes: 1));
    });
  });
}
