// Widget tests for the B1 Mock Test horizontal question-navigation strip.
//
// Task 7.2: Verify that tapping a question indicator reports the tapped index
// through `onSelect` (Requirement 4.2), that the active question is visually
// distinguished from the others (Requirement 4.1/4.2), and that answered vs
// unanswered questions render differently (Requirement 4.4).
//
// `MockQuestionStrip` is purely presentational and reads its accent/dark-mode
// colors from the static `ThemeManager` notifiers, which default to the light
// theme and the green accent preset. The tests therefore only need to pump the
// widget inside a `MaterialApp` — no Provider or async setup is required. The
// active indicator is filled with `ThemeManager.accent`, answered (non-active)
// indicators carry a small `Icons.check_rounded` marker, and every indicator
// shows its 1-based number, giving reliable, presentation-stable anchors.

import 'package:berlin_nukus/screens/student/mock_test/widgets/mock_question_strip.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a [MockQuestionStrip] inside a minimal MaterialApp scaffold.
Future<void> _pumpStrip(
  WidgetTester tester, {
  required int count,
  required int activeIndex,
  required bool Function(int) isAnswered,
  required void Function(int) onSelect,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MockQuestionStrip(
          count: count,
          activeIndex: activeIndex,
          isAnswered: isAnswered,
          onSelect: onSelect,
        ),
      ),
    ),
  );
  await tester.pump();
}

/// The 44x44 indicator [Container] whose label is [label] (e.g. '3').
Container _indicatorFor(WidgetTester tester, String label) {
  final container = find
      .ancestor(of: find.text(label), matching: find.byType(Container))
      .first;
  return tester.widget<Container>(container);
}

void main() {
  group('MockQuestionStrip', () {
    testWidgets(
        'renders one numbered indicator per question (Requirement 4.1)',
        (tester) async {
      await _pumpStrip(
        tester,
        count: 4,
        activeIndex: 0,
        isAnswered: (_) => false,
        onSelect: (_) {},
      );

      // 1-based numbering for every question in the active Teil.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('tapping an indicator reports its index (Requirement 4.2)',
        (tester) async {
      final tapped = <int>[];
      await _pumpStrip(
        tester,
        count: 4,
        activeIndex: 0,
        isAnswered: (_) => false,
        onSelect: tapped.add,
      );

      // Tap the third indicator → onSelect fires with index 2 (0-based).
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(tapped, [2]);

      // Tap the first indicator → onSelect fires with index 0.
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(tapped, [2, 0]);
    });

    testWidgets(
        'the active question is filled with the accent color (Requirement 4.2)',
        (tester) async {
      await _pumpStrip(
        tester,
        count: 3,
        activeIndex: 1,
        isAnswered: (_) => false,
        onSelect: (_) {},
      );

      // The active indicator (index 1, label '2') uses the accent fill, while
      // an inactive, unanswered indicator does not.
      final activeDecoration =
          _indicatorFor(tester, '2').decoration as BoxDecoration;
      final inactiveDecoration =
          _indicatorFor(tester, '1').decoration as BoxDecoration;

      expect(activeDecoration.color, ThemeManager.accent);
      expect(inactiveDecoration.color, isNot(ThemeManager.accent));
    });

    testWidgets(
        'answered and unanswered questions render differently (Requirement 4.4)',
        (tester) async {
      // Question index 2 is answered; the others are not. None is active, so
      // the answered marker is the distinguishing affordance.
      await _pumpStrip(
        tester,
        count: 4,
        activeIndex: 0,
        isAnswered: (i) => i == 2,
        onSelect: (_) {},
      );

      // Exactly one answered (non-active) indicator → exactly one check marker.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // The answered indicator's fill differs from an unanswered indicator's.
      final answeredDecoration =
          _indicatorFor(tester, '3').decoration as BoxDecoration; // index 2
      final unansweredDecoration =
          _indicatorFor(tester, '4').decoration as BoxDecoration; // index 3
      expect(answeredDecoration.color, isNot(unansweredDecoration.color));
    });

    testWidgets('an answered question that is active shows no extra marker',
        (tester) async {
      // When the answered question is also active, the accent fill — not the
      // check marker — communicates state (the marker is suppressed).
      await _pumpStrip(
        tester,
        count: 3,
        activeIndex: 2,
        isAnswered: (i) => i == 2,
        onSelect: (_) {},
      );

      expect(find.byIcon(Icons.check_rounded), findsNothing);
      final activeDecoration =
          _indicatorFor(tester, '3').decoration as BoxDecoration;
      expect(activeDecoration.color, ThemeManager.accent);
    });
  });
}
