# Requirements Document

## Introduction

**B1 Mock Test Redesign** — bu allaqachon ishlab chiqilgan **b1-mock-test** funksiyasi ustiga
qo'yiladigan UI/UX qayta loyihalash va yaxshilash bosqichi. Talaba ishlayotgan mock testni ko'rib
chiqdi va ekran ko'rinishi hamda navigatsiyasiga oid bir qator aniq o'zgartirish so'rovlarini
bildirdi. Ushbu spec faqat **taqdimot (presentation) / UX qatlamini** o'zgartiradi: mavjud kodlar
(`lib/screens/student/mock_test/` ichidagi runner, intro, result ekranlari va to'rt Section
ko'rinishi) hamda domen yadrosi (assembler, scorer, controller, attempt modellari) qayta
yozilmaydi — ular **qayta ishlatiladi**. Domen yadrosining xulqi o'zgarmaydi; controller faqat
o'qishga mo'ljallangan (read-only) yordamchi metodlar bilan to'ldirilishi mumkin (masalan, natija
ekranidagi har bir savol bo'yicha to'g'ri/noto'g'rilikni aniqlash uchun).

Asosiy maqsadlar:

- Mock test ekranlarini ilovaning umumiy dizayn tiliga (Duolingo uslubidagi `GamifiedCard`,
  `AppColors`, `ThemeManager` accent rangi va dark mode) moslashtirish.
- Runner ichida barcha Section va ularning Teile'larini ko'rsatadigan **burger (overview)
  menyusini** qo'shish, animatsiyali burger → X belgisi bilan.
- Savol/variantlarni gorizontal joylashtirish, yuqorida **sanab turuvchi taymer**, pastda
  **Previous/Next** tugmalari va chiqishni tasdiqlash oynasini saqlash.
- Natija ekranida har bir savol bo'yicha to'g'ri/noto'g'ri javoblarni ko'rsatadigan **to'liq
  ko'rib chiqish (review)** qo'shish.
- Barcha Section ko'rinishlari (Lesen, Hören, Schreiben, Sprechen) aniq ko'rinadigan va
  erishiladigan bo'lishini ta'minlash.

## Glossary

- **Mock_Test_Redesign**: Mavjud B1 mock test funksiyasining qayta loyihalangan taqdimot qatlami.
- **Mock_Test_Runner**: Talaba test davomida ishlatadigan asosiy runner ekrani
  (`mock_test_runner_screen.dart`).
- **Design_System**: Ilovaning umumiy dizayn tili — `GamifiedCard` vidjeti, `AppColors` rang
  palitrasi va `ThemeManager` (accent presetlari + dark/light rejim).
- **Section**: TELC B1 imtihon sohasi: Leseverstehen, Sprachbausteine, Hörverstehen, Schriftlicher
  Ausdruck, Mündlicher Ausdruck.
- **Teil**: Section ichidagi raqamlangan qism (masalan, Leseverstehen Teil 1).
- **Question**: Teil ichidagi alohida savol/topshiriq.
- **Overview_Drawer**: Burger menyu ochilganda chiqadigan, barcha Section va Teile ro'yxatini
  ko'rsatadigan hamda ular orasida o'tishga imkon beradigan panel.
- **Burger_Menu_Icon**: Runner ichidagi, uch chiziqdan "X" belgisiga va aksincha animatsiya bilan
  o'tadigan menyu tugmasi.
- **Section_Timer**: Runner tepasida sanab turuvchi (countdown) taymer, joriy Section/Teil uchun
  rasmiy TELC B1 vaqt me'yorini ko'rsatadi.
- **Question_Review**: Natija ekranidagi, har bir savol bo'yicha javob holatini (to'g'ri/noto'g'ri
  yoki AI bahosi) ko'rsatadigan ko'rib chiqish bo'limi.
- **Auto_Graded_Section**: Lesen, Sprachbausteine va Hören — javoblar `correctAnswer` bilan
  taqqoslab avtomatik baholanadi.
