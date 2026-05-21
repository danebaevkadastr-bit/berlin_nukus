import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Darslar alohida `darslar` collectionda saqlanadi.
/// Har bir hujjat ID: `{groupId}_{dateKey}` (masalan: `abc123_2026-05-21`)
class DarslarService {
  static final DarslarService _instance = DarslarService._internal();
  factory DarslarService() => _instance;
  DarslarService._internal();

  static const String collection = 'darslar';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String docId(String groupId, String dateKey) => '${groupId}_$dateKey';

  DocumentReference<Map<String, dynamic>> lessonRef(String groupId, String dateKey) {
    return _firestore.collection(collection).doc(docId(groupId, dateKey));
  }

  Map<String, dynamic> _lessonsQueryToMap(QuerySnapshot<Map<String, dynamic>> snap) {
    final map = <String, dynamic>{};
    for (final doc in snap.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      final dateKey = data['dateKey'] as String? ?? '';
      if (dateKey.isEmpty) continue;
      data.remove('groupId');
      data.remove('dateKey');
      map[dateKey] = data;
    }
    return map;
  }

  void _attachLessons(Map<String, dynamic> groupData, Map<String, dynamic> lessonsMap) {
    groupData['lessons'] = lessonsMap;
  }

  /// Guruh hujjati + uning barcha darslari (UI uchun `lessons` map sifatida).
  Stream<Map<String, dynamic>> getGroupWithLessonsStream(String groupId) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    DocumentSnapshot<Map<String, dynamic>>? lastGroup;
    QuerySnapshot<Map<String, dynamic>>? lastLessons;

    void emit() {
      if (lastGroup == null || !lastGroup!.exists) {
        controller.add({'lessons': <String, dynamic>{}});
        return;
      }
      final data = Map<String, dynamic>.from(lastGroup!.data() ?? {});
      final lessonsMap = lastLessons != null
          ? _lessonsQueryToMap(lastLessons!)
          : <String, dynamic>{};
      _attachLessons(data, lessonsMap);
      controller.add(data);
    }

    final groupSub = _firestore.collection('groups').doc(groupId).snapshots().listen((snap) {
      lastGroup = snap;
      emit();
    });

    final lessonsSub = _firestore
        .collection(collection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .listen((snap) {
      lastLessons = snap;
      emit();
    });

    controller.onCancel = () {
      groupSub.cancel();
      lessonsSub.cancel();
    };

    return controller.stream;
  }

