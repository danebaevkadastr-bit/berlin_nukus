import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import 'teacher_course_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String teacherId = currentUser?.uid ?? '';
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    if (teacherId.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            l.myGroups.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
              letterSpacing: 1.0,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            l.pleaseReLogin,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.duoTextDark,
                fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.myGroups.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('teacherId', isEqualTo: teacherId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: isDark ? Colors.white : AppColors.duoTextDark),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data?.docs ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👥', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    l.noGroupsAssigned,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      fontWeight: FontWeight.w600,
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
                return const Center(child: CircularProgressIndicator());
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
                  final shadows = [
                    AppColors.duoBlueShadow,
                    AppColors.duoGreenShadow,
                    AppColors.duoOrangeShadow,
                    AppColors.duoPurpleShadow,
                    AppColors.duoRedShadow,
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
                                    builder: (_) => TeacherCourseDetailScreen(
                                      groupId: groupDoc.id,
                                      groupName: groupName,
                                      courseTitle: courseTitle,
                                      startDate: '',
                                      color: colors[cIndex],
                                      shadowColor: shadows[cIndex],
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
                                      child: Text('👥', style: TextStyle(fontSize: 24)),
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
                                          '${students.length} talaba',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.notifications_outlined, color: colors[cIndex]),
                                    onPressed: () => _showNotificationDialog(context, groupDoc.id, groupName, students, isDark),
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
      final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
      if (doc.exists) {
        courseDetails[courseId] = doc.data() as Map<String, dynamic>;
      }
    }
    return courseDetails;
  }

  void _showNotificationDialog(BuildContext context, String groupId, String groupName, List? students, bool isDark) {
    final l = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A32) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.duoBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.notifications_outlined, color: AppColors.duoBlue, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.sendMessage,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.duoTextDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          groupName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GamifiedCard(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                child: TextField(
                  controller: titleController,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                  decoration: InputDecoration(
                    labelText: l.titleLabel,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GamifiedCard(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                child: TextField(
                  controller: bodyController,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                  decoration: InputDecoration(
                    labelText: l.messageBodyLabel,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GamifiedCard(
                      onTap: () => Navigator.pop(context),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                      child: Center(
                        child: Text(
                          l.cancel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : AppColors.duoTextDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GamifiedCard(
                      onTap: () async {
                        if (titleController.text.isEmpty || bodyController.text.isEmpty) return;

                        final studentIds = students?.cast<String>() ?? [];
                        for (final studentId in studentIds) {
                          final notification = AppNotification(
                            id: DateTime.now().millisecondsSinceEpoch.toString() + studentId,
                            title: titleController.text,
                            body: bodyController.text,
                            type: 'system',
                            createdAt: DateTime.now(),
                            userId: studentId,
                            groupId: groupId,
                            data: {'groupName': groupName},
                          );
                          await _notificationService.createNotification(notification);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.messageSent),
                              backgroundColor: AppColors.duoGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: AppColors.duoBlue,
                      shadowColor: AppColors.duoBlueShadow,
                      child: Center(
                        child: Text(
                          l.submit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}