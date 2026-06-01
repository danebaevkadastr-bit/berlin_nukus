# Talablar Hujjati (Requirements Document)

## Kirish (Introduction)

Bu hujjat statistika ekranida o'qish vaqtini (daqiqalarni) ko'rsatish funksiyasini tavsiflaydi. Hozirda `StudentStatisticsScreen` faqat davomat, uy vazifasi, yulduzlar va streak ko'rsatadi. Foydalanuvchilar o'zlarining o'qishga sarflagan vaqtlarini (daqiqa/soat) ko'rishni xohlashadi.

Mavjud tizimda `StreakService` orqali `dailyMinutesMap` va `recordActivity` funksiyalari allaqachon mavjud, lekin bu ma'lumotlar statistika ekranida ko'rsatilmayapti.

## Lug'at (Glossary)

- **Statistika_Ekrani**: `StudentStatisticsScreen` - talabaning o'quv natijalarini ko'rsatadigan ekran
- **Vaqt_Kuzatuvchi**: O'qish vaqtini kuzatib boruvchi va saqlovchi xizmat (StreakService)
- **Kunlik_Daqiqalar**: Bir kunda o'qishga sarflangan daqiqalar soni
- **Haftalik_Daqiqalar**: Bir haftada o'qishga sarflangan umumiy daqiqalar
- **Umumiy_Daqiqalar**: Barcha vaqt davomida o'qishga sarflangan daqiqalar
- **Daqiqa_Kartasi**: Statistika ekranidagi vaqt ko'rsatuvchi karta komponenti
- **Haftalik_Grafik**: So'nggi 7 kunlik o'qish vaqtini vizual ko'rsatuvchi grafik

## Talablar (Requirements)

### Talaba 1: Umumiy O'qish Vaqtini Ko'rsatish

**Foydalanuvchi Hikoyasi:** Talaba sifatida, men umumiy o'qishga sarflagan vaqtimni ko'rishni xohlayman, shunda o'z progressimni baholay olaman.

#### Qabul Mezonlari (Acceptance Criteria)

1. WHEN Statistika_Ekrani ochilganda, THE Statistika_Ekrani SHALL umumiy o'qish vaqtini daqiqalarda yoki soatlarda ko'rsatishi kerak
2. WHILE umumiy vaqt 60 daqiqadan kam bo'lsa, THE Statistika_Ekrani SHALL vaqtni daqiqalarda ko'rsatishi kerak (masalan: "45 daqiqa")
3. WHILE umumiy vaqt 60 daqiqa yoki undan ko'p bo'lsa, THE Statistika_Ekrani SHALL vaqtni soat va daqiqalarda ko'rsatishi kerak (masalan: "2 soat 30 daqiqa")
4. THE Daqiqa_Kartasi SHALL ⏱️ emoji va "O'qish vaqti" sarlavhasi bilan ko'rsatilishi kerak

### Talaba 2: Bugungi O'qish Vaqtini Ko'rsatish

**Foydalanuvchi Hikoyasi:** Talaba sifatida, men bugun qancha vaqt o'qiganimni ko'rishni xohlayman, shunda kunlik maqsadlarimga erishayotganimni bilaman.

#### Qabul Mezonlari (Acceptance Criteria)

1. WHEN Statistika_Ekrani ochilganda, THE Statistika_Ekrani SHALL bugungi o'qish vaqtini alohida ko'rsatishi kerak
2. WHILE bugungi vaqt 0 bo'lsa, THE Statistika_Ekrani SHALL "0 daqiqa" ko'rsatishi kerak
3. THE Bugungi_Daqiqa_Kartasi SHALL 📅 emoji va "Bugun" sarlavhasi bilan ko'rsatilishi kerak

### Talaba 3: Haftalik O'qish Vaqti Grafigi

**Foydalanuvchi Hikoyasi:** Talaba sifatida, men so'nggi 7 kunlik o'qish vaqtimni grafik ko'rinishida ko'rishni xohlayman, shunda o'qish odatlarimni kuzatib boraman.

#### Qabul Mezonlari (Acceptance Criteria)

1. WHEN Statistika_Ekrani ochilganda, THE Statistika_Ekrani SHALL so'nggi 7 kunlik o'qish vaqtini bar chart (ustunli grafik) ko'rinishida ko'rsatishi kerak
2. THE Haftalik_Grafik SHALL har bir kun uchun sana (kun.oy formatida) va daqiqalar sonini ko'rsatishi kerak
3. THE Haftalik_Grafik SHALL eng yuqori qiymatga nisbatan boshqa ustunlarni proporsional ko'rsatishi kerak
4. WHILE barcha kunlar uchun vaqt 0 bo'lsa, THE Haftalik_Grafik SHALL bo'sh holat xabarini ko'rsatishi kerak ("Hali o'qish vaqti yozilmagan")

### Talaba 4: Vaqt Ma'lumotlarini Firestore'dan Olish

**Foydalanuvchi Hikoyasi:** Talaba sifatida, men o'qish vaqtim to'g'ri saqlanishini va qayta yuklanishini xohlayman, shunda ma'lumotlarim yo'qolmaydi.

#### Qabul Mezonlari (Acceptance Criteria)

1. WHEN Statistika_Ekrani yuklanayotganda, THE Vaqt_Kuzatuvchi SHALL foydalanuvchining `dailyMinutesMap` ma'lumotlarini Firestore'dan olishi kerak
2. THE Vaqt_Kuzatuvchi SHALL umumiy daqiqalarni `dailyMinutesMap` dagi barcha qiymatlarni qo'shib hisoblashi kerak
3. IF Firestore'dan ma'lumot olishda xatolik yuz bersa, THEN THE Statistika_Ekrani SHALL xatolik xabarini ko'rsatishi va 0 qiymatlarni ko'rsatishi kerak
4. FOR ALL valid dailyMinutesMap ma'lumotlari, umumiy daqiqalar hisoblash keyin formatlash keyin qayta hisoblash SHALL bir xil natija berishi kerak (round-trip property)

### Talaba 5: Vaqt Formatini Lokalizatsiya Qilish

**Foydalanuvchi Hikoyasi:** Talaba sifatida, men vaqt ma'lumotlarini o'zbek tilida ko'rishni xohlayman, shunda tushunishim oson bo'ladi.

#### Qabul Mezonlari (Acceptance Criteria)

1. THE Statistika_Ekrani SHALL vaqt birliklarini o'zbek tilida ko'rsatishi kerak ("daqiqa", "soat")
2. THE Statistika_Ekrani SHALL "O'qish vaqti", "Bugun", "Haftalik statistika" kabi sarlavhalarni o'zbek tilida ko'rsatishi kerak
3. WHEN til sozlamalari o'zgartirilganda, THE Statistika_Ekrani SHALL yangi tilda ko'rsatishi kerak

### Talaba 6: UI Dizayn Mosligi

**Foydalanuvchi Hikoyasi:** Talaba sifatida, men yangi vaqt statistikasining mavjud dizaynga mos kelishini xohlayman, shunda ilova bir xil ko'rinishda bo'ladi.

#### Qabul Mezonlari (Acceptance Criteria)

1. THE Daqiqa_Kartasi SHALL mavjud statistika kartalari (davomat, uy vazifasi, streak) bilan bir xil dizaynga ega bo'lishi kerak
2. THE Daqiqa_Kartasi SHALL `GamifiedCard` widgetidan foydalanishi kerak
3. THE Haftalik_Grafik SHALL ilova ranglar sxemasiga (AppColors) mos kelishi kerak
4. THE Statistika_Ekrani SHALL dark mode va light mode da to'g'ri ko'rinishi kerak
