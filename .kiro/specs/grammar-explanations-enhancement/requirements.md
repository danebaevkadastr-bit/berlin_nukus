# Requirements Document

## Introduction

Ushbu hujjat grammatika bo'limidagi tushuntirishlarni takomillashtirish funksiyasini tavsiflaydi. Hozirgi holatda grammatika qoidalari faqat oddiy matn ko'rinishida ko'rsatilmoqda. Foydalanuvchilar har bir grammatika mavzusi uchun batafsil nazariy tushuntirishlar, jadvallar (artikl jadvali, tuslanish jadvali) va formatlangan misollar ko'rishni xohlaydi.

## Glossary

- **Grammatika_Tizimi**: Nemis tili grammatikasini o'rgatish uchun mo'ljallangan ilova moduli
- **Tushuntirish_Komponenti**: Grammatika qoidalarini batafsil ko'rsatuvchi UI komponenti
- **Jadval_Komponenti**: Grammatik ma'lumotlarni jadval ko'rinishida ko'rsatuvchi UI komponenti
- **Nazariy_Qism**: Grammatika mavzusining batafsil matnli tushuntirishi
- **Misol_Komponenti**: Nemischa jumlalarni tarjimasi bilan ko'rsatuvchi UI komponenti
- **GrammarExplanation_Modeli**: Batafsil tushuntirishlar uchun ma'lumotlar strukturasi
- **GrammarTable_Modeli**: Jadval ma'lumotlari uchun strukturasi
- **GrammarExample_Modeli**: Formatlangan misollar uchun strukturasi
- **Foydalanuvchi**: Ilovadan foydalanadigan o'quvchi

## Requirements

### Requirement 1: Batafsil Tushuntirish Modeli

**User Story:** Dasturchi sifatida, men batafsil grammatika tushuntirishlarini saqlash uchun yangi ma'lumotlar strukturasini xohlayman, shunda har bir mavzu uchun nazariy qism, jadvallar va misollarni alohida boshqarish mumkin bo'ladi.

#### Acceptance Criteria

1. THE GrammarExplanation_Modeli SHALL nazariy tushuntirish matnini saqlash uchun `theoryText` maydonini o'z ichiga oladi
2. THE GrammarExplanation_Modeli SHALL jadvallar ro'yxatini saqlash uchun `tables` maydonini o'z ichiga oladi
3. THE GrammarExplanation_Modeli SHALL formatlangan misollar ro'yxatini saqlash uchun `examples` maydonini o'z ichiga oladi
4. THE GrammarTable_Modeli SHALL jadval sarlavhasini saqlash uchun `title` maydonini o'z ichiga oladi
5. THE GrammarTable_Modeli SHALL ustun nomlarini saqlash uchun `headers` maydonini o'z ichiga oladi
6. THE GrammarTable_Modeli SHALL jadval qatorlarini saqlash uchun `rows` maydonini o'z ichiga oladi
7. THE GrammarExample_Modeli SHALL nemischa jumlani saqlash uchun `german` maydonini o'z ichiga oladi
8. THE GrammarExample_Modeli SHALL o'zbekcha tarjimani saqlash uchun `uzbek` maydonini o'z ichiga oladi
9. THE GrammarExample_Modeli SHALL ixtiyoriy grammatik izohni saqlash uchun `note` maydonini o'z ichiga oladi

### Requirement 2: GrammarRule Modelini Kengaytirish

**User Story:** Dasturchi sifatida, men mavjud GrammarRule modelini yangi tushuntirish strukturasi bilan bog'lashni xohlayman, shunda orqaga qarab muvofiqlik saqlanadi.

#### Acceptance Criteria

1. THE Grammatika_Tizimi SHALL mavjud GrammarRule modeliga ixtiyoriy `detailedExplanation` maydonini qo'shadi
2. WHEN `detailedExplanation` maydoni mavjud bo'lsa, THE Tushuntirish_Komponenti SHALL batafsil ko'rinishni ko'rsatadi
3. WHEN `detailedExplanation` maydoni mavjud bo'lmasa, THE Tushuntirish_Komponenti SHALL mavjud oddiy `explanation` maydonini ko'rsatadi
4. THE Grammatika_Tizimi SHALL JSON serializatsiya va deserializatsiyani yangi maydonlar bilan qo'llab-quvvatlaydi

### Requirement 3: Nazariy Qism Ko'rsatish

**User Story:** O'quvchi sifatida, men har bir grammatika qoidasi uchun batafsil nazariy tushuntirishni o'qishni xohlayman, shunda mavzuni chuqurroq tushunaman.

#### Acceptance Criteria

1. WHEN Foydalanuvchi grammatika qoidasini ochsa, THE Tushuntirish_Komponenti SHALL nazariy qismni formatlangan matn sifatida ko'rsatadi
2. THE Nazariy_Qism SHALL paragraflar, ro'yxatlar va ta'kidlangan matnni qo'llab-quvvatlaydi
3. THE Nazariy_Qism SHALL o'qish uchun qulay shrift o'lchami va qator oralig'ida ko'rsatiladi
4. WHILE qorong'i rejim yoqilgan bo'lsa, THE Nazariy_Qism SHALL mos ranglar sxemasida ko'rsatiladi

