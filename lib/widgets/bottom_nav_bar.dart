import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36), // Pill shape
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.transparent : AppColors.duoCardGrayShadow.withValues(alpha: 0.5),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : AppColors.duoCardGrayShadow.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 0, // Solid 3D shadow for the bar
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.home_rounded, l.navHome, 0),
            _buildNavItem(context, Icons.group_rounded, l.navGroup, 1),
            _buildNavItem(context, Icons.menu_book_rounded, l.navLearning, 2),
            _buildNavItem(context, Icons.sports_esports_rounded, l.navGames, 3),
            _buildNavItem(context, Icons.person_rounded, l.navProfile, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    const activeColor = AppColors.duoBlue;
    final inactiveColor = isDark ? Colors.white54 : AppColors.duoTextLight;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: isActive ? 48 : 32,
              height: isActive ? 48 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : inactiveColor,
                size: isActive ? 28 : 24,
              ),
            ),
            if (!isActive) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
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