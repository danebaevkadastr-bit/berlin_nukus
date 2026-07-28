import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/leaderboard_category.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';
import '../services/haptic_service.dart';

/// Peshqadamlar (Leaderboard) ekrani uchun kategoriya tanlash komponenti.
///
/// Gamified 3D chip uslubidagi gorizontal scroll tab selector.
/// Har bir kategoriyaning o'z rangi, emojisi va 3D bosilish effekti bor.
///
/// Foydalanish:
/// ```dart
/// CategoryTabSelector(
///   selectedCategory: LeaderboardCategory.bnTiyin,
///   onCategoryChanged: (category) {
///     // Kategoriya o'zgarganda
///   },
/// )
/// ```
class CategoryTabSelector extends StatelessWidget {
  /// Hozirgi tanlangan kategoriya
  final LeaderboardCategory selectedCategory;

  /// Kategoriya o'zgarganda chaqiriladigan callback
  final ValueChanged<LeaderboardCategory> onCategoryChanged;

  const CategoryTabSelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    final categories = [
      _CategoryData(
        category: LeaderboardCategory.bnTiyin,
        label: l.bnTiyin,
        emoji: '⭐',
        color: AppColors.duoOrange,
        shadowColor: AppColors.duoOrangeShadow,
      ),
      _CategoryData(
        category: LeaderboardCategory.lesen,
        label: l.lesen,
        emoji: '📖',
        color: AppColors.duoGreen,
        shadowColor: AppColors.duoGreenShadow,
      ),
      _CategoryData(
        category: LeaderboardCategory.horen,
        label: l.horen,
        emoji: '🎧',
        color: AppColors.duoBlue,
        shadowColor: AppColors.duoBlueShadow,
      ),
      _CategoryData(
        category: LeaderboardCategory.mockTest,
        label: l.mockTest,
        emoji: '📝',
        color: AppColors.duoPurple,
        shadowColor: AppColors.duoPurpleShadow,
      ),
      _CategoryData(
        category: LeaderboardCategory.attendance,
        label: l.attendance,
        emoji: '📅',
        color: AppColors.duoRed,
        shadowColor: AppColors.duoRedShadow,
      ),
    ];

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final data = categories[index];
          final isSelected = selectedCategory == data.category;

          return Padding(
            padding: EdgeInsets.only(right: index < categories.length - 1 ? 8 : 0),
            child: _CategoryChip(
              data: data,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => onCategoryChanged(data.category),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryData {
  final LeaderboardCategory category;
  final String label;
  final String emoji;
  final Color color;
  final Color shadowColor;

  const _CategoryData({
    required this.category,
    required this.label,
    required this.emoji,
    required this.color,
    required this.shadowColor,
  });
}

class _CategoryChip extends StatefulWidget {
  final _CategoryData data;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.data,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  static const double _shadowDepth = 3.0;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isSelected = widget.isSelected;
    final isDark = widget.isDark;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _scaleCtrl.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _scaleCtrl.reverse();
          HapticService.lightImpact();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _scaleCtrl.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.only(top: _isPressed ? _shadowDepth : 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? data.color
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? data.shadowColor
                  : (isDark ? Colors.white12 : AppColors.duoCardGrayShadow),
              width: 2,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: isSelected
                          ? data.shadowColor
                          : (isDark
                              ? Colors.black38
                              : AppColors.duoCardGrayShadow),
                      offset: const Offset(0, _shadowDepth),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                data.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppColors.duoTextDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
