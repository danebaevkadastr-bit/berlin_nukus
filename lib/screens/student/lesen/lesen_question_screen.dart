import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/student_results_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import 'lesen_data.dart';

class LesenQuestionScreen extends StatefulWidget {
  final LesenTeil teil;
  final String level;

  /// App bar sarlavhasi. Berilmasa "Teil {raqam}" ko'rsatiladi.
  final String? titleOverride;

  const LesenQuestionScreen({
    super.key,
    required this.teil,
    required this.level,
    this.titleOverride,
  });

  @override
  State<LesenQuestionScreen> createState() => _LesenQuestionScreenState();
}

class _LesenQuestionScreenState extends State<LesenQuestionScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<bool?> _results = [];
  final List<String?> _selectedAnswers = [];

  late final AnimationController _pulseController;

  String? get _selectedAnswer => _selectedAnswers[_currentIndex];
  bool get _answered => _results[_currentIndex] != null;

  final _scrollController = ScrollController();
  final _questionScrollController = ScrollController();

  List<LesenQuestion> get _questions => widget.teil.questions;
  LesenQuestion get _current => _questions[_currentIndex];

  // ── Multi-test helper'lar (Sprachbausteine) ───────────────────────────────
  bool get _isMultiTest => widget.teil.questionsPerTest > 0;
  int get _questionsPerTest =>
      _isMultiTest ? widget.teil.questionsPerTest : _questions.length;

  /// Joriy savol qaysi TEST guruhiga tegishli (0-indeksli).
  int get _currentTestIndex =>
      _isMultiTest ? _currentIndex ~/ _questionsPerTest : 0;

  /// Joriy savolning o'z TEST'i ichidagi tartibi (1-indeksli, ko'rsatish uchun).
  int get _indexWithinTest =>
      _isMultiTest ? (_currentIndex % _questionsPerTest) + 1 : _currentIndex + 1;

  /// Joriy savol uchun ko'rsatiladigan matn.
  String? get _currentPassage {
    final texts = widget.teil.testTexts;
    if (_isMultiTest && texts != null && _currentTestIndex < texts.length) {
      return texts[_currentTestIndex];
    }
    return widget.teil.sharedText ?? _current.passage;
  }

  /// Joriy matnda ___(N)___ bo'sh joylari bormi (Sprachbausteine).
  bool get _currentHasBlanks {
    final p = _currentPassage;
    return p != null && RegExp(r'___\((\d+)\)___').hasMatch(p);
  }

  Color get _accentColor => ThemeManager.accent;
  Color get _accentShadow => ThemeManager.accentShadow;

  /// Joriy savol uchun ko'rsatiladigan rasm (Teil 3). Avval testImages,
  /// bo'lmasa savolning o'z imageUrl'i.
  String? get _currentImage {
    final imgs = widget.teil.testImages;
    if (_isMultiTest && imgs != null && _currentTestIndex < imgs.length) {
      return imgs[_currentTestIndex];
    }
    return _current.imageUrl;
  }

  // ── SharedPreferences keys ────────────────────────────────────────────────
  String _prefKey(int index) =>
      'lesen_${widget.level}_teil${widget.teil.teilNumber}_q$index';
  String _prefAnswerKey(int index) =>
      'lesen_${widget.level}_teil${widget.teil.teilNumber}_q${index}_answer';

  @override
  void initState() {
    super.initState();
    _results.addAll(List.filled(_questions.length, null));
    _selectedAnswers.addAll(List.filled(_questions.length, null));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _loadResults();
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _questions.length; i++) {
      final val = prefs.getString(_prefKey(i));
      if (val == 'true') {
        _results[i] = true;
      } else if (val == 'false') {
        _results[i] = false;
      }
      if (_results[i] != null) {
        _selectedAnswers[i] = prefs.getString(_prefAnswerKey(i));
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveResult(int index, bool isCorrect, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey(index), isCorrect.toString());
    await prefs.setString(_prefAnswerKey(index), answer);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    _questionScrollController.dispose();
    super.dispose();
  }

  /// Kamida 1 ta javob berilgan bo'lsa — natijani Firestore'ga saqlaydi.
  /// Back tugmasi yoki dispose paytida chaqiriladi.
  Future<void> _saveIfNeeded() async {
    final answered = _results.where((r) => r != null).length;
    if (answered == 0) return; // hech narsa yechmagan bo'lsa saqlamaymiz
    await _saveToFirebase();
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) {
      return;
    }
    setState(() => _currentIndex = index);
    _scrollQuestionPickerTo(index);
    // Yangi savolga o'tganda matnni boshidan ko'rsatish
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _scrollQuestionPickerTo(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_questionScrollController.hasClients) return;
      const itemWidth = 44.0;
      final offset = (index * itemWidth).clamp(
        0.0,
        _questionScrollController.position.maxScrollExtent,
      );
      _questionScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final isCorrect = answer == _current.correctAnswer;
    setState(() {
      _selectedAnswers[_currentIndex] = answer;
      _results[_currentIndex] = isCorrect;
    });
    _saveResult(_currentIndex, isCorrect, answer);
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      _goToQuestion(_currentIndex + 1);
    } else {
      _finishAndSave();
    }
  }

  Future<void> _finishAndSave() async {
    await _saveToFirebase();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveToFirebase() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final correct = _results.where((r) => r == true).length;
      final total = _questions.length;
      await StudentResultsService.saveResult(
        uid: uid,
        type: 'lesen',
        title: widget.titleOverride ?? 'Teil ${widget.teil.teilNumber}',
        level: widget.level,
        score: correct,
        total: total,
      );
    } catch (e) {
      debugPrint('Lesen save error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final isLast = _currentIndex == _questions.length - 1;

    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, _, __) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _saveIfNeeded();
            if (context.mounted) Navigator.pop(context);
          },
          child: Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                  size: 20,
                ),
                onPressed: () async {
                  await _saveIfNeeded();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            title: Text(
              widget.titleOverride ?? 'Teil ${widget.teil.teilNumber}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 1.0,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildQuestionPicker(isDark),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageCard(isDark, l),
                      _buildTextCard(isDark, l),
                      const SizedBox(height: 16),
                      _buildQuestionCard(isDark, l),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(isDark, l, isLast),
            ],
          ),
          ),
        );
      },
    );
  }

  // ── Question picker ──────────────────────────────────────────────────────
  Widget _buildQuestionPicker(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          GamifiedCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: _accentColor,
            shadowColor: _accentShadow,
            shadowDepth: 4,
            borderRadius: 20,
            child: Text(
              // Har doim teildagi jami savol soniga nisbatan ko'rsatamiz
              // (masalan 1 / 100), Hören bilan bir xil.
              '${_currentIndex + 1} / ${_questions.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                controller: _questionScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _isMultiTest
                    ? _questions.length +
                        (_questions.length / _questionsPerTest).ceil()
                    : _questions.length,
                itemBuilder: (context, index) {
                  if (!_isMultiTest) {
                    return _buildQuestionButton(index, isDark);
                  }
                  // Har TEST guruhidan oldin "TEST n" header chiqaramiz.
                  final slot = _questionsPerTest + 1;
                  final positionInGroup = index % slot;
                  final groupIndex = index ~/ slot;
                  if (positionInGroup == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _accentColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'TEST ${groupIndex + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: _accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  }
                  final questionIndex =
                      groupIndex * _questionsPerTest + (positionInGroup - 1);
                  if (questionIndex >= _questions.length) {
                    return const SizedBox.shrink();
                  }
                  return _buildQuestionButton(questionIndex, isDark);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionButton(int i, bool isDark) {
    final selected = i == _currentIndex;
    final result = _results[i];

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (selected) {
      bgColor = _accentColor;
      borderColor = _accentShadow;
      textColor = Colors.white;
    } else if (result == true) {
      bgColor = AppColors.duoGreen.withValues(alpha: 0.2);
      borderColor = AppColors.duoGreen;
      textColor = AppColors.duoGreen;
    } else if (result == false) {
      bgColor = AppColors.duoRed.withValues(alpha: 0.2);
      borderColor = AppColors.duoRed;
      textColor = AppColors.duoRed;
    } else {
      bgColor =
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.2) : Colors.white;
      borderColor = isDark ? Colors.white24 : AppColors.duoCardGrayShadow;
      textColor = isDark ? Colors.white70 : AppColors.duoTextDark;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _goToQuestion(i),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _accentShadow,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reklama rasmi (Teil 3) ─────────────────────────────────────────────
  /// Joriy savol rasmini ko'rsatadi. Rasm doim ko'rinadi; ustiga bosilsa
  /// to'liq ekranda ochiladi va yaqinlashtirsa bo'ladi.
  Widget _buildImageCard(bool isDark, AppLocalizations l) {
    final url = _currentImage;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamifiedCard(
        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
        shadowColor: isDark ? Colors.black26 : _accentShadow,
        shadowDepth: 5,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_rounded, size: 18, color: _accentColor),
                const SizedBox(width: 8),
                Text(
                  l.lesenAnzeige.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Icon(Icons.zoom_in_rounded,
                    size: 18,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _openImageViewer(url),
              child: Hero(
                tag: url,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    placeholder: (context, _) => Container(
                      height: 220,
                      color: isDark ? Colors.white10 : AppColors.duoBackground,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _accentColor,
                      ),
                    ),
                    errorWidget: (context, _, __) => Container(
                      height: 160,
                      color: isDark ? Colors.white10 : AppColors.duoBackground,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image_rounded,
                              size: 36, color: AppColors.duoRed),
                          const SizedBox(height: 8),
                          Text(
                            l.lesenImageError,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.duoRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rasmni to'liq ekranda ochadi (yaqinlashtirib ko'rish uchun).
  void _openImageViewer(String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _ImageViewer(imageUrl: url),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  // ── Reading text ─────────────────────────────────────────────────────────
  Widget _buildTextCard(bool isDark, AppLocalizations l) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    // Teil 2 da matn umumiy (sharedText), Sprachbausteine da har TEST'ning
    // o'z matni (testTexts), boshqa Teil'larda har savolda alohida.
    final passage = _currentPassage;
    if (passage == null || passage.isEmpty) return const SizedBox.shrink();

    final baseStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.7,
    );

    // Matnda ___(N)___ belgilari bormi? Bo'lsa — interaktiv bo'sh joylar.
    final hasBlanks = RegExp(r'___\((\d+)\)___').hasMatch(passage);

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : _accentShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 18, color: _accentColor),
              const SizedBox(width: 8),
              Text(
                l.lesenText.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasBlanks)
            Text.rich(
              TextSpan(children: _buildPassageSpans(passage, baseStyle)),
              style: baseStyle,
            )
          else
            SelectableText(passage, style: baseStyle),
        ],
      ),
    );
  }

  /// Matnni ___(N)___ belgilari bo'yicha bo'lib, har bo'sh joy o'rniga
  /// interaktiv chip (WidgetSpan) qo'yadi.
  List<InlineSpan> _buildPassageSpans(String passage, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'___\((\d+)\)___');
    int last = 0;

    for (final match in regex.allMatches(passage)) {
      if (match.start > last) {
        spans.add(TextSpan(text: passage.substring(last, match.start)));
      }
      // Matndagi raqam testdagi tartib (1..N), savol indeksini hisoblaymiz.
      final blankNumWithinTest = int.parse(match.group(1)!);
      final questionIndex =
          _currentTestIndex * _questionsPerTest + (blankNumWithinTest - 1);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildInlineBlank(questionIndex, blankNumWithinTest),
        ),
      );
      last = match.end;
    }
    if (last < passage.length) {
      spans.add(TextSpan(text: passage.substring(last)));
    }
    return spans;
  }

  /// Matn ichidagi bitta bo'sh joy (raqam yoki tanlangan javob).
  Widget _buildInlineBlank(int questionIndex, int displayNumber) {
    if (questionIndex < 0 || questionIndex >= _questions.length) {
      return const SizedBox.shrink();
    }
    final isActive = questionIndex == _currentIndex;
    final result = _results[questionIndex];
    final answer = _selectedAnswers[questionIndex];
    final answered = result != null;

    Color bg;
    Color border;
    Color fg;
    if (answered && result) {
      bg = AppColors.duoGreen.withValues(alpha: 0.18);
      border = AppColors.duoGreen;
      fg = AppColors.duoGreen;
    } else if (answered && !result) {
      bg = AppColors.duoRed.withValues(alpha: 0.18);
      border = AppColors.duoRed;
      fg = AppColors.duoRed;
    } else if (isActive) {
      bg = _accentColor.withValues(alpha: 0.18);
      border = _accentColor;
      fg = _accentColor;
    } else {
      bg = _accentColor.withValues(alpha: 0.06);
      border = _accentColor.withValues(alpha: 0.4);
      fg = _accentColor;
    }

    // Bo'sh joyda nima ko'rsatiladi: javob berilgan bo'lsa — tanlangan so'z,
    // aks holda — raqam.
    final label = answered && answer != null ? answer : '$displayNumber';

    final chip = GestureDetector(
      onTap: () => _goToQuestion(questionIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: answered ? 14 : 13,
            fontWeight: FontWeight.w800,
            color: fg,
            height: 1.1,
          ),
        ),
      ),
    );

    // Joriy (faol) va hali javob berilmagan bo'sh joy yonib turadi.
    if (isActive && !answered) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.08).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        ),
        child: chip,
      );
    }
    return chip;
  }

  // ── Question + answers ───────────────────────────────────────────────────
  /// Teil 3 — javoblar bitta harf (a–l, x). Shu holatda ixcham harf-katak
  /// ko'rinishi ishlatiladi.
  bool get _isLetterChoice =>
      _current.options.isNotEmpty &&
      _current.options.every((o) => o.length == 1);

  /// Teil 3 uchun ixcham harf-katak (a, b, c ... x) tanlovi.
  Widget _buildLetterGrid(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _current.options.map((option) {
        final isCorrectOption = option == _current.correctAnswer;
        final isSelected = _selectedAnswer == option;
        final isCorrectResult = _answered && isCorrectOption;
        final isWrongResult = _answered && isSelected && !isCorrectOption;

        Color bg;
        Color border;
        Color fg;
        if (isCorrectResult) {
          bg = AppColors.duoGreen.withValues(alpha: isDark ? 0.2 : 0.1);
          border = AppColors.duoGreen;
          fg = AppColors.duoGreen;
        } else if (isWrongResult) {
          bg = AppColors.duoRed.withValues(alpha: isDark ? 0.2 : 0.1);
          border = AppColors.duoRed;
          fg = AppColors.duoRed;
        } else if (isSelected) {
          bg = _accentColor.withValues(alpha: isDark ? 0.2 : 0.1);
          border = _accentColor;
          fg = _accentColor;
        } else {
          bg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
          border = isDark ? Colors.white12 : _accentColor.withValues(alpha: 0.25);
          fg = isDark ? Colors.white : AppColors.duoTextDark;
        }

        // "x" — mos reklama yo'q
        final isX = option == 'x';

        return GestureDetector(
          onTap: _answered ? null : () => _selectAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isX ? null : 48,
            height: 48,
            padding: isX
                ? const EdgeInsets.symmetric(horizontal: 16)
                : EdgeInsets.zero,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 2),
            ),
            child: Text(
              isX ? '✕' : option,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCard(bool isDark, AppLocalizations l) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    // Faqat rasm bo'lgan savol (Teil 3, savol matni hali yo'q) — savol
    // kartasini ko'rsatmaymiz.
    if (_current.prompt.isEmpty && _current.options.isEmpty) {
      return const SizedBox.shrink();
    }

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : _accentShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentHasBlanks
                ? '$_indexWithinTest'
                : '${l.lesenQuestion} ${_isMultiTest ? _indexWithinTest : _currentIndex + 1}',
            style: TextStyle(
              fontSize: _currentHasBlanks ? 15 : 12,
              fontWeight: FontWeight.w900,
              color: _currentHasBlanks ? _accentColor : textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          if (!_currentHasBlanks) ...[
            const SizedBox(height: 10),
            Text(
              _current.prompt,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (_isLetterChoice)
            _buildLetterGrid(isDark)
          else
            ...List.generate(_current.options.length, (i) {
            final option = _current.options[i];
            final label = String.fromCharCode(97 + i); // a, b, c ...
            final isCorrectOption = option == _current.correctAnswer;
            final isSelected = _selectedAnswer == option;
            final isCorrectResult = _answered && isCorrectOption;
            final isWrongResult = _answered && isSelected && !isCorrectOption;

            Color cardColor;
            Color borderColor;
            Color labelBg;
            Color labelText;
            Color optionText;

            if (isCorrectResult) {
              cardColor =
                  AppColors.duoGreen.withValues(alpha: isDark ? 0.15 : 0.08);
              borderColor = AppColors.duoGreen;
              labelBg = AppColors.duoGreen;
              labelText = Colors.white;
              optionText = AppColors.duoGreen;
            } else if (isWrongResult) {
              cardColor =
                  AppColors.duoRed.withValues(alpha: isDark ? 0.15 : 0.08);
              borderColor = AppColors.duoRed;
              labelBg = AppColors.duoRed;
              labelText = Colors.white;
              optionText = AppColors.duoRed;
            } else if (isSelected) {
              cardColor =
                  _accentColor.withValues(alpha: isDark ? 0.15 : 0.08);
              borderColor = _accentColor;
              labelBg = _accentColor;
              labelText = Colors.white;
              optionText = textPrimary;
            } else {
              cardColor =
                  isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
              borderColor = isDark
                  ? Colors.white12
                  : _accentColor.withValues(alpha: 0.25);
              labelBg = _accentColor.withValues(alpha: 0.15);
              labelText = _accentColor;
              optionText = textPrimary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: _answered ? null : () => _selectAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: labelBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: labelText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: optionText,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (isCorrectResult)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.check_circle_rounded,
                              color: AppColors.duoGreen, size: 20),
                        )
                      else if (isWrongResult)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.cancel_rounded,
                              color: AppColors.duoRed, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool isDark, AppLocalizations l, bool isLast) {
    final canGoBack = _currentIndex > 0;
    final textColor = isDark ? Colors.white : AppColors.duoTextDark;
    final disabledText = isDark ? Colors.white38 : AppColors.duoTextLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white12
                : AppColors.duoCardGrayShadow.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: isDark
                  ? AppColors.duoCardGray.withValues(alpha: 0.15)
                  : Colors.white,
              shadowColor:
                  isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
              shadowDepth: canGoBack ? 4 : 2,
              borderRadius: 16,
              onTap: canGoBack ? () => _goToQuestion(_currentIndex - 1) : null,
              child: Center(
                child: Text(
                  '← ${l.lesenBack}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: canGoBack ? textColor : disabledText,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GamifiedCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: _accentColor,
              shadowColor: _accentShadow,
              shadowDepth: 5,
              borderRadius: 16,
              onTap: _next,
              child: Center(
                child: Text(
                  isLast ? l.lesenFinish : l.lesenNextQuestion,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// To'liq ekranli rasm ko'ruvchi — yaqinlashtirish (pinch-zoom), surish va
/// ikki marta bosib kattalashtirish imkoniyati bilan.
class _ImageViewer extends StatefulWidget {
  final String imageUrl;

  const _ImageViewer({required this.imageUrl});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      // Allaqachon kattalashgan — asl holatga qaytaramiz
      _controller.value = Matrix4.identity();
    } else {
      // Bosilgan nuqtaga yaqinlashtiramiz (3x)
      final pos = _doubleTapDetails?.localPosition;
      if (pos == null) return;
      const scale = 3.0;
      final x = -pos.dx * (scale - 1);
      final y = -pos.dy * (scale - 1);
      _controller.value = Matrix4.identity()
        ..setEntry(0, 0, scale)
        ..setEntry(1, 1, scale)
        ..setEntry(0, 3, x)
        ..setEntry(1, 3, y);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTapDown: (d) => _doubleTapDetails = d,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1.0,
              maxScale: 5.0,
              child: Center(
                child: Hero(
                  tag: widget.imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, _) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, _, __) => const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Yopish tugmasi
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
