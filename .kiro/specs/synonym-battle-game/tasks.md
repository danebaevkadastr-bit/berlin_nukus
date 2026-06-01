# Implementation Plan: Sinonimlar Jangi (Synonym Battle Game)

## Overview

This implementation plan creates a new vocabulary game for German language learners. The game presents German words and asks users to identify the correct synonym from four options. The implementation follows existing game patterns (Der/Die/Das, Grammar Quiz) and integrates with the existing GameStarsService for star persistence.

## Tasks

- [x] 1. Create data models and utility classes
  - [x] 1.1 Create SynonymWord model class
    - Create `lib/models/synonym_word.dart`
    - Define `SynonymWord` class with `word`, `translation`, `synonyms`, and `difficulty` fields
    - Add `randomSynonym` getter to return a random synonym from the list
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 1.2 Create SynonymData utility class with 50+ German words
    - Create `lib/utils/synonym_data.dart`
    - Add 50+ German words with synonyms organized by difficulty (easy, medium, hard)
    - Implement `shuffledWords({int limit})` method for random word selection
    - Implement `generateDistractors(SynonymWord word, int count)` method
    - Implement `generateOptions(SynonymWord word)` method returning 4 options (1 correct + 3 distractors)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.3, 3.4, 3.5_

  - [ ]* 1.3 Write property tests for SynonymData
    - **Property 1: Data Integrity - Synonyms Exist** - Every word has at least one synonym
    - **Property 2: Data Integrity - Translations Exist** - Every word has non-empty translation
    - **Property 3: Question Generation Validity** - generateOptions returns exactly 4 options with 1 correct
    - **Property 9: Shuffle Produces Valid Permutation** - shuffledWords returns valid permutation
    - **Validates: Requirements 2.2, 2.3, 2.5, 3.3, 3.4, 3.5**

  - [x] 1.4 Create SynonymRules configuration class
    - Create `lib/utils/synonym_rules.dart`
    - Define game constants: `questionsPerRound = 10`, `secondsPerQuestion = 10`, `pointsPerCorrect = 10`, `streakBonusEvery = 5`, `streakBonusPoints = 5`, `timerWarningThreshold = 4`
    - Add localized rule text strings in Uzbek
    - _Requirements: 1.2, 1.3, 1.4, 5.1, 5.3, 6.1, 6.2, 7.1_

- [x] 2. Checkpoint - Ensure data layer is complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Extend GameStarsService for synonym battle stars
  - [x] 3.1 Add synonym battle methods to GameStarsService
    - Add `_synonymBattleKey(String uid)` method
    - Add `getSynonymBattleStars(String uid)` method
    - Add `addSynonymBattleStars(String uid, int earned)` method
    - Update `getTotalStars(String uid)` to include synonym battle stars
    - _Requirements: 9.1, 9.2, 9.4_

  - [ ]* 3.2 Write unit tests for GameStarsService extension
    - Test `getSynonymBattleStars` returns 0 for new users
    - Test `addSynonymBattleStars` correctly adds and persists stars
    - Test `getTotalStars` includes synonym battle stars
    - **Validates: Requirements 9.1, 9.2**

- [x] 4. Create Rules Screen
  - [x] 4.1 Create SynonymBattleRulesScreen
    - Create `lib/screens/student/games/synonym_battle_rules_screen.dart`
    - Follow DerDieDasRulesScreen pattern for layout and styling
    - Display game title, rules explanation, scoring system, and time limit info in Uzbek
    - Use GamifiedCard widgets for consistent UI
    - Add "O'YINNI BOSHLASH" button that navigates to SynonymBattleGameScreen
    - Support dark/light mode via ThemeManager.isDark
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 10.1, 10.2, 10.6_

  - [ ]* 4.2 Write widget tests for SynonymBattleRulesScreen
    - Test rules text is displayed
    - Test "O'YINNI BOSHLASH" button exists and navigates correctly
    - Test dark/light mode styling
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6**

