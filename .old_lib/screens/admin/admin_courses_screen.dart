import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import 'admin_course_groups_screen.dart';
import '../../l10n/app_localizations.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  void _deleteCourse(_AdminCourseItem course) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A32) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_rounded, size: 48, color: AppColors.duoRed),
              const SizedBox(height: 16),
              Text(
                '${course.title} kursini o\'chirmoqchimisiz?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu amalni qaytarib bo\'lmaydi.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GamifiedCard(
                      onTap: () => Navigator.pop(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.duoBackground,
                      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                      child: Center(
                        child: Text(
                          l.cancel.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
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
                        await FirebaseService().deleteCourse(course.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: AppColors.duoRed,
                      shadowColor: const Color(0xFFCC3B3E),
                      shadowDepth: 4,
                      child: Center(
                        child: Text(
                          l.delete.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
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

  void _openGroups(String courseId, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminCourseGroupsScreen(
          courseId: courseId,
          courseTitle: title,
        ),
      ),
    );
  }

  void _editCourse(_AdminCourseItem course) {
    final titleController = TextEditingController(text: course.title);
    String type = course.type;
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2A32) : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.edit.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDialogField(titleController, l.courseName, isDark),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  dropdownColor: isDark ? const Color(0xFF1E2A32) : Colors.white,
                  decoration: InputDecoration(
                    labelText: l.courseType,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.duoBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Offline', 'Online']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setDialog(() => type = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GamifiedCard(
                        onTap: () => Navigator.pop(context),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.duoBackground,
                        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                        child: Center(
                          child: Text(
                            l.cancel.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
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
                          if (titleController.text.isEmpty) return;
                          await FirebaseService().updateCourse(
                            courseId: course.id,
                            title: titleController.text.trim(),
                            type: type,
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        shadowDepth: 4,
                        child: Center(
                          child: Text(
                            l.save.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
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
      ),
    );
  }

  void _showAddCourseDialog() {
    final titleController = TextEditingController();
    String type = 'Offline';
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2A32) : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.addCourse.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDialogField(titleController, l.courseName, isDark),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  dropdownColor: isDark ? const Color(0xFF1E2A32) : Colors.white,
                  decoration: InputDecoration(
                    labelText: l.courseType,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.duoBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Offline', 'Online']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setDialog(() => type = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GamifiedCard(
                        onTap: () => Navigator.pop(context),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.duoBackground,
                        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                        child: Center(
                          child: Text(
                            l.cancel.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
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
                          if (titleController.text.isEmpty) return;
                          await FirebaseService().addCourse(
                            title: titleController.text.trim(),
                            type: type,
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        shadowDepth: 4,
                        child: Center(
                          child: Text(
                            l.save.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
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
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, bool isDark) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.duoTextDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : AppColors.duoTextLight,
        ),
        filled: true,
        fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService().getCoursesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            body: const Center(child: CircularProgressIndicator(color: AppColors.duoBlue)),
          );
        }

        final courses = snapshot.data ?? [];
        
        final offlineCount = courses.where((course) => course['type'] == 'Offline').length;
        final onlineCount = courses.where((course) => course['type'] == 'Online').length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.courses.toUpperCase(),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          heroTag: 'add_course_fab',
          backgroundColor: AppColors.duoGreen,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () => _showAddCourseDialog(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: courses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 64, color: isDark ? Colors.white24 : AppColors.duoTextLight.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    l.noCoursesYet,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
              children: [
                _CoursesHeader(
                  total: '${courses.length}',
                  offline: '$offlineCount',
                  online: '$onlineCount',
                  isDark: isDark,
                  l: l,
                ),
                const SizedBox(height: 24),
                ...courses.map((course) {
                      final item = _AdminCourseItem(
                        id: course['id'] ?? '',
                        title: course['title'] ?? 'Noma\'lum kurs',
                        type: course['type'] ?? 'Offline',
                        groups: course['groups'] ?? 0,
                        students: course['students'] ?? 0,
                        color: course['type'] == 'Online' ? AppColors.duoOrange : AppColors.duoBlue,
                        shadow: course['type'] == 'Online' ? AppColors.duoOrangeShadow : AppColors.duoBlueShadow,
                      );
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AdminCourseCard(
                          course: item,
                          isDark: isDark,
                          l: l,
                          onTap: () => _openGroups(item.id, item.title),
                          onEdit: () => _editCourse(item),
                          onDelete: () => _deleteCourse(item),
                          onGroups: () => _openGroups(item.id, item.title),
                        ),
                      );
                    }),
              ],
            ),
    );
    });
  }
}

class _CoursesHeader extends StatelessWidget {
  final String total;
  final String offline;
  final String online;
  final bool isDark;
  final AppLocalizations l;

  const _CoursesHeader({
    required this.total,
    required this.offline,
    required this.online,
    required this.isDark,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return GamifiedCard(
      padding: const EdgeInsets.all(22),
      color: AppColors.duoPurple,
      shadowColor: AppColors.duoPurpleShadow,
      shadowDepth: 5,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KURS BOSHQARUVI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Berlin Nukus Kurslari',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.school_rounded, size: 32, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderStat(title: l.courses, value: total),
              _HeaderStat(title: 'Offline', value: offline),
              _HeaderStat(title: 'Online', value: online),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String title;
  final String value;

  const _HeaderStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _AdminCourseCard extends StatelessWidget {
  final _AdminCourseItem course;
  final bool isDark;
  final AppLocalizations l;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onGroups;

  const _AdminCourseCard({
    required this.course,
    required this.isDark,
    required this.l,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onGroups,
  });

  @override
  Widget build(BuildContext context) {
    return GamifiedCard(
      padding: const EdgeInsets.all(18),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: course.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(
                    course.type == 'Online' ? Icons.laptop_rounded : Icons.school_rounded,
                    color: course.color,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: course.type == 'Online'
                            ? AppColors.duoBlue.withValues(alpha: 0.15)
                            : AppColors.duoGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: course.type == 'Online' ? AppColors.duoBlue : AppColors.duoGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: AppColors.duoRed, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _CourseInfoMiniCard(title: l.totalGroups, value: '${course.groups}', color: course.color, isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: _CourseInfoMiniCard(title: l.totalStudents, value: '${course.students}', color: course.color, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GamifiedCard(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: isDark ? Colors.white12 : AppColors.duoBackground,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGray,
                  shadowDepth: 3,
                  onTap: onEdit,
                  child: Center(
                    child: Text(
                      l.edit.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GamifiedCard(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: course.color,
                  shadowColor: course.shadow,
                  shadowDepth: 4,
                  onTap: onGroups,
                  child: Center(
                    child: Text(
                      l.totalGroups.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseInfoMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _CourseInfoMiniCard({
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCourseItem {
  final String id;
  final String title;
  final String type;
  final int groups;
  final int students;
  final Color color;
  final Color shadow;

  const _AdminCourseItem({
    required this.id,
    required this.title,
    required this.type,
    required this.groups,
    required this.students,
    required this.color,
    required this.shadow,
  });
}