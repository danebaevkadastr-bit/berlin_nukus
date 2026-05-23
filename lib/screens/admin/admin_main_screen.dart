import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';

import 'admin_courses_screen.dart';
import 'admin_home_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_students_screen.dart';
import 'admin_teachers_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeScreen(),
    const AdminStudentsScreen(),
    const AdminTeachersScreen(),
    const AdminCoursesScreen(),
    const AdminPaymentsScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, _, __) {
        final isDark = ThemeManager.isDark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          body: SafeArea(
            child: Stack(
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
                // Gamified pill-shaped bottom nav bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomNav(context, isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          color: isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.transparent
                : AppColors.duoCardGrayShadow.withValues(alpha: 0.5),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black26
                  : AppColors.duoCardGrayShadow.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.dashboard_rounded, 'Bosh', 0),
            _buildNavItem(context, Icons.people_rounded, 'O\'quvchi', 1),
            _buildNavItem(context, Icons.school_rounded, 'Ustoz', 2),
            _buildNavItem(context, Icons.menu_book_rounded, 'Kurs', 3),
            _buildNavItem(context, Icons.payments_rounded, 'To\'lov', 4),
            _buildNavItem(context, Icons.person_rounded, 'Profil', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const activeColor = AppColors.duoBlue;
    final inactiveColor = isDark ? Colors.white54 : AppColors.duoTextLight;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: isActive ? 40 : 28,
              height: isActive ? 40 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : inactiveColor,
                size: isActive ? 22 : 20,
              ),
            ),
            if (!isActive) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: inactiveColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }
}