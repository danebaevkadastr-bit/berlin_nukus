import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_manager.dart';
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

  void _showAddWordDialog(BuildContext context) {
    final controller = TextEditingController();
    bool isTranslating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = ThemeManager.isDark;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Yangi nemischa so'z qo'shish",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.duoTextDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Nemischa so'z, ibora yoki so'zlar ro'yxatini yozing. AI har birini o'zi tahlil qilib, tarjima va grammatikasini aniqlaydi.",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLines: 5,
                      minLines: 2,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: "Masalan:\ndie Entscheidung\nverstehen\nder Tisch\nyoki so'zlar ro'yxatini joylashtiring...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : AppColors.duoTextLight,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white12 : AppColors.duoBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.duoGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: isTranslating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                        label: Text(
                          isTranslating ? "AI so'zlarni ajratib tarjima qilmoqda..." : "AI bilan tahlil qilib qo'shish",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: isTranslating
                            ? null
                            : () async {
                                final text = controller.text.trim();
                                if (text.isEmpty) return;
                                setModalState(() => isTranslating = true);
                                try {
                                  final count = await VocabularyService.addBulkWordsWithAi(
                                    text: text,
                                    uiLangCode: LocaleManager.code,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _loadSavedWords();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$count ta so\'z muvaffaqiyatli tahlil qilindi va lug\'atga qo\'shildi!'),
                                        backgroundColor: AppColors.duoGreen,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setModalState(() => isTranslating = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Xato: $e')),
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.duoGreen,
        elevation: 4,
        onPressed: () => _showAddWordDialog(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          "Nemischa so'z qo'shish",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
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
                        savedWords: _savedWords,
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
  final List<SavedWord> savedWords;
  final int learningCount;
  final int newCount;

  const _StatisticsCard({
    required this.savedWords,
    required this.learningCount,
    required this.newCount,
  });

  @override
  State<_StatisticsCard> createState() => _StatisticsCardState();
}

class _ChartDataPoint {
  final String label;
  final int newCount;
  final int learningCount;

  _ChartDataPoint({
    required this.label,
    required this.newCount,
    required this.learningCount,
  });

  int get total => newCount + learningCount;
}

class _StatisticsCardState extends State<_StatisticsCard> {
  int _selectedIndex = 0;
  int? _touchedBarIndex;
  final List<String> _tabs = ['7 kun', '1 oy', '6 oy', '1 yil'];

  List<_ChartDataPoint> _getChartData() {
    final now = DateTime.now();

    if (_selectedIndex == 0) {
      // 7 kun
      const dayNames = ['Du', 'Se', 'Chor', 'Pay', 'Ju', 'Shan', 'Yak'];
      return List.generate(7, (i) {
        final date = now.subtract(Duration(days: 6 - i));
        final dayLabel = dayNames[date.weekday - 1];
        final wordsOnDate = widget.savedWords.where((w) =>
            w.savedAt.year == date.year &&
            w.savedAt.month == date.month &&
            w.savedAt.day == date.day);
        final newC = wordsOnDate.where((w) => w.learningStage == 0).length;
        final learnC = wordsOnDate.where((w) => w.learningStage > 0).length;
        return _ChartDataPoint(
          label: dayLabel,
          newCount: newC,
          learningCount: learnC,
        );
      });
    } else if (_selectedIndex == 1) {
      // 1 oy (4 hafta)
      return List.generate(4, (i) {
        final startDays = (3 - i) * 7;
        final endDays = startDays - 7;
        final startDate = now.subtract(Duration(days: startDays));
        final endDate = now.subtract(Duration(days: endDays < 0 ? 0 : endDays));
        final wordsInWeek = widget.savedWords.where((w) =>
            w.savedAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            w.savedAt.isBefore(endDate.add(const Duration(days: 1))));
        final newC = wordsInWeek.where((w) => w.learningStage == 0).length;
        final learnC = wordsInWeek.where((w) => w.learningStage > 0).length;
        return _ChartDataPoint(
          label: '${i + 1}-h',
          newCount: newC,
          learningCount: learnC,
        );
      });
    } else if (_selectedIndex == 2) {
      // 6 oy
      const monthNames = [
        'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
        'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
      ];
      return List.generate(6, (i) {
        final mOffset = 5 - i;
        var month = now.month - mOffset;
        var year = now.year;
        while (month <= 0) {
          month += 12;
          year -= 1;
        }
        final wordsInMonth = widget.savedWords.where(
            (w) => w.savedAt.year == year && w.savedAt.month == month);
        final newC = wordsInMonth.where((w) => w.learningStage == 0).length;
        final learnC = wordsInMonth.where((w) => w.learningStage > 0).length;
        return _ChartDataPoint(
          label: monthNames[month - 1],
          newCount: newC,
          learningCount: learnC,
        );
      });
    } else {
      // 1 yil (12 oy)
      const monthNames = [
        'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
        'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
      ];
      return List.generate(12, (i) {
        final mOffset = 11 - i;
        var month = now.month - mOffset;
        var year = now.year;
        while (month <= 0) {
          month += 12;
          year -= 1;
        }
        final wordsInMonth = widget.savedWords.where(
            (w) => w.savedAt.year == year && w.savedAt.month == month);
        final newC = wordsInMonth.where((w) => w.learningStage == 0).length;
        final learnC = wordsInMonth.where((w) => w.learningStage > 0).length;
        return _ChartDataPoint(
          label: monthNames[month - 1],
          newCount: newC,
          learningCount: learnC,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final chartData = _getChartData();

    int maxCount = chartData.fold<int>(
        0, (max, p) => p.total > max ? p.total : max);
    if (maxCount == 0) maxCount = 5;

    final periodNewTotal = chartData.fold<int>(0, (sum, p) => sum + p.newCount);
    final periodLearnTotal = chartData.fold<int>(0, (sum, p) => sum + p.learningCount);

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
                        _touchedBarIndex = null;
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
                            fontSize: 13,
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
          const SizedBox(height: 20),

          // Interaktiv Dinamik Bar Chart
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-Axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$maxCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                    Text(
                      '${(maxCount / 2).round()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Chart Columns Area
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final chartHeight = constraints.maxHeight;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(chartData.length, (idx) {
                                final p = chartData[idx];
                                final isTouched = _touchedBarIndex == idx;

                                final double totalHeightFactor =
                                    maxCount > 0 ? (p.total / maxCount) : 0.0;
                                final double barHeight =
                                    (totalHeightFactor * chartHeight).clamp(0.0, chartHeight);

                                final double newRatio =
                                    p.total > 0 ? (p.newCount / p.total) : 0.5;
                                final double learnRatio =
                                    p.total > 0 ? (p.learningCount / p.total) : 0.5;

                                return Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _touchedBarIndex =
                                            _touchedBarIndex == idx ? null : idx;
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Tooltip indicator when touched
                                        if (isTouched)
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.duoPurple,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${p.total}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        // Bar Column
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOutCubic,
                                          height: barHeight == 0 ? 4 : barHeight,
                                          width: isTouched ? 16 : 12,
                                          decoration: BoxDecoration(
                                            color: barHeight == 0
                                                ? (isDark
                                                    ? Colors.white12
                                                    : Colors.black12)
                                                : null,
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: isTouched
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.duoBlue
                                                          .withValues(alpha: 0.4),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          child: barHeight > 0
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Column(
                                                    children: [
                                                      if (p.learningCount > 0)
                                                        Expanded(
                                                          flex: (learnRatio * 100).round(),
                                                          child: Container(
                                                            color: AppColors.duoOrange,
                                                          ),
                                                        ),
                                                      if (p.newCount > 0)
                                                        Expanded(
                                                          flex: (newRatio * 100).round(),
                                                          child: Container(
                                                            color: AppColors.duoBlue,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // X-Axis labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: chartData.map((p) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                p.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                ),
                              ),
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
          const SizedBox(height: 20),

          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    _tabs[_selectedIndex],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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

          // Dynamic Legends Table
          _LegendTableRow(
            count: '$periodNewTotal',
            label: "Yangi so'zlar",
            color: AppColors.duoBlue,
            isDark: isDark,
          ),
          _LegendTableRow(
            count: '$periodLearnTotal',
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
            width: 90,
            child: Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
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
            width: 14,
            height: 14,
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Builder(builder: (context) {
                final l = AppLocalizations.of(context);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      l.noWordsYet,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Bosqich 1 — belgi chapda
                    _EmptyStageRow(
                      number: 1,
                      title: l.vocabStage1Desc,
                      badgeOnLeft: true,
                      isDark: isDark,
                    ),
                    const _SnakeConnector(leftToRight: true),
                    // Bosqich 2 — belgi o'ngda
                    _EmptyStageRow(
                      number: 2,
                      title: l.vocabStage2Desc,
                      badgeOnLeft: false,
                      isDark: isDark,
                    ),
                    const _SnakeConnector(leftToRight: false),
                    // Bosqich 3 — belgi chapda
                    _EmptyStageRow(
                      number: 3,
                      title: l.vocabStage3Desc,
                      badgeOnLeft: true,
                      isDark: isDark,
                    ),
                  ],
                );
              }),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.words.length,
              itemBuilder: (context, index) {
                final word = widget.words[index];
                return _WordTimelineCard(
                  word: word,
                  onDelete: () async {
                    await VocabularyService.deleteWord(word.germanWord);
                    setState(() {
                      widget.words.removeAt(index);
                    });
                    widget.onUpdate();
                  },
                  onStageChange: (newStage) async {
                    setState(() {
                      word.learningStage = newStage;
                    });
                    
                    final allWords = await VocabularyService.getSavedWords();
                    final wordIndex = allWords.indexWhere((w) => w.germanWord.toLowerCase() == word.germanWord.toLowerCase());
                    if (wordIndex != -1) {
                      allWords[wordIndex] = word;
                      await VocabularyService.saveWords(allWords);
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
  final VoidCallback onDelete;

  const _WordTimelineCard({
    required this.word,
    required this.onStageChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.duoCardGray,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  word.germanWord,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                tooltip: "O'chirish",
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ma'nolari (tarjima + misol gaplar)
          ...word.meanings.map((m) => _MeaningBlock(meaning: m, isDark: isDark)),

          const SizedBox(height: 16),
          Container(height: 1, color: isDark ? Colors.white12 : AppColors.duoCardGray),
          const SizedBox(height: 16),

          // O'rganish bosqichi selektori
          Builder(builder: (context) {
            final l = AppLocalizations.of(context);
            return Row(
              children: [
                Text(
                  l.learningStageLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white54 : AppColors.duoTextLight,
                  ),
                ),
                const Spacer(),
                for (int i = 1; i <= 3; i++) ...[
                  if (i > 1) const SizedBox(width: 8),
                  _StageDot(
                    number: i,
                    isActive: word.learningStage >= i,
                    onTap: () => onStageChange(i),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  final WordMeaning meaning;
  final bool isDark;

  const _MeaningBlock({required this.meaning, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjima
          if (meaning.translation.isNotEmpty)
            Text(
              meaning.translation,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          // Grammatik ma'lumot
          if (meaning.grammar.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                meaning.grammar,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white54 : AppColors.duoBlue,
                ),
              ),
            ),
          // Misol gap (nemis)
          if (meaning.exampleGerman.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                meaning.exampleGerman,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white60 : AppColors.duoTextLight,
                ),
              ),
            ),
          // Misol gap (o'zbek)
          if (meaning.exampleUzbek.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                meaning.exampleUzbek,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StageDot extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback onTap;

  const _StageDot({
    required this.number,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? _kStageColor : (isDark ? Colors.white12 : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? const [BoxShadow(color: _kStageShadow, offset: Offset(0, 3), blurRadius: 0)]
              : null,
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : (isDark ? Colors.white38 : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bo'sh holat: zigzag (ilon) tartibidagi bosqichlar ──────────────────────────
const Color _kStageColor = Color(0xFF8B7BA8);
const Color _kStageShadow = Color(0xFF6F5F8C);

class _EmptyStageRow extends StatelessWidget {
  final int number;
  final String title;
  final bool badgeOnLeft;
  final bool isDark;

  const _EmptyStageRow({
    required this.number,
    required this.title,
    required this.badgeOnLeft,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final badge = _StageBadge(number: number);
    final bubble = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.duoCardGray.withValues(alpha: 0.12)
              : const Color(0xFFF1EDF5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: isDark ? Colors.white70 : const Color(0xFF4A4458),
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: badgeOnLeft
          ? [badge, const SizedBox(width: 20), bubble]
          : [bubble, const SizedBox(width: 20), badge],
    );
  }
}

class _StageBadge extends StatelessWidget {
  final int number;

  const _StageBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _kStageColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: _kStageShadow,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Bosqichlarni bog'lovchi egri (ilon shaklidagi) chiziqli punktir.
/// [leftToRight] true bo'lsa chapdagi belgidan o'ngdagi belgiga,
/// false bo'lsa o'ngdan chapga buriladi.
class _SnakeConnector extends StatelessWidget {
  final bool leftToRight;

  const _SnakeConnector({required this.leftToRight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: CustomPaint(
        painter: _SnakePainter(leftToRight: leftToRight),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final bool leftToRight;

  _SnakePainter({required this.leftToRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kStageColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Belgilar markazi (64px belgi kengligining yarmi = 32)
    const double badgeCenter = 32;
    final double startX = leftToRight ? badgeCenter : size.width - badgeCenter;
    final double endX = leftToRight ? size.width - badgeCenter : badgeCenter;
    const double radius = 18;

    final path = Path()..moveTo(startX, 0);
    // Pastga tushish
    path.lineTo(startX, size.height / 2 - radius);
    // Gorizontalga buriladigan burchak
    path.arcToPoint(
      Offset(startX + (leftToRight ? radius : -radius), size.height / 2),
      radius: const Radius.circular(18),
      clockwise: !leftToRight,
    );
    // Gorizontal yo'l
    path.lineTo(endX - (leftToRight ? radius : -radius), size.height / 2);
    // Pastga buriladigan burchak
    path.arcToPoint(
      Offset(endX, size.height / 2 + radius),
      radius: const Radius.circular(18),
      clockwise: leftToRight,
    );
    // Pastki belgigacha tushish
    path.lineTo(endX, size.height);

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path source, Paint paint) {
    const double dashWidth = 7;
    const double dashSpace = 6;
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) =>
      oldDelegate.leftToRight != leftToRight;
}



