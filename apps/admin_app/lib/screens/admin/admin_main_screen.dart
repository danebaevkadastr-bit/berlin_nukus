import 'package:flutter/material.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/responsive_layout.dart';
import 'package:core/widgets/bottom_nav_bar.dart';

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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminHomeScreen(
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const AdminStudentsScreen(),
      const AdminTeachersScreen(),
      const AdminCoursesScreen(),
      const AdminPaymentsScreen(),
      const AdminProfileScreen(),
    ];
  }

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
              desktop: Row(
                children: [
                  _buildSideNav(context, isDark),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _pages,
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
                Icon(Icons.admin_panel_settings, color: AppColors.duoBlue, size: 32),
                SizedBox(width: 12),
                Text('Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.duoBlue)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSideNavItem(context, Icons.dashboard_rounded, AppLocalizations.of(context).navHome, 0),
          _buildSideNavItem(context, Icons.people_rounded, AppLocalizations.of(context).navStudent, 1),
          _buildSideNavItem(context, Icons.school_rounded, AppLocalizations.of(context).navTeacher, 2),
          _buildSideNavItem(context, Icons.menu_book_rounded, AppLocalizations.of(context).navCourse, 3),
          _buildSideNavItem(context, Icons.payments_rounded, AppLocalizations.of(context).navPayment, 4),
          _buildSideNavItem(context, Icons.person_rounded, AppLocalizations.of(context).navProfile, 5),
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
            Expanded(child: _buildNavItem(context, Icons.dashboard_rounded, AppLocalizations.of(context).navHome, 0)),
            Expanded(child: _buildNavItem(context, Icons.people_rounded, AppLocalizations.of(context).navStudent, 1)),
            Expanded(child: _buildNavItem(context, Icons.school_rounded, AppLocalizations.of(context).navTeacher, 2)),
            Expanded(child: _buildNavItem(context, Icons.menu_book_rounded, AppLocalizations.of(context).navCourse, 3)),
            Expanded(child: _buildNavItem(context, Icons.payments_rounded, AppLocalizations.of(context).navPayment, 4)),
            Expanded(child: _buildNavItem(context, Icons.person_rounded, AppLocalizations.of(context).navProfile, 5)),
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