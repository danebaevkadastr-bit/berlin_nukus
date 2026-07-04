# Requirements Document

## Introduction

This feature adds audio recording capability to the Sprechen (speaking practice) section of the Berlin-Nukus German-learning app. Each speaking task (Aufgabe) — including both Kandidat A and Kandidat B variants within a Teil — gets its own independent recording control. A learner records spoken German (up to approximately four minutes), reviews the recording through playback, and then submits the finished audio to an AI service for evaluation. The recording is sent to the AI only after the learner finishes recording; audio is not streamed during capture.

This feature applies only to the two Teile currently available in the Sprechen section. It does not change existing Sprechen content (instructions, keywords, examples, sample answers) or redesign the existing screen layout beyond adding the recording controls and feedback display per Aufgabe.

This document captures functional requirements using EARS patterns. Several decisions require user input and are listed in the "Open Questions and Assumptions" section.

## Glossary

- **Sprechen_Section**: The speaking-practice feature located at `lib/screens/student/sprechen/`.
- **Teil**: A part of a TELC speaking exam, represented by `SprechenTeil`. Each Teil contains one or more Aufgaben (or tests).
- **Aufgabe**: A single speaking task, represented by `SprechenAufgabe`. May carry a `partner` value of "A" or "B" (Kandidat A / Kandidat B) or be empty for single-candidate tasks.
- **Recorder**: The component that captures microphone audio into an audio file on the device.
- **Recording_Control**: The per-Aufgabe UI element that lets the learner start, stop, re-record, play back, and submit a recording.
- **Recording_Timer**: The component that tracks elapsed recording time and enforces the maximum recording duration.
- **Max_Recording_Duration**: The maximum recording length, set to 240 seconds (four minutes).
- **Audio_Recording**: The completed audio file produced by the Recorder for one Aufgabe.
- **Playback_Player**: The component that plays the Audio_Recording back to the learner (built on the existing `audioplayers` package).
- **Permission_Handler**: The microphone permission component (built on the existing `permission_handler` package).
- **AI_Evaluator**: The AI service — Google Gemini, accessed via the `AIService` and the Cloudflare Worker proxy — that evaluates a submitted Audio_Recording (sent directly as audio) and returns spoken-language feedback including an AI-generated score.
- **Evaluation_Feedback**: The structured feedback returned by the AI_Evaluator (for example pronunciation, fluency, grammar, and content commentary).
- **Upload_Service**: The component responsible for transferring the Audio_Recording to a location reachable by the AI_Evaluator (for example `CloudinaryService`).
- **AppLocalizations**: The localization helper that resolves strings across the four supported locales (uz, kaa, ru, de).
- **Native_Platform**: An Android build of the app.
- **Web_Platform**: A web build of the app.

## Requirements

### Requirement 1: Per-Aufgabe Recording Control

**User Story:** As a learner, I want a separate recording control on each speaking task, so that I can record an independent answer for every Aufgabe including Kandidat A and Kandidat B.

#### Acceptance Criteria

1. THE Sprechen_Section SHALL display one Recording_Control for each Aufgabe rendered in a Teil.
2. WHERE an Aufgabe has a partner value of "A" or "B", THE Sprechen_Section SHALL associate a distinct Recording_Control with that specific Kandidat.
3. WHILE a Teil contains multiple tests, THE Sprechen_Section SHALL display Recording_Controls only for the Aufgaben of the currently selected test.
4. THE Recording_Control SHALL maintain the recording state of one Aufgabe independently from the recording state of every other Aufgabe.
5. THE Sprechen_Section SHALL add Recording_Controls to the two Teile currently available without modifying the existing instruction, keyword, example, or sample-answer content of those Teile.

### Requirement 2: Microphone Permission Handling

**User Story:** As a learner, I want the app to request microphone access when I start recording, so that I can record my voice.

#### Acceptance Criteria

1. WHEN the learner activates the Recording_Control to start recording and microphone permission has not been granted, THE Permission_Handler SHALL request microphone permission.
2. IF the learner grants microphone permission, THEN THE Recorder SHALL start recording.
3. IF the learner denies microphone permission, THEN THE Sprechen_Section SHALL display a localized message explaining that microphone access is required to record.
4. IF microphone permission is permanently denied, THEN THE Sprechen_Section SHALL display a localized message offering to open the device application settings.
5. WHILE microphone permission is already granted, WHEN the learner activates the Recording_Control to start recording, THE Recorder SHALL start recording without re-requesting permission.

### Requirement 3: Start, Stop, and Re-record

**User Story:** As a learner, I want to start, stop, and re-record my answer, so that I can capture a recording I am satisfied with.

#### Acceptance Criteria

