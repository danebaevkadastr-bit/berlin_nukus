import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/services/cloudinary_service.dart';
import 'package:core/services/darslar_service.dart';
import 'package:core/services/notification_service.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/course_week_utils.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/utils/user_profile_utils.dart';
import 'package:core/widgets/user_avatar.dart';
import 'package:core/widgets/safe_bottom_sheet.dart';
import 'package:core/l10n/app_localizations.dart';

class TeacherCourseDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String courseTitle;
  final String startDate;
  final Color color;
  final Color shadowColor;

  const TeacherCourseDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.courseTitle,
    required this.startDate,
    this.color = AppColors.duoBlue,
    this.shadowColor = AppColors.duoBlueShadow,
  });

  @override
  State<TeacherCourseDetailScreen> createState() => _TeacherCourseDetailScreenState();
}

class _TeacherCourseDetailScreenState extends State<TeacherCourseDetailScreen> {
  int _selectedWeekIndex = 0;
  late List<_WeekRange> _weeks;

  @override
  void initState() {
    super.initState();
    _weeks = [];
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

  List<_WeekRange> _generateWeeks(DateTime startDate, int weeksCount) {
    return CourseWeekUtils.generateWeeks(startDate, weeksCount)
        .map((w) => _WeekRange(start: w.start, end: w.end, index: w.index))
        .toList();
  }

  /// Kompakt sana: 10.05
  String _formatDayMonth(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m';
  }

  String _formatWeekRangeLabel(_WeekRange week) {
    return '${_formatDayMonth(week.start)} - ${_formatDayMonth(week.end)}';
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

  List<_LessonDay> _getLessonDaysForWeek(_WeekRange week, Map<String, dynamic> groupData) {
    final l = AppLocalizations.of(context);
    final days = <_LessonDay>[];
    final lessonsMap = groupData['lessons'] as Map<String, dynamic>? ?? {};
    final startedDateStr = groupData['started']?.toString();
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
        lessonType: lessonData?['lessonType'] ?? l.lesson,
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return StreamBuilder<Map<String, dynamic>>(
      stream: DarslarService().getGroupWithLessonsStream(widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? {};
        final weeksCount = (data['weeksCount'] as num?)?.toInt() ?? 1;
        final startDate = _parseStartDate(data['started']?.toString() ?? widget.startDate);
        _weeks = _generateWeeks(startDate, weeksCount);

        if (_selectedWeekIndex >= _weeks.length) {
          _selectedWeekIndex = _weeks.length - 1;
          if (_selectedWeekIndex < 0) _selectedWeekIndex = 0;
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : AppColors.duoTextDark, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.groupName.toUpperCase(),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.duoTextDark,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.0,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.curriculum,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      widget.courseTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Week selector
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _weeks.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _weeks.length) {
                      return GestureDetector(
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('groups')
                              .doc(widget.groupId)
                              .update({'weeksCount': FieldValue.increment(1)});
                        },
                        child: Container(
                          width: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark
                                ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                : Colors.white,
                            border: Border.all(
                              color: isDark ? Colors.transparent : AppColors.duoCardGrayShadow,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.add_rounded, color: widget.color, size: 28),
                        ),
                      );
                    }
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
                              ? widget.color
                              : (isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white),
                          border: Border.all(
                            color: isSelected
                                ? widget.shadowColor
                                : (isDark ? Colors.transparent : AppColors.duoCardGrayShadow),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? widget.shadowColor
                                  : (isDark
                                      ? Colors.black26
                                      : AppColors.duoCardGrayShadow.withValues(alpha: 0.5)),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _formatWeekRangeLabel(week),
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

              Expanded(
                child: _weeks.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                        itemCount:
                            _getLessonDaysForWeek(_weeks[_selectedWeekIndex], data).length,
                        itemBuilder: (context, index) {
                          final day =
                              _getLessonDaysForWeek(_weeks[_selectedWeekIndex], data)[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildLessonCard(context, day, data),
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

  // ==================== LESSON CARD ====================

  Widget _buildLessonCard(
      BuildContext context, _LessonDay day, Map<String, dynamic> groupData) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final submittedCount = day.submissions.values
        .where((v) => (v as Map<String, dynamic>?)?['submitted'] == true)
        .length;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.color.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.date.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: widget.color,
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
              Row(
                children: [
                  if (day.hasLesson) ...[
                    // Edit
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      onPressed: () => _showAddLessonSheet(context, day, isEdit: true),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    // Delete
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: AppColors.duoRed,
                      onPressed: () => _deleteLesson(context, day),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.color.withValues(alpha: 0.15),
                    ),
                    child: Text(
                      day.lessonType.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: widget.color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (day.hasLesson && (day.time != null || day.room != null)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (day.time != null && day.time!.isNotEmpty) ...[
                  Icon(Icons.access_time_rounded, size: 14, color: isDark ? Colors.white54 : AppColors.duoTextLight),
                  const SizedBox(width: 4),
                  Text(
                    day.time!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (day.room != null && day.room!.isNotEmpty) ...[
                  Icon(Icons.meeting_room_rounded, size: 14, color: isDark ? Colors.white54 : AppColors.duoTextLight),
                  const SizedBox(width: 4),
                  Text(
                    day.room!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    ),
                  ),
                ],
              ],
            ),
          ],
          
          const SizedBox(height: 16),

          if (!day.hasLesson)
            GestureDetector(
              onTap: () => _showAddLessonSheet(context, day),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  border: Border.all(color: widget.color, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: widget.color),
                    const SizedBox(width: 8),
                    Text(
                      l.addLesson,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900, color: widget.color),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                // Row 1: Materials | Homework submissions
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showMaterialsSheet(context, day),
                        child: _actionChip(
                          isDark: isDark,
                          icon: Icons.attach_file_rounded,
                          label: '${day.materials.length} ${l.materialLabel}',
                          color: null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showHomeworkSubmissionsSheet(context, day, groupData),
                        child: _actionChip(
                          isDark: isDark,
                          icon: Icons.assignment_turned_in_rounded,
                          label: '$submittedCount ${l.submitted}',
                          color: day.homeworks.isNotEmpty ? AppColors.duoGreen : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Homework editor
                GestureDetector(
                  onTap: () => _showHomeworkSheet(context, day),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isDark ? Colors.black12 : AppColors.duoBackground,
                      border: day.homeworks.isNotEmpty
                          ? Border.all(color: AppColors.duoGreen.withValues(alpha: 0.5), width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 20,
                          color: day.homeworks.isNotEmpty
                              ? AppColors.duoGreen
                              : (isDark ? Colors.white60 : AppColors.duoTextLight)),
                        const SizedBox(width: 8),
                        Text(
                          day.homeworks.isEmpty
                              ? l.addHomework
                              : '${l.homeworkCount} (${day.homeworks.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: day.homeworks.isNotEmpty
                                ? AppColors.duoGreen
                                : (isDark ? Colors.white60 : AppColors.duoTextLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Row 3: Attendance
                GestureDetector(
                  onTap: () => _showAttendanceSheet(context, day, groupData),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: widget.color,
                      border: Border.all(color: widget.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(color: widget.shadowColor, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.how_to_reg_rounded, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          l.markAttendance,
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
            ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required bool isDark,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color != null
            ? color.withValues(alpha: 0.12)
            : (isDark ? Colors.black12 : AppColors.duoBackground),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color ?? (isDark ? Colors.white70 : AppColors.duoTextLight)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color ?? (isDark ? Colors.white70 : AppColors.duoTextLight),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MATERIALS SHEET ====================

  void _showMaterialsSheet(BuildContext context, _LessonDay day) {
    final l = AppLocalizations.of(context);
    final linkController = TextEditingController();
    final textController = TextEditingController();
    String selectedTab = 'link';
    bool isUploading = false;
    String? uploadError;

    final dateKey = _formatDateKey(day.date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ThemeManager.isDark;
        final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;

        return StatefulBuilder(
          builder: (ctx, setModalState) {

            // ── Upload helpers ──────────────────────────────────────────────
            Future<void> uploadAndSave({
              required List<int> bytes,
              required String filename,
              required bool isRaw,
              required String type,
            }) async {
              setModalState(() {
                isUploading = true;
                uploadError = null;
              });
              try {
                final url = isRaw
                    ? await CloudinaryService.uploadRawFile(
                        bytes: bytes,
                        filename: filename,
                        folder: 'materials/${widget.groupId}',
                      )
                    : await CloudinaryService.uploadBytes(
                        bytes: bytes,
                        filename: filename,
                        folder: 'materials/${widget.groupId}',
                      );
                final newMat = {
                  'type': type,
                  'content': url,
                  'filename': filename,
                };
                await DarslarService().addMaterial(widget.groupId, dateKey, newMat);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                setModalState(() {
                  isUploading = false;
                  uploadError = e.toString();
                });
              }
            }

            Future<void> pickImage(ImageSource source) async {
              final picker = ImagePicker();
              final xfile = await picker.pickImage(
                source: source,
                imageQuality: 85,
              );
              if (xfile == null) return;
              final bytes = await xfile.readAsBytes();
              await uploadAndSave(
                bytes: bytes,
                filename: xfile.name.isNotEmpty ? xfile.name : 'image.jpg',
                isRaw: false,
                type: 'image',
              );
            }

            Future<void> pickFile() async {
              final result = await FilePicker.platform.pickFiles(
                withData: true,
                allowMultiple: false,
              );
              if (result == null || result.files.isEmpty) return;
              final file = result.files.first;
              final bytes = file.bytes;
              if (bytes == null) return;
              final ext = file.extension?.toLowerCase() ?? '';
              final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
              await uploadAndSave(
                bytes: bytes,
                filename: file.name,
                isRaw: !isImage,
                type: isImage ? 'image' : 'file',
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.90),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 50, height: 6,
                          decoration: BoxDecoration(
                              color: AppColors.duoCardGrayShadow,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        Icon(Icons.attach_file_rounded, size: 22, color: isDark ? Colors.white : AppColors.duoTextDark),
                        const SizedBox(width: 10),
                        Text(l.materialsHeader,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.duoTextDark)),
                      ]),
                      const SizedBox(height: 16),

                      // ── Mavjud materiallar ──────────────────────────────
                      if (day.materials.isNotEmpty) ...[
                        Text(l.addedMaterials,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white60 : AppColors.duoTextLight)),
                        const SizedBox(height: 8),
                        ...day.materials.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final mat = entry.value as Map<String, dynamic>? ?? {};
                          final type = mat['type'] ?? 'link';
                          final content = mat['content'] ?? '';
                          final filename = mat['filename'] as String?;
                          final matIcon = type == 'image'
                              ? Icons.image_rounded
                              : type == 'file'
                                  ? Icons.insert_drive_file_rounded
                                  : type == 'link'
                                      ? Icons.link_rounded
                                      : Icons.notes_rounded;
                          final display = filename ?? content;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: isDark ? Colors.black26 : AppColors.duoBackground,
                              ),
                              child: Row(
                                children: [
                                  Icon(matIcon, size: 20, color: isDark ? Colors.white54 : AppColors.duoTextLight),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(display,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : AppColors.duoTextDark),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final newMats = List<dynamic>.from(day.materials);
                                      newMats.removeAt(idx);
                                      await DarslarService()
                                          .setMaterials(widget.groupId, dateKey, newMats);
                                      if (ctx.mounted) Navigator.pop(ctx);
                                    },
                                    child: const Icon(Icons.close_rounded,
                                        size: 20, color: AppColors.duoRed),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                      ],

                      // ── Upload xato ─────────────────────────────────────
                      if (uploadError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.duoRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.duoRed.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.duoRed, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(uploadError!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.duoRed)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Tabs ────────────────────────────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _tabButton(ctx, isDark, l.link, 'link', selectedTab,
                                (v) => setModalState(() => selectedTab = v)),
                            const SizedBox(width: 8),
                            _tabButton(ctx, isDark, l.text, 'text', selectedTab,
                                (v) => setModalState(() => selectedTab = v)),
                            const SizedBox(width: 8),
                            _tabButton(ctx, isDark, 'Rasm', 'image', selectedTab,
                                (v) => setModalState(() => selectedTab = v)),
                            const SizedBox(width: 8),
                            _tabButton(ctx, isDark, 'Fayl', 'file', selectedTab,
                                (v) => setModalState(() => selectedTab = v)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Tab content ─────────────────────────────────────
                      if (selectedTab == 'link')
                        TextField(
                          controller: linkController,
                          keyboardType: TextInputType.url,
                          style: TextStyle(
                              color: isDark ? Colors.white : AppColors.duoTextDark,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: l.linkHint,
                            hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : AppColors.duoTextLight),
                            prefixIcon: const Icon(Icons.link_rounded),
                            filled: true,
                            fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none),
                          ),
                        )
                      else if (selectedTab == 'text')
                        TextField(
                          controller: textController,
                          maxLines: 4,
                          style: TextStyle(
                              color: isDark ? Colors.white : AppColors.duoTextDark,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: l.materialTextHint,
                            hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : AppColors.duoTextLight),
                            prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 56),
                                child: Icon(Icons.notes_rounded)),
                            filled: true,
                            fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none),
                          ),
                        )
                      else if (selectedTab == 'image') ...[
                        // Rasm — gallery yoki kamera
                        Row(
                          children: [
                            Expanded(
                              child: GamifiedCard(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                color: isDark
                                    ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                    : Colors.white,
                                shadowColor: isDark
                                    ? Colors.black26
                                    : AppColors.duoCardGrayShadow,
                                shadowDepth: 4,
                                onTap: isUploading
                                    ? null
                                    : () => pickImage(ImageSource.gallery),
                                child: Column(
                                  children: [
                                    Icon(Icons.photo_library_rounded,
                                        size: 36,
                                        color: widget.color),
                                    const SizedBox(height: 8),
                                    Text('Galereya',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.duoTextDark)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GamifiedCard(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                color: isDark
                                    ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                    : Colors.white,
                                shadowColor: isDark
                                    ? Colors.black26
                                    : AppColors.duoCardGrayShadow,
                                shadowDepth: 4,
                                onTap: isUploading
                                    ? null
                                    : () => pickImage(ImageSource.camera),
                                child: Column(
                                  children: [
                                    Icon(Icons.camera_alt_rounded,
                                        size: 36,
                                        color: widget.color),
                                    const SizedBox(height: 8),
                                    Text('Kamera',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.duoTextDark)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (selectedTab == 'file') ...[
                        // Fayl tanlash
                        GamifiedCard(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          color: isDark
                              ? AppColors.duoCardGray.withValues(alpha: 0.1)
                              : Colors.white,
                          shadowColor:
                              isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                          shadowDepth: 4,
                          onTap: isUploading ? null : pickFile,
                          child: Column(
                            children: [
                              Icon(Icons.upload_file_rounded,
                                  size: 40, color: widget.color),
                              const SizedBox(height: 10),
                              Text('Fayl tanlash',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.duoTextDark)),
                              const SizedBox(height: 4),
                              Text('PDF, DOCX, PPTX, va boshqalar',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.duoTextLight)),
                            ],
                          ),
                        ),
                      ],

                      // ── Upload progress ─────────────────────────────────
                      if (isUploading) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: widget.color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Cloudinary ga yuklanmoqda...',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: widget.color)),
                            ],
                          ),
                        ),
                      ],

                      // ── Saqlash tugmasi (link va text uchun) ────────────
                      if (selectedTab == 'link' || selectedTab == 'text') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: GamifiedCard(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            color: widget.color,
                            shadowColor: widget.shadowColor,
                            onTap: () async {
                              final content = selectedTab == 'link'
                                  ? linkController.text.trim()
                                  : textController.text.trim();
                              if (content.isEmpty) return;
                              final newMat = {'type': selectedTab, 'content': content};
                              await DarslarService()
                                  .addMaterial(widget.groupId, dateKey, newMat);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: Center(
                              child: Text(l.saveBtn,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.0)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tabButton(
    BuildContext ctx,
    bool isDark,
    String label,
    String value,
    String selected,
    ValueChanged<String> onTap,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? widget.color : (isDark ? Colors.black26 : AppColors.duoBackground),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? widget.shadowColor : Colors.transparent, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.duoTextLight),
          ),
        ),
      ),
    );
  }

  // ==================== HOMEWORK SHEET (editor) ====================

  void _showHomeworkSheet(BuildContext context, _LessonDay day) {
    final l = AppLocalizations.of(context);
    // Deep copy so edits don't bleed into UI before save
    final List<Map<String, String>> homeworkList = day.homeworks
        .map((e) => Map<String, String>.from(e as Map? ?? {}))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ThemeManager.isDark;
        final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.assignment_rounded, size: 22, color: isDark ? Colors.white : AppColors.duoTextDark),
                          const SizedBox(width: 10),
                          Text(l.homeworkHeader,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.duoTextDark)),
                        ]),
                        GestureDetector(
                          onTap: () =>
                              setModalState(() => homeworkList.add({'title': '', 'detail': '', 'test': ''})),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.duoGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12)),
                            child:
                                const Icon(Icons.add_rounded, color: AppColors.duoGreen, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: homeworkList.isEmpty
                          ? Center(
                              child: Text(
                                l.tapToAddHomework,
                                style: TextStyle(
                                    color: isDark ? Colors.white38 : AppColors.duoTextLight,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          : ListView.builder(
                              itemCount: homeworkList.length,
                              itemBuilder: (ctx, idx) => _buildHomeworkEntry(
                                  ctx, idx, homeworkList, isDark, setModalState),
                            ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: GamifiedCard(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        onTap: () async {
                          final dateKey = _formatDateKey(day.date);
                          final validHomeworks = homeworkList
                              .where((h) => h['title']?.isNotEmpty == true)
                              .toList();
                          await DarslarService()
                              .setHomeworks(widget.groupId, dateKey, validHomeworks);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: Center(
                          child: Text(l.saveBtn,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeworkEntry(
    BuildContext ctx,
    int idx,
    List<Map<String, String>> list,
    bool isDark,
    StateSetter setModalState,
  ) {
    final l = AppLocalizations.of(ctx);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.black26 : AppColors.duoBackground,
        border: Border.all(
            color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text('${idx + 1}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: widget.color, fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text('Vazifa ${idx + 1}',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : AppColors.duoTextDark,
                          fontSize: 14))),
              GestureDetector(
                onTap: () => setModalState(() => list.removeAt(idx)),
                child:
                    const Icon(Icons.delete_outline_rounded, color: AppColors.duoRed, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          _homeworkTextField(
            isDark: isDark,
            hint: l.titleHint,
            initialValue: list[idx]['title'] ?? '',
            onChanged: (v) => list[idx]['title'] = v,
            maxLines: 1,
          ),
          const SizedBox(height: 8),

          // Detail
          _homeworkTextField(
            isDark: isDark,
            hint: l.detailInfoHint,
            initialValue: list[idx]['detail'] ?? '',
            onChanged: (v) => list[idx]['detail'] = v,
            maxLines: 3,
          ),
          const SizedBox(height: 10),

          // Test section per homework
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
              border: Border.all(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.25), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 15, color: const Color(0xFF7C3AED).withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text(
                      l.testAnswersOptional,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Format: 1a,2b,3c,4d',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _homeworkTextField(
                  isDark: isDark,
                  hint: '1a,2b,3c...',
                  initialValue: list[idx]['test'] ?? '',
                  onChanged: (v) => list[idx]['test'] = v,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeworkTextField({
    required bool isDark,
    required String hint,
    required String initialValue,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    final ctrl = TextEditingController(text: initialValue);
    ctrl.selection = TextSelection.fromPosition(TextPosition(offset: ctrl.text.length));
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      maxLines: maxLines,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.duoTextDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: isDark ? Colors.white38 : AppColors.duoTextLight,
            fontWeight: FontWeight.w500),
        filled: true,
        fillColor: isDark ? Colors.black12 : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ==================== HOMEWORK SUBMISSIONS SHEET ====================

  void _showHomeworkSubmissionsSheet(
      BuildContext context, _LessonDay day, Map<String, dynamic> groupData) {
    final studentIds = List<String>.from(groupData['students'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ThemeManager.isDark;
        final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;
        final l = AppLocalizations.of(ctx);

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.78,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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

              // Summary banner
              GamifiedCard(
                padding: const EdgeInsets.all(16),
                color: AppColors.duoGreen,
                shadowColor: AppColors.duoGreenShadow,
                child: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_rounded, size: 28, color: Colors.white),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${day.submissions.values.where((v) => (v as Map?)?['submitted'] == true).length} / ${studentIds.length}',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const Text('topshirdi',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    'Topshirganlar / Topshirmaganlar',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? Colors.white70 : AppColors.duoTextDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: studentIds.isEmpty
                    ? Center(child: Text(l.noStudentsInGroup))
                    : FutureBuilder<QuerySnapshot?>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .where(FieldPath.documentId, whereIn: studentIds)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final docs = snapshot.data?.docs ?? [];
                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: docs.length,
                            itemBuilder: (context, i) {
                              final doc = docs[i];
                              final udata = doc.data() as Map<String, dynamic>;
                              final name =
                                  UserProfileUtils.displayName(udata, fallback: l.student);
                              final phone = UserProfileUtils.phone(udata);
                              final avatar = UserProfileUtils.avatarUrl(udata);
                              final uid = doc.id;
                              final subData =
                                  day.submissions[uid] as Map<String, dynamic>? ?? {};
                              final submitted = subData['submitted'] == true;
                              final sColor = submitted ? AppColors.duoGreen : AppColors.duoRed;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GamifiedCard(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  color: isDark
                                      ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                      : Colors.white,
                                  shadowColor:
                                      isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                                  child: Row(
                                    children: [
                                      UserAvatar(
                                        imageUrl: avatar,
                                        size: 42,
                                        fallbackEmoji: '🧑‍🎓',
                                        backgroundColor: sColor.withValues(alpha: 0.15),
                                        borderRadius: 12,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.duoTextDark,
                                              ),
                                            ),
                                            if (phone.isNotEmpty)
                                              Text(
                                                phone,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : AppColors.duoTextLight,
                                                ),
                                              ),
                                            if (submitted && subData['note'] != null)
                                              Text(
                                                subData['note'] as String,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : AppColors.duoTextLight,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              
                                            // Check for test grades
                                            if (submitted && subData['testGrades'] != null)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      'Natija: ${subData['testGrades']['correctCount'] ?? 0}/${subData['testGrades']['totalCount'] ?? 0} to\'g\'ri',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w800,
                                                        color: AppColors.duoOrange,
                                                      ),
                                                    ),
                                                  ),
                                                  if (subData['testGrades']['hwResults'] != null)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 6),
                                                      child: Wrap(
                                                        spacing: 4,
                                                        runSpacing: 4,
                                                        children: () {
                                                          final hwResults = subData['testGrades']['hwResults'] as Map<String, dynamic>;
                                                          final allGraded = <Map<String, dynamic>>[];
                                                          for (var hw in hwResults.values) {
                                                            if (hw['graded'] != null) {
                                                              allGraded.addAll(List<Map<String, dynamic>>.from(hw['graded']));
                                                            }
                                                          }
                                                          return allGraded.map((g) {
                                                            final isCorrect = g['isCorrect'] == true;
                                                            return Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: isCorrect ? AppColors.duoGreen.withValues(alpha: 0.15) : AppColors.duoRed.withValues(alpha: 0.15),
                                                                borderRadius: BorderRadius.circular(6),
                                                                border: Border.all(color: isCorrect ? AppColors.duoGreen : AppColors.duoRed, width: 1),
                                                              ),
                                                              child: Text(
                                                                isCorrect
                                                                    ? '${g['q']}${g['student'].toString().isEmpty ? '?' : g['student']}'
                                                                    : '${g['q']}${g['student'].toString().isEmpty ? '?' : g['student']} (${g['expected']})',
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.w800,
                                                                  color: isCorrect ? AppColors.duoGreen : AppColors.duoRed,
                                                                ),
                                                              ),
                                                            );
                                                          }).toList();
                                                        }(),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                color: sColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10)),
                                            child: Text(
                                              submitted ? 'TOPSHIRDI' : 'YO\'Q',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w900,
                                                  color: sColor),
                                            ),
                                          ),
                                          if (submitted && subData['checked'] != true)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final dateKey = _formatDateKey(day.date);
                                                  await DarslarService()
                                                      .markHomeworkChecked(
                                                          widget.groupId, dateKey, uid);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.duoBlue.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: AppColors.duoBlue, width: 1),
                                                  ),
                                                  child: const Text(
                                                    'TEKSHIRILDI',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w900,
                                                      color: AppColors.duoBlue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (submitted && subData['checked'] == true)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text('✓ Tekshirilgan',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.duoGreen)
                                              ),
                                            )
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
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== ADD LESSON SHEET ====================

  void _deleteLesson(BuildContext context, _LessonDay day) async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeManager.isDark ? const Color(0xFF131F24) : Colors.white,
        title: Text(l.deleteLessonTitle, style: TextStyle(color: ThemeManager.isDark ? Colors.white : AppColors.duoTextDark)),
        content: Text(l.deleteLessonConfirm, style: TextStyle(color: ThemeManager.isDark ? Colors.white70 : AppColors.duoTextLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelUpper, style: const TextStyle(color: AppColors.duoTextLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.deleteUpper, style: const TextStyle(color: AppColors.duoRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dateKey = _formatDateKey(day.date);
      await DarslarService().deleteLesson(widget.groupId, dateKey);
    }
  }

  void _showAddLessonSheet(BuildContext context, _LessonDay day, {bool isEdit = false}) {
    String selectedType = 'Lesen';
    final customController = TextEditingController();
    final timeController = TextEditingController();
    final roomController = TextEditingController();
    final types = ['Lesen', 'Hören', 'Grammatik', 'Schreiben', 'Sprechen', 'Test'];

    if (isEdit && day.hasLesson) {
      if (types.contains(day.lessonType)) {
        selectedType = day.lessonType;
      } else {
        selectedType = day.lessonType;
        customController.text = day.lessonType;
      }
      if (day.time != null) timeController.text = day.time!;
      if (day.room != null) roomController.text = day.room!;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        final isDark = ThemeManager.isDark;
        final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeBottomSheet.scrollable(
              context: ctx,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Text(isEdit ? l.editLessonTitle : l.addLesson,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.duoTextDark)),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: types.map((t) {
                        final isSelected = selectedType == t;
                        return GestureDetector(
                          onTap: () => setModalState(() {
                            selectedType = t;
                            customController.clear();
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.color
                                  : (isDark ? Colors.black26 : AppColors.duoBackground),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected ? widget.shadowColor : Colors.transparent,
                                  width: 2),
                            ),
                            child: Text(t,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : AppColors.duoTextLight))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: customController,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.duoTextDark),
                      onChanged: (val) {
                        if (val.isNotEmpty) setModalState(() => selectedType = val);
                      },
                      decoration: InputDecoration(
                        hintText: l.customLessonTypeHint,
                        hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : AppColors.duoTextLight,
                            fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: timeController,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.duoTextDark),
                            decoration: InputDecoration(
                              hintText: 'Vaqt (14:00)',
                              hintStyle: TextStyle(
                                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                  fontWeight: FontWeight.w600),
                              prefixIcon: Icon(Icons.access_time_rounded, color: widget.color),
                              filled: true,
                              fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: roomController,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.duoTextDark),
                            decoration: InputDecoration(
                              hintText: 'Xona (B1)',
                              hintStyle: TextStyle(
                                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                  fontWeight: FontWeight.w600),
                              prefixIcon: Icon(Icons.meeting_room_rounded, color: widget.color),
                              filled: true,
                              fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: GamifiedCard(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        onTap: () async {
                          final dateKey = _formatDateKey(day.date);
                          if (isEdit) {
                            await DarslarService().updateLesson(
                              groupId: widget.groupId,
                              dateKey: dateKey,
                              lessonType: selectedType,
                              room: roomController.text.trim(),
                              time: timeController.text.trim(),
                            );
                          } else {
                            await DarslarService().createLesson(
                              groupId: widget.groupId,
                              dateKey: dateKey,
                              lessonType: selectedType,
                              room: roomController.text.trim(),
                              time: timeController.text.trim(),
                            );

                            // Send notification to students
                            await _sendLessonNotificationToStudents(
                              widget.groupId,
                              widget.groupName,
                              selectedType,
                              timeController.text.trim(),
                              day.date,
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: Center(
                          child: Text(l.saveBtn,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendLessonNotificationToStudents(
    String groupId,
    String groupName,
    String lessonType,
    String time,
    DateTime date,
  ) async {
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return;

      final groupData = groupDoc.data();
      final studentIds = groupData?['students'] as List<dynamic>?;

      if (studentIds == null || studentIds.isEmpty) return;

      final notificationService = NotificationService();
      final formattedDate = '${date.day}/${date.month}/${date.year}';

      for (final studentId in studentIds) {
        await notificationService.createLessonReminder(
          userId: studentId as String,
          groupName: groupName,
          lessonTopic: lessonType,
          lessonTime: '$formattedDate $time',
        );
      }
    } catch (e) {
      debugPrint('Error sending lesson notification: $e');
    }
  }

  // ==================== ATTENDANCE SHEET ====================

  void _showAttendanceSheet(
      BuildContext context, _LessonDay day, Map<String, dynamic> groupData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ThemeManager.isDark;
        final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;
        final l = AppLocalizations.of(ctx);
        final studentIds = List<String>.from(groupData['students'] ?? []);

        final lessonsMap = groupData['lessons'] as Map<String, dynamic>? ?? {};
        final dateKey = _formatDateKey(day.date);
        final lessonData = lessonsMap[dateKey] as Map<String, dynamic>? ?? {};
        final attendanceMap = Map<String, bool>.from(lessonData['attendance'] ?? {});

        for (final uid in studentIds) {
          if (!attendanceMap.containsKey(uid)) attendanceMap[uid] = true;
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final presentCount = attendanceMap.values.where((v) => v == true).length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow, width: 2),
              ),
              child: Column(
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

                  GamifiedCard(
                    padding: const EdgeInsets.all(20),
                    color: widget.color,
                    shadowColor: widget.shadowColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${day.date.day}.${day.date.month.toString().padLeft(2, '0')} DAVOMAT',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white70,
                                  letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text('🧑‍🎓', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Text('$presentCount / ${studentIds.length}',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(this.context);
                            await DarslarService()
                                .setAttendance(widget.groupId, dateKey, attendanceMap);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l.attendanceSaved,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  backgroundColor: AppColors.duoGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: widget.color,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('SAQLASH',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: studentIds.isEmpty
                        ? Center(child: Text(l.noStudentsInGroup))
                        : FutureBuilder<QuerySnapshot?>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .where(FieldPath.documentId, whereIn: studentIds)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final userDocs = snapshot.data?.docs ?? [];
                              return ListView.builder(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: userDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = userDocs[index];
                                  final uData = doc.data() as Map<String, dynamic>;
                                  final name = UserProfileUtils.displayName(
                                    uData,
                                    fallback: l.student,
                                  );
                                  final phone = UserProfileUtils.phone(uData);
                                  final avatar = UserProfileUtils.avatarUrl(uData);
                                  final uid = doc.id;
                                  final isPresent = attendanceMap[uid] ?? true;
                                  final sColor =
                                      isPresent ? AppColors.duoGreen : AppColors.duoRed;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GamifiedCard(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      color: isDark
                                          ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                          : Colors.white,
                                      shadowColor: isDark
                                          ? Colors.black26
                                          : AppColors.duoCardGrayShadow,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                UserAvatar(
                                                  imageUrl: avatar,
                                                  size: 44,
                                                  fallbackEmoji: '🧑‍🎓',
                                                  backgroundColor:
                                                      sColor.withValues(alpha: 0.15),
                                                  borderRadius: 14,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w800,
                                                          color: isDark
                                                              ? Colors.white
                                                              : AppColors.duoTextDark,
                                                        ),
                                                      ),
                                                      if (phone.isNotEmpty)
                                                        Text(
                                                          phone,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                            color: isDark
                                                                ? Colors.white54
                                                                : AppColors.duoTextLight,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Switch(
                                            value: isPresent,
                                            activeThumbColor: AppColors.duoGreen,
                                            activeTrackColor:
                                                AppColors.duoGreen.withValues(alpha: 0.3),
                                            inactiveThumbColor: AppColors.duoRed,
                                            inactiveTrackColor:
                                                AppColors.duoRed.withValues(alpha: 0.3),
                                            onChanged: (v) =>
                                                setModalState(() => attendanceMap[uid] = v),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== MODELS ====================

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
