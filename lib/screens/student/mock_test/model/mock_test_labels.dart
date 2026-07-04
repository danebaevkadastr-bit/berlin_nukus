// Presentation-layer labels for the B1 Mock Test redesign.
//
// This file holds UI-facing label helpers that intentionally live *outside* the
// domain core (`mock_test_structure.dart`), so the official exam structure stays
// untouched (Requirement 10). German exam Section names are never localized —
// they remain in German regardless of the current app locale (Requirements 2.6,
// 11.2).

import 'mock_test_structure.dart';

/// Returns the official German name of a [MockSection].
///
/// The returned name is always in German (Leseverstehen, Sprachbausteine,
/// Hörverstehen, Schriftlicher Ausdruck, Mündlicher Ausdruck) regardless of the
/// current interface locale, since these are German exam content rather than
/// app-authored interface text (Requirements 2.6, 11.2).
String mockSectionGermanName(MockSection section) {
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
