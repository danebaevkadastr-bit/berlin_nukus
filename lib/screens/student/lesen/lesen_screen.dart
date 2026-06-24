import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import '../../../widgets/level_picker_sheet.dart';
import 'lesen_data.dart';
import 'lesen_question_screen.dart';

class LesenScreen extends StatefulWidget {
  const LesenScreen({super.key});

  @override
  State<LesenScreen> createState() => _LesenScreenState();
}

class _LesenScreenState extends State<LesenScreen> {
  String _selectedLevel = 'B1';

  // teilNumber → {correct, wrong}
  final Map<int, int> _correctMap = {};
  final Map<int, int> _wrongMap = {};

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2'];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, int> correct = {};
    final Map<int, int> wrong = {};

    // Hozircha faqat B1 ma'lumotlari mavjud.
    if (_selectedLevel == 'B1') {
      for (final teil in lesenB1.teile) {
        int c = 0, w = 0;
        for (int i = 0; i < teil.questions.length; i++) {
          final val = prefs.getString(
              'lesen_${_selectedLevel}_teil${teil.teilNumber}_q$i');
          if (val == 'true') c++;
          if (val == 'false') w++;
        }
        correct[teil.teilNumber] = c;
        wrong[teil.teilNumber] = w;
      }
    }

    if (mounted) {
      setState(() {
        _correctMap
          ..clear()
          ..addAll(correct);
        _wrongMap
          ..clear()
          ..addAll(wrong);
      });
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.duoGreen;
      case 'A2':
        return AppColors.duoBlue;
      case 'B1':
        return AppColors.duoOrange;
      case 'B2':
        return AppColors.duoRed;
      default:
        return AppColors.duoBlue;
    }
  }

  Color _levelShadow(String level) {
    switch (level) {
      case 'A1':
        return AppColors.duoGreenShadow;
      case 'A2':
        return AppColors.duoBlueShadow;
      case 'B1':
        return AppColors.duoOrangeShadow;
      case 'B2':
        return AppColors.duoRedShadow;
      default:
        return AppColors.duoBlueShadow;
    }
  }

  String _levelName(AppLocalizations l, String level) {
    switch (level) {
      case 'A1':
        return l.lesenA1LevelName;
      case 'A2':
        return l.lesenA2LevelName;
      case 'B1':
        return l.lesenB1LevelName;
      case 'B2':
        return l.lesenB2LevelName;
      default:
        return level;
    }
  }

  void _showLevelPicker(AppLocalizations l, bool isDark) async {
    final selected = await LevelPickerSheet.show(
      context: context,
      isDark: isDark,
      title: l.lesenSelectLevel,
      levels: _levels,
      selectedLevel: _selectedLevel,
      levelName: (lvl) => _levelName(l, lvl),
      comingSoonLabel: l.lesenComingSoon,
      readyLevels: const {'B1'},
    );
    if (selected != null && selected != _selectedLevel) {
      setState(() => _selectedLevel = selected);
      _loadStats();
    }
  }

  void _openTeil(LesenTeil teil) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LesenQuestionScreen(
          teil: teil,
          level: _selectedLevel,
          titleOverride: _teilTitle(teil),
        ),
      ),
    ).then((_) => _loadStats());
  }

  /// Teil raqamiga qarab app bar sarlavhasini beradi.
  /// Sprachbausteine (4, 5) — alohida nomlanadi.
  String? _teilTitle(LesenTeil teil) {
    switch (teil.teilNumber) {
      case 4:
        return 'Sprachbausteine 1';
      case 5:
        return 'Sprachbausteine 2';
      default:
        return 'Teil ${teil.teilNumber}';
    }
  }

  void _showComingSoon(AppLocalizations l, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF1E2A32) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚧', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text(
                l.lesenComingSoon,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l.lesenComingSoonDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 24),
              GamifiedCard(
                color: AppColors.duoBlue,
                shadowColor: AppColors.duoBlueShadow,
                shadowDepth: 4,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onTap: () => Navigator.pop(ctx),
                child: const Center(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final levelColor = _levelColor(_selectedLevel);
    final levelShadow = _levelShadow(_selectedLevel);
    final isB1 = _selectedLevel == 'B1';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => _showLevelPicker(l, isDark),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l.lesenScreenTitle} – $_selectedLevel',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: isDark ? Colors.white70 : AppColors.duoTextLight,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            GamifiedCard(
              color: levelColor,
              shadowColor: levelShadow,
              shadowDepth: 6,
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: Colors.white, size: 44),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l.lesenScreenTitle} – $_selectedLevel',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _levelName(l, _selectedLevel),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showLevelPicker(l, isDark),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedLevel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.swap_vert_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'TEILE',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),

            // Teil 1
            _buildTeilCard(
              context,
              isDark: isDark,
              l: l,
              title: isB1 ? l.lesenB1Teil1Title : 'Teil 1',
              description: isB1 ? l.lesenB1Teil1Desc : '',
              note: isB1 ? l.lesenB1Teil1Note : '',
              headerIcon: Icons.title_rounded,
              color: AppColors.duoBlue,
              shadow: AppColors.duoBlueShadow,
              totalQuestions: isB1 ? lesenB1.teile[0].questions.length : 0,
              correct: _correctMap[1] ?? 0,
              wrong: _wrongMap[1] ?? 0,
              isAvailable: isB1,
              onTap: isB1
                  ? () => _openTeil(lesenB1.teile[0])
                  : () => _showComingSoon(l, isDark),
            ),
            const SizedBox(height: 14),

            // Teil 2
            _buildTeilCard(
              context,
              isDark: isDark,
              l: l,
              title: isB1 ? l.lesenB1Teil2Title : 'Teil 2',
              description: isB1 ? l.lesenB1Teil2Desc : '',
              note: isB1 ? l.lesenB1Teil2Note : '',
              headerIcon: Icons.article_rounded,
              color: AppColors.duoOrange,
              shadow: AppColors.duoOrangeShadow,
              totalQuestions: isB1 ? lesenB1.teile[1].questions.length : 0,
              correct: _correctMap[2] ?? 0,
              wrong: _wrongMap[2] ?? 0,
              isAvailable: isB1,
              onTap: isB1
                  ? () => _openTeil(lesenB1.teile[1])
                  : () => _showComingSoon(l, isDark),
            ),
            const SizedBox(height: 14),

            // Teil 3
            _buildTeilCard(
              context,
              isDark: isDark,
              l: l,
              title: isB1 ? l.lesenB1Teil3Title : 'Teil 3',
              description: isB1 ? l.lesenB1Teil3Desc : '',
              note: isB1 ? l.lesenB1Teil3Note : '',
              headerIcon: Icons.fact_check_rounded,
              color: AppColors.duoGreen,
              shadow: AppColors.duoGreenShadow,
              totalQuestions: isB1 ? lesenB1.teile[2].questions.length : 0,
              correct: _correctMap[3] ?? 0,
              wrong: _wrongMap[3] ?? 0,
              isAvailable: isB1,
              onTap: isB1
                  ? () => _openTeil(lesenB1.teile[2])
                  : () => _showComingSoon(l, isDark),
            ),

            // ── Sprachbausteine (faqat B1) ──────────────────────────────────
            if (isB1) ...[
              const SizedBox(height: 28),
              Text(
                l.lesenSprachbausteine.toUpperCase(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.lesenSprachbausteineDesc,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: isDark ? Colors.white60 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 14),

              // Sprachbausteine Teil 1 (grammatika)
              _buildTeilCard(
                context,
                isDark: isDark,
                l: l,
                title: l.lesenB1Teil4Title,
                description: l.lesenB1Teil4Desc,
                note: l.lesenB1Teil4Note,
                headerIcon: Icons.rule_rounded,
                color: AppColors.duoPurple,
                shadow: AppColors.duoPurpleShadow,
                totalQuestions: lesenB1.teile[3].questions.length,
                correct: _correctMap[4] ?? 0,
                wrong: _wrongMap[4] ?? 0,
                isAvailable: true,
                onTap: () => _openTeil(lesenB1.teile[3]),
              ),
              const SizedBox(height: 14),

              // Sprachbausteine Teil 2 (lug'at)
              _buildTeilCard(
                context,
                isDark: isDark,
                l: l,
                title: l.lesenB1Teil5Title,
                description: l.lesenB1Teil5Desc,
                note: l.lesenB1Teil5Note,
                headerIcon: Icons.translate_rounded,
                color: AppColors.duoBlue,
                shadow: AppColors.duoBlueShadow,
                totalQuestions: lesenB1.teile[4].questions.length,
                correct: _correctMap[5] ?? 0,
                wrong: _wrongMap[5] ?? 0,
                isAvailable: true,
                onTap: () => _openTeil(lesenB1.teile[4]),
              ),
            ],

            if (!isB1) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? AppColors.duoOrange.withValues(alpha: 0.1)
                      : AppColors.duoOrange.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.duoOrange.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🚧', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.lesenComingSoon,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.duoOrange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.lesenComingSoonDesc,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.duoTextLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeilCard(
    BuildContext context, {
    required bool isDark,
    required AppLocalizations l,
    required String title,
    required String description,
    required String note,
    required IconData headerIcon,
    required Color color,
    required Color shadow,
    required int totalQuestions,
    required int correct,
    required int wrong,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    final disabledColor =
        isDark ? Colors.white12 : AppColors.duoCardGrayShadow;
    final headerColor = isAvailable ? color : disabledColor;
    final headerTextColor = isAvailable
        ? Colors.white
        : (isDark ? Colors.white54 : AppColors.duoTextLight);

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark
          ? Colors.black26
          : (isAvailable ? shadow : AppColors.duoCardGrayShadow),
      shadowDepth: 5,
      padding: const EdgeInsets.all(0),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                bottom: BorderSide(
                  color: isAvailable ? shadow : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(headerIcon, color: headerTextColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: headerTextColor,
                    ),
                  ),
                ),
                if (!isAvailable)
                  Icon(
                    Icons.lock_rounded,
                    color: isDark ? Colors.white30 : AppColors.duoTextLight,
                    size: 18,
                  ),
              ],
            ),
          ),

          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      height: 1.4,
                    ),
                  ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isAvailable ? color : AppColors.duoCardGray)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: isAvailable
                              ? color
                              : (isDark
                                  ? Colors.white38
                                  : AppColors.duoTextLight),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isAvailable
                                  ? color
                                  : (isDark
                                      ? Colors.white38
                                      : AppColors.duoTextLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // ── Stats row ──
                Row(
                  children: [
                    _statChip(
                      isDark,
                      Icons.quiz_rounded,
                      '$totalQuestions',
                      l.lesenTotalQuestions,
                      (isAvailable ? color : AppColors.duoCardGray)
                          .withValues(alpha: isDark ? 0.15 : 0.12),
                      isAvailable
                          ? color
                          : (isDark
                              ? Colors.white54
                              : AppColors.duoTextLight),
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      isDark,
                      Icons.check_circle_rounded,
                      '$correct',
                      l.lesenCorrect,
                      AppColors.duoGreen.withValues(alpha: 0.15),
                      AppColors.duoGreen,
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      isDark,
                      Icons.cancel_rounded,
                      '$wrong',
                      l.lesenWrong,
                      AppColors.duoRed.withValues(alpha: 0.15),
                      AppColors.duoRed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(
    bool isDark,
    IconData icon,
    String value,
    String label,
    Color bg,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
