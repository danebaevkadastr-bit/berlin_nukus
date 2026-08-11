import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core/providers/user_provider.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/l10n/app_localizations.dart';
import 'package:core/services/darslar_service.dart';
import 'package:core/services/notification_service.dart';
import 'teacher_course_detail_screen.dart';
import '../notification_screen.dart';
import 'package:core/widgets/user_avatar.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DarslarService().getTeacherGroupsWithLessonsStream(userProvider.uid),
        builder: (context, snapshot) {
          int totalGroups = 0;
          int totalStudents = 0;
          List<_TodayLesson> todayLessons = [];
          List<_PendingWork> pendingWorks = [];

          if (snapshot.hasData) {
            final groups = snapshot.data!;
            totalGroups = groups.length;

            final todayKey = _formatDateKey(DateTime.now());

            for (final data in groups) {
              final groupId = data['id'] as String? ?? '';
              final studentsList = List<String>.from(data['students'] ?? []);
              totalStudents += studentsList.length;

              final lessonsMap = data['lessons'] as Map<String, dynamic>? ?? {};
              
              // Today's lessons
              if (lessonsMap.containsKey(todayKey)) {
                final lData = lessonsMap[todayKey] as Map<String, dynamic>;
                todayLessons.add(_TodayLesson(
                  groupId: groupId,
                  groupName: data['name'] ?? '',
                  courseTitle: data['courseTitle'] ?? '',
                  startDate: data['started'] ?? '',
                  time: lData['time'] ?? '14:00',
                  room: lData['room'],
                  studentsCount: studentsList.length,
                  lessonType: lData['lessonType'] ?? 'Dars',
                ));
              }

              // Pending Works
              lessonsMap.forEach((date, lDataMap) {
                final lData = lDataMap as Map<String, dynamic>;
                final submissions = lData['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
                
                int pendingCount = 0;
                int totalSubs = submissions.length;
                
                submissions.forEach((uid, subDataMap) {
                  final subData = subDataMap as Map<String, dynamic>;
                  if (subData['submitted'] == true && subData['checked'] != true) {
                    pendingCount++;
                  }
                });

                if (pendingCount > 0) {
                  final homeworks = List<dynamic>.from(lData['homeworks'] ?? []);
                  String hwTitle = '${l.homeworkDefault} ($date)';
                  if (homeworks.isNotEmpty && (homeworks.first as Map)['title'] != null) {
                    hwTitle = (homeworks.first as Map)['title'];
                  }
                  
                  pendingWorks.add(_PendingWork(
                    groupId: groupId,
                    groupName: data['name'] ?? '',
                    courseTitle: data['courseTitle'] ?? '',
                    startDate: data['started'] ?? '',
                    title: hwTitle,
                    submissions: totalSubs,
                    totalStudents: studentsList.length,
                    type: lData['lessonType'] ?? 'Vazifa',
                  ));
                }
              });
            }
          }

          return Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 3D avatar
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppColors.duoPurple,
                            border: Border.all(
                                color: AppColors.duoPurpleShadow, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.duoPurpleShadow,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: UserAvatar(
                            imageUrl: userProvider.avatarUrl,
                            size: 48,
                            borderRadius: 16,
                            fallbackEmoji: '👨‍🏫',
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${l.hello}, ${userProvider.name}!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        isDark ? Colors.white : AppColors.duoTextDark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 20),
                              ],
                            ),
                            Text(
                              'Berlin Nukus',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.duoTextLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification bell
                    GamifiedCard(
                      padding: const EdgeInsets.all(10),
                      borderRadius: 16,
                      color: isDark
                          ? AppColors.duoCardGray.withValues(alpha: 0.1)
                          : Colors.white,
                      shadowColor:
                          isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                      shadowDepth: 4,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Icon(Icons.notifications_rounded,
                              color:
                                  isDark ? Colors.white : AppColors.duoTextDark,
                              size: 28),
                          StreamBuilder<int>(
                            stream: NotificationService().getUnreadCount(userProvider.uid),
                            builder: (context, snapshot) {
                              final unreadCount = snapshot.data ?? 0;
                              if (unreadCount == 0) return const SizedBox.shrink();
                              return Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.duoRed,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Scrollable content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // ── Stat cards row ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard('$totalGroups', Icons.groups_rounded, l.navGroup,
                                AppColors.duoBlue, AppColors.duoBlueShadow),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard("$totalStudents", Icons.school_rounded, l.studentsShort,
                                AppColors.duoGreen, AppColors.duoGreenShadow),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                                '${todayLessons.length}',
                                Icons.menu_book_rounded,
                                l.lessonsShort,
                                AppColors.duoOrange,
                                AppColors.duoOrangeShadow),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Today's lessons section ──
                      _buildTodayLessonsSection(todayLessons, isDark, l),

                      const SizedBox(height: 24),

                      // ── Pending work section ──
                      _buildPendingWorkSection(pendingWorks, isDark, l),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  // ── Stat card (colored 3D) ──
  Widget _buildStatCard(
      String value, IconData iconData, String label, Color color, Color shadow) {
    return GamifiedCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: color,
      shadowColor: shadow,
      shadowDepth: 5,
      borderRadius: 16,
      child: Column(
        children: [
          Icon(iconData, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Today lessons section ──
  Widget _buildTodayLessonsSection(List<_TodayLesson> todayLessons, bool isDark, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 24, color: AppColors.duoBlue),
            const SizedBox(width: 8),
            Text(
              l.todayLessons.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (todayLessons.isEmpty)
          GamifiedCard(
            color: isDark
                ? AppColors.duoCardGray.withValues(alpha: 0.1)
                : Colors.white,
            shadowColor:
                isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                l.noTodayLessons,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
            ),
          )
        else
          ...todayLessons.map((lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTodayLessonCard(lesson, isDark),
              )),
      ],
    );
  }

  Widget _buildTodayLessonCard(_TodayLesson lesson, bool isDark) {
    Color lessonColor;
    IconData lessonIcon;
    switch (lesson.lessonType) {
      case 'Lesen':
        lessonColor = AppColors.duoBlue;
        lessonIcon = Icons.menu_book_rounded;
        break;
      case 'Hören':
        lessonColor = AppColors.duoGreen;
        lessonIcon = Icons.headphones_rounded;
        break;
      case 'Sprechen':
        lessonColor = AppColors.duoOrange;
        lessonIcon = Icons.record_voice_over_rounded;
        break;
      case 'Schreiben':
        lessonColor = AppColors.duoPurple;
        lessonIcon = Icons.edit_rounded;
        break;
      default:
        lessonColor = AppColors.duoBlue;
        lessonIcon = Icons.class_rounded;
    }

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherCourseDetailScreen(
              groupId: lesson.groupId,
              groupName: lesson.groupName,
              courseTitle: lesson.courseTitle,
              startDate: lesson.startDate,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: lessonColor,
              boxShadow: [
                BoxShadow(
                  color: lessonColor.withValues(alpha: 0.4),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
                child: Icon(lessonIcon, color: Colors.white, size: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.courseTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: isDark ? Colors.white70 : AppColors.duoTextLight),
                        const SizedBox(width: 4),
                        Text(lesson.time,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.duoTextLight)),
                      ],
                    ),
                    if (lesson.room != null && lesson.room!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(Icons.room_rounded, size: 14, color: isDark ? Colors.white70 : AppColors.duoTextLight),
                          const SizedBox(width: 4),
                          Text(lesson.room!,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.duoTextLight)),
                        ],
                      ),
                    ],
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(Icons.people_rounded, size: 14, color: isDark ? Colors.white70 : AppColors.duoTextLight),
                        const SizedBox(width: 4),
                        Text('${lesson.studentsCount}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.duoTextLight)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: lessonColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              lesson.lessonType,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: lessonColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pending work section ──
  Widget _buildPendingWorkSection(List<_PendingWork> pendingWorks, bool isDark, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment_rounded, size: 24, color: AppColors.duoOrange),
            const SizedBox(width: 8),
            Text(
              l.pendingWork.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (pendingWorks.isEmpty)
          GamifiedCard(
            color: isDark
                ? AppColors.duoCardGray.withValues(alpha: 0.1)
                : Colors.white,
            shadowColor:
                isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                l.noPendingWork,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
            ),
          )
        else
          ...pendingWorks.map((work) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPendingWorkCard(work, isDark),
              )),
      ],
    );
  }

  Widget _buildPendingWorkCard(_PendingWork work, bool isDark) {
    final remaining = work.totalStudents - work.submissions;
    final percent = work.totalStudents > 0 ? work.submissions / work.totalStudents : 0.0;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherCourseDetailScreen(
              groupId: work.groupId,
              groupName: work.groupName,
              courseTitle: work.courseTitle,
              startDate: work.startDate,
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.duoOrange.withValues(alpha: 0.2),
                ),
                child: const Center(
                    child: Icon(Icons.edit_document, color: AppColors.duoOrange, size: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${work.groupName}: ${work.title}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      work.type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.white70 : AppColors.duoTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (remaining > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.duoOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$remaining ${AppLocalizations.of(context).remainingShort}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.duoOrange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isDark ? Colors.white12 : AppColors.duoCardGray,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.duoOrange,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${work.submissions}/${work.totalStudents} ${AppLocalizations.of(context).submittedShort}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                ),
              ),
              Text(
                AppLocalizations.of(context).checkUpper,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.duoBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data models ──

class _TodayLesson {
  final String groupId;
  final String groupName;
  final String courseTitle;
  final String startDate;
  final String time;
  final String? room;
  final int studentsCount;
  final String lessonType;

  const _TodayLesson({
    required this.groupId,
    required this.groupName,
    required this.courseTitle,
    required this.startDate,
    required this.time,
    this.room,
    required this.studentsCount,
    required this.lessonType,
  });
}

class _PendingWork {
  final String groupId;
  final String groupName;
  final String courseTitle;
  final String startDate;
  final String title;
  final int submissions;
  final int totalStudents;
  final String type;

  const _PendingWork({
    required this.groupId,
    required this.groupName,
    required this.courseTitle,
    required this.startDate,
    required this.title,
    required this.submissions,
    required this.totalStudents,
    required this.type,
  });
}