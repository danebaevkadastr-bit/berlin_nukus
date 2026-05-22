import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import 'student_group_screen.dart';
import 'student_learning_screen.dart';
import 'student_games_screen.dart';
import 'student_profile_screen.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firebase_service.dart';
import '../../services/streak_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: ThemeManager.isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          body: SafeArea(
            child: Stack(
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: [
                    const StudentHomeContent(),
                    const StudentGroupScreen(),
                    const StudentLearningScreen(),
                    StudentGamesScreen(isActive: _currentIndex == 3),
                    const StudentProfileScreen(),
                  ],
                ),
                // Pastki navigatsiya
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomNavBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService().getStudentGroupsStream(userProvider.uid),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> pendingHomeworks = [];
        List<Map<String, dynamic>> upcomingLessons = [];
        Map<String, dynamic>? todayLesson;
        String? todayGroupTitle;
        String? todayTeacher;

        if (snapshot.hasData) {
          final todayKey = _formatDateKey(DateTime.now());

          for (final data in snapshot.data!) {
            final lessonsMap = data['lessons'] as Map<String, dynamic>? ?? {};

            // Check today's lesson
            if (lessonsMap.containsKey(todayKey)) {
              if (todayLesson == null) { // Faqat birinchi topilgan darsni ko'rsatamiz
                todayLesson = lessonsMap[todayKey] as Map<String, dynamic>;
                todayGroupTitle = data['name'];
                todayTeacher = data['teacherName'];
              }
            }

            // Check pending homeworks (for past or today's lessons)
            lessonsMap.forEach((date, lDataMap) {
              final lData = lDataMap as Map<String, dynamic>;
              final homeworks = List<dynamic>.from(lData['homeworks'] ?? []);
              if (homeworks.isNotEmpty) {
                final subs = lData['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
                final mySub = subs[userProvider.uid] as Map<String, dynamic>?;
                if (mySub == null || mySub['submitted'] != true) {
                  // Har bir vazifa uchun ma'lumotni saqlash
                  for (final hw in homeworks) {
                    if (hw is String) {
                      pendingHomeworks.add({
                        'title': hw,
                        'groupName': data['name'],
                        'date': date,
                        'deadline': lData['homeworkDeadline'] ?? date,
                      });
                    }
                  }
                }
              }
            });

            // Keyingi darslarni hisoblash (bugundan keyingi 2 ta)
            final lessonDates = lessonsMap.keys.toList()..sort();
            for (final date in lessonDates) {
              if (date != todayKey && upcomingLessons.length < 2) {
                final lData = lessonsMap[date] as Map<String, dynamic>;
                upcomingLessons.add({
                  'date': date,
                  'topic': lData['topic'] ?? 'Dars',
                  'groupName': data['name'],
                  'teacherName': data['teacherName'],
                });
              }
            }
          }
        }

        return Column(
          children: [
            // Header
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
                          color: AppColors.duoBlue,
                          border: Border.all(color: AppColors.duoBlueShadow, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.duoBlueShadow,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🧑', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.hello}, ${userProvider.name}! 👋',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.duoTextDark,
                            ),
                          ),
                          Text(
                            l.readyToLearn,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.duoTextLight,
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
                    color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                    shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                    shadowDepth: 4,
                    child: Stack(
                      children: [
                        Icon(Icons.notifications_rounded,
                            color: isDark ? Colors.white : AppColors.duoTextDark, size: 28),
                        Positioned(
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Asosiy scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Bugungi dars ──
                    if (todayLesson != null)
                      GamifiedCard(
                        color: AppColors.duoBlue,
                        shadowColor: AppColors.duoBlueShadow,
                        shadowDepth: 6,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${DateTime.now().day}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.duoBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.todayLesson.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      if (todayGroupTitle != null)
                                        Text(
                                          todayGroupTitle,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white70,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDarsInfo('⏰', todayLesson['time'] ?? 'Noma\'lum'),
                                _buildDarsInfo('🏫', todayLesson['room'] ?? 'Noma\'lum'),
                                _buildDarsInfo('👨‍🏫', todayTeacher ?? 'Ustoz'),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      GamifiedCard(
                        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              const Text('😴', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 12),
                              Text(
                                "Bugun dars yo'q, dam oling yoki qo'shimcha mashq qiling",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white70 : AppColors.duoTextDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ── Uyga vazifalar (faqat vazifa bor bo'lsa chiqadi) ──
                    if (pendingHomeworks.isNotEmpty) ...[
                      GamifiedCard(
                        color: AppColors.duoOrange,
                        shadowColor: AppColors.duoOrangeShadow,
                        shadowDepth: 6,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text('📝', style: TextStyle(fontSize: 28)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.homework.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${pendingHomeworks.length} ta vazifa',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...pendingHomeworks.take(3).map((hw) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hw['title'] ?? 'Vazifa',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            hw['groupName'] ?? 'Guruh',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      hw['deadline'] ?? hw['date'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Keyingi darslar ──
                    if (upcomingLessons.isNotEmpty) ...[
                      GamifiedCard(
                        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
                        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('📅', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Text(
                                  'KEYINGI DARSLAR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppColors.duoTextDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...upcomingLessons.map((lesson) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white12 : AppColors.duoBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.duoBlue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        lesson['date'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.duoBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lesson['topic'] ?? 'Dars',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : AppColors.duoTextDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lesson['groupName'] ?? 'Guruh',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Daily Streak & Chart ──
                    FutureBuilder<Map<String, dynamic>>(
                      future: Future.wait([
                        StreakService.getCurrentStreak(userProvider.uid),
                        StreakService.getWeeklyUsage(userProvider.uid),
                      ]).then((values) => {
                        'streak': values[0] as int,
                        'weeklyUsage': values[1] as List<double>,
                      }),
                      builder: (context, streakSnapshot) {
                        final streak = streakSnapshot.data?['streak'] ?? 0;
                        final weeklyUsage = streakSnapshot.data?['weeklyUsage'] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
                        
                        return GamifiedCard(
                          color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
                          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "STREAK: $streak KUN",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : AppColors.duoTextDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (int i = 0; i < 7; i++)
                                    _buildVerticalBarChartItem(
                                      day: ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'][i],
                                      value: weeklyUsage[i],
                                      isToday: i == DateTime.now().weekday - 1,
                                      isDark: isDark,
                                    )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Statistika va Natijalar ──
                    GamifiedCard(
                      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
                      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('📊', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                "STATISTIKA VA NATIJALAR",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.duoTextDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  icon: '🎯',
                                  title: 'Davomat',
                                  value: '95%',
                                  color: AppColors.duoGreen,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatItem(
                                  icon: '⭐',
                                  title: 'O\'rtacha Ball',
                                  value: '8.4',
                                  color: AppColors.duoPurple,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Peshqadamlar jadvali ──
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: FirebaseService().getLeaderboardStream(),
                      builder: (context, leaderboardSnapshot) {
                        final leaderboard = leaderboardSnapshot.data ?? [];
                        
                        return GamifiedCard(
                          color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
                          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🏆', style: TextStyle(fontSize: 24)),
                                      const SizedBox(width: 8),
                                      Text(
                                        l.leaderboard.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : AppColors.duoTextDark,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (leaderboard.isEmpty)
                                Center(
                                  child: Text(
                                    'Hozircha ma\'lumot yo\'q',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                    ),
                                  ),
                                )
                              else
                                ...leaderboard.take(3).toList().asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final user = entry.value;
                                  final rankEmoji = index == 0 ? '🥇' : index == 1 ? '🥈' : '🥉';
                                  final name = user['fullName'] ?? user['name'] ?? 'Noma\'lum';
                                  final stars = user['totalStars'] ?? 0;
                                  final isMe = user['id'] == userProvider.uid;
                                  
                                  return Column(
                                    children: [
                                      _buildLeaderItem(
                                        context,
                                        rank: rankEmoji,
                                        name: name,
                                        xp: '$stars ⭐',
                                        isMe: isMe,
                                      ),
                                      if (index < 2 && index < leaderboard.length - 1) const SizedBox(height: 8),
                                    ],
                                  );
                                }).toList(),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 120), // Bottom nav bar uchun joy
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildDarsInfo(String icon, String text) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalBarChartItem({
    required String day,
    required double value,
    required bool isToday,
    required bool isDark,
  }) {
    const height = 60.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          width: 12,
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : AppColors.duoCardGray,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height * value,
            width: 12,
            decoration: BoxDecoration(
              color: isToday ? AppColors.duoOrange : AppColors.duoBlue,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
            color: isToday
                ? AppColors.duoOrange
                : (isDark ? Colors.white54 : AppColors.duoTextLight),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderItem(
    BuildContext context, {
    required String rank,
    required String name,
    required String xp,
    required bool isMe,
  }) {
    final isDark = ThemeManager.isDark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isMe ? AppColors.duoBlue.withValues(alpha: 0.1) : Colors.transparent,
        border: isMe ? Border.all(color: AppColors.duoBlue, width: 2) : null,
      ),
      child: Row(
        children: [
          Text(rank, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
          ),
          Text(
            xp,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isMe ? AppColors.duoBlue : (isDark ? Colors.white70 : AppColors.duoTextLight),
            ),
          ),
        ],
      ),
    );
  }
}