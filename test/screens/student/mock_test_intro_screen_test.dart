// Widget tests for the B1 Mock Test intro screen.
//
// Asserts that the redesigned intro screen renders the overview (Duration card,
// the per-Section breakdown, and the Important Notes), shows the German exam
// section names regardless of the interface locale (Requirement 11.2), and that
// pressing the start control assembles an attempt and navigates into the
// [MockTestRunnerScreen] (Requirements 1.1, 10.3).
//
// The intro screen assembles a fresh attempt via
// `MockTestAssembler.assemble(rng: Random())` using the app's shipped B1
// content (lesenB1, horenB1, schreibenTasksB1, sprechenB1), which is present in
// the test environment, so the start flow routes into the runner.
//
// The screens localize app-authored text through `AppLocalizations.of(context)`,
// which reads a `ValueNotifier<AppLocale>` from a Provider; the tests pin the
// locale to Uzbek (`uz`) so the asserted strings are deterministic. The runner
// hosts periodic timers, so after navigating into it the tests use
// `tester.pump` (never `pumpAndSettle`).

import 'package:berlin_nukus/l10n/locale_manager.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_intro_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_runner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── Test scaffolding ─────────────────────────────────────────────────────────

/// Wraps [child] in a MaterialApp with the locale Provider the screens expect.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('MockTestIntroScreen overview render', () {
    testWidgets('renders the Duration, Sections and Important Notes headers',
        (tester) async {
      await tester.pumpWidget(_wrap(const MockTestIntroScreen()));
      await tester.pump();

      // Localized section headers (uz).
      expect(find.text('Davomiyligi'), findsOneWidget);
      expect(find.text('Bo\'limlar'), findsOneWidget);
      expect(find.text('Muhim eslatmalar'), findsOneWidget);

      // The overall duration (90 + 30 + 30 + 15 + 20 prep = 185 min).
      expect(find.text('185 daqiqa'), findsOneWidget);
    });

    testWidgets('shows the German section names regardless of locale (11.2)',
        (tester) async {
      await tester.pumpWidget(_wrap(const MockTestIntroScreen()));
      await tester.pump();

      // German exam section names stay German even though the interface is uz.
      expect(find.text('Lesen & Sprachbausteine'), findsOneWidget);
      expect(find.text('Hören'), findsOneWidget);
      expect(find.text('Schreiben'), findsOneWidget);
      expect(find.text('Sprechen'), findsOneWidget);
    });

    testWidgets('shows per-section question counts and durations',
        (tester) async {
      await tester.pumpWidget(_wrap(const MockTestIntroScreen()));
      await tester.pump();

      // Lesen & Sprachbausteine: 40 questions, 90 minutes.
      expect(find.text('40 savol  •  90 daqiqa'), findsOneWidget);
      // Hören: 20 questions, 30 minutes.
      expect(find.text('20 savol  •  30 daqiqa'), findsOneWidget);
      // Schreiben: 1 question, 30 minutes.
      expect(find.text('1 savol  •  30 daqiqa'), findsOneWidget);
      // Sprechen: 3 questions, 15 minutes.
      expect(find.text('3 savol  •  15 daqiqa'), findsOneWidget);
    });

    testWidgets('shows the localized start button', (tester) async {
      await tester.pumpWidget(_wrap(const MockTestIntroScreen()));
      await tester.pump();

      expect(find.text('Testni boshlash'), findsOneWidget);
    });
  });

  group('MockTestIntroScreen start flow', () {
    testWidgets(
        'tapping start assembles an attempt and navigates to the runner (1.1, 10.3)',
        (tester) async {
      await tester.pumpWidget(_wrap(const MockTestIntroScreen()));
      await tester.pump();

      // Not in the runner yet.
      expect(find.byType(MockTestRunnerScreen), findsNothing);

      final startButton = find.text('Testni boshlash');
      expect(startButton, findsOneWidget);
      await tester.ensureVisible(startButton);
      await tester.pump();
      await tester.tap(startButton);

      // Drive the route transition into the runner. The runner hosts periodic
      // timers, so we pump fixed durations instead of pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(MockTestRunnerScreen), findsOneWidget);
    });
  });
}
