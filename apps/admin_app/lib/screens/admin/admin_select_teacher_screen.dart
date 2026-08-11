import 'package:flutter/material.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/widgets/user_avatar.dart';
import 'package:core/utils/user_profile_utils.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/services/firebase_service.dart';

class AdminSelectTeacherScreen extends StatefulWidget {
  const AdminSelectTeacherScreen({super.key});

  @override
  State<AdminSelectTeacherScreen> createState() => _AdminSelectTeacherScreenState();
}

class _AdminSelectTeacherScreenState extends State<AdminSelectTeacherScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          'TEACHER TANLASH',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
                  hintText: 'Qidirish...',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : AppColors.duoTextLight,
                  ),
                  border: InputBorder.none,
                  icon: const Text('🔍', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirebaseService().getTeachersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.duoBlue));
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
                          'Teacherlar topilmadi',
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
                  padding: const EdgeInsets.all(24),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final data = teachers[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GamifiedCard(
                        padding: const EdgeInsets.all(16),
                        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                        onTap: () {
                          Navigator.pop(context, {
                            'id': data['id'] ?? data['uid'],
                            'name': data['fullName'],
                            'email': data['email'],
                            'phone': data['phone'],
                          });
                        },
                        child: Row(
                          children: [
                            UserAvatar(
                              imageUrl: UserProfileUtils.avatarUrl(data),
                              size: 48,
                              fallbackEmoji: '👨‍🏫',
                              backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    UserProfileUtils.displayName(data),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.duoTextDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    data['phone'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : AppColors.duoTextLight),
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
  }
}