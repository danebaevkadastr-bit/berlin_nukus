# Implementation Plan: Statistika Ekranida Daqiqalarni Ko'rsatish

## Overview

Bu amalga oshirish rejasi statistika ekranida o'qish vaqtini (daqiqalarni) ko'rsatish funksiyasini qo'shishni o'z ichiga oladi. Mavjud `StudentStatisticsScreen` ekraniga yangi UI komponentlari qo'shiladi va `StreakService`dagi mavjud `dailyMinutesMap` ma'lumotlaridan foydalaniladi.

## Tasks

- [x] 1. StreakService xizmatiga yangi metodlar qo'shish
  - [x] 1.1 `getTotalMinutes` metodini qo'shish
    - Foydalanuvchining barcha vaqt davomida o'qishga sarflagan umumiy daqiqalarini hisoblash
    - `dailyMinutesMap` dagi barcha qiymatlarni yig'ish
    - Xatolik holatida 0 qaytarish
    - _Talablar: 4.1, 4.2_
  
  - [x] 1.2 `getTodayMinutes` metodini qo'shish
    - Bugungi kun uchun o'qish daqiqalarini olish
    - `dailyMinutesMap` dan bugungi sana kaliti bo'yicha qiymat olish
    - Agar bugungi sana mavjud bo'lmasa, 0 qaytarish
    - _Talablar: 2.1, 2.2_

- [x] 2. Vaqt formatlash utility funksiyasini yaratish
  - [x] 2.1 `formatMinutes` funksiyasini yaratish
    - `lib/utils/time_formatter.dart` faylini yaratish
    - Daqiqalarni o'qilishi oson formatga o'girish (masalan: "45 daqiqa", "2 soat 30 daqiqa")
    - 60 daqiqadan kam bo'lsa faqat daqiqalarni ko'rsatish
    - 60 daqiqa yoki undan ko'p bo'lsa soat va daqiqalarni ko'rsatish
    - _Talablar: 1.2, 1.3_
  
  - [ ]* 2.2 `formatMinutes` uchun property test yozish
    - **Property 1: Vaqt Formatlash To'g'riligi**
    - **Validates: Talablar 1.2, 1.3**

- [x] 3. AppLocalizations ga yangi lokalizatsiya stringlarini qo'shish
  - [x] 3.1 Vaqt statistikasi uchun lokalizatsiya stringlarini qo'shish
    - `studyTime` - "O'qish vaqti" sarlavhasi
    - `today` - "Bugun" sarlavhasi
    - `weeklyStatistics` - "Haftalik statistika" sarlavhasi
    - `noStudyTimeRecorded` - "Hali o'qish vaqti yozilmagan" xabari
    - `minutesFormat(int)` - daqiqalar formati
    - `hoursFormat(int)` - soatlar formati
    - `hoursMinutesFormat(int, int)` - soat va daqiqalar formati
    - O'zbek, Qoraqalpoq, Rus va Nemis tillarida
    - _Talablar: 5.1, 5.2_

- [x] 4. Checkpoint - Barcha testlar o'tishini tekshirish
  - Barcha testlar o'tishini tekshiring, savollar bo'lsa foydalanuvchidan so'rang.

- [x] 5. StudentStatisticsScreen ga yangi state o'zgaruvchilarini qo'shish
  - [x] 5.1 Yangi state o'zgaruvchilarini e'lon qilish
    - `_totalMinutes` - umumiy o'qish daqiqalari
    - `_todayMinutes` - bugungi o'qish daqiqalari
    - `_weeklyMinutes` - haftalik ma'lumotlar (List<double>)
    - `_weeklyDates` - haftalik sanalar (List<String>)
    - _Talablar: 1.1, 2.1, 3.1_
  
  - [x] 5.2 `_loadMinutesData` metodini qo'shish
    - `StreakService.getTotalMinutes` ni chaqirish
    - `StreakService.getTodayMinutes` ni chaqirish
    - `StreakService.getWeeklyUsage` ni chaqirish
    - `StreakService.getWeeklyDates` ni chaqirish
    - Xatolik holatida default qiymatlarni o'rnatish
    - _Talablar: 4.1, 4.3_

- [x] 6. StudentStatisticsScreen ga yangi UI komponentlarini qo'shish
  - [x] 6.1 Vaqt statistika kartalarini qo'shish
    - Umumiy o'qish vaqti kartasi (⏱️ emoji, "O'qish vaqti" sarlavhasi)
    - Bugungi o'qish vaqti kartasi (📅 emoji, "Bugun" sarlavhasi)
    - Mavjud kartalar qatoriga qo'shish
    - `GamifiedCard` widgetidan foydalanish
    - Dark/Light mode qo'llab-quvvatlash
    - _Talablar: 1.1, 1.4, 2.1, 2.3, 6.1, 6.2, 6.4_
  
  - [x] 6.2 Haftalik grafik komponentini qo'shish
    - `_buildWeeklyChart` metodini yaratish
    - So'nggi 7 kunlik o'qish vaqtini bar chart ko'rinishida ko'rsatish
    - Har bir kun uchun sana (kun.oy formatida) va daqiqalar sonini ko'rsatish
    - Eng yuqori qiymatga nisbatan boshqa ustunlarni proporsional ko'rsatish
    - Bo'sh holat xabarini ko'rsatish (barcha 0 bo'lganda)
    - `GamifiedCard` widgetidan foydalanish
    - Dark/Light mode qo'llab-quvvatlash
    - _Talablar: 3.1, 3.2, 3.3, 3.4, 6.3, 6.4_
  
  - [x] 6.3 `_buildChartBar` helper metodini yaratish
    - Bitta ustun uchun UI yaratish
    - Sana, qiymat va balandlikni ko'rsatish
    - Proporsional balandlik hisoblash
    - _Talablar: 3.2, 3.3_

- [x] 7. Checkpoint - Barcha testlar o'tishini tekshirish
  - Barcha testlar o'tishini tekshiring, savollar bo'lsa foydalanuvchidan so'rang.

- [ ]* 8. Unit testlar yozish
  - [ ]* 8.1 StreakService metodlari uchun unit testlar
    - `getTotalMinutes` uchun testlar
    - `getTodayMinutes` uchun testlar
    - Bo'sh map, bitta qiymat, ko'p qiymatlar holatlari
    - _Talablar: 4.2_
  
  - [ ]* 8.2 Vaqt formatlash uchun unit testlar
    - 0 daqiqa → "0 daqiqa"
    - 45 daqiqa → "45 daqiqa"
    - 60 daqiqa → "1 soat"
    - 90 daqiqa → "1 soat 30 daqiqa"
    - 120 daqiqa → "2 soat"
    - _Talablar: 1.2, 1.3_

- [x] 9. Yakuniy checkpoint - Barcha testlar o'tishini tekshirish
  - Barcha testlar o'tishini tekshiring, savollar bo'lsa foydalanuvchidan so'rang.

## Notes

- `*` bilan belgilangan vazifalar ixtiyoriy va tezroq MVP uchun o'tkazib yuborilishi mumkin
- Har bir vazifa aniq talablarga havola qiladi
- Checkpointlar bosqichma-bosqich tekshirishni ta'minlaydi
- Property testlar universal to'g'rilik xususiyatlarini tekshiradi
- Unit testlar aniq misollar va chegaraviy holatlarni tekshiradi

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "3.1"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["2.2", "5.1"] },
    { "id": 3, "tasks": ["5.2"] },
    { "id": 4, "tasks": ["6.1", "6.2"] },
    { "id": 5, "tasks": ["6.3"] },
    { "id": 6, "tasks": ["8.1", "8.2"] }
  ]
}
```
