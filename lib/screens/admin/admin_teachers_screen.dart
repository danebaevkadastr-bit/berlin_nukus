import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/user_profile_utils.dart';
import '../../widgets/gamified_button.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';

class AdminTeachersScreen extends StatefulWidget {
  const AdminTeachersScreen({super.key});

  @override
  State<AdminTeachersScreen> createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
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
          l.totalTeachers.toUpperCase(),
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
              stream: FirebaseService().getTeachersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.duoGreen));
                }

                var teachers = snapshot.data ?? [];

                if (_query.isNotEmpty) {
                  teachers = teachers.where((data) {
                    final name = (data['fullName'] ?? '').toLowerCase();
                    final email = (data['email'] ?? '').toLowerCase();
                    return name.contains(_query.toLowerCase()) || email.contains(_query.toLowerCase());
                  }).toList();
                }

                if (teachers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👨‍🏫', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          l.noTeachersFound,
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
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final data = teachers[index];
                    return _TeacherCard(
                      teacherId: data['id'],
                      name: UserProfileUtils.displayName(data, fallback: l.noData),
                      email: data['email'] ?? l.noData,
                      phone: UserProfileUtils.phone(data),
                      avatarUrl: UserProfileUtils.avatarUrl(data),
                      createdAt: data['createdAt'],
                      isDark: isDark,
                      l: l,
                      onDelete: () => _deleteTeacher(data['id'], l),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Keep above custom bottom bar
        child: FloatingActionButton(
          onPressed: () => _showAddTeacherSheet(context, l, isDark),
          backgroundColor: AppColors.duoGreen,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
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

  void _deleteTeacher(String teacherId, AppLocalizations l) async {
    final isDark = ThemeManager.isDark;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.duoCardGray : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l.deleteTeacherTitle.toUpperCase(),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        content: Text(
          l.deleteTeacherConfirm,
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
      await FirebaseService().deleteUser(teacherId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.teacherDeleted,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  void _showAddTeacherSheet(BuildContext context, AppLocalizations l, bool isDark) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2E35) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black54 : Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l.addTeacher.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: nameController,
                  label: l.fullNameLabel,
                  hint: 'Rustam Ubaydullayev',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: emailController,
                  label: l.email,
                  hint: 'rustam@gmail.com',
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: phoneController,
                  label: l.phoneLabel,
                  hint: '+998901112233',
                  icon: Icons.phone_android_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l.cancel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white60 : AppColors.duoTextLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GamifiedButton(
                        text: l.add,
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        height: 50,
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          final phone = phoneController.text.trim();

                          if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l.fillAllFields,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.duoRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            );
                            return;
                          }

                          await FirebaseService().addTeacher(
                            fullName: name,
                            email: email,
                            phone: phone,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'O\'qituvchi muvaffaqiyatli qo\'shildi!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.duoGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white60 : AppColors.duoTextLight,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        GamifiedCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: isDark ? const Color(0xFF131F24) : Colors.white,
          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
          borderRadius: 16,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
              border: InputBorder.none,
              icon: Icon(icon, color: isDark ? Colors.white54 : AppColors.duoTextLight, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}


class _TeacherCard extends StatefulWidget {
  final String teacherId;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final DateTime? createdAt;
  final bool isDark;
  final AppLocalizations l;
  final VoidCallback onDelete;

  const _TeacherCard({
    required this.teacherId,
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
  State<_TeacherCard> createState() => _TeacherCardState();
}

class _TeacherCardState extends State<_TeacherCard> {
  bool _isExpanded = false;
  List<Map<String, dynamic>> _assignedGroups = [];
  bool _isLoadingGroups = false;

  @override
  void initState() {
    super.initState();
    _loadAssignedGroups();
  }

  Future<void> _loadAssignedGroups() async {
    setState(() => _isLoadingGroups = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _assignedGroups = [
        {'id': 'g1', 'name': 'A1 Guruh', 'courseTitle': 'Nemis tili boshlang\'ich'},
      ];
      _isLoadingGroups = false;
    });
  }

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
                  fallbackEmoji: '👨‍🏫',
                  backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Text(
                    '${widget.l.assignedGroupsLabel.toUpperCase()}:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: widget.isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isLoadingGroups)
                const Center(child: CircularProgressIndicator())
              else if (_assignedGroups.isEmpty)
                Text(
                  widget.l.notAssignedYet,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                )
              else
                ..._assignedGroups.map((group) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.duoGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.duoGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group['name'] ?? widget.l.noData,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: widget.isDark ? Colors.white : AppColors.duoTextDark,
                                ),
                              ),
                              Text(
                                group['courseTitle'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark ? Colors.white70 : AppColors.duoTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
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