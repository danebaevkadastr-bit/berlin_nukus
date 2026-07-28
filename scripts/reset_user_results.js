// Firebase Admin SDK orqali barcha foydalanuvchilar natijalarini reset qilish
// Node.js muhitida ishlatish uchun

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Firebase service account key

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function resetAllUserResults() {
  console.log('🔄 Barcha foydalanuvchilar natijalarini reset qilish boshlandi...\n');

  try {
    // 1. Barcha student foydalanuvchilarni olish
    const usersSnapshot = await db.collection('users')
      .where('role', '==', 'student')
      .get();

    console.log(`📊 Jami ${usersSnapshot.size} ta student topildi.\n`);

    let successCount = 0;
    let errorCount = 0;

    // 2. Har bir foydalanuvchi uchun
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userName = userDoc.data().fullName || 'Noma\'lum';

      try {
        console.log(`👤 ${userName} (${userId}):`);

        // a) totalStars ni 0 ga o'rnatish
        await db.collection('users').doc(userId).update({
          totalStars: 0
        });
        console.log('   ✅ totalStars → 0');

        // b) results subcollection'dagi barcha hujjatlarni o'chirish (lesen, horen)
        const resultsSnapshot = await db.collection('users')
          .doc(userId)
          .collection('results')
          .get();

        if (!resultsSnapshot.empty) {
          const batch = db.batch();
          resultsSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
          });
          await batch.commit();
          console.log(`   ✅ ${resultsSnapshot.size} ta result o'chirildi (lesen/horen)`);
        } else {
          console.log('   ℹ️  results yo\'q');
        }

        // c) mock_test_history subcollection'dagi barcha hujjatlarni o'chirish
        const mockTestSnapshot = await db.collection('users')
          .doc(userId)
          .collection('mock_test_history')
          .get();

        if (!mockTestSnapshot.empty) {
          const batch = db.batch();
          mockTestSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
          });
          await batch.commit();
          console.log(`   ✅ ${mockTestSnapshot.size} ta mock test o'chirildi`);
        } else {
          console.log('   ℹ️  mock test yo\'q');
        }

        successCount++;
        console.log('');

      } catch (error) {
        console.error(`   ❌ Xatolik: ${error.message}\n`);
        errorCount++;
      }
    }

    console.log('═══════════════════════════════════════════════');
    console.log('📈 NATIJA:');
    console.log(`   ✅ Muvaffaqiyatli: ${successCount}`);
    console.log(`   ❌ Xatolik: ${errorCount}`);
    console.log('═══════════════════════════════════════════════\n');

  } catch (error) {
    console.error('❌ Umumiy xatolik:', error);
  } finally {
    process.exit(0);
  }
}

// Tasdiqlash
console.log('⚠️  OGOHLANTIRISH: Bu script barcha studentlarning natijalarini o\'chiradi!');
console.log('   - totalStars → 0');
console.log('   - results (lesen/horen) → o\'chiriladi');
console.log('   - mock_test_history → o\'chiriladi\n');

const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Davom etishni xohlaysizmi? (ha/yo\'q): ', (answer) => {
  rl.close();
  if (answer.toLowerCase() === 'ha' || answer.toLowerCase() === 'yes') {
    resetAllUserResults();
  } else {
    console.log('❌ Bekor qilindi.');
    process.exit(0);
  }
});
