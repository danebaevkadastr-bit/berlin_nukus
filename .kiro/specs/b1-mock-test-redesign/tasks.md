# Implementation Plan: B1 Mock Test Redesign

## Overview

Bu reja `b1-mock-test` funksiyasining **taqdimot qatlamini** qayta loyihalaydi. Domen yadrosi
(`model/mock_test_assembler.dart`, `mock_test_scorer.dart`, `mock_test_attempt.dart`,
`mock_test_structure.dart`, `mock_test_exceptions.dart`) **o'zgartirilmaydi** (Requirement 10).
`MockTestController` faqat read-only yordamchi metodlar + bitta pozitsiya-navigatsiya metodi bilan
kengaytiriladi.

Reja avval **pure mantiq** (review/timer modellari, controller extension) bilan boshlanadi va ularni
property-test bilan qoplaydi, so'ng UI komponentlarini (burger/drawer, taymer, savol-strip, navbar)
quradi, oxirida runner / result / intro ekranlariga **ulaydi**. Har bir qadam oldingisiga tayanadi va
osilib qolgan kod qoldirmaydi. Til: **Dart / Flutter**. Property testlar uchun mavjud `glados`
(`^1.1.7`) kutubxonasidan foydalaniladi; testlar `test/` katalogiga joylashtiriladi.

## Tasks

