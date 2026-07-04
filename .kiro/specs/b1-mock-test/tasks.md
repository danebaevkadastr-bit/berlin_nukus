# Implementation Plan: B1 Mock Test

## Overview

This plan builds the B1 Mock Test feature as a pure domain core (structure, assembler, attempt,
scorer) plus a thin Flutter presentation layer that reuses existing section UI patterns and AI
services. Work starts bottom-up: the official structure table and immutable attempt models first,
then the pure assembler and scorer (each validated by property tests against the design's
correctness properties), then the controller, and finally the screens and views wired into the
existing B1 mock-test entry point. Property tests use `package:test` with `glados` and run a
minimum of 100 iterations; each is tagged with its design property reference.

## Tasks

- [x] 1. Define the official exam structure and immutable attempt models
  - [x] 1.1 Create `MockTestStructure` and `TeilSpec`
    - Create `lib/screens/student/mock_test/model/mock_test_structure.dart`
    - Define `MockSection` enum (leseverstehen, sprachbausteine, hoerverstehen, schriftlicherAusdruck, muendlicherAusdruck)
    - Define `TeilSpec` (section, teilNumber, questionsPerTest) and the ordered `teilSpecs` list mapping every Teil to its source
    - Add `totalPoints` (300), `sectionMaxPoints`, `sectionOrder`, `writtenSections`, `oralSection`
    - _Requirements: 1.2, 5.1, 5.2, 5.3, 9.2, 10.3_

  - [x] 1.2 Create `SelectedTest` sealed hierarchy and attempt models
    - Create `lib/screens/student/mock_test/model/mock_test_attempt.dart`
    - Define `SelectedLesenTest`, `SelectedHorenTest`, `SelectedSchreibenTest`, `SelectedSprechenTest`
    - Define `MockTeil` (section, teilNumber, test) and `MockTestAttempt` (ordered `teile`, `sectionTeile(section)`)
    - Wrap all lists with `List.unmodifiable` and mark fields `final` so the attempt is immutable after construction
    - Define `AnswerKey` (teilIndex, questionIndex) with value equality (`==`/`hashCode`)
    - _Requirements: 3.1, 3.2, 3.3, 4.1_

  - [x] 1.3 Create `MockAssemblyException`
    - Create `lib/screens/student/mock_test/model/mock_test_exceptions.dart`
    - Carry the offending `MockSection` and `teilNumber` for diagnostics
    - _Requirements: 12.1, 12.2_

- [x] 2. Implement the pure assembler (test-level random selection)
  - [x] 2.1 Implement `MockTestAssembler.chunk` and `selectIndex`
    - Create `lib/screens/student/mock_test/model/mock_test_assembler.dart`
    - `chunk<T>(questions, perTest)` splits a flat list into contiguous Tests
    - `selectIndex(rng, count)` returns a uniform index in `[0, count)`, returning 0 when `count == 1`
    - _Requirements: 2.1, 2.3, 2.4_

  - [x] 2.2 Implement `MockTestAssembler.assemble`
    - Inject `Random rng`; default sources to `lesenB1`, `horenB1`, `schreibenTasksB1`, `sprechenB1`
    - Lesen: chunk each `LesenTeil` by `questionsPerTest`, pick group `g`, carry the slice plus `testTexts?[g]`/`testImages?[g]` (fall back to `sharedText` when no per-test text)
    - Hören: chunk each `HorenTeil` by 5 (Teil 1, 3) or 10 (Teil 2), pick one group (audio is intrinsic to each question)
    - Schreiben: pick one `SchreibenTask` from the list
    - Sprechen: pick one `SprechenTest` when `tests` is non-empty, otherwise use the single `aufgaben` group
    - Emit `teile` already ordered by official Section order then ascending `teilNumber`
    - Throw `MockAssemblyException` when any required Teil exposes zero Tests
    - _Requirements: 1.1, 1.3, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 12.1, 12.2_

  - [x]* 2.3 Write property test for whole-unit verbatim selection
    - **Property 1: Whole-unit verbatim selection**
    - **Validates: Requirements 1.1, 1.3, 2.2, 3.1, 3.2, 3.3, 3.5**
    - Use `glados` with synthetic source generators and seeded `Random`; min 100 iterations
    - Tag: `// Feature: b1-mock-test, Property 1`

  - [x]* 2.4 Write property test for structural completeness
    - **Property 2: Structural completeness**
    - **Validates: Requirements 1.2**
    - Assert exactly one selected Test per `teilSpecs` entry, no missing/extra Teile
    - Tag: `// Feature: b1-mock-test, Property 2`

  - [x]* 2.5 Write property test for valid and reachable random selection
    - **Property 3: Valid and reachable random selection**
    - **Validates: Requirements 2.1, 2.3, 2.4**
    - Cover the single-Test boundary and reachability of every index across the seed space
    - Tag: `// Feature: b1-mock-test, Property 3`

  - [x]* 2.6 Write property test for Lesen auxiliary content alignment
    - **Property 4: Lesen auxiliary content alignment**
    - **Validates: Requirements 3.4**
    - Assert text equals `testTexts[g]` (or `sharedText`) and image equals `testImages[g]` for selected group `g`
    - Tag: `// Feature: b1-mock-test, Property 4`

  - [x]* 2.7 Write property test for section and Teil ordering
    - **Property 5: Section and Teil ordering**
    - **Validates: Requirements 5.1, 5.2, 5.3**
    - Assert official Section grouping/order and ascending `teilNumber`; written precedes oral
    - Tag: `// Feature: b1-mock-test, Property 5`

  - [x]* 2.8 Write property test for fresh, independent assembly per attempt
    - **Property 8: Fresh, independent assembly per Attempt**
    - **Validates: Requirements 4.4**
    - Assert two independent rng sources produce internally valid, independent attempts
    - Tag: `// Feature: b1-mock-test, Property 8`

