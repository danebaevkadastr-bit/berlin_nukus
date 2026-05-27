import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../notification_screen.dart';
import '../../widgets/user_avatar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('courses').snapshots(),
            builder: (context, coursesSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('groups').snapshots(),
                builder: (context, groupsSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('payments').snapshots(),
                    builder: (context, paymentsSnapshot) {
                      final users = usersSnapshot.data?.docs ?? [];
                      final studentsCount = users.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['role'] == 'student';
                      }).length;
                      final teachersCount = users.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['role'] == 'teacher';
                      }).length;
                      
                      final coursesCount = coursesSnapshot.data?.docs.length ?? 0;
                      final groupsCount = groupsSnapshot.data?.docs.length ?? 0;
                      
                      final payments = paymentsSnapshot.data?.docs ?? [];
                      final pendingPaymentsCount = payments.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['status'] == 'pending';
                      }).length;

                      return Column(
                        children: [
                          // ── Header ──
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Avatar 3D
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: AppColors.duoRed,
                                        border: Border.all(
                                            color: AppColors.duoRedShadow, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppColors.duoRedShadow,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: UserAvatar(
                                        imageUrl: userProvider.avatarUrl,
                                        size: 48,
                                        borderRadius: 16,
                                        fallbackEmoji: '👑',
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Salom, ${userProvider.name.split(' ').first}!',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    isDark ? Colors.white : AppColors.duoTextDark,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 20),
                                          ],
                                        ),
                                        Text(
                                          l.adminDashboard,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white70
                                                : AppColors.duoTextLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Bildirishnoma
                                GamifiedCard(
                                  padding: const EdgeInsets.all(10),
                                  borderRadius: 16,
                                  color: isDark
                                      ? AppColors.duoCardGray.withValues(alpha: 0.1)
                                      : Colors.white,
                                  shadowColor:
                                      isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                                  shadowDepth: 4,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const NotificationScreen(),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Icon(Icons.notifications_rounded,
                                          color:
                                              isDark ? Colors.white : AppColors.duoTextDark,
                                          size: 28),
                                      StreamBuilder<int>(
                                        stream: NotificationService().getUnreadCount(userProvider.uid),
                                        builder: (context, snapshot) {
                                          final unreadCount = snapshot.data ?? 0;
                                          if (unreadCount == 0) return const SizedBox.shrink();
                                          return Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.duoRed,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Asosiy scroll ──
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1) Statistika (2x2 Grid)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          iconData: Icons.school_rounded,
                                          title: l.totalStudents,
                                          value: '$studentsCount',
                                          color: AppColors.duoBlue,
                                          shadow: AppColors.duoBlueShadow,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          iconData: Icons.person_search_rounded,
                                          title: l.totalTeachers,
                                          value: '$teachersCount',
                                          color: AppColors.duoGreen,
                                          shadow: AppColors.duoGreenShadow,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          iconData: Icons.menu_book_rounded,
                                          title: l.courses,
                                          value: '$coursesCount',
                                          color: AppColors.duoOrange,
                                          shadow: AppColors.duoOrangeShadow,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          iconData: Icons.groups_rounded,
                                          title: l.totalGroups,
                                          value: '$groupsCount',
                                          color: AppColors.duoPurple,
                                          shadow: AppColors.duoPurpleShadow,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // 2) Tezkor harakatlar
                                  Text(
                                    l.quickAction.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.duoTextDark,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildQuickAction(
                                          iconData: Icons.person_add_rounded,
                                          title: l.addStudent,
                                          color: AppColors.duoBlue,
                                          shadow: AppColors.duoBlueShadow,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildQuickAction(
                                          iconData: Icons.supervisor_account_rounded,
                                          title: l.addTeacher,
                                          color: AppColors.duoGreen,
                                          shadow: AppColors.duoGreenShadow,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildQuickAction(
                                          iconData: Icons.auto_stories_rounded,
                                          title: l.courses,
                                          color: AppColors.duoOrange,
                                          shadow: AppColors.duoOrangeShadow,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildQuickAction(
                                          iconData: Icons.settings_rounded,
                                          title: l.groups,
                                          color: AppColors.duoPurple,
                                          shadow: AppColors.duoPurpleShadow,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // 3) So'nggi holat
                                  Text(
                                    l.recentActivity.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.duoTextDark,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildActivityCard(
                                    iconData: Icons.trending_up_rounded,
                                    title: AppLocalizations.of(context).activeGroupsLabel,
                                    subtitle: AppLocalizations.of(context).activeGroupsCountText(groupsCount),
                                    color: AppColors.duoBlue,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildActivityCard(
                                    iconData: Icons.assignment_rounded,
                                    title: AppLocalizations.of(context).newTestsLabel,
                                    subtitle: AppLocalizations.of(context).noNewTestsLabel,
                                    color: AppColors.duoGreen,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildActivityCard(
                                    iconData: Icons.account_balance_wallet_rounded,
                                    title: AppLocalizations.of(context).paymentControlLabel,
                                    subtitle: pendingPaymentsCount > 0
                                        ? AppLocalizations.of(context).pendingPaymentsCount(pendingPaymentsCount)
                                        : AppLocalizations.of(context).allPaymentsConfirmed,
                                    color: AppColors.duoOrange,
                                    isDark: isDark,
                                  ),

                                  const SizedBox(height: 120),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData iconData,
    required String title,
    required String value,
    required Color color,
    required Color shadow,
  }) {
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: color,
      shadowColor: shadow,
      shadowDepth: 5,
      borderRadius: 16,
      child: Column(
        children: [
          Icon(iconData, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData iconData,
    required String title,
    required Color color,
    required Color shadow,
  }) {
    return GamifiedCard(
      color: color,
      shadowColor: shadow,
      shadowDepth: 5,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(iconData, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData iconData,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Icon(iconData, size: 24, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
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