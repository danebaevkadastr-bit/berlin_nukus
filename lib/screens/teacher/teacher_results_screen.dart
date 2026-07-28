import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/darslar_service.dart';
import '../../services/mock_test_history_service.dart';
import '../../services/student_results_service.dart';
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
              child: Builder(builder: (context) {
                final l = AppLocalizations.of(context);
                return Text(
                  l.pleaseReLoginShort2,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
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
      final title = g['courseTitle'] as String? ?? l.navGroup;
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
          l.noCoursesFound,
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
                        '${c.groupCount} ${l.groups.toLowerCase()}',
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
                        '${students.length} ${l.student}',
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

  @override
  Widget build(BuildContext context) {
    final studentIds = List<String>.from(groupData['students'] ?? []);
    final l = AppLocalizations.of(context);

    if (studentIds.isEmpty) {
      return Center(
        child: Text(
          l.noStudentsInGroup,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : AppColors.duoTextLight,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
      itemCount: studentIds.length,
      itemBuilder: (context, index) {
        final studentId = studentIds[index];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
          builder: (context, userSnap) {
            final uData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
            final name = UserProfileUtils.displayName(uData, fallback: l.student);
            final avatar = UserProfileUtils.avatarUrl(uData);

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
                      builder: (_) => _StudentDetailResults(
                        studentId: studentId,
                        studentName: name,
                        groupData: groupData,
                        isDark: isDark,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    UserAvatar(imageUrl: avatar, size: 44, fallbackEmoji: '🧑‍🎓'),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
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
      },
    );
  }
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

// ─────────────────────────────────────────────────────────────────────────────
// Talaba natijasi ekrani (gorizontal tablar: Uyga vazifa / Lesen / Hören / Mock test)
// ─────────────────────────────────────────────────────────────────────────────
class _StudentDetailResults extends StatelessWidget {
  final String studentId;
  final String studentName;
  final Map<String, dynamic> groupData;
  final bool isDark;

  const _StudentDetailResults({
    required this.studentId,
    required this.studentName,
    required this.groupData,
    required this.isDark,
  });

  String _fmtDateKey(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length == 3) return '${parts[2]}.${parts[1]}.${parts[0]}';
    return dateKey;
  }

  List<_SubmissionEntry> _getHomeworkEntries() {
    final lessons = groupData['lessons'] as Map<String, dynamic>? ?? {};
    final entries = <_SubmissionEntry>[];
    final sortedDates = lessons.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final dateKey in sortedDates) {
      final lesson = lessons[dateKey];
      if (lesson is! Map<String, dynamic>) continue;
      final subs = lesson['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
      final homeworks = List<dynamic>.from(lesson['homeworks'] ?? []);
      final lessonType = lesson['lessonType'] as String? ?? 'Dars';

      final raw = subs[studentId];
      if (raw is! Map<String, dynamic>) continue;
      if (raw['submitted'] != true) continue;

      entries.add(_SubmissionEntry(
        dateKey: dateKey,
        lessonType: lessonType,
        homeworks: homeworks,
        submission: raw,
      ));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final groupId = groupData['id'] as String? ?? '';
    final homeworkEntries = _getHomeworkEntries();

    final tabs = <_ResultTab>[
      _ResultTab(label: l.homeworkDefault, icon: Icons.assignment_rounded),
      _ResultTab(label: 'Lesen', icon: Icons.menu_book_rounded),
      _ResultTab(label: 'Hören', icon: Icons.headphones_rounded),
      _ResultTab(label: 'Mock Test', icon: Icons.fact_check_rounded),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : AppColors.duoTextDark, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            studentName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.duoBlue,
                indicatorWeight: 3,
                labelColor: isDark ? Colors.white : AppColors.duoTextDark,
                unselectedLabelColor: isDark ? Colors.white54 : AppColors.duoTextLight,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: tabs.map((t) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t.icon, size: 16),
                      const SizedBox(width: 6),
                      Text(t.label),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Uyga vazifa
            homeworkEntries.isEmpty
                ? _emptyTab(l.noHomeworkSubmittedYet)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    itemCount: homeworkEntries.length,
                    itemBuilder: (context, i) {
                      final e = homeworkEntries[i];
                      return _SubmissionTile(
                        entry: e,
                        groupId: groupId,
                        studentId: studentId,
                        isDark: isDark,
                        fmtDate: _fmtDateKey,
                      );
                    },
                  ),
            // Lesen
            _ResultsFromFirebase(studentId: studentId, type: 'lesen', isDark: isDark),
            // Hören
            _ResultsFromFirebase(studentId: studentId, type: 'horen', isDark: isDark),
            // Mock Test
            _ResultsFromFirebase(studentId: studentId, type: 'mock_test', isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _emptyTab(String msg) {
    return Center(
      child: Text(
        msg,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white54 : AppColors.duoTextLight,
        ),
      ),
    );
  }
}

class _ResultTab {
  final String label;
  final IconData icon;
  const _ResultTab({required this.label, required this.icon});
}

/// Firebase'dan Lesen/Hören/Mock Test natijalarini ko'rsatuvchi widget.
class _ResultsFromFirebase extends StatelessWidget {
  final String studentId;
  final String type;
  final bool isDark;

  const _ResultsFromFirebase({
    required this.studentId,
    required this.type,
    required this.isDark,
  });

  String _emptyMsg() {
    switch (type) {
      case 'lesen':
        return 'Bu talaba hali Lesen testini topshirmagan';
      case 'horen':
        return 'Bu talaba hali Hören testini topshirmagan';
      case 'mock_test':
        return 'Bu talaba hali Mock test topshirmagan';
      default:
        return 'Natijalar topilmadi';
    }
  }

  String _fmtTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }
    return '';
  }

  /// Teil bo'yicha natijalarni guruhlaymiz (Lesen/Hören uchun)
  Map<String, List<Map<String, dynamic>>> _groupByTeil(List<Map<String, dynamic>> results) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    
    for (final r in results) {
      final title = r['title'] as String? ?? '';
      
      // Teil'ni aniqlash: "Teil 1", "Teil 2" va h.k.
      String teil = 'Boshqa'; // Default
      
      // Regex bilan Teil'ni topish
      final teilMatch = RegExp(r'Teil\s*(\d+)', caseSensitive: false).firstMatch(title);
      if (teilMatch != null) {
        teil = 'Teil ${teilMatch.group(1)}';
      } else if (title.toLowerCase().contains('lesen') || title.toLowerCase().contains('hören')) {
        // Agar Teil yo'q bo'lsa, lekin Lesen/Hören mavjud bo'lsa
        teil = 'Umumiy';
      }
      
      grouped.putIfAbsent(teil, () => []);
      grouped[teil]!.add(r);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final stream = type == 'mock_test'
        ? MockTestHistoryService.stream(uid: studentId)
        : StudentResultsService.resultsStream(studentId, type: type);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.duoBlue),
          );
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Text(
              _emptyMsg(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : AppColors.duoTextLight,
              ),
            ),
          );
        }

        // Mock test uchun Teil guruhlamaslik
        if (type == 'mock_test') {
          return _buildRegularList(results);
        }

        // Lesen/Hören uchun Teil bo'yicha guruhlash
        final grouped = _groupByTeil(results);
        final sortedTeils = grouped.keys.toList()..sort((a, b) {
          // Teil raqami bo'yicha saralash: Teil 1, Teil 2, ...
          final aMatch = RegExp(r'(\d+)').firstMatch(a);
          final bMatch = RegExp(r'(\d+)').firstMatch(b);
          if (aMatch != null && bMatch != null) {
            return int.parse(aMatch.group(1)!).compareTo(int.parse(bMatch.group(1)!));
          }
          return a.compareTo(b);
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          itemCount: sortedTeils.length,
          itemBuilder: (context, i) {
            final teil = sortedTeils[i];
            final teilResults = grouped[teil]!;
            final topPadding = i > 0 ? 20.0 : 0.0;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teil header
                Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12, top: topPadding),
                  child: Text(
                    teil.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.duoBlue : AppColors.duoBlue.withValues(alpha: 0.8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                // Natijalar
                ...teilResults.map((r) => _buildResultCard(r)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRegularList(List<Map<String, dynamic>> results) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      itemCount: results.length,
      itemBuilder: (context, i) => _buildResultCard(results[i]),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> r) {
    final title = r['title'] as String? ?? (type == 'mock_test' ? 'Mock Test B1' : '');
    final level = r['level'] as String? ?? '';
    // Mock test history'da field nomlari boshqacha
    final rawScore = (r['score'] as num?)?.toInt()
        ?? (r['totalPoints'] as num?)?.toInt() ?? 0;
    final rawTotal = (r['total'] as num?)?.toInt()
        ?? (r['totalMax'] as num?)?.toInt() ?? 0;
    final date = _fmtTimestamp(r['date']);
    final details = r['details'] as Map<String, dynamic>?;
    final hasQuestionDetails = details != null && details['questions'] != null;

    int score = rawScore;
    int total = rawTotal;

    // Eskiroq saqlangan natijalar uchun to'g'ri testlar va savollar sonini hisoblash
    if (hasQuestionDetails) {
      final qList = List<Map<String, dynamic>>.from(details['questions']);
      if (qList.isNotEmpty) {
        final attempted = qList.where((q) => q['isCorrect'] != null || (q['userAnswer'] as String? ?? '').isNotEmpty).toList();
        if (attempted.isNotEmpty && attempted.length < total && total >= 15) {
          total = attempted.length;
          score = attempted.where((q) => q['isCorrect'] == true).length;
        } else if (total > qList.length) {
          total = qList.length;
          score = qList.where((q) => q['isCorrect'] == true).length;
        }
      }
    }

    final percentage = total > 0 ? (score / total * 100).round() : 0;

    Color scoreColor;
    if (percentage >= 80) {
      scoreColor = AppColors.duoGreen;
    } else if (percentage >= 60) {
      scoreColor = AppColors.duoOrange;
    } else {
      scoreColor = AppColors.duoRed;
    }

    return Builder(
      builder: (builderContext) {
        return GestureDetector(
          onTap: hasQuestionDetails
              ? () {
                  Navigator.push(
                    builderContext,
                    MaterialPageRoute(
                      builder: (_) => _QuestionDetailsScreen(
                        title: '$title${level.isNotEmpty ? ' ($level)' : ''}',
                        score: score,
                        total: total,
                        percentage: percentage,
                        questions: List<Map<String, dynamic>>.from(details['questions']),
                        isDark: isDark,
                      ),
                    ),
                  );
                }
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              ),
            ),
            child: Row(
              children: [
                // Score circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scoreColor.withValues(alpha: 0.15),
                    border: Border.all(color: scoreColor, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$title${level.isNotEmpty ? ' ($level)' : ''}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$score / $total  ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white70 : AppColors.duoTextDark,
                            ),
                          ),
                          if (date.isNotEmpty) ...[
                            Text(
                              '·  ',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white38 : AppColors.duoTextLight,
                              ),
                            ),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : AppColors.duoTextLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasQuestionDetails)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight,
                  ),
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
    final l = AppLocalizations.of(context);
    final checked = entry.submission['checked'] == true;
    final hwTitle = entry.homeworks.isNotEmpty
        ? ((entry.homeworks.first as Map?)?['title'] as String? ?? l.homeworkDefault)
        : l.homeworkDefault;

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
                  child: Text(
                    l.checkedUpper,
                    style: const TextStyle(
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


// ─────────────────────────────────────────────────────────────────────────────
// Savol batafsil ekrani - Teacher har savol bo'yicha natijalarni ko'radi
// ─────────────────────────────────────────────────────────────────────────────
class _QuestionDetailsScreen extends StatelessWidget {
  final String title;
  final int score;
  final int total;
  final int percentage;
  final List<Map<String, dynamic>> questions;
  final bool isDark;

  const _QuestionDetailsScreen({
    required this.title,
    required this.score,
    required this.total,
    required this.percentage,
    required this.questions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Eskiroq yozuvlar uchun faqat yechilgan/topshirilgan savollarni filtrlash
    final attemptedQuestions = questions.where((q) => 
      q['isCorrect'] != null || (q['userAnswer'] as String? ?? '').isNotEmpty
    ).toList();

    final displayQuestions = (questions.length >= 15 && attemptedQuestions.isNotEmpty && attemptedQuestions.length < questions.length)
        ? attemptedQuestions
        : questions;

    final displayScore = displayQuestions.where((q) => q['isCorrect'] == true).length;
    final displayTotal = displayQuestions.length;
    final displayPercentage = displayTotal > 0 ? (displayScore / displayTotal * 100).round() : percentage;

    Color scoreColor;
    if (displayPercentage >= 80) {
      scoreColor = AppColors.duoGreen;
    } else if (displayPercentage >= 60) {
      scoreColor = AppColors.duoOrange;
    } else {
      scoreColor = AppColors.duoRed;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Savollar Batafsil',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header - umumiy natija
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scoreColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scoreColor.withValues(alpha: 0.15),
                    border: Border.all(color: scoreColor, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$displayPercentage%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$displayScore / $displayTotal to\'g\'ri javob',
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
          ),
          
          // Savollar ro'yxati
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              itemCount: displayQuestions.length,
              itemBuilder: (context, i) {
                final q = displayQuestions[i];
                final qNum = q['questionNumber'] as int? ?? (i + 1);
                final qText = q['questionText'] as String? ?? '';
                final userAnswer = q['userAnswer'] as String? ?? '';
                final correctAnswer = q['correctAnswer'] as String? ?? '';
                final isCorrect = q['isCorrect'] == true;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect 
                          ? AppColors.duoGreen.withValues(alpha: 0.3)
                          : AppColors.duoRed.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Savol raqami va status
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCorrect
                                  ? AppColors.duoGreen.withValues(alpha: 0.15)
                                  : AppColors.duoRed.withValues(alpha: 0.15),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$qNum',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isCorrect ? AppColors.duoGreen : AppColors.duoRed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isCorrect ? '✅ To\'g\'ri' : '❌ Xato',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isCorrect ? AppColors.duoGreen : AppColors.duoRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Savol matni
                      Text(
                        qText,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Talaba javobi
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.duoGreen.withValues(alpha: 0.08)
                              : AppColors.duoRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Talaba javobi:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : AppColors.duoTextLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userAnswer.isNotEmpty ? userAnswer : '(Javob berilmagan)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // To'g'ri javob (agar xato bo'lsa)
                      if (!isCorrect) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.duoGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To\'g\'ri javob:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.duoGreen.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                correctAnswer,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.duoGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
