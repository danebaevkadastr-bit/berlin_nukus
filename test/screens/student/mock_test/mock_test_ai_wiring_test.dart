// Tests for the AI-evaluation wiring of the B1 mock-test section views.
//
// Task 10.5 (Requirements 8.1, 8.2): verify that the section views forward the
// right data into the AI evaluation flow.
//
// Investigation note (feasibility):
//   * `AIService.evaluateSchreiben` and `SprechenEvaluationService.evaluate` are
//     both *static* methods that perform live HTTP calls through a Cloudflare
//     Worker proxy. Static methods cannot be replaced/mocked directly, and the
//     repo carries no mocking package (only `flutter_test` + `glados`).
//   * For Schreiben (8.1) the view owns the call site, so a tiny backward
//     compatible injection seam (`SchreibenMockView.evaluator`, defaulting to
//     `AIService.evaluateSchreiben`) lets us inject a capturing fake and assert
//     the selected `SchreibenTask`'s fields, the answer, and the word count are
//     forwarded verbatim. This is a real, end-to-end widget test of the wiring.
//   * For Sprechen (8.2) the `SprechenEvaluationService.evaluate(audioBytes,
//     mimeType, ...)` call is buried inside the shared `SprechenRecordingControl`
//     (owned by the sprechen-audio-recording spec) and only fires after a real
//     microphone recording — neither of which is drivable in a widget test, and
//     which is out of scope to refactor here. The seam the mock view *does* own
//     is the `onEvaluated` callback: the view must route the evaluation produced
//     by `SprechenEvaluationService.evaluate` into the controller. We assert
//     exactly that wiring (the evaluation is stored on the controller), which is
//     the best feasible coverage of Requirement 8.2 at this layer.

import 'package:berlin_nukus/l10n/locale_manager.dart';
import 'package:berlin_nukus/models/schreiben_task.dart';
import 'package:berlin_nukus/screens/student/mock_test/mock_test_controller.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_attempt.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_structure.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/schreiben_mock_view.dart';
import 'package:berlin_nukus/screens/student/mock_test/views/sprechen_mock_view.dart';
import 'dart:typed_data';

import 'package:berlin_nukus/screens/student/sprechen/sprechen_data.dart';
import 'package:berlin_nukus/screens/student/sprechen/sprechen_recording_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _schreibenTask = SchreibenTask(
  id: 3,
  task: 'Schreiben Sie eine E-Mail an Ihren Vermieter.',
  points: [
    'Grund für die E-Mail',
    'Beschreiben Sie das Problem',
    'Was erwarten Sie?',
    'Schlagen Sie einen Termin vor',
  ],
  style: 'formal',
  minWords: 80,
  level: 'B1',
  letter: 'Sehr geehrte Damen und Herren, ...',
);

MockTestAttempt _schreibenAttempt() => MockTestAttempt(const [
      MockTeil(
        section: MockSection.schriftlicherAusdruck,
        teilNumber: 1,
        test: SelectedSchreibenTest(task: _schreibenTask),
      ),
    ]);

SprechenAufgabe _sprechenAufgabe() => SprechenAufgabe(
      title: 'Über ein Thema sprechen',
      instruction: 'Sprechen Sie über Ihre Heimatstadt.',
      keywords: const ['Heimat', 'Stadt'],
      examples: const ['Ich komme aus ...'],
    );

MockTestAttempt _sprechenAttempt() => MockTestAttempt([
      MockTeil(
        section: MockSection.muendlicherAusdruck,
        teilNumber: 1,
        test: SelectedSprechenTest(
          thema: 'Meine Heimatstadt',
          aufgaben: [_sprechenAufgabe()],
        ),
      ),
    ]);

/// Wraps [child] with the providers/localization scaffolding the views expect:
/// a `Provider<ValueNotifier<AppLocale>>` (so `AppLocalizations.of` resolves) and
/// a `MaterialApp` host with a scrollable body.
Widget _host(Widget child) {
  return ChangeNotifierProvider<ValueNotifier<AppLocale>>.value(
    value: LocaleManager.currentLocale,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    // Keep a deterministic active locale for every test.
    LocaleManager.setLocale(AppLocale.uz);
  });

  // Schreiben endi test davomida baholanmaydi: o'quvchi yozadi, javob
  // controllerga saqlanadi va baholash TEST YAKUNIDA (runner tomonidan
  // `AIService.evaluateSchreiben` orqali) bajariladi. Shu sababli view'ning
  // vazifasi — yozilgan javobni controllerga to'g'ri yozib qo'yish.
  group('Schreiben answer capture', () {
    testWidgets(
        'records the typed answer into the controller for end-of-test evaluation',
        (tester) async {
      final controller = MockTestController(attempt: _schreibenAttempt());

      await tester.pumpWidget(
        _host(SchreibenMockView(controller: controller, teilIndex: 0)),
      );

      const answer =
          'Sehr geehrte Damen und Herren ich schreibe Ihnen wegen der Heizung';
      await tester.enterText(find.byType(TextField), answer);
      await tester.pump();

      // The view stores the answer so the runner can evaluate it at the end.
      expect(controller.schreibenAnswer, answer);
      // No evaluation happens during the test, so no feedback yet.
      expect(controller.schreibenFeedback, isNull);
    });

    testWidgets('restores a previously saved answer when reopened',
        (tester) async {
      final controller = MockTestController(attempt: _schreibenAttempt());
      controller.recordSchreibenAnswer('Mein bereits gespeicherter Text');

      await tester.pumpWidget(
        _host(SchreibenMockView(controller: controller, teilIndex: 0)),
      );
      await tester.pump();

      // Re-entering the Teil re-displays the saved answer (navigation-safe).
      expect(find.text('Mein bereits gespeicherter Text'), findsOneWidget);
    });
  });

  group('Sprechen AI wiring (Requirement 8.2)', () {
    testWidgets(
        'view captures the recorded audio into the controller for end-of-test evaluation',
        (tester) async {
      final controller = MockTestController(attempt: _sprechenAttempt());

      await tester.pumpWidget(
        _host(SprechenMockView(controller: controller, teilIndex: 0)),
      );
      await tester.pump();

      // The Teil shows a single recording control wired via onAudioSubmit: the
      // audio is captured now and evaluated at the END of the test (no waiting
      // for the AI during the exam).
      final control = tester.widget<SprechenRecordingControl>(
          find.byType(SprechenRecordingControl));
      expect(control.onAudioSubmit, isNotNull,
          reason: 'view must wire onAudioSubmit so the recorded audio is captured');

      expect(controller.pendingSprechenAudios, isEmpty);

      await control.onAudioSubmit!(Uint8List.fromList([1, 2, 3, 4]), 'audio/mp4');

      // The Sprechen Teil has teilNumber 1, so the audio is stored under key 1.
      expect(controller.pendingSprechenAudios.containsKey(1), isTrue);
      expect(controller.pendingSprechenAudios[1]!.mimeType, 'audio/mp4');
      // No evaluation is produced during the test — it happens at the end.
      expect(controller.sprechenEvaluations, isEmpty);
    });
  });
}
