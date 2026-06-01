# Implementation Plan: Leaderboard Screen Enhancement

## Overview

Ushbu rejada Peshqadamlar (Leaderboard) ekranini yaxshilash uchun amalga oshirish bosqichlari keltirilgan. Asosiy maqsadlar: kategoriya tanlash komponenti, yangi Firebase streamlar, yaxshilangan SIZ belgisi va silliq animatsiyalar.

## Tasks

- [x] 1. Asosiy komponentlar va enumlarni yaratish
  - [x] 1.1 LeaderboardCategory enum yaratish
    - `lib/models/leaderboard_category.dart` faylini yaratish
    - Uchta kategoriya: `stars`, `attendance`, `averageScore`
    - _Requirements: 1.2_

  - [x] 1.2 Lokalizatsiya stringlarini qo'shish
    - `lib/l10n/app_localizations.dart` fayliga yangi stringlar qo'shish
    - Stringlar: `stars`, `attendance`, `averageScore`, `checkInternet`, `retryButton`
    - Barcha tillar uchun: uz, kaa, ru, de
    - _Requirements: 1.2, 7.2_

- [x] 2. SizBadge widget yaratish
  - [x] 2.1 SizBadge StatefulWidget yaratish
    - `lib/widgets/siz_badge.dart` faylini yaratish
    - Gradient fon: `duoBlue` → `duoPurple`
    - BoxShadow: yumshoq ko'k soya (blurRadius: 8, spreadRadius: 2)
    - Border radius: 20px, padding: horizontal 12px, vertical 6px
    - _Requirements: 5.1, 5.2, 5.4_

  - [x] 2.2 Pulsatsiya animatsiyasini qo'shish
    - AnimationController bilan scale animatsiyasi (1.0 → 1.1 → 1.0)
    - Davomiylik: 2000ms, Curves.easeInOut
    - `animate` parametri bilan yoqish/o'chirish imkoniyati
    - _Requirements: 5.3_

  - [x] 2.3 Dark/Light theme qo'llab-quvvatlash
    - ThemeManager.isDark orqali tema aniqlash
    - Har ikkala temada to'g'ri ko'rinish
    - _Requirements: 5.5_

  - [ ]* 2.4 SizBadge uchun widget testlar yozish
    - Gradient mavjudligini tekshirish
    - Soya mavjudligini tekshirish
    - Animatsiya ishlashini tekshirish
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 3. CategoryTabSelector widget yaratish
  - [x] 3.1 CategoryTabSelector StatefulWidget yaratish
    - `lib/widgets/category_tab_selector.dart` faylini yaratish
    - TabBar bilan uchta tab: Yulduzlar, Davomat, O'rtacha Ball
    - `selectedCategory` va `onCategoryChanged` parametrlari
    - _Requirements: 1.1, 1.2_

  - [x] 3.2 Tanlangan tab uchun vizual ajratish
    - Tanlangan tab uchun gradient fon
    - Animatsiyali o'tish TabController orqali
    - _Requirements: 1.3_

  - [x] 3.3 Default kategoriya sozlash
    - Sukut bo'yicha Yulduzlar kategoriyasi tanlangan
    - _Requirements: 1.4_

  - [ ]* 3.4 CategoryTabSelector uchun widget testlar yozish
    - Uchta tab mavjudligini tekshirish
    - Default tanlangan tab (Yulduzlar)
    - Tab almashish callback ishlashini tekshirish
    - **Property 4: Kategoriya tanlash vizual aks etishi**
    - **Validates: Requirements 1.3**

