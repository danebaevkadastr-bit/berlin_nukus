import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/mock_test_history_service.dart';
import '../../services/streak_service.dart';
import '../../services/student_results_service.dart';
import '../../widgets/bn_tiyin.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../utils/time_formatter.dart';
import '../../l10n/app_localizations.dart';
import 'student_attendance_detail_screen.dart';

class StudentStatisticsScreen extends StatefulWidget {
  const StudentStatisticsScreen({super.key});
  @override
  State<StudentStatisticsScreen> createState() => _StudentStatisticsScreenState();
}

class _StudentStatisticsScreenState extends State<StudentStatisticsScreen> {
  // General stats
  int _totalLessons = 0;
  int _attendedLessons = 0;
  int _totalHomeworks = 0;
  int _completedHomeworks = 0;
  double _averageHomeworkScore = 0.0;
  int _currentStreak = 0;
  int _totalStars = 0;
  int _totalMinutes = 0;
  List<double> _weeklyMinutes = List.filled(7, 0.0);
  List<String> _weeklyDates = [];

  // Test results
  List<Map<String, dynamic>> _mockHistory = [];
  List<Map<String, dynamic>> _lesenResults = [];
  List<Map<String, dynamic>> _horenResults = [];

  // Swipeable graph controller
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadStatistics(),
      _loadTestResults(),
    ]);
  }

  Future<void> _loadTestResults() async {
    final uid = Provider.of<UserProvider>(context, listen: false).uid;
    if (uid.isEmpty) return;

    final results = await Future.wait([
      MockTestHistoryService.getAll(),
      StudentResultsService.getResults(uid, type: 'lesen'),
      StudentResultsService.getResults(uid, type: 'horen'),
    ]);

    if (mounted) {
      setState(() {
        _mockHistory = (results[0]).reversed.toList();
        _lesenResults = (results[1]).reversed.toList();
        _horenResults = (results[2]).reversed.toList();
      });
    }
  }

  Future<void> _loadStatistics() async {
    final uid = Provider.of<UserProvider>(context, listen: false).uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();

    final streak = await StreakService.getCurrentStreak(uid);
    final totalMinutes = await StreakService.getTotalMinutes(uid);
    final weeklyMinutes = await StreakService.getWeeklyUsage(uid);
    final weeklyDates = await StreakService.getWeeklyDates();

    final groupsSnapshot = await FirebaseService().getStudentGroupsStream(uid).first;
    int totalLessons = 0, attendedLessons = 0, totalHomeworks = 0, completedHomeworks = 0;
    double totalHomeworkScore = 0.0;
    int scoredHomeworks = 0;

    for (final group in groupsSnapshot) {
      final lessons = group['lessons'] as Map<String, dynamic>? ?? {};
      for (final lessonEntry in lessons.entries) {
        final lesson = lessonEntry.value as Map<String, dynamic>;
        final attendance = lesson['attendance'] as Map<String, dynamic>? ?? {};
        if (attendance.containsKey(uid)) {
          totalLessons++;
          if (attendance[uid] == true) attendedLessons++;
        }
        final homeworks = List<dynamic>.from(lesson['homeworks'] ?? []);
        final submissions = lesson['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
        final mySubmission = submissions[uid] as Map<String, dynamic>?;
        totalHomeworks += homeworks.length;
        if (mySubmission != null && mySubmission['submitted'] == true) {
          completedHomeworks++;
          final testGrades = mySubmission['testGrades'] as Map<String, dynamic>? ?? {};
          final correctCount = testGrades['correctCount'] as int? ?? 0;
          final totalCount = testGrades['totalCount'] as int? ?? 0;
          if (totalCount > 0) {
            totalHomeworkScore += (correctCount / totalCount) * 100;
            scoredHomeworks++;
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _totalStars = userData?['totalStars'] ?? 0;
        _currentStreak = streak;
        _totalMinutes = totalMinutes;
        _weeklyMinutes = weeklyMinutes;
        _weeklyDates = weeklyDates;
        _totalLessons = totalLessons;
        _attendedLessons = attendedLessons;
        _totalHomeworks = totalHomeworks;
        _completedHomeworks = completedHomeworks;
        _averageHomeworkScore = scoredHomeworks > 0 ? totalHomeworkScore / scoredHomeworks : 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final attendancePct = _totalLessons > 0 ? (_attendedLessons / _totalLessons * 100).round() : 0;
    final homeworkPct = _totalHomeworks > 0 ? (_completedHomeworks / _totalHomeworks * 100).round() : 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.statisticsAndResults.toUpperCase(),
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile
            GamifiedCard(
              padding: const EdgeInsets.all(18),
              color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.08) : Colors.white,
              shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              child: Row(children: [
                UserAvatar(imageUrl: userProvider.avatarUrl, size: 56,
                    backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
                    borderRadius: 18),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(userProvider.name,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.duoTextDark)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const BnTiyin(size: 16),
                    const SizedBox(width: 4),
                    Text('$_totalStars Tiyin',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                  ]),
                ])),
              ]),
            ),

            const SizedBox(height: 16),

            // Stat cards 2x2
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const StudentAttendanceDetailScreen())),
                child: _statCard(Icons.bar_chart_rounded, l.attendance,
                    '$attendancePct%', AppColors.duoGreen, isDark, tappable: true),
              )),
              const SizedBox(width: 12),
              Expanded(child: _statCard(Icons.assignment_turned_in_rounded,
                  l.homeworkCompletion, '$homeworkPct%', AppColors.duoBlue, isDark)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _statCard(Icons.local_fire_department_rounded,
                  l.streak, '$_currentStreak', AppColors.duoOrange, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _statCard(Icons.timer_rounded,
                  l.studyTime, formatMinutes(_totalMinutes, l), AppColors.duoPurple, isDark)),
            ]),

            const SizedBox(height: 24),

            // Swipeable graphs
            _buildSwipeableGraphs(isDark, l),

            const SizedBox(height: 24),

            // Detail sections
            _buildDetailSection(isDark, l.lessons, [
              {'label': l.totalLessons, 'value': '$_totalLessons'},
              {'label': l.attended, 'value': '$_attendedLessons'},
              {'label': l.notAttended, 'value': '${_totalLessons - _attendedLessons}'},
            ]),
            const SizedBox(height: 14),
            _buildDetailSection(isDark, l.homework, [
              {'label': l.totalHomeworks, 'value': '$_totalHomeworks'},
              {'label': l.completed, 'value': '$_completedHomeworks'},
              {'label': l.notCompleted, 'value': '${_totalHomeworks - _completedHomeworks}'},
            ]),
            const SizedBox(height: 14),
            _buildDetailSection(isDark, l.achievements, [
              {'label': l.totalStars, 'value': '$_totalStars'},
              {'label': l.currentStreak, 'value': l.streakDays(_currentStreak)},
              {'label': l.averageScore, 'value': l.scoreOutOf(_averageHomeworkScore)},
            ]),
          ],
        ),
      ),
    );
  }

  // ── Swipeable graphs ────────────────────────────────────────────────────────
  Widget _buildSwipeableGraphs(bool isDark, AppLocalizations l) {
    final pages = [
      _WeeklyPage(
          weeklyMinutes: _weeklyMinutes, weeklyDates: _weeklyDates,
          isDark: isDark, l: l),
      _MockTestPage(history: _mockHistory, isDark: isDark),
      _TestResultsPage(results: _lesenResults, title: 'Lesen',
          color: AppColors.duoRed, isDark: isDark),
      _TestResultsPage(results: _horenResults, title: 'Hören',
          color: AppColors.duoGreen, isDark: isDark),
    ];
    final labels = [l.weeklyStatistics, 'Mock Test', 'Lesen', 'Hören'];

    return Column(children: [
      SizedBox(
        height: 220,
        child: PageView.builder(
          controller: _pageController,
          itemCount: pages.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (ctx, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: pages[i],
          ),
        ),
      ),
      const SizedBox(height: 10),
      // Dot indicators + label
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ...List.generate(pages.length, (i) => GestureDetector(
          onTap: () => _pageController.animateToPage(i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _currentPage ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _currentPage
                  ? AppColors.duoBlue
                  : (isDark ? Colors.white24 : AppColors.duoCardGrayShadow),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        )),
      ]),
      const SizedBox(height: 6),
      Text(labels[_currentPage],
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : AppColors.duoTextLight)),
    ]);
  }

  // ── Stat card ────────────────────────────────────────────────────────────────
  Widget _statCard(IconData icon, String title, String value,
      Color color, bool isDark, {bool tappable = false}) {
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.08) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, size: 28, color: color),
          if (tappable)
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: isDark ? Colors.white38 : AppColors.duoTextLight),
        ]),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : AppColors.duoTextLight)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  // ── Detail section ───────────────────────────────────────────────────────────
  Widget _buildDetailSection(bool isDark, String title, List<Map<String, String>> items) {
    return GamifiedCard(
      padding: const EdgeInsets.all(18),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.08) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark)),
        const SizedBox(height: 14),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(item['label']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.duoTextLight)),
            Text(item['value']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.duoTextDark)),
          ]),
        )),
      ]),
    );
  }
}

