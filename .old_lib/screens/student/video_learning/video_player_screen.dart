import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/providers/user_provider.dart';
import '../../../l10n/locale_manager.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_button.dart';
import '../../../widgets/gamified_card.dart';
import '../../../widgets/safe_bottom_sheet.dart';
import 'video_ai_service.dart';
import 'video_data.dart';

class VideoPlayerScreen extends StatefulWidget {
  final GermanVideo video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _ytController;
  final FlutterTts _tts = FlutterTts();

  double _currentSecondsDouble = 0.0;
  int _activeSegmentIndex = 0;
  Timer? _syncTimer;

  List<VideoQuizQuestion>? _aiQuizQuestions;
  bool _isLoadingAiQuiz = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initYoutubePlayer();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.45);
  }

  void _initYoutubePlayer() {
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        strictRelatedVideos: true,
      ),
    );

    // Sinxron subtitr timerini ulash (Real-time, har 200ms da tekshiradi)
    _syncTimer = Timer.periodic(const Duration(milliseconds: 200), (t) async {
      if (!mounted) return;
      try {
        final double curTime = await _ytController.currentTime;

        setState(() {
          _currentSecondsDouble = curTime;

          for (int i = 0; i < widget.video.subtitles.length; i++) {
            final seg = widget.video.subtitles[i];
            if (curTime >= seg.startTimeSec && curTime <= seg.endTimeSec) {
              _activeSegmentIndex = i;
              break;
            }
          }
        });
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _ytController.close();
    _tts.stop();
    super.dispose();
  }

  void _speakWord(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _onWordTapped(GermanWord word) async {
    // Video pauzaga tushadi
    try {
      _ytController.pauseVideo();
    } catch (_) {}

    // Audio talaffuz
    _speakWord(word.wordDe);

    // 3D Bottom Sheet
    final isDark = ThemeManager.isDark;
    final langCode = LocaleManager.code;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isSaved = false;

        return SafeBottomSheet.scrollable(
          context: ctx,
          maxHeightFactor: 0.65,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header row (Word & Audio button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                word.wordDe,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.duoTextDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                word.translationFor(langCode),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.duoGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GamifiedButton(
                          text: '',
                          icon: Icons.volume_up_rounded,
                          width: 52,
                          height: 52,
                          color: AppColors.duoBlue,
                          shadowColor: AppColors.duoBlueShadow,
                          onPressed: () => _speakWord(word.wordDe),
                        ),
                      ],
                    ),

                    if (word.exampleDe.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote_rounded, color: AppColors.duoBlue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                word.exampleDe,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white70 : AppColors.duoTextDark,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Save to Vocabulary Button
                    GamifiedButton(
                      text: isSaved
                          ? (langCode == 'kaa' ? 'SAQLANDI' : (langCode == 'ru' ? 'СОХРАНЕНО' : 'SAQLANDI'))
                          : (langCode == 'kaa' ? 'LUG\'ATGA SAQLAW ⭐' : (langCode == 'ru' ? 'СОХРАНИТЬ В СЛОВАРЬ ⭐' : 'LUG\'ATGA SAQLASH ⭐')),
                      icon: isSaved ? Icons.check_circle_rounded : Icons.star_rounded,
                      color: isSaved ? AppColors.duoCardGray : AppColors.duoGreen,
                      shadowColor: isSaved ? AppColors.duoCardGrayShadow : AppColors.duoGreenShadow,
                      onPressed: () async {
                        if (isSaved) return;
                        if (userProvider.uid.isNotEmpty) {
                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userProvider.uid)
                                .collection('vocabulary')
                                .add({
                              'german': word.wordDe,
                              'uzbek': word.transUz,
                              'karakalpak': word.transKaa,
                              'russian': word.transRu,
                              'example': word.exampleDe,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                          } catch (_) {}
                        }
                        setModalState(() => isSaved = true);

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              langCode == 'kaa'
                                  ? 'Sózlikke saqlandı! ⭐'
                                  : (langCode == 'ru'
                                      ? 'Сохранено в словарь! ⭐'
                                      : 'Lug\'atga saqlandi! ⭐'),
                            ),
                            backgroundColor: AppColors.duoGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showQuizModal() async {
    final isDark = ThemeManager.isDark;
    final langCode = LocaleManager.code;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      _ytController.pauseVideo();
    } catch (_) {}

    // Gemini AI orqali real vaqtda savollar generatsiya qilish
    if (_aiQuizQuestions == null && !_isLoadingAiQuiz) {
      setState(() => _isLoadingAiQuiz = true);
      _aiQuizQuestions = await VideoAiService.generateQuizQuestions(
        video: widget.video,
        langCode: langCode,
      );
      setState(() => _isLoadingAiQuiz = false);
    }

    final quizList = _aiQuizQuestions ?? widget.video.quizQuestions;
    if (quizList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ushbu video uchun savollar mavjud emas.')),
      );
      return;
    }

    int questionIndex = 0;
    int? selectedOption;
    bool isAnswered = false;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeBottomSheet.scrollable(
          context: ctx,
          maxHeightFactor: 0.85,
          child: StatefulBuilder(
            builder: (context, setQuizState) {
              final q = quizList[questionIndex];
              final qText = q.getQuestion(langCode);
              final options = q.getOptions(langCode);
              final explanation = q.getExplanation(langCode);

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.duoOrange, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'AI TEKSHIRUV (QUIZ) 🤖🏆',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.duoTextDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Savol
                    Text(
                      'Savol ${questionIndex + 1} / ${quizList.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.duoBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      qText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options list
                    ...List.generate(options.length, (optIdx) {
                      final isSelected = selectedOption == optIdx;
                      final isCorrect = optIdx == q.correctAnswerIndex;

                      Color cardColor = isDark ? const Color(0xFF131F24) : AppColors.duoBackground;
                      Color borderColor = Colors.transparent;

                      if (isAnswered) {
                        if (isCorrect) {
                          cardColor = AppColors.duoGreen.withValues(alpha: 0.15);
                          borderColor = AppColors.duoGreen;
                        } else if (isSelected) {
                          cardColor = AppColors.duoRed.withValues(alpha: 0.15);
                          borderColor = AppColors.duoRed;
                        }
                      } else if (isSelected) {
                        borderColor = AppColors.duoBlue;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GamifiedCard(
                          color: cardColor,
                          shadowDepth: 2,
                          onTap: isAnswered
                              ? null
                              : () {
                                  setQuizState(() {
                                    selectedOption = optIdx;
                                    isAnswered = true;
                                  });

                                  if (optIdx == q.correctAnswerIndex && userProvider.uid.isNotEmpty) {
                                    try {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userProvider.uid)
                                          .update({'xp': FieldValue.increment(20)});
                                    } catch (_) {}
                                  }
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAnswered && isCorrect
                                        ? AppColors.duoGreen
                                        : (isAnswered && isSelected ? AppColors.duoRed : AppColors.duoBlue),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${optIdx + 1}',
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    options[optIdx],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : AppColors.duoTextDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    if (isAnswered) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.duoOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          explanation,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.duoOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GamifiedButton(
                        text: questionIndex + 1 < quizList.length ? 'KEYINGI SAVOL ➔' : 'TAMOMLASH 🏆',
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        onPressed: () {
                          if (questionIndex + 1 < quizList.length) {
                            setQuizState(() {
                              questionIndex++;
                              selectedOption = null;
                              isAnswered = false;
                            });
                          } else {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tabriklaymiz! +20 XP topshirdingiz! 🏆🔥'),
                                backgroundColor: AppColors.duoGreen,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final langCode = LocaleManager.code;
    final subtitles = widget.video.subtitles;
    final currentSegment = subtitles.isNotEmpty ? subtitles[_activeSegmentIndex] : null;

    return YoutubePlayerScaffold(
      controller: _ytController,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: isDark ? Colors.white : AppColors.duoTextDark, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.video.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.stars_rounded, color: AppColors.duoOrange),
                onPressed: _showQuizModal,
              ),
            ],
          ),
          body: Column(
            children: [
              // Live YouTube Iframe Player
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: player,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle Guide Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, color: AppColors.duoBlue, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          langCode == 'kaa'
                              ? 'SINXRON SUBTITR (Sózdi basıń):'
                              : (langCode == 'ru'
                                  ? 'ИНТЕРАКТИВНЫЙ СУБТИТР (Нажмите слово):'
                                  : 'SINXRON SUBTITR (So\'z ustidan bosing):'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.duoBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    if (_isLoadingAiQuiz)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.duoOrange),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Interactive Subtitle Word Chips Panel
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                      width: 1.5,
                    ),
                  ),
                  child: currentSegment == null
                      ? const Center(
                          child: Text(
                            'Videoni ijro etish uchun Play tugmasini bosing 🎬',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.duoTextLight),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: currentSegment.words.map((w) {
                                  return GestureDetector(
                                    onTap: () => _onWordTapped(w),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.duoBlue.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.duoBlue, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.duoBlue.withValues(alpha: 0.2),
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        w.wordDe,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : AppColors.duoTextDark,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