- [x] 3. Checkpoint - assembler complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Implement the pure scorer and result model
  - [x] 4.1 Implement `MockResult` and `MockTestScorer`
    - Create `lib/screens/student/mock_test/model/mock_test_scorer.dart`
    - `autoGradeCount` counts correct presented answers; unanswered => incorrect
    - `normalize(correct, total, max)` does linear normalization clamped to `[0, max]`
    - `parseAiFraction(rawScore)` parses `"X/Y"`; null/unparseable => null
    - `score(...)` produces `MockResult` (per-section points, `unavailableSections`, written/oral totals and maxima, `writtenPassed`/`oralPassed` at 60%)
    - _Requirements: 7.1, 7.2, 7.3, 8.3, 9.1, 9.2, 9.3, 9.4_

  - [x]* 4.2 Write property test for auto-graded scoring
    - **Property 9: Auto-graded scoring**
    - **Validates: Requirements 7.1, 7.2, 7.3**
    - Use answer-map generators (correct/incorrect/unanswered); assert count bounds and unanswered handling
    - Tag: `// Feature: b1-mock-test, Property 9`

  - [x]* 4.3 Write property test for point normalization
    - **Property 10: Point normalization**
    - **Validates: Requirements 9.2**
    - Assert range `[0, sectionMax]`, 0 at zero correct, `sectionMax` at all correct, monotonic non-decreasing
    - Tag: `// Feature: b1-mock-test, Property 10`

  - [x]* 4.4 Write property test for result totals, pass thresholds, and unavailable sections
    - **Property 11: Result totals, pass thresholds, and unavailable sections**
    - **Validates: Requirements 8.3, 9.1, 9.3, 9.4**
    - Assert written total bounded by 225, oral by 75, pass flags at 60%, unavailable AI section flagged while others still scored
    - Tag: `// Feature: b1-mock-test, Property 11`

- [x] 5. Checkpoint - scorer complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Implement the attempt controller
  - [x] 6.1 Implement `MockTestController`
    - Create `lib/screens/student/mock_test/mock_test_controller.dart`
    - Hold the immutable `MockTestAttempt`, `currentTeilIndex`, `answers` map, and AI results (`schreibenFeedback`, `sprechenEvaluation`)
    - `selectAnswer(key, option)` preserved across navigation; `next()`/`previous()` move within `teile` without changing content; `isOnFinalTeil`; `buildResult()` delegates to `MockTestScorer`
    - Never replace the held attempt during the attempt
    - _Requirements: 4.1, 4.2, 4.3, 6.1, 6.2, 6.3_

  - [x]* 6.2 Write property test for attempt immutability
    - **Property 6: Attempt immutability**
    - **Validates: Requirements 4.1, 4.2**
    - Drive navigation-action sequences; assert re-reading any Teil yields identical questions/order
    - Tag: `// Feature: b1-mock-test, Property 6`

  - [x]* 6.3 Write property test for answer preservation across navigation
    - **Property 7: Answer preservation across navigation**
    - **Validates: Requirements 4.3**
    - Interleave `selectAnswer` with `next`/`previous`; assert each answered question keeps its latest option
    - Tag: `// Feature: b1-mock-test, Property 7`

  - [x]* 6.4 Write unit tests for controller navigation
    - Test `next`/`previous`/`isOnFinalTeil` transitions and answer recording
    - _Requirements: 6.1, 6.2, 6.3_

- [x] 7. Implement the localization fallback verification
  - [x]* 7.1 Write property test for localization fallback
    - **Property 12: Localization fallback**
    - **Validates: Requirements 11.3**
    - Generate localization maps containing a `uz` entry and arbitrary active codes; assert active-locale value when present, else `uz`
    - Tag: `// Feature: b1-mock-test, Property 12`

