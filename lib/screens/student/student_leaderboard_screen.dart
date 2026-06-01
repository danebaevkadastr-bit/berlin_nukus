import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../models/leaderboard_category.dart';
import '../../services/firebase_service.dart';
import '../../widgets/category_tab_selector.dart';
import '../../widgets/gamified_button.dart';
import '../../widgets/leaderboard_list_item.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';

/// Peshqadamlar (Leaderboard) ekrani
///
/// Foydalanuvchilarga turli mezonlar bo'yicha reytingni ko'rish imkonini beradi:
/// - Yulduzlar bo'yicha
/// - Davomat bo'yicha
/// - O'rtacha ball bo'yicha
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 3.1, 4.1, 6.1, 6.3
class StudentLeaderboardScreen extends StatefulWidget {
  const StudentLeaderboardScreen({super.key});

  @override
  State<StudentLeaderboardScreen> createState() => _StudentLeaderboardScreenState();
}

class _StudentLeaderboardScreenState extends State<StudentLeaderboardScreen> {
  /// Tanlangan kategoriya (sukut bo'yicha Yulduzlar)
  /// Requirements: 1.4
  LeaderboardCategory _selectedCategory = LeaderboardCategory.stars;

  /// Kategoriyaga qarab tegishli stream qaytaradi
  /// Requirements: 2.1, 3.1, 4.1
  Stream<List<Map<String, dynamic>>> _getStreamForCategory(LeaderboardCategory category) {
    final firebaseService = FirebaseService();
    switch (category) {
      case LeaderboardCategory.stars:
        return firebaseService.getLeaderboardStream();
      case LeaderboardCategory.attendance:
        return firebaseService.getAttendanceLeaderboardStream();
      case LeaderboardCategory.averageScore:
        return firebaseService.getAverageScoreLeaderboardStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
      body: Column(
        children: [
          // CategoryTabSelector - AppBar ostida
          // Requirements: 1.1, 1.2, 1.3, 1.4
          CategoryTabSelector(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          // Leaderboard ro'yxati
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                key: ValueKey(_selectedCategory),
                stream: _getStreamForCategory(_selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    // Task 9.2: Check if error is network-related
                    // Requirements: 7.2
                    final error = snapshot.error;
                    final bool isNetworkError = error is SocketException ||
                        error.toString().contains('network') ||
                        error.toString().contains('internet') ||
                        error.toString().contains('connection') ||
                        error.toString().contains('SocketException') ||
                        error.toString().contains('Failed host lookup');
                    
                    // Task 9.1: Error state UI
                    // Requirements: 7.1, 7.3
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Warning icon (64px)
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 64,
                              color: isDark ? Colors.white54 : AppColors.duoTextLight,
                            ),
                            const SizedBox(height: 16),
                            // Error message (16px, w600)
                            // Task 9.2: Network error shows l.checkInternet
                            Text(
                              isNetworkError ? l.checkInternet : l.errorOccurred,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : AppColors.duoTextLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            // Retry button (GamifiedButton)
                            // Requirements: 7.3
                            SizedBox(
                              width: 200,
                              child: GamifiedButton(
                                text: l.retryButton,
                                icon: Icons.refresh_rounded,
                                onPressed: () {
                                  // Trigger rebuild by calling setState
                                  setState(() {});
                                },
                                color: AppColors.duoBlue,
                                shadowColor: AppColors.duoBlueShadow,
                                height: 48,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final leaderboard = snapshot.data ?? [];

                  if (leaderboard.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 64,
                            color: isDark ? Colors.white54 : AppColors.duoTextLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.noDataYet,
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

                  // LeaderboardListItem bilan ro'yxat
                  // Requirements: 2.2, 3.2, 4.2
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final user = leaderboard[index];
                      final isMe = user['id'] == userProvider.uid;
                      final rank = index + 1;

                      return LeaderboardListItem(
                        user: user,
                        rank: rank,
                        isCurrentUser: isMe,
                        category: _selectedCategory,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
