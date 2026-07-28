# 🔔 Push Notification Debug Yo'riqnomasi

## Muammo
Ilova ichida notification ko'rinmoqda (Firestore'ga yozilmoqda), lekin telefon yuqorisidan push notification kelmayapti.

---

## 1️⃣ OneSignal Sozlamalari Tekshirish

### env.txt faylini tekshiring:
```bash
ONESIGNAL_APP_ID=b231383b-7565-412c-912b-3a7c594da80b
CF_WORKER_URL=https://berlinnukus-proxy.danebaevkadastr.workers.dev
APP_TOKEN=Wor7pFuZSsendpyxDPgx4pHUj7An93sy8gRzO7IVkk4x
```

✅ Barcha qiymatlar to'ldirilgan bo'lishi kerak

---

## 2️⃣ Console Loglarni Tekshirish

Yangi notification yuborilganda console'da quyidagi loglar ko'rinishi kerak:

### OneSignal Initialization:
```
🔔 OneSignal setup boshlandi...
   App ID: b231383b-7565-412c-912b-3a7c594da80b
🔔 OneSignal initialized
🔔 Permission requested
✅ OneSignal setup tugallandi
```

### OneSignal Login:
```
🔔 OneSignal login: abc123xyz456
✅ OneSignal login tugallandi
```

### Notification Yuborish:
```
📤 OneSignal Push yuborish boshlandi...
   UserId: abc123xyz456
   Title: Yangi xabar
   Body: Teacher sizga xabar yubordi
   AppId: b231383b-7565-412c-912b-3a7c594da80b
   ProxyUrl: https://berlinnukus-proxy.danebaevkadastr.workers.dev
📡 Request body: {...}
📥 Response status: 200
📥 Response body: {"id":"...","recipients":1}
✅ OneSignal push sent successfully
```

---

## 3️⃣ Ehtimoliy Muammolar va Yechimlar

### ❌ Muammo 1: "APP ID not set"
**Sabab:** `env.txt` faylida `ONESIGNAL_APP_ID` yo'q yoki noto'g'ri

**Yechim:**
1. `env.txt` faylini oching
2. `ONESIGNAL_APP_ID=b231383b-7565-412c-912b-3a7c594da80b` mavjudligini tekshiring
3. Hot restart qiling

---

### ❌ Muammo 2: "CF_WORKER_URL not set"
**Sabab:** Cloudflare Worker URL yo'q

**Yechim:**
1. `env.txt` faylida `CF_WORKER_URL` mavjudligini tekshiring
2. Hot restart qiling

---

### ❌ Muammo 3: Response status 400-500
**Sabab:** Worker xatolik qaytarmoqda

**Console'da ko'rish kerak:**
```
📥 Response status: 400
📥 Response body: {"error":"..."}
❌ Failed to send OneSignal push: ...
```

**Yechim:**
1. Cloudflare Worker loglarini tekshiring
2. Worker'da REST API key to'g'ri sozlanganligini tekshiring

---

### ❌ Muammo 4: Response 200, lekin push kelmayapti
**Sabab:** User device'ida subscription yo'q

**Tekshirish:**
1. OneSignal Dashboard'ga kiring: https://dashboard.onesignal.com/
2. Loyihangizni tanlang
3. **Audience** → **All Users** ga o'ting
4. User ID bo'yicha qidiring (external_id)

**Agar user topilmasa:**
```dart
// OneSignalHelper.login() chaqirilmaganligini tekshiring
// main.dart va user_provider.dart da tekshiring
```

---

### ❌ Muammo 5: Permission berilmagan
**Android:**
- Settings → Apps → Berlin-Nukus → Notifications → ON

**iOS:**
- Settings → Berlin-Nukus → Notifications → Allow Notifications → ON

---

## 4️⃣ Test Qilish

### Test notification yuborish:
1. Teacher sifatida login qiling
2. Guruhga yangi dars qo'shing
3. Console loglarni kuzating
4. Student ilovasini yoping (background'ga o'tkazing)
5. Push notification kelishi kerak

---

## 5️⃣ OneSignal Dashboard Tekshirish

1. [OneSignal Dashboard](https://dashboard.onesignal.com/) ga kiring
2. Berlin-Nukus loyihasini tanlang
3. **Messages** → **Delivery** → So'nggi notification'larni ko'ring
4. **Sent** va **Delivered** raqamlarini tekshiring

**Sent > 0, Delivered = 0** → User subscription yo'q
**Sent > 0, Delivered > 0** → Push yuborildi, lekin ko'rinmayapti

---

## 6️⃣ Cloudflare Worker Tekshirish

Worker URL: `https://berlinnukus-proxy.danebaevkadastr.workers.dev`

### Worker loglarini ko'rish:
1. [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Workers & Pages → berlinnukus-proxy → Logs
3. Real-time logs tab'ni oching
4. Notification yuboring va loglarni kuzating

---

## 7️⃣ Diagnostika Testi

Quyidagi kodni istalgan joydan chaqiring:

```dart
// Test notification yuborish
final notificationService = NotificationService();
await notificationService.createNotification(
  AppNotification(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: 'Test Notification',
    body: 'Bu test xabari',
    type: 'test',
    createdAt: DateTime.now(),
    userId: 'STUDENT_USER_ID', // Real student ID
  ),
);
```

Console'da barcha loglarni tekshiring.

---

## ✅ Muvaffaqiyatli Push Notification

Agar hamma narsa to'g'ri bo'lsa, console'da:
```
📤 OneSignal Push yuborish boshlandi...
📥 Response status: 200
📥 Response body: {"id":"xyz-123","recipients":1}
✅ OneSignal push sent successfully
```

Va telefonda push notification ko'rinishi kerak! 🎉

---

## 📞 Yordam

Agar muammo hal bo'lmasa:
1. Barcha console loglarni screenshot qiling
2. OneSignal Dashboard screenshot qiling
3. Cloudflare Worker loglarini screenshot qiling
