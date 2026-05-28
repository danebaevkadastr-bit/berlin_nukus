import 'package:cloud_firestore/cloud_firestore.dart';

/// O'rtacha ball tizimi.
///
/// Ball formulasi (0–100):
///   - Davomat:          40% og'irlik  (attendedLessons / totalLessons * 100)
///   - Uyga vazifa:      35% og'irlik  (bajarilgan / jami * 100)
///   - O'rganish (horen, games, chat): 25% og'irlik
///
/// Natija: weighted average, 0–100 oralig'ida.
class ScoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Firestore keys ────────────────────────────────────────────────────────
  static const String _learningScoreKey = 'learningScore';      // 0–100
  static const String _learningCountKey = 'learningScoreCount'; // nechta o'lchov

  // ── Learning score (horen, games, chat) ──────────────────────────────────

  /// O'rganish natijasini qo'shish (masalan, horen to'g'ri javob).
  /// [score] — 0.0 dan 1.0 gacha (to'g'ri/jami nisbati).
  static Future<void> addLearningScore(String uid, double score) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      final prev = (data[_learningScoreKey] as num?)?.toDouble() ?? 0.0;
      final count = (data[_learningCountKey] as int?) ?? 0;

      // Running average
      final newCount = count + 1;
      final newAvg = (prev * count + score * 100) / newCount;

      await _firestore.collection('users').doc(uid).set({
        _learningScoreKey: newAvg,
        _learningCountKey: newCount,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // ── Composite score hisoblash ─────────────────────────────────────────────

  /// Barcha guruhlar bo'yicha composite ball hisoblash.
  /// [groups] — FirebaseService().getStudentGroupsStream dan kelgan ma'lumot.
  static Future<double?> computeScore(
    String uid,
    List<Map<String, dynamic>> groups,
  ) async {
    if (groups.isEmpty) return null;

    // 1. Davomat
    int totalLessons = 0;
    int attendedLessons = 0;

    // 2. Uyga vazifa
    int totalHomeworks = 0;
    int doneHomeworks = 0;

    for (final data in groups) {
      final lessonsMap = data['lessons'] as Map<String, dynamic>? ?? {};
      for (final lessonEntry in lessonsMap.entries) {
        final lesson = lessonEntry.value as Map<String, dynamic>;

        // Davomat
        final attendance = lesson['attendance'] as Map<String, dynamic>? ?? {};
        if (attendance.containsKey(uid)) {
          totalLessons++;
          if (attendance[uid] == true) attendedLessons++;
        }

        // Uyga vazifa
        final homeworks = List<dynamic>.from(lesson['homeworks'] ?? []);
        if (homeworks.isNotEmpty) {
          totalHomeworks++;
          final subs = lesson['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
          final mySub = subs[uid] as Map<String, dynamic>?;
          if (mySub != null && mySub['submitted'] == true) {
            doneHomeworks++;
          }
        }
      }
    }

    // 3. O'rganish bali (Firestore dan)
    double learningScore = 0.0;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      learningScore = (doc.data()?[_learningScoreKey] as num?)?.toDouble() ?? 0.0;
    } catch (_) {}

    // Weighted average
    final attendanceScore = totalLessons > 0
        ? (attendedLessons / totalLessons * 100)
        : null;
    final homeworkScore = totalHomeworks > 0
        ? (doneHomeworks / totalHomeworks * 100)
        : null;

    // Faqat mavjud komponentlarni hisoblaymiz
    double total = 0;
    double weight = 0;

    if (attendanceScore != null) {
      total += attendanceScore * 0.40;
      weight += 0.40;
    }
    if (homeworkScore != null) {
      total += homeworkScore * 0.35;
      weight += 0.35;
    }
    if (learningScore > 0) {
      total += learningScore * 0.25;
      weight += 0.25;
    }

    if (weight == 0) return null;
    return total / weight;
  }

  /// Composite ballni Firestore ga saqlash (leaderboard uchun).
  static Future<void> syncScoreToFirestore(
    String uid,
    List<Map<String, dynamic>> groups,
  ) async {
    final score = await computeScore(uid, groups);
    if (score == null) return;
    try {
      await _firestore.collection('users').doc(uid).set({
        'averageScore': score.round(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
