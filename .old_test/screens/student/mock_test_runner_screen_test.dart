// Widget tests for the B1 Mock Test redesigned runner composition.
//
// Task 10.3: Exercise the recomposed MockTestRunnerScreen end to end — the
// animated burger leading control opening/closing the overlay
// MockOverviewDrawer (Requirement 2.1), the separate exit affordance surfacing
// the leave-confirmation dialog and "stay" preserving the exact Teil/answers
// (Requirements 6.1, 6.2, 6.3), completing on the final Teil routing to the
// result screen (Requirement 8.5), and reaching a Schreiben / Sprechen Teil
// rendering its matching section view (Requirements 9.2, 9.3).
//
// Requirements: 2.1, 6.1, 6.2, 6.3, 8.5, 9.2, 9.3
//
// These are example-based widget tests. The runner localizes its app-authored
// chrome through `AppLocalizations.of(context)`, which reads a
// `ValueNotifier<AppLocale>` from a Provider; the tests mirror the app's
// `ChangeNotifierProvider.value` wiring and pin the locale to the Uzbek (`uz`)
// default so the asserted strings ("Imtihon tuzilishi", "Testdan chiqasizmi?",
// "Davom etish", "Yakunlash") are deterministic. The runner mounts a real
// SectionTimer (a periodic 1-second timer) and the Hören/Sprechen views own
// audio/recording lifecycles, so the tests drive frames with `tester.pump()`
// (never `pumpAndSettle`) and tear the tree down with `pumpWidget(SizedBox())`
// at the end of each test to cancel the timer and dispose those resources. The
// synthetic attempt mirrors the all-five-Sections fixture used by
// `test/models/mock_test_review_invariants_test.dart`, with empty Hören audio
// URLs and a no-network Sprechen Aufgabe so nothing hangs.

import 'package:core/l10n/locale_manager.dart';
import 'package:core/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_result_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_review_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_runner_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/schreiben_mock_view.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/sprechen_mock_view.dart';
import 'package:berlin_nukus/screens/student/mock_test/widgets/animated_burger_icon.dart';
import 'package:berlin_nukus/screens/student/mock_test/widgets/mock_overview_drawer.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── Test fixtures ─────────────────────────────────────────────────────────────

const _options = ['A', 'B', 'C', 'D'];

LesenQuestion _lesenQ(int n) => LesenQuestion(
      prompt: 'Frage $n',
      options: _options,
      correctAnswer: 'A',
    );

// Empty audioUrl so HorenMockView never loads/plays audio (no hanging timers).
HorenQuestion _horenQ(int n) => HorenQuestion(
      audioTitle: 'Audio',
      audioUrl: '',
      question: 'Frage $n',
      options: _options,
      correctAnswer: 'A',
    );

/// A deterministic, frozen attempt covering all five Sections in official TELC
/// B1 order, mirroring the invariants-test fixture.
///
/// Global Teil indices (their position in `attempt.teile`):
///   0 → Leseverstehen        Teil 1 (Lesen)
///   1 → Sprachbausteine      Teil 4 (Lesen — unique "Teil 4" label)
///   2 → Hörverstehen         Teil 1 (Hören, empty audio)
///   3 → Schriftlicher Ausdruck Teil 1 (Schreiben)
///   4 → Mündlicher Ausdruck  Teil 1 (Sprechen — the final Teil)
MockTestAttempt _buildAttempt() {
  return MockTestAttempt([
    MockTeil(
      section: MockSection.leseverstehen,
      teilNumber: 1,
      test: SelectedLesenTest(
        questions: [_lesenQ(1), _lesenQ(2)],
        text: null,
        imageUrl: null,
      ),
    ),
    MockTeil(
      section: MockSection.sprachbausteine,
      teilNumber: 4,
      test: SelectedLesenTest(
        questions: [_lesenQ(3), _lesenQ(4)],
        text: null,
        imageUrl: null,
      ),
    ),
    MockTeil(
      section: MockSection.hoerverstehen,
      teilNumber: 1,
      test: SelectedHorenTest(questions: [_horenQ(1)]),
    ),
    const MockTeil(
      section: MockSection.schriftlicherAusdruck,
      teilNumber: 1,
      test: SelectedSchreibenTest(
        task: SchreibenTask(
          id: 1,
          task: 'Schreiben Sie einen Brief.',
          points: ['Punkt 1', 'Punkt 2'],
          style: 'formell',
          minWords: 80,
          level: 'B1',
        ),
      ),
    ),
    MockTeil(
      section: MockSection.muendlicherAusdruck,
      teilNumber: 1,
      test: SelectedSprechenTest(
        aufgaben: const [
          SprechenAufgabe(
            title: 'Sich vorstellen',
            instruction: 'Stellen Sie sich vor.',
          ),
        ],
      ),
    ),
  ]);
}

/// Wraps [child] in a MaterialApp with the locale Provider the runner expects,
/// pinned to [locale] (default `uz`). A tall, narrow surface keeps the whole
/// overview-drawer Section/Teil list on screen without lazy ListView culling.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(home: child),
  );
}

/// The shared burger ↔ drawer animation progress (`0` = closed, `1` = open),
/// read off the single AnimatedIcon driven by the runner's AnimationController.
double _burgerProgress(WidgetTester tester) =>
    tester.widget<AnimatedIcon>(find.byType(AnimatedIcon)).progress.value;

/// Pumps the runner onto a tall surface and settles the first frame.
Future<void> _pumpRunner(
  WidgetTester tester,
  MockTestController controller,
) async {
  tester.view.physicalSize = const Size(420, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_wrap(MockTestRunnerScreen(controller: controller)));
  await tester.pump();
}

