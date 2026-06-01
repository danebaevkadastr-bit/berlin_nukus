# Requirements Document

## Kirish

Ushbu hujjat Peshqadamlar (Leaderboard) ekranini yaxshilash uchun talablarni belgilaydi. Hozirgi vaqtda ekran faqat yulduzlar bo'yicha reytingni ko'rsatadi. Foydalanuvchi bir nechta kategoriyalar (davomat, o'rtacha ball) bo'yicha reyting ko'rishni va joriy foydalanuvchini ko'rsatuvchi "SIZ" belgisining yanada chiroyli dizaynini xohlaydi.

## Glossary

- **Peshqadamlar_Ekrani**: O'quvchilar reytingini ko'rsatuvchi Flutter ekrani (StudentLeaderboardScreen)
- **Kategoriya_Tanlash_Komponenti**: Foydalanuvchiga turli reyting kategoriyalarini tanlash imkonini beruvchi UI komponenti
- **Yulduzlar_Reytingi**: O'quvchilarning umumiy yulduzlar soni bo'yicha tartiblangan ro'yxat
- **Davomat_Reytingi**: O'quvchilarning darsga qatnashish foizi bo'yicha tartiblangan ro'yxat
- **O'rtacha_Ball_Reytingi**: O'quvchilarning uy vazifasi o'rtacha balli bo'yicha tartiblangan ro'yxat
- **SIZ_Belgisi**: Joriy foydalanuvchini boshqa foydalanuvchilardan ajratib ko'rsatuvchi vizual belgi
- **Firebase_Service**: Firestore ma'lumotlar bazasidan ma'lumotlarni oluvchi xizmat

## Talablar

### Talab 1: Kategoriya Tanlash Komponenti

**User Story:** Men o'quvchi sifatida turli mezonlar bo'yicha reytingni ko'rishni xohlayman, shunda o'zimni turli yo'nalishlarda boshqalar bilan solishtirishim mumkin.

#### Qabul Mezonlari

1. WHEN Peshqadamlar_Ekrani ochilganda, THE Kategoriya_Tanlash_Komponenti SHALL ekranning yuqori qismida ko'rinishi kerak
2. THE Kategoriya_Tanlash_Komponenti SHALL uchta kategoriyani ko'rsatishi kerak: Yulduzlar, Davomat, O'rtacha Ball
3. WHEN foydalanuvchi kategoriyani tanlasa, THE Kategoriya_Tanlash_Komponenti SHALL tanlangan kategoriyani vizual ravishda ajratib ko'rsatishi kerak
4. THE Kategoriya_Tanlash_Komponenti SHALL sukut bo'yicha Yulduzlar kategoriyasini tanlangan holda ko'rsatishi kerak

### Talab 2: Yulduzlar Bo'yicha Reyting

**User Story:** Men o'quvchi sifatida yulduzlar bo'yicha reytingni ko'rishni xohlayman, shunda eng ko'p yulduz to'plagan o'quvchilarni bilishim mumkin.

#### Qabul Mezonlari

1. WHEN Yulduzlar kategoriyasi tanlanganda, THE Peshqadamlar_Ekrani SHALL o'quvchilarni umumiy yulduzlar soni bo'yicha kamayish tartibida ko'rsatishi kerak
2. THE Peshqadamlar_Ekrani SHALL har bir o'quvchi uchun yulduzlar sonini ko'rsatishi kerak
3. WHEN ikkita o'quvchining yulduzlari teng bo'lsa, THE Peshqadamlar_Ekrani SHALL ularni ism bo'yicha alifbo tartibida ko'rsatishi kerak

### Talab 3: Davomat Bo'yicha Reyting

**User Story:** Men o'quvchi sifatida davomat bo'yicha reytingni ko'rishni xohlayman, shunda eng muntazam qatnashuvchi o'quvchilarni bilishim mumkin.

#### Qabul Mezonlari

1. WHEN Davomat kategoriyasi tanlanganda, THE Peshqadamlar_Ekrani SHALL o'quvchilarni davomat foizi bo'yicha kamayish tartibida ko'rsatishi kerak
2. THE Peshqadamlar_Ekrani SHALL har bir o'quvchi uchun davomat foizini ko'rsatishi kerak
3. THE Firebase_Service SHALL davomat ma'lumotlarini olish uchun yangi stream metodini taqdim etishi kerak
4. WHEN ikkita o'quvchining davomati teng bo'lsa, THE Peshqadamlar_Ekrani SHALL ularni ism bo'yicha alifbo tartibida ko'rsatishi kerak
5. IF o'quvchining davomat ma'lumotlari mavjud bo'lmasa, THEN THE Peshqadamlar_Ekrani SHALL davomat foizini 0% sifatida ko'rsatishi kerak

### Talab 4: O'rtacha Ball Bo'yicha Reyting

**User Story:** Men o'quvchi sifatida o'rtacha ball bo'yicha reytingni ko'rishni xohlayman, shunda eng yaxshi natija ko'rsatayotgan o'quvchilarni bilishim mumkin.

#### Qabul Mezonlari

1. WHEN O'rtacha Ball kategoriyasi tanlanganda, THE Peshqadamlar_Ekrani SHALL o'quvchilarni uy vazifasi o'rtacha balli bo'yicha kamayish tartibida ko'rsatishi kerak
2. THE Peshqadamlar_Ekrani SHALL har bir o'quvchi uchun o'rtacha ballni ko'rsatishi kerak
3. THE Firebase_Service SHALL o'rtacha ball ma'lumotlarini olish uchun yangi stream metodini taqdim etishi kerak
4. WHEN ikkita o'quvchining o'rtacha balli teng bo'lsa, THE Peshqadamlar_Ekrani SHALL ularni ism bo'yicha alifbo tartibida ko'rsatishi kerak
5. IF o'quvchining uy vazifasi ma'lumotlari mavjud bo'lmasa, THEN THE Peshqadamlar_Ekrani SHALL o'rtacha ballni 0 sifatida ko'rsatishi kerak

### Talab 5: Yaxshilangan SIZ Belgisi Dizayni

**User Story:** Men o'quvchi sifatida o'zimni ro'yxatda chiroyli va zamonaviy belgi bilan ko'rishni xohlayman, shunda o'z o'rnimni osonroq topishim mumkin.

#### Qabul Mezonlari

1. THE SIZ_Belgisi SHALL gradient fon rangiga ega bo'lishi kerak
2. THE SIZ_Belgisi SHALL yumshoq soya effektiga ega bo'lishi kerak
3. THE SIZ_Belgisi SHALL animatsiyali pulsatsiya effektiga ega bo'lishi kerak
4. THE SIZ_Belgisi SHALL ilovaning mavjud rang sxemasiga mos kelishi kerak
5. THE SIZ_Belgisi SHALL qorong'i va yorug' mavzularda to'g'ri ko'rinishi kerak

### Talab 6: Kategoriya Almashinuvi Animatsiyasi

**User Story:** Men o'quvchi sifatida kategoriyalar o'rtasida silliq o'tishni ko'rishni xohlayman, shunda foydalanuvchi tajribasi yaxshilansin.

#### Qabul Mezonlari

1. WHEN foydalanuvchi kategoriyani almashtirganda, THE Peshqadamlar_Ekrani SHALL ro'yxatni silliq animatsiya bilan yangilashi kerak
2. THE Peshqadamlar_Ekrani SHALL kategoriya almashtirilganda yuklanish indikatorini ko'rsatishi kerak
3. WHEN yangi ma'lumotlar yuklanganda, THE Peshqadamlar_Ekrani SHALL fade-in animatsiyasi bilan ko'rsatishi kerak

### Talab 7: Xato Holatlarini Boshqarish

**User Story:** Men o'quvchi sifatida xato yuz berganda aniq xabar ko'rishni xohlayman, shunda nima bo'lganini tushunishim mumkin.

#### Qabul Mezonlari

1. IF ma'lumotlarni yuklashda xato yuz bersa, THEN THE Peshqadamlar_Ekrani SHALL foydalanuvchiga tushunarli xato xabarini ko'rsatishi kerak
2. IF tarmoq ulanishi yo'q bo'lsa, THEN THE Peshqadamlar_Ekrani SHALL "Internet ulanishini tekshiring" xabarini ko'rsatishi kerak
3. THE Peshqadamlar_Ekrani SHALL xato holatida qayta urinish tugmasini ko'rsatishi kerak