### Requirement 4: Jadval Ko'rsatish

**User Story:** O'quvchi sifatida, men grammatik ma'lumotlarni jadval ko'rinishida ko'rishni xohlayman (masalan: artikl jadvali, tuslanish jadvali), shunda ma'lumotlarni tez solishtirish mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN grammatika qoidasida jadvallar mavjud bo'lsa, THE Jadval_Komponenti SHALL har bir jadvalni sarlavha bilan ko'rsatadi
2. THE Jadval_Komponenti SHALL ustun sarlavhalarini ajratilgan rangda ko'rsatadi
3. THE Jadval_Komponenti SHALL qatorlarni navbatma-navbat rangda ko'rsatadi (zebra uslubi)
4. THE Jadval_Komponenti SHALL gorizontal aylantirish (scroll) imkoniyatini ta'minlaydi, WHEN jadval ekran kengligidan katta bo'lsa
5. WHILE qorong'i rejim yoqilgan bo'lsa, THE Jadval_Komponenti SHALL mos ranglar sxemasida ko'rsatiladi
6. THE Jadval_Komponenti SHALL jadval katakchalarida matnni markazlashtiradi

### Requirement 5: Formatlangan Misollar Ko'rsatish

**User Story:** O'quvchi sifatida, men nemischa misollarni o'zbekcha tarjimasi bilan birga ko'rishni xohlayman, shunda jumlalarni to'g'ri tushunaman.

#### Acceptance Criteria

1. WHEN grammatika qoidasida misollar mavjud bo'lsa, THE Misol_Komponenti SHALL har bir misolni nemischa va o'zbekcha ko'rsatadi
2. THE Misol_Komponenti SHALL nemischa jumlani qalin shriftda ko'rsatadi
3. THE Misol_Komponenti SHALL o'zbekcha tarjimani kursiv shriftda ko'rsatadi
4. WHEN misolda izoh mavjud bo'lsa, THE Misol_Komponenti SHALL izohni alohida rangda ko'rsatadi
5. THE Misol_Komponenti SHALL misollarni raqamlangan ro'yxat sifatida ko'rsatadi

### Requirement 6: A1 Daraja Uchun Namuna Ma'lumotlar

**User Story:** O'quvchi sifatida, men A1 darajadagi asosiy mavzular uchun batafsil tushuntirishlarni ko'rishni xohlayman, shunda nemis tilini o'rganishni boshlashim mumkin.

#### Acceptance Criteria

1. THE Grammatika_Tizimi SHALL "Artikllar (der/die/das)" mavzusi uchun batafsil tushuntirish va jadval bilan ma'lumot taqdim etadi
2. THE Grammatika_Tizimi SHALL "Hozirgi zamon (Präsens)" mavzusi uchun tuslanish jadvali bilan ma'lumot taqdim etadi
3. THE Grammatika_Tizimi SHALL "Akkusativ holati" mavzusi uchun artikl o'zgarishlari jadvali bilan ma'lumot taqdim etadi
4. THE Grammatika_Tizimi SHALL har bir mavzu uchun kamida 5 ta formatlangan misol taqdim etadi

### Requirement 7: Tushuntirish Ekrani Navigatsiyasi

**User Story:** O'quvchi sifatida, men grammatika qoidasini bosib batafsil tushuntirish ekraniga o'tishni xohlayman, shunda to'liq ma'lumotni ko'rishim mumkin.

#### Acceptance Criteria

1. WHEN Foydalanuvchi grammatika qoidasini bossa, THE Grammatika_Tizimi SHALL batafsil tushuntirish ekraniga navigatsiya qiladi
2. THE Tushuntirish_Komponenti SHALL ekran yuqorisida mavzu sarlavhasini ko'rsatadi
3. THE Tushuntirish_Komponenti SHALL nazariy qism, jadvallar va misollarni ketma-ket ko'rsatadi
4. THE Tushuntirish_Komponenti SHALL orqaga qaytish tugmasini ta'minlaydi
5. THE Tushuntirish_Komponenti SHALL vertikal aylantirish (scroll) imkoniyatini ta'minlaydi

### Requirement 8: Responsive Dizayn

**User Story:** O'quvchi sifatida, men tushuntirishlarni turli ekran o'lchamlarida qulay ko'rishni xohlayman, shunda telefon va planshetda foydalanishim mumkin.

#### Acceptance Criteria

1. THE Tushuntirish_Komponenti SHALL kichik ekranlarda (telefon) to'liq kenglikda ko'rsatiladi
2. THE Tushuntirish_Komponenti SHALL katta ekranlarda (planshet) maksimal kenglikni cheklaydi
3. THE Jadval_Komponenti SHALL kichik ekranlarda gorizontal aylantirish imkoniyatini ta'minlaydi
4. THE Misol_Komponenti SHALL kichik ekranlarda nemischa va o'zbekcha matnni vertikal joylashtiriladi
