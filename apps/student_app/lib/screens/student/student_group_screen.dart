import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/widgets/safe_bottom_sheet.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/course_week_utils.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/l10n/app_localizations.dart';
import 'package:core/services/firebase_service.dart';
import 'package:core/services/darslar_service.dart';
import 'package:core/services/notification_service.dart';
import 'package:core/models/notification.dart';
import 'student_chat_screen.dart';

class StudentGroupScreen extends StatefulWidget {
  const StudentGroupScreen({super.key});

  @override
  State<StudentGroupScreen> createState() => _StudentGroupScreenState();
}

class _StudentGroupScreenState extends State<StudentGroupScreen> {
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
                              context, day, uid, currentGroup['id'] ?? '',
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
      BuildContext context, _LessonDay day, String uid, String groupId) {
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
            Container(
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

                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(l.homeworkHeader,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: titleColor)),
                    const Spacer(),
                    if (alreadySubmitted)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.duoGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text('TOPSHIRILDI',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.duoGreen)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: day.homeworks.length,
                    itemBuilder: (ctx, idx) {
                      final hw = day.homeworks[idx] as Map<String, dynamic>? ?? {};
                      final title = hw['title'] ?? '';
                      final detail = hw['detail'] ?? '';
                      final testAnswers = hw['test'] as String? ?? '';
                      final hasTest = testAnswers.isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: isDark ? Colors.black26 : AppColors.duoBackground,
                          border: Border.all(
                              color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                              width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8)),
                                  alignment: Alignment.center,
                                  child: Text('${idx + 1}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: color,
                                          fontSize: 14)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: titleColor)),
                                ),
                              ],
                            ),

                            if (detail.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(detail,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: subColor,
                                      height: 1.5)),
                            ],

                            if (hasTest) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                                  border: Border.all(
                                      color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                                      width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        SizedBox(width: 6),
                                        Text('TEST',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF7C3AED))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStudentTestView(
                                      hwIndex: idx,
                                      testAnswers: testAnswers,
                                      controller: testControllers[idx],
                                      isDark: isDark,
                                      readonly: alreadySubmitted,
                                      mySubmission: mySubmission,
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

                if (!alreadySubmitted) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: l.commentOptional,
                      hintStyle:
                          TextStyle(color: isDark ? Colors.white38 : AppColors.duoTextLight),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamifiedCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: color,
                      shadowColor: shadowColor,
                      onTap: () async {
                        final dateKey = _formatDateKey(day.date);
                        final Map<String, dynamic> testResults = {};
                        int totalCorrect = 0;
                        int totalQuestions = 0;

                        for (int i = 0; i < day.homeworks.length; i++) {
                          final studentAnsStr = testControllers[i].text.trim();
                          if (studentAnsStr.isNotEmpty) {
                            final expectedStr = (day.homeworks[i] as Map)['test'] as String? ?? '';
                            final expectedParts = expectedStr.split(RegExp(r'[,\s]+')).where((p) => p.isNotEmpty).toList();
                            final studentParts = studentAnsStr.split(RegExp(r'[,\s]+')).where((p) => p.isNotEmpty).toList();

                            List<Map<String, dynamic>> gradedQuestions = [];
                            for (var exp in expectedParts) {
                              final match = RegExp(r'^(\d+)([a-eA-E])$').firstMatch(exp.trim());
                              if (match != null) {
                                totalQuestions++;
                                final qNum = match.group(1)!;
                                final expAns = match.group(2)!.toLowerCase();

                                String stuAns = '';
                                for (var stu in studentParts) {
                                  final stuMatch = RegExp(r'^(\d+)([a-eA-E])$').firstMatch(stu.trim());
                                  if (stuMatch != null && stuMatch.group(1) == qNum) {
                                    stuAns = stuMatch.group(2)!.toLowerCase();
                                    break;
                                  }
                                }

                                final isCorrect = stuAns == expAns;
                                if (isCorrect) totalCorrect++;

                                gradedQuestions.add({
                                  'q': qNum,
                                  'expected': expAns,
                                  'student': stuAns,
                                  'isCorrect': isCorrect,
                                });
                              }
                            }

                            testResults['hw_$i'] = {
                              'studentRaw': studentAnsStr,
                              'graded': gradedQuestions,
                            };
                          }
                        }

                        final bool isPurelyTest = day.homeworks.isNotEmpty && day.homeworks.every((h) => ((h as Map)['test'] as String? ?? '').isNotEmpty) && noteController.text.trim().isEmpty;
                        
                        await DarslarService().setHomeworkSubmission(
                          groupId: groupId,
                          dateKey: dateKey,
                          studentId: uid,
                          submission: {
                            'submitted': true,
                            'submittedAt': DateTime.now().toIso8601String(),
                            'note': noteController.text.trim(),
                            'testGrades': {
                              'hwResults': testResults,
                              'correctCount': totalCorrect,
                              'totalCount': totalQuestions,
                            },
                            'checked': isPurelyTest,
                          },
                        );

                        await _sendHomeworkSubmissionNotificationToTeacher(
                          groupId,
                          uid,
                          dateKey,
                        );

                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Center(
                        child: Text(
                          'TOPSHIRISH',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  if ((mySubmission['note'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isDark ? Colors.black12 : AppColors.duoBackground),
                      child: Text(
                        '${mySubmission['note']}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: subColor,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentTestView({
    required int hwIndex,
    required String testAnswers,
    required TextEditingController controller,
    required bool isDark,
    required bool readonly,
    required Map<String, dynamic> mySubmission,
  }) {
    final parts = testAnswers.trim().split(RegExp(r'[,\s]+'));
    final questionCount = parts
        .where((p) => RegExp(r'^\d+[a-eA-E]$').hasMatch(p.trim()))
        .length;

    Widget resultWidget = const SizedBox();
    if (readonly) {
      final grades = mySubmission['testGrades']?['hwResults']?['hw_$hwIndex'];
      if (grades != null && grades['graded'] != null) {
        final gradedList = List<Map<String, dynamic>>.from(grades['graded']);
        
        int correctCount = gradedList.where((g) => g['isCorrect'] == true).length;
        int totalCount = gradedList.length;

        resultWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Natija: $correctCount / $totalCount to\'g\'ri',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.duoOrange,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: gradedList.map((g) {
                final isCorrect = g['isCorrect'] == true;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.duoGreen.withValues(alpha: 0.15) : AppColors.duoRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isCorrect ? AppColors.duoGreen : AppColors.duoRed, width: 1),
                  ),
                  child: Text(
                    isCorrect
                        ? '${g['q']}${g['student'].toString().isEmpty ? '?' : g['student']}'
                        : '${g['q']}${g['student'].toString().isEmpty ? '?' : g['student']} (To\'g\'risi: ${g['expected']})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isCorrect ? AppColors.duoGreen : AppColors.duoRed,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      } else {
        resultWidget = const Text(
          'Javob yuborildi',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.duoGreen),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$questionCount ta savol',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : AppColors.duoTextLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (!readonly)
          TextField(
            controller: controller,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.duoTextDark,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5),
            decoration: InputDecoration(
              hintText: 'Javoblar: 1a,2b,3c...',
              hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : AppColors.duoTextLight),
              filled: true,
              fillColor: isDark ? Colors.black26 : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          )
        else
          resultWidget,
      ],
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
    this.materials = const [],
    this.homeworks = const [],
    this.submissions = const {},
  });
}