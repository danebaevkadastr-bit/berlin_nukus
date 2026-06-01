# Implementation Plan: Grammar Explanations Enhancement

## Overview

Ushbu rejada grammatika bo'limidagi tushuntirishlarni takomillashtirish uchun amalga oshirish bosqichlari keltirilgan. Asosiy maqsad — har bir grammatika qoidasi uchun batafsil nazariy tushuntirishlar, jadvallar va formatlangan misollar ko'rsatish imkoniyatini yaratish.

## Tasks

- [x] 1. Ma'lumotlar modellarini yaratish
  - [x] 1.1 GrammarExample modelini yaratish
    - `lib/models/grammar_example.dart` faylini yaratish
    - `german`, `uzbek`, `note` maydonlarini qo'shish
    - `fromJson()` va `toJson()` metodlarini implement qilish
    - `==` operatori va `hashCode` ni override qilish
    - _Requirements: 1.7, 1.8, 1.9, 2.4_

  - [x] 1.2 GrammarTable modelini yaratish
    - `lib/models/grammar_table.dart` faylini yaratish
    - `title`, `headers`, `rows` maydonlarini qo'shish
    - `fromJson()` va `toJson()` metodlarini implement qilish
    - `==` operatori va `hashCode` ni override qilish
    - _Requirements: 1.4, 1.5, 1.6, 2.4_

  - [x] 1.3 GrammarExplanation modelini yaratish
    - `lib/models/grammar_explanation.dart` faylini yaratish
    - `theoryText`, `tables`, `examples` maydonlarini qo'shish
    - `fromJson()` va `toJson()` metodlarini implement qilish
    - `==` operatori va `hashCode` ni override qilish
    - _Requirements: 1.1, 1.2, 1.3, 2.4_

  - [x] 1.4 GrammarRule modelini kengaytirish
    - `lib/models/grammar_level.dart` faylida `GrammarRule` klassiga `detailedExplanation` maydonini qo'shish
    - `fromJson()` va `toJson()` metodlarini yangilash
    - Orqaga muvofiqlik uchun maydonni ixtiyoriy qilish
    - _Requirements: 2.1, 2.4_

- [x] 2. Checkpoint - Modellar to'g'ri yaratilganini tekshirish
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. UI widgetlarni yaratish
  - [x] 3.1 TheoryWidget yaratish
    - `lib/widgets/grammar/theory_widget.dart` faylini yaratish
    - `theoryText` parametrini qabul qilish
    - Paragraflar, ro'yxatlar va ta'kidlangan matnni parse qilish
    - Light/Dark mode qo'llab-quvvatlash
    - O'qish uchun qulay shrift o'lchami va qator oralig'i
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 3.2 GrammarTableWidget yaratish
    - `lib/widgets/grammar/grammar_table_widget.dart` faylini yaratish
    - `GrammarTable` parametrini qabul qilish
    - Sarlavha, ustun sarlavhalari va qatorlarni ko'rsatish
    - Zebra uslubidagi qatorlar (navbatma-navbat rang)
    - Gorizontal scroll qo'llab-quvvatlash
    - Light/Dark mode qo'llab-quvvatlash
    - Matnni markazlashtirish
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

  - [x] 3.3 GrammarExampleWidget yaratish
    - `lib/widgets/grammar/grammar_example_widget.dart` faylini yaratish
    - `List<GrammarExample>` parametrini qabul qilish
    - Nemischa jumlani qalin shriftda ko'rsatish
    - O'zbekcha tarjimani kursiv shriftda ko'rsatish
    - Izohni alohida rangda ko'rsatish
    - Raqamlangan ro'yxat sifatida ko'rsatish
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 4. GrammarExplanationScreen yaratish
  - [x] 4.1 Ekran strukturasini yaratish
    - `lib/screens/student/grammar_explanation_screen.dart` faylini yaratish
    - `GrammarRule` va `GrammarLevel` parametrlarini qabul qilish
    - AppBar (sarlavha va orqaga tugma) qo'shish
    - SingleChildScrollView bilan vertikal scroll
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

  - [x] 4.2 Batafsil va oddiy ko'rinishni implement qilish
    - `detailedExplanation` mavjudligini tekshirish
    - Mavjud bo'lsa: TheoryWidget, GrammarTableWidget, GrammarExampleWidget ko'rsatish
    - Mavjud bo'lmasa: oddiy `explanation` matnini ko'rsatish
    - _Requirements: 2.2, 2.3_

  - [x] 4.3 Responsive dizaynni implement qilish
    - Kichik ekranlarda to'liq kenglik
    - Katta ekranlarda maksimal kenglikni cheklash (600px)
    - MediaQuery orqali ekran o'lchamini aniqlash
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 5. Checkpoint - UI komponentlar to'g'ri ishlashini tekshirish
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Navigatsiya va integratsiya
  - [x] 6.1 GrammarRulesScreen dan navigatsiya qo'shish
    - Mavjud `GrammarRulesScreen` da qoida bosilganda `GrammarExplanationScreen` ga o'tish
    - `Navigator.push` orqali navigatsiya
    - `GrammarRule` va `GrammarLevel` parametrlarini uzatish
    - _Requirements: 7.1_

