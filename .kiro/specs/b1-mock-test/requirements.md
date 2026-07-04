# Requirements Document

## Introduction

The B1 Mock Test (TELC Deutsch B1 — vollständige Übungsprüfung) is a new screen that lets a
student sit a complete, exam-like practice run of the TELC Deutsch B1 examination inside the
existing Flutter app. The mock test does **not** introduce any new question content. Instead it
**assembles** an exam from the content that already exists in the app's B1 learning sections —
Lesen (`lesenB1`), Hören (`horenB1`), Schreiben (`schreibenTasksB1`), and Sprechen (`sprechenB1`).

The defining behavior is **test-level random selection**: for each section/Teil, the app picks one
complete pre-authored "test" (a whole Aufgabe group) at random from the tests available for that
Teil. The individual questions inside the chosen test stay together and keep their original order —
they are never shuffled or mixed across tests. Once a mock attempt is assembled, the selected
content is frozen for the whole attempt.

The screen follows the official TELC B1 section ordering and surfaces the official timing and points
information. Reading and listening parts are auto-graded; the writing and speaking parts reuse the
existing AI-evaluation flows. All user-facing text honors the app's four locales (uz, kaa, ru, de).

## Glossary

- **Mock_Test**: The complete TELC B1 practice exam screen and its controlling logic.
- **Section**: One of the four TELC B1 exam areas: Lesen (Leseverstehen + Sprachbausteine), Hören,
  Schreiben, Sprechen.
- **Teil**: A numbered subpart of a Section (for example Lesen Teil 1, Hören Teil 2), matching the
  `teilNumber` fields in the existing data models.
- **Test**: A single complete, pre-authored Aufgabe group for one Teil — the smallest unit selected
  at random. Concretely:
  - Lesen: a contiguous group of `questionsPerTest` questions within a `LesenTeil` (and the matching
    entry in `testTexts` / `testImages` when present).
  - Hören: a contiguous group of questions within a `HorenTeil` (5 questions per Test for Teil 1 and
    Teil 3, 10 questions per Test for Teil 2, per the existing `horen_question_screen` grouping).
  - Schreiben: one `SchreibenTask` from `schreibenTasksB1`.
  - Sprechen: for a `SprechenTeil` that has `tests`, one `SprechenTest`; for a `SprechenTeil` that
    has only `aufgaben`, the single `aufgaben` group is the only Test.
- **Question**: A single item inside a Test (`LesenQuestion`, `HorenQuestion`, a Schreiben prompt
  point set, or a `SprechenAufgabe`).
- **Attempt**: One started run of the Mock_Test, from assembly through to the result screen.
- **Assembly**: The act of selecting one Test per Teil to build an Attempt.
- **Auto_Graded_Section**: Lesen and Hören, where answers are scored automatically by comparing the
  selected option to `correctAnswer`.
- **AI_Evaluated_Section**: Schreiben and Sprechen, scored by the existing AI-evaluation flows.
- **Result_Summary**: The end-of-attempt screen presenting scores, points, and pass/fail status.
- **Pass_Threshold**: 60% of the available points, evaluated separately for the written part and the
  oral part, per TELC B1 rules.
- **Localization_Service**: The existing `AppLocalizations._t({...})` mechanism that returns text for
  the active locale (uz, kaa, ru, de).

## Requirements

### Requirement 1: Assemble a mock test from existing section content

**User Story:** As a B1 student, I want the mock test to be built from the questions already in the
learning sections, so that I practice with familiar, validated content and no new material is needed.

#### Acceptance Criteria

1. WHEN a student starts a new Attempt, THE Mock_Test SHALL build the Attempt using only content from
   `lesenB1`, `horenB1`, `schreibenTasksB1`, and `sprechenB1`.
2. THE Mock_Test SHALL include one Test for every Teil that the TELC B1 structure defines across the
   Lesen, Hören, Schreiben, and Sprechen Sections.
3. WHEN building an Attempt, THE Mock_Test SHALL NOT create, alter, or synthesize Question content
   beyond what exists in the source data models.