// ── Haftalik statistika grafigi ─────────────────────────────────────────────
class _WeeklyPage extends StatelessWidget {
  final List<double> weeklyMinutes;
  final List<String> weeklyDates;
  final bool isDark;
  final AppLocalizations l;
  const _WeeklyPage({required this.weeklyMinutes, required this.weeklyDates,
      required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    final maxVal = weeklyMinutes.isEmpty ? 0.0 : weeklyMinutes.reduce(math.max);
    return GamifiedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.08) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.weeklyStatistics, style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark)),
        const SizedBox(height: 12),
        if (maxVal == 0)
          Expanded(child: Center(child: Text(l.noStudyTimeRecorded,
              style: TextStyle(color: isDark ? Colors.white38 : AppColors.duoTextLight))))
        else
          Expanded(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final v = weeklyMinutes.length > i ? weeklyMinutes[i] : 0.0;
              final h = maxVal > 0 ? (v / maxVal * 90).clamp(4.0, 90.0) : 4.0;
              final day = weeklyDates.length > i ? weeklyDates[i] : '';
              return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (v > 0) Text('${v.toInt()}',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                const SizedBox(height: 3),
                Container(
                  width: 28, height: h,
                  decoration: BoxDecoration(
                    color: AppColors.duoBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(day, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : AppColors.duoTextLight)),
              ]);
            }),
          )),
      ]),
    );
  }
}