- **AI_Evaluated_Section**: Schreiben va Sprechen — mavjud AI baholash oqimlari orqali baholanadi.
- **Domain_Core**: O'zgarmaydigan domen yadrosi — `MockTestAssembler`, `MockTestScorer`,
  `MockTestController` xulqi va `MockTestAttempt` modellari.
- **Exit_Confirmation**: Talaba boshlangan attempt'dan chiqmoqchi bo'lganda chiqadigan tasdiqlash
  oynasi (allaqachon mavjud).
- **Localization_Service**: Mavjud `AppLocalizations` mexanizmi (uz, kaa, ru, de; uz fallback).

## Requirements

### Requirement 1: Ilovaning dizayn tiliga moslashtirish

**User Story:** B1 talabasi sifatida, men mock test ekrani ilovaning qolgan qismi bilan bir xil
ko'rinishda bo'lishini xohlayman, shunda u begona his qildirmaydi va men uchun tanish bo'ladi.

#### Acceptance Criteria

1. THE Mock_Test_Redesign SHALL barcha kartalar, tugmalar va sirtlarni Design_System
   komponentlari (`GamifiedCard`) va `AppColors` rang palitrasi orqali render qiladi.
2. WHILE ilova dark rejimda, THE Mock_Test_Redesign SHALL barcha ekranlarni `ThemeManager` dark
   rejim ranglari bilan ko'rsatadi.
3. WHEN foydalanuvchi accent presetini o'zgartiradi, THE Mock_Test_Redesign SHALL urg'u
   elementlarini (tanlangan variant, faol holat, progress) tanlangan `ThemeManager` accent rangida
   ko'rsatadi.
4. THE Mock_Test_Redesign SHALL barcha mock test ekranlari (intro, runner, Section ko'rinishlari,
   result) bo'ylab bir xil tipografiya, burchak radiuslari va oraliq (spacing) qoidalaridan
   foydalanadi.

### Requirement 2: Runner ichidagi burger / overview menyusi

**User Story:** B1 talabasi sifatida, men test ichida barcha Section va Teile tuzilmasini ko'rsatuvchi
menyuni ochib, ular orasida o'tishni xohlayman, shunda imtihon tuzilishini tushunaman va kerakli
qismga tez o'taman.

#### Acceptance Criteria

1. WHILE attempt davom etmoqda, THE Mock_Test_Runner SHALL tepada Overview_Drawer'ni ochadigan
   burger menyu tugmasini ko'rsatadi.
2. WHEN talaba burger menyu tugmasini bosadi, THE Overview_Drawer SHALL barcha Section'larni
   (Leseverstehen, Sprachbausteine, Hörverstehen, Schriftlicher Ausdruck, Mündlicher Ausdruck) va
   ularning Teile'larini rasmiy TELC B1 tartibida ko'rsatadi.
3. WHEN talaba Overview_Drawer'da bir Teil'ni tanlaydi, THE Mock_Test_Runner SHALL o'sha Teil'ga
   o'tadi va Overview_Drawer'ni yopadi.
4. WHILE Overview_Drawer ochiq, THE Overview_Drawer SHALL joriy faol Teil'ni vizual ravishda
   ajratib ko'rsatadi.
5. WHEN talaba Overview_Drawer'da Teil orasida o'tadi, THE Mock_Test_Runner SHALL talabaning oldin
   kiritgan javoblarini saqlab qoladi.
6. THE Overview_Drawer SHALL Section nomlarini interfeys tilidan (uz, kaa, ru, de) qat'i nazar
   nemis tilida (Leseverstehen, Sprachbausteine, Hörverstehen, Schriftlicher Ausdruck, Mündlicher
   Ausdruck) ko'rsatadi.

### Requirement 3: Animatsiyali burger menyu tugmasi

**User Story:** B1 talabasi sifatida, men menyu tugmasi ochilganda silliq animatsiya bilan o'zgarishini
xohlayman, shunda menyu holati menga aniq ko'rinadi.

#### Acceptance Criteria

1. WHILE Overview_Drawer yopiq, THE Burger_Menu_Icon SHALL uchta gorizontal chiziq (hamburger)
   shaklida ko'rinadi.