/// Tears the tree down so the SectionTimer's periodic timer is cancelled and
/// the Hören/Sprechen audio resources are disposed.
Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

void main() {
  group('MockTestRunnerScreen — overview drawer (2.1)', () {
    testWidgets(
        'tapping the burger opens the drawer; the close control closes it',
        (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      await _pumpRunner(tester, controller);

      // Drawer starts closed: the burger sits at the three-line shape (0).
      expect(find.byType(MockOverviewDrawer), findsOneWidget);
      expect(_burgerProgress(tester), closeTo(0.0, 0.001));

      // Tap the animated burger leading control → drawer opens (Requirement 2.1).
      await tester.tap(find.byType(AnimatedBurgerIcon));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // The shared animation has driven the burger → X morph / drawer-open to
      // completion, and the drawer shows its localized title plus the German
      // Section names.
      expect(_burgerProgress(tester), closeTo(1.0, 0.001));
      expect(find.text('Imtihon tuzilishi'), findsOneWidget);
      expect(find.text('Leseverstehen'), findsOneWidget);
      expect(find.text('Sprachbausteine'), findsOneWidget);
      expect(find.text('Hörverstehen'), findsOneWidget);
      expect(find.text('Schriftlicher Ausdruck'), findsOneWidget);
      expect(find.text('Mündlicher Ausdruck'), findsOneWidget);

      // Tap the drawer's close (X) control → drawer closes back to the burger.
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(_burgerProgress(tester), closeTo(0.0, 0.001));

      await _dispose(tester);
    });

    testWidgets(
        'selecting a Teil from the drawer navigates to it and closes the drawer',
        (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      await _pumpRunner(tester, controller);

      // The runner starts on the first Teil.
      expect(controller.currentTeilIndex, 0);

      // Open the drawer.
      await tester.tap(find.byType(AnimatedBurgerIcon));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(_burgerProgress(tester), closeTo(1.0, 0.001));

      // Tap the Sprachbausteine "Teil 4" tile — its global index is 1.
      await tester.tap(find.text('Teil 4'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // The runner jumped to that Teil (Requirement 2.5 preserves answers; the
      // cursor moved) and the drawer closed.
      expect(controller.currentTeilIndex, 1);
      expect(_burgerProgress(tester), closeTo(0.0, 0.001));

      await _dispose(tester);
    });
  });

  group('MockTestRunnerScreen — exit confirmation (6.1, 6.2, 6.3)', () {
    testWidgets(
        'the exit action shows the dialog; "stay" dismisses it and preserves '
        'the Teil and answers',
        (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      // Record an answer on the first Teil so we can prove it survives "stay".
      controller.selectAnswer(const AnswerKey(0, 0), 'A');

      await _pumpRunner(tester, controller);
      expect(controller.currentTeilIndex, 0);

      // No dialog before the student tries to leave.
      expect(find.text('Testdan chiqasizmi?'), findsNothing);

      // Tap the distinct exit affordance (Icons.logout_rounded) → the
      // leave-confirmation dialog is shown (Requirement 6.1).
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Testdan chiqasizmi?'), findsOneWidget);

      // Choose "Davom etish" (stay) → the dialog is dismissed and the attempt
      // is NOT discarded (Requirements 6.2, 6.3).
      await tester.tap(find.text('Davom etish'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Testdan chiqasizmi?'), findsNothing);
      // Same screen, same Teil, same answers.
      expect(find.byType(MockTestRunnerScreen), findsOneWidget);
      expect(controller.currentTeilIndex, 0);
      expect(controller.answerFor(const AnswerKey(0, 0)), 'A');

      await _dispose(tester);
    });
  });

  group('MockTestRunnerScreen — completion (8.5)', () {
    testWidgets(
        'finishing on the final Teil routes to the result screen',
        (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      await _pumpRunner(tester, controller);

      // Jump to the final Teil (Mündlicher Ausdruck — Sprechen).
      controller.goToTeil(controller.teilCount - 1);
      await tester.pump();
      expect(controller.isOnFinalTeil, isTrue);
      expect(find.byType(MockTestResultScreen), findsNothing);

      // The final Teil exposes a separate Finish control; tapping it builds the
      // result + review and routes to the result screen (Requirement 8.5).
      final finishButton = find.widgetWithText(ElevatedButton, 'Yakunlash');
      expect(finishButton, findsOneWidget);
      await tester.tap(finishButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MockTestResultScreen), findsOneWidget);

      await _dispose(tester);
    });
  });

  group('MockTestRunnerScreen — section view mapping (9.2, 9.3)', () {
    testWidgets('reaching the Schreiben Teil renders the SchreibenMockView (9.2)',
        (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      await _pumpRunner(tester, controller);

      // Global index 3 is the Schriftlicher Ausdruck (Schreiben) Teil.
      controller.goToTeil(3);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SchreibenMockView), findsOneWidget);
      expect(find.byType(SprechenMockView), findsNothing);

      await _dispose(tester);
    });

    testWidgets('reaching the Sprechen Teil renders the SprechenMockView (9.3)',
        (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());
      await _pumpRunner(tester, controller);

      // Global index 4 is the Mündlicher Ausdruck (Sprechen) Teil.
      controller.goToTeil(4);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SprechenMockView), findsOneWidget);
      expect(find.byType(SchreibenMockView), findsNothing);

      await _dispose(tester);
    });
  });
}
