import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';

import '../../services/vocabulary_service.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<SavedWord> _savedWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedWords();
  }

  Future<void> _loadSavedWords() async {
    setState(() => _isLoading = true);
    _savedWords = await VocabularyService.getSavedWords();
    setState(() => _isLoading = false);
  }



  int get _learningWordsCount => _savedWords.where((w) => w.learningStage > 0 && w.learningStage < 3).length;
  int get _newWordsCount => _savedWords.where((w) => w.learningStage == 0).length;
  int get _allWordsCount => _savedWords.length;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          "Mening lug'atim",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    children: [
                      // O'rganilayotgan so'zlar
                      _CategoryCard(
                        title: "O'rganilayotgan so'zlar",
                        count: _learningWordsCount,
                        color: AppColors.duoBlue,
                        shadowColor: AppColors.duoBlueShadow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordListScreen(
                                title: "O'rganilayotgan so'zlar",
                                words: _savedWords.where((w) => w.learningStage > 0 && w.learningStage < 3).toList(),
                                onUpdate: () {
                                  _loadSavedWords();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Yangi so'zlar
                      _CategoryCard(
                        title: "Yangi so'zlar",
                        count: _newWordsCount,
                        color: AppColors.duoPurple,
                        shadowColor: AppColors.duoPurpleShadow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordListScreen(
                                title: "Yangi so'zlar",
                                words: _savedWords.where((w) => w.learningStage == 0).toList(),
                                onUpdate: () {
                                  _loadSavedWords();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Barcha so'zlar
                      _CategoryCard(
                        title: "Barcha so'zlar",
                        count: _allWordsCount,
                        color: AppColors.duoOrange,
                        shadowColor: AppColors.duoOrangeShadow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordListScreen(
                                title: "Barcha so'zlar",
                                words: _savedWords,
                                onUpdate: () {
                                  _loadSavedWords();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Statistika
                      _StatisticsCard(
                        learningCount: _learningWordsCount,
                        newCount: _newWordsCount,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GamifiedCard(
      color: color,
      shadowColor: shadowColor,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: shadowColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsCard extends StatefulWidget {
  final int learningCount;
  final int newCount;

  const _StatisticsCard({
    required this.learningCount,
    required this.newCount,
  });

  @override
  State<_StatisticsCard> createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<_StatisticsCard> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['7 kun', '1 oy', '6 oy', '1 yil'];

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.transparent : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : AppColors.duoCardGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected 
                                ? (isDark ? Colors.black87 : AppColors.duoTextDark)
                                : (isDark ? Colors.white54 : AppColors.duoTextLight),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          
          // Chart Mockup
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Y-axis
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 1; i >= 0; i--)
                      Expanded(
                        flex: i == 1 ? 1 : 0,
                        child: Align(
                          alignment: i == 1 ? Alignment.topCenter : Alignment.bottomCenter,
                          child: Text(
                            '$i',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : AppColors.duoTextLight,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                // Graph Area
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: _MockChartPainter(
                            isDark: isDark,
                            lineColor: isDark ? Colors.white24 : Colors.black12,
                          ),
                          child: Container(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // X-axis
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['Shan', 'Yak', 'Du', 'Se', 'Chor', 'Pay', 'Ju'].map((day) {
                          return Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : AppColors.duoTextLight,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    _tabs[_selectedIndex],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: isDark ? Colors.white12 : AppColors.duoCardGray,
                ),
              ],
            ),
          ),
          Container(height: 1, color: isDark ? Colors.white12 : AppColors.duoCardGray),

          // Legends Table
          _LegendTableRow(
            count: '${widget.newCount}',
            label: "Yangi so'zlar",
            color: AppColors.duoBlue,
            isDark: isDark,
          ),
          _LegendTableRow(
            count: '${widget.learningCount}',
            label: "O'rganilayotgan so'zlar",
            color: AppColors.duoOrange,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _LegendTableRow extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final bool isDark;

  const _LegendTableRow({
    required this.count,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white12 : AppColors.duoCardGray),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: isDark ? Colors.white12 : AppColors.duoCardGray,
          ),
          const SizedBox(width: 16),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.duoTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockChartPainter extends CustomPainter {
  final bool isDark;
  final Color lineColor;

  _MockChartPainter({required this.isDark, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final borderPaint = Paint()
      ..color = isDark ? Colors.white54 : AppColors.duoTextDark
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw left and bottom borders
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), borderPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), borderPaint);

    // Draw dashed vertical lines and horizontal lines
    final double stepX = size.width / 6;
    final double stepY = size.height / 5;

    for (int i = 1; i <= 6; i++) {
      _drawDashedLine(
        canvas,
        Offset(i * stepX, 0),
        Offset(i * stepX, size.height),
        paint,
      );
    }
    
    for (int i = 1; i <= 5; i++) {
      _drawDashedLine(
        canvas,
        Offset(0, i * stepY),
        Offset(size.width, i * stepY),
        paint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    double startY = p1.dy;
    
    final distance = (p2 - p1).distance;
    final dx = (p2.dx - p1.dx) / distance;
    final dy = (p2.dy - p1.dy) / distance;

    double drawn = 0.0;
    while (drawn < distance) {
      final x1 = startX + dx * drawn;
      final y1 = startY + dy * drawn;
      
      drawn += dashWidth;
      if (drawn > distance) drawn = distance;
      
      final x2 = startX + dx * drawn;
      final y2 = startY + dy * drawn;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      drawn += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Yangi ekran - so'zlar ro'yxati
class WordListScreen extends StatefulWidget {
  final String title;
  final List<SavedWord> words;
  final VoidCallback onUpdate;

  const WordListScreen({
    super.key,
    required this.title,
    required this.words,
    required this.onUpdate,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
            onPressed: () {
              // Info dialog
            },
          ),
        ],
      ),
      body: widget.words.isEmpty
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Sizda hali so'zlar yo'q",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _TimelineStage(
                    number: 1,
                    title: "Darslikdan yangi so'zlar qo'shing — ular shu yerda saqlanadi.",
                    isActive: false,
                    isCompleted: false,
                    onTap: () {},
                  ),
                  const _TimelineConnector(isActive: false),
                  _TimelineStage(
                    number: 2,
                    title: "So'zlarni o'rganishni boshlasangiz, ular \"O'rganilayotgan so'zlar\" bo'limida saqlanadi.",
                    isActive: false,
                    isCompleted: false,
                    onTap: () {},
                  ),
                  const _TimelineConnector(isActive: false),
                  _TimelineStage(
                    number: 3,
                    title: "To'liq o'zlashtirilgan so'zlar \"Hamma so'zlar\" bo'limiga o'tadi.",
                    isActive: false,
                    isCompleted: false,
                    onTap: () {},
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.words.length,
              itemBuilder: (context, index) {
                final word = widget.words[index];
                return _WordTimelineCard(
                  word: word,
                  onStageChange: (newStage) async {
                    setState(() {
                      word.learningStage = newStage;
                    });
                    
                    // Save to SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    final raw = prefs.getString('saved_vocabulary') ?? '[]';
                    final list = jsonDecode(raw) as List<dynamic>;
                    final allWords = list
                        .map((e) => SavedWord.fromMap(Map<String, dynamic>.from(e as Map)))
                        .toList();
                    
                    final wordIndex = allWords.indexWhere((w) => w.germanWord == word.germanWord);
                    if (wordIndex != -1) {
                      allWords[wordIndex] = word;
                      await prefs.setString('saved_vocabulary', jsonEncode(allWords.map((w) => w.toMap()).toList()));
                    }
                    
                    widget.onUpdate();
                  },
                );
              },
            ),
    );
  }
}

class _WordTimelineCard extends StatelessWidget {
  final SavedWord word;
  final Function(int) onStageChange;

  const _WordTimelineCard({
    required this.word,
    required this.onStageChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // So'z nomi
          Text(
            word.germanWord,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // Timeline
          _TimelineStage(
            number: 1,
            title: "Darslikdan yangi so'zlar qo'shing — ular shu yerda saqlanadi.",
            isActive: word.learningStage >= 1,
            isCompleted: word.learningStage > 1,
            onTap: () => onStageChange(1),
          ),
          _TimelineConnector(isActive: word.learningStage > 1),
          _TimelineStage(
            number: 2,
            title: "So'zlarni o'rganishni boshlasangiz, ular \"O'rganilayotgan so'zlar\" bo'limida saqlanadi.",
            isActive: word.learningStage >= 2,
            isCompleted: word.learningStage > 2,
            onTap: () => onStageChange(2),
          ),
          _TimelineConnector(isActive: word.learningStage > 2),
          _TimelineStage(
            number: 3,
            title: "To'liq o'zlashtirilgan so'zlar \"Hamma so'zlar\" bo'limiga o'tadi.",
            isActive: word.learningStage >= 3,
            isCompleted: word.learningStage >= 3,
            onTap: () => onStageChange(3),
          ),
        ],
      ),
    );
  }
}

class _TimelineStage extends StatelessWidget {
  final int number;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  const _TimelineStage({
    required this.number,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF8B7BA8) : (isDark ? Colors.white24 : Colors.grey[300]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Description
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  final bool isActive;

  const _TimelineConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: Container(
        width: 2,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isActive
                ? [const Color(0xFF8B7BA8), const Color(0xFF8B7BA8)]
                : [Colors.grey[300]!, Colors.grey[300]!],
          ),
        ),
        child: CustomPaint(
          painter: _DottedLinePainter(isActive: isActive),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final bool isActive;

  _DottedLinePainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? const Color(0xFF8B7BA8) : Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5;
    const dashSpace = 5;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


