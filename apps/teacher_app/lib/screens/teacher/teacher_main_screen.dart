import 'package:flutter/material.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/responsive_layout.dart';
import 'package:core/widgets/bottom_nav_bar.dart';
import 'teacher_courses_screen.dart';
import 'teacher_home_screen.dart';
import 'teacher_profile_screen.dart';
import 'teacher_results_screen.dart';
import 'teacher_chat_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 0;

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
            child: ResponsiveLayout(
              mobile: Stack(
                children: [
                  IndexedStack(
                    index: _currentIndex,
                    children: const [
                      TeacherHomeScreen(),
                      TeacherCoursesScreen(),
                      TeacherResultsScreen(),
                      TeacherChatScreen(),
                      TeacherProfileScreen(),
                    ],
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
              desktop: Row(
                children: [
                  _buildSideNav(context, isDark),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: const [
                        TeacherHomeScreen(),
                        TeacherCoursesScreen(),
                        TeacherResultsScreen(),
                        TeacherChatScreen(),
                        TeacherProfileScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideNav(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context);
    return Container(
      width: 250,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Icon(Icons.school, color: AppColors.duoBlue, size: 32),
                SizedBox(width: 12),
                Text('Teacher', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.duoBlue)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSideNavItem(context, Icons.home_rounded, l.navHome, 0),
          _buildSideNavItem(context, Icons.book_rounded, l.courses, 1),
          _buildSideNavItem(context, Icons.assignment_rounded, l.myResults, 2),
          _buildSideNavItem(context, Icons.chat_bubble_outline_rounded, l.chat, 3),
          _buildSideNavItem(context, Icons.person_rounded, l.navProfile, 4),
        ],
      ),
    );
  }

  Widget _buildSideNavItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = AppColors.duoBlue;
    final inactiveColor = isDark ? Colors.white54 : AppColors.duoTextLight;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context);

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
          children: [
            Expanded(child: _buildNavItem(context, Icons.home_rounded, l.navHome, 0)),
            Expanded(child: _buildNavItem(context, Icons.book_rounded, l.courses, 1)),
            Expanded(child: _buildNavItem(context, Icons.assignment_rounded, l.myResults, 2)),
            Expanded(child: _buildNavItem(context, Icons.chat_bubble_outline_rounded, l.chat, 3)),
            Expanded(child: _buildNavItem(context, Icons.person_rounded, l.navProfile, 4)),
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

    return AnimatedNavItem(
      icon: icon,
      label: label,
      index: index,
      isActive: isActive,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      onTap: () => setState(() => _currentIndex = index),
    );
  }
}