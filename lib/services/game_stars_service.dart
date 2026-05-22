import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O'yinlardan toplangan yulduzlarni qurilmada va Firestore da saqlaydi.
class GameStarsService {
  static String _derDieDasKey(String uid) => 'game_stars_der_die_das_$uid';
  static String _strangeSentencesKey(String uid) =>
      'game_stars_strange_sentences_$uid';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<int> getDerDieDasStars(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_derDieDasKey(uid)) ?? 0;
  }

  /// Raunddan olingan yulduzlarni qo'shadi; yangi jami qiymatni qaytaradi.
  static Future<int> addDerDieDasStars(String uid, int earned) async {
    if (earned <= 0) return getDerDieDasStars(uid);
    final prefs = await SharedPreferences.getInstance();
    final key = _derDieDasKey(uid);
    final total = (prefs.getInt(key) ?? 0) + earned;
    await prefs.setInt(key, total);
    
    // Firestore ga ham saqlash
    await _syncStarsToFirestore(uid);
    
    return total;
  }

  static Future<int> getStrangeSentencesStars(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_strangeSentencesKey(uid)) ?? 0;
  }

  static Future<int> addStrangeSentencesStars(String uid, int earned) async {
    if (earned <= 0) return getStrangeSentencesStars(uid);
    final prefs = await SharedPreferences.getInstance();
    final key = _strangeSentencesKey(uid);
    final total = (prefs.getInt(key) ?? 0) + earned;
    await prefs.setInt(key, total);
    
    // Firestore ga ham saqlash
    await _syncStarsToFirestore(uid);
    
    return total;
  }

  /// Barcha o'yinlar yig'indisi.
  static Future<int> getTotalStars(String uid) async {
    final der = await getDerDieDasStars(uid);
    final strange = await getStrangeSentencesStars(uid);
    return der + strange;
  }

  /// Yulduzlarni Firestore users collection ga sinxronizatsiya qiladi
  static Future<void> _syncStarsToFirestore(String uid) async {
    try {
      final total = await getTotalStars(uid);
      await _firestore.collection('users').doc(uid).set({
        'totalStars': total,
      }, SetOptions(merge: true));
    } catch (e) {
      // Xatolarni ignore qilish, local storage ishlaydi
    }
  }

  /// Firestore dan userning yulduzlarini olish
  static Future<int> getStarsFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['totalStars'] ?? 0;
      }
    } catch (e) {
      // Xatolarni ignore qilish
    }
    return 0;
  }
}
