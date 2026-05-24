import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
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
  bool _showStreakAnimation = false;

  @override
  void initState() {
    super.initState();
    _checkStreakAnimation();
  }

  Future<void> _checkStreakAnimation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFirstLogin = await StreakService.isFirstLoginToday(userProvider.uid);
    if (isFirstLogin) {
      setState(() {
        _showStreakAnimation = true;
      });
      await StreakService.markFirstLoginToday(userProvider.uid);
      await StreakService.recordActivity(userProvider.uid);
      // 3 soniyadan keyin animatsiyani yopish
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showStreakAnimation = false;
          });
        }
      });
    }
  }

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
                // Streak animatsiyasi
                if (_showStreakAnimation)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 100)),
                            const SizedBox(height: 20),
                            const Text(
                              'STREAK SAQLANDI!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Har kuni o\'rganishda davom eting!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class StudentHomeContent extends StatefulWidget {
  const StudentHomeContent({super.key});

  @override
  State<StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<StudentHomeContent> {
  int _currentWeekIndex = 0;

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
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(isDark);
        }

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
                    } else if (hw is Map) {
                      pendingHomeworks.add({
                        'title': hw['title'] ?? 'Vazifa',
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

        // Empty state - agar guruhlar bo'lmasa
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return _buildEmptyState(isDark);
        }

        // We removed the full screen empty state for no lessons so that the header, stats, and leaderboard still render.
        // The UI handles no lessons by showing a '😴' card.

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
              child: RefreshIndicator(
                onRefresh: () async {
                  // Refresh data
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                l.noLessonToday,
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
                              child: Dismissible(
                                key: Key(hw['title']?.toString() ?? hw.toString()),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.endToStart) {
                                    // Swipe to delete
                                    return true;
                                  } else if (direction == DismissDirection.startToEnd) {
                                    // Swipe to complete
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${hw['title']} tugatildi!'),
                                        backgroundColor: AppColors.duoGreen,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    return false; // Don't dismiss, just mark as complete
                                  }
                                  return false;
                                },
                                background: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: AppColors.duoGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  if (direction == DismissDirection.endToStart) {
                                    // Delete action
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${hw['title']} olib tashlandi'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
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
                                  l.upcomingLessons,
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

                    // ── AI Features (Chat, Translator, Bot) ──
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            icon: '💬',
                            title: 'Chat',
                            subtitle: 'AI bilan gaplashish',
                            color: AppColors.duoBlue,
                            isDark: isDark,
                            onTap: () {
                              // Chat screen navigatsiyasi
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: '🌐',
                            title: 'Tarjimon',
                            subtitle: 'Tarjima qilish',
                            color: AppColors.duoPurple,
                            isDark: isDark,
                            onTap: () {
                              // Translator screen navigatsiyasi
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: '🤖',
                            title: 'AI Bot',
                            subtitle: 'Savol-javob',
                            color: AppColors.duoGreen,
                            isDark: isDark,
                            onTap: () {
                              // AI Bot screen navigatsiyasi
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Daily Activity & Chart ──
                    FutureBuilder<Map<String, dynamic>>(
                      future: Future.wait([
                        StreakService.getCurrentStreak(userProvider.uid),
                        StreakService.getWeeklyUsageForWeek(userProvider.uid, weekOffset: _currentWeekIndex),
                        StreakService.getWeeklyDatesForWeek(weekOffset: _currentWeekIndex),
                      ]).then((values) => {
                        'streak': values[0] as int,
                        'weeklyUsage': values[1] as List<double>,
                        'weeklyDates': values[2] as List<String>,
                      }),
                      builder: (context, streakSnapshot) {
                        final streak = streakSnapshot.data?['streak'] ?? 0;
                        final weeklyUsage = streakSnapshot.data?['weeklyUsage'] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
                        final weeklyDates = streakSnapshot.data?['weeklyDates'] ?? ['1.1', '2.1', '3.1', '4.1', '5.1', '6.1', '7.1'];

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
                                      "FAOLIYAT: $streak KUN",
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _currentWeekIndex > 0
                                        ? () {
                                            setState(() {
                                              _currentWeekIndex--;
                                            });
                                          }
                                        : null,
                                    icon: Icon(Icons.chevron_left,
                                        color: _currentWeekIndex > 0
                                            ? (isDark ? Colors.white : AppColors.duoTextDark)
                                            : Colors.grey),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        for (int i = 0; i < 7; i++)
                                          _buildVerticalBarChartItem(
                                            context: context,
                                            day: weeklyDates[i],
                                            value: weeklyUsage[i],
                                            isToday: _currentWeekIndex == 0 && i == 6,
                                            isDark: isDark,
                                          )
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentWeekIndex++;
                                      });
                                    },
                                    icon: Icon(Icons.chevron_right,
                                        color: isDark ? Colors.white : AppColors.duoTextDark),
                                  ),
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
                                l.statisticsAndResults,
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
                                }),
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
    required BuildContext context,
    required String day,
    required double value,
    required bool isToday,
    required bool isDark,
  }) {
    const height = 60.0;
    // Daqiqalarni daqiqaga aylantirish (max 120 daqiqa deb olamiz)
    final minutes = value.toInt();
    final barHeight = (minutes / 120).clamp(0.0, 1.0) * height;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$day: $minutes daqiqa'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Daqiqalarni ko'rsatish
          if (minutes > 0)
            Text(
              '${minutes}d',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isToday ? AppColors.duoOrange : (isDark ? Colors.white70 : AppColors.duoTextLight),
              ),
            ),
          const SizedBox(height: 4),
          Container(
            height: height,
            width: 12,
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : AppColors.duoCardGray,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: barHeight,
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
      ),
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

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GamifiedCard(
        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState(bool isDark) {
    return NoGroupsEmptyState(
      onAction: () {
        // Navigate to games screen
        // This would require access to the parent widget's state
      },
    );
  }

  Widget _buildNoLessonsState(bool isDark) {
    return const NoLessonsEmptyState();
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SkeletonLoader(
                    width: 52,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: 150,
                        height: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      SkeletonLoader(
                        width: 100,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
              SkeletonLoader(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Today's lesson skeleton
          const SkeletonLessonCard(),
          const SizedBox(height: 20),
          // Homework skeleton
          const SkeletonCard(height: 120),
          const SizedBox(height: 20),
          // Upcoming lessons skeleton
          const SkeletonCard(height: 100),
          const SizedBox(height: 20),
          // Activity chart skeleton
          const SkeletonCard(height: 150),
          const SizedBox(height: 20),
          // Stats skeleton
          const Row(
            children: [
              Expanded(child: SkeletonStatItem()),
              SizedBox(width: 12),
              Expanded(child: SkeletonStatItem()),
            ],
          ),
          const SizedBox(height: 20),
          // Leaderboard skeleton
          const SkeletonCard(height: 200),
        ],
      ),
    );
  }
}