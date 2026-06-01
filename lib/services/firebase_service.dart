import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'darslar_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── USER OPERATIONS ────────────────────────────────────────────────────────

  /// Stream of all users who have the role of 'student'
  Stream<List<Map<String, dynamic>>> getStudentsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              // Convert Timestamp to DateTime if present
              if (data['createdAt'] is Timestamp) {
                data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
              }
              return data;
            }).toList());
  }

  /// Stream of all users who have the role of 'teacher'
  Stream<List<Map<String, dynamic>>> getTeachersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              // Convert Timestamp to DateTime if present
              if (data['createdAt'] is Timestamp) {
                data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
              }
              return data;
            }).toList());
  }

  /// Add a student directly to Firestore
  Future<void> addStudent({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    // Generate a new document reference
    final docRef = _firestore.collection('users').doc();
    await docRef.set({
      'uid': docRef.id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add a teacher directly to Firestore
  Future<void> addTeacher({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final docRef = _firestore.collection('users').doc();
    await docRef.set({
      'uid': docRef.id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': 'teacher',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a user document from Firestore
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Fetch user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Update user profile data (fullName, phone, avatarUrl)
  Future<void> updateUserProfile(String uid, {
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['fullName'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (updates.isEmpty) return;
    await _firestore.collection('users').doc(uid).update(updates);
  }

  /// Add a student to a group. Ensures the student is not already in another group.
  /// Returns null on success, or the existing group name if student is already in another group.
  Future<String?> addStudentToGroup(String groupId, String studentId) async {
    // Check if the student is already in ANY group
    final existingGroups = await _firestore
        .collection('groups')
        .where('students', arrayContains: studentId)
        .limit(1)
        .get();
    if (existingGroups.docs.isNotEmpty) {
      return existingGroups.docs.first.data()['name'] as String?;
    }
    await _firestore.collection('groups').doc(groupId).update({
      'students': FieldValue.arrayUnion([studentId]),
    });
    return null;
  }

  /// Remove a student from a group
  Future<void> removeStudentFromGroup(String groupId, String studentId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'students': FieldValue.arrayRemove([studentId]),
    });
  }

  // ── COURSES AND GROUPS ─────────────────────────────────────────────────────

  /// Stream of all courses with real group and student counts
  Stream<List<Map<String, dynamic>>> getCoursesStream() {
    return _firestore.collection('courses').orderBy('createdAt', descending: true).snapshots().asyncMap(
      (snapshot) async {
        final courses = <Map<String, dynamic>>[];
        
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          final courseId = doc.id;
          
          // Guruhlar sonini hisoblash
          final groupsSnapshot = await _firestore
              .collection('groups')
              .where('courseId', isEqualTo: courseId)
              .get();
          final groupsCount = groupsSnapshot.docs.length;
          
          // Studentlar sonini hisoblash (barcha guruhlardagi unique studentlar)
          final studentIds = <String>{};
          for (final groupDoc in groupsSnapshot.docs) {
            final students = groupDoc.data()['students'] as List<dynamic>? ?? [];
            for (final student in students) {
              if (student is String) {
                studentIds.add(student);
              }
            }
          }
          
          data['groups'] = groupsCount;
          data['students'] = studentIds.length;
          
          courses.add(data);
        }
        
        return courses;
      },
    );
  }

  /// Add a new course
  Future<void> addCourse({
    required String title,
    required String type,
  }) async {
    final docRef = _firestore.collection('courses').doc();
    await docRef.set({
      'id': docRef.id,
      'title': title,
      'type': type,
      'groups': 0,
      'students': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream of groups for a specific course
  Stream<List<Map<String, dynamic>>> getGroupsStream(String courseId) {
    return _firestore
        .collection('groups')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Stream of all groups a student is enrolled in (darslar bilan birga)
  Stream<List<Map<String, dynamic>>> getStudentGroupsStream(String studentId) {
    return DarslarService().getStudentGroupsWithLessonsStream(studentId);
  }

  /// Add a new group
  Future<void> addGroup({
    required String courseId,
    required String courseTitle,
    required String name,
    required String duration,
    required String startDate,
    required int color,
  }) async {
    final docRef = _firestore.collection('groups').doc();
    await docRef.set({
      'id': docRef.id,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'name': name,
      'duration': duration,
      'started': startDate,
      'color': color,
      'students': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Optionally update course's groups count
    // await _firestore.collection('courses').doc(courseId).update({
    //   'groups': FieldValue.increment(1),
    // });
  }

  // ── MOCK DATA CLEANUP ──────────────────────────────────────────────────────

  static const _seedCourseIds = {'c1', 'c2', 'c3', 'c4'};
  static const _seedGroupIds = {'g1', 'g2', 'g3'};
  static const _seedPaymentIds = {'p1', 'p2'};

  static bool _isMockUserId(String? id) =>
      id != null && id.startsWith('mock_');

  /// Eski seed/mock ma'lumotlarni Firestore'dan olib tashlaydi.
  Future<void> removeMockData() async {
    try {
      var removed = 0;
      WriteBatch batch = _firestore.batch();
      var batchOps = 0;

      Future<void> flushBatch({bool force = false}) async {
        if (batchOps == 0) return;
        if (!force && batchOps < 450) return;
        await batch.commit();
        batch = _firestore.batch();
        batchOps = 0;
      }

      Future<void> queueDelete(DocumentReference ref) async {
        batch.delete(ref);
        batchOps++;
        removed++;
        await flushBatch();
      }

      Future<void> queueUpdate(
        DocumentReference ref,
        Map<String, dynamic> data,
      ) async {
        batch.update(ref, data);
        batchOps++;
        removed++;
        await flushBatch();
      }

      // ── Users (mock_*) ───────────────────────────────────────────────────
      final usersSnap = await _firestore.collection('users').get();
      for (final doc in usersSnap.docs) {
        if (_isMockUserId(doc.id)) {
          await queueDelete(doc.reference);
        }
      }

      // ── Courses (c1–c4) ──────────────────────────────────────────────────
      final coursesSnap = await _firestore.collection('courses').get();
      for (final doc in coursesSnap.docs) {
        if (_seedCourseIds.contains(doc.id)) {
          await queueDelete(doc.reference);
        }
      }

      // ── Groups (g1–g3 yoki seed kursga bog'langan) ───────────────────────
      final groupsSnap = await _firestore.collection('groups').get();
      final groupsToDelete = <String>{};

      for (final groupDoc in groupsSnap.docs) {
        final data = groupDoc.data();
        final groupId = groupDoc.id;
        final courseId = data['courseId'] as String?;

        if (_seedGroupIds.contains(groupId) ||
            _seedCourseIds.contains(courseId)) {
          groupsToDelete.add(groupId);
          await queueDelete(groupDoc.reference);
          continue;
        }

        var changed = false;
        final updates = <String, dynamic>{};

        final teacherId = data['teacherId'] as String?;
        if (_isMockUserId(teacherId)) {
          updates['teacherId'] = FieldValue.delete();
          updates['teacherName'] = FieldValue.delete();
          changed = true;
        }

        final students = data['students'];
        if (students is List) {
          final cleaned = students
              .where((s) => s is String && !_isMockUserId(s))
              .toList();
          if (cleaned.length != students.length) {
            updates['students'] = cleaned;
            changed = true;
          }
        }

        if (changed) {
          await queueUpdate(groupDoc.reference, updates);
        }
      }

      // ── Darslar (o'chirilgan guruhlar uchun) ─────────────────────────────
      final darslarSnap =
          await _firestore.collection(DarslarService.collection).get();
      for (final doc in darslarSnap.docs) {
        final data = doc.data();
        final groupId = data['groupId'] as String? ?? '';
        final prefixMatch = _seedGroupIds.any((g) => doc.id.startsWith('${g}_'));
        if (groupsToDelete.contains(groupId) ||
            _seedGroupIds.contains(groupId) ||
            prefixMatch) {
          await queueDelete(doc.reference);
        }
      }

      // ── Payments (p1, p2 yoki mock talaba) ───────────────────────────────
      final paymentsSnap = await _firestore.collection('payments').get();
      for (final doc in paymentsSnap.docs) {
        final data = doc.data();
        final studentId = data['studentId'] as String?;
        if (_seedPaymentIds.contains(doc.id) || _isMockUserId(studentId)) {
          await queueDelete(doc.reference);
        }
      }

      await flushBatch(force: true);

      if (removed > 0) {
        debugPrint('FirebaseCleanup: $removed ta mock yozuv o\'chirildi/yangilandi.');
      }
    } catch (e) {
      debugPrint('FirebaseCleanupError: $e');
    }
  }

  /// @deprecated Use [removeMockData] instead.
  Future<void> removeMockUsers() => removeMockData();

  // ── LEADERBOARD ─────────────────────────────────────────────────────────────

  /// Stream of leaderboard (top students by total stars)
  /// Sorts by totalStars (descending), then by fullName (alphabetically) for ties
  /// @deprecated Use getGroupLeaderboardStream instead for group-specific leaderboard
  /// _Requirements: 2.1, 2.3_
  Stream<List<Map<String, dynamic>>> getLeaderboardStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
          final students = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            // Null qiymatlar uchun 0 default
            data['totalStars'] = (data['totalStars'] as num?)?.toInt() ?? 0;
            return data;
          }).toList();

          // Sort by totalStars (descending), then by fullName (alphabetically) for ties
          students.sort((a, b) {
            final aStars = a['totalStars'] as int;
            final bStars = b['totalStars'] as int;

            final starsCompare = bStars.compareTo(aStars);
            if (starsCompare != 0) return starsCompare;

            // Secondary sort by fullName (alphabetically) for equal stars
            final aName = (a['fullName'] as String?) ?? '';
            final bName = (b['fullName'] as String?) ?? '';
            return aName.compareTo(bName);
          });

          // Limit to top 10
          return students.take(10).toList();
        });
  }

  /// Stream of leaderboard for a specific group (top students by total stars)
  Stream<List<Map<String, dynamic>>> getGroupLeaderboardStream(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().asyncMap((groupDoc) async {
      if (!groupDoc.exists) return [];

      final groupData = groupDoc.data();
      final studentIds = List<String>.from(groupData?['students'] ?? []);

      if (studentIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where(FieldPath.documentId, whereIn: studentIds)
          .orderBy('totalStars', descending: true)
          .limit(10)
          .get();

      return usersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Stream of leaderboard sorted by attendance percentage (descending)
  /// Calculates attendance from lessons data in 'darslar' collection
  /// Returns 0% for students with no attendance data
  Stream<List<Map<String, dynamic>>> getAttendanceLeaderboardStream() {
    // Combine students stream with lessons stream to calculate attendance
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .asyncMap((usersSnapshot) async {
      if (usersSnapshot.docs.isEmpty) return [];

      // Get all lessons to calculate attendance
      final lessonsSnapshot =
          await _firestore.collection(DarslarService.collection).get();

      // Build attendance map: studentId -> {attended: int, total: int}
      final attendanceStats = <String, Map<String, int>>{};

      for (final lessonDoc in lessonsSnapshot.docs) {
        final lessonData = lessonDoc.data();
        final attendance = lessonData['attendance'] as Map<String, dynamic>?;
        if (attendance == null || attendance.isEmpty) continue;

        for (final entry in attendance.entries) {
          final studentId = entry.key;
          final wasPresent = entry.value == true;

          attendanceStats.putIfAbsent(
              studentId, () => {'attended': 0, 'total': 0});
          attendanceStats[studentId]!['total'] =
              (attendanceStats[studentId]!['total'] ?? 0) + 1;
          if (wasPresent) {
            attendanceStats[studentId]!['attended'] =
                (attendanceStats[studentId]!['attended'] ?? 0) + 1;
          }
        }
      }

      // Map users with calculated attendance percentage
      final students = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Calculate attendance percentage
        final stats = attendanceStats[doc.id];
        if (stats != null && stats['total']! > 0) {
          data['attendancePercentage'] =
              (stats['attended']! / stats['total']!) * 100;
        } else {
          // Default to 0% if no attendance data
          data['attendancePercentage'] = 0.0;
        }

        return data;
      }).toList();

      // Sort by attendance percentage (descending), then by fullName (alphabetically) for ties
      students.sort((a, b) {
        final aPercentage = (a['attendancePercentage'] as num?) ?? 0.0;
        final bPercentage = (b['attendancePercentage'] as num?) ?? 0.0;

        final percentageCompare = bPercentage.compareTo(aPercentage);
        if (percentageCompare != 0) return percentageCompare;

        // Secondary sort by fullName (alphabetically) for equal percentages
        final aName = (a['fullName'] as String?) ?? '';
        final bName = (b['fullName'] as String?) ?? '';
        return aName.compareTo(bName);
      });

      return students;
    });
  }

  /// Stream of leaderboard sorted by average score (descending)
  /// O'quvchilarni averageScore bo'yicha kamayish tartibida tartiblaydi
  /// Teng qiymatlar uchun fullName bo'yicha alifbo tartibida tartiblaydi
  /// Null qiymatlar uchun 0 default qiymati ishlatiladi
  /// _Requirements: 4.1, 4.3, 4.4, 4.5_
  Stream<List<Map<String, dynamic>>> getAverageScoreLeaderboardStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
          final students = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            // Null qiymatlar uchun 0 default (Requirement 4.5)
            data['averageScore'] = (data['averageScore'] as num?)?.toInt() ?? 0;
            return data;
          }).toList();

          // averageScore bo'yicha kamayish tartibida tartiblash (Requirement 4.1)
          // Teng qiymatlar uchun fullName bo'yicha alifbo tartibida (Requirement 4.4)
          students.sort((a, b) {
            final scoreA = a['averageScore'] as int;
            final scoreB = b['averageScore'] as int;

            final scoreCompare = scoreB.compareTo(scoreA);
            if (scoreCompare != 0) return scoreCompare;

            // Secondary sort by fullName (alphabetically) for equal scores
            final aName = (a['fullName'] as String?) ?? '';
            final bName = (b['fullName'] as String?) ?? '';
            return aName.compareTo(bName);
          });

          return students;
        });
  }
}
