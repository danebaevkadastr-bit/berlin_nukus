import 'package:flutter_test/flutter_test.dart';
import 'package:berlin_nukus/l10n/app_localizations.dart';

void main() {
  const locales = ['uz', 'kaa', 'ru', 'de'];

  // Sprechen audio yozish funksiyasi uchun barcha yangi kalitlar.
  List<String> keysFor(AppLocalizations l) => [
        l.sprechenRecord,
        l.sprechenStop,
        l.sprechenReRecord,
        l.sprechenPlay,
        l.sprechenPause,
        l.sprechenSubmit,
        l.sprechenEvaluating,
        l.sprechenRecordingStatus,
        l.sprechenMaxLengthReached,
        l.sprechenMicPermissionDenied,
        l.sprechenMicPermissionSettings,
        l.sprechenOpenSettings,
        l.sprechenRecordingUnavailable,
        l.sprechenUploadError,
        l.sprechenEvaluationError,
        l.sprechenTimeoutError,
        l.sprechenRetry,
        l.sprechenFeedbackTitle,
        l.sprechenScore,
        l.sprechenPronunciation,
        l.sprechenFluency,
        l.sprechenGrammar,
        l.sprechenContent,
        l.sprechenOverall,
      ];

  test('Requirement 10.1: barcha sprechen audio kalitlari 4 tilda bo\'sh emas',
      () {
    for (final code in locales) {
      final l = AppLocalizations(code);
      final values = keysFor(l);
      for (final v in values) {
        expect(v.trim(), isNotEmpty,
            reason: '"$code" tilida bo\'sh kalit topildi');
      }
    }
  });

  test('Requirement 10.2: har til boshqa qiymat beradi (asosiy kalitlar)', () {
    final uz = AppLocalizations('uz');
    final de = AppLocalizations('de');
    final ru = AppLocalizations('ru');

    // Bir nechta kalitda tillar farqli ekanini tekshiramiz (tarjima qilingan).
    expect(uz.sprechenRecord, isNot(equals(de.sprechenRecord)));
    expect(de.sprechenSubmit, equals('Zur Bewertung senden'));
    expect(ru.sprechenScore, equals('Балл'));
    expect(uz.sprechenRetry, equals('Qayta urinish'));
  });

  test('Requirement 10.3: noma\'lum til uz ga fallback qiladi', () {
    final unknown = AppLocalizations('xx');
    final uz = AppLocalizations('uz');
    // Noma'lum kod uchun _t uz qiymatini qaytaradi.
    expect(unknown.sprechenRecord, equals(uz.sprechenRecord));
    expect(unknown.sprechenFeedbackTitle, equals(uz.sprechenFeedbackTitle));
  });
}
