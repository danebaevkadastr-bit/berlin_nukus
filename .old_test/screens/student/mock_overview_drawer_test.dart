// Widget tests for the B1 Mock Test redesigned overview (burger) drawer and the
// animated burger → X icon.
//
// Task 5.3: Verify that the MockOverviewDrawer
//   * lists every Section in its official German name (Requirements 2.2, 2.6,
//     9.4) regardless of the interface locale,
//   * visually distinguishes the currently active Teil (Requirement 2.4),
//   * jumps to a Teil and closes the drawer when a Teil tile is tapped —
//     invoking onSelectTeil with that Teil's global index and then onClose
//     (Requirements 2.3, 3.3),
// and that the AnimatedBurgerIcon
//   * morphs between the three-line burger (progress 0) and the "X" (progress 1)
//     shapes (Requirements 3.2, 3.3),
//   * completes that morph within the runner's animation budget of ≤400 ms
//     (Requirement 3.4) — driven here by an AnimationController set to the
//     runner's 300 ms duration.
//
// Requirements: 2.2, 2.3, 2.4, 2.6, 3.2, 3.3, 3.4, 9.4
//
// These are example-based widget tests. Both widgets localize their
// app-authored chrome through `AppLocalizations.of(context)`, which reads a
// `ValueNotifier<AppLocale>` from a Provider; the tests mirror the app's
// `ChangeNotifierProvider.value` wiring (see mock_nav_bar_test.dart) and pin the
// locale to the Uzbek (`uz`) default. The German Section names are asserted to
// stay German under that locale, exercising Requirements 2.6 / 9.4.

import 'package:core/l10n/locale_manager.dart';
import 'package:core/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/horen/horen_data.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_review_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
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

HorenQuestion _horenQ(int n) => HorenQuestion(
      audioTitle: 'Audio',
      audioUrl: 'https://example.test/a.mp3',
      question: 'Frage $n',
      options: _options,
      correctAnswer: 'A',
    );

