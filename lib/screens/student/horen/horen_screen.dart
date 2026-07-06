import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import '../../../widgets/level_picker_sheet.dart';
import 'horen_data.dart';
import 'horen_question_screen.dart';

class HorenScreen extends StatefulWidget {
  const HorenScreen({super.key});

  @override
  State<HorenScreen> createState() => _HorenScreenState();
}

class _HorenScreenState extends State<HorenScreen> {
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

    // Faqat ma'lumoti bor darajalar uchun statistikani yuklaymiz
    final currentLevel = _levelData(_selectedLevel);

    if (currentLevel != null) {
      for (final teil in currentLevel.teile) {
        int c = 0, w = 0;
        for (int i = 0; i < teil.questions.length; i++) {
          final val = prefs.getString(
              'horen_${_selectedLevel}_teil${teil.teilNumber}_q$i');
          if (val == 'true') c++;
          if (val == 'false') w++;
        }
        correct[teil.teilNumber] = c;
        wrong[teil.teilNumber] = w;
      }
    }

    if (mounted) {
      setState(() {
        // Eski darajaning raqamlari qolib ketmasligi uchun avval tozalaymiz
        _correctMap
          ..clear()
          ..addAll(correct);
        _wrongMap
          ..clear()
          ..addAll(wrong);
      });
    }
  }

  /// Daraja uchun ma'lumotlarni qaytaradi. Ma'lumoti yo'q darajalar (A2, B2)
  /// uchun null qaytaradi — shunda A1 kontenti noto'g'ri ko'rsatilmaydi.
  HorenLevel? _levelData(String level) {
    switch (level) {
      case 'A1':
        return horenA1;
      case 'B1':
        return horenB1;
      default:
        return null;
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
        return l.horenA1LevelName;
      case 'A2':
        return l.horenA2LevelName;
      case 'B1':
        return l.horenB1LevelName;
      case 'B2':
        return l.horenB2LevelName;
      default:
        return level;
    }
  }

  void _showLevelPicker(AppLocalizations l, bool isDark) async {
    final selected = await LevelPickerSheet.show(
      context: context,
      isDark: isDark,
      title: l.horenSelectLevel,
      levels: _levels,
      selectedLevel: _selectedLevel,
      levelName: (lvl) => _levelName(l, lvl),
      comingSoonLabel: l.horenComingSoon,
      readyLevels: const {'A1', 'B1'},
    );
    if (selected != null && selected != _selectedLevel) {
      setState(() => _selectedLevel = selected);
      _loadStats();
    }
  }

  void _openTeil(HorenTeil teil) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HorenQuestionScreen(
          teil: teil,
          level: _selectedLevel,
        ),
      ),
    ).then((_) => _loadStats());
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
              const Icon(Icons.construction_rounded,
                  size: 52, color: AppColors.duoOrange),
              const SizedBox(height: 16),
              Text(
                l.horenComingSoon,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l.horenComingSoonDesc,
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

    // Hozirgi daraja uchun ma'lumotlarni olish. null bo'lsa — kontent yo'q.
    final currentLevelData = _levelData(_selectedLevel);
    final hasData = currentLevelData != null;

    // B1 uchun maxsus title va description
    final teil1Title = isB1 ? l.horenB1Teil1Title : l.horenTeil1Title;
    final teil1Desc = isB1 ? l.horenB1Teil1Desc : l.horenTeil1Desc;
    final teil2Title = isB1 ? l.horenB1Teil2Title : l.horenTeil2Title;
    final teil2Desc = isB1 ? l.horenB1Teil2Desc : l.horenTeil2Desc;
    final teil3Title = isB1 ? l.horenB1Teil3Title : l.horenTeil3Title;
    final teil3Desc = isB1 ? l.horenB1Teil3Desc : l.horenTeil3Desc;

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
                '${l.horenScreenTitle} – $_selectedLevel',
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
                  const Icon(Icons.hearing_rounded,
                      color: Colors.white, size: 44),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l.horenScreenTitle} – $_selectedLevel',
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
              teilNumber: 1,
              title: teil1Title,
              description: teil1Desc,
              note: l.horenTeil1Note,
              headerIcon: Icons.record_voice_over_rounded,
              color: AppColors.duoBlue,
              shadow: AppColors.duoBlueShadow,
              totalQuestions:
                  hasData ? currentLevelData.teile[0].questions.length : 0,
              correct: _correctMap[1] ?? 0,
              wrong: _wrongMap[1] ?? 0,
              isAvailable: hasData,
              onTap: hasData
                  ? () => _openTeil(currentLevelData.teile[0])
                  : () => _showComingSoon(l, isDark),
            ),
            const SizedBox(height: 14),

            // Teil 2
            _buildTeilCard(
              context,
              isDark: isDark,
              l: l,
              teilNumber: 2,
              title: teil2Title,
              description: teil2Desc,
              note: l.horenTeil2Note,
              headerIcon: Icons.campaign_rounded,
              color: AppColors.duoOrange,
              shadow: AppColors.duoOrangeShadow,
              totalQuestions:
                  hasData ? currentLevelData.teile[1].questions.length : 0,
              correct: _correctMap[2] ?? 0,
              wrong: _wrongMap[2] ?? 0,
              isAvailable: hasData,
              onTap: hasData
                  ? () => _openTeil(currentLevelData.teile[1])
                  : () => _showComingSoon(l, isDark),
            ),
            const SizedBox(height: 14),

            // Teil 3
            _buildTeilCard(
              context,
              isDark: isDark,
              l: l,
              teilNumber: 3,
              title: teil3Title,
              description: teil3Desc,
              note: l.horenTeil3Note,
              headerIcon: Icons.short_text_rounded,
              color: AppColors.duoGreen,
              shadow: AppColors.duoGreenShadow,
              totalQuestions:
                  hasData ? currentLevelData.teile[2].questions.length : 0,
              correct: _correctMap[3] ?? 0,
              wrong: _wrongMap[3] ?? 0,
              isAvailable: hasData,
              onTap: hasData
                  ? () => _openTeil(currentLevelData.teile[2])
                  : () => _showComingSoon(l, isDark),
            ),

            if (!hasData) ...[
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
                    const Icon(Icons.construction_rounded,
                        size: 28, color: AppColors.duoOrange),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tez kunda',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.duoOrange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.horenComingSoonDesc,
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
    required int teilNumber,
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
      shadowColor: isDark ? Colors.black26 : (isAvailable ? shadow : AppColors.duoCardGrayShadow),
      shadowDepth: 5,
      padding: const EdgeInsets.all(0),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                // Note chip
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
                const SizedBox(height: 14),
                // ── Stats row ──
                Row(
                  children: [
                    _statChip(
                      isDark,
                      Icons.quiz_rounded,
                      '$totalQuestions',
                      l.horenTotalQuestions,
                      (isAvailable ? color : AppColors.duoCardGray)
                          .withValues(alpha: isDark ? 0.15 : 0.12),
                      isAvailable
                          ? color
                          : (isDark ? Colors.white54 : AppColors.duoTextLight),
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      isDark,
                      Icons.check_circle_rounded,
                      '$correct',
                      l.horenCorrect,
                      AppColors.duoGreen.withValues(alpha: 0.15),
                      AppColors.duoGreen,
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      isDark,
                      Icons.cancel_rounded,
                      '$wrong',
                      l.horenWrong,
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
