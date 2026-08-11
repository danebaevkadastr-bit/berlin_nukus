import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Bo'limlar bo'ylab bir xil ko'rinishdagi daraja tanlash paneli (bottom sheet).
///
/// Hören, Lesen, Conversations va boshqa bo'limlar shu widgetdan foydalanadi —
/// shunda daraja tanlash UI'si hamma joyda bir xil bo'ladi.
///
/// Standart ranglar: A1=yashil, A2=ko'k, B1=to'q sariq, B2=qizil.
class LevelPickerSheet {
  /// Daraja tanlash panelini ko'rsatadi va tanlangan darajani qaytaradi
  /// (bekor qilinsa null).
  static Future<String?> show({
    required BuildContext context,
    required bool isDark,
    required String title,
    required List<String> levels,
    required String selectedLevel,
    required String Function(String level) levelName,
    required String comingSoonLabel,
    Set<String> readyLevels = const {},
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : AppColors.duoCardGrayShadow,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...levels.map((level) {
                  final isSelected = selectedLevel == level;
                  final color = levelColor(level);
                  // readyLevels bo'sh bo'lsa — barcha darajalar tayyor deb hisoblanadi.
                  final isReady =
                      readyLevels.isEmpty || readyLevels.contains(level);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.pop(sheetContext, level),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.1)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : AppColors.duoBackground),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? color.withValues(alpha: 0.5)
                                : (isDark
                                    ? Colors.white12
                                    : AppColors.duoCardGrayShadow),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: levelShadow(level), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: levelShadow(level),
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                level,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        level,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.duoTextDark,
                                        ),
                                      ),
                                      if (!isReady) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.duoOrange
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            comingSoonLabel,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.duoOrange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    levelName(level),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.duoTextLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  color: color, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Standart daraja rangi (butun ilova bo'ylab bir xil).
  static Color levelColor(String level) {
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
        return AppColors.duoGreen;
    }
  }

  /// Standart daraja soyasi.
  static Color levelShadow(String level) {
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
        return AppColors.duoGreenShadow;
    }
  }
}
