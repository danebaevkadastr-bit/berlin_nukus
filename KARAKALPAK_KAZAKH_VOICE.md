# Qoraqalpoq Tili uchun Qozoq Ovozi 🎙️

## O'zgarishlar

Qoraqalpoq tili (kaa) uchun **qozoq tilini (kk-KZ)** ishlatish sozlandi. Sababi: Gemini AI modeli qoraqalpoq tilini bilmaydi, lekin qozoq tili qoraqalpoqchaga eng yaqin turkiy til.

## MUHIM: Ovoz va Til

### Nima Qilindi?
- ✅ **Ovoz**: Qozoqcha (kk-KZ) - Gemini Live API qo'llab-quvvatlaydi
- ✅ **Voice name**: Aoede (Universal voice for kk-KZ)
- ✅ **Gaplashish**: Қазақша
- ✅ **Tushuntirishlar**: Қазақша
- ✅ Bot to'liq қазақша ishlaydi

### Strategiya
Bot **қазақ tilida** gaplashadi va tushuntiradi. Nemis so'zlarini o'rgatishda nemis tilidan misollar beradi. Bu eng yaxshi yondashuv - ona tilida tushuntirish va nemis tilini o'rgatish.

## Misol

```
Bot қазақша: "Сәлем! Бүгін не үйренеміз?"

User: "Ich habe gegangen nach Berlin."

Bot қазақша tuzatadi:
"Тоқта! 'Ich habe gegangen' қате! Қозғалыс етістіктері 'sein' қолданады. 
Дұрысы: 'Ich bin gegangen'. Есте сақта - harakat fe'llari 'sein' bilan!"
```

## Qilingan Yangiliklar

### 1. **Gemini Live Ovoz API** 🎤
**Fayl**: `lib/services/gemini_live_service.dart`

- ✅ Qoraqalpoq tili (kaa) uchun **қазақ ovozi (kk-KZ)**
- ✅ Voice name: `Aoede` (Universal Gemini voice)
- ✅ Boshqa tillar uchun `de-DE` (Nemis)
- ✅ Gemini Live API 70+ tilni qo'llab-quvvatlaydi

```dart
// Qoraqalpoq uchun qozoq ovozi
final speechLangCode = _uiLangCode == 'kaa' ? 'kk-KZ' : 'de-DE';
final voiceName = _uiLangCode == 'kaa' ? 'Aoede' : 'Puck';
```

### 2. **Gemini Live Prompt - Қазақша** 📝
**Fayl**: `lib/services/gemini_live_prompt.dart`

- ✅ Bot **қазақша gaplashadi**
- ✅ Xato tuzatishlar **қазақша**
- ✅ Nemis so'zlarini o'rgatishda nemis misollar beradi
- ✅ System prompt қазақча

```dart
case 'kaa':
  return 'KASACHISCH'; // Bot қазақша gaplashadi
```

### 3. **Qozoqcha Misollar** 💬

Bot endi qoraqalpoq foydalanuvchilar uchun qozoq tilida tushuntiradi:

```
Мысал (Қазақша):
User: "Ich habe gegangen nach Berlin."
AI: "Тоқта! 'Ich habe gegangen'?! Шынымен бе?! Қозғалыс етістіктері 'sein' қолданады, 
     'haben' емес! Дұрысы: 'Ich bin gegangen'. Мұны 1-сынып баласы да біледі ғой!"
```

## Tillar Mapping Jadvali

| Dastur Tili | AI Ovoz | Voice Name | Til | Izoh |
|-------------|---------|------------|-----|------|
| uz          | de-DE   | Puck       | Nemischa | Bot nemis o'qituvchisi |
| **kaa**     | **kk-KZ** | **Aoede** | **Қазақша** | **Bot қазақша gaplashadi** ✅ |
| ru          | de-DE   | Puck       | Немецкий | Bot nemis o'qituvchisi |
| de          | de-DE   | Puck       | Deutsch  | Bot nemis o'qituvchisi |

**Strategiya**: 
- O'zbek, rus, nemis foydalanuvchilar: Bot nemischa gaplashadi
- **Qoraqalpoq foydalanuvchilar**: Bot **қазақша** gaplashadi (yaqin til)

## Test Qilish

1. Ilovada tilni **Qaraqalpaqsha** (kaa) ga o'zgartiring
2. Gemini Live AI bilan gaplashing
3. ✅ Bot **қазақша gaplashadi** (kk-KZ ovozi)
4. ✅ Xatolarni **қазақша** tushuntiradi
5. ✅ "O'ylayabman" (thinking) muammosi yo'q!
6. ✅ Qozoq ovozi (Aoede) ishlaydi

## Muammo va Yechim

### ✅ Oxirgi Yechim (v1.2)
**Қазақ ovozi (kk-KZ) ISHLAYDI!** ✅
- Gemini Live API 70+ tilni qo'llab-quvvatlaydi, shu jumladan қазақ tilini
- Voice: Aoede (Universal voice, barcha tillar uchun)
- Bot қазақша gaplashadi va tushuntiradi
- "O'ylayabman" muammosi hal qilindi

## Texnik Ma'lumotlar

- **API**: Google Gemini 2.0 Flash Live
- **Qozoq ovoz kodi**: `kk-KZ` (Қазақстан қазақ тілі)
- **Voice**: Aoede (Universal Gemini voice)
- **Format**: PCM 16-bit, 24kHz
- **Qo'llab-quvvatlangan tillar**: 70+ (Gemini Live API)

## Kelajak Yaxshilashlar

- [x] "O'ylayabman" muammosini hal qilish (DONE ✅)
- [x] Қазақ ovozini qo'llash (DONE ✅)
- [ ] Qozoq-nemis ikki tilli lug'at integratsiyasi
- [ ] Lotin va kirill yozuvlarini qo'llab-quvvatlash
- [ ] Qoraqalpoq dialekti uchun maxsus so'zlar bazasi
- [ ] Boshqa qozoq ovozlarini sinash (Aoede dan boshqasi)

---
**Sana**: 2026-07-07  
**Versiya**: 1.2 (Қазақ ovozi qo'shildi)  
**Muallif**: Kiro AI  
**Strategiya**: Қазақ ovozi (kk-KZ) + Қазақша gaplashish (kaa uchun) ✅
