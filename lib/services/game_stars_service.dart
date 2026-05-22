import 'package:shared_preferences/shared_preferences.dart';

/// O'yinlardan toplangan yulduzlarni qurilmada saqlaydi (o'yin holati emas).
class GameStarsService {
  static String _derDieDasKey(String uid) => 'game_stars_der_die_das_$uid';
  static String _strangeSentencesKey(String uid) =>
      'game_stars_strange_sentences_$uid';

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
    return total;
  }

  /// Barcha o'yinlar yig'indisi.
  static Future<int> getTotalStars(String uid) async {
    final der = await getDerDieDasStars(uid);
    final strange = await getStrangeSentencesStars(uid);
    return der + strange;
  }
}
