import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';

class StudentLeaderboardScreen extends StatelessWidget {
  const StudentLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.leaderboard.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService().getLeaderboardStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final leaderboard = snapshot.data ?? [];

          if (leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Hozircha ma\'lumot yo\'q',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final isMe = user['id'] == userProvider.uid;
              final rank = index + 1;
              String rankEmoji;
              Color rankColor;

              if (rank == 1) {
                rankEmoji = '🥇';
                rankColor = const Color(0xFFFFD700);
              } else if (rank == 2) {
                rankEmoji = '🥈';
                rankColor = const Color(0xFFC0C0C0);
              } else if (rank == 3) {
                rankEmoji = '🥉';
                rankColor = const Color(0xFFCD7F32);
              } else {
                rankEmoji = '$rank';
                rankColor = isDark ? Colors.white54 : AppColors.duoTextLight;
              }

              final name = user['fullName'] ?? user['name'] ?? 'Noma\'lum';
              final stars = user['totalStars'] ?? 0;
              final avatarUrl = user['avatarUrl'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(16),
                  color: isMe
                      ? (isDark ? AppColors.duoBlue.withValues(alpha: 0.15) : AppColors.duoBlue.withValues(alpha: 0.1))
                      : (isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white),
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  shadowDepth: isMe ? 4 : 2,
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
                        child: Center(
                          child: Text(
                            rankEmoji,
                            style: TextStyle(
                              fontSize: rank <= 3 ? 24 : 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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
                      // Name and stars
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  '$stars',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isMe ? AppColors.duoBlue : (isDark ? Colors.white70 : AppColors.duoTextLight),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Me badge
                      if (isMe)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.duoBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'SIZ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