  /// Bir nechta guruhlar uchun darslarni `lessons` map ichiga qo'shib qaytaradi.
  Future<List<Map<String, dynamic>>> mergeLessonsIntoGroups(
    List<QueryDocumentSnapshot> groupDocs,
  ) async {
    if (groupDocs.isEmpty) return [];

    final groupIds = groupDocs.map((d) => d.id).toList();
    final lessonsByGroup = <String, Map<String, dynamic>>{};

    for (var i = 0; i < groupIds.length; i += 10) {
      final chunk = groupIds.sublist(i, i + 10 > groupIds.length ? groupIds.length : i + 10);
      final snap = await _firestore
          .collection(collection)
          .where('groupId', whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final gid = data['groupId'] as String? ?? '';
        final dateKey = data['dateKey'] as String? ?? '';
        if (gid.isEmpty || dateKey.isEmpty) continue;
        lessonsByGroup.putIfAbsent(gid, () => {});
        final lesson = Map<String, dynamic>.from(data);
        lesson.remove('groupId');
        lesson.remove('dateKey');
        lessonsByGroup[gid]![dateKey] = lesson;
      }
    }

    return groupDocs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      data['id'] = doc.id;
      _attachLessons(data, lessonsByGroup[doc.id] ?? {});
      return data;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> _groupsWithLessonsStream(
    Stream<QuerySnapshot> groupsStream,
  ) {
    return groupsStream.asyncMap((groupsSnap) async {
      return mergeLessonsIntoGroups(groupsSnap.docs);
    });
  }

  Stream<List<Map<String, dynamic>>> getStudentGroupsWithLessonsStream(String studentId) {
    return _groupsWithLessonsStream(
      _firestore
          .collection('groups')
          .where('students', arrayContains: studentId)
          .snapshots(),
    );
  }

  Stream<List<Map<String, dynamic>>> getTeacherGroupsWithLessonsStream(String teacherId) {
    return _groupsWithLessonsStream(
      _firestore
          .collection('groups')
          .where('teacherId', isEqualTo: teacherId)
          .snapshots(),
    );
  }

  Future<void> createLesson({
    required String groupId,
    required String dateKey,
    required String lessonType,
    required String room,
    required String time,
  }) async {
    await lessonRef(groupId, dateKey).set({
      'groupId': groupId,
      'dateKey': dateKey,
      'lessonType': lessonType,
      'room': room,
      'time': time,
      'done': false,
      'materials': <dynamic>[],
      'homeworks': <dynamic>[],
      'homeworkSubmissions': <String, dynamic>{},
      'attendance': <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLesson({
    required String groupId,
    required String dateKey,
    required String lessonType,
    required String room,
    required String time,
  }) async {
    await lessonRef(groupId, dateKey).set({
      'groupId': groupId,
      'dateKey': dateKey,
      'lessonType': lessonType,
      'room': room,
      'time': time,
    }, SetOptions(merge: true));
  }

  Future<void> deleteLesson(String groupId, String dateKey) async {
    await lessonRef(groupId, dateKey).delete();
  }

  Future<void> setMaterials(String groupId, String dateKey, List<dynamic> materials) async {
    await lessonRef(groupId, dateKey).set({'materials': materials}, SetOptions(merge: true));
  }

  Future<void> addMaterial(String groupId, String dateKey, Map<String, dynamic> material) async {
    await lessonRef(groupId, dateKey).set({
      'groupId': groupId,
      'dateKey': dateKey,
      'materials': FieldValue.arrayUnion([material]),
    }, SetOptions(merge: true));
  }

  Future<void> setHomeworks(String groupId, String dateKey, List<dynamic> homeworks) async {
    await lessonRef(groupId, dateKey).set({'homeworks': homeworks}, SetOptions(merge: true));
  }

  Future<void> setAttendance(
    String groupId,
    String dateKey,
    Map<String, bool> attendance,
  ) async {
    await lessonRef(groupId, dateKey).set({'attendance': attendance}, SetOptions(merge: true));
  }

  Future<void> setHomeworkSubmission({
    required String groupId,
    required String dateKey,
    required String studentId,
    required Map<String, dynamic> submission,
  }) async {
    await lessonRef(groupId, dateKey).set({
      'groupId': groupId,
      'dateKey': dateKey,
      'homeworkSubmissions.$studentId': submission,
    }, SetOptions(merge: true));
  }

  Future<void> markHomeworkChecked(String groupId, String dateKey, String studentId) async {
    await lessonRef(groupId, dateKey).update({
      'homeworkSubmissions.$studentId.checked': true,
    });
  }

  /// Agar `darslar` bo'sh va `groups`da eski `lessons` bo'lsa, ko'chiradi.
  Future<void> migrateLessonsIfNeeded() async {
    final existing = await _firestore.collection(collection).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final groupsSnap = await _firestore.collection('groups').get();
    final hasLegacyLessons = groupsSnap.docs.any((doc) {
      final lessons = doc.data()['lessons'];
      return lessons is Map && lessons.isNotEmpty;
    });
    if (!hasLegacyLessons) return;

    await migrateLessonsFromGroups();
  }

  /// Mavjud `groups.lessons` mapini `darslar` collectionga ko'chiradi (bir martalik).
  Future<int> migrateLessonsFromGroups() async {
    final groupsSnap = await _firestore.collection('groups').get();
    var migrated = 0;
    WriteBatch batch = _firestore.batch();
    var batchCount = 0;

    Future<void> commitIfNeeded({bool force = false}) async {
      if (batchCount > 0 && (force || batchCount >= 400)) {
        await batch.commit();
        batch = _firestore.batch();
        batchCount = 0;
      }
    }

    for (final groupDoc in groupsSnap.docs) {
      final data = groupDoc.data();
      final lessonsMap = data['lessons'] as Map<String, dynamic>?;
      if (lessonsMap == null || lessonsMap.isEmpty) continue;

      for (final entry in lessonsMap.entries) {
        final dateKey = entry.key;
        final lessonData = Map<String, dynamic>.from(entry.value as Map);
        batch.set(lessonRef(groupDoc.id, dateKey), {
          'groupId': groupDoc.id,
          'dateKey': dateKey,
          ...lessonData,
        }, SetOptions(merge: true));
        migrated++;
        batchCount++;
        await commitIfNeeded();
      }

      batch.update(groupDoc.reference, {'lessons': FieldValue.delete()});
      batchCount++;
      await commitIfNeeded();
    }

    await commitIfNeeded(force: true);
    debugPrint('DarslarService: $migrated ta dars ko\'chirildi.');
    return migrated;
  }
}
