// Widget tests for the B1 Mock Test redesigned bottom navigation bar.
//
// Task 8.2: Assert the MockNavBar's per-Teil control states — first, middle,
// and final Teil — verifying that:
//   * First Teil  (canGoBack=false): Previous hidden, Next enabled, Finish absent.
//   * Middle Teil (canGoBack=true, canGoNext=true): Previous shown, Next enabled,
//     Finish absent.
//   * Final Teil  (isFinalTeil=true, canGoNext=false): Next DISABLED (it never
//     becomes Finish), and a separate, enabled Finish control is present.
// It also verifies that tapping a disabled Next does nothing and that tapping
// Finish invokes the onFinish callback — so an attempt can never be finished
// early (Requirement 8.6).
//
// Requirements: 8.1 (Previous hidden on the first Teil), 8.2 (Next enabled on
// non-final Teile), 8.3 (Next disabled on the final Teil, never morphs into
// Finish), 8.4 (a separate Finish control on the final Teil), 8.6 (Finish only
// on the final Teil — no early finish).
//
// These are example-based widget tests. The MockNavBar localizes its
// app-authored labels through `AppLocalizations.of(context)`, which reads a
// `ValueNotifier<AppLocale>` from a Provider; the tests mirror the app's
// `ChangeNotifierProvider.value` wiring and pin the locale to the Uzbek (`uz`)
// default so the asserted labels ("Oldingi" / "Keyingi" / "Yakunlash") are
// deterministic.

import 'package:core/l10n/locale_manager.dart';
import 'package:berlin_nukus/screens/student/mock_test/widgets/mock_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── Test scaffolding ─────────────────────────────────────────────────────────

// Uzbek (`uz`) labels for the three controls, pinned by the locale Provider.
const String _previousLabel = 'Oldingi';
const String _nextLabel = 'Keyingi';
const String _finishLabel = 'Yakunlash';

/// Wraps [child] in a MaterialApp with the locale Provider the widget expects.
/// The locale notifier is pinned to the supplied [locale] (default `uz`) so the
/// localized labels under test are deterministic. The bar is placed at the
/// bottom of a Scaffold to mirror its real placement in the runner.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(
      home: Scaffold(bottomNavigationBar: child),
    ),
  );
}

/// Returns the single [ElevatedButton] that carries the given [label]. The Next
/// and Finish controls are both ElevatedButtons; Previous is an OutlinedButton.
/// Reading `.onPressed` lets the tests assert enabled (non-null) vs disabled
/// (null) state directly.
ElevatedButton _elevatedWith(String label) {
  final finder = find.widgetWithText(ElevatedButton, label);
  return finder.evaluate().single.widget as ElevatedButton;
}

void main() {
  group('MockNavBar control states', () {
    testWidgets('first Teil: Previous hidden, Next enabled, Finish absent (8.1, 8.2)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        MockNavBar(
          canGoBack: false,
          canGoNext: true,
          isFinalTeil: false,
          onPrevious: () {},
          onNext: () {},
          onFinish: () {},
        ),
      ));
      await tester.pump();

      // Previous is hidden on the first Teil (Requirement 8.1).
      expect(find.widgetWithText(OutlinedButton, _previousLabel), findsNothing);

      // Next is present and enabled (Requirement 8.2).
      expect(find.widgetWithText(ElevatedButton, _nextLabel), findsOneWidget);
      expect(_elevatedWith(_nextLabel).onPressed, isNotNull);

      // No Finish control anywhere but the final Teil (Requirement 8.6).
      expect(find.widgetWithText(ElevatedButton, _finishLabel), findsNothing);
    });

    testWidgets('middle Teil: Previous shown, Next enabled, Finish absent (8.2, 8.6)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        MockNavBar(
          canGoBack: true,
          canGoNext: true,
          isFinalTeil: false,
          onPrevious: () {},
          onNext: () {},
          onFinish: () {},
        ),
      ));
      await tester.pump();

      // Previous is shown and enabled on a middle Teil (Requirement 8.1).
      expect(find.widgetWithText(OutlinedButton, _previousLabel), findsOneWidget);

      // Next is present and enabled (Requirement 8.2).
      expect(find.widgetWithText(ElevatedButton, _nextLabel), findsOneWidget);
      expect(_elevatedWith(_nextLabel).onPressed, isNotNull);

      // Finish is still absent — the test cannot be finished early (8.6).
      expect(find.widgetWithText(ElevatedButton, _finishLabel), findsNothing);
    });

    testWidgets(
        'final Teil: Next disabled (never becomes Finish), separate Finish present and enabled (8.3, 8.4)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        MockNavBar(
          canGoBack: true,
          canGoNext: false,
          isFinalTeil: true,
          onPrevious: () {},
          onNext: () {},
          onFinish: () {},
        ),
      ));
      await tester.pump();

      // Previous is shown on the final Teil.
      expect(find.widgetWithText(OutlinedButton, _previousLabel), findsOneWidget);

      // Next is still present but DISABLED — it must not morph into Finish
      // (Requirement 8.3).
      expect(find.widgetWithText(ElevatedButton, _nextLabel), findsOneWidget);
      expect(_elevatedWith(_nextLabel).onPressed, isNull);

      // A separate, enabled Finish control appears only on the final Teil
      // (Requirements 8.4, 8.6).
      expect(find.widgetWithText(ElevatedButton, _finishLabel), findsOneWidget);
      expect(_elevatedWith(_finishLabel).onPressed, isNotNull);
    });
  });

  group('MockNavBar interactions', () {
    testWidgets('tapping the disabled Next on the final Teil does nothing (8.3)',
        (tester) async {
      var nextTaps = 0;
      await tester.pumpWidget(_wrap(
        MockNavBar(
          canGoBack: true,
          canGoNext: false,
          isFinalTeil: true,
          onPrevious: () {},
          onNext: () => nextTaps++,
          onFinish: () {},
        ),
      ));
      await tester.pump();

      // The Next control is disabled, so tapping it must not invoke onNext.
      await tester.tap(find.widgetWithText(ElevatedButton, _nextLabel));
      await tester.pump();
      expect(nextTaps, 0);
    });

    testWidgets('tapping Finish on the final Teil invokes onFinish (8.4, 8.5)',
        (tester) async {
      var finishTaps = 0;
      await tester.pumpWidget(_wrap(
        MockNavBar(
          canGoBack: true,
          canGoNext: false,
          isFinalTeil: true,
          onPrevious: () {},
          onNext: () {},
          onFinish: () => finishTaps++,
        ),
      ));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, _finishLabel));
      await tester.pump();
      expect(finishTaps, 1);
    });
  });
}
