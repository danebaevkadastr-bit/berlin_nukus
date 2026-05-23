import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User daily streak va activity tracking
class StreakService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _lastActiveKey = 'streak_last_active';
  static const String _currentStreakKey = 'streak_current';

  /// Bugungi activity ni yozish
  static Future<void> recordActivity(String uid, {int minutes = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey(DateTime.now());
    final lastActive = prefs.getString(_lastActiveKey);

    // Firestore ga yozish
    await _firestore.collection('users').doc(uid).set({
      'lastActiveDate': today,
      'activityLog': FieldValue.arrayUnion([today]),
    }, SetOptions(merge: true));

    // Kunlik daqiqalarni yangilash
    if (minutes > 0) {
      await _firestore.collection('users').doc(uid).set({
        'dailyMinutes': FieldValue.arrayUnion([{'date': today, 'minutes': minutes}]),
      }, SetOptions(merge: true));
    }

    // Agar bugun birinchi marta kelsa, streakni yangilash
    if (lastActive != today) {
      // Local storage ga yozish
      await prefs.setString(_lastActiveKey, today);

      // Streak ni hisoblash va yangilash
      await _updateStreak(uid, lastActive);
    }
  }

  /// Streak ni hisoblash va yangilash
  static Future<void> _updateStreak(String uid, String? lastActive) async {
    if (lastActive == null) {
      // Birinchi marta
      await _setCurrentStreak(uid, 1);
      return;
    }

    final today = _getDateKey(DateTime.now());
    final yesterday = _getDateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (lastActive == yesterday) {
      // Ketma-ket - streak oshirish
      final current = await getCurrentStreak(uid);
      await _setCurrentStreak(uid, current + 1);
    } else if (lastActive != today) {
      // Kun o'tib ketgan - streakni qaytadan boshlash
      await _setCurrentStreak(uid, 1);
    }
  }

  /// Current streak ni olish
  static Future<int> getCurrentStreak(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['currentStreak'] ?? 1;
      }
    } catch (e) {
      // Xatolarni ignore qilish
    }
    return 1;
  }

  /// Current streak ni o'rnatish
  static Future<void> _setCurrentStreak(String uid, int streak) async {
    await _firestore.collection('users').doc(uid).set({
      'currentStreak': streak,
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStreakKey, streak);
  }

  /// Weekly usage data ni olish (so'nggi 7 kun) - daqiqalarda
  static Future<List<double>> getWeeklyUsage(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final dailyMinutes = doc.data()?['dailyMinutes'] as List<dynamic>? ?? [];
        final usage = <double>[];

        for (int i = 6; i >= 0; i--) {
          final date = _getDateKey(DateTime.now().subtract(Duration(days: i)));
          final dayMinutes = dailyMinutes
              .where((item) => item is Map && item['date'] == date)
              .fold<int>(0, (sum, item) => sum + (item['minutes'] as int? ?? 0));
          usage.add(dayMinutes.toDouble());
        }

        return usage;
      }
    } catch (e) {
      // Xatolarni ignore qilish
    }

    // Default: hozircha random data
    return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  }

  /// Weekly dates ni olish (so'nggi 7 kun)
  static Future<List<String>> getWeeklyDates() async {
    final dates = <String>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final day = date.day;
      final month = date.month;
      dates.add('$day.$month');
    }
    return dates;
  }

  /// Date key format: YYYY-MM-DD
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// User bugun faolmi
  static Future<bool> isUserActiveToday(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final lastActive = doc.data()?['lastActiveDate'] as String?;
        final today = _getDateKey(DateTime.now());
        return lastActive == today;
      }
    } catch (e) {
      // Xatolarni ignore qilish
    }
    return false;
  }

  /// Bugun birinchi marta kirganmi (streak animatsiyasi uchun)
  static Future<bool> isFirstLoginToday(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActive = prefs.getString(_lastActiveKey);
      final today = _getDateKey(DateTime.now());
      return lastActive != today;
    } catch (e) {
      // Xatolarni ignore qilish
    }
    return false;
  }

  /// Birinchi loginni belgilash
  static Future<void> markFirstLoginToday(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey(DateTime.now());
    await prefs.setString(_lastActiveKey, today);
  }
}
