import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import 'teacher_course_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class TeacherCoursesScreen extends StatelessWidget {
  const TeacherCoursesScreen({super.key});

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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 110),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final doc = groups[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? l.noData;
              final courseTitle = data['courseTitle'] ?? l.noData;
              final started = data['started'] ?? l.noData;

              // Alternating colors for groups
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
                padding: const EdgeInsets.only(bottom: 16),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(20),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherCourseDetailScreen(
                          groupId: doc.id,
                          groupName: name,
                          courseTitle: courseTitle,
                          startDate: started,
                          color: colors[cIndex],
                          shadowColor: shadows[cIndex],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              color: colors[cIndex].withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text('👥', style: TextStyle(fontSize: 30)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppColors.duoTextDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  courseTitle,
                                  style: TextStyle(
                                    fontSize: 13,
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _buildInfoChip(
                            emoji: '🧑‍🎓',
                            label: l.totalStudents,
                            value: '${(data['students'] as List?)?.length ?? 0}',
                            color: colors[cIndex],
                            isDark: isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            emoji: '📅',
                            label: l.started,
                            value: started,
                            color: colors[cIndex],
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoChip({
    required String emoji,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}