### Requirement 2: Random selection at the Test level

**User Story:** As a B1 student, I want each section to use a randomly chosen complete test, so that
repeated attempts feel varied while each test stays internally coherent.

#### Acceptance Criteria

1. WHEN assembling an Attempt, THE Mock_Test SHALL select, for each Teil, one Test chosen at random
   from the Tests available for that Teil.
2. WHILE selecting a Test for a Teil, THE Mock_Test SHALL choose the Test as a whole unit and SHALL
   NOT select individual Questions independently.
3. WHERE a Teil exposes more than one Test, THE Mock_Test SHALL give every available Test a non-zero
   probability of being selected.
4. WHERE a Teil exposes exactly one Test, THE Mock_Test SHALL select that single Test for the Teil.

### Requirement 3: Preserve question grouping and order within a selected test

**User Story:** As a B1 student, I want the questions inside a chosen test to stay together and in
order, so that the practice matches how the real exam presents each Aufgabe.

#### Acceptance Criteria

1. WHEN a Test is selected for a Teil, THE Mock_Test SHALL present the Questions of that Test in the
   same order in which they appear in the source data model.
2. THE Mock_Test SHALL present only Questions that belong to the selected Test for a given Teil.
3. THE Mock_Test SHALL keep every Question of a selected Test together within that Teil and SHALL NOT
   combine Questions from different Tests in the same Teil.
4. WHERE a selected Lesen Test has an associated entry in `testTexts` or `testImages`, THE Mock_Test
   SHALL present the text or image entry that corresponds to that selected Test.
5. WHERE a selected Hören Test has associated audio, THE Mock_Test SHALL present the audio that
   corresponds to the Questions of that selected Test.

### Requirement 4: Question immutability during an attempt

**User Story:** As a B1 student, I want the questions to stay fixed once my test starts, so that the
content does not change while I work through the exam.

#### Acceptance Criteria

1. WHEN an Attempt has been assembled, THE Mock_Test SHALL keep the selected Tests and their
   Questions unchanged for the entire duration of that Attempt.
2. WHILE an Attempt is in progress, THE Mock_Test SHALL re-display the same Questions when the
   student navigates back to a previously visited Teil.
3. WHILE an Attempt is in progress, THE Mock_Test SHALL preserve each answer the student has entered
   when the student navigates between Teile.
4. WHEN the student starts a new Attempt after finishing or leaving a previous one, THE Mock_Test
   SHALL perform a fresh Assembly for the new Attempt.

### Requirement 5: TELC B1 section and Teil ordering

**User Story:** As a B1 student, I want the mock test to follow the official TELC B1 order, so that my
practice mirrors the real exam flow.

#### Acceptance Criteria

1. THE Mock_Test SHALL present the Sections in the official TELC B1 order: Leseverstehen, then
   Sprachbausteine, then Hörverstehen, then Schriftlicher Ausdruck, then Mündlicher Ausdruck.
2. WITHIN each Section, THE Mock_Test SHALL present the Teile in ascending `teilNumber` order.
3. THE Mock_Test SHALL present the written Sections (Lesen, Sprachbausteine, Hören, Schreiben) before
   the oral Section (Sprechen).

### Requirement 6: Navigation through the attempt

**User Story:** As a B1 student, I want to move through the sections of the mock test in a controlled
way, so that I can complete the whole exam and reach my results.

#### Acceptance Criteria

1. WHILE an Attempt is in progress, THE Mock_Test SHALL allow the student to advance from the current
   Teil to the next Teil in the defined order.
2. WHILE an Attempt is in progress, THE Mock_Test SHALL display the student's current position within
   the Attempt, identifying the active Section and Teil.
3. WHEN the student reaches the final Teil and requests completion, THE Mock_Test SHALL present the
   Result_Summary.
4. IF the student attempts to leave an in-progress Attempt, THEN THE Mock_Test SHALL request
   confirmation before discarding the Attempt.

### Requirement 7: Auto-graded scoring for Lesen and Hören

**User Story:** As a B1 student, I want my reading and listening answers scored automatically, so that
I get immediate, objective results for those sections.

#### Acceptance Criteria

1. WHEN the student submits an answer for a Question in an Auto_Graded_Section, THE Mock_Test SHALL
   determine correctness by comparing the selected option to the Question's `correctAnswer`.
2. WHEN an Attempt is completed, THE Mock_Test SHALL compute, for each Auto_Graded_Section, the count
   of correctly answered Questions out of the total presented Questions.
3. IF a Question in an Auto_Graded_Section is left unanswered when the Attempt is completed, THEN THE
   Mock_Test SHALL score that Question as incorrect.

### Requirement 8: AI evaluation for Schreiben and Sprechen

**User Story:** As a B1 student, I want my writing and speaking responses evaluated, so that I receive
feedback on the productive sections of the exam.

#### Acceptance Criteria

1. WHEN the student submits a Schreiben response, THE Mock_Test SHALL evaluate the response using the
   existing Schreiben AI-evaluation flow.
2. WHEN the student submits a Sprechen response, THE Mock_Test SHALL evaluate the response using the
   existing Sprechen audio-recording and AI-evaluation flow.
3. IF an AI evaluation cannot be completed for an AI_Evaluated_Section, THEN THE Mock_Test SHALL
   inform the student that the evaluation is unavailable and SHALL allow the student to view the rest
   of the Result_Summary.

### Requirement 9: Result summary aligned with TELC B1 points

**User Story:** As a B1 student, I want a results screen that reflects the official TELC B1 points and
pass criteria, so that I understand how I performed against the real exam standard.

#### Acceptance Criteria

1. WHEN an Attempt is completed, THE Mock_Test SHALL present a Result_Summary that reports a score for
   each Section.
2. THE Mock_Test SHALL present per-Section scores normalized to the official TELC B1 point values:
   Leseverstehen 75 points, Sprachbausteine 30 points, Hörverstehen 75 points, Schriftlicher Ausdruck
   45 points, Mündlicher Ausdruck 75 points.
3. THE Result_Summary SHALL present the total written-part points and the total oral-part points.
4. WHEN presenting the Result_Summary, THE Mock_Test SHALL indicate, for the written part and for the
   oral part separately, whether the student met the Pass_Threshold of 60% of the available points.

### Requirement 10: Display official timing and points information

**User Story:** As a B1 student, I want to see the official timing and points for each section, so
that I can pace myself like in the real exam.

#### Acceptance Criteria

1. WHERE a Section or Teil is displayed, THE Mock_Test SHALL display the official TELC B1 time
   allowance and point value associated with that Section.
2. THE Mock_Test SHALL display the combined 90-minute allowance for Leseverstehen and Sprachbausteine,
   the listening allowance for Hörverstehen, the 30-minute allowance for Schriftlicher Ausdruck, and
   the preparation and speaking allowance for Mündlicher Ausdruck.
3. THE Mock_Test SHALL display the total examination value of 300 points.

### Requirement 11: Localization of all mock test text

**User Story:** As a student who uses the app in my own language, I want the mock test interface in my
selected locale, so that I can understand the instructions and results.

#### Acceptance Criteria

1. THE Mock_Test SHALL render all app-authored interface text through the Localization_Service for the
   active locale (uz, kaa, ru, or de).
2. THE Mock_Test SHALL present the German exam content (German question text, passages, and German
   exam terms such as Section and Teil names) in German, regardless of the active locale.
3. IF a localized string is missing for the active locale, THEN THE Localization_Service SHALL return
   the Uzbek (`uz`) fallback text.

### Requirement 12: Handling insufficient source content

**User Story:** As a B1 student, I want a clear message when the mock test cannot be built, so that I
am not left with a broken or incomplete exam.

#### Acceptance Criteria

1. IF a required Teil has no Test available in its source data model, THEN THE Mock_Test SHALL report
   to the student that the Attempt cannot be assembled.
2. IF an Attempt cannot be assembled because required content is missing, THEN THE Mock_Test SHALL NOT
   present a partially assembled Attempt as if it were complete.
