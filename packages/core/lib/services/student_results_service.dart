import 'package:cloud_firestore/cloud_firestore.dart';

/// Talaba test natijalarini Firebase'ga saqlash va o'qish.
/// Collection: users/{uid}/results/{auto-id}
///
/// Har natija: {type, title, level, score, total, percentage, date, details?}
class StudentResultsService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference _resultsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('results');

  /// Yangi natija saqlash.
  static Future<void> saveResult({
    required String uid,
    required String type, // 'lesen' | 'horen' | 'mock_test'
    required String title,
    String level = '',
    required int score,
    required int total,
    Map<String, dynamic>? details,
  }) async {
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    await _resultsRef(uid).add({
      'type': type,
      'title': title,
      'level': level,
      'score': score,
      'total': total,
      'percentage': percentage,
      'date': FieldValue.serverTimestamp(),
      if (details != null) 'details': details,
    });
  }

  /// Ovozli AI foydalanishini saqlash.
  static Future<void> saveVoiceAiUsage({
    required String uid,
    String mode = 'telc',
  }) async {
    await _resultsRef(uid).add({
      'type': 'voice_ai',
      'title': 'Ovozli AI muloqot',
      'level': mode,
      'score': 1,
      'total': 1,
      'percentage': 100,
      'date': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('users').doc(uid).set({
      'lastVoiceAiDate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Talabaning barcha natijalarini turlar bo'yicha olish.
  static Future<List<Map<String, dynamic>>> getResults(
    String uid, {
    String? type,
  }) async {
    Query query = _resultsRef(uid);
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    final snap = await query.limit(50).get();
    final results = snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['id'] = d.id;
      return data;
    }).toList();
    // Client-side sort (Firestore composite index kerak bo'lmasligi uchun)
    results.sort((a, b) {
      final aDate = a['date'];
      final bDate = b['date'];
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return (bDate as Timestamp).compareTo(aDate as Timestamp);
    });
    return results;
  }

  /// Stream (real-time) — teacher ekranida ishlatish uchun.
  static Stream<List<Map<String, dynamic>>> resultsStream(
    String uid, {
    String? type,
  }) {
    Query query = _resultsRef(uid);
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    return query.limit(50).snapshots().map((snap) {
      final results = snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        data['id'] = d.id;
        return data;
      }).toList();
      results.sort((a, b) {
        final aDate = a['date'];
        final bDate = b['date'];
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return (bDate as Timestamp).compareTo(aDate as Timestamp);
      });
      return results;
    });
  }
}