1. WHEN the learner activates the start action on an idle Recording_Control, THE Recorder SHALL begin capturing microphone audio for that Aufgabe.
2. WHILE the Recorder is capturing audio, THE Recording_Control SHALL display a stop action and an indication that recording is in progress.
3. WHEN the learner activates the stop action while recording, THE Recorder SHALL stop capturing audio and produce an Audio_Recording for that Aufgabe.
4. WHEN the learner activates the re-record action on an Aufgabe that already has an Audio_Recording, THE Recorder SHALL discard the existing Audio_Recording for that Aufgabe and begin capturing new audio.
5. WHILE the Recorder is capturing audio for one Aufgabe, IF the learner activates the start action on a different Aufgabe, THEN THE Sprechen_Section SHALL stop the active recording before starting the new recording.

### Requirement 4: Recording Duration Limit

**User Story:** As a learner, I want a four-minute recording limit with a visible timer, so that my recording stays within the evaluation limit.

#### Acceptance Criteria

1. WHILE the Recorder is capturing audio, THE Recording_Timer SHALL display the elapsed recording time updated at least once per second.
2. WHEN the elapsed recording time reaches the Max_Recording_Duration of 240 seconds, THE Recorder SHALL automatically stop capturing audio and produce an Audio_Recording.
3. WHEN the Recorder automatically stops at the Max_Recording_Duration, THE Sprechen_Section SHALL display a localized message indicating that the maximum recording length was reached.
4. WHILE the Recorder is capturing audio, THE Recording_Timer SHALL indicate the remaining time relative to the Max_Recording_Duration.

### Requirement 5: Playback Before Submission

**User Story:** As a learner, I want to play back my recording before sending it, so that I can confirm the recording is acceptable.

#### Acceptance Criteria

1. WHEN the Recorder produces an Audio_Recording for an Aufgabe, THE Recording_Control SHALL display a playback action for that Audio_Recording.
2. WHEN the learner activates the playback action, THE Playback_Player SHALL play the Audio_Recording for that Aufgabe.
3. WHILE the Playback_Player is playing an Audio_Recording, WHEN the learner activates the pause action, THE Playback_Player SHALL pause playback.
4. WHEN the learner re-records an Aufgabe, THE Playback_Player SHALL stop playing the previous Audio_Recording for that Aufgabe.

### Requirement 6: Submit Completed Recording to AI

**User Story:** As a learner, I want my finished recording sent to the AI for evaluation, so that I can receive feedback on my spoken German.

#### Acceptance Criteria

1. WHILE an Aufgabe has a completed Audio_Recording, THE Recording_Control SHALL display a submit action for that Aufgabe.
2. THE Sprechen_Section SHALL send an Audio_Recording to the AI_Evaluator only after the Recorder has finished producing that Audio_Recording.
3. WHEN the learner activates the submit action, THE Upload_Service SHALL make the Audio_Recording available to the AI_Evaluator.
4. WHEN the Audio_Recording is available to the AI_Evaluator, THE AI_Evaluator SHALL receive the Audio_Recording together with the Aufgabe context, including the task instruction and, where present, the Meinung text and partner role.
5. WHILE the AI_Evaluator is processing a submitted Audio_Recording, THE Recording_Control SHALL display a localized in-progress indicator for that Aufgabe.
6. WHILE a submission for an Aufgabe is in progress, THE Recording_Control SHALL prevent a second concurrent submission of the same Aufgabe.

### Requirement 7: AI Evaluation Feedback Display

**User Story:** As a learner, I want to see the AI's feedback after evaluation, so that I can understand how to improve my speaking.

#### Acceptance Criteria

1. WHEN the AI_Evaluator returns Evaluation_Feedback for an Aufgabe, THE Sprechen_Section SHALL display the Evaluation_Feedback associated with that Aufgabe.
2. THE Evaluation_Feedback SHALL include commentary on pronunciation, fluency, grammar, and content relevance to the task.
3. THE AI_Evaluator SHALL generate a score as part of the evaluation, and THE Sprechen_Section SHALL display that score together with the Evaluation_Feedback.
4. THE Sprechen_Section SHALL display the Evaluation_Feedback in the learner's selected interface language as resolved by AppLocalizations.
5. WHEN new Evaluation_Feedback is returned for an Aufgabe that already has feedback displayed, THE Sprechen_Section SHALL replace the previous Evaluation_Feedback with the new Evaluation_Feedback.
6. WHEN the learner leaves the Sprechen_Section screen, THE Sprechen_Section SHALL discard the Evaluation_Feedback and the Audio_Recording without persisting them.

### Requirement 8: Error Handling