- [x] 7. A1 daraja uchun namuna ma'lumotlar
  - [x] 7.1 Artikllar mavzusi uchun batafsil tushuntirish
    - `lib/data/grammar_data.dart` faylida A1 Artikllar mavzusiga `detailedExplanation` qo'shish
    - Nazariy qism: artikl turlari, grammatik jins tushunchasi
    - Jadval: aniq artikllar jadvali (der/die/das/die)
    - Kamida 5 ta formatlangan misol
    - _Requirements: 6.1, 6.4_

  - [x] 7.2 Präsens mavzusi uchun batafsil tushuntirish
    - A1 Hozirgi zamon (Präsens) mavzusiga `detailedExplanation` qo'shish
    - Nazariy qism: fe'l tuslanishi qoidalari
    - Jadval: sein, haben, regular fe'llar tuslanish jadvali
    - Kamida 5 ta formatlangan misol
    - _Requirements: 6.2, 6.4_

  - [x] 7.3 Akkusativ mavzusi uchun batafsil tushuntirish
    - A1 Akkusativ holati mavzusiga `detailedExplanation` qo'shish
    - Nazariy qism: akkusativ holati qoidalari
    - Jadval: artikl o'zgarishlari jadvali (Nominativ vs Akkusativ)
    - Kamida 5 ta formatlangan misol
    - _Requirements: 6.3, 6.4_

- [x] 8. Final checkpoint - Barcha funksionallik to'g'ri ishlashini tekshirish
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 9. Testlar
  - [ ]* 9.1 Model unit testlarini yozish
    - GrammarExample, GrammarTable, GrammarExplanation uchun unit testlar
    - JSON serializatsiya/deserializatsiya testlari
    - _Requirements: 1.1-1.9, 2.4_

  - [ ]* 9.2 Property test: JSON Round-Trip
    - **Property 2: JSON Serializatsiya Round-Trip**
    - **Validates: Requirements 2.4**

  - [ ]* 9.3 Widget testlarini yozish
    - TheoryWidget, GrammarTableWidget, GrammarExampleWidget uchun widget testlar
    - GrammarExplanationScreen uchun widget testlar
    - _Requirements: 3.1-3.4, 4.1-4.6, 5.1-5.5_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Dart/Flutter loyihasi uchun mavjud pattern va uslubga rioya qilish kerak
- Light/Dark mode qo'llab-quvvatlash barcha UI komponentlarda talab qilinadi

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["1.3"] },
    { "id": 2, "tasks": ["1.4"] },
    { "id": 3, "tasks": ["3.1", "3.2", "3.3"] },
    { "id": 4, "tasks": ["4.1"] },
    { "id": 5, "tasks": ["4.2", "4.3"] },
    { "id": 6, "tasks": ["6.1"] },
    { "id": 7, "tasks": ["7.1", "7.2", "7.3"] },
    { "id": 8, "tasks": ["9.1", "9.2", "9.3"] }
  ]
}
```