- [x] 4. Checkpoint - Komponentlar tayyor
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Firebase Service kengaytmalari
  - [x] 5.1 Davomat bo'yicha leaderboard stream yaratish
    - `getAttendanceLeaderboardStream()` metodini qo'shish
    - O'quvchilarni `attendancePercentage` bo'yicha tartiblash
    - Null qiymatlar uchun 0% default
    - _Requirements: 3.1, 3.3, 3.5_

  - [x] 5.2 O'rtacha ball bo'yicha leaderboard stream yaratish
    - `getAverageScoreLeaderboardStream()` metodini qo'shish
    - O'quvchilarni `averageScore` bo'yicha tartiblash
    - Null qiymatlar uchun 0 default
    - _Requirements: 4.1, 4.3, 4.5_

  - [x] 5.3 Tartiblash logikasini yaxshilash
    - Teng qiymatlar uchun ikkinchi darajali tartiblash (fullName bo'yicha alifbo)
    - Barcha uchta stream uchun qo'llash
    - _Requirements: 2.3, 3.4, 4.4_

  - [ ]* 5.4 Firebase stream metodlari uchun unit testlar yozish
    - **Property 1: Kategoriya bo'yicha tartiblash**
    - **Property 2: Teng qiymatlar uchun alifbo tartibi**
    - **Validates: Requirements 2.1, 2.3, 3.1, 3.4, 4.1, 4.4**

- [x] 6. LeaderboardListItem widget yaratish
  - [x] 6.1 LeaderboardListItem StatelessWidget yaratish
    - `lib/widgets/leaderboard_list_item.dart` faylini yaratish
    - Parametrlar: `user`, `rank`, `isCurrentUser`, `category`
    - Rank 1, 2, 3 uchun maxsus ikonlar
    - _Requirements: 2.2, 3.2, 4.2_

  - [x] 6.2 Kategoriyaga qarab qiymat ko'rsatish
    - `stars`: yulduzlar soni (⭐ 150)
    - `attendance`: foiz (📅 95%)
    - `averageScore`: ball (📊 87)
    - _Requirements: 2.2, 3.2, 4.2_

  - [x] 6.3 SizBadge integratsiyasi
    - `isCurrentUser` true bo'lganda SizBadge ko'rsatish
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ]* 6.4 LeaderboardListItem uchun widget testlar yozish
    - **Property 3: Kategoriyaga mos qiymat ko'rsatish**
    - **Validates: Requirements 2.2, 3.2, 4.2**

- [x] 7. Checkpoint - Komponentlar va servislar tayyor
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. StudentLeaderboardScreen yangilash
  - [x] 8.1 CategoryTabSelector integratsiyasi
    - AppBar ostiga CategoryTabSelector qo'shish
    - Kategoriya o'zgarishini boshqarish
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 8.2 Kategoriyaga qarab stream tanlash
    - `stars` → `getLeaderboardStream()`
    - `attendance` → `getAttendanceLeaderboardStream()`
    - `averageScore` → `getAverageScoreLeaderboardStream()`
    - _Requirements: 2.1, 3.1, 4.1_

  - [x] 8.3 LeaderboardListItem bilan ro'yxat yangilash
    - Mavjud inline kodni LeaderboardListItem bilan almashtirish
    - Kategoriya parametrini uzatish
    - _Requirements: 2.2, 3.2, 4.2_

  - [x] 8.4 Animatsiyali o'tishlar qo'shish
    - Kategoriya almashtirilganda fade-in animatsiyasi
    - AnimatedSwitcher yoki FadeTransition ishlatish
    - _Requirements: 6.1, 6.3_

- [x] 9. Xato holatlarini boshqarish
  - [x] 9.1 Xato holati UI yaratish
    - Warning ikoni (64px)
    - Xato xabari (16px, w600)
    - Qayta urinish tugmasi (GamifiedButton)
    - _Requirements: 7.1, 7.3_

  - [x] 9.2 Tarmoq xatosi uchun maxsus xabar
    - "Internet ulanishini tekshiring" xabari
    - Lokalizatsiya qo'llab-quvvatlash
    - _Requirements: 7.2_

  - [x] 9.3 Yuklanish indikatori
    - Kategoriya almashtirilganda yuklanish ko'rsatish
    - CircularProgressIndicator ishlatish
    - _Requirements: 6.2_

- [x] 10. Final checkpoint - Barcha funksionallik tayyor
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Barcha UI komponentlar dark/light theme qo'llab-quvvatlashi kerak
- Lokalizatsiya barcha tillar uchun (uz, kaa, ru, de) qo'shilishi kerak

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["2.1", "3.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "3.2", "3.3"] },
    { "id": 3, "tasks": ["2.4", "3.4", "5.1", "5.2"] },
    { "id": 4, "tasks": ["5.3", "6.1"] },
    { "id": 5, "tasks": ["5.4", "6.2", "6.3"] },
    { "id": 6, "tasks": ["6.4", "8.1"] },
    { "id": 7, "tasks": ["8.2", "8.3"] },
    { "id": 8, "tasks": ["8.4", "9.1"] },
    { "id": 9, "tasks": ["9.2", "9.3"] }
  ]
}
```
