import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import 'student_settings_screen.dart';
import '../../utils/theme_manager.dart';
import '../../core/auth_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/student_payment_card.dart';
import 'student_payments_list_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l.navProfile.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
        child: Column(
          children: [
            // Profil kartasi
            _buildProfileCard(userProvider),
            const SizedBox(height: 24),

            // To'lovlar
            _buildPaymentsSection(userProvider),
            const SizedBox(height: 24),

            // Sozlamalar
            _buildSettingsButton(),
            const SizedBox(height: 16),

            // Chiqish
            _buildLogoutButton(userProvider),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProvider userProvider) {
    final isDark = ThemeManager.isDark;
    final cardBg = isDark ? const Color(0xFF1F2C33) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Avatar with Camera Badge
          GestureDetector(
            onTap: userProvider.isLoading
                ? null
                : () async {
                    final url = await userProvider.pickAndUploadAvatar(context);
                    if (!mounted) return;
                    if (url != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).profilePhotoUpdated),
                          backgroundColor: AppColors.duoGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.duoBlue, Color(0xFF1CB0F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.duoBlue.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: userProvider.avatarUrl.isEmpty
                      ? const Center(
                          child: Icon(Icons.person_rounded, size: 54, color: Colors.white),
                        )
                      : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userProvider.avatarUrl,
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.person_rounded, size: 54, color: Colors.white),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.duoGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1F2C33) : Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.duoGreen.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                        : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Foydalanuvchi ismi va Daraja belgilari
          Text(
            userProvider.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Role / Level pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.duoBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, size: 14, color: AppColors.duoBlue),
                const SizedBox(width: 6),
                Text(
                  userProvider.role.toLowerCase() == 'teacher'
                      ? 'O\'QITUVCHI'
                      : 'TALABA · TELC B1',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.duoBlue,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Email & Telefon ma'lumotlari kartochkalari
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 16, color: textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userProvider.email.isNotEmpty ? userProvider.email : '—',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (userProvider.phone.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(height: 1, thickness: 1),
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone_iphone_rounded, size: 16, color: textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          userProvider.phone,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection(UserProvider userProvider) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_rounded, color: AppColors.duoGreen, size: 22),
                const SizedBox(width: 8),
                Text(
                  l.payments.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentPaymentsListScreen(studentId: userProvider.uid),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l.viewAll.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.duoGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('payments')
              .where('studentId', isEqualTo: userProvider.uid)
              .snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.duoOrange),
                ),
              );
            }

            final docs = sortPaymentsByNewest(snap.data?.docs.toList() ?? []);

            if (docs.isEmpty) {
              return GamifiedCard(
                padding: const EdgeInsets.all(24),
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: isDark ? Colors.white30 : AppColors.duoTextLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'To\'lov tarixi yo\'q',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final latest = docs.first.data() as Map<String, dynamic>;
            return StudentPaymentCard(payment: latest);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsButton() {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentSettingsScreen(),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.duoBlue.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.settings_rounded, color: AppColors.duoBlue, size: 28),
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

  Widget _buildLogoutButton(UserProvider userProvider) {
    final l = AppLocalizations.of(context);
    
    return GamifiedCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: AppColors.duoRed,
      shadowColor: AppColors.duoRedShadow,
      shadowDepth: 5,
      onTap: () async {
        await userProvider.logout();
        if (!mounted) return;
        AuthNavigation.replaceWithLogin(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            l.logout.toUpperCase(),
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