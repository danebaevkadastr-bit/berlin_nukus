import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';

class MockTestScreen extends StatelessWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          'MOCK TEST',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            GamifiedCard(
              color: AppColors.duoBlue,
              shadowColor: AppColors.duoBlueShadow,
              shadowDepth: 6,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MOCK TEST',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bilimingizni sinab ko\'ring',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _sectionTitle(isDark, 'DARAJA TANLANG'),
            const SizedBox(height: 14),

            // Level cards
            _buildLevelCard(
              context,
              isDark: isDark,
              level: 'A1',
              title: 'Boshlang\'ich',
              description: 'Oddiy so\'zlar, asosiy grammatika',
              emoji: '🌱',
              color: AppColors.duoGreen,
              shadow: AppColors.duoGreenShadow,
              questionCount: 30,
              duration: '20 daqiqa',
            ),
            const SizedBox(height: 14),

            _buildLevelCard(
              context,
              isDark: isDark,
              level: 'A2',
              title: 'Elementar',
              description: 'Kundalik suhbat, kengaytirilgan grammatika',
              emoji: '🌿',
              color: AppColors.duoBlue,
              shadow: AppColors.duoBlueShadow,
              questionCount: 40,
              duration: '25 daqiqa',
            ),
            const SizedBox(height: 14),

            _buildLevelCard(
              context,
              isDark: isDark,
              level: 'B1',
              title: 'O\'rta',
              description: 'Murakkab jumlalar, keng lug\'at',
              emoji: '🌳',
              color: AppColors.duoOrange,
              shadow: AppColors.duoOrangeShadow,
              questionCount: 50,
              duration: '35 daqiqa',
            ),
            const SizedBox(height: 14),

            _buildLevelCard(
              context,
              isDark: isDark,
              level: 'B2',
              title: 'O\'rta-yuqori',
              description: 'Ilg\'or grammatika, akademik til',
              emoji: '🏔️',
              color: AppColors.duoRed,
              shadow: AppColors.duoRedShadow,
              questionCount: 60,
              duration: '45 daqiqa',
            ),

            const SizedBox(height: 32),

            _sectionTitle(isDark, 'QANDAY ISHLAYDI'),
            const SizedBox(height: 14),

            _buildInfoCard(isDark, '1️⃣', 'Daraja tanlang',
                'O\'zingizga mos A1–B2 darajasini tanlang'),
            const SizedBox(height: 10),
            _buildInfoCard(isDark, '2️⃣', 'Savollarni javoblang',
                'Har bir savol uchun to\'g\'ri javobni belgilang'),
            const SizedBox(height: 10),
            _buildInfoCard(isDark, '3️⃣', 'Natijani ko\'ring',
                'Test yakunida batafsil tahlil va ball ko\'rsatiladi'),

            const SizedBox(height: 32),

            // Coming soon notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? AppColors.duoOrange.withValues(alpha: 0.1)
                    : AppColors.duoOrange.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.duoOrange.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('🚧', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tez kunda',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.duoOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mock test tizimi hozirda ishlab chiqilmoqda. Yaqin orada faol bo\'ladi!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: isDark
                                ? Colors.white70
                                : AppColors.duoTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(bool isDark, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white : AppColors.duoTextDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required bool isDark,
    required String level,
    required String title,
    required String description,
    required String emoji,
    required Color color,
    required Color shadow,
    required int questionCount,
    required String duration,
  }) {
    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(18),
      onTap: () => _showComingSoon(context, isDark),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: shadow, width: 2),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                level,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppColors.duoTextLight,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildChip(
                      isDark,
                      '❓ $questionCount savol',
                      color.withValues(alpha: 0.15),
                      color,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      isDark,
                      '⏱ $duration',
                      color.withValues(alpha: 0.15),
                      color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.lock_rounded,
            color: isDark ? Colors.white30 : AppColors.duoTextLight,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(bool isDark, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      bool isDark, String emoji, String title, String subtitle) {
    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF1E2A32) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚧', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text(
                'Tez kunda!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bu daraja uchun mock test hozirda tayyorlanmoqda. Yaqin orada faol bo\'ladi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GamifiedCard(
                  color: AppColors.duoBlue,
                  shadowColor: AppColors.duoBlueShadow,
                  shadowDepth: 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: () => Navigator.pop(ctx),
                  child: const Center(
                    child: Text(
                      'TUSHUNARLI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
