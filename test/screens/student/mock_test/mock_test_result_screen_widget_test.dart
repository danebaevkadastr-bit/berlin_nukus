// Widget tests for the B1 Mock Test result screen.
//
// Task 11.3: Assert that the result screen presents per-Section normalized
// points, the written-part and oral-part totals, the pass/fail badges, and the
// "evaluation unavailable" note for any AI Section that could not be scored.
//
// Requirements: 9.1 (per-Section points normalized to the TELC B1 maxima are
// shown), 9.2 (the normalized point values), 9.3 (written/oral totals with the
// 60% pass/fail evaluation), 9.4 (every available Section is still presented),
// and 8.3 (an unavailable AI Section is shown with the unavailable note while
// the rest are still scored).
//
// These are example-based widget tests. The screen localizes app-authored text
// through `AppLocalizations.of(context)`, which reads a
// `ValueNotifier<AppLocale>` from a Provider; the tests mirror the app's
// `ChangeNotifierProvider.value` wiring and pin the locale to the Uzbek (`uz`)
// default so the asserted strings are deterministic. The German exam Section
// names stay German regardless of locale, per the localization requirements.
//
// `MockResult` is constructed directly so the presentation is exercised in
// isolation from the scorer and runner.

import 'package:berlin_nukus/l10n/locale_manager.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_result_screen.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_review.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_scorer.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── Test scaffolding ─────────────────────────────────────────────────────────

/// Wraps [child] in a MaterialApp with the locale Provider the screen expects.
/// The locale notifier is pinned to the supplied [locale] (default `uz`) so the
/// localized strings under test are deterministic.
Widget _wrap(Widget child, {AppLocale locale = AppLocale.uz}) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(home: child),
  );
}

/// Builds an empty [MockReview] that preserves [result] for the score-summary
/// assertions. The per-question review rows are covered separately in
/// `mock_test_result_screen_test.dart`; here the review lists are intentionally
/// empty so only the score summary (Sections, totals, badges, unavailable note)
/// is exercised.
MockReview _emptyReview(MockResult result) => MockReview(
      result: result,
      autoGraded: const [],
      aiSections: const [],
    );

void main() {
  group('MockTestResultScreen presentation', () {
    testWidgets(
        'shows per-Section points, totals, pass badges, and the unavailable '
        'note (9.1, 9.2, 9.3, 9.4, 8.3)', (tester) async {
      // A passing attempt with Schriftlicher Ausdruck unavailable. Every other
      // Section is still scored; the written/oral totals clear the 60%
      // threshold (written 155/225, oral 50/75).
      final result = MockResult(
        sectionPoints: const {
          MockSection.leseverstehen: 60,
          MockSection.sprachbausteine: 25,
          MockSection.hoerverstehen: 70,
          MockSection.muendlicherAusdruck: 50,
        },
        unavailableSections: const {MockSection.schriftlicherAusdruck},
        writtenPoints: 155,
        writtenMax: 225,
        oralPoints: 50,
        oralMax: 75,
      );

      await tester.pumpWidget(
          _wrap(MockTestResultScreen(result: result, review: _emptyReview(result))));
      await tester.pump();

      // Per-Section normalized points (9.1, 9.2), each out of the Section
      // maximum. Section names stay German.
      expect(find.text('Leseverstehen'), findsOneWidget);
      expect(find.text('60 / 75 ball'), findsOneWidget);
      expect(find.text('Sprachbausteine'), findsOneWidget);
      expect(find.text('25 / 30 ball'), findsOneWidget);
      expect(find.text('Hörverstehen'), findsOneWidget);
      expect(find.text('70 / 75 ball'), findsOneWidget);
      expect(find.text('Mündlicher Ausdruck'), findsOneWidget);

      // The unavailable AI Section is still listed by name, with the note in
      // place of a score (8.3, 9.4).
      expect(find.text('Schriftlicher Ausdruck'), findsOneWidget);
      expect(find.text('Baholash mavjud emas'), findsOneWidget);

      // Written/oral part totals (9.3). The written total appears once; the
      // oral total appears both on the part card and the Mündlicher Section
      // card (they share the same value by definition).
      expect(find.text('155 / 225 ball'), findsOneWidget);
      expect(find.text('50 / 75 ball'), findsNWidgets(2));
      expect(find.text('Yozma qism'), findsOneWidget);
      expect(find.text("Og'zaki qism"), findsOneWidget);

      // Both parts pass the 60% threshold, so both badges read "passed" and
      // none read "failed".
      expect(find.text("O'tdi"), findsNWidgets(2));
      expect(find.text("O'tmadi"), findsNothing);
    });

    testWidgets('shows fail badges when both parts miss the threshold (9.3)',
        (tester) async {
      // A failing attempt: written 25/225 and oral 10/75 both fall below 60%.
      final result = MockResult(
        sectionPoints: const {
          MockSection.leseverstehen: 10,
          MockSection.sprachbausteine: 5,
          MockSection.hoerverstehen: 5,
          MockSection.schriftlicherAusdruck: 5,
          MockSection.muendlicherAusdruck: 10,
        },
        unavailableSections: const {},
        writtenPoints: 25,
        writtenMax: 225,
        oralPoints: 10,
        oralMax: 75,
      );

      await tester.pumpWidget(
          _wrap(MockTestResultScreen(result: result, review: _emptyReview(result))));
      await tester.pump();

      // Both part totals are present. "10 / 75 ball" appears three times: the
      // Leseverstehen Section (10/75), the Mündlicher Section (10/75), and the
      // oral part card (10/75, which equals the Mündlicher Section value).
      expect(find.text('25 / 225 ball'), findsOneWidget);
      expect(find.text('10 / 75 ball'), findsNWidgets(3));

      // Both parts fail the 60% threshold, so both badges read "failed" and
      // none read "passed".
      expect(find.text("O'tmadi"), findsNWidgets(2));
      expect(find.text("O'tdi"), findsNothing);

      // With nothing unavailable, the unavailable note is absent and every
      // Section is presented (9.4).
      expect(find.text('Baholash mavjud emas'), findsNothing);
      for (final section in MockTestStructure.sectionOrder) {
        expect(find.text(mockSectionGermanNameForTest(section)), findsOneWidget);
      }
    });
  });
}

/// Mirrors the screen's German Section labels for the per-Section assertions.
String mockSectionGermanNameForTest(MockSection section) {
  switch (section) {
    case MockSection.leseverstehen:
      return 'Leseverstehen';
    case MockSection.sprachbausteine:
      return 'Sprachbausteine';
    case MockSection.hoerverstehen:
      return 'Hörverstehen';
    case MockSection.schriftlicherAusdruck:
      return 'Schriftlicher Ausdruck';
    case MockSection.muendlicherAusdruck:
      return 'Mündlicher Ausdruck';
  }
}