- [x] 5. Create Game Screen
  - [x] 5.1 Create SynonymBattleGameScreen with core game logic
    - Create `lib/screens/student/games/synonym_battle_game_screen.dart`
    - Follow DerDieDasGameScreen pattern for state management and layout
    - Implement state variables: `_deck`, `_currentOptions`, `_index`, `_score`, `_correct`, `_wrong`, `_streak`, `_timeLeft`, `_timer`, `_answered`, `_finished`, `_feedbackMessage`, `_lastWasCorrect`, `_totalSavedStars`
    - Implement `_startNewRound()` to initialize deck with 10 shuffled words
    - Implement `_startTimer()` with 10-second countdown per question
    - _Requirements: 2.5, 5.1, 5.2, 7.1, 7.2, 7.3_

  - [x] 5.2 Implement question display UI
    - Display German word in large font centered
    - Display Uzbek translation in smaller font below
    - Display 4 answer option buttons using GamifiedCard
    - Show progress bar and question counter (e.g., "3/10")
    - Show current score and streak counter
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 6.3, 6.4, 7.2, 7.3_

  - [x] 5.3 Implement timer display and warning
    - Display timer with icon showing seconds remaining
    - Change timer color to red when <= 4 seconds remaining
    - Handle timeout as incorrect answer
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 5.4 Implement answer handling and feedback
    - Implement `_onAnswer(String? chosenSynonym)` method
    - Check if selected option is in word's synonyms list
    - Display green "To'g'ri!" message for correct answers
    - Display red message with correct answer for incorrect/timeout
    - Disable answer buttons after selection
    - Auto-advance to next question after 1.5 seconds
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [x] 5.5 Implement scoring logic with streak bonus
    - Add 10 points for each correct answer
    - Add 5 bonus points every 5 consecutive correct answers
    - Reset streak to 0 on incorrect answer or timeout
    - Display current score and streak on screen
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [ ]* 5.6 Write property tests for scoring logic
    - **Property 5: Scoring - Base Points** - Correct answer adds exactly 10 points
    - **Property 6: Scoring - Streak Bonus** - Bonus awarded every 5 correct answers
    - **Property 7: Scoring - Streak Reset** - Streak resets to 0 on incorrect answer
    - **Validates: Requirements 6.1, 6.2, 6.5**

  - [x] 5.7 Implement results section
    - Display after 10 questions completed
    - Show round score, total saved stars, correct/wrong counts, accuracy percentage
    - Display emoji and motivational message based on accuracy (90%+ = 🏆, 70%+ = ⭐, 50%+ = 💪, <50% = 📘)
    - Add "YANA O'YNASH" button to start new round
    - Add "ORQAGA" button to return to games list
    - Save stars via GameStarsService.addSynonymBattleStars
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 9.1, 9.3_

  - [ ]* 5.8 Write property test for results calculation
    - **Property 8: Results Calculation and Display** - Accuracy percentage and emoji match thresholds
    - **Validates: Requirements 8.3, 8.4**

  - [x] 5.9 Add sound and haptic feedback
    - Call SoundService.playCorrect() on correct answer
    - Call SoundService.playIncorrect() on incorrect answer
    - Call HapticService for button interactions
    - _Requirements: 10.3, 10.4, 10.5_

  - [ ]* 5.10 Write widget tests for SynonymBattleGameScreen
    - Test question display with word and translation
    - Test 4 answer options are displayed
    - Test timer display and countdown
    - Test feedback display on answer selection
    - Test results section display after round completion
    - **Validates: Requirements 3.1, 3.2, 3.3, 5.2, 8.1, 8.2**

- [x] 6. Checkpoint - Ensure game screens are complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Integrate with StudentGamesScreen
  - [x] 7.1 Add navigation method for Synonym Battle
    - Add `_openSynonymBattleGame()` method to StudentGamesScreen
    - Use HapticService.mediumImpact() on tap
    - Check group membership via GroupCheckHelper.checkAndWarn
    - Navigate to SynonymBattleRulesScreen using SlideTransitionPage
    - Reload stars after returning from game
    - _Requirements: 11.1, 11.3, 11.4_

  - [x] 7.2 Replace Coming Soon dialog with actual game navigation
    - Update Synonym Battle card's onTap from `_showComingSoonDialog` to `_openSynonymBattleGame`
    - Remove `isComingSoon: true` from the Synonym Battle card
    - Add import for SynonymBattleRulesScreen
    - _Requirements: 11.1, 11.2_

  - [ ]* 7.3 Write integration test for game flow
    - Test navigation from StudentGamesScreen to Rules Screen
    - Test navigation from Rules Screen to Game Screen
    - Test full game round completion
    - Test star persistence after game
    - **Validates: Requirements 11.1, 11.2, 9.1, 9.4**

- [x] 8. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Follow existing patterns from DerDieDasRulesScreen and DerDieDasGameScreen for consistency
- All UI text should be in Uzbek language
- Use existing services: GameStarsService, SoundService, HapticService
- Use existing widgets: GamifiedCard, SlideTransitionPage

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.4"] },
    { "id": 1, "tasks": ["1.2"] },
    { "id": 2, "tasks": ["1.3", "3.1"] },
    { "id": 3, "tasks": ["3.2", "4.1"] },
    { "id": 4, "tasks": ["4.2", "5.1"] },
    { "id": 5, "tasks": ["5.2", "5.3"] },
    { "id": 6, "tasks": ["5.4", "5.5"] },
    { "id": 7, "tasks": ["5.6", "5.7"] },
    { "id": 8, "tasks": ["5.8", "5.9"] },
    { "id": 9, "tasks": ["5.10", "7.1"] },
    { "id": 10, "tasks": ["7.2"] },
    { "id": 11, "tasks": ["7.3"] }
  ]
}
```
