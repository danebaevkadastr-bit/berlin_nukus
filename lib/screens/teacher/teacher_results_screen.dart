import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/darslar_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../utils/user_profile_utils.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/homework_submission_detail.dart';
import '../../widgets/user_avatar.dart';

/// Ustoz: kurs → guruh → talaba uy vazifa natijalari.
class TeacherResultsScreen extends StatefulWidget {
  const TeacherResultsScreen({super.key});

  @override
  State<TeacherResultsScreen> createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  _ResultsLevel _level = _ResultsLevel.courses;
  String? _courseId;
  String? _courseTitle;
  Map<String, dynamic>? _groupData;

  void _goCourses() {
    setState(() {
      _level = _ResultsLevel.courses;
      _courseId = null;
      _courseTitle = null;
      _groupData = null;
    });
  }

  void _goGroups(String courseId, String courseTitle) {
    setState(() {
      _level = _ResultsLevel.groups;
      _courseId = courseId;
      _courseTitle = courseTitle;
      _groupData = null;
    });
  }

  void _goStudents(Map<String, dynamic> group) {
    setState(() {
      _level = _ResultsLevel.students;
      _groupData = group;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final uid = context.watch<UserProvider>().uid;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _level != _ResultsLevel.courses
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: isDark ? Colors.white : AppColors.duoTextDark, size: 20),
                onPressed: () {
                  if (_level == _ResultsLevel.students) {
                    _goGroups(_courseId!, _courseTitle!);
                  } else {
                    _goCourses();
                  }
                },
              )
            : null,
        title: Text(
          _appBarTitle(context).toUpperCase(),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: uid.isEmpty
          ? Center(
              child: Text(
                'Iltimos, qayta kiring',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: DarslarService().getTeacherGroupsWithLessonsStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.duoOrange),
                  );
                }
                final groups = snapshot.data ?? [];
                final l = AppLocalizations.of(context);
                if (groups.isEmpty) {
                  return _empty(isDark, '${l.groups} topilmadi', Icons.school_rounded);
                }

                switch (_level) {
                  case _ResultsLevel.courses:
                    return _CoursesList(
                      groups: groups,
                      isDark: isDark,
                      onCourseTap: _goGroups,
                    );
                  case _ResultsLevel.groups:
                    return _GroupsList(
                      groups: groups
                          .where((g) =>
                              (g['courseId'] as String? ?? '') == _courseId)
                          .toList(),
                      courseTitle: _courseTitle ?? '',
                      isDark: isDark,
                      onGroupTap: _goStudents,
                    );
                  case _ResultsLevel.students:
                    return _StudentsResultsList(
                      groupData: _groupData!,
                      isDark: isDark,
                    );
                }
              },
            ),
    );
  }

  String _appBarTitle(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (_level) {
      case _ResultsLevel.courses:
        return l.myResults;
      case _ResultsLevel.groups:
        return _courseTitle ?? l.groups;
      case _ResultsLevel.students:
        return _groupData?['name'] as String? ?? l.studentsLabel;
    }
  }

  Widget _empty(bool isDark, String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: isDark ? Colors.white24 : AppColors.duoTextLight),
          const SizedBox(height: 12),
          Text(
            msg,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ResultsLevel { courses, groups, students }

class _CoursesList extends StatelessWidget {
  final List<Map<String, dynamic>> groups;
  final bool isDark;
  final void Function(String courseId, String courseTitle) onCourseTap;

  const _CoursesList({
    required this.groups,
    required this.isDark,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final courses = <String, _CourseBucket>{};
    for (final g in groups) {
      final id = g['courseId'] as String? ?? '';
      final title = g['courseTitle'] as String? ?? 'Kurs';
      courses.putIfAbsent(
        id,
        () => _CourseBucket(id: id, title: title, groupCount: 0, submissionCount: 0),
      );
      courses[id]!.groupCount++;
      courses[id]!.submissionCount += _countSubmissions(g);
    }

    final list = courses.values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    if (list.isEmpty) {
      return Center(
        child: Text(
          'Kurslar yo\'q',
          style: TextStyle(color: isDark ? Colors.white54 : AppColors.duoTextLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final c = list[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GamifiedCard(
            padding: const EdgeInsets.all(18),
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            onTap: () => onCourseTap(c.id, c.title),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.duoBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.duoBlue, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c.groupCount} ${l.groups.toLowerCase()} · ${c.submissionCount} ${l.task}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight),
              ],
            ),
          ),
        );
      },
    );
  }

  static int _countSubmissions(Map<String, dynamic> group) {
    var n = 0;
    final lessons = group['lessons'] as Map<String, dynamic>? ?? {};
    for (final lesson in lessons.values) {
      if (lesson is! Map) continue;
      final subs = lesson['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
      n += subs.values
          .where((s) => s is Map && s['submitted'] == true)
          .length;
    }
    return n;
  }
}

class _CourseBucket {
  final String id;
  final String title;
  int groupCount;
  int submissionCount;

  _CourseBucket({
    required this.id,
    required this.title,
    required this.groupCount,
    required this.submissionCount,
  });
}

class _GroupsList extends StatelessWidget {
  final List<Map<String, dynamic>> groups;
  final String courseTitle;
  final bool isDark;
  final void Function(Map<String, dynamic> group) onGroupTap;

  const _GroupsList({
    required this.groups,
    required this.courseTitle,
    required this.isDark,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (groups.isEmpty) {
      return Center(
        child: Text(
          'Bu kursda ${l.groups.toLowerCase()} yo\'q',
          style: TextStyle(color: isDark ? Colors.white54 : AppColors.duoTextLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
      itemCount: groups.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              courseTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white38 : AppColors.duoTextLight,
                letterSpacing: 0.6,
              ),
            ),
          );
        }
        final g = groups[i - 1];
        final name = g['name'] as String? ?? l.groups;
        final students = List<String>.from(g['students'] ?? []);
        final subs = _CoursesList._countSubmissions(g);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GamifiedCard(
            padding: const EdgeInsets.all(18),
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            onTap: () => onGroupTap(g),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.duoGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.groups_rounded, color: AppColors.duoGreen, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${students.length} ${l.student} · $subs ${l.task}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentsResultsList extends StatelessWidget {
  final Map<String, dynamic> groupData;
  final bool isDark;

  const _StudentsResultsList({
    required this.groupData,
    required this.isDark,
  });

  String _fmtDateKey(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length == 3) {
      return '${parts[2]}.${parts[1]}.${parts[0]}';
    }
    return dateKey;
  }

  List<_StudentResultBundle> _buildBundles() {
    final studentIds = List<String>.from(groupData['students'] ?? []);
    final lessons = groupData['lessons'] as Map<String, dynamic>? ?? {};
    final byStudent = <String, List<_SubmissionEntry>>{
      for (final id in studentIds) id: [],
    };

    final sortedDates = lessons.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final dateKey in sortedDates) {
      final lesson = lessons[dateKey];
      if (lesson is! Map<String, dynamic>) continue;
      final subs = lesson['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
      final homeworks = List<dynamic>.from(lesson['homeworks'] ?? []);
      final lessonType = lesson['lessonType'] as String? ?? 'Dars';

      subs.forEach((studentId, raw) {
        if (raw is! Map<String, dynamic>) return;
        if (raw['submitted'] != true) return;
        if (!byStudent.containsKey(studentId)) {
          byStudent[studentId] = [];
        }
        byStudent[studentId]!.add(
          _SubmissionEntry(
            dateKey: dateKey,
            lessonType: lessonType,
            homeworks: homeworks,
            submission: raw,
          ),
        );
      });
    }

    return studentIds
        .map((id) => _StudentResultBundle(
              studentId: id,
              entries: byStudent[id] ?? [],
            ))
        .where((b) => b.entries.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupId = groupData['id'] as String? ?? '';
    final bundles = _buildBundles();

    if (bundles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Hali uy vazifa topshirilmagan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
      itemCount: bundles.length,
      itemBuilder: (context, index) {
        final bundle = bundles[index];
        return _StudentResultCard(
          studentId: bundle.studentId,
          groupId: groupId,
          entries: bundle.entries,
          isDark: isDark,
          fmtDate: _fmtDateKey,
        );
      },
    );
  }
}

class _StudentResultBundle {
  final String studentId;
  final List<_SubmissionEntry> entries;

  _StudentResultBundle({required this.studentId, required this.entries});
}

class _SubmissionEntry {
  final String dateKey;
  final String lessonType;
  final List<dynamic> homeworks;
  final Map<String, dynamic> submission;

  _SubmissionEntry({
    required this.dateKey,
    required this.lessonType,
    required this.homeworks,
    required this.submission,
  });
}

class _StudentResultCard extends StatelessWidget {
  final String studentId;
  final String groupId;
  final List<_SubmissionEntry> entries;
  final bool isDark;
  final String Function(String) fmtDate;

  const _StudentResultCard({
    required this.studentId,
    required this.groupId,
    required this.entries,
    required this.isDark,
    required this.fmtDate,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
      builder: (context, userSnap) {
        final uData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
        final l = AppLocalizations.of(context);
        final name = UserProfileUtils.displayName(uData, fallback: l.student);
        final phone = UserProfileUtils.phone(uData);
        final avatar = UserProfileUtils.avatarUrl(uData);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GamifiedCard(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      imageUrl: avatar,
                      size: 48,
                      fallbackEmoji: '🧑‍🎓',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.duoTextDark,
                            ),
                          ),
                          if (phone.isNotEmpty)
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : AppColors.duoTextLight,
                              ),
                            ),
                          Text(
                            '${entries.length} ta ${l.task}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.duoGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...entries.map((e) => _SubmissionTile(
                      entry: e,
                      groupId: groupId,
                      studentId: studentId,
                      isDark: isDark,
                      fmtDate: fmtDate,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final _SubmissionEntry entry;
  final String groupId;
  final String studentId;
  final bool isDark;
  final String Function(String) fmtDate;

  const _SubmissionTile({
    required this.entry,
    required this.groupId,
    required this.studentId,
    required this.isDark,
    required this.fmtDate,
  });

  @override
  Widget build(BuildContext context) {
    final checked = entry.submission['checked'] == true;
    final hwTitle = entry.homeworks.isNotEmpty
        ? ((entry.homeworks.first as Map?)?['title'] as String? ?? 'Uy vazifa')
        : 'Uy vazifa';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? Colors.black26 : AppColors.duoBackground,
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmtDate(entry.dateKey),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    Text(
                      '${entry.lessonType} · $hwTitle',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!checked)
                TextButton(
                  onPressed: () async {
                    await DarslarService().markHomeworkChecked(
                      groupId,
                      entry.dateKey,
                      studentId,
                    );
                    if (context.mounted) {
                      final l = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.checked,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: AppColors.duoGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'TEKSHIRILDI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.duoBlue,
                    ),
                  ),
                )
              else
                const Text(
                  '✓ Tekshirilgan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.duoGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          HomeworkSubmissionDetail(
            submission: entry.submission,
            homeworks: entry.homeworks,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
