import 'package:flutter/material.dart';
import 'package:core/services/firebase_service.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/widgets/user_avatar.dart';
import 'package:core/utils/user_profile_utils.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/l10n/app_localizations.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.totalStudents.toUpperCase(),
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
      body: Column(
        children: [
          _buildSearch(l, isDark),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirebaseService().getStudentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.duoBlue));
                }

                var students = snapshot.data ?? [];

                if (_query.isNotEmpty) {
                  students = students.where((data) {
                    final name = (data['fullName'] ?? '').toLowerCase();
                    final email = (data['email'] ?? '').toLowerCase();
                    return name.contains(_query.toLowerCase()) || email.contains(_query.toLowerCase());
                  }).toList();
                }

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🧑‍🎓', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          l.noStudentsFound,
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final data = students[index];
                    return _StudentCard(
                      studentId: data['id'],
                      name: UserProfileUtils.displayName(data, fallback: l.noData),
                      email: data['email'] ?? l.noData,
                      phone: UserProfileUtils.phone(data),
                      avatarUrl: UserProfileUtils.avatarUrl(data),
                      createdAt: data['createdAt'],
                      isDark: isDark,
                      l: l,
                      onDelete: () => _deleteStudent(data['id'], l),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(AppLocalizations l, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GamifiedCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
        borderRadius: 24,
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          decoration: InputDecoration(
            hintText: '${l.search}...',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
            border: InputBorder.none,
            icon: const Text('🔍', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }

  void _deleteStudent(String studentId, AppLocalizations l) async {
    final isDark = ThemeManager.isDark;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.duoCardGray : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l.deleteStudentTitle.toUpperCase(),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        content: Text(
          l.deleteStudentConfirm,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.duoTextLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l.cancel.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.duoBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.duoRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: Text(
              l.delete.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await FirebaseService().deleteUser(studentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.studentDeleted,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }
}

class _StudentCard extends StatefulWidget {
  final String studentId;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final DateTime? createdAt;
  final bool isDark;
  final AppLocalizations l;
  final VoidCallback onDelete;

  const _StudentCard({
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.createdAt,
    required this.isDark,
    required this.l,
    required this.onDelete,
  });

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamifiedCard(
        padding: const EdgeInsets.all(20),
        color: widget.isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
        shadowColor: widget.isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  imageUrl: widget.avatarUrl,
                  size: 52,
                  fallbackEmoji: '🧑‍🎓',
                  borderRadius: 16,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? Colors.white : AppColors.duoTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white70 : AppColors.duoTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.duoRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.duoRed, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: widget.isDark ? Colors.white54 : AppColors.duoTextLight,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),
              _buildInfoRow('📱', widget.l.phoneLabel, widget.phone),
              const SizedBox(height: 10),
              _buildInfoRow('📅', widget.l.joinedDate, widget.createdAt != null
                  ? '${widget.createdAt!.day}.${widget.createdAt!.month}.${widget.createdAt!.year}'
                  : widget.l.noData),
              const SizedBox(height: 10),
              _buildInfoRow('👥', widget.l.groupLabel, widget.l.notAssignedYet),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? Colors.white54 : AppColors.duoTextLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        ),
      ],
    );
  }
}