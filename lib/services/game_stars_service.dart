import 'package:shared_preferences/shared_preferences.dart';

/// O'yinlardan toplangan yulduzlarni qurilmada saqlaydi (o'yin holati emas).
class GameStarsService {
  static String _derDieDasKey(String uid) => 'game_stars_der_die_das_$uid';

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

  /// Hozircha barcha o'yinlar yig'indisi (kelajakda boshqa o'yinlar qo'shiladi).
  static Future<int> getTotalStars(String uid) async {
    return getDerDieDasStars(uid);
  }
}