// ── Mock test natijalari grafigi ─────────────────────────────────────────────
class _MockTestPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final bool isDark;
  const _MockTestPage({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GamifiedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.08) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.fact_check_rounded, size: 16, color: AppColors.duoOrange),
          const SizedBox(width: 6),
          Text('Mock Test', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.duoTextDark)),
        ]),
        const SizedBox(height: 10),
        if (history.isEmpty)
          Expanded(child: Center(child: Text('Hali imtihon topshirilmagan',
              style: TextStyle(color: isDark ? Colors.white38 : AppColors.duoTextLight))))
        else
          Expanded(child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(history.length, (i) {
                final item = history[i];
                final total = (item['totalPoints'] as num?)?.toInt() ?? 0;
                final max = (item['totalMax'] as num?)?.toInt() ?? 300;
                final pct = max > 0 ? total / max : 0.0;
                final passed = item['writtenPassed'] == true && item['oralPassed'] == true;
                final h = (pct * 90).clamp(4.0, 90.0);
                final color = passed ? AppColors.duoGreen : AppColors.duoRed;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('${(pct * 100).round()}%',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
                    const SizedBox(height: 3),
                    Container(
                      width: 32, height: h,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${i + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight)),
                  ]),
                );
              }),
            ),
          )),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            _dot(AppColors.duoGreen), const SizedBox(width: 4),
            Text("O'tdi", style: TextStyle(fontSize: 10,
                color: isDark ? Colors.white54 : AppColors.duoTextLight)),
            const SizedBox(width: 12),
            _dot(AppColors.duoRed), const SizedBox(width: 4),
            Text("O'tmadi", style: TextStyle(fontSize: 10,
                color: isDark ? Colors.white54 : AppColors.duoTextLight)),
          ]),
        ],
      ]),
    );
  }

  Widget _dot(Color color) => Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

// ── Lesen / Hören natijalari grafigi ────────────────────────────────────────
class _TestResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String title;
  final Color color;
  final bool isDark;
  const _TestResultsPage({required this.results, required this.title,
      required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GamifiedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.08) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(title == 'Lesen' ? Icons.menu_book_rounded : Icons.headphones_rounded,
              size: 16, color: color),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.duoTextDark)),
          const SizedBox(width: 8),
          if (results.isNotEmpty)
            Text('${results.length} ta urinish',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight)),
        ]),
        const SizedBox(height: 10),
        if (results.isEmpty)
          Expanded(child: Center(child: Text('Hali test topshirilmagan',
              style: TextStyle(color: isDark ? Colors.white38 : AppColors.duoTextLight))))
        else
          Expanded(child: Column(children: [
            // Bar chart
            Expanded(child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(results.length, (i) {
                  final pct = (results[i]['percentage'] as num?)?.toInt() ?? 0;
                  final h = (pct / 100 * 90).clamp(4.0, 90.0);
                  final barColor = pct >= 70 ? AppColors.duoGreen
                      : pct >= 50 ? AppColors.duoOrange : AppColors.duoRed;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('$pct%', style: TextStyle(fontSize: 9,
                          fontWeight: FontWeight.w800, color: barColor)),
                      const SizedBox(height: 3),
                      Container(width: 28, height: h,
                          decoration: BoxDecoration(color: barColor,
                              borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 4),
                      Text('${i + 1}', style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight)),
                    ]),
                  );
                }),
              ),
            )),
            // Avg
            const SizedBox(height: 4),
            _buildAvgBar(isDark),
          ])),
      ]),
    );
  }

  Widget _buildAvgBar(bool isDark) {
    if (results.isEmpty) return const SizedBox.shrink();
    final avg = results.fold<int>(0, (s, r) =>
        s + ((r['percentage'] as num?)?.toInt() ?? 0)) ~/ results.length;
    final color = avg >= 70 ? AppColors.duoGreen : avg >= 50 ? AppColors.duoOrange : AppColors.duoRed;

    return Row(children: [
      Text("O'rtacha:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white54 : AppColors.duoTextLight)),
      const SizedBox(width: 6),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: avg / 100,
          backgroundColor: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
          color: color, minHeight: 6),
      )),
      const SizedBox(width: 6),
      Text('$avg%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    ]);
  }
}
