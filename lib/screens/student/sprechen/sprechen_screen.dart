import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import '../../../widgets/level_picker_sheet.dart';
import 'sprechen_data.dart';
import 'sprechen_teil_screen.dart';

class SprechenScreen extends StatefulWidget {
  const SprechenScreen({super.key});

  @override
  State<SprechenScreen> createState() => _SprechenScreenState();
}

class _SprechenScreenState extends State<SprechenScreen> {
  String _selectedLevel = 'A1';

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2'];

  SprechenLevel get _data {
    switch (_selectedLevel) {
      case 'A1':
        return sprechenA1;
      case 'A2':
        return sprechenA2;
      case 'B1':
        return sprechenB1;
      case 'B2':
        return sprechenB2;
      default:
        return sprechenA1;
    }
  }

  Color _levelColor(String level) => LevelPickerSheet.levelColor(level);
  Color _levelShadow(String level) => LevelPickerSheet.levelShadow(level);

  String _levelName(AppLocalizations l, String level) {
    switch (level) {
      case 'A1':
        return l.sprechenA1LevelName;
      case 'A2':
        return l.sprechenA2LevelName;
      case 'B1':
        return l.sprechenB1LevelName;
      case 'B2':
        return l.sprechenB2LevelName;
      default:
        return level;
    }
  }

  void _showLevelPicker(AppLocalizations l, bool isDark) async {
    final selected = await LevelPickerSheet.show(
      context: context,
      isDark: isDark,
      title: l.sprechenSelectLevel,
      levels: _levels,
      selectedLevel: _selectedLevel,
      levelName: (lvl) => _levelName(l, lvl),
      comingSoonLabel: l.sprechenComingSoon,
    );
    if (selected != null && selected != _selectedLevel) {
      setState(() => _selectedLevel = selected);
    }
  }

  void _openTeil(SprechenTeil teil) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SprechenTeilScreen(
          teil: teil,
          level: _selectedLevel,
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
    final teile = _data.teile;

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
                '${l.sprechenScreenTitle} – $_selectedLevel',
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
                  const Icon(Icons.record_voice_over_rounded,
                      color: Colors.white, size: 44),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l.sprechenScreenTitle} – $_selectedLevel',
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

            const SizedBox(height: 20),

            // Info chip — bu bo'lim baholanmaydi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: levelColor.withValues(alpha: isDark ? 0.12 : 0.08),
                border: Border.all(
                  color: levelColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: levelColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.sprechenHint,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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

            ...teile.asMap().entries.map((entry) {
              final i = entry.key;
              final teil = entry.value;
              final colors = [
                AppColors.duoBlue,
                AppColors.duoOrange,
                AppColors.duoGreen,
                AppColors.duoRed,
              ];
              final shadows = [
                AppColors.duoBlueShadow,
                AppColors.duoOrangeShadow,
                AppColors.duoGreenShadow,
                AppColors.duoRedShadow,
              ];
              final color = colors[i % colors.length];
              final shadow = shadows[i % shadows.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildTeilCard(
                  isDark: isDark,
                  teil: teil,
                  color: color,
                  shadow: shadow,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTeilCard({
    required bool isDark,
    required SprechenTeil teil,
    required Color color,
    required Color shadow,
  }) {
    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : shadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(0),
      onTap: () => _openTeil(teil),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                bottom: BorderSide(color: shadow, width: 3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '${teil.teilNumber}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Teil ${teil.teilNumber} – ${teil.title}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teil.description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_rounded, size: 13, color: color),
                      const SizedBox(width: 6),
                      Text(
                        teil.tests.isNotEmpty
                            ? '${teil.tests.length} ${AppLocalizations.of(context).sprechenTest}'
                            : '${teil.aufgaben.length} ${AppLocalizations.of(context).sprechenTasks}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
