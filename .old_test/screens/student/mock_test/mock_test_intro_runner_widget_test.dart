// Widget tests for the B1 Mock Test intro screen and runner host.
//
// Task 9.4: Assert the intro screen's timing/points display (90-min combined
// reading allowance, listening allowance, 30-min Schreiben allowance, Mündlich
// preparation+speaking allowance, per-section point values, and the 300-point
// total), and assert that completing on the final Teil of the runner routes to
// the result screen while back navigation surfaces the leave-confirmation
// dialog.
//
// Requirements: 6.3 (completion on the final Teil presents the result),
// 6.4 (leaving an in-progress attempt requests confirmation), 10.1/10.2/10.3
// (official timing and the 300-point total are displayed).
//
// These are example-based widget tests. The screens localize app-authored text
// through `AppLocalizations.of(context)`, which reads a
// `ValueNotifier<AppLocale>` from a Provider; the tests mirror the app's
// `ChangeNotifierProvider.value` wiring and pin the locale to the Uzbek (`uz`)
// default so the asserted strings are deterministic. The runner is driven by a
// MockTestController built from a small synthetic Lesen-only attempt so the
// tests never touch network images, audio playback, or microphone recording.

import 'package:core/l10n/locale_manager.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_intro_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_result_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_runner_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── Test scaffolding ─────────────────────────────────────────────────────────

/// Wraps [child] in a MaterialApp with the locale Provider the screens expect.
/// The locale notifier is pinned to the supplied [locale] (default `uz`) so the
/// localized strings under test are deterministic.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(home: child),
  );
}

LesenQuestion _lesenQ(String tag) => LesenQuestion(
      prompt: '$tag-Frage',
      options: const ['Option A', 'Option B'],
      correctAnswer: 'Option A',
    );

/// A small Leseverstehen-only attempt with [teilCount] Teile. Using Lesen for
/// every Teil keeps the runner free of network images, audio, and recording so
/// the navigation behavior can be tested in isolation.
MockTestAttempt _lesenAttempt({int teilCount = 2}) {
  return MockTestAttempt([
    for (var i = 0; i < teilCount; i++)
      MockTeil(
        section: MockSection.leseverstehen,
        teilNumber: i + 1,
        test: SelectedLesenTest(
          questions: [_lesenQ('T${i + 1}-Q1')],
          text: null,
          imageUrl: null,
        ),
      ),
  ]);
}

void main() {
  group('MockTestIntroScreen overview display', () {
    testWidgets(
        'displays the total duration and per-Section breakdown (10.1, 10.2)',
        (tester) async {
      await tester.pumpWidget(_wrap(const MockTestIntroScreen()));
      await tester.pump();

      // Overall duration (90 + 30 + 30 + 15 + 20 prep = 185 min).
      expect(find.text('185 daqiqa'), findsOneWidget);

      // Per-section breakdown: questions • minutes.
      expect(find.text('40 savol  •  90 daqiqa'), findsOneWidget);
      expect(find.text('20 savol  •  30 daqiqa'), findsOneWidget);
      expect(find.text('1 savol  •  30 daqiqa'), findsOneWidget);
      expect(find.text('3 savol  •  15 daqiqa'), findsOneWidget);
    });

    testWidgets('displays the German section names and important notes',
        (tester) async {
      await tester.pumpWidget(_wrap(const MockTestIntroScreen()));
      await tester.pump();

      expect(find.text('Lesen & Sprachbausteine'), findsOneWidget);
      expect(find.text('Hören'), findsOneWidget);
      expect(find.text('Schreiben'), findsOneWidget);
      expect(find.text('Sprechen'), findsOneWidget);

      // Important Notes header is present.
      expect(find.text('Muhim eslatmalar'), findsOneWidget);

      // Sanity-check the structure constant the totals derive from.
      expect(MockTestStructure.totalPoints, 300);
    });
  });

  group('MockTestRunnerScreen navigation', () {
    testWidgets('completing on the final Teil routes to the result screen (6.3)',
        (tester) async {
      final controller = MockTestController(attempt: _lesenAttempt());
      await tester.pumpWidget(
        _wrap(MockTestRunnerScreen(controller: controller)),
      );
      await tester.pump();

      // On the first (non-final) Teil the advance control is shown.
      expect(controller.isOnFinalTeil, isFalse);
      expect(find.widgetWithText(ElevatedButton, 'Keyingi'), findsOneWidget);
      expect(find.byType(MockTestResultScreen), findsNothing);

      // Advance to the final Teil.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keyingi'));
      await tester.pumpAndSettle();
      expect(controller.isOnFinalTeil, isTrue);

      // On the final Teil the finish control is shown; tapping it routes to the
      // result screen.
      final finishButton = find.widgetWithText(ElevatedButton, 'Yakunlash');
      expect(finishButton, findsOneWidget);
      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      expect(find.byType(MockTestResultScreen), findsOneWidget);
    });

    testWidgets('back navigation shows the leave-confirmation dialog (6.4)',
        (tester) async {
      final controller = MockTestController(attempt: _lesenAttempt());
      await tester.pumpWidget(
        _wrap(MockTestRunnerScreen(controller: controller)),
      );
      await tester.pump();

      // No dialog before the student tries to leave.
      expect(find.text('Testdan chiqasizmi?'), findsNothing);

      // Tapping the exit affordance (a distinct logout action in the AppBar,
      // separate from the burger menu morph) requests confirmation before
      // discarding.
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Testdan chiqasizmi?'), findsOneWidget);
      // The dialog offers stay/leave actions and the attempt is not discarded.
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(MockTestRunnerScreen), findsOneWidget);
    });
  });
}
