import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../services/firebase_service.dart';

class AdminSelectStudentScreen extends StatefulWidget {
  const AdminSelectStudentScreen({super.key});

  @override
  State<AdminSelectStudentScreen> createState() => _AdminSelectStudentScreenState();
}

class _AdminSelectStudentScreenState extends State<AdminSelectStudentScreen> {
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
          'STUDENT TANLASH',
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
                          'Studentlar topilmadi',
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final data = students[index];

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
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.duoBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(child: Text('🧑‍🎓', style: TextStyle(fontSize: 24))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['fullName'] ?? 'Noma\'lum',
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
                                  if ((data['phone'] ?? '').isNotEmpty)
                                    Text(
                                      data['phone'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : AppColors.duoTextLight,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: isDark ? Colors.white54 : AppColors.duoTextLight),
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