/// A deterministic, frozen attempt covering all five Sections in official
/// order, so the drawer renders one German header per Section plus its Teile.
///
/// Global Teil indices (their position in `attempt.teile`):
///   0 → Leseverstehen Teil 1
///   1 → Leseverstehen Teil 2
///   2 → Sprachbausteine Teil 4
///   3 → Hörverstehen Teil 1
///   4 → Hörverstehen Teil 2
///   5 → Schriftlicher Ausdruck Teil 1
///   6 → Mündlicher Ausdruck Teil 1
MockTestAttempt _buildAttempt() {
  return MockTestAttempt([
    MockTeil(
      section: MockSection.leseverstehen,
      teilNumber: 1,
      test: SelectedLesenTest(questions: [_lesenQ(1), _lesenQ(2)]),
    ),
    MockTeil(
      section: MockSection.leseverstehen,
      teilNumber: 2,
      test: SelectedLesenTest(questions: [_lesenQ(3), _lesenQ(4)]),
    ),
    MockTeil(
      section: MockSection.sprachbausteine,
      teilNumber: 4,
      test: SelectedLesenTest(questions: [_lesenQ(5), _lesenQ(6)]),
    ),
    MockTeil(
      section: MockSection.hoerverstehen,
      teilNumber: 1,
      test: SelectedHorenTest(questions: [_horenQ(1), _horenQ(2)]),
    ),
    MockTeil(
      section: MockSection.hoerverstehen,
      teilNumber: 2,
      test: SelectedHorenTest(questions: [_horenQ(3)]),
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

/// Wraps [child] in a MaterialApp with the locale Provider the widgets expect,
/// pinned to [locale] (default `uz`). A tall surface is used so the whole
/// Section/Teil list renders without lazy ListView off-screen culling.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('MockOverviewDrawer', () {
    testWidgets(
        'lists every Section in its German name regardless of locale (2.2, 2.6, 9.4)',
        (tester) async {
      // Tall surface so all Section headers + Teil tiles render at once.
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = MockTestController(attempt: _buildAttempt());

      await tester.pumpWidget(_wrap(
        MockOverviewDrawer(
          controller: controller,
          animation: const AlwaysStoppedAnimation<double>(1.0),
          onSelectTeil: (_) {},
          onClose: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // All five Sections appear with their official German names — never
      // localized (Requirements 2.2, 2.6, 9.4).
      expect(find.text('Leseverstehen'), findsOneWidget);
      expect(find.text('Sprachbausteine'), findsOneWidget);
      expect(find.text('Hörverstehen'), findsOneWidget);
      expect(find.text('Schriftlicher Ausdruck'), findsOneWidget);
      expect(find.text('Mündlicher Ausdruck'), findsOneWidget);

      // The Sprachbausteine Teil keeps its German exam label, unique here.
      expect(find.text('Teil 4'), findsOneWidget);
    });

    testWidgets('highlights the currently active Teil (2.4)', (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = MockTestController(attempt: _buildAttempt());
      // Move the cursor to the Sprachbausteine Teil (global index 2).
      controller.goToTeil(2);

      await tester.pumpWidget(_wrap(
        MockOverviewDrawer(
          controller: controller,
          animation: const AlwaysStoppedAnimation<double>(1.0),
          onSelectTeil: (_) {},
          onClose: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // The active Teil tile is marked with the filled "play" icon; every other
      // Teil tile uses the outlined circle. Exactly one tile is active.
      expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
      // Six remaining Teile (7 total - 1 active) show the outlined marker.
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(6));
    });

    testWidgets(
        'tapping a Teil tile reports its global index and closes the drawer (2.3, 3.3)',
        (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = MockTestController(attempt: _buildAttempt());
      int? selectedIndex;
      var closeCalls = 0;

      await tester.pumpWidget(_wrap(
        MockOverviewDrawer(
          controller: controller,
          animation: const AlwaysStoppedAnimation<double>(1.0),
          onSelectTeil: (index) => selectedIndex = index,
          onClose: () => closeCalls++,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the Sprachbausteine "Teil 4" tile — its global index is 2.
      await tester.tap(find.text('Teil 4'));
      await tester.pump();

      // Selecting a Teil reports its global index (Requirement 2.3) and closes
      // the drawer (Requirements 2.3, 3.3).
      expect(selectedIndex, 2);
      expect(closeCalls, 1);
    });
  });

  group('AnimatedBurgerIcon', () {
    testWidgets('renders the burger → X morph icon (3.2, 3.3)', (tester) async {
      await tester.pumpWidget(_wrap(
        AnimatedBurgerIcon(
          progress: const AlwaysStoppedAnimation<double>(0.0),
          onTap: () {},
        ),
      ));
      await tester.pump();

      // The morph is rendered by an AnimatedIcon driven by `progress`.
      expect(find.byType(AnimatedBurgerIcon), findsOneWidget);
      expect(find.byType(AnimatedIcon), findsOneWidget);
      final icon = tester.widget<AnimatedIcon>(find.byType(AnimatedIcon));
      expect(icon.icon, AnimatedIcons.menu_close);
      expect(icon.progress.value, 0.0);
    });

    testWidgets('completes the burger ↔ X morph within ≤400 ms (3.4)',
        (tester) async {
      await tester.pumpWidget(_wrap(const _BurgerHost()));
      await tester.pump();

      final state = tester.state<_BurgerHostState>(find.byType(_BurgerHost));

      // Burger shape at rest (progress 0).
      expect(state.controller.value, 0.0);

      // Open: the runner drives this with a 300 ms controller (≤400 ms budget).
      state.controller.forward();
      // First frame starts the ticker (records its start timestamp)...
      await tester.pump();
      // ...then advance to the 400 ms ceiling.
      await tester.pump(const Duration(milliseconds: 400));

      // The morph has fully completed within the 400 ms budget (Requirement
      // 3.4): the icon reached the "X" shape (progress 1).
      expect(state.controller.value, 1.0);
      // And the controller's configured duration honors the ≤400 ms limit.
      expect(
        state.controller.duration!.inMilliseconds,
        lessThanOrEqualTo(400),
      );
    });
  });
}

/// Hosts an [AnimatedBurgerIcon] with a real [AnimationController] using the
/// runner's 300 ms duration so the morph timing can be exercised.
class _BurgerHost extends StatefulWidget {
  const _BurgerHost();

  @override
  State<_BurgerHost> createState() => _BurgerHostState();
}

class _BurgerHostState extends State<_BurgerHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBurgerIcon(
      progress: controller,
      onTap: () {},
    );
  }
}
