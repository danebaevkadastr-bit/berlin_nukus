import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import 'student_settings_screen.dart';
import '../../utils/theme_manager.dart';
import '../auth/login_screen.dart';
import '../../l10n/app_localizations.dart';
import 'student_payment_screen.dart';

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
    
    return GamifiedCard(
      padding: const EdgeInsets.all(24),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: AppColors.duoBlue,
              border: Border.all(color: AppColors.duoBlueShadow, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.duoBlueShadow,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text('🧑', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userProvider.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            userProvider.email,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.duoTextLight,
            ),
          ),
          if (userProvider.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              userProvider.phone,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.duoTextLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentsSection(UserProvider userProvider) {
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
                  'TO\'LOVLAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StudentPaymentScreen(studentId: userProvider.uid)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.duoGreen),
              label: const Text('TO\'LOV QO\'SHISH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.duoGreen)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('payments')
              .where('studentId', isEqualTo: userProvider.uid)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.duoOrange)));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return GamifiedCard(
                padding: const EdgeInsets.all(24),
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 48, color: isDark ? Colors.white30 : AppColors.duoTextLight),
                      const SizedBox(height: 12),
                      Text('To\'lov tarixi yo\'q', style: TextStyle(color: isDark ? Colors.white54 : AppColors.duoTextLight, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: docs.map((doc) {
                final p = doc.data() as Map<String, dynamic>;
                final status = p['status'] ?? 'pending';
                final periodStart = (p['periodStart'] as Timestamp?)?.toDate();
                final periodEnd = (p['periodEnd'] as Timestamp?)?.toDate();
                final note = p['note'] ?? '';
                final adminNote = p['adminNote'] ?? '';
                final type = p['type'] ?? 'card';

                Color statusColor;
                String statusText;
                IconData statusIcon;
                switch (status) {
                  case 'accepted':
                    statusColor = AppColors.duoGreen;
                    statusText = 'QABUL QILINDI';
                    statusIcon = Icons.check_circle_rounded;
                    break;
                  case 'rejected':
                    statusColor = AppColors.duoRed;
                    statusText = 'BEKOR QILINDI';
                    statusIcon = Icons.cancel_rounded;
                    break;
                  default:
                    statusColor = AppColors.duoOrange;
                    statusText = 'KUTILMOQDA';
                    statusIcon = Icons.pending_rounded;
                }

                String periodText = '';
                if (periodStart != null && periodEnd != null) {
                  periodText = '${periodStart.day}.${_pad(periodStart.month)}.${periodStart.year} – ${periodEnd.day}.${_pad(periodEnd.month)}.${periodEnd.year}';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GamifiedCard(
                    padding: const EdgeInsets.all(16),
                    color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                    shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: statusColor.withValues(alpha: 0.15)),
                          child: Icon(statusIcon, color: statusColor, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                periodText.isNotEmpty ? periodText : 'Period noma\'lum',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.duoTextDark),
                              ),
                              if (note.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(note, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.duoTextLight)),
                              ],
                              if (adminNote.isNotEmpty && status != 'pending') ...[
                                const SizedBox(height: 3),
                                Text('Admin: $adminNote', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                type == 'cash' ? 'NAQD' : 'PLASTIK',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? Colors.white38 : AppColors.duoTextLight),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: statusColor.withValues(alpha: 0.12)),
                          child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
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