2. WHEN Overview_Drawer ochiladi, THE Burger_Menu_Icon SHALL uchta chiziqdan "X" shakliga
   animatsiya bilan o'tadi.
3. WHEN Overview_Drawer yopiladi, THE Burger_Menu_Icon SHALL "X" shaklidan uchta chiziq shakliga
   animatsiya bilan qaytadi.
4. THE Burger_Menu_Icon SHALL o'tish animatsiyasini 400 millisekunddan oshmaydigan davomiylikda
   bajaradi.

### Requirement 4: Savol va variantlarning gorizontal joylashuvi

**User Story:** B1 talabasi sifatida, men savollar va variantlarni gorizontal joylashuvda ko'rishni
xohlayman, shunda ekrandan samaraliroq foydalanaman va savollar orasida tez harakatlanaman.

#### Acceptance Criteria

1. WHILE talaba bir Teil ustida ishlamoqda, THE Mock_Test_Runner SHALL o'sha Teil'ning savollarini
   gorizontal, suriladigan navigatsiya tasmasi orqali ko'rsatadi.
2. WHEN talaba navigatsiya tasmasidagi savol indikatorini tanlaydi, THE Mock_Test_Runner SHALL
   o'sha savolni faol qiladi.
3. WHERE bir savolning variantlari qisqa (masalan, harf tanlovlari a–l yoki x), THE
   Mock_Test_Runner SHALL variantlarni gorizontal joylashuvda ko'rsatadi.
4. WHILE savol-navigatsiya tasmasi ko'rsatilmoqda, THE Mock_Test_Runner SHALL javob berilgan va
   javob berilmagan savollarni vizual ravishda farqlab ko'rsatadi.
5. THE Mock_Test_Runner SHALL nemis tilidagi imtihon mazmuni (matn, savol, variantlar)
   o'qilishini gorizontal joylashuv tufayli kesib qo'ymasdan to'liq ko'rsatadi.

### Requirement 5: Yuqorida sanab turuvchi taymer

**User Story:** B1 talabasi sifatida, men test davomida yuqorida qolgan vaqtni ko'rsatuvchi taymerni
ko'rishni xohlayman, shunda haqiqiy imtihondagidek vaqtimni boshqaraman.

#### Acceptance Criteria

1. WHILE attempt davom etmoqda, THE Section_Timer SHALL runner tepasida joriy Section uchun qolgan
   vaqtni sanab turuvchi (countdown) shaklda ko'rsatadi.
2. THE Section_Timer SHALL har bir Section uchun rasmiy TELC B1 vaqt me'yoridan foydalanadi.
3. WHEN talaba boshqa Section'ga o'tadi, THE Section_Timer SHALL yangi Section uchun belgilangan
   vaqt me'yorini ko'rsatadi.
4. WHILE qolgan vaqt belgilangan past chegaradan kam VA noldan katta, THE Section_Timer SHALL
   ogohlantiruvchi vizual holatni (masalan, rang o'zgarishi) ko'rsatadi.
5. WHEN qolgan vaqt nolga yetadi, THE Section_Timer SHALL ogohlantiruvchi (past vaqt) vizual
   holatini to'xtatadi va "vaqt tugadi" holatiga o'tadi.
6. WHEN qolgan vaqt nolga yetadi, THE Section_Timer SHALL "00:00" o'rniga alohida "vaqt tugadi"
   xabari yoki vizual ko'rsatkichini ko'rsatadi.
7. WHEN qolgan vaqt nolga yetadi, THE Mock_Test_Runner SHALL attempt'ni avtomatik yakunlamaydi va
   talaba ishlashda davom etishi mumkin bo'ladi (auto-submit yoki grace-period yo'q).
8. THE Section_Timer SHALL vaqt qiymatlarini sanoqdagi raqamlar bilan ko'rsatadi va atrof matnni
   Localization_Service orqali joriy lokalda ko'rsatadi.

### Requirement 6: Chiqishni tasdiqlash oynasini saqlash

