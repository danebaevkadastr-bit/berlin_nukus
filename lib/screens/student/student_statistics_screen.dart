import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/streak_service.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import 'student_attendance_detail_screen.dart';

class StudentStatisticsScreen extends StatefulWidget {
  const StudentStatisticsScreen({super.key});

  @override
  State<StudentStatisticsScreen> createState() => _StudentStatisticsScreenState();
}

class _StudentStatisticsScreenState extends State<StudentStatisticsScreen> {
  int _totalLessons = 0;
  int _attendedLessons = 0;
  int _totalHomeworks = 0;
  int _completedHomeworks = 0;
  double _averageHomeworkScore = 0.0;
  int _currentStreak = 0;
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.uid;

    // Get user data for stars
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();
    setState(() {
      _totalStars = userData?['totalStars'] ?? 0;
    });

    // Get streak
    final streak = await StreakService.getCurrentStreak(uid);
    setState(() {
      _currentStreak = streak;
    });

    // Get groups and calculate statistics
    final groupsSnapshot = await FirebaseService().getStudentGroupsStream(uid).first;

    int totalLessons = 0;
    int attendedLessons = 0;
    int totalHomeworks = 0;
    int completedHomeworks = 0;
    double totalHomeworkScore = 0.0;
    int scoredHomeworks = 0;

    for (final group in groupsSnapshot) {
      final lessons = group['lessons'] as Map<String, dynamic>? ?? {};

      for (final lessonEntry in lessons.entries) {
        final lesson = lessonEntry.value as Map<String, dynamic>;

        // Attendance
        final attendance = lesson['attendance'] as Map<String, dynamic>? ?? {};
        if (attendance.containsKey(uid)) {
          totalLessons++;
          if (attendance[uid] == true) {
            attendedLessons++;
          }
        }

        // Homework
        final homeworks = List<dynamic>.from(lesson['homeworks'] ?? []);
        final submissions = lesson['homeworkSubmissions'] as Map<String, dynamic>? ?? {};
        final mySubmission = submissions[uid] as Map<String, dynamic>?;

        totalHomeworks += homeworks.length;

        if (mySubmission != null && mySubmission['submitted'] == true) {
          completedHomeworks++;

          // Calculate score from test results
          final testGrades = mySubmission['testGrades'] as Map<String, dynamic>? ?? {};
          final correctCount = testGrades['correctCount'] as int? ?? 0;
          final totalCount = testGrades['totalCount'] as int? ?? 0;

          if (totalCount > 0) {
            final score = (correctCount / totalCount) * 100;
            totalHomeworkScore += score;
            scoredHomeworks++;
          }
        }
      }
    }

    setState(() {
      _totalLessons = totalLessons;
      _attendedLessons = attendedLessons;
      _totalHomeworks = totalHomeworks;
      _completedHomeworks = completedHomeworks;
      _averageHomeworkScore = scoredHomeworks > 0 ? totalHomeworkScore / scoredHomeworks : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    final attendancePercentage = _totalLessons > 0 ? (_attendedLessons / _totalLessons * 100).round() : 0;
    final homeworkCompletionRate = _totalHomeworks > 0 ? (_completedHomeworks / _totalHomeworks * 100).round() : 0;

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
          l.statisticsAndResults.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile card
            GamifiedCard(
              padding: const EdgeInsets.all(20),
              color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
              shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: userProvider.avatarUrl,
                    size: 64,
                    fallbackEmoji: '👤',
                    backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
                    borderRadius: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.duoTextDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.duoOrange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$_totalStars yulduz',
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main statistics
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentAttendanceDetailScreen(),
                      ),
                    ),
                    child: _buildStatCard(
                      icon: '📊',
                      title: l.attendance,
                      value: '$attendancePercentage%',
                      color: AppColors.duoGreen,
                      isDark: isDark,
                      tappable: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: '📝',
                    title: l.homeworkCompletion,
                    value: '$homeworkCompletionRate%',
                    color: AppColors.duoBlue,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: '⭐',
                    title: l.averageScore,
                    value: _averageHomeworkScore.toStringAsFixed(1),
                    color: AppColors.duoPurple,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: '🔥',
                    title: l.streak,
                    value: '$_currentStreak',
                    color: AppColors.duoOrange,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Detailed statistics
            _buildDetailSection(
              isDark: isDark,
              title: l.lessons,
              items: [
                {'label': l.totalLessons, 'value': '$_totalLessons'},
                {'label': l.attended, 'value': '$_attendedLessons'},
                {'label': l.notAttended, 'value': '${_totalLessons - _attendedLessons}'},
              ],
            ),

            const SizedBox(height: 16),

            _buildDetailSection(
              isDark: isDark,
              title: l.homework,
              items: [
                {'label': l.totalHomeworks, 'value': '$_totalHomeworks'},
                {'label': l.completed, 'value': '$_completedHomeworks'},
                {'label': l.notCompleted, 'value': '${_totalHomeworks - _completedHomeworks}'},
              ],
            ),

            const SizedBox(height: 16),

            _buildDetailSection(
              isDark: isDark,
              title: l.achievements,
              items: [
                {'label': l.totalStars, 'value': '$_totalStars'},
                {'label': l.currentStreak, 'value': l.streakDays(_currentStreak)},
                {'label': l.averageScore, 'value': l.scoreOutOf(_averageHomeworkScore)},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    bool tappable = false,
  }) {
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              if (tappable)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? Colors.white38 : AppColors.duoTextLight,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required bool isDark,
    required String title,
    required List<Map<String, String>> items,
  }) {
    return GamifiedCard(
      padding: const EdgeInsets.all(20),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
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
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      ),
                    ),
                    Text(
                      item['value']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
