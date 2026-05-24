import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/user_profile_utils.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../services/firebase_service.dart';
import '../../l10n/app_localizations.dart';
import 'admin_select_student_screen.dart';
import 'admin_select_teacher_screen.dart';

class AdminGroupDetailScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const AdminGroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  Future<void> _addStudent(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminSelectStudentScreen()),
    );

    if (result != null && context.mounted) {
      final studentId = result['id'] as String;
      final l = AppLocalizations.of(context);

      final existingGroupName = await FirebaseService().addStudentToGroup(groupId, studentId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingGroupName != null
                ? '${l.studentAlreadyInGroup} "$existingGroupName" ${l.studyingInGroup}'
                : AppLocalizations.of(context).studentAddedToGroupMsg(result['name']),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: existingGroupName != null ? AppColors.duoOrange : AppColors.duoGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Future<void> _removeStudent(BuildContext context, String studentId, String studentName) async {
    await FirebaseService().removeStudentFromGroup(groupId, studentId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).studentRemovedFromGroupMsg(studentName), style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          groupName.toUpperCase(),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_student_fab',
        onPressed: () => _addStudent(context),
        backgroundColor: AppColors.duoGreen,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Text('➕', style: TextStyle(fontSize: 24)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.duoBlue));
          }

          final groupData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final studentIds = List<String>.from(groupData['students'] ?? []);
          final teacherId = groupData['teacherId'] as String? ?? '';
          final teacherName = groupData['teacherName'] as String? ?? 'Biriktirilmagan';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SectionTitle(AppLocalizations.of(context).groupAboutHeader),
              GamifiedCard(
                padding: const EdgeInsets.all(20),
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoLine(title: AppLocalizations.of(context).groupNameInfo, value: groupName, isDark: isDark),
                    if (groupData['started'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoLine(title: AppLocalizations.of(context).startedInfo, value: groupData['started'], isDark: isDark),
                    ],
                    if (groupData['duration'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoLine(title: AppLocalizations.of(context).durationInfo, value: '${groupData['duration']} ${AppLocalizations.of(context).monthsLabel}', isDark: isDark),
                    ],
                    const SizedBox(height: 12),
                    _InfoLine(title: AppLocalizations.of(context).studentCountInfo, value: AppLocalizations.of(context).studentsCountShort(studentIds.length), isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(AppLocalizations.of(context).teacherHeader),
              GamifiedCard(
                padding: const EdgeInsets.all(20),
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (teacherId.isNotEmpty)
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(teacherId)
                            .snapshots(),
                        builder: (context, teacherSnap) {
                          final tData =
                              teacherSnap.data?.data() as Map<String, dynamic>? ?? {};
                          return UserAvatar(
                            imageUrl: UserProfileUtils.avatarUrl(tData),
                            size: 48,
                            fallbackEmoji: '👨‍🏫',
                            backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
                          );
                        },
                      )
                    else
                      UserAvatar(
                        size: 48,
                        fallbackEmoji: '👨‍🏫',
                        backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: teacherId.isNotEmpty
                          ? StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(teacherId)
                                  .snapshots(),
                              builder: (context, teacherSnap) {
                                final tData = teacherSnap.data?.data()
                                        as Map<String, dynamic>? ??
                                    {};
                                final name = UserProfileUtils.displayName(
                                  tData,
                                  fallback: teacherName,
                                );
                                final phone = UserProfileUtils.phone(tData);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.toUpperCase(),
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
                                              ? Colors.white70
                                              : AppColors.duoTextLight,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            )
                          : Text(
                              teacherName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                              ),
                            ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminSelectTeacherScreen()),
                        );
                        if (result != null) {
                          await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
                            'teacherId': result['id'],
                            'teacherName': result['name'],
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context).teacherAssigned, style: const TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: AppColors.duoGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ));
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.duoBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalizations.of(context).changeTeacher,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.duoBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _SectionTitle(AppLocalizations.of(context).studentsHeader)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.duoOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${studentIds.length} TA',
                      style: const TextStyle(
                        color: AppColors.duoOrange,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (studentIds.isEmpty)
                GamifiedCard(
                  padding: const EdgeInsets.all(24),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).noStudentsAddedYet,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                  ),
                )
              else
                ...studentIds.map((sid) => _FirebaseStudentItem(
                      studentId: sid,
                      isDark: isDark,
                      onRemove: (name) => _removeStudent(context, sid, name),
                    )),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.duoTextDark,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String title;
  final String value;
  final bool isDark;

  const _InfoLine({required this.title, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : AppColors.duoTextLight,
          ),
        ),
        Expanded(
          child: Text(
            value.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _FirebaseStudentItem extends StatelessWidget {
  final String studentId;
  final bool isDark;
  final void Function(String name) onRemove;

  const _FirebaseStudentItem({
    required this.studentId,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(studentId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 72, child: Center(child: CircularProgressIndicator(color: AppColors.duoBlue)));
          }
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final name = UserProfileUtils.displayName(data);
          final phone = UserProfileUtils.phone(data);
          final avatar = UserProfileUtils.avatarUrl(data);

          return GamifiedCard(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: avatar,
                  size: 48,
                  fallbackEmoji: '🧑‍🎓',
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
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight,
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onRemove(name),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.duoRed.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.duoRed, size: 20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}