**User Story:** As a learner, I want clear messages when something goes wrong, so that I know what happened and what to do next.

#### Acceptance Criteria

1. IF the Recorder fails to start capturing audio, THEN THE Sprechen_Section SHALL display a localized error message and return the Recording_Control to the idle state.
2. IF the Recorder fails while capturing audio, THEN THE Sprechen_Section SHALL display a localized error message and discard the incomplete Audio_Recording.
3. IF the Upload_Service fails to make the Audio_Recording available to the AI_Evaluator, THEN THE Sprechen_Section SHALL display a localized network error message and offer to retry the submission.
4. IF the AI_Evaluator returns an error or an unparseable response, THEN THE Sprechen_Section SHALL display a localized evaluation error message and retain the Audio_Recording so the learner can resubmit.
5. WHILE a submission is awaiting a response, IF no response is received within a defined timeout, THEN THE Sprechen_Section SHALL display a localized timeout message and offer to retry the submission.

### Requirement 9: Platform Support (Native and Web)

**User Story:** As a learner, I want recording to work on the platform I use, so that I can practice on Android or in the browser.

#### Acceptance Criteria

1. WHERE the app runs on the Native_Platform, THE Recorder SHALL capture audio into a device file using the audio recording package.
2. WHERE the app runs on the Web_Platform, THE Recorder SHALL capture audio using the browser-supported recording mechanism.
3. THE Sprechen_Section SHALL submit the resulting Audio_Recording to the AI_Evaluator on both the Native_Platform and the Web_Platform.
4. IF the current platform does not support audio recording, THEN THE Sprechen_Section SHALL display a localized message indicating that recording is unavailable on that platform.

### Requirement 10: Localization

**User Story:** As a learner, I want all recording-related text in my chosen language, so that I can use the feature in Uzbek, Karakalpak, Russian, or German.

#### Acceptance Criteria

1. THE Sprechen_Section SHALL display every label, status message, and error message of the Recording_Control using AppLocalizations for the locales uz, kaa, ru, and de.
2. WHEN the learner changes the interface language, THE Sprechen_Section SHALL display recording-related text in the newly selected language.
3. IF a localized string is missing for the selected locale, THEN AppLocalizations SHALL resolve the string using the existing fallback order.

## Decisions

The following decisions have been confirmed by the user and resolve the corresponding open questions:

1. **AI provider — Gemini with direct audio input.** The AI_Evaluator uses Google Gemini, which natively understands audio. The finished Audio_Recording is sent directly to Gemini (no separate speech-to-text step in the UI). This requires a new Gemini audio-capable path through the Cloudflare Worker proxy (the existing text-only `AIService` methods do not cover this). Transport details (inline base64 vs file/URL) are settled in design.

2. **No result persistence.** Evaluation_Feedback and recordings are session-scoped only. Nothing is stored in Firestore, shared_preferences, or any backend after the learner leaves the screen. Audio files are temporary and may be deleted after evaluation.

3. **AI-generated score.** The AI_Evaluator produces the score itself as part of the evaluation (the app does not compute it). The exact scale/rubric wording is proposed by the AI and rendered as returned; design will define the response structure the app parses.

### Gemini rate limit note (informational, as of 2025–2026)

Gemini rate limits apply per project/API key (shared across all app users), measured in requests-per-minute (RPM), tokens-per-minute (TPM), and requests-per-day (RPD); RPD resets at midnight Pacific time. Audio is billed as normal request tokens (roughly 32 tokens per second of audio), not as a separate quota. Approximate free-tier daily limits by model: Gemini 2.5 Flash ≈ 250 RPD, Gemini 2.5 Flash-Lite ≈ 1000 RPD, Gemini 2.5 Pro ≈ 100 RPD. A ~4-minute recording is a small token cost. Because the free-tier daily cap is shared across all users, the design must account for the chosen model's daily limit and consider enabling billing (paid tier removes the restrictive daily cap at very low audio cost) or worker-side throttling for many concurrent learners.

## Remaining Open Questions (for design)

These do not block requirements but must be settled during design:

1. **Audio storage/transport**: Whether the Audio_Recording is sent inline (base64 through the Worker to Gemini) or uploaded to Cloudinary first and passed by URL. Affects Requirement 6 and 8.
2. **Audio format and quality**: Encoding (AAC/m4a vs Opus/webm), sample rate, and bitrate, plus any upload size cap, balancing quality against token/upload cost. The 240-second limit is fixed.
3. **Concurrent recordings policy**: Requirement 3.5 assumes only one Aufgabe records at a time — confirm during design.
4. **Cost/rate limiting**: Which Gemini model to use given the shared daily limit, and whether to add per-session submission limits or worker-side throttling for many users.
