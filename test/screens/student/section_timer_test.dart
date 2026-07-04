// Unit + widget tests for the B1 Mock Test Section timer.
//
// Covers:
//   * MockTestTiming.allowanceOf / blockKeyOf — Leseverstehen and
//     Sprachbausteine share a single block key and allowance (Requirements
//     5.2, 5.3).
//   * SectionTimer widget — the `warning` color state appears when the
//     remaining time drops into the warning window, and on time-up the distinct
//     expired label (l.mockTimerExpired) is shown instead of "00:00" while the
//     attempt is NOT auto-finished (Requirements 5.5, 5.6, 5.7, 5.8).
//
// The widget seeds each block's remaining time from MockTestTiming.allowanceOf
// and counts down via a periodic 1-second timer. The tests therefore advance
// the fake clock with tester.pump(Duration) so the periodic timer fires enough
// times to enter the warning and time-up phases. The Mündlicher Ausdruck
// (Sprechen) block has the shortest allowance (15 minutes), so it is used to
// reach those phases with the least elapsed time.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:berlin_nukus/l10n/locale_manager.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_timing.dart';
import 'package:berlin_nukus/screens/student/mock_test/widgets/section_timer.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/utils/app_colors.dart';

/// Builds a controller whose only Teil is a Mündlicher Ausdruck (Sprechen)
/// Teil, so the active block carries the shortest official allowance (15 min).
MockTestController _sprechenController() {
  final attempt = MockTestAttempt([
    MockTeil(
      section: MockSection.muendlicherAusdruck,
      teilNumber: 1,
      test: SelectedSprechenTest(
        aufgaben: const [
          SprechenAufgabe(title: 'Sich vorstellen', instruction: 'Stellen Sie sich vor.'),
        ],
      ),
    ),
  ]);
  return MockTestController(attempt: attempt);
}

/// Wraps [child] with the locale provider AppLocalizations depends on plus a
/// MaterialApp/Scaffold host.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier(locale),
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

/// Finds the single Icon rendered inside the [SectionTimer] banner.
Icon _timerIcon(WidgetTester tester) {
  return tester.widget<Icon>(
    find.descendant(of: find.byType(SectionTimer), matching: find.byType(Icon)),
  );
}

void main() {
  group('MockTestTiming.blockKeyOf', () {
    test('Leseverstehen and Sprachbausteine share one block key', () {
      expect(
        MockTestTiming.blockKeyOf(MockSection.leseverstehen),
        MockTestTiming.blockKeyOf(MockSection.sprachbausteine),
      );
    });

    test('every other Section has a distinct block key', () {
      final keys = {
        MockTestTiming.blockKeyOf(MockSection.leseverstehen),
        MockTestTiming.blockKeyOf(MockSection.hoerverstehen),
        MockTestTiming.blockKeyOf(MockSection.schriftlicherAusdruck),
        MockTestTiming.blockKeyOf(MockSection.muendlicherAusdruck),
      };
      // Lese/Sprachbausteine collapse to one key, leaving four unique keys.
      expect(keys.length, 4);
    });
  });

  group('MockTestTiming.allowanceOf', () {
    test('Leseverstehen and Sprachbausteine share the 90-minute allowance', () {
      expect(MockTestTiming.allowanceOf(MockSection.leseverstehen),
          const Duration(minutes: 90));
      expect(MockTestTiming.allowanceOf(MockSection.sprachbausteine),
          const Duration(minutes: 90));
      expect(
        MockTestTiming.allowanceOf(MockSection.leseverstehen),
        MockTestTiming.allowanceOf(MockSection.sprachbausteine),
      );
    });

    test('each remaining Section uses its official allowance', () {
      expect(MockTestTiming.allowanceOf(MockSection.hoerverstehen),
          const Duration(minutes: 30));
      expect(MockTestTiming.allowanceOf(MockSection.schriftlicherAusdruck),
          const Duration(minutes: 30));
      expect(MockTestTiming.allowanceOf(MockSection.muendlicherAusdruck),
          const Duration(minutes: 15));
    });

    test('warningThreshold is one minute', () {
      expect(MockTestTiming.warningThreshold, const Duration(minutes: 1));
    });
  });

  group('SectionTimer widget', () {
    testWidgets('builds and shows the seeded countdown in mm:ss', (tester) async {
      final controller = _sprechenController();
      await tester.pumpWidget(_wrap(SectionTimer(controller: controller)));

      // Sprechen allowance is 15 minutes → seeded at 15:00, normal phase.
      expect(find.text('15:00'), findsOneWidget);
      expect(_timerIcon(tester).icon, Icons.timer_rounded);

      // Unmount to cancel the periodic timer.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('enters the warning color state when time is low', (tester) async {
      final controller = _sprechenController();
      await tester.pumpWidget(_wrap(SectionTimer(controller: controller)));

      // Advance to 30s remaining (900s allowance - 870s), inside the 60s
      // warning window but above zero.
      await tester.pump(const Duration(seconds: 870));

      final icon = _timerIcon(tester);
      expect(icon.icon, Icons.timer_rounded);
      expect(icon.color, AppColors.duoOrange,
          reason: 'warning phase should use the warning color');
      expect(find.text('00:30'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'on time-up shows the expired label, not 00:00, and never finishes the attempt',
        (tester) async {
      final controller = _sprechenController();
      await tester.pumpWidget(_wrap(SectionTimer(controller: controller)));

      // Advance the full 15-minute allowance to reach zero.
      await tester.pump(const Duration(minutes: 15));

      // Distinct expired label is shown instead of "00:00" (Req 5.6).
      expect(find.text('Vaqt tugadi'), findsOneWidget);
      expect(find.text('00:00'), findsNothing);
      expect(_timerIcon(tester).icon, Icons.timer_off_rounded);
      expect(_timerIcon(tester).color, AppColors.duoRed);

      // The attempt is NOT auto-finished: the controller's position and answers
      // are untouched by the timer (Req 5.7).
      expect(controller.currentTeilIndex, 0);
      expect(controller.answers, isEmpty);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
