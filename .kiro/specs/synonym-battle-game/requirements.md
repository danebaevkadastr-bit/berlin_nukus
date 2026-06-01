# Requirements Document

## Kirish (Introduction)

Sinonimlar Jangi (Synonym Battle) - bu o'zbek tili so'zlashuvchilar uchun nemis tilini o'rganish ilovasidagi yangi o'yin. O'yin foydalanuvchilarga nemis tilidagi so'zlarning sinonimlarini topish orqali lug'at boyligini oshirishga yordam beradi. O'yin mavjud o'yinlar (Der/Die/Das, Grammar Quiz, Strange Sentences, Story Game) bilan bir xil arxitektura va UI patternlaridan foydalanadi.

## Glossary (Lug'at)

- **Synonym_Battle_Game**: Sinonimlar jangi o'yini - foydalanuvchi nemis so'ziga to'g'ri sinonimni tanlashi kerak bo'lgan o'yin
- **Rules_Screen**: Qoidalar ekrani - o'yin qoidalarini ko'rsatadigan boshlang'ich ekran
- **Game_Screen**: O'yin ekrani - asosiy o'yin jarayoni bo'ladigan ekran
- **Results_Screen**: Natijalar ekrani - o'yin yakunida ko'rsatiladigan statistika
- **Question_Card**: Savol kartasi - nemis so'zi va variantlar ko'rsatiladigan UI komponenti
- **Answer_Option**: Javob varianti - foydalanuvchi tanlashi mumkin bo'lgan sinonim varianti
- **Star_System**: Yulduz tizimi - to'g'ri javoblar uchun beriladigan ball tizimi
- **Streak_Bonus**: Ketma-ket bonus - ketma-ket to'g'ri javoblar uchun qo'shimcha ball
- **Timer**: Taymer - har bir savol uchun vaqt chegarasi
- **Synonym_Data**: Sinonim ma'lumotlari - nemis so'zlari va ularning sinonimlari to'plami
- **GameStarsService**: O'yin yulduzlarini boshqaruvchi servis
- **GamifiedCard**: O'yin UI komponenti - kartochka ko'rinishidagi widget

## Requirements (Talablar)

### Requirement 1: Qoidalar Ekrani (Rules Screen)

**User Story:** O'quvchi sifatida, men o'yinni boshlashdan oldin qoidalarni ko'rishni xohlayman, shunda men o'yin qanday o'ynalishini tushunaman.

#### Acceptance Criteria

1. WHEN foydalanuvchi Sinonimlar Jangi o'yinini tanlasa, THE Rules_Screen SHALL o'yin qoidalarini o'zbek tilida ko'rsatishi kerak
2. THE Rules_Screen SHALL o'yin maqsadini tushuntiruvchi matn ko'rsatishi kerak
3. THE Rules_Screen SHALL ball tizimini (har bir to'g'ri javob uchun ball, streak bonus) tushuntirishi kerak
4. THE Rules_Screen SHALL vaqt chegarasi haqida ma'lumot ko'rsatishi kerak
5. THE Rules_Screen SHALL "O'YINNI BOSHLASH" tugmasini ko'rsatishi kerak
6. WHEN foydalanuvchi "O'YINNI BOSHLASH" tugmasini bossa, THE Rules_Screen SHALL Game_Screen ga o'tishi kerak

### Requirement 2: O'yin Ma'lumotlari (Game Data)

**User Story:** O'quvchi sifatida, men turli xil nemis so'zlari va ularning sinonimlarini o'rganishni xohlayman, shunda men lug'atimni kengaytiraman.

#### Acceptance Criteria

