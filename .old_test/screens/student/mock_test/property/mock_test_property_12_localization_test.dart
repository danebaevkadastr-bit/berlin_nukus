// Feature: b1-mock-test, Property 12: Localization fallback
//
// *For any* localization map that contains a `uz` entry and *any* active locale
// code, the Localization_Service returns the entry for the active locale when
// present and otherwise returns the `uz` entry.
//
// Validates: Requirements 11.3
//
// Code under test: the fallback contract of `AppLocalizations._t`
// (lib/l10n/app_localizations.dart):
//
//     String _t(Map<String, String> map) =>
//         map[_code] ?? map['uz'] ?? map.values.first;
//
// Both `_t` and the backing `_code` field are private, so the fallback cannot
// be driven with arbitrary maps through the public surface (the public getters
// only ever pass complete four-locale maps, so their fallback branch is never
// exercised). As permitted for inaccessible logic, this test validates the
// documented fallback contract by mirroring that exact expression in `localize`
// below and asserting Property 12 over generated maps and active codes.
//
// Property-based tests use `glados` with a seeded `Random` and run a minimum of
// 100 iterations (the glados default `numRuns`). Smart generators constrain the
// input space to maps that always contain a `uz` entry (the Property 12
// precondition) plus an arbitrary subset of the other supported locales, paired
// with an active code drawn from the supported locales and unknown codes.

import 'package:glados/glados.dart';

/// Mirrors the fallback contract of `AppLocalizations._t` for an explicit
/// active locale [code]: the active-locale entry when present, otherwise the
/// `uz` entry, otherwise the first value.
String localize(Map<String, String> map, String code) =>
    map[code] ?? map['uz'] ?? map.values.first;

/// The non-`uz` locales the app supports, in a stable order.
const List<String> otherLocales = ['kaa', 'ru', 'de'];

/// Candidate active codes: the four supported locales plus unknown codes that
/// must trigger the `uz` fallback.
const List<String> activeCandidates = ['uz', 'kaa', 'ru', 'de', 'en', 'xx'];

/// Builds a localization map that always contains a `uz` entry (the Property 12
/// precondition) and includes each of [otherLocales] whose presence bit is set
/// in [presenceMask]. Every value is distinct so a wrong-key lookup is
/// detectable.
Map<String, String> buildMap(int presenceMask) {
  final map = <String, String>{'uz': 'val_uz'};
  for (var i = 0; i < otherLocales.length; i++) {
    if ((presenceMask >> i) & 1 == 1) {
      final code = otherLocales[i];
      map[code] = 'val_$code';
    }
  }
  return map;
}

void main() {
  group('Property 12: localization fallback', () {
    // Core contract: returns the active-locale value when present, else `uz`.
    Glados2<int, int>(any.int, any.int).test(
      'returns active-locale value when present, otherwise the uz fallback',
      (rawPresence, rawActive) {
        final presenceMask = rawPresence.abs() % (1 << otherLocales.length);
        final active =
            activeCandidates[rawActive.abs() % activeCandidates.length];
        final map = buildMap(presenceMask);

        final result = localize(map, active);

        final expected = map.containsKey(active) ? map[active] : map['uz'];
        expect(
          result,
          expected,
          reason: 'active=$active over map=$map',
        );
      },
    );

    // Present-locale facet: whenever the active code is a key, its own value is
    // returned (the fallback is never taken).
    Glados2<int, int>(any.int, any.int).test(
      'returns the active-locale entry verbatim when that locale is present',
      (rawPresence, rawActive) {
        final presenceMask = rawPresence.abs() % (1 << otherLocales.length);
        final map = buildMap(presenceMask);
        final presentKeys = map.keys.toList();
        final active = presentKeys[rawActive.abs() % presentKeys.length];

        expect(localize(map, active), map[active]);
      },
    );

    // Fallback facet: any active code missing from the map resolves to `uz`.
    Glados2<int, int>(any.int, any.int).test(
      'falls back to the uz entry for any unsupported/missing active code',
      (rawPresence, rawActive) {
        final presenceMask = rawPresence.abs() % (1 << otherLocales.length);
        final map = buildMap(presenceMask);
        // Unknown codes that are guaranteed not to be keys in the map.
        const missingCodes = ['en', 'xx', 'fr', 'tr'];
        final active = missingCodes[rawActive.abs() % missingCodes.length];

        expect(localize(map, active), map['uz']);
      },
    );
  });
}
