# Requirements Document

## Introduction

Sprechen AI — Berlin-Nukus Flutter ilovasidagi AI mentor bilan nemis tilida suhbat qilish moduli. Hozirda barcha mavzular va suhbatlar uchun bir xil AI prompt ishlatiladi, daraja farqi yo'q. Ushbu feature foydalanuvchiga o'z darajasini (A1, A2, B1) tanlash imkonini beradi va AI shu darajaga mos lug'at, grammatika va gap murakkabligini qo'llaydi. Daraja Firebase profilida saqlanadi va barcha Sprechen AI suhbatlarida avtomatik qo'llaniladi.

## Glossary

- **Sprechen_AI**: Berlin-Nukus ilovasidagi AI mentor bilan nemis tilida suhbat qilish moduli
- **Level**: Foydalanuvchining nemis tili bilim darajasi — A1 (boshlang'ich), A2 (elementar), B1 (o'rta)
- **Level_Prompt**: AI ga yuboriladigan tizim ko'rsatmasi, foydalanuvchi darajasiga mos lug'at va grammatika talablarini o'z ichiga oladi
- **UserProfile**: Firebase Firestore'dagi foydalanuvchi ma'lumotlari hujjati (`users/{uid}`)
- **ChatScreen**: Foydalanuvchi va AI mentor o'rtasidagi suhbat ekrani (`chat_screen.dart`)
- **ConversationsScreen**: Mavzular ro'yxati va daraja tanlash ekrani (`conversations_screen.dart`)
- **UserProvider**: Foydalanuvchi holati va Firebase ma'lumotlarini boshqaruvchi Flutter ChangeNotifier
- **LevelSelector**: Foydalanuvchiga daraja tanlash imkonini beruvchi UI komponenti
- **ContextPrompt**: AI ga yuboriladigan to'liq tizim ko'rsatmasi (daraja + mavzu + qoidalar)
- **A1_Level**: Boshlang'ich daraja — juda oddiy lug'at, qisqa gaplar (3–5 so'z), Present Tense
- **A2_Level**: Elementar daraja — kengaytirilgan lug'at, o'rta uzunlikdagi gaplar, Perfekt va Präteritum
- **B1_Level**: O'rta daraja — murakkab lug'at, uzun gaplar, modal fe'llar, Konjunktiv II

## Requirements

### Requirement 1: Daraja tanlash va saqlash

**User Story:** As a student, I want to select my German proficiency level (A1, A2, or B1), so that the AI mentor adapts its language complexity to match my current ability.

#### Acceptance Criteria

1. WHEN a student opens the Sprechen AI section and no `sprechen_level` value exists in SharedPreferences on the current device, THE LevelSelector SHALL display a level selection screen with A1, A2, and B1 options before showing the conversations list, regardless of any level saved on other devices or in Firebase.
2. WHEN a student selects a level, THE UserProvider SHALL save the selected level to the `sprechen_level` field in the Firebase Firestore `users/{uid}` document.
3. WHEN a student selects a level, THE UserProvider SHALL also save the selected level to SharedPreferences under the key `sprechen_level` for offline access.
4. WHEN a student has a `sprechen_level` value stored in SharedPreferences on the current device, THE ConversationsScreen SHALL load and display that level as the active selection without showing the level selection screen again.
5. IF the Firebase save operation fails, THEN THE UserProvider SHALL retain the level in SharedPreferences and retry the Firebase save on the next app launch.
6. WHEN a student changes their level from the profile or settings, THE UserProvider SHALL update both Firebase Firestore and SharedPreferences with the new level value.

---

### Requirement 2: Daraja ko'rsatmasi (Level Prompt)

**User Story:** As a student, I want the AI mentor to use vocabulary and grammar appropriate for my selected level, so that I can practice German at the right difficulty.

#### Acceptance Criteria

1. WHEN a ChatScreen session starts, THE ContextPrompt SHALL include a level-specific instruction block derived from the student's active `sprechen_level`.
2. WHILE the student's level is A1, THE ContextPrompt SHALL instruct the AI to use only A1 vocabulary (Grundwortschatz), sentences of 3–5 words, Present Tense (Präsens) only, and no subordinate clauses.
3. WHILE the student's level is A2, THE ContextPrompt SHALL instruct the AI to use A1–A2 vocabulary only, sentences of 6–10 words, Perfekt and Präteritum tenses, and simple subordinate clauses with `weil` and `dass` — A2 students SHALL NOT receive B1-level vocabulary or grammar.
4. WHILE the student's level is B1, THE ContextPrompt SHALL instruct the AI to use B1 vocabulary, sentences of 10–15 words, modal verbs (können, müssen, dürfen, sollen), Konjunktiv II for polite requests, and complex subordinate clauses — B1 students SHALL NOT receive A1-only simplified responses.
5. THE ContextPrompt SHALL combine the level instruction block with the existing topic instruction and chat rules without removing or overriding any existing rule.
6. WHEN the student's level is not set or cannot be loaded, THE ContextPrompt SHALL default to A1 level instructions.

---

### Requirement 3: Daraja ko'rsatgichi (Level Badge)

**User Story:** As a student, I want to see my current level displayed in the Sprechen AI interface, so that I always know which level I am practicing at.

#### Acceptance Criteria

1. THE ConversationsScreen SHALL display the student's active `sprechen_level` as a badge (e.g., "A1", "A2", "B1") in the app bar or near the level picker button.
2. WHEN a student taps the level badge or the level picker area in ConversationsScreen, THE LevelSelector SHALL open a bottom sheet showing all three level options (A1, A2, B1) with descriptions.
3. WHEN a student selects a new level from the bottom sheet, THE ConversationsScreen SHALL update the displayed badge immediately without requiring a full screen reload.
4. THE ChatScreen app bar SHALL display the student's active level as a small badge next to the topic title, so the student can see which level is active during the conversation.

---

### Requirement 4: Daraja o'zgarganda suhbatni yangilash

**User Story:** As a student, I want the AI to immediately apply my new level when I change it, so that the conversation difficulty updates without needing to restart the app.

#### Acceptance Criteria

1. WHEN a student changes their level while a ChatScreen session is open, THE ChatScreen SHALL apply the new level instructions to all subsequent AI messages in the same session.
2. WHEN a student changes their level, THE ChatScreen SHALL NOT clear existing chat history — only new AI responses SHALL use the updated level instructions.
3. WHEN a student restarts a conversation topic after having changed their level, THE ChatScreen SHALL use the new level's ContextPrompt from the beginning of the new session. WHEN a student restarts a conversation topic without having changed their level, THE ChatScreen SHALL apply the current level's ContextPrompt as normal.

---

### Requirement 5: Profil ekranida daraja ko'rsatish va o'zgartirish

**User Story:** As a student, I want to view and change my Sprechen AI level from my profile screen, so that I can manage my learning settings in one place.

#### Acceptance Criteria

1. THE StudentProfileScreen SHALL display the student's current `sprechen_level` value in the profile card section.
2. WHEN a student taps the level display in StudentProfileScreen (including when the displayed value is the default "A1"), THE LevelSelector SHALL open and allow the student to select a new level.
3. WHEN a student saves a new level from StudentProfileScreen, THE UserProvider SHALL persist the change to both Firebase Firestore and SharedPreferences.
4. WHEN the `sprechen_level` field is absent from the Firebase Firestore user document, THE UserProvider SHALL treat the level as A1 and display "A1" in the profile card.

---

### Requirement 6: Daraja ma'lumotlarini yuklash

**User Story:** As a student, I want my selected level to load quickly when I open the app, so that the AI is ready to respond at the correct level without delay.

#### Acceptance Criteria

1. WHEN the app starts and a user is authenticated, THE UserProvider SHALL load the `sprechen_level` field from Firebase Firestore as part of the existing `loadUserDataByUid` call.
2. WHILE the Firebase level data is loading, THE ConversationsScreen SHALL use the SharedPreferences cached value of `sprechen_level` to avoid blocking the UI.
3. WHEN the Firebase level data finishes loading, THE UserProvider SHALL notify listeners so that ConversationsScreen and ChatScreen update to reflect the confirmed level. IF the notification fails, THE system SHALL accept that affected screens may show outdated level information until the user navigates away or restarts the app.
4. IF the SharedPreferences cache is empty and Firebase has not yet responded, THE ConversationsScreen SHALL default to displaying "A1" until the actual level is loaded.
