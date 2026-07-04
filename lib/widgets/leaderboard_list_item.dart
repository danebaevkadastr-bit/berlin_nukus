import 'package:flutter/material.dart';
import '../models/leaderboard_category.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';
import './bn_tiyin.dart';
import './gamified_card.dart';
import './siz_badge.dart';
import './user_avatar.dart';

/// Peshqadamlar ro'yxatidagi har bir o'quvchi uchun element
///
/// Rank, avatar, ism va kategoriyaga qarab qiymatni ko'rsatadi.
/// Joriy foydalanuvchi uchun SizBadge ko'rsatiladi.
///
/// Requirements: 2.2, 3.2, 4.2
class LeaderboardListItem extends StatelessWidget {
  /// O'quvchi ma'lumotlari (id, fullName, avatarUrl, totalStars, attendancePercentage, averageScore)
  final Map<String, dynamic> user;

  /// O'quvchining reytingdagi o'rni (1 dan boshlab)
  final int rank;

  /// Joriy foydalanuvchi ekanligini bildiradi
  final bool isCurrentUser;

  /// Tanlangan kategoriya (qaysi qiymatni ko'rsatishni aniqlaydi)
  final LeaderboardCategory category;

  const LeaderboardListItem({
    super.key,
    required this.user,
    required this.rank,
    required this.isCurrentUser,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    // User ma'lumotlarini olish
    final name = user['fullName'] ?? user['name'] ?? 'Noma\'lum';
    final avatarUrl = user['avatarUrl'] ?? '';

    // Rank uchun rang va ikon
    final (rankWidget, rankColor) = _buildRankWidget(rank, isDark);

    // Kategoriyaga qarab qiymat
    final valueWidget = _buildValueWidget(category, isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GamifiedCard(
        padding: const EdgeInsets.all(16),
        color: isCurrentUser
            ? (isDark
                ? Color.alphaBlend(
                    AppColors.duoOrange.withValues(alpha: 0.12),
                    const Color(0xFF131F24),
                  )
                : Color.alphaBlend(
                    AppColors.duoOrange.withValues(alpha: 0.08),
                    Colors.white,
                  ))
            : (isDark
                ? Color.alphaBlend(
                    AppColors.duoCardGray.withValues(alpha: 0.05),
                    const Color(0xFF131F24),
                  )
                : Colors.white),
        shadowColor: isDark
            ? Colors.black26
            : (isCurrentUser
                ? AppColors.duoOrangeShadow
                : AppColors.duoCardGrayShadow),
        shadowDepth: isCurrentUser ? 4 : 2,
        child: Row(
          children: [
            // Rank
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rankColor.withValues(alpha: 0.15),
              ),
              child: Center(child: rankWidget),
            ),
            const SizedBox(width: 16),
            // Avatar
            UserAvatar(
              imageUrl: avatarUrl,
              size: 48,
              fallbackEmoji: '👤',
              backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
              borderRadius: 16,
            ),
            const SizedBox(width: 16),
            // Name and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  valueWidget,
                ],
              ),
            ),
            // SIZ badge for current user
            if (isCurrentUser) const SizBadge(animate: true),
          ],
        ),
      ),
    );
  }

  /// Rank uchun widget va rang qaytaradi
  /// Rank 1, 2, 3 uchun maxsus ikonlar (🥇🥈🥉)
  (Widget, Color) _buildRankWidget(int rank, bool isDark) {
    if (rank == 1) {
      return (
        const Text('🥇', style: TextStyle(fontSize: 28)),
        const Color(0xFFFFD700), // Gold
      );
    } else if (rank == 2) {
      return (
        const Text('🥈', style: TextStyle(fontSize: 28)),
        const Color(0xFFC0C0C0), // Silver
      );
    } else if (rank == 3) {
      return (
        const Text('🥉', style: TextStyle(fontSize: 28)),
        const Color(0xFFCD7F32), // Bronze
      );
    } else {
      final rankColor = isDark ? Colors.white54 : AppColors.duoTextLight;
      return (
        Text(
          '$rank',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: rankColor,
          ),
        ),
        rankColor,
      );
    }
  }

  /// Kategoriyaga qarab qiymat widgetini qaytaradi
  /// - stars: yulduzlar soni (⭐ 150)
  /// - attendance: foiz (📅 95%)
  /// - averageScore: ball (📊 87)
  Widget _buildValueWidget(LeaderboardCategory category, bool isDark) {
    final valueColor = isCurrentUser
        ? AppColors.duoOrange
        : (isDark ? Colors.white70 : AppColors.duoTextLight);

    switch (category) {
      case LeaderboardCategory.stars:
        final stars = user['totalStars'] ?? 0;
        return Row(
          children: [
            const BnTiyin(size: 16),
            const SizedBox(width: 4),
            Text(
              '$stars',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        );

      case LeaderboardCategory.attendance:
        final attendance = (user['attendancePercentage'] ?? 0.0).toDouble();
        final attendanceFormatted = attendance.toStringAsFixed(0);
        return Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$attendanceFormatted%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        );

      case LeaderboardCategory.averageScore:
        final avgScore = user['averageScore'] ?? 0;
        return Row(
          children: [
            const Text('📊', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$avgScore',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        );
    }
  }
}
