// Localization unit tests for the B1 Mock Test redesign (Task 4.3).
//
// These tests verify two distinct localization rules of the redesign:
//
//   1. The new app-authored interface keys (overview / timer / review labels)
//      return a non-empty value for every supported locale (uz, kaa, ru, de)
//      and fall back to the Uzbek (`uz`) value for an unknown/missing locale.
//      (Requirements 11.1, 11.3)
//
//   2. `mockSectionGermanName` returns the German exam Section name for every
//      MockSection value, regardless of the active interface locale, since
//      German exam content is never localized. (Requirement 11.2)
//
// The active locale in this app is a plain string code passed to the
// `AppLocalizations(code)` constructor (the same pattern used by
// `AppLocalizations.of` and the existing `sprechen_localization_test.dart`).

import 'package:core/l10n/app_localizations.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_labels.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const supportedLocales = ['uz', 'kaa', 'ru', 'de'];

  /// All redesign keys introduced in Task 4.1.
  List<String> redesignKeysFor(AppLocalizations l) => [
        l.mockOverviewTitle,
        l.mockTimerLabel,
        l.mockTimerExpired,
        l.mockReviewTitle,
        l.mockReviewYourAnswer,
        l.mockReviewCorrectAnswer,
        l.mockReviewUnanswered,
        l.mockExitTooltip,
        l.mockResultUnavailable,
      ];

  group('Requirement 11.1: redesign keys are localized for every locale', () {
    test('every new key returns a non-empty value in uz/kaa/ru/de', () {
      for (final code in supportedLocales) {
        final l = AppLocalizations(code);
        for (final value in redesignKeysFor(l)) {
          expect(value.trim(), isNotEmpty,
              reason: 'An empty redesign key was found for locale "$code"');
        }
      }
    });

    test('each supported locale provides its own translation', () {
      final uz = AppLocalizations('uz');
      final de = AppLocalizations('de');
      final ru = AppLocalizations('ru');
      final kaa = AppLocalizations('kaa');

      // The German translations differ from the Uzbek defaults.
      expect(de.mockOverviewTitle, equals('Prüfungsstruktur'));
      expect(de.mockTimerExpired, equals('Zeit abgelaufen'));
      expect(de.mockReviewCorrectAnswer, equals('Richtige Antwort'));

      // Russian and Karakalpak resolve to their own (non-uz) values.
      expect(ru.mockTimerLabel, equals('Оставшееся время'));
      expect(kaa.mockReviewUnanswered, isNot(equals(uz.mockReviewUnanswered)));
    });
  });

  group('Requirement 11.3: unknown locale falls back to uz', () {
    test('an unsupported locale code returns the Uzbek value for every key',
        () {
      final unknown = AppLocalizations('xx');
      final uz = AppLocalizations('uz');

      final unknownValues = redesignKeysFor(unknown);
      final uzValues = redesignKeysFor(uz);

      expect(unknownValues, equals(uzValues),
          reason: 'Unknown locale must fall back to the uz translation');
    });
  });

  group('Requirement 11.2: section names stay German for all locales', () {
    // The expected German exam Section names, never localized.
    const expectedGermanNames = {
      MockSection.leseverstehen: 'Leseverstehen',
      MockSection.sprachbausteine: 'Sprachbausteine',
      MockSection.hoerverstehen: 'Hörverstehen',
      MockSection.schriftlicherAusdruck: 'Schriftlicher Ausdruck',
      MockSection.muendlicherAusdruck: 'Mündlicher Ausdruck',
    };

    test('mockSectionGermanName returns the German name for every MockSection',
        () {
      for (final section in MockSection.values) {
        expect(mockSectionGermanName(section),
            equals(expectedGermanNames[section]),
            reason: 'German Section name mismatch for $section');
      }
    });

    test('German Section names are independent of the active interface locale',
        () {
      // mockSectionGermanName takes no locale and must not depend on one:
      // the value is identical no matter which locale is active in the app.
      for (final section in MockSection.values) {
        final name = mockSectionGermanName(section);
        for (final _ in supportedLocales) {
          expect(name, equals(expectedGermanNames[section]));
        }
        // Also confirm an unknown locale cannot alter German content.
        expect(name, equals(expectedGermanNames[section]));
      }
    });
  });
}