- [x] 8. Checkpoint - domain core and controller complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Implement the intro screen and runner host
  - [x] 9.1 Implement `MockTestIntroScreen`
    - Create `lib/screens/student/mock_test/mock_test_intro_screen.dart`
    - Display official timing (Leseverstehen + Sprachbausteine combined 90 min, Hörverstehen listening allowance, Schriftlicher Ausdruck 30 min, Mündlicher Ausdruck preparation + speaking) and the 300-point total
    - Start button triggers `MockTestAssembler.assemble`; on `MockAssemblyException` show a localized "cannot be assembled" message and do not start
    - Route all app-authored text through `AppLocalizations._t`
    - _Requirements: 10.1, 10.2, 10.3, 11.1, 11.2, 12.1, 12.2_

  - [x] 9.2 Implement `MockTestRunnerScreen`
    - Create `lib/screens/student/mock_test/mock_test_runner_screen.dart`
    - Host a non-shuffling navigator over `attempt.teile`, show position indicator ("Section · Teil n"), advance control, and a complete control on the final Teil that routes to the result screen
    - Intercept back navigation with a localized confirmation dialog (`PopScope`)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 11.1_

  - [x] 9.3 Wire the B1 entry point to the intro screen
    - Update `lib/screens/student/mock_test_screen.dart` so selecting B1 routes to `MockTestIntroScreen` instead of the "coming soon" dialog
    - _Requirements: 1.1_

  - [x]* 9.4 Write widget tests for intro/runner navigation and timing display
    - Assert timing/points display (90-min combined, listening, 30-min Schreiben, Mündlich prep+speaking, per-section points, 300 total)
    - Assert completing on the final Teil routes to the result screen and back navigation shows the confirmation dialog
    - _Requirements: 6.3, 6.4, 10.1, 10.2, 10.3_

- [x] 10. Implement the section views
  - [x] 10.1 Implement `lesen_mock_view`
    - Create `lib/screens/student/mock_test/views/lesen_mock_view.dart`
    - Mirror `lesen_question_screen`: render passage/image + options, record answers via `selectAnswer`
    - _Requirements: 3.4, 7.1, 11.1, 11.2_

  - [x] 10.2 Implement `horen_mock_view`
    - Create `lib/screens/student/mock_test/views/horen_mock_view.dart`
    - Mirror `horen_question_screen`: `audioplayers` playback per question + options, with audio-error retry UI
    - _Requirements: 3.5, 7.1, 11.1, 11.2_

  - [x] 10.3 Implement `schreiben_mock_view`
    - Create `lib/screens/student/mock_test/views/schreiben_mock_view.dart`
    - Mirror `schreiben_screen` (letter + 4 points + text field); submit via `AIService.evaluateSchreiben` and store feedback on the controller; on failure flag the section unavailable and allow continuing
    - _Requirements: 8.1, 8.3, 11.1, 11.2_

  - [x] 10.4 Implement `sprechen_mock_view`
    - Create `lib/screens/student/mock_test/views/sprechen_mock_view.dart`
    - Embed the existing `sprechen_recording_control` widget and `SprechenEvaluationService.evaluate`; store the evaluation on the controller; on failure/denied mic surface localized error and flag the section unavailable
    - _Requirements: 8.2, 8.3, 11.1, 11.2_

  - [x]* 10.5 Write tests for AI-evaluation wiring
    - With a mocked `AIService.evaluateSchreiben`, assert it is called with the selected `SchreibenTask`'s `task`, `points`, `style`, `minWords`, `letter`, and the student's answer/word count
    - With a mocked `SprechenEvaluationService.evaluate`, assert it is invoked with the recorded audio bytes and mime type
    - _Requirements: 8.1, 8.2_

  - [x]* 10.6 Write localization widget tests for section views
    - Assert switching locale changes app-authored labels while German passages/questions stay German
    - _Requirements: 11.1, 11.2_

- [x] 11. Implement the result screen and final wiring
  - [x] 11.1 Implement `MockTestResultScreen`
    - Create `lib/screens/student/mock_test/mock_test_result_screen.dart`
    - Render per-Section points normalized to TELC maxima, written and oral totals, and pass/fail badges; show an "evaluation unavailable" note for any AI section that failed while still presenting the rest
    - Route all app-authored text through `AppLocalizations._t`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 8.3, 11.1_

  - [x] 11.2 Wire runner completion to the result screen
    - Connect `MockTestRunnerScreen` completion to `controller.buildResult()` and navigation into `MockTestResultScreen`
    - _Requirements: 6.3, 9.1_

  - [x]* 11.3 Write widget test for result presentation
    - Assert per-section normalized points, written/oral totals, pass/fail badges, and the unavailable-section note
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 8.3_

- [x] 12. Final checkpoint - ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional test sub-tasks and can be skipped for a faster MVP.
- Each task references specific requirements for traceability.
- Checkpoints ensure incremental validation as the domain core, controller, and UI come together.
- Property tests (Properties 1–12) validate the pure assembly and scoring core via `glados` with a minimum of 100 iterations each; unit/widget/mock tests cover navigation, AI wiring, timing/points display, and localization.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["2.2", "4.1"] },
    { "id": 3, "tasks": ["2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "4.2", "4.3", "4.4", "6.1", "7.1"] },
    { "id": 4, "tasks": ["6.2", "6.3", "6.4", "9.1", "9.2"] },
    { "id": 5, "tasks": ["9.3", "10.1", "10.2", "10.3", "10.4", "11.1"] },
    { "id": 6, "tasks": ["9.4", "10.5", "10.6", "11.2", "11.3"] }
  ]
}
```
