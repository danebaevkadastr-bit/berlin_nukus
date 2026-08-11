import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'teacher_individual_chat_screen.dart';
import 'package:core/l10n/app_localizations.dart';

class TeacherChatScreen extends StatefulWidget {
  const TeacherChatScreen({super.key});

  @override
  State<TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('groups')
            .where('teacherId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.duoBlue));
          }

          final groups = snapshot.data?.docs ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💬', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    l.noGroupsTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.noGroupsAssigned,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group groups by courseId
          final Map<String, List<QueryDocumentSnapshot>> groupedByCourse = {};
          for (final doc in groups) {
            final data = doc.data() as Map<String, dynamic>;
            final courseId = data['courseId'] as String?;
            if (courseId != null) {
              groupedByCourse.putIfAbsent(courseId, () => []).add(doc);
            }
          }

          // Get course details for each courseId
          return FutureBuilder<Map<String, Map<String, dynamic>>>(
            future: _fetchCourseDetails(groupedByCourse.keys.toList()),
            builder: (context, courseSnapshot) {
              if (courseSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.duoBlue));
              }

              final courseDetails = courseSnapshot.data ?? {};

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 110),
                itemCount: groupedByCourse.length,
                itemBuilder: (context, index) {
                  final courseId = groupedByCourse.keys.elementAt(index);
                  final courseGroups = groupedByCourse[courseId]!;
                  final courseData = courseDetails[courseId] ?? {};
                  final courseTitle = courseData['title'] ?? l.noData;
                  final courseType = courseData['type'] ?? l.noData;

                  // Alternating colors for courses
                  final colors = [
                    AppColors.duoBlue,
                    AppColors.duoGreen,
                    AppColors.duoOrange,
                    AppColors.duoPurple,
                    AppColors.duoRed,
                  ];
                  
                  final cIndex = index % colors.length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course header
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 12),
                          child: Text(
                            courseTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: colors[cIndex],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Course type badge
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors[cIndex].withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              courseType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors[cIndex],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        // Groups in this course
                        ...courseGroups.map((groupDoc) {
                          final groupData = groupDoc.data() as Map<String, dynamic>;
                          final groupName = groupData['name'] ?? l.noData;
                          final students = groupData['students'] as List? ?? [];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GamifiedCard(
                              padding: const EdgeInsets.all(16),
                              color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                              shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TeacherIndividualChatScreen(
                                      groupId: groupDoc.id,
                                      groupName: groupName,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: colors[cIndex].withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: Text('💬', style: TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          groupName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : AppColors.duoTextDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l.studentsCount(students.length),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.duoTextLight),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, Map<String, dynamic>>> _fetchCourseDetails(List<String> courseIds) async {
    final Map<String, Map<String, dynamic>> courseDetails = {};
    for (final courseId in courseIds) {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      if (doc.exists) {
        courseDetails[courseId] = doc.data() as Map<String, dynamic>;
      }
    }
    return courseDetails;
  }
}
