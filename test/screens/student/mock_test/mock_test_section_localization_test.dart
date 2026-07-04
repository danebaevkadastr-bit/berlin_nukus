// Localization widget tests for the B1 Mock Test section views.
//
// Task 10.6: Assert that switching the active locale changes app-authored
// labels (e.g. the "Frage"/question label, the "Text" label) while the German
// exam content (passages, prompts, options) is presented verbatim in German
// regardless of the active locale.
//
// Requirements:
//   * 11.1 — app-authored UI text is localized through AppLocalizations.
//   * 11.2 — German exam content (passages/prompts/options) is shown verbatim
//            in German and is NOT translated by the active locale.
//
// The active locale in this app is driven by a Provider<ValueNotifier<AppLocale>>
// (see AppLocalizations.of), not by MaterialApp's `locale`. So each pump wraps
// the view in that Provider with the locale under test.
//
// The simplest section view (no audio / no AI) is `LesenMockView`, so it is the
// one exercised here. A SelectedLesenTest with text-only content (no imageUrl)
// is used so no CachedNetworkImage is created during the test.

import 'package:berlin_nukus/l10n/locale_manager.dart';
import 'package:berlin_nukus/screens/student/lesen/lesen_data.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/lesen_mock_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── German exam content (verbatim, must never be translated) ─────────────────

const _germanText = 'Lesen Sie den folgenden deutschen Text aufmerksam.';
const _germanPassage = 'Die Bibliothek ist montags geschlossen.';
const _germanPrompt0 = 'Wann ist die Bibliothek geschlossen?';
const _germanOptions0 = ['Am Montag', 'Am Dienstag', 'Am Wochenende'];
const _germanPrompt1 = 'Welche Antwort ist korrekt?';
const _germanOptions1 = ['Erste Antwort', 'Zweite Antwort', 'Dritte Antwort'];

/// A single-Teil attempt holding a German Leseverstehen Test (text only, no
/// image so no network image widget is built).
MockTestAttempt _buildAttempt() {
  return MockTestAttempt([
    MockTeil(
      section: MockSection.leseverstehen,
      teilNumber: 1,
      test: SelectedLesenTest(
        questions: [
          LesenQuestion(
            passage: _germanPassage,
            prompt: _germanPrompt0,
            options: _germanOptions0,
            correctAnswer: _germanOptions0.first,
          ),
          LesenQuestion(
            prompt: _germanPrompt1,
            options: _germanOptions1,
            correctAnswer: _germanOptions1.first,
          ),
        ],
        text: _germanText,
      ),
    ),
  ]);
}

/// Wraps the view in the locale Provider used by AppLocalizations.of, so the
/// pumped tree resolves app-authored labels against [locale].
Widget _wrap(AppLocale locale, MockTestController controller) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: ValueNotifier<AppLocale>(locale),
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: LesenMockView(controller: controller, teilIndex: 0),
        ),
      ),
    ),
  );
}

/// Asserts the German exam content is rendered verbatim, whatever the locale.
void _expectGermanContentPresent() {
  expect(find.text(_germanPrompt0), findsOneWidget);
  expect(find.text(_germanPrompt1), findsOneWidget);
  for (final option in [..._germanOptions0, ..._germanOptions1]) {
    expect(find.text(option), findsOneWidget);
  }
}

void main() {
  group('LesenMockView localization', () {
    testWidgets(
        'app-authored question label is localized for Uzbek while German '
        'content stays German', (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());

      await tester.pumpWidget(_wrap(AppLocale.uz, controller));
      await tester.pumpAndSettle();

      // App-authored "Frage" label rendered in Uzbek ("Savol").
      expect(find.text('Savol 1'), findsOneWidget);
      expect(find.text('Savol 2'), findsOneWidget);
      // The Russian label must not appear under the Uzbek locale.
      expect(find.text('Вопрос 1'), findsNothing);
      // App-authored "Text" label (uppercased by the card) in Uzbek.
      expect(find.text('MATN'), findsWidgets);

      // German exam content is shown verbatim regardless of locale.
      _expectGermanContentPresent();
      expect(find.text(_germanText), findsOneWidget);
    });

    testWidgets(
        'app-authored question label is localized for Russian while German '
        'content stays German', (tester) async {
      final controller = MockTestController(attempt: _buildAttempt());

      await tester.pumpWidget(_wrap(AppLocale.ru, controller));
      await tester.pumpAndSettle();

      // App-authored "Frage" label rendered in Russian ("Вопрос").
      expect(find.text('Вопрос 1'), findsOneWidget);
      expect(find.text('Вопрос 2'), findsOneWidget);
      // The Uzbek label must not appear under the Russian locale.
      expect(find.text('Savol 1'), findsNothing);
      // App-authored "Text" label (uppercased by the card) in Russian.
      expect(find.text('ТЕКСТ'), findsWidgets);

      // German exam content is identical to the Uzbek render — never translated.
      _expectGermanContentPresent();
      expect(find.text(_germanText), findsOneWidget);
    });

    testWidgets(
        'switching locale changes app-authored labels but not German content',
        (tester) async {
      // Uzbek render.
      final uzController = MockTestController(attempt: _buildAttempt());
      await tester.pumpWidget(_wrap(AppLocale.uz, uzController));
      await tester.pumpAndSettle();
      expect(find.text('Savol 1'), findsOneWidget);
      expect(find.text('MATN'), findsWidgets);
      _expectGermanContentPresent();

      // Re-pump under Russian — app-authored labels switch language.
      final ruController = MockTestController(attempt: _buildAttempt());
      await tester.pumpWidget(_wrap(AppLocale.ru, ruController));
      await tester.pumpAndSettle();

      // Labels changed with the locale.
      expect(find.text('Savol 1'), findsNothing);
      expect(find.text('MATN'), findsNothing);
      expect(find.text('Вопрос 1'), findsOneWidget);
      expect(find.text('ТЕКСТ'), findsWidgets);

      // German exam content is unchanged across the locale switch.
      _expectGermanContentPresent();
      expect(find.text(_germanText), findsOneWidget);
    });
  });
}