- [x] 1. Pure review va timer modellarini yaratish (domen yadrosiga tegmasdan)
  - [x] 1.1 Review modellari va `resolveOutcome` ni yaratish
    - `lib/screens/student/mock_test/model/mock_test_review.dart` faylini yaratish
    - `enum QuestionOutcome { correct, incorrect, unanswered }` ni qo'shish
    - Pure top-level `QuestionOutcome resolveOutcome(String? selected, String correctAnswer)` ni yozish (null → unanswered; teng → correct; aks holda incorrect)
    - Immutable `QuestionReview`, `TeilReview`, `AiSectionReview`, `MockReview` modellarini yozish (ro'yxatlar `List.unmodifiable`); Flutter/I-O bog'liqligisiz, pure Dart
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 10.2_

  - [x] 1.2 Taymer modellari va `computeTimerState` ni yaratish
    - `lib/screens/student/mock_test/model/mock_test_timing.dart` faylini yaratish
    - `enum TimerPhase { normal, warning, timeUp }` va immutable `SectionTimerState` ni qo'shish
    - Pure `SectionTimerState computeTimerState(Duration remaining, Duration warningThreshold)` ni yozish (side-effect yo'q, hech qachon auto-submit emas)
    - `MockTestTiming` ni yozish: blok davomiyliklari (Lese+Sprachbausteine 90m, Hören 30m, Schreiben 30m, Sprechen 15m), `warningThreshold` 1m, `Object blockKeyOf(MockSection)` va `Duration allowanceOf(MockSection)`
    - _Requirements: 5.2, 5.4, 5.5, 5.7_

- [x] 2. `MockTestController` ni read-only review + navigatsiya bilan kengaytirish
  - [x] 2.1 `MockTestReview` extension'ini yozish
    - `lib/screens/student/mock_test/mock_test_review_controller.dart` faylida `extension MockTestReview on MockTestController` ni yaratish
    - `void goToTeil(int index)` — faqat `currentTeilIndex` ni o'zgartiradi; diapazondan tashqari indeks no-op; assembled content/answers/AI natijalari tegilmaydi
    - `QuestionOutcome outcomeFor(AnswerKey key)` — `resolveOutcome` orqali pure derivatsiya
    - `MockReview buildReview()` — auto-graded Teile uchun per-savol `QuestionReview`/`TeilReview`, AI Section'lar uchun `AiSectionReview` (`MockTestScorer.parseAiFraction` orqali `available`), `result` sifatida `buildResult()`; faqat mavjud holatni o'qiydi
    - _Requirements: 2.5, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 10.1, 10.2, 10.3_

  - [x]* 2.2 Navigatsiya va read-only metodlar uchun property test yozish
    - **Property 3: Navigatsiya va read-only metodlar holatni o'zgartirmaydi**
    - `{ goToTeil, next, previous, outcomeFor, buildReview }` dan tasodifiy ketma-ketlik so'ng `answers` deep-equal, AI natijalari va `attempt` ref o'zgarmasligini, `currentTeilIndex ∈ [0, teilCount)` ekanini tekshirish; `glados`, ≥100 iteratsiya
    - `test/models/mock_test_review_invariants_test.dart`
    - **Validates: Requirements 2.5, 6.2, 10.2**

  - [x]* 2.3 Auto-graded review uchun property test yozish (scorer oracle)
    - **Property 1: Auto-graded review per-savol to'g'riligi**
    - Har auto-graded Teil savoli uchun aynan bitta `QuestionReview`, `correctOption == correctAnswer`, `selectedOption == answerFor(key)`, `outcome == resolveOutcome(...)`, va `correct` lar soni `MockTestScorer.autoGradeCount` ga tengligini model-based tekshirish; `glados`, ≥100 iteratsiya
    - `test/models/mock_test_review_autograde_test.dart`
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4**

  - [x]* 2.4 AI Section review mavjudligi uchun property test yozish (scorer oracle)
    - **Property 2: AI Section review mavjudligi**
    - Har `AiSectionReview.available == (parseAiFraction(raw) != null)`, `available == false` to'plami `buildResult().unavailableSections` ga teng, va AI baholar borligi/yo'qligi auto-graded review qatorlariga ta'sir qilmasligini tekshirish; `glados`, ≥100 iteratsiya
    - `test/models/mock_test_review_ai_test.dart`
    - **Validates: Requirements 7.5, 7.6**

- [x] 3. Taymer mantig'ini tekshirish
  - [x]* 3.1 `computeTimerState` uchun property test yozish
    - **Property 4: Section_Timer holati klassifikatsiyasi**
    - `r >= 0`, `t > 0` uchun: `timeUp` iff `r == 0`, `warning` iff `0 < r <= t`, `normal` iff `r > t`; o'zaro istisno; pure (side-effect yo'q); edge `r == 0`, `r == t` qoplangan; `glados`, ≥100 iteratsiya
    - `test/models/mock_test_timing_test.dart`
    - **Validates: Requirements 5.4, 5.5, 5.7**

- [x] 4. Lokalizatsiya va nemis Section nomlari
  - [x] 4.1 Yangi lokalizatsiya kalitlarini qo'shish
    - `lib/l10n/app_localizations.dart` ga `_t({uz, kaa, ru, de})` uslubida qo'shish: `mockOverviewTitle`, `mockTimerLabel`, `mockTimerExpired`, `mockReviewTitle`, `mockReviewYourAnswer`, `mockReviewCorrectAnswer`, `mockReviewUnanswered`, `mockExitTooltip`, `mockResultUnavailable`
    - uz fallback xulqini ta'minlash
    - _Requirements: 5.6, 5.8, 7.6, 11.1, 11.3_

  - [x] 4.2 Nemis Section nomlari yordamchisini qo'shish
    - `mockSectionGermanName(MockSection)` helper'ini qo'shish (Leseverstehen, Sprachbausteine, Hörverstehen, Schriftlicher Ausdruck, Mündlicher Ausdruck); lokaldan qat'i nazar nemischa
    - `lib/screens/student/mock_test/model/mock_test_structure.dart` (yoki yangi `mock_test_labels.dart`)
    - _Requirements: 2.6, 11.2_

  - [x]* 4.3 Lokalizatsiya uchun unit test yozish
    - Yangi kalitlar har lokal (uz/kaa/ru/de) uchun va yo'q lokalda uz fallback qaytarishini tekshirish; `mockSectionGermanName` nemischa qolishini tekshirish
    - `test/mock_test_redesign_localization_test.dart`
    - _Requirements: 11.1, 11.2, 11.3_

- [x] 5. Animatsiyali burger va Overview_Drawer
  - [x] 5.1 `AnimatedBurgerIcon` widget'ini yaratish
    - `lib/screens/student/mock_test/widgets/animated_burger_icon.dart` — `AnimatedIcon(icon: AnimatedIcons.menu_close, progress: animation)`, `onTap` callback
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 5.2 `MockOverviewDrawer` ni yaratish
    - `lib/screens/student/mock_test/widgets/mock_overview_drawer.dart` — barcha 5 Section va Teile'larni `MockTestStructure` tartibida `mockSectionGermanName` bilan ko'rsatish; joriy Teil accent rang bilan ajratish; Teil tanlanganda `controller.goToTeil(index)` + yopish; `GamifiedCard`/`AppColors`/dark
    - Slide + scrim animatsiyasini `Animation<double>` orqali boshqarish
    - _Requirements: 1.1, 1.2, 1.3, 2.2, 2.3, 2.4, 2.5, 2.6, 9.4_

  - [x]* 5.3 Drawer va burger animatsiyasi uchun widget test yozish
    - Drawer barcha Section/Teile nemischa ko'rsatishi, joriy Teil ajratilishi, Teil tanlash `goToTeil` chaqirishi va drawer yopilishi; burger↔X animatsiya davomiyligi ≤400 ms
    - `test/screens/student/mock_overview_drawer_test.dart`
    - _Requirements: 2.2, 2.3, 2.4, 2.6, 3.2, 3.3, 3.4, 9.4_

- [x] 6. Section_Timer widget'i
  - [x] 6.1 `SectionTimer` widget'ini yaratish
    - `lib/screens/student/mock_test/widgets/section_timer.dart` — joriy Section blokining qolgan vaqtini `Timer.periodic(1s)` bilan `mm:ss` sanaydi; har blok uchun qolgan vaqt saqlanadi va faol bo'lganda davom etadi; `computeTimerState` orqali normal/warning/timeUp; `timeUp` da `l.mockTimerExpired`; auto-submit YO'Q; raqamlar sanoqda, atrof matn lokalizatsiya
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 11.1_

  - [x]* 6.2 Taymer widget va allowance uchun test yozish
    - `MockTestTiming.allowanceOf` / `blockKeyOf` (Lese+Sprachbausteine bir kalit) unit testlari; `warning` rang holati, `timeUp` da expired label ko'rsatilishi va attempt yakunlanmasligi widget testi
    - `test/screens/student/section_timer_test.dart`
    - _Requirements: 5.2, 5.3, 5.6, 5.7, 5.8_

- [x] 7. `MockQuestionStrip` (gorizontal savol-navigatsiya)
  - [x] 7.1 `MockQuestionStrip` widget'ini yaratish
    - `lib/screens/student/mock_test/widgets/mock_question_strip.dart` — gorizontal suriladigan `ListView`, `count`/`activeIndex`/`isAnswered`/`onSelect`; javob berilgan vs berilmagan vizual farq; accent/dark
    - _Requirements: 1.1, 1.3, 4.1, 4.2, 4.4, 8.7_

  - [x]* 7.2 Savol-strip uchun widget test yozish
    - Indikator bosilganda `onSelect` chaqirilishi, faol savol va answered/unanswered farqi
    - `test/screens/student/mock_question_strip_test.dart`
    - _Requirements: 4.1, 4.2, 4.4_

- [x] 8. `MockNavBar` (qayta loyihalangan pastki navigatsiya)
  - [x] 8.1 `MockNavBar` widget'ini yaratish
    - `lib/screens/student/mock_test/widgets/mock_nav_bar.dart` — `canGoBack`/`canGoNext`/`isFinalTeil` va `onPrevious`/`onNext`/`onFinish`; birinchi Teil'da Previous yashirin; oxirgi Teil'da Next disabled (Finish'ga aylanmaydi) va alohida faol Finish; oxirgidan boshqa joyda Finish yashirin; `AppColors`/accent/dark
    - _Requirements: 1.1, 1.3, 8.1, 8.2, 8.3, 8.4, 8.6, 8.7_

  - [x]* 8.2 Navbar holatlari uchun widget test yozish
    - Birinchi/o'rta/oxirgi Teil holatlari, Next disabled oxirgida, Finish faqat oxirgida, erta yakunlash imkonsizligi
    - `test/screens/student/mock_nav_bar_test.dart`
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.6_

- [x] 9. Section ko'rinishlarini faol-savol modeliga moslash
  - [x] 9.1 Lesen/Hören mock view'larini faol savol indeksiga moslash
    - `lib/screens/student/mock_test/views/lesen_mock_view.dart` va `horen_mock_view.dart` ni `MockQuestionStrip` tanlagan faol savol indeksiga moslash; shared passage/rasm/audio yuqorida qoladi (R4.5 nemis mazmuni kesilmaydi); qisqa harf variantlari gorizontal `Wrap` (mavjud `_buildLetterGrid` qayta ishlatiladi); baholash/yig'ish chaqiruvlari (`selectAnswer`) o'zgarmaydi
    - _Requirements: 4.1, 4.3, 4.5, 10.3_

- [x] 10. Runner ekranini qayta kompozitsiya qilish (komponentlarni ulash)
  - [x] 10.1 `MockTestRunnerScreen` ni qayta loyihalash va ulash
    - `lib/screens/student/mock_test/mock_test_runner_screen.dart`: bitta `AnimationController` (300 ms) bilan `AnimatedBurgerIcon` leading + drawer overlay/scrim sinxron; AppBar title `Section · Teil n` (nemischa) + alohida Exit ikonka (`Icons.logout_rounded`, tooltip); body Column — `SectionTimer` banner, `LinearProgressIndicator`, `MockQuestionStrip`, Expanded faol Teil ko'rinishi (`SelectedTest` subtipi bo'yicha mos view), `MockNavBar`
    - Mavjud `PopScope(canPop:false)` + `_confirmExit` exit-confirmation mantig'ini saqlash; davom etilsa aynan o'sha Teil/javob/pozitsiyada qolish
    - Finish bosilganda `controller.buildResult()` + `controller.buildReview()` → `MockTestResultScreen`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 3.1, 3.4, 5.1, 6.1, 6.2, 6.3, 6.4, 8.5, 9.1, 9.2, 9.3_

  - [x]* 10.2 Teil → Section view xaritalanishi uchun property test yozish
    - **Property 5: Barcha Teile o'z Section ko'rinishiga to'liq xaritalanadi**
    - `[0, teilCount)` har Teil indeksi `SelectedTest` subtipiga mos view'ga (Lesen/Horen/Schreiben/Sprechen) hech bo'sh/ishlovsiz holatsiz xaritalanishini tekshirish; `glados`, ≥100 iteratsiya
    - `test/screens/student/mock_runner_view_mapping_test.dart`
    - **Validates: Requirements 9.1, 9.2, 9.3**

  - [x]* 10.3 Runner kompozitsiyasi uchun widget test yozish
    - Burger drawer'ni ochishi/yopishi, exit dialog ko'rsatilishi va davom etishda holat saqlanishi, oxirgi Teil'da Finish natija ekraniga o'tkazishi
    - `test/screens/student/mock_test_runner_screen_test.dart`
    - _Requirements: 2.1, 6.1, 6.2, 6.3, 8.5, 9.2, 9.3_

- [x] 11. Result ekranida Question_Review
  - [x] 11.1 `MockTestResultScreen` ni `MockReview` bilan kengaytirish
    - `lib/screens/student/mock_test/mock_test_result_screen.dart` ni `MockResult` **va** `MockReview` qabul qiladigan qilish; mavjud hero/total/Section ball kartalarini aynan saqlash (R7.7)
    - Ostiga `QuestionReview` bo'limi: har auto-graded savol uchun savol matni (nemischa), tanlangan/to'g'ri variant va `QuestionOutcome` (correct=yashil, incorrect/unanswered=qizil, "javob berilmagan"); AI Section uchun bahosi+feedback yoki `l.mockResultUnavailable`; yorliqlar lokalizatsiya
    - _Requirements: 1.1, 1.2, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 11.1, 11.2_

  - [x]* 11.2 Result review uchun widget/unit test yozish
    - `buildReview().result == buildResult()` (totallar saqlanishi), per-savol qatorlari ko'rsatilishi, AI unavailable holati boshqa Section'larga to'sqinlik qilmasligi
    - `test/screens/student/mock_test_result_screen_test.dart`
    - _Requirements: 7.1, 7.5, 7.6, 7.7_

- [x] 12. Intro ekranini moslash va oqimni ulash
  - [x] 12.1 `MockTestIntroScreen` ni Design_System'ga moslash va ulash
    - `lib/screens/student/mock_test/mock_test_intro_screen.dart` ni `GamifiedCard`/`AppColors`/dark/accent ga moslash; mavjud `MockTestAssembler.assemble` chaqiruvi va `MockAssemblyException` → `mockTestCannotAssemble` snackbar xulqini saqlash; `MockTestController` yaratib runnerga o'tish
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 10.3_

  - [x]* 12.2 Intro ekrani uchun widget test yozish
    - Design-system render, assembly muvaffaqiyatida runnerga o'tish, assembly muvaffaqiyatsizligida snackbar
    - `test/screens/student/mock_test_intro_screen_test.dart`
    - _Requirements: 1.1, 10.3_

- [~] 13. Yakuniy checkpoint va domen regressiyasi
  - Domen regressiya testlarini (`test/models/mock_test_assembler_test.dart` va mavjud scorer testlari) **o'zgartirmasdan** qayta ishga tushirish — baholash/yig'ish xulqi o'zgarmaganini tasdiqlash (R10.1)
  - Barcha testlar o'tishini ta'minlash (`flutter test --no-pub`), savol tug'ilsa foydalanuvchidan so'rash

## Notes

- `*` bilan belgilangan sub-tasklar ixtiyoriy (test) va tezroq MVP uchun o'tkazib yuborilishi mumkin.
- Domen yadrosi fayllari (`assembler`, `scorer`, `attempt`, `structure`, `exceptions`) **o'zgartirilmaydi**;
  controller faqat read-only extension bilan kengaytiriladi (R10).
- Property testlar `glados` (`^1.1.7`) bilan, har biri ≥100 iteratsiya; Property 1 va 2 model-based —
  `MockTestScorer` ni oracle sifatida ishlatadi.
- Nemis imtihon mazmuni (savol/passaj/Section/Teil nomlari) hech qachon lokalizatsiya qilinmaydi (R11.2).
- Checkpoint domen regressiyasini va to'liq test paketini tekshiradi.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "4.2", "5.1", "7.1", "8.1"] },
    { "id": 1, "tasks": ["2.1", "3.1", "4.1", "6.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "2.4", "4.3", "5.2", "6.2", "7.2", "8.2", "9.1", "11.1"] },
    { "id": 3, "tasks": ["5.3", "11.2", "12.1"] },
    { "id": 4, "tasks": ["10.1"] },
    { "id": 5, "tasks": ["10.2", "10.3", "12.2"] }
  ]
}
```
