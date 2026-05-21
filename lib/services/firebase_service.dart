import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  /// Returns null on success, or an error message string.
  Future<String?> addStudentToGroup(String groupId, String studentId) async {
    // Check if the student is already in ANY group
    final existingGroups = await _firestore
        .collection('groups')
        .where('students', arrayContains: studentId)
        .limit(1)
        .get();
    if (existingGroups.docs.isNotEmpty) {
      final existingGroupName = existingGroups.docs.first.data()['name'] ?? 'Boshqa guruh';
      return 'Bu talaba allaqachon "$existingGroupName" guruhida o\'qiydi!';
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

  /// Stream of all courses
  Stream<List<Map<String, dynamic>>> getCoursesStream() {
    return _firestore.collection('courses').orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList(),
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

  /// Stream of all groups a student is enrolled in
  Stream<List<Map<String, dynamic>>> getStudentGroupsStream(String studentId) {
    return _firestore
        .collection('groups')
        .where('students', arrayContains: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
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

  // ── SEED INITIAL DATA ──────────────────────────────────────────────────────

  /// Check if the `/users` collection is empty and seed default mock users, courses, groups, and payments
  Future<void> seedInitialData() async {
    try {
      final snapshot = await _firestore.collection('users').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        // Database already seeded or populated
        return;
      }

      debugPrint('FirebaseSeeder: Seeding initial mock data into Cloud Firestore...');

      final WriteBatch batch = _firestore.batch();

      // Seed Student 1
      final s1 = _firestore.collection('users').doc('mock_student_1');
      batch.set(s1, {
        'uid': 'mock_student_1',
        'fullName': 'Ali Valiyev',
        'email': 'ali@gmail.com',
        'phone': '+998901234567',
        'role': 'student',
        'createdAt': Timestamp.now(),
      });

      // Seed Student 2
      final s2 = _firestore.collection('users').doc('mock_student_2');
      batch.set(s2, {
        'uid': 'mock_student_2',
        'fullName': 'Aziza Karimova',
        'email': 'aziza@gmail.com',
        'phone': '+998901234568',
        'role': 'student',
        'createdAt': Timestamp.now(),
      });

      // Seed Student 3
      final s3 = _firestore.collection('users').doc('mock_student_3');
      batch.set(s3, {
        'uid': 'mock_student_3',
        'fullName': 'Botir Qodirov',
        'email': 'botir@gmail.com',
        'phone': '+998901234569',
        'role': 'student',
        'createdAt': Timestamp.now(),
      });

      // Seed Teacher 1
      final t1 = _firestore.collection('users').doc('mock_teacher_1');
      batch.set(t1, {
        'uid': 'mock_teacher_1',
        'fullName': 'Rustam Ubaydullayev',
        'email': 'rustam@gmail.com',
        'phone': '+998901112233',
        'role': 'teacher',
        'createdAt': Timestamp.now(),
      });

      // Seed Teacher 2
      final t2 = _firestore.collection('users').doc('mock_teacher_2');
      batch.set(t2, {
        'uid': 'mock_teacher_2',
        'fullName': 'Dilnoza Ismoilova',
        'email': 'dilnoza@gmail.com',
        'phone': '+998901112234',
        'role': 'teacher',
        'createdAt': Timestamp.now(),
      });

      // Seed pre-existing login mock accounts in Firestore so profiles exist when autogenerated
      final adminDoc = _firestore.collection('users').doc('mock_admin_musa');
      batch.set(adminDoc, {
        'uid': 'mock_admin_musa',
        'fullName': 'Admin (Musa)',
        'email': 'admin@mail.com',
        'phone': '+998991112233',
        'role': 'admin',
        'createdAt': Timestamp.now(),
      });

      final teacherDoc = _firestore.collection('users').doc('mock_teacher_mail');
      batch.set(teacherDoc, {
        'uid': 'mock_teacher_mail',
        'fullName': 'O\'qituvchi (Teacher)',
        'email': 'teacher@mail.com',
        'phone': '+998991112244',
        'role': 'teacher',
        'createdAt': Timestamp.now(),
      });

      final studentDoc = _firestore.collection('users').doc('mock_student_mail');
      batch.set(studentDoc, {
        'uid': 'mock_student_mail',
        'fullName': 'Talaba (Student)',
        'email': 'student@mail.com',
        'phone': '+998991112255',
        'role': 'student',
        'createdAt': Timestamp.now(),
      });

      // Seed 4 mock courses
      final coursesList = [
        {'id': 'c1', 'title': 'German A1', 'desc': 'Nemis tili boshlang\'ich darajasi'},
        {'id': 'c2', 'title': 'German A2', 'desc': 'Nemis tili o\'rta boshlang\'ich darajasi'},
        {'id': 'c3', 'title': 'German B1', 'desc': 'Nemis tili o\'rta darajasi'},
        {'id': 'c4', 'title': 'German B2', 'desc': 'Nemis tili yuqori o\'rta darajasi'},
      ];
      for (final course in coursesList) {
        batch.set(_firestore.collection('courses').doc(course['id']), {
          'id': course['id'],
          'title': course['title'],
          'description': course['desc'],
          'createdAt': Timestamp.now(),
        });
      }

      // Seed 3 mock groups
      final groupsList = [
        {'id': 'g1', 'name': 'A1 Boshlang\'ich Guruh', 'courseId': 'c1', 'courseTitle': 'German A1', 'teacherId': 'mock_teacher_1', 'teacherName': 'Rustam Ubaydullayev'},
        {'id': 'g2', 'name': 'A2 Davomchilar Guruh', 'courseId': 'c2', 'courseTitle': 'German A2', 'teacherId': 'mock_teacher_2', 'teacherName': 'Dilnoza Ismoilova'},
        {'id': 'g3', 'name': 'B1 Mustaqil Guruh', 'courseId': 'c3', 'courseTitle': 'German B1', 'teacherId': 'mock_teacher_1', 'teacherName': 'Rustam Ubaydullayev'},
      ];
      for (final group in groupsList) {
        batch.set(_firestore.collection('groups').doc(group['id']), {
          'id': group['id'],
          'name': group['name'],
          'courseId': group['courseId'],
          'courseTitle': group['courseTitle'],
          'teacherId': group['teacherId'],
          'teacherName': group['teacherName'],
          'createdAt': Timestamp.now(),
        });
      }

      // Seed 2 mock payments
      batch.set(_firestore.collection('payments').doc('p1'), {
        'id': 'p1',
        'studentId': 'mock_student_1',
        'studentName': 'Ali Valiyev',
        'course': 'German A1',
        'amount': '500 000 so\'m',
        'date': '01.03.2026',
        'status': 'paid',
        'createdAt': Timestamp.now(),
      });
      batch.set(_firestore.collection('payments').doc('p2'), {
        'id': 'p2',
        'studentId': 'mock_student_2',
        'studentName': 'Aziza Karimova',
        'course': 'German A2',
        'amount': '600 000 so\'m',
        'date': '01.04.2026',
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      await batch.commit();
      debugPrint('FirebaseSeeder: Seeding completed successfully!');
    } catch (e) {
      debugPrint('FirebaseSeederError: Failed to seed database: $e');
    }
  }
}
