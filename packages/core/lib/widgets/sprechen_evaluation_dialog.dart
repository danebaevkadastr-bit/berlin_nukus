import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sprechen_live_evaluation.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';
import 'ai_voice_face.dart';

/// Ovozli AI suhbati yakunlangach ko'rsatiladigan interaktiv loading va natija modal ekrani.
class SprechenEvaluationDialog extends StatefulWidget {
  final String taskTitle;
  final String teilTitle;
  final int teilNumber;
  final String level;
  final Future<SprechenLiveEvaluation> evaluationFuture;
  final VoidCallback? onRetry;

  const SprechenEvaluationDialog({
    super.key,
    required this.taskTitle,
    required this.teilTitle,
    required this.teilNumber,
    required this.level,
    required this.evaluationFuture,
    this.onRetry,
  });

  static Future<void> show({
    required BuildContext context,
    required String taskTitle,
    required String teilTitle,
    required int teilNumber,
    required String level,
    required Future<SprechenLiveEvaluation> evaluationFuture,
    VoidCallback? onRetry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SprechenEvaluationDialog(
        taskTitle: taskTitle,
        teilTitle: teilTitle,
        teilNumber: teilNumber,
        level: level,
        evaluationFuture: evaluationFuture,
        onRetry: onRetry,
      ),
    );
  }

  @override
  State<SprechenEvaluationDialog> createState() => _SprechenEvaluationDialogState();
}

class _SprechenEvaluationDialogState extends State<SprechenEvaluationDialog>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  SprechenLiveEvaluation? _result;
  String? _errorMessage;

  int _stepIndex = 0;
  int _tipIndex = 0;
  Timer? _stepTimer;
  Timer? _tipTimer;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  static const List<String> _loadingSteps = [
    'Suhbat audio va matni yig\'ilmoqda...',
    'Barcha gaplar va grammatik xatolar tahlil qilinmoqda...',
    'So\'z boyligi va Redemittel iboralar tekshirilmoqda...',
    'TELC B1 imtihon mezonlari bo\'yicha ballar hisoblanmoqda...',
  ];

  static const List<String> _b1Tips = [
    'TELC B1 Maslahat: "weil", "dass", "obwohl" bog\'lovchilaridan keyin fe\'l gap oxirida keladi.',
    'TELC B1 Maslahat: Rejalashtirishda partner fikriga "Das ist eine gute Idee, aber..." deb munosabat bildiring.',
    'TELC B1 Maslahat: O\'z fikringizni bildirishda "Ich bin der Meinung, dass..." iborasi yuqori ball beradi.',
    'TELC B1 Maslahat: Tushunmay qolganda "Könntest du das bitte wiederholen?" deb so\'rang.',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _stepTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (_loading && mounted) {
        setState(() {
          _stepIndex = (_stepIndex + 1) % _loadingSteps.length;
        });
      }
    });

    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_loading && mounted) {
        setState(() {
          _tipIndex = (_tipIndex + 1) % _b1Tips.length;
        });
      }
    });

    _loadEvaluation();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _tipTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEvaluation() async {
    try {
      final res = await widget.evaluationFuture;
      if (mounted) {
        setState(() {
          _result = res;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'AI baholashda xatolik yuz berdi: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final media = MediaQuery.of(context);

    return Container(
      height: media.size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131F24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: _loading
                ? _buildEngagingLoadingView(isDark)
                : (_errorMessage != null
                    ? _buildErrorView(isDark)
                    : _buildResultView(isDark)),
          ),
        ],
      ),
    );
  }

  /// Interaktiv va zerikarsiz Loading View
  Widget _buildEngagingLoadingView(bool isDark) {
    final progress = (_stepIndex + 1) / _loadingSteps.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Animated Pulse AI Avatar
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.duoBlue.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.duoBlue.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const AiVoiceFace(
                state: AiFaceState.thinking,
                emotion: AiFaceEmotion.neutral,
                size: 140,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'TELC ${widget.level} AI Tahlili',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic step text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _loadingSteps[_stepIndex],
              key: ValueKey<int>(_stepIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.duoBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Glowing Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                color: AppColors.duoBlue,
              ),
            ),
          ),
          const Spacer(),

          // Tip card carousel at bottom
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey<int>(_tipIndex),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.duoPurple.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.duoPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _b1Tips[_tipIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.duoTextDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Natijalarni ko'rsatuvchi Gamified Result View
  Widget _buildResultView(bool isDark) {
    final res = _result!;
    final percentage = (res.score / res.maxScore * 100).round();
    final isPassed = res.score >= (res.maxScore * 0.6);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Score gauge & grade status)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPassed
                    ? [const Color(0xFF1CB0F6), const Color(0xFF58CC02)]
                    : [const Color(0xFFFF4B4B), const Color(0xFFFF9600)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isPassed ? AppColors.duoGreen : AppColors.duoRed)
                      .withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'TELC ${widget.level} SPRECHEN NATIJASI',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${res.score}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' / ${res.maxScore} ball ($percentage%)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    res.gradeLabel,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // TELC Mezonlari bo'yicha taqsimot
          if (res.criteriaScores.isNotEmpty) ...[
            Text(
              'TELC IMTIHON MEZONLARI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: res.criteriaScores.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : AppColors.duoTextLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.duoBlue,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Xatolar va To'g'rilangan shakli (Mistakes & Diffs)
          if (res.corrections.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.build_circle_rounded,
                    size: 18, color: AppColors.duoOrange),
                const SizedBox(width: 6),
                Text(
                  'XATOLAR TAHLILI VA TUZATISHLAR (${res.corrections.length} TA)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.duoOrange,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: res.corrections.map((corr) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.duoOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original xato gap
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel_rounded,
                              size: 16, color: AppColors.duoRed),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              corr.originalText,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.duoRed,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // To'g'rilangan gap
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: AppColors.duoGreen),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              corr.correctedText,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.duoGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (corr.explanation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tushuntirish: ${corr.explanation}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.duoTextDark.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Overall Feedback
          if (res.overallFeedback.isNotEmpty) ...[
            Text(
              'UMUMIY XULOSA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.duoBlue.withValues(alpha: isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                res.overallFeedback,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Strengths (Kuchli tomonlar)
          if (res.strengths.isNotEmpty) ...[
            Text(
              'KUCHLI TOMONLARINGIZ',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.duoGreen,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: res.strengths.map((str) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: AppColors.duoOrange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          str,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.duoTextDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Action buttons
          Row(
            children: [
              if (widget.onRetry != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onRetry!();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.duoBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Qayta urinish',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.duoBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duoGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tushunarli',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 54, color: AppColors.duoRed),
          const SizedBox(height: 16),
          Text(
            'Baholashda xatolik yuz berdi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.duoRed),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.duoBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Yopish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
