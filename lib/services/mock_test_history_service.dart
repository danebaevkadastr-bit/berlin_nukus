import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/student/mock_test/model/mock_test_scorer.dart';

/// Mock test natijalarini Firestore'da saqlash va o'qish.
/// Collection: users/{uid}/mock_test_history
class MockTestHistoryService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference _historyRef(String uid) =>
      _db.collection('users').doc(uid).collection('mock_test_history');

  /// Natijani saqlash.
  static Future<void> save(MockResult result) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final sectionMap = <String, int>{};
    for (final entry in result.sectionPoints.entries) {
      sectionMap[entry.key.name] = entry.value;
    }

    await _historyRef(uid).add({
      'date': FieldValue.serverTimestamp(),
      'writtenPoints': result.writtenPoints,
      'writtenMax': result.writtenMax,
      'oralPoints': result.oralPoints,
      'oralMax': result.oralMax,
      'writtenPassed': result.writtenPassed,
      'oralPassed': result.oralPassed,
      'totalPoints': result.writtenPoints + result.oralPoints,
      'totalMax': result.writtenMax + result.oralMax,
      'sectionPoints': sectionMap,
      'unavailableSections':
          result.unavailableSections.map((s) => s.name).toList(),
    });
  }

  /// Barcha natijalarni olish (yangi → eski).
  static Future<List<Map<String, dynamic>>> getAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _historyRef(uid).limit(50).get();
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
  }

  /// Real-time stream.
  static Stream<List<Map<String, dynamic>>> stream({String? uid}) {
    final userId = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Stream.empty();
    return _historyRef(userId).limit(50).snapshots().map((snap) {
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