1. THE Synonym_Data SHALL kamida 50 ta nemis so'zi va ularning sinonimlarini o'z ichiga olishi kerak
2. THE Synonym_Data SHALL har bir so'z uchun kamida bitta to'g'ri sinonimni saqlashi kerak
3. THE Synonym_Data SHALL har bir so'z uchun o'zbek tilidagi tarjimasini saqlashi kerak
4. THE Synonym_Data SHALL so'zlarni qiyinlik darajasi bo'yicha guruhlashi kerak (oson, o'rta, qiyin)
5. WHEN o'yin boshlansa, THE Synonym_Battle_Game SHALL so'zlarni tasodifiy tartibda aralashtirishi kerak

### Requirement 3: Savol Ko'rsatish (Question Display)

**User Story:** O'quvchi sifatida, men aniq va tushunarli savol ko'rishni xohlayman, shunda men to'g'ri javob bera olaman.

#### Acceptance Criteria

1. THE Question_Card SHALL nemis so'zini katta shriftda markazda ko'rsatishi kerak
2. THE Question_Card SHALL so'zning o'zbek tilidagi tarjimasini kichikroq shriftda ko'rsatishi kerak
3. THE Question_Card SHALL to'rtta Answer_Option ni ko'rsatishi kerak
4. THE Answer_Option lar orasida faqat bitta to'g'ri sinonim bo'lishi kerak
5. THE Answer_Option lar tasodifiy tartibda joylashtirilishi kerak
6. WHILE savol ko'rsatilayotganda, THE Timer SHALL qolgan vaqtni soniyalarda ko'rsatishi kerak

### Requirement 4: Javob Berish Mexanizmi (Answer Mechanism)

**User Story:** O'quvchi sifatida, men javob berganimda darhol natijani ko'rishni xohlayman, shunda men o'rganishim mumkin.

#### Acceptance Criteria

1. WHEN foydalanuvchi Answer_Option ni tanlasa, THE Synonym_Battle_Game SHALL javobni tekshirishi kerak
2. WHEN javob to'g'ri bo'lsa, THE Synonym_Battle_Game SHALL yashil rang bilan "To'g'ri!" xabarini ko'rsatishi kerak
3. WHEN javob noto'g'ri bo'lsa, THE Synonym_Battle_Game SHALL qizil rang bilan to'g'ri javobni ko'rsatishi kerak
4. WHEN javob berilgandan so'ng, THE Synonym_Battle_Game SHALL 1.5 soniyadan keyin keyingi savolga o'tishi kerak
5. WHILE javob tekshirilayotganda, THE Answer_Option lar o'chirilgan (disabled) holatda bo'lishi kerak

### Requirement 5: Vaqt Chegarasi (Time Limit)

**User Story:** O'quvchi sifatida, men vaqt chegarasi bilan o'ynashni xohlayman, shunda men tezroq fikrlashni o'rganaman.

#### Acceptance Criteria

1. THE Timer SHALL har bir savol uchun 10 soniya vaqt berishi kerak
2. THE Timer SHALL qolgan vaqtni vizual ko'rsatishi kerak
3. WHEN vaqt 4 soniyadan kam qolsa, THE Timer SHALL qizil rangga o'zgarishi kerak
4. IF vaqt tugasa, THEN THE Synonym_Battle_Game SHALL javobni noto'g'ri deb hisoblashi kerak
5. IF vaqt tugasa, THEN THE Synonym_Battle_Game SHALL to'g'ri javobni ko'rsatishi kerak

### Requirement 6: Ball Tizimi (Scoring System)

**User Story:** O'quvchi sifatida, men to'g'ri javoblar uchun ball olishni xohlayman, shunda men o'z yutuqlarimni kuzataman.

#### Acceptance Criteria

1. WHEN javob to'g'ri bo'lsa, THE Star_System SHALL 10 ball (yulduz) qo'shishi kerak
2. WHEN foydalanuvchi ketma-ket 5 ta to'g'ri javob bersa, THE Streak_Bonus SHALL qo'shimcha 5 ball berishi kerak
3. THE Synonym_Battle_Game SHALL joriy raund balini ekranda ko'rsatishi kerak
4. THE Synonym_Battle_Game SHALL ketma-ket to'g'ri javoblar sonini ko'rsatishi kerak
5. WHEN noto'g'ri javob berilsa, THE Streak_Bonus hisoblagichi 0 ga qaytishi kerak

### Requirement 7: Raund Tuzilishi (Round Structure)

**User Story:** O'quvchi sifatida, men qisqa raundlarda o'ynashni xohlayman, shunda men vaqtimni samarali ishlataman.

#### Acceptance Criteria

1. THE Synonym_Battle_Game SHALL har bir raundda 10 ta savol ko'rsatishi kerak
2. THE Synonym_Battle_Game SHALL joriy savol raqamini va jami savollar sonini ko'rsatishi kerak
3. THE Synonym_Battle_Game SHALL progress bar orqali raund jarayonini vizual ko'rsatishi kerak
4. WHEN 10-savol yakunlansa, THE Synonym_Battle_Game SHALL Results_Screen ga o'tishi kerak

### Requirement 8: Natijalar Ekrani (Results Screen)

**User Story:** O'quvchi sifatida, men raund yakunida batafsil statistikani ko'rishni xohlayman, shunda men o'z yutuqlarimni baholashim mumkin.

#### Acceptance Criteria

1. THE Results_Screen SHALL raundda to'plangan ballni ko'rsatishi kerak
2. THE Results_Screen SHALL to'g'ri va noto'g'ri javoblar sonini ko'rsatishi kerak
3. THE Results_Screen SHALL aniqlik foizini (accuracy) ko'rsatishi kerak
4. THE Results_Screen SHALL natijaga qarab emoji va motivatsion xabar ko'rsatishi kerak (90%+ = 🏆, 70%+ = ⭐, 50%+ = 💪, <50% = 📘)
5. THE Results_Screen SHALL "YANA O'YNASH" tugmasini ko'rsatishi kerak
6. THE Results_Screen SHALL "ORQAGA" tugmasini ko'rsatishi kerak
7. WHEN foydalanuvchi "YANA O'YNASH" tugmasini bossa, THE Synonym_Battle_Game SHALL yangi raund boshlashi kerak

### Requirement 9: Yulduzlarni Saqlash (Star Persistence)

**User Story:** O'quvchi sifatida, men to'plagan yulduzlarim saqlanishini xohlayman, shunda men umumiy yutuqlarimni ko'raman.

#### Acceptance Criteria

1. WHEN raund yakunlansa, THE GameStarsService SHALL to'plangan ballni local storage ga saqlashi kerak
2. THE GameStarsService SHALL yulduzlarni Firebase Firestore ga sinxronizatsiya qilishi kerak
3. THE Results_Screen SHALL jami to'plangan yulduzlar sonini ko'rsatishi kerak
4. WHEN foydalanuvchi o'yinlar ro'yxatiga qaytsa, THE StudentGamesScreen SHALL yangilangan jami yulduzlarni ko'rsatishi kerak

### Requirement 10: UI/UX Dizayni (UI/UX Design)

**User Story:** O'quvchi sifatida, men chiroyli va qulay interfeysda o'ynashni xohlayman, shunda men o'yindan zavq olaman.

#### Acceptance Criteria

1. THE Synonym_Battle_Game SHALL mavjud o'yinlar bilan bir xil UI patternlardan foydalanishi kerak (GamifiedCard, AppColors)
2. THE Synonym_Battle_Game SHALL dark mode va light mode ni qo'llab-quvvatlashi kerak
3. THE Synonym_Battle_Game SHALL to'g'ri javob uchun ovozli effekt (SoundService.playCorrect) ijro etishi kerak
4. THE Synonym_Battle_Game SHALL noto'g'ri javob uchun ovozli effekt (SoundService.playIncorrect) ijro etishi kerak
5. THE Synonym_Battle_Game SHALL tugmalar bosilganda haptic feedback berishi kerak (HapticService)
6. THE Synonym_Battle_Game SHALL barcha matnlarni o'zbek tilida ko'rsatishi kerak

### Requirement 11: Navigatsiya Integratsiyasi (Navigation Integration)

**User Story:** O'quvchi sifatida, men o'yinni o'yinlar ro'yxatidan osongina ochishni xohlayman.

#### Acceptance Criteria

1. WHEN foydalanuvchi StudentGamesScreen da Sinonimlar Jangi kartasini bossa, THE Synonym_Battle_Game SHALL Rules_Screen ni ochishi kerak
2. THE StudentGamesScreen SHALL "Coming Soon" dialogini olib tashlashi va haqiqiy o'yinga yo'naltirishi kerak
3. WHEN foydalanuvchi guruhga a'zo bo'lmasa, THE GroupCheckHelper SHALL ogohlantirish ko'rsatishi kerak
4. THE Synonym_Battle_Game SHALL SlideTransitionPage animatsiyasidan foydalanishi kerak
