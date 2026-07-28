# Firebase Admin Scripts

Bu script'lar Firebase Firestore ma'lumotlarini boshqarish uchun ishlatiladi.

## 🔧 O'rnatish

### 1. Node.js o'rnating
- [Node.js](https://nodejs.org/) versiyasi 16 yoki yuqori

### 2. Dependencies o'rnating
```bash
cd scripts
npm install
```

### 3. Firebase Service Account Key olish

1. [Firebase Console](https://console.firebase.google.com/) ga kiring
2. Loyihangizni tanlang
3. ⚙️ Settings → Project settings → Service accounts
4. "Generate new private key" tugmasini bosing
5. `serviceAccountKey.json` nomli faylni `scripts` papkasiga joylashtiring

**⚠️ MUHIM:** `serviceAccountKey.json` faylini `.gitignore` ga qo'shing!

## 📝 Mavjud Script'lar

### reset_user_results.js

Barcha student foydalanuvchilarning natijalarini tozalaydi:

- ✅ `totalStars` → 0
- ✅ `results` subcollection (lesen/horen) → o'chiriladi
- ✅ `mock_test_history` subcollection → o'chiriladi

#### Ishlatish:

```bash
npm run reset
```

yoki

```bash
node reset_user_results.js
```

#### Script nima qiladi:

1. Barcha `role === 'student'` foydalanuvchilarni topadi
2. Har birida:
   - `totalStars` ni 0 ga o'rnatadi
   - `users/{uid}/results` collection'dagi barcha hujjatlarni o'chiradi
   - `users/{uid}/mock_test_history` collection'dagi barcha hujjatlarni o'chiradi
3. Natijalarni ko'rsatadi

#### Xavfsizlik:

- Script ishga tushishdan oldin tasdiqlash so'raydi
- Har bir user uchun batafsil log ko'rsatiladi
- Xatolik yuz berganda davom etadi va oxirida hisobotni chiqaradi

## ⚠️ Ogohlantirishlar

1. **Backup oling!** Script qaytarib bo'lmaydigan o'zgarishlar kiritadi
2. **Test muhitda sinab ko'ring** production'da ishlatishdan oldin
3. **Service Account Key'ni himoyalang** - bu maxfiy ma'lumot!
4. **`.gitignore` ga qo'shing:**
   ```
   scripts/serviceAccountKey.json
   scripts/node_modules/
   ```

## 🔒 .gitignore

`scripts` papkasi uchun `.gitignore` fayl:

```
# Service Account Key (MAXFIY!)
serviceAccountKey.json

# Node modules
node_modules/

# Logs
*.log
npm-debug.log*
```

## 📞 Yordam

Savol yoki muammo bo'lsa, development team bilan bog'laning.
