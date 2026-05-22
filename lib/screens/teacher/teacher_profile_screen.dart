import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/auth_navigation.dart';
import '../student/student_settings_screen.dart';
import '../../l10n/app_localizations.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.teacherProfile.toUpperCase(),
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark, letterSpacing: 1.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
        child: Column(
          children: [
            // ── Profile Card ──
            _buildProfileCard(userProvider, isDark, l),
            const SizedBox(height: 24),

            // ── Stats ──
            _buildStatsRow(l),
            const SizedBox(height: 24),

            // ── Settings ──
            _buildSettingsButton(isDark, l),
            const SizedBox(height: 16),

            // ── Logout ──
            _buildLogoutButton(l),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProvider userProvider, bool isDark, AppLocalizations l) {
    return GamifiedCard(
      padding: const EdgeInsets.all(24),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(
        children: [
          GestureDetector(
            onTap: userProvider.isLoading
                ? null
                : () async {
                    final url = await userProvider.pickAndUploadAvatar(context);
                    if (!mounted) return;
                    if (url != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil rasmi yangilandi'),
                          backgroundColor: AppColors.duoGreen,
                        ),
                      );
                    }
                  },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: AppColors.duoPurple,
                    border: Border.all(color: AppColors.duoPurpleShadow, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.duoPurpleShadow,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: userProvider.avatarUrl.isEmpty
                      ? const Center(child: Text('👨‍🏫', style: TextStyle(fontSize: 48)))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.network(
                            userProvider.avatarUrl,
                            fit: BoxFit.cover,
                            width: 88,
                            height: 88,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('👨‍🏫', style: TextStyle(fontSize: 48)),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.duoGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: userProvider.isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userProvider.name.isEmpty ? 'Ustoz' : userProvider.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            userProvider.email.isEmpty ? 'teacher@berlinnukus.uz' : userProvider.email,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.duoTextLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.duoPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              l.totalTeachers.toUpperCase(),
              style: const TextStyle(
                color: AppColors.duoPurple,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppLocalizations l) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('3', '👥', l.myGroups, AppColors.duoBlue, AppColors.duoBlueShadow),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('30', '🧑‍🎓', "O'quvchi", AppColors.duoGreen, AppColors.duoGreenShadow),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('5', '📚', "Kurslar", AppColors.duoOrange, AppColors.duoOrangeShadow),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String emoji, String label, Color color, Color shadowColor) {
    return GamifiedCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: color,
      shadowColor: shadowColor,
      shadowDepth: 5,
      borderRadius: 16,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
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

  Widget _buildSettingsButton(bool isDark, AppLocalizations l) {
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentSettingsScreen(),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.duoBlue.withValues(alpha: 0.15),
            ),
            child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.settingsTitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.settingsDesc,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.duoTextLight),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l) {
    return GamifiedCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: AppColors.duoRed,
      shadowColor: AppColors.duoRedShadow,
      shadowDepth: 5,
      onTap: () async {
        await AuthService().signOut();
        if (!mounted) return;
        AuthNavigation.replaceWithLogin(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚪', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            l.logoutLabel.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}