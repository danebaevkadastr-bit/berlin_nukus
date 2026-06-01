import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/leaderboard_category.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';

/// Peshqadamlar (Leaderboard) ekrani uchun kategoriya tanlash komponenti.
///
/// TabBar yordamida uchta kategoriya o'rtasida almashish imkonini beradi:
/// - [LeaderboardCategory.stars] - Yulduzlar bo'yicha reyting
/// - [LeaderboardCategory.attendance] - Davomat bo'yicha reyting
/// - [LeaderboardCategory.averageScore] - O'rtacha ball bo'yicha reyting
///
/// Foydalanish:
/// ```dart
/// CategoryTabSelector(
///   selectedCategory: LeaderboardCategory.stars,
///   onCategoryChanged: (category) {
///     // Kategoriya o'zgarganda
///   },
/// )
/// ```
class CategoryTabSelector extends StatefulWidget {
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
  State<CategoryTabSelector> createState() => _CategoryTabSelectorState();
}

class _CategoryTabSelectorState extends State<CategoryTabSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LeaderboardCategory.values.length,
      vsync: this,
      initialIndex: widget.selectedCategory.index,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void didUpdateWidget(CategoryTabSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tashqaridan kategoriya o'zgarsa, tab controllerini yangilash
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _tabController.animateTo(widget.selectedCategory.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final newCategory = LeaderboardCategory.values[_tabController.index];
    if (newCategory != widget.selectedCategory) {
      widget.onCategoryChanged(newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeManager.cardShadow(context),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.duoBlue, AppColors.duoPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? const Color(0xFF94A3B8)
            : AppColors.duoTextDark,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⭐'),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l.stars,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📅'),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l.attendance,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📊'),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l.averageScore,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