**User Story:** B1 talabasi sifatida, men testdan tasodifan chiqib ketmasligim uchun chiqishdan oldin
tasdiqlash so'ralishini xohlayman.

#### Acceptance Criteria

1. IF talaba davom etayotgan attempt'dan chiqmoqchi bo'lsa, THEN THE Mock_Test_Runner SHALL
   Exit_Confirmation oynasini ko'rsatadi.
2. WHEN talaba Exit_Confirmation'da davom etishni tanlaydi, THE Mock_Test_Runner SHALL talabani
   chiqishdan oldingi aynan o'sha holatga (o'sha Teil, o'sha javoblar va o'sha pozitsiya)
   qaytaradi va hech qanday javobni o'chirmaydi.
3. WHEN talaba Exit_Confirmation'da chiqishni tasdiqlaydi, THE Mock_Test_Runner SHALL attempt'dan
   chiqadi.
4. THE Exit_Confirmation SHALL Design_System ranglari va Localization_Service matnlari bilan
   ko'rsatiladi.

### Requirement 7: Natijada har bir savol bo'yicha to'liq ko'rib chiqish

**User Story:** B1 talabasi sifatida, test tugagach men qaysi savollarga to'g'ri va qaysiga noto'g'ri
javob berganimni har bir savol bo'yicha ko'rishni xohlayman, shunda xatolarimni aniqlab o'rganaman.

#### Acceptance Criteria

1. WHEN attempt yakunlanadi, THE Question_Review SHALL har bir Auto_Graded_Section savoli uchun
   talabaning javobi to'g'ri yoki noto'g'ri ekanini ko'rsatadi.
2. WHEN bir Auto_Graded_Section savoli javob berilmagan holda yakunlangan, THE Question_Review
   SHALL o'sha savolni noto'g'ri (javob berilmagan) sifatida ko'rsatadi.
3. THE Question_Review SHALL har bir Auto_Graded_Section savoli uchun talaba tanlagan variant va
   to'g'ri variantni ko'rsatadi.
4. THE Question_Review SHALL Auto_Graded_Section'lar uchun per-savol to'g'ri/noto'g'ri tafsilotlarini
   AI_Evaluated_Section'larga oid taqdimot qoidalaridan qat'i nazar har doim ko'rsatadi.
5. WHERE bir Section AI_Evaluated_Section hisoblanadi, THE Question_Review SHALL per-savol
   to'g'ri/noto'g'ri belgisi o'rniga o'sha Section uchun AI bahosi va feedback'ini ko'rsatadi.
6. IF bir AI_Evaluated_Section uchun AI bahosi mavjud bo'lmasa, THEN THE Question_Review SHALL
   o'sha Section uchun "baholash mavjud emas" holatini ko'rsatadi va qolgan Section'lar ko'rib
   chiqilishiga to'sqinlik qilmaydi.
7. THE Question_Review SHALL mavjud Section'lar bo'yicha umumiy ballar va pass/fail natijasini
   (avvalgi result ekrani ko'rsatuvi) saqlab qoladi.

### Requirement 8: Pastdagi Previous va Next tugmalari

**User Story:** B1 talabasi sifatida, men ekran pastida oldingi va keyingi tugmalari orqali Teile
orasida harakatlanishni xohlayman, shunda test bo'ylab nazorat bilan o'taman.

#### Acceptance Criteria

1. WHILE attempt davom etmoqda VA joriy Teil birinchi Teil emas, THE Mock_Test_Runner SHALL
   ekran pastida "Previous" tugmasini ko'rsatadi.
2. WHILE attempt davom etmoqda VA joriy Teil oxirgi Teil emas, THE Mock_Test_Runner SHALL ekran
   pastida faol "Next" tugmasini ko'rsatadi.
3. WHILE joriy Teil oxirgi Teil, THE Mock_Test_Runner SHALL "Next" tugmasini o'chirilgan
   (disabled) holatda ko'rsatadi va uni "Finish" yoki yakunlash tugmasiga o'zgartirmaydi.
4. WHILE joriy Teil oxirgi Teil, THE Mock_Test_Runner SHALL "Next" tugmasidan alohida, aniq
   yakunlash (complete/finish) boshqaruvini ko'rsatadi.
5. WHEN talaba oxirgi Teil'da alohida yakunlash boshqaruvini bosadi, THE Mock_Test_Runner SHALL
   natija ekranini (Question_Review bilan) ko'rsatadi.
6. WHILE joriy Teil oxirgi Teil emas, THE Mock_Test_Runner SHALL yakunlash (complete/finish)
   boshqaruvini ko'rsatmaydi va talaba attempt'ni erta yakunlay olmaydi.
7. THE Previous va Next tugmalari SHALL Design_System uslubida (`AppColors`, accent va dark rejim)
   ko'rsatiladi.

### Requirement 9: Barcha Section ko'rinishlarining ko'rinishi va erishilishi

**User Story:** B1 talabasi sifatida, men Hörverstehen, Schriftlicher Ausdruck va Mündlicher Ausdruck
bo'limlari ham ko'rinishini va ularga osongina o'tishni xohlayman, shunda butun imtihonni to'liq
o'taman.

#### Acceptance Criteria

1. THE Mock_Test_Runner SHALL to'rt Section ko'rinishini ham (Lesen/Sprachbausteine, Hören,
   Schreiben, Sprechen) attempt davomida erishiladigan qiladi.
2. WHEN talaba Schreiben Teil'iga yetib boradi, THE Mock_Test_Runner SHALL Schriftlicher Ausdruck
   ko'rinishini ko'rsatadi.
3. WHEN talaba Sprechen Teil'iga yetib boradi, THE Mock_Test_Runner SHALL Mündlicher Ausdruck
   ko'rinishini ko'rsatadi.
4. THE Overview_Drawer SHALL barcha Section'larni (jumladan Hörverstehen, Schriftlicher Ausdruck,
   Mündlicher Ausdruck) ro'yxatda ko'rsatadi va ularga to'g'ridan-to'g'ri o'tishni ta'minlaydi.

### Requirement 10: Domen yadrosini o'zgartirmaslik

**User Story:** Texnik egasi sifatida, men qayta loyihalash faqat ko'rinishga ta'sir qilishini va
test mantig'i o'zgarmasligini xohlayman, shunda baholash va yig'ish (assembly) ishonchli qoladi.

#### Acceptance Criteria

1. THE Mock_Test_Redesign SHALL Domain_Core'ning (assembler, scorer, controller xulqi, attempt
   modellari) mavjud baholash va yig'ish xulqini o'zgartirmaydi.
2. WHERE Question_Review uchun per-savol to'g'ri/noto'g'rilik kerak bo'lsa, THE
   `MockTestController` SHALL faqat o'qishga mo'ljallangan (read-only) yordamchi metodlar bilan
   to'ldiriladi va mavjud holatni o'zgartirmaydi.
3. THE Mock_Test_Redesign SHALL mavjud Section ko'rinishlari, intro va result ekranlarini qayta
   ishlatadi va ularning baholash/yig'ish mantig'ini qayta yozmaydi.

### Requirement 11: Lokalizatsiya

**User Story:** O'z tilida ishlatuvchi talaba sifatida, men interfeys matnlarini o'z lokalimda
ko'rishni xohlayman, lekin nemis imtihon mazmuni nemischa qolishini kutaman.

#### Acceptance Criteria

1. THE Mock_Test_Redesign SHALL barcha ilova muallifligidagi interfeys matnlarini (taymer atrofi,
   menyu, tugma va review yorliqlari) Localization_Service orqali joriy lokalda (uz, kaa, ru, de)
   ko'rsatadi.
2. THE Mock_Test_Redesign SHALL nemis imtihon mazmunini (nemis savol matni, passajlar va Section/
   Teil nomlari) joriy lokaldan qat'i nazar nemis tilida ko'rsatadi.
3. IF joriy lokal uchun matn mavjud bo'lmasa, THEN THE Localization_Service SHALL o'zbekcha (`uz`)
   fallback matnini qaytaradi.
