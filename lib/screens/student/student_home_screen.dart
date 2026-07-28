import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/user_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/bn_tiyin.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/app_colors.dart';
import 'student_group_screen.dart';
import 'student_learning_screen.dart';
import 'student_games_screen.dart';
import 'student_profile_screen.dart';
import 'student_leaderboard_screen.dart';
import 'student_statistics_screen.dart';
import 'student_chat_screen.dart';
import 'translation_screen.dart';
import 'voice_ai_screen.dart';
import '../notification_screen.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firebase_service.dart';
import '../../services/streak_service.dart';
import '../../widgets/streak_screen_overlay.dart';
import '../../services/score_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/group_check_helper.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _showStreakAnimation = false;
  int _streakDays = 1;
  DateTime? _sessionStart;
  String _uid = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
    _checkStreakAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lifecycle/dispose paytida context'ga murojaat qilmaslik uchun uid'ni
    // oldindan saqlab qo'yamiz.
    _uid = Provider.of<UserProvider>(context, listen: false).uid;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // Ilova fonga o'tganda joriy sessiya daqiqalarini saqlaymiz.
      _saveSessionMinutes();
      _sessionStart = null;
    } else if (state == AppLifecycleState.resumed) {
      // Ilovaga qaytganda yangi sessiyani boshlaymiz.
      _sessionStart = DateTime.now();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveSessionMinutes();
    super.dispose();
  }

  Future<void> _saveSessionMinutes() async {
    if (_sessionStart == null || _uid.isEmpty) return;
    final minutes = DateTime.now().difference(_sessionStart!).inMinutes;
    _sessionStart = DateTime.now();
    // Faqat 2 daqiqadan ko'p bo'lsa hisob qilamiz — passive ochish hisoblanmasin
    if (minutes >= 2) {
      await StreakService.recordActivity(_uid, minutes: minutes);
    }
  }

  Future<void> _checkStreakAnimation() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Dasturga eng birinchi marta kirilganda streak ekrani chiqmasin.
    final prefs = await SharedPreferences.getInstance();
    const launchedKey = 'app_launched_before';
    final launchedBefore = prefs.getBool(launchedKey) ?? false;
    if (!launchedBefore) {
      await prefs.setBool(launchedKey, true);
      await StreakService.recordActivity(userProvider.uid, minutes: 0);
      return;
    }

    final isFirstLogin = await StreakService.isFirstLoginToday(userProvider.uid);
    if (isFirstLogin) {
      final currentStreak = await StreakService.getCurrentStreak(userProvider.uid);
      if (mounted) {
        setState(() {
          _streakDays = currentStreak > 0 ? currentStreak : 1;
          _showStreakAnimation = true;
        });
      }
      await StreakService.recordActivity(userProvider.uid, minutes: 0);
    }
  }

  void _dismissStreakAnimation() {
    if (_showStreakAnimation) {
      setState(() {
        _showStreakAnimation = false;
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
            child: ResponsiveLayout(
              mobile: Stack(
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
                    child: StreakScreenOverlay(
                      streakDays: _streakDays,
                      onDismiss: _dismissStreakAnimation,
                    ),
                  ),
              ],
            ),
            desktop: Stack(
              children: [
                Row(
                  children: [
                    _buildSideNav(context, ThemeManager.isDark),
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: [
                          const StudentHomeContent(),
                          const StudentGroupScreen(),
                          const StudentLearningScreen(),
                          StudentGamesScreen(isActive: _currentIndex == 3),
                          const StudentProfileScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
                // Streak animatsiyasi
                if (_showStreakAnimation)
                  Positioned.fill(
                    child: StreakScreenOverlay(
                      streakDays: _streakDays,
                      onDismiss: _dismissStreakAnimation,
                    ),
                  ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideNav(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context);
    return Container(
      width: 250,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Icon(Icons.school, color: AppColors.duoGreen, size: 32),
                SizedBox(width: 12),
                Text('Student', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.duoGreen)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSideNavItem(context, Icons.home_rounded, l.navHome, 0),
          _buildSideNavItem(context, Icons.group_rounded, l.navGroup, 1),
          _buildSideNavItem(context, Icons.menu_book_rounded, l.navLearning, 2),
          _buildSideNavItem(context, Icons.sports_esports_rounded, l.navGames, 3),
          _buildSideNavItem(context, Icons.person_rounded, l.navProfile, 4),
        ],
      ),
    );
  }

  Widget _buildSideNavItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = AppColors.duoGreen;
    final inactiveColor = isDark ? Colors.white54 : AppColors.duoTextLight;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentHomeContent extends StatefulWidget {
  const StudentHomeContent({super.key});

  @override
  State<StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<StudentHomeContent>
    with WidgetsBindingObserver {
  int _currentWeekIndex = 0;
  
  // Cache for weekly data to avoid full rebuild
  Map<String, dynamic>? _cachedWeeklyData;
  bool _isLoadingWeeklyData = false;

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWeeklyData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Ilovaga qaytganda statistikani yangilaymiz — fonga o'tishda saqlangan
    // sessiya daqiqalari grafikка aks etadi.
    if (state == AppLifecycleState.resumed && _currentWeekIndex == 0) {
      _loadWeeklyData();
    }
  }

  Future<void> _loadWeeklyData() async {
    if (_isLoadingWeeklyData) return;
    
    // Faqat loading flagini o'rnatamiz — eski ma'lumotni saqlaymiz
    // shunda ekran butunlay rebuild bo'lmaydi.
    _isLoadingWeeklyData = true;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      final values = await Future.wait([
        StreakService.getCurrentStreak(userProvider.uid),
        StreakService.getWeeklyUsageForWeek(userProvider.uid, weekOffset: _currentWeekIndex),
        StreakService.getWeeklyDatesForWeek(weekOffset: _currentWeekIndex),
      ]);

      if (mounted) {
        setState(() {
          _cachedWeeklyData = {
            'streak': values[0] as int,
            'weeklyUsage': values[1] as List<double>,
            'weeklyDates': values[2] as List<String>,
          };
          _isLoadingWeeklyData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeeklyData = false;
        });
      }
    }
  }

  void _changeWeek(int delta) {
    _currentWeekIndex += delta;
    _loadWeeklyData();
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

        // Xatolik yoki ma'lumot yo'q bo'lsa ham ekran qulamasin —
        // bo'sh ro'yxat bilan davom etamiz (statistika 0 ko'rsatadi).
        final groups = snapshot.data ?? const <Map<String, dynamic>>[];

        List<Map<String, dynamic>> pendingHomeworks = [];
        List<Map<String, dynamic>> upcomingLessons = [];
        Map<String, dynamic>? todayLesson;
        String? todayGroupTitle;
        String? todayTeacher;

        if (groups.isNotEmpty) {
          final todayKey = _formatDateKey(DateTime.now());

          for (final data in groups) {
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
                        'title': hw['title'] ?? l.task,
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
                  'topic': lData['topic'] ?? l.lesson,
                  'groupName': data['name'],
                  'teacherName': data['teacherName'],
                });
              }
            }
          }
        }

        // Empty state - agar guruhlar bo'lmasa (Vaqtincha o'chirib turildi)
        /*
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return _buildEmptyState(isDark);
        }
        */

        // ── Real statistika hisoblash ──
        final uid = userProvider.uid;
        int totalLessons = 0;
        int attendedLessons = 0;

        for (final data in groups) {
          final lessonsMap = data['lessons'] as Map<String, dynamic>? ?? {};
          for (final lessonEntry in lessonsMap.entries) {
            final lesson = lessonEntry.value as Map<String, dynamic>;
            // Davomat
            final attendance = lesson['attendance'] as Map<String, dynamic>? ?? {};
            if (attendance.containsKey(uid)) {
              totalLessons++;
              if (attendance[uid] == true) attendedLessons++;
            }
          }
        }

        final attendancePercent = totalLessons > 0
            ? '${(attendedLessons / totalLessons * 100).round()}%'
            : '--';

        // O'rtacha ball — ScoreService orqali hisoblanadi va FutureBuilder da ko'rsatiladi

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
                        child: UserAvatar(
                          imageUrl: userProvider.avatarUrl,
                          size: 48,
                          borderRadius: 16,
                          fallbackEmoji: '🧑‍🎓',
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.hello}, ${userProvider.name}!',
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
                            color: isDark ? Colors.white : AppColors.duoTextDark, size: 28),
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

            // Asosiy scroll
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Haqiqiy ma'lumotlarni yangilash
                  await userProvider.loadUserData();
                  await _loadWeeklyData();
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
                                _buildDarsInfo(Icons.access_time_rounded, todayLesson['time'] ?? l.unknown),
                                _buildDarsInfo(Icons.school_rounded, todayLesson['room'] ?? l.unknown),
                                _buildDarsInfo(Icons.person_rounded, todayTeacher ?? l.teacherBadge),
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
                              Icon(Icons.bedtime_rounded, size: 40, color: isDark ? Colors.white70 : AppColors.duoTextLight),
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
                                  child: const Icon(
                                    Icons.assignment_rounded,
                                    size: 28,
                                    color: Colors.white,
                                  ),
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
                                        l.homeworkTasksCount(pendingHomeworks.length),
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
                                    final messenger = ScaffoldMessenger.of(context);
                                    final title = hw['title'] as String? ?? '';
                                    final doneText = l.homeworkMarkedDone(title);
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    if (!mounted) return false;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(doneText),
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
                                        content: Text(l.homeworkUnmarked(hw['title'] as String? ?? '')),
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
                                              hw['title'] ?? l.task,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              hw['groupName'] ?? l.navGroup,
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
                                Icon(Icons.calendar_today_rounded, size: 24, color: isDark ? Colors.white : AppColors.duoTextDark),
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
                                            lesson['topic'] ?? l.lesson,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : AppColors.duoTextDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lesson['groupName'] ?? l.navGroup,
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
                            icon: Icons.chat_bubble_rounded,
                            title: l.chat,
                            subtitle: l.groupChat,
                            color: AppColors.duoBlue,
                            isDark: isDark,
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final groups = await FirebaseService().getStudentGroupsStream(userProvider.uid).first;
                                if (groups.isEmpty) {
                                  if (context.mounted) GroupCheckHelper.checkAndWarn(context);
                                } else {
                                  navigator.push(
                                    MaterialPageRoute(
                                      builder: (_) => StudentChatScreen(
                                        groupId: groups.first['id'],
                                        groupName: groups.first['name'],
                                      ),
                                    ),
                                  );
                                }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.translate_rounded,
                            title: l.translator,
                            subtitle: l.translateAction,
                            color: AppColors.duoPurple,
                            isDark: isDark,
                            onTap: () async {
                              final allowed = await GroupCheckHelper.checkAndWarn(context);
                              if (!allowed || !context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TranslationScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.smart_toy_rounded,
                            title: l.aiBot,
                            subtitle: l.qaSubtitle,
                            color: AppColors.duoGreen,
                            isDark: isDark,
                            onTap: () async {
                              final allowed = await GroupCheckHelper.checkAndWarn(context);
                              if (!allowed || !context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VoiceAiScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Daily Activity & Chart ──
                    GamifiedCard(
                      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
                      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                      padding: const EdgeInsets.all(20),
                      child: _cachedWeeklyData == null
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 24,
                                      color: AppColors.duoOrange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.activityStreakDays(_cachedWeeklyData!['streak'] ?? 0),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: isDark ? Colors.white : AppColors.duoTextDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _currentWeekIndex == 0 
                                                ? l.thisWeek 
                                                : l.weeksAgo(_currentWeekIndex),
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
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left arrow button - go to past
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: _isLoadingWeeklyData ? null : () => _changeWeek(1),
                                        icon: Icon(
                                          Icons.chevron_left,
                                          size: 20,
                                          color: _isLoadingWeeklyData 
                                              ? Colors.grey 
                                              : (isDark ? Colors.white : AppColors.duoTextDark),
                                        ),
                                      ),
                                    ),
                                    // Chart area - expanded
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: _isLoadingWeeklyData
                                            ? const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              )
                                            : Builder(
                                                builder: (context) {
                                                  final usage = _cachedWeeklyData!['weeklyUsage'] as List<double>;
                                                  final dates = _cachedWeeklyData!['weeklyDates'] as List<String>;
                                                  double maxVal = 0;
                                                  for (final v in usage) {
                                                    if (v > maxVal) maxVal = v;
                                                  }
                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      for (int i = 0; i < 7; i++)
                                                        _buildVerticalBarChartItem(
                                                          context: context,
                                                          day: dates[i],
                                                          value: usage[i],
                                                          maxValue: maxVal,
                                                          isToday: _currentWeekIndex == 0 && i == 6,
                                                          isDark: isDark,
                                                        )
                                                    ],
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                    // Right arrow button - go to future (disabled if current week)
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: (_currentWeekIndex > 0 && !_isLoadingWeeklyData)
                                            ? () => _changeWeek(-1)
                                            : null,
                                        icon: Icon(
                                          Icons.chevron_right,
                                          size: 20,
                                          color: (_currentWeekIndex > 0 && !_isLoadingWeeklyData)
                                              ? (isDark ? Colors.white : AppColors.duoTextDark)
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Weekly summary
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.duoBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.duoBlue.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildWeeklyStat(
                                        icon: Icons.bar_chart_rounded,
                                        iconColor: AppColors.duoBlue,
                                        label: l.totalTime,
                                        value: l.minutesShort(
                                          (_cachedWeeklyData!['weeklyUsage'] as List<double>)
                                              .fold<double>(0, (sum, val) => sum + val)
                                              .toInt(),
                                        ),
                                        isDark: isDark,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: isDark ? Colors.white12 : Colors.black12,
                                      ),
                                      _buildWeeklyStat(
                                        icon: Icons.calendar_today_rounded,
                                        iconColor: AppColors.duoGreen,
                                        label: l.activeDays,
                                        value: (_cachedWeeklyData!['weeklyUsage'] as List<double>)
                                            .where((val) => val > 0)
                                            .length
                                            .toString(),
                                        isDark: isDark,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: isDark ? Colors.white12 : Colors.black12,
                                      ),
                                      _buildWeeklyStat(
                                        icon: Icons.timer_rounded,
                                        iconColor: AppColors.duoPurple,
                                        label: l.average,
                                        value: l.minutesShort(
                                          ((_cachedWeeklyData!['weeklyUsage'] as List<double>)
                                                  .fold<double>(0, (sum, val) => sum + val) /
                                              7)
                                              .round(),
                                        ),
                                        isDark: isDark,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 20),

                    // ── Statistika va Natijalar ──
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentStatisticsScreen(),
                          ),
                        );
                      },
                      child: GamifiedCard(
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
                                    const Icon(
                                      Icons.bar_chart_rounded,
                                      size: 24,
                                      color: AppColors.duoBlue,
                                    ),
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
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    icon: Icons.my_location_rounded,
                                    title: l.attendance,
                                    value: attendancePercent,
                                    color: AppColors.duoGreen,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FutureBuilder<double?>(
                                    future: ScoreService.computeScore(userProvider.uid, snapshot.data ?? []),
                                    builder: (context, scoreSnap) {
                                      final val = scoreSnap.data;
                                      final display = val != null
                                          ? val.toStringAsFixed(1)
                                          : '--';
                                      // Sync to Firestore in background
                                      if (val != null && snapshot.data != null) {
                                        ScoreService.syncScoreToFirestore(
                                          userProvider.uid,
                                          snapshot.data!,
                                        );
                                      }
                                      return _buildStatItem(
                                        icon: Icons.school_rounded,
                                        title: l.averageScore,
                                        value: display,
                                        color: AppColors.duoPurple,
                                        isDark: isDark,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Peshqadamlar jadvali ──
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: groups.isNotEmpty
                          ? FirebaseService().getGroupLeaderboardStream(groups.first['id'])
                          : Stream.value([]),
                      builder: (context, leaderboardSnapshot) {
                        // Debug: Ma'lumotlarni tekshirish
                        if (kDebugMode) {
                          if (groups.isNotEmpty) {
                          }
                          if (leaderboardSnapshot.hasError) {
                          }
                        }
                        
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
                                      const Icon(
                                        Icons.emoji_events_rounded,
                                        size: 24,
                                        color: AppColors.duoOrange,
                                      ),
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
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const StudentLeaderboardScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      l.viewAll.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.duoBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (leaderboard.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text(
                                      l.noDataYet,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...leaderboard.take(3).toList().asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final user = entry.value;
                                  final rankIcon = index == 0 ? Icons.emoji_events_rounded : index == 1 ? Icons.military_tech_rounded : Icons.emoji_events_rounded;
                                  final rankColor = index == 0 ? AppColors.duoOrange : index == 1 ? Colors.grey : AppColors.duoOrange.withValues(alpha: 0.7);
                                  final name = user['fullName'] ?? user['name'] ?? l.unknown;
                                  final stars = user['totalStars'] ?? 0;
                                  final isMe = user['id'] == userProvider.uid;
                                  
                                  return Column(
                                    children: [
                                      _buildLeaderItem(
                                        context,
                                        rank: rankIcon,
                                        rankColor: rankColor,
                                        name: name,
                                        xp: '$stars',
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

  Widget _buildDarsInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white),
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

  Widget _buildWeeklyStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : AppColors.duoTextLight,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalBarChartItem({
    required BuildContext context,
    required String day,
    required double value,
    required double maxValue,
    required bool isToday,
    required bool isDark,
  }) {
    const height = 120.0;
    final minutes = value.toInt();
    // Barlar hafta ichidagi eng katta qiymatga nisbatan chiziladi — shunda
    // kichik qiymatlar ham ko'rinadi. value > 0 bo'lsa kamida 12px ko'rinadi.
    final ratio = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final barHeight = minutes > 0 ? (ratio * height).clamp(12.0, height) : 0.0;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (minutes > 0) {
            final snackL = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.bar_chart_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        snackL.dayMinutes(day, minutes),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.duoBlue,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show minutes above the bar
            SizedBox(
              height: 18,
              child: minutes > 0
                  ? Text(
                      '${minutes}d',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isToday ? AppColors.duoOrange : (isDark ? Colors.white70 : AppColors.duoTextLight),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 4),
            // Bar container
            Container(
              height: height,
              width: 26,
              decoration: BoxDecoration(
                // Toza (blur/glowsiz) fon "track".
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.duoCardGray.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(13),
              ),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                height: barHeight,
                width: 26,
                decoration: BoxDecoration(
                  // Toza, to'liq rangli bar (shaffof gradientsiz — xira emas).
                  color: isToday ? AppColors.duoOrange : AppColors.duoBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Day label
            Text(
              day,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                color: isToday
                    ? AppColors.duoOrange
                    : (isDark ? Colors.white54 : AppColors.duoTextLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
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
              Icon(icon, size: 18, color: color),
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
    required IconData icon,
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
            Icon(
              icon,
              size: 32,
              color: color,
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
    required IconData rank,
    required Color rankColor,
    required String name,
    required String xp,
    required bool isMe,
  }) {
    final isDark = ThemeManager.isDark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isMe ? AppColors.duoOrange.withValues(alpha: 0.1) : Colors.transparent,
        border: isMe ? Border.all(color: AppColors.duoOrange, width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(rank, size: 22, color: rankColor),
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
          Row(
            children: [
              const BnTiyin(size: 16),
              const SizedBox(width: 4),
              Text(
                xp,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isMe ? AppColors.duoOrange : (isDark ? Colors.white70 : AppColors.duoTextLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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