import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/gamified_button.dart';
import '../../widgets/safe_bottom_sheet.dart';
import '../../utils/app_colors.dart';
import '../../utils/course_week_utils.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firebase_service.dart';
import '../../services/darslar_service.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';
import 'student_chat_screen.dart';
import 'classroom_3d_placeholder_screen.dart';

class StudentGroupScreen3DExperiment extends StatefulWidget {
  const StudentGroupScreen3DExperiment({super.key});

  @override
  State<StudentGroupScreen3DExperiment> createState() => _StudentGroupScreen3DExperimentState();
}

class _StudentGroupScreen3DExperimentState extends State<StudentGroupScreen3DExperiment> {
  List<Map<String, dynamic>> _groups = [];
  int _currentTabIndex = 0;
  int _selectedWeekIndex = 0;
  late List<_WeekRange> _weeks;

  @override
  void initState() {
    super.initState();
    _weeks = [];
  }

  List<_WeekRange> _generateWeeks(DateTime startDate, int weeksCount) {
    return CourseWeekUtils.generateWeeks(startDate, weeksCount)
        .map((w) => _WeekRange(start: w.start, end: w.end, index: w.index))
        .toList();
  }

  DateTime _parseStartDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}
    return DateTime.now();
  }

  String _formatShortDate(DateTime date) {
    final l = AppLocalizations.of(context);
    final months = [
      l.jan, l.feb, l.mar, l.apr, l.may, l.iyn,
      l.iyl, l.avg, l.sen, l.okt, l.noy, l.dek
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getWeekdayName(int weekday) {
    final l = AppLocalizations.of(context);
    final names = {
      1: l.monLong, 2: l.tueLong, 3: l.wedLong,
      4: l.thuLong, 5: l.friLong, 6: l.satLong, 7: l.sunLong,
    };
    return names[weekday] ?? '';
  }

  List<_LessonDay> _getLessonDaysForWeek(_WeekRange week, Map<String, dynamic> group) {
    final days = <_LessonDay>[];
    final lessonsMap = group['lessons'] as Map<String, dynamic>? ?? {};
    final startedDateStr = group['started']?.toString();
    final startDate = _parseStartDate(startedDateStr);
    final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);

    final weekRange = CourseWeekRange(
      start: week.start,
      end: week.end,
      index: week.index,
    );
    for (final date in CourseWeekUtils.daysInWeek(weekRange)) {
      if (date.isBefore(normalizedStartDate)) continue;

      final dateKey = _formatDateKey(date);
      final lessonData = lessonsMap[dateKey] as Map<String, dynamic>?;

      days.add(_LessonDay(
        date: date,
        weekdayName: _getWeekdayName(date.weekday),
        lessonType: lessonData?['lessonType'] ?? 'Dars',
        hasLesson: lessonData != null,
        room: lessonData?['room'],
        time: lessonData?['time'],
        materials: List<dynamic>.from(lessonData?['materials'] ?? []),
        homeworks: List<dynamic>.from(lessonData?['homeworks'] ?? []),
        submissions: Map<String, dynamic>.from(lessonData?['homeworkSubmissions'] ?? {}),
      ));
    }
    return days;
  }

  Color currentGroupColor() {
    if (_groups.isEmpty) return AppColors.duoBlue;
    return Color(_groups[_currentTabIndex]['color'] ?? AppColors.duoBlue.toARGB32());
  }

  Color currentGroupShadow() {
    if (_groups.isEmpty) return AppColors.duoBlueShadow;
    return Color(_groups[_currentTabIndex]['shadowColor'] ?? AppColors.duoBlueShadow.toARGB32());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService().getStudentGroupsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            appBar: _buildAppBar(l.myGroup),
            body: const Center(child: CircularProgressIndicator(color: AppColors.duoBlue)),
          );
        }

        _groups = snapshot.data ?? [];

        if (_groups.isEmpty) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            appBar: _buildAppBar(l.myGroup),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GamifiedCard(
                    color: AppColors.duoBlue,
                    shadowColor: AppColors.duoBlueShadow,
                    padding: EdgeInsets.all(24),
                    child: Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.notEnrolledInAnyCourse,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (_currentTabIndex >= _groups.length) _currentTabIndex = 0;
        final currentGroup = _groups[_currentTabIndex];

        // Generate weeks
        final startedDateStr = currentGroup['started']?.toString();
        final startDate = _parseStartDate(startedDateStr);
        final weeksCount = (currentGroup['weeksCount'] as num?)?.toInt() ?? 1;
        _weeks = _generateWeeks(startDate, weeksCount);
        if (_selectedWeekIndex >= _weeks.length) {
          _selectedWeekIndex = _weeks.length - 1;
          if (_selectedWeekIndex < 0) _selectedWeekIndex = 0;
        }

        final lessonDays = _weeks.isEmpty
            ? <_LessonDay>[]
            : _getLessonDaysForWeek(_weeks[_selectedWeekIndex], currentGroup);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: _buildAppBar(currentGroup['name'].toString().toUpperCase()),
          body: Column(
            children: [
              // Tab bar for multiple groups
              if (_groups.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: GamifiedCard(
                    padding: const EdgeInsets.all(4),
                    borderRadius: 24,
                    color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                    shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                    child: Row(
                      children: List.generate(_groups.length, (index) {
                        final isActive = _currentTabIndex == index;
                        final groupColor =
                            Color(_groups[index]['color'] ?? AppColors.duoBlue.toARGB32());
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _currentTabIndex = index;
                              _selectedWeekIndex = 0;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isActive ? groupColor : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _groups[index]['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isActive
                                      ? Colors.white
                                      : (isDark ? Colors.white54 : AppColors.duoTextLight),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Week selector
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _weeks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final week = _weeks[index];
                    final isSelected = _selectedWeekIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedWeekIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isSelected
                              ? currentGroupColor()
                              : (isDark
                                  ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                  : Colors.white),
                          border: Border.all(
                            color: isSelected
                                ? currentGroupShadow()
                                : (isDark ? Colors.transparent : AppColors.duoCardGrayShadow),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? currentGroupShadow()
                                  : (isDark
                                      ? Colors.black26
                                      : AppColors.duoCardGrayShadow.withValues(alpha: 0.5)),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${_formatShortDate(week.start)} - ${_formatShortDate(week.end)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.duoTextDark),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Lesson days list
              Expanded(
                child: lessonDays.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
                        itemCount: lessonDays.length,
                        itemBuilder: (context, index) {
                          final day = lessonDays[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildLessonCard(
                              context, day, uid, currentGroup['id'] ?? '', index == 0,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    final isDark = ThemeManager.isDark;
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.duoTextDark,
          letterSpacing: 1.0,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        if (_groups.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentChatScreen(
                    groupId: _groups[_currentTabIndex]['id'],
                    groupName: _groups[_currentTabIndex]['name'],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLessonCard(
      BuildContext context, _LessonDay day, String uid, String groupId, bool isSpecialActiveDay) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final color = currentGroupColor();
    final shadowColor = currentGroupShadow();
    final mySubmission = day.submissions[uid] as Map<String, dynamic>? ?? {};
    final submitted = mySubmission['submitted'] == true;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.date.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${day.weekdayName}, ${day.date.day}.${day.date.month.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withValues(alpha: 0.15),
                ),
                child: Text(
                  day.lessonType.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 12),
                ),
              ),
            ],
          ),

          // Show room and time if available
          if (day.hasLesson && (day.time != null || day.room != null)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (day.time != null && day.time!.isNotEmpty) ...[
                  Icon(Icons.access_time_rounded, size: 13, color: isDark ? Colors.white70 : AppColors.duoTextLight),
                  const SizedBox(width: 4),
                  Text(day.time!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                  const SizedBox(width: 12),
                ],
                if (day.room != null && day.room!.isNotEmpty) ...[
                  Icon(Icons.school_rounded, size: 13, color: isDark ? Colors.white70 : AppColors.duoTextLight),
                  const SizedBox(width: 4),
                  Text(day.room!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                ],
              ],
            ),
          ],

          const SizedBox(height: 16),

          if (!day.hasLesson)
            isSpecialActiveDay
                ? Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark
                              ? AppColors.duoCardGray.withValues(alpha: 0.05)
                              : AppColors.duoBackground,
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.duoOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.online_prediction_rounded,
                                color: AppColors.duoOrange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'FAOLLASHTIRILGAN SINFXONA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.duoOrange,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'AI O\'qituvchi bilan 3D virtual dars',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : AppColors.duoTextDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GamifiedButton(
                        text: 'Darsga kirish 🎮',
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const Classroom3DPlaceholderScreen(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 350),
                            ),
                          );
                        },
                        color: AppColors.duoBlue,
                        shadowColor: AppColors.duoBlueShadow,
                        height: 52,
                        icon: Icons.meeting_room_rounded,
                      ),
                    ],
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : AppColors.duoBackground,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).noLessonAddedYet,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        ),
                      ),
                    ),
                  )
          else
            Column(
              children: [
                // Row 1: Materials + Homework submission status
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showMaterialsSheet(context, day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark ? Colors.black12 : AppColors.duoBackground,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${day.materials.length} Material',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: submitted
                              ? AppColors.duoGreen.withValues(alpha: 0.15)
                              : (isDark ? Colors.black12 : AppColors.duoBackground),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                submitted ? 'Topshirildi' : 'Topshirilmagan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: submitted
                                      ? AppColors.duoGreen
                                      : (isDark ? Colors.white70 : AppColors.duoTextLight),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Homework button (only if homeworks exist)
                if (day.homeworks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showHomeworkSheet(context, day, uid, groupId),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: submitted ? AppColors.duoGreen : color,
                        border: Border.all(
                            color: submitted ? AppColors.duoGreenShadow : shadowColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: submitted ? AppColors.duoGreenShadow : shadowColor,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            submitted ? l.homeworkSubmitted : l.viewHomework,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // ==================== MATERIALS SHEET (view only) ====================

  void _showMaterialsSheet(BuildContext context, _LessonDay day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ThemeManager.isDark;
        final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;
        final titleColor = isDark ? Colors.white : AppColors.duoTextDark;
        final subColor = isDark ? Colors.white54 : AppColors.duoTextLight;

        return SafeBottomSheet.scrollable(
          context: ctx,
          maxHeightFactor: 0.75,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50, height: 6,
                    decoration: BoxDecoration(
                        color: AppColors.duoCardGrayShadow,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(day.lessonType.toUpperCase(),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                            letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(ctx).materials,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: subColor)),
                const SizedBox(height: 20),

                if (day.materials.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(ctx).noMaterialsYet,
                        style: TextStyle(fontWeight: FontWeight.w700, color: subColor),
                      ),
                    ),
                  )
                else
                  ...day.materials.map((item) {
                    final mat = item as Map<String, dynamic>? ?? {};
                    final type = mat['type'] ?? 'link';
                    final content = mat['content'] ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark
                            ? AppColors.duoCardGray.withValues(alpha: 0.1)
                            : AppColors.duoBackground,
                        border: Border.all(
                            color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                            width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: currentGroupColor().withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Icon(
                                type == 'link' ? Icons.link_rounded : Icons.description_rounded,
                                size: 22,
                                color: currentGroupColor(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type == 'link' ? 'Havola' : 'Matn',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: subColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  content,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: titleColor),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendHomeworkSubmissionNotificationToTeacher(
    String groupId,
    String studentId,
    String dateKey,
  ) async {
    final l = AppLocalizations.of(context);
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return;

      final groupData = groupDoc.data();
      final teacherId = groupData?['teacherId'] as String?;
      final groupName = groupData?['name'] as String?;

      if (teacherId == null || groupName == null) return;

      final notificationService = NotificationService();

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(studentId).get();
      final studentName = userDoc.data()?['fullName'] as String? ?? 'Talaba';

      await notificationService.createNotification(
        AppNotification(
          id: '${DateTime.now().millisecondsSinceEpoch}_${studentId.hashCode}',
          title: l.homeworkSubmittedNotifTitle,
          body: '$studentName $groupName ($dateKey)',
          type: 'homework',
          createdAt: DateTime.now(),
          userId: teacherId,
          data: {
            'groupName': groupName,
            'studentName': studentName,
            'dateKey': dateKey,
          },
        ),
      );
    } catch (e) {
      debugPrint('Error sending homework submission notification: $e');
    }
  }

  // ==================== HOMEWORK SHEET (student view + submit) ====================

  void _showHomeworkSheet(
      BuildContext context, _LessonDay day, String uid, String groupId) {
    final mySubmission = Map<String, dynamic>.from(day.submissions[uid] ?? {});
    final alreadySubmitted = mySubmission['submitted'] == true;

    final List<TextEditingController> testControllers = List.generate(
      day.homeworks.length,
      (i) => TextEditingController(),
    );
    final noteController =
        TextEditingController(text: mySubmission['note'] as String? ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ThemeManager.isDark;
        final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;
        final titleColor = isDark ? Colors.white : AppColors.duoTextDark;
        final subColor = isDark ? Colors.white54 : AppColors.duoTextLight;
        final color = currentGroupColor();
        final shadowColor = currentGroupShadow();
        final l = AppLocalizations.of(ctx);

        return SafeBottomSheet.fixedHeight(
          context: ctx,
          heightFactor: 0.92,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50, height: 6,
                    decoration: BoxDecoration(
                        color: AppColors.duoCardGrayShadow,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l.homeworkHeader,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${day.weekdayName}, ${day.date.day}.${day.date.month.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: subColor),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...day.homeworks.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final hw = entry.value;
                          final title = hw is Map ? (hw['title'] ?? '') : hw.toString();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isDark
                                  ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                  : AppColors.duoBackground,
                              border: Border.all(
                                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                                  width: 2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${idx + 1}-vazifa',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: subColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: titleColor),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        Text(
                          'Izoh / Javob',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: titleColor),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: noteController,
                          enabled: !alreadySubmitted,
                          maxLines: 3,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: titleColor),
                          decoration: InputDecoration(
                            hintText: 'Vazifa bo\'yicha javobingizni yozing...',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: subColor),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                : AppColors.duoBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                                  width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                                  width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: color, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (!alreadySubmitted)
                  GamifiedButton(
                    text: 'Topshirish',
                    onPressed: () async {
                      final dateKey = _formatDateKey(day.date);
                      final darslarService = DarslarService();
                      await darslarService.setHomeworkSubmission(
                        groupId: groupId,
                        dateKey: dateKey,
                        studentId: uid,
                        submission: {
                          'submitted': true,
                          'submittedAt': DateTime.now().toIso8601String(),
                          'note': noteController.text.trim(),
                        },
                      );
                      await _sendHomeworkSubmissionNotificationToTeacher(groupId, uid, dateKey);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                    color: color,
                    shadowColor: shadowColor,
                    height: 52,
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.duoGreen.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.duoGreen, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'Topshirilgan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.duoGreen,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeekRange {
  final DateTime start;
  final DateTime end;
  final int index;
  _WeekRange({required this.start, required this.end, required this.index});
}

class _LessonDay {
  final DateTime date;
  final String weekdayName;
  final String lessonType;
  final bool hasLesson;
  final String? room;
  final String? time;
  final List<dynamic> materials;
  final List<dynamic> homeworks;
  final Map<String, dynamic> submissions;

  _LessonDay({
    required this.date,
    required this.weekdayName,
    required this.lessonType,
    required this.hasLesson,
    this.room,
    this.time,
    required this.materials,
    required this.homeworks,
    required this.submissions,
  